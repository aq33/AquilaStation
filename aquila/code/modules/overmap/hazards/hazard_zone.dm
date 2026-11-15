/// AQUILA - lokalne strefy zagrożeń na overmapie (wzór: Shiptest code/modules/overmap/objects/events/, Bay/Eris overmap events).
/// Strefa to anomalia overmapy o promieniu kilku-kilkunastu pól: leży w system_contents układu, chowa się w nullspace
/// razem z układem (spawn_anomaly / remove_ship / restore_contents) i sama pokazuje się na DRADIS oraz w oknie rozpoznania
/// (get_scope_objects bierze każdą /obj/effect/overmap_anomaly). Okręty w środku mają strefę w overmap_hazards.
/// Typy stref: hazards/hazard_types.dm, rozmieszczenie w układach: hazards/hazard_spawn.dm.
///
/// Skutki dla czujników i AI idą przez nadpisania z ..():
/// - get_detection_range(): mnożnik wykrywalności okrętu w strefie i zasięgu obserwatora w strefie (po wszystkich warstwach
///   sensorów: sensor_signature.dm, ai_sensor_suites.dm, player_sensors.dm),
/// - get_overmap_speed_mult(): okręt AI w polu asteroid/szczątków nie przekracza prędkości bezpiecznej,
/// - /datum/signal/subspace/vocal/broadcast(): zakłócenia radia (ten sam Gibberish co przy kompresji sygnału).

/// Debug > Toggle overmap hazards: wyłączone = strefy nic nie robią i nie powstają nowe
GLOBAL_VAR_INIT(overmap_hazards_enabled, TRUE)

/// Najmniejszy łączny mnożnik wykrywalności i zasięgu czujników od stref (kilka nakładających się stref)
#define HAZARD_MIN_SENSOR_MULT 0.3
/// Ile znaków wiadomości radiowej zamienia zakłócenie, gdy już trafi (procent na znak, jak chance w Gibberish())
#define HAZARD_RADIO_GARBLE_CHANCE 25
/// Zapas przy ostrzeżeniu przed zapowiedzianym uderzeniem (EMP, rozbłysk): tyle po nim nic kolejnego nie spada na okręt
#define HAZARD_STRIKE_COOLDOWN (6 SECONDS)

/obj/structure/overmap
	/// AQUILA - lazy list stref zagrożeń, w których okręt teraz jest (hazards/hazard_zone.dm)
	var/list/overmap_hazards
	/// AQUILA - world.time, przed którym strefa nie zapowie temu okrętowi kolejnego uderzenia (EMP, rozbłysk)
	var/next_hazard_strike = 0
	/// AQUILA - world.time, przed którym nie powtarzamy ostrzeżenia o zbyt dużej prędkości w polu
	var/next_hazard_speed_warning = 0

/obj/effect/overmap_anomaly/hazard
	name = "strefa zagrożenia"
	desc = "Obszar przestrzeni, w którym coś zagraża okrętom."
	icon = null
	icon_state = null
	bound_width = 32
	bound_height = 32
	layer = LOW_OBJ_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	resistance_flags = INDESTRUCTIBLE
	// Nawigacja zna strefę od razu: na DRADIS i w rozpoznaniu widać nazwę, nie "anomalia". Nie ma czego skanować.
	research_points = 0
	scanned = TRUE
	/// Promień strefy w polach overmapy
	var/radius = 10
	/// Losowy promień przy powstaniu: list(min, max); null = radius
	var/list/radius_range
	/// Kolor i przezroczystość poświaty strefy na mapie
	var/zone_color = "#ffffff"
	var/zone_alpha = 80
	/// Co ile strefa działa na okręty w środku
	var/hazard_cycle = 4 SECONDS
	/// Szansa (%) na cykl, że strefa uderzy w okręt w środku
	var/chance_to_affect = 15
	/// Mnożnik zasięgu, z jakiego widać okręt w strefie (1 = bez zmian)
	var/signature_mult = 1
	/// Mnożnik zasięgu czujników okrętu w strefie
	var/sensor_mult = 1
	/// Szansa (%), że wiadomość radiowa z okrętu w strefie (albo do niego) przyjdzie zniekształcona
	var/interference = 0
	/// Prędkość (pola/s na oś), której okręt AI w strefie nie przekracza; 0 = bez limitu
	var/ai_speed_cap = 0
	/// Komunikaty dla załogi przy wejściu i wyjściu (relay); nazwa strefy jest doklejana w get_enter_message()
	var/enter_message = "Wchodzimy w strefę zagrożenia."
	var/exit_message = "Opuściliśmy strefę zagrożenia."
	var/enter_sound = 'nsv13/sound/effects/radiostatic.ogg'
	/// Okręty w środku strefy
	var/list/affecting = list()
	var/next_cycle = 0

/obj/effect/overmap_anomaly/hazard/Initialize(mapload, system)
	. = ..()
	if(length(radius_range) == 2)
		radius = rand(radius_range[1], radius_range[2])
	build_hazard_visuals()
	update_hazard_processing()

/obj/effect/overmap_anomaly/hazard/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	clear_affecting(TRUE)
	GLOB.overmap_anomalies -= src
	if(current_system)
		current_system.system_contents -= src
		current_system.contents_positions -= src
		current_system = null
	return ..()

/// Sonda nie ma tu czego mierzyć: przelatuje dalej (bazowe on_entered zjadłoby ją za 0 punktów)
/obj/effect/overmap_anomaly/hazard/on_entered(datum/source, atom/movable/AM)
	if(research_points <= 0)
		return
	return ..()

/obj/effect/overmap_anomaly/hazard/Moved(atom/OldLoc, Dir, Forced = FALSE)
	. = ..()
	update_hazard_processing()

/// Strefa działa tylko na poziomie overmapy; w nullspace (układ bez nikogo) i w teście stoi
/obj/effect/overmap_anomaly/hazard/proc/update_hazard_processing()
	if(z && SSmapping.level_trait(z, ZTRAIT_OVERMAP))
		START_PROCESSING(SSprocessing, src)
		return
	STOP_PROCESSING(SSprocessing, src)
	clear_affecting(TRUE)

/obj/effect/overmap_anomaly/hazard/process(delta_time)
	if(!GLOB.overmap_hazards_enabled || !z || !current_system)
		clear_affecting(TRUE)
		return
	refresh_affected(current_system.system_contents)
	if(world.time < next_cycle)
		return
	next_cycle = world.time + hazard_cycle
	for(var/obj/structure/overmap/OM as anything in affecting.Copy())
		if(!QDELETED(OM))
			hazard_tick(OM)

/// Czy strefa w ogóle działa na ten obiekt: asteroidy, stacje i rzeczy niezniszczalne zostają w spokoju
/obj/effect/overmap_anomaly/hazard/proc/can_affect(obj/structure/overmap/OM)
	if(QDELETED(OM) || isasteroid(OM) || !OM.velocity)
		return FALSE
	if(OM.mass >= MASS_IMMOBILE || (OM.resistance_flags & INDESTRUCTIBLE))
		return FALSE
	return TRUE

/// Aktualizuje listę okrętów w strefie. candidates podawane, żeby dało się testować bez układu gwiezdnego.
/obj/effect/overmap_anomaly/hazard/proc/refresh_affected(list/candidates)
	for(var/obj/structure/overmap/OM in candidates)
		if(OM.z != z || (OM in affecting) || !can_affect(OM))
			continue
		if(overmap_dist(src, OM) <= radius)
			start_affecting(OM)
	for(var/obj/structure/overmap/OM as anything in affecting.Copy())
		// +1 pole zapasu przy wyjściu, żeby okręt na granicy nie dostawał komunikatów co sekundę
		if(QDELETED(OM) || OM.z != z || !(OM in candidates) || overmap_dist(src, OM) > radius + 1)
			stop_affecting(OM)

/obj/effect/overmap_anomaly/hazard/proc/start_affecting(obj/structure/overmap/OM)
	affecting |= OM
	LAZYOR(OM.overmap_hazards, src)
	RegisterSignal(OM, COMSIG_PARENT_QDELETING, PROC_REF(on_affected_deleted))
	var/message = get_enter_message(OM)
	if(message)
		OM.relay(enter_sound, "<span class='warning'>[message]</span>")

/obj/effect/overmap_anomaly/hazard/proc/stop_affecting(obj/structure/overmap/OM, silent = FALSE)
	affecting -= OM
	if(!OM)
		return
	LAZYREMOVE(OM.overmap_hazards, src)
	UnregisterSignal(OM, COMSIG_PARENT_QDELETING)
	if(!silent && !QDELETED(OM) && exit_message)
		OM.relay(null, "<span class='notice'>[exit_message]</span>")

/obj/effect/overmap_anomaly/hazard/proc/clear_affecting(silent = FALSE)
	for(var/obj/structure/overmap/OM as anything in affecting.Copy())
		stop_affecting(OM, silent)

/obj/effect/overmap_anomaly/hazard/proc/on_affected_deleted(datum/source)
	SIGNAL_HANDLER
	stop_affecting(source, TRUE)

/obj/effect/overmap_anomaly/hazard/proc/get_enter_message(obj/structure/overmap/OM)
	return enter_message

/// Jeden cykl strefy dla okrętu w środku
/obj/effect/overmap_anomaly/hazard/proc/hazard_tick(obj/structure/overmap/OM)
	if(prob(get_affect_chance(OM)))
		affect_ship(OM)

/// Szansa (%) na uderzenie w tym cyklu
/obj/effect/overmap_anomaly/hazard/proc/get_affect_chance(obj/structure/overmap/OM)
	return chance_to_affect

/// Skutek strefy dla okrętu (nadpisują typy stref)
/obj/effect/overmap_anomaly/hazard/proc/affect_ship(obj/structure/overmap/OM)
	return

/// Ostrzeżenie dla załogi i uderzenie po 2 sekundach, jeśli okręt wciąż jest w strefie (Shiptest: EMP, rozbłysk)
/obj/effect/overmap_anomaly/hazard/proc/telegraph_strike(obj/structure/overmap/OM, warning)
	if(world.time < OM.next_hazard_strike)
		return FALSE
	OM.next_hazard_strike = world.time + HAZARD_STRIKE_COOLDOWN
	OM.relay('nsv13/sound/effects/ship/pdsr_warning.ogg', "<span class='userdanger'>[warning]</span>")
	addtimer(CALLBACK(src, PROC_REF(delayed_strike), OM), 2 SECONDS)
	return TRUE

/obj/effect/overmap_anomaly/hazard/proc/delayed_strike(obj/structure/overmap/OM)
	if(QDELETED(OM) || !(OM in affecting))
		return
	strike(OM)

/// Zapowiedziane uderzenie (nadpisują typy stref)
/obj/effect/overmap_anomaly/hazard/proc/strike(obj/structure/overmap/OM)
	return

/// Obrażenia kadłuba okrętu bez wnętrza (myśliwce, okręty AI): ułamek wytrzymałości
/obj/effect/overmap_anomaly/hazard/proc/hull_hit(obj/structure/overmap/OM, fraction, message)
	if(message)
		OM.relay(null, "<span class='danger'>[message]</span>")
	OM.take_damage(max(OM.max_integrity * fraction, 1), BRUTE, "overmap_heavy")

/// Wygląd strefy: miękka poświata na cały promień z istniejących ikon (light_352) i kilka nakładek z ikon gry
/obj/effect/overmap_anomaly/hazard/proc/build_hazard_visuals()
	cut_overlays()
	var/mutable_appearance/glow = mutable_appearance('icons/effects/light_overlays/light_352.dmi', "light", alpha = zone_alpha, color = zone_color)
	var/scale = (radius * 2 * world.icon_size) / 352
	glow.pixel_x = -160 // środek ikony 352x352 nad środkiem kafelka
	glow.pixel_y = -160
	glow.transform = matrix(scale, 0, 0, 0, scale, 0)
	add_overlay(glow)
	add_hazard_details()

/// Dodatkowe nakładki typu strefy (okruchy skał, chmury)
/obj/effect/overmap_anomaly/hazard/proc/add_hazard_details()
	return

/// Nakładka w losowym miejscu wewnątrz strefy (do share części promienia od środka)
/obj/effect/overmap_anomaly/hazard/proc/add_scattered_detail(icon_file, state, icon_size = 32, scale = 1, detail_alpha = 255, detail_color = null, share = 0.8)
	var/mutable_appearance/detail = mutable_appearance(icon_file, state, alpha = detail_alpha, color = detail_color)
	var/dist = sqrt(rand()) * radius * share * world.icon_size
	var/angle = rand(0, 359)
	var/offset = (world.icon_size - icon_size) / 2
	detail.pixel_x = round(offset + dist * cos(angle))
	detail.pixel_y = round(offset + dist * sin(angle))
	var/matrix/M = matrix(scale, 0, 0, 0, scale, 0)
	detail.transform = M.Turn(rand(0, 359))
	add_overlay(detail)

// ---- Okręt w strefach ----

/// Mnożnik zasięgu, z jakiego widać ten okręt (iloczyn stref, w których jest)
/obj/structure/overmap/proc/get_hazard_concealment_mult()
	. = 1
	for(var/obj/effect/overmap_anomaly/hazard/zone as anything in overmap_hazards)
		. *= zone.signature_mult
	return max(., HAZARD_MIN_SENSOR_MULT)

/// Mnożnik zasięgu czujników tego okrętu
/obj/structure/overmap/proc/get_hazard_sensor_mult()
	. = 1
	for(var/obj/effect/overmap_anomaly/hazard/zone as anything in overmap_hazards)
		. *= zone.sensor_mult
	return max(., HAZARD_MIN_SENSOR_MULT)

/// Szansa (%) na zniekształcenie wiadomości radiowej przez otoczenie okrętu
/obj/structure/overmap/proc/get_hazard_interference()
	. = 0
	if(!GLOB.overmap_hazards_enabled)
		return
	for(var/obj/effect/overmap_anomaly/hazard/zone as anything in overmap_hazards)
		. = max(., zone.interference)

/// Najniższy limit prędkości AI ze stref, w których jest okręt; 0 = brak
/obj/structure/overmap/proc/get_hazard_ai_speed_cap()
	. = 0
	for(var/obj/effect/overmap_anomaly/hazard/zone as anything in overmap_hazards)
		if(zone.ai_speed_cap > 0 && (!. || zone.ai_speed_cap < .))
			. = zone.ai_speed_cap

/// Czy strefa ma uderzać we wnętrze okrętu (mapa statku gracza), czy tylko w kadłub na overmapie
/obj/structure/overmap/proc/has_hazard_interior()
	return length(occupying_levels) && length(linked_areas) && !ai_controlled

/// Losowy kafelek wnętrza okrętu: z przypisanych obszarów, tylko na poziomach tego okrętu (nie kosmos)
/obj/structure/overmap/proc/get_hazard_hull_turf()
	if(!length(linked_areas))
		return null
	for(var/attempt in 1 to 6)
		var/area/A = pick(linked_areas)
		if(!A || istype(A, /area/space))
			continue
		var/list/area_contents = A.contents
		if(!length(area_contents))
			continue
		var/turf/T = get_turf(pick(area_contents))
		if(!T || isspaceturf(T))
			continue
		var/datum/space_level/SL = SSmapping.z_list[T.z]
		if(SL?.linked_overmap != src)
			continue
		return T
	return null

/// Idzie od kafelka wnętrza w stronę dir aż do kosmosu za kadłubem (krawędź statku) i jeszcze 2 pola dalej
/obj/structure/overmap/proc/get_hazard_edge_turf(turf/from, dir)
	var/turf/T = from
	for(var/i in 1 to 200)
		var/turf/next = get_step(T, dir)
		if(!next)
			return T
		T = next
		if(isspaceturf(T))
			for(var/j in 1 to 2)
				next = get_step(T, dir)
				if(next)
					T = next
			return T
	return T

/// Meteor z eventu meteorów wycelowany w okręt: leci od krawędzi mapy statku (głównie od dziobu, wschód) przez losowy
/// kafelek wnętrza, jak handle_meteor_launches() przy złym skoku FTL, ale z tabelą meteorów strefy
/obj/structure/overmap/proc/launch_hazard_meteor(list/meteor_types)
	var/turf/target = get_hazard_hull_turf()
	if(!target || !length(meteor_types))
		return FALSE
	var/edge = TRANSITIONEDGE + 1
	var/turf/start
	var/turf/goal
	switch(pick(EAST, EAST, NORTH, SOUTH))
		if(EAST)
			start = locate(world.maxx - edge, target.y, target.z)
			goal = locate(edge, target.y, target.z)
		if(NORTH)
			start = locate(target.x, world.maxy - edge, target.z)
			goal = locate(target.x, edge, target.z)
		if(SOUTH)
			start = locate(target.x, edge, target.z)
			goal = locate(target.x, world.maxy - edge, target.z)
	if(!start || !goal)
		return FALSE
	var/meteor_type = pickweight(meteor_types)
	new meteor_type(start, goal)
	return TRUE

// ---- Czujniki, AI i radio ----

/// Okręt w strefie widać z mniejszej odległości, a okręt w strefie widzi mniej (po wszystkich warstwach czujników)
/obj/structure/overmap/get_detection_range(obj/structure/overmap/observer, record = TRUE)
	. = ..()
	if(!GLOB.overmap_hazards_enabled || (!overmap_hazards && !observer?.overmap_hazards))
		return
	. *= get_hazard_concealment_mult()
	if(observer)
		. *= observer.get_hazard_sensor_mult()

/// Okręt AI w polu asteroid albo szczątków zwalnia do prędkości bezpiecznej (limit na oś, jak speed_limit w physics.dm)
/obj/structure/overmap/get_overmap_speed_mult()
	. = ..()
	if(!overmap_hazards || !ai_controlled || !GLOB.overmap_hazards_enabled || speed_limit <= 0)
		return
	var/cap = get_hazard_ai_speed_cap()
	if(cap > 0)
		. = min(., cap / speed_limit)

/datum/signal/subspace/vocal
	/// AQUILA - zakłócenie od stref overmapy już sprawdzone (kopia sygnału nie losuje drugi raz)
	var/hazard_checked = FALSE

/datum/signal/subspace/vocal/copy()
	. = ..()
	var/datum/signal/subspace/vocal/signal_copy = .
	if(istype(signal_copy))
		signal_copy.hazard_checked = hazard_checked

/datum/signal/subspace/vocal/broadcast()
	if(!hazard_checked && GLOB.overmap_hazards_enabled)
		hazard_checked = TRUE
		var/chance = get_hazard_interference()
		if(chance > 0 && prob(chance))
			data["message"] = Gibberish(data["message"], FALSE, HAZARD_RADIO_GARBLE_CHANCE)
	return ..()

/// Najsilniejsze zakłócenie stref na okręcie nadawcy albo na poziomach, do których idzie sygnał
/datum/signal/subspace/vocal/proc/get_hazard_interference()
	. = 0
	var/obj/structure/overmap/OM = source?.get_overmap()
	if(istype(OM))
		. = OM.get_hazard_interference()
	for(var/level in levels)
		if(!isnum(level) || level < 1 || level > length(SSmapping.z_list))
			continue
		var/datum/space_level/SL = SSmapping.z_list[level]
		if(SL?.linked_overmap)
			. = max(., SL.linked_overmap.get_hazard_interference())

// ---- Admin ----

/world/AVerbsDebug()
	. = ..()
	. += /client/proc/toggle_overmap_hazards

/client/proc/toggle_overmap_hazards()
	set category = "Debug"
	set name = "Toggle overmap hazards"
	set desc = "Włącza lub wyłącza strefy zagrożeń na overmapie (pola asteroid i szczątków, mgławice, burze jonowe, rozbłyski)."
	if(!check_rights(R_DEBUG))
		return
	GLOB.overmap_hazards_enabled = !GLOB.overmap_hazards_enabled
	var/state = GLOB.overmap_hazards_enabled ? "włączył" : "wyłączył"
	message_admins("[key_name_admin(usr)] [state] strefy zagrożeń na overmapie.")
	log_admin("[key_name(usr)] toggled overmap hazards to [GLOB.overmap_hazards_enabled].")

#undef HAZARD_MIN_SENSOR_MULT
#undef HAZARD_RADIO_GARBLE_CHANCE
#undef HAZARD_STRIKE_COOLDOWN
