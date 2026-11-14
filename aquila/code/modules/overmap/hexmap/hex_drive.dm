// AQUILA - skok FTL po hexach. Skok zużywa część naładowania napędu (1/3 za kafel, 2/3 za bramę) zamiast całego,
// a po skoku napęd przez HEX_FTL_COOLDOWN stygnie i się nie ładuje. Napęd zostaje włączony; wyłącza się tylko,
// gdy skok zużyje cały ładunek, i wtedy inżynieria musi go włączyć ponownie. Działa dla obu napędów:
// komputera Seegson (ftl_legacy.dm, nasze okręty) i napędu Thirringa z pylonami (drive.dm).

/obj/structure/overmap
	/// Koszt zaplanowanego skoku po hexach, w procentach; 0 = skok nie jest skokiem po hexach (powrót, admin)
	var/hex_pending_cost = 0
	/// Liczba hexów zaplanowanego skoku (do czasu lotu)
	var/hex_pending_hexes = 0
	/// Do kiedy napęd stygnie po skoku
	var/hex_cooldown_until = 0
	/// Kiedy zaplanowano skok: plan przerwany przez interdykcję nie może przejść na następny, niezwiązany skok
	var/hex_pending_time = 0

/// Plan skoku po hexach na najbliższy jump_start()
/obj/structure/overmap/proc/hex_set_pending(cost, hexes)
	hex_pending_cost = cost
	hex_pending_hexes = hexes
	hex_pending_time = world.time

/obj/structure/overmap/proc/hex_clear_pending()
	hex_pending_cost = 0
	hex_pending_hexes = 0

/// Plan jest świeży: jump_start() przychodzi po rozruchu, więc starszy plan pochodzi z przerwanego skoku
/obj/structure/overmap/proc/hex_pending_fresh()
	if(!hex_pending_cost && !hex_pending_hexes)
		return FALSE
	return world.time <= hex_pending_time + max(HEX_FTL_STARTUP, ftl_drive?.ftl_startup_time) + 5 SECONDS

/// Naładowanie napędu w procentach (0–100), bez zaokrąglenia: koszty to ułamki (1/3, 2/3)
/obj/structure/overmap/proc/hex_charge()
	if(istype(ftl_drive, /obj/machinery/computer/ship/ftl_core))
		return clamp(ftl_drive.progress / ftl_drive.req_charge * 100, 0, 100)
	var/obj/machinery/computer/ship/ftl_computer/legacy = ftl_drive
	if(istype(legacy))
		return clamp(legacy.progress / legacy.spoolup_time * 100, 0, 100)
	return 0

/// Procent do pokazania graczom (koszt 1/3 pokazujemy jako 34%, żeby trzy skoki zgadzały się z pełnym napędem)
/proc/hex_percent_text(value)
	return "[CEILING(value - 0.001, 1)]%"

/// Ile sekund cooldownu zostało
/obj/structure/overmap/proc/hex_cooldown_left()
	return max(0, round((hex_cooldown_until - world.time) / 10, 1))

/// Hex, w którym okręt teraz stoi (null w locie)
/obj/structure/overmap/proc/current_hex()
	RETURN_TYPE(/datum/hex)
	var/datum/star_system/S = SSstar_system.ships[src]?["current_system"]
	return GLOB.hexmap?.hex_of_system(S)

/// Powód, dla którego okręt nie może skoczyć za podany koszt, albo null
/obj/structure/overmap/proc/hex_jump_blocker(cost)
	if(!ftl_drive)
		return "Brak napędu FTL."
	if(ftl_drive.lockout)
		return "Napęd zablokowany kodem nadpisania."
	if(ftl_drive.ftl_state == FTL_STATE_JUMPING || SSstar_system.ships[src]?["target_system"])
		return "Okręt jest już w skoku."
	if(world.time < hex_cooldown_until)
		return "Napęd stygnie po skoku: jeszcze [hex_cooldown_left()] s."
	if(hex_charge() + 0.001 < cost)
		return "Za mało naładowania napędu: [round(hex_charge(), 1)]% z potrzebnych [hex_percent_text(cost)]."
	return null

/**
 * Rozpoczyna skok na hex. Trasa kończy się na pierwszym zagrożeniu, więc okręt może stanąć przed celem.
 * Zwraca TRUE, jeśli napęd zaczął rozruch.
 */
/obj/structure/overmap/proc/hex_jump(datum/hex/target, mob/user)
	var/datum/hex/here = current_hex()
	if(!here || !target || here == target)
		return FALSE
	var/list/route = GLOB.hexmap.route(here, target, faction)
	if(!route)
		if(user)
			to_chat(user, "<span class='warning'>Brak trasy do tego kafla.</span>")
		return FALSE
	var/reason = hex_jump_blocker(route["cost"])
	if(reason)
		if(user)
			to_chat(user, "<span class='warning'>[reason]</span>")
		return FALSE
	var/list/path = route["path"]
	var/datum/hex/destination = path[length(path)]
	var/datum/star_system/target_system = GLOB.hexmap.system_for(destination)
	hex_set_pending(route["cost"], route["hexes"])
	if(user)
		log_game("[key_name(user)] ordered [src] to jump [route["hexes"]] hexes to [destination.id] ([target_system.name]) for [route["cost"]]% charge.")
	ftl_drive.jump(target_system)
	return TRUE

/// Odwołuje skok po hexach w czasie rozruchu bez utraty naładowania. Zwraca TRUE, jeśli było co odwołać.
/obj/structure/overmap/proc/hex_cancel_jump()
	if(!hex_pending_cost || ftl_drive?.ftl_state != FTL_STATE_JUMPING)
		return FALSE
	hex_clear_pending()
	hex_resume_charging()
	return TRUE

/// Rozruch przed skokiem: skok po hexach ma krótszy (begin_jump w ftl_jump.dm, hook AQ EDIT)
/obj/structure/overmap/proc/hex_startup_time()
	return (hex_pending_cost && hex_pending_fresh()) ? HEX_FTL_STARTUP : ftl_drive.ftl_startup_time

/obj/structure/overmap/proc/hex_startup_sound()
	return (hex_pending_cost && hex_pending_fresh()) ? HEX_FTL_START_SOUND : ftl_drive.ftl_start

/// Czas lotu w minutach (jump_start mnoży przez MINUTES): skok po hexach liczy kafle trasy, inny skok zostaje przy `speed` z jump_start()
/obj/structure/overmap/proc/hex_travel_minutes(speed)
	if(!hex_pending_hexes || !hex_pending_fresh())
		return speed
	return (HEX_FTL_TRAVEL_BASE + HEX_FTL_TRAVEL_PER_HEX * max(1, hex_pending_hexes)) / (1 MINUTES)

/**
 * Wołane z jump_start() zamiast depower(): zabiera koszt skoku, zostawia resztę ładunku i włącza cooldown.
 * Zwraca FALSE dla skoków, które nie są skokami po hexach (powrót na koniec rundy, admin, skok awaryjny) – wtedy stary depower().
 */
/obj/structure/overmap/proc/hex_on_departure(misjump = FALSE)
	if(!hex_pending_cost || misjump || !hex_pending_fresh())
		hex_clear_pending()
		return FALSE
	var/cost = hex_pending_cost
	hex_clear_pending()
	hex_cooldown_until = world.time + HEX_FTL_COOLDOWN
	var/empty = FALSE
	if(istype(ftl_drive, /obj/machinery/computer/ship/ftl_core))
		ftl_drive.progress = max(0, ftl_drive.progress - ftl_drive.req_charge * cost / 100)
		empty = ftl_drive.progress < 0.01 * ftl_drive.req_charge
	else
		var/obj/machinery/computer/ship/ftl_computer/legacy = ftl_drive
		if(istype(legacy))
			legacy.progress = max(0, legacy.progress - legacy.spoolup_time * cost / 100)
			empty = legacy.progress < 0.01 * legacy.spoolup_time
	if(empty) // cały ładunek zużyty: napęd gaśnie i inżynieria musi go włączyć
		ftl_drive.depower()
		ftl_drive.radio.talk_into(ftl_drive, "Ładunek napędu wyczerpany. Napęd wyłączony, wymagane ponowne uruchomienie.", ftl_drive.radio_channel)
		return TRUE
	hex_resume_charging()
	return TRUE

/// Napęd wraca do ładowania po skoku albo odwołaniu (po cooldownie dobija do pełna)
/obj/structure/overmap/proc/hex_resume_charging()
	if(istype(ftl_drive, /obj/machinery/computer/ship/ftl_core))
		if(!ftl_drive.active)
			ftl_drive.ftl_state = FTL_STATE_IDLE
			return
		ftl_drive.ftl_state = ftl_drive.progress >= ftl_drive.req_charge ? FTL_STATE_READY : FTL_STATE_SPOOLING
		START_PROCESSING(SSmachines, ftl_drive)
		return
	var/obj/machinery/computer/ship/ftl_computer/legacy = ftl_drive
	if(!istype(legacy))
		return
	if(!legacy.active)
		legacy.ftl_state = FTL_STATE_IDLE
		return
	if(legacy.progress >= legacy.spoolup_time)
		legacy.ftl_state = FTL_STATE_READY
		legacy.icon_state = "ftl_ready"
		return
	legacy.ftl_state = FTL_STATE_SPOOLING
	legacy.icon_state = "ftl_charging"
	START_PROCESSING(SSmachines, legacy)

// W cooldownie po skoku po hexach napędy się nie ładują. Komputer Seegson nie może też ładować w czasie rozruchu skoku:
// jego process() ustawia SPOOLING i przerwałby skok, który ruszył z niepełnym ładunkiem.
/obj/machinery/computer/ship/ftl_computer/process()
	if(ftl_state == FTL_STATE_JUMPING)
		return
	if(linked && world.time < linked.hex_cooldown_until)
		return
	return ..()

/obj/machinery/computer/ship/ftl_core/process(delta_time)
	if(linked && world.time < linked.hex_cooldown_until && ftl_state != FTL_STATE_JUMPING)
		return
	return ..()

/// Skok awaryjny na mapie hex: losowy kafel w promieniu 1–2 w tym samym sektorze (jak dotąd: z obrażeniami i bez celu)
/obj/structure/overmap/emergency_jump()
	var/datum/hex/here = current_hex()
	if(!here)
		return ..()
	var/list/candidates = list()
	for(var/datum/hex/H as anything in GLOB.hexmap.hexes_in_range(here, HEX_EMERGENCY_MAX))
		if(GLOB.hexmap.distance(here, H) < HEX_EMERGENCY_MIN || GLOB.hexmap.blocks(H))
			continue
		candidates += H
	if(!length(candidates))
		return ..()
	var/datum/hex/target = pick(candidates)
	next_emergency_jump = world.time + EMERGENCY_FTL_COOLDOWN
	hex_set_pending(0, GLOB.hexmap.distance(here, target))
	ftl_drive.jump(GLOB.hexmap.system_for(target), misjump = TRUE)

/// Hexy tego samego sektora w promieniu
/datum/hexmap/proc/hexes_in_range(datum/hex/center, radius)
	. = list()
	for(var/dq in -radius to radius)
		for(var/dr in max(-radius, -dq - radius) to min(radius, -dq + radius))
			var/datum/hex/H = hex_axial(center.sector, center.q + dq, center.r + dr)
			if(H && H != center)
				. += H
