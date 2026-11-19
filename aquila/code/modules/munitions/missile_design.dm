// AQUILA - projektowanie pocisków (rework systemów okrętu, etap D; inspiracja: Nebulous: Fleet Command).
// Rework amunicji: stół projektowy w zbrojowni przerabia części torped i rakiet. Na stół kładzie się układ napędowy
// albo układ naprowadzania, a stół ustawia go według projektu (silnik: sprint, standardowy, marszowy; naprowadzanie).
// Przy składaniu gotowa amunicja bierze projekt z części w obudowie (apply_missile_parts_design) i przy strzale
// przekazuje go pociskowi tą samą drogą co kuźnia amunicji (transfer_forged_munition). Głowica zostaje jak dotąd.
// Naprowadzanie w locie: podczerwień gubi zimny cel i cel w masce, radar daje się ściągnąć wabikowi,
// "z okrętu" leci na cel główny operatora rozpoznania, a pocisk bez naprowadzania leci prosto.

/// Najwięcej zapisanych projektów pocisków (lista jest wspólna dla wszystkich stołów i żyje całą rundę)
#define MISSILE_DESIGNS_MAX 30
#define MISSILE_SEEKER_NONE "brak"
#define MISSILE_SEEKER_IR "podczerwień"
#define MISSILE_SEEKER_RADAR "radar"
#define MISSILE_SEEKER_COMMAND "z okrętu"
/// Poniżej tego ciepła celu głowica na podczerwień traci namiar
#define MISSILE_IR_MIN_HEAT 0.12
/// Z ilu pól radar pocisku widzi wabika
#define MISSILE_RADAR_DECOY_RANGE 8

/// Opcje projektu: slot = list(nazwa = list(mnożniki))
/// speed: mnożnik czasu na kratkę (mniej = szybciej), range: zasięg, integrity: odporność na PDC, turn: skręt
GLOBAL_LIST_INIT(missile_design_options, list(
	"engine" = list(
		"sprint" = list("speed" = 0.6, "range" = 0.6),
		"standardowy" = list(),
		"marszowy" = list("speed" = 1.3, "range" = 1.6)
	),
	"seeker" = list(
		MISSILE_SEEKER_NONE = list("speed" = 0.9, "turn" = 0),
		MISSILE_SEEKER_IR = list("turn" = 1.2),
		MISSILE_SEEKER_RADAR = list(),
		MISSILE_SEEKER_COMMAND = list("turn" = 0.8)
	)
))

/// Projekty zapisane na stołach w tej rundzie
GLOBAL_LIST_EMPTY(missile_designs)

/datum/missile_design
	/// Trwały numer zapisanego projektu (okno wczytuje i usuwa po nim, a nie po pozycji na liście)
	var/id = 0
	var/static/next_id = 0
	var/name = "nowy projekt"
	var/engine = "standardowy"
	var/seeker = MISSILE_SEEKER_RADAR

/datum/missile_design/proc/copy()
	var/datum/missile_design/D = new
	D.name = name
	D.engine = engine
	D.seeker = seeker
	return D

/// Mnożnik danej cechy ze wszystkich slotów
/datum/missile_design/proc/mult(stat)
	. = 1
	for(var/slot in list("engine" = engine, "seeker" = seeker))
		var/list/option = GLOB.missile_design_options[slot][vars[slot]]
		if(option && !isnull(option[stat]))
			. *= option[stat]

/// Parametry względem zwykłej torpedy/rakiety, do okna i opisu
/datum/missile_design/proc/summary()
	return list(
		"speed" = round(1 / mult("speed"), 0.01),
		"range" = round(mult("range"), 0.01), // zasięg liczy się w kafelkach, prędkość go nie zmienia
		"integrity" = round(mult("integrity"), 0.01),
		"turn" = round(mult("turn"), 0.01),
		"seeker" = seeker
	)

/datum/component/missile_design
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/datum/missile_design/design
	/// Okręt, który wystrzelił pocisk (do naprowadzania "z okrętu")
	var/obj/structure/overmap/launcher
	/// Czy radar pocisku już dał się ściągnąć wabikowi (raz)
	var/decoy_checked = FALSE

/datum/component/missile_design/Initialize(datum/missile_design/design)
	if(!isatom(parent) || !design)
		return COMPONENT_INCOMPATIBLE
	src.design = design.copy()
	if(istype(parent, /obj/item/projectile/guided_munition))
		apply_to_projectile(parent)
	else
		RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/component/missile_design/Destroy(force, silent)
	launcher = null
	return ..()

/datum/component/missile_design/proc/apply_to_projectile(obj/item/projectile/guided_munition/P)
	P.speed = P.speed * design.mult("speed")
	P.range = round(P.range * design.mult("range"))
	if(P.max_integrity)
		P.max_integrity = round(P.max_integrity * design.mult("integrity"))
		P.obj_integrity = P.max_integrity
	P.homing_turn_speed = round(initial(P.homing_turn_speed) * design.mult("turn"))
	if(design.seeker == MISSILE_SEEKER_NONE)
		P.homing = FALSE
		P.homing_target = null

/datum/component/missile_design/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	var/list/s = design.summary()
	examine_list += "<span class='notice'>Projekt z części: silnik [design.engine], naprowadzanie: [design.seeker].</span>"
	examine_list += "<span class='notice'>Prędkość ×[s["speed"]], zasięg ×[s["range"]], odporność ×[s["integrity"]].</span>"

/// Cel naprowadzania co krok (process_homing). Zwraca nowy cel albo null, gdy pocisk traci namiar.
/datum/component/missile_design/proc/seek(obj/item/projectile/guided_munition/P, atom/current)
	switch(design.seeker)
		if(MISSILE_SEEKER_NONE)
			return null
		if(MISSILE_SEEKER_COMMAND)
			var/obj/structure/overmap/ship = launcher
			if(istype(ship) && !QDELETED(ship))
				for(var/obj/structure/overmap/target as anything in ship.designated_targets)
					if(ship.designated_targets[target] == "primary" && !QDELETED(target) && target.z == P.z)
						return target
			return current
		if(MISSILE_SEEKER_IR)
			var/obj/structure/overmap/target = current
			if(istype(target) && (target.is_cloaked() || target.get_signature_heat() < MISSILE_IR_MIN_HEAT))
				return null
			return current
		if(MISSILE_SEEKER_RADAR)
			if(decoy_checked || !istype(current, /obj/structure/overmap))
				return current
			var/obj/structure/overmap/target = current
			for(var/obj/item/projectile/guided_munition/torpedo/decoy/D in range(MISSILE_RADAR_DECOY_RANGE, P))
				if(D.faction == target.faction)
					decoy_checked = TRUE
					if(prob(50))
						return D
					break
			return current
	return current

/// Wabik, który zwodzi ten pocisk: "flare" (podczerwień), "chaff" (radar) albo null (bez naprowadzania albo z okrętu).
/// Pocisk bez projektu jak dawniej: torpeda leci na ciepło, rakieta na radar.
/obj/item/projectile/guided_munition/proc/decoy_kind()
	var/datum/component/missile_design/MD = GetComponent(/datum/component/missile_design)
	if(!MD)
		return istype(src, /obj/item/projectile/guided_munition/torpedo) ? "flare" : "chaff"
	switch(MD.design.seeker)
		if(MISSILE_SEEKER_IR)
			return "flare"
		if(MISSILE_SEEKER_RADAR)
			return "chaff"
	return null

// --- Pocisk: naprowadzanie z projektu ---

/obj/item/projectile/guided_munition/process_homing()
	var/datum/component/missile_design/MD = GetComponent(/datum/component/missile_design)
	if(MD && homing)
		var/atom/target = MD.seek(src, homing_target)
		if(target != homing_target)
			if(target)
				set_homing_target(target)
			else
				homing_target = null
	return ..()

/// windup() przywraca initial(homing_turn_speed), więc projekt nakłada skręt jeszcze raz po nim
/obj/item/projectile/guided_munition/windup()
	. = ..()
	var/datum/component/missile_design/MD = GetComponent(/datum/component/missile_design)
	if(MD && !QDELETED(src))
		homing_turn_speed = round(initial(homing_turn_speed) * MD.design.mult("turn"))

/// Przenosi projekt z obudowy na amunicję i z amunicji na pocisk (obok kuźni amunicji)
/proc/transfer_missile_design(atom/source, atom/target)
	if(!source || !target)
		return
	var/datum/component/missile_design/MD = source.GetComponent(/datum/component/missile_design)
	if(!MD)
		return
	var/datum/component/missile_design/new_md = target.AddComponent(/datum/component/missile_design, MD.design)
	if(istype(target, /obj/item/projectile))
		var/obj/item/projectile/P = target
		new_md?.launcher = P.overmap_firer

/// Projekt z przerobionych części w obudowie: niestandardowy silnik albo naprowadzanie dają gotowej amunicji projekt
/proc/apply_missile_parts_design(atom/casing, atom/target)
	if(!casing || !target)
		return
	var/datum/missile_design/D = new
	var/changed = FALSE
	for(var/obj/item/ship_weapon/parts/missile/part in casing)
		var/slot = part.aq_design_slot()
		if(!slot || !part.aq_design_option)
			continue
		D.vars[slot] = part.aq_design_option
		if(part.aq_design_option != part.aq_default_option())
			changed = TRUE
	if(changed)
		D.name = "silnik [D.engine], [D.seeker]"
		var/datum/component/missile_design/new_md = target.AddComponent(/datum/component/missile_design, D)
		if(istype(target, /obj/item/projectile))
			var/obj/item/projectile/P = target
			new_md?.launcher = P.overmap_firer
	qdel(D)

// --- Części przerabiane na stole ---

/obj/item/ship_weapon/parts/missile
	/// Opcja z projektu ustawiona na stole projektowym (null = część, której stół nie przerabia)
	var/aq_design_option

/obj/item/ship_weapon/parts/missile/Initialize(mapload)
	. = ..()
	if(aq_design_slot() && !aq_design_option)
		aq_design_option = aq_default_option()

/// Pozycja projektu, którą zmienia ta część ("engine", "seeker") albo null
/obj/item/ship_weapon/parts/missile/proc/aq_design_slot()
	return null

/obj/item/ship_weapon/parts/missile/proc/aq_default_option()
	return null

/obj/item/ship_weapon/parts/missile/proc/set_design_option(option)
	aq_design_option = option
	name = option == aq_default_option() ? initial(name) : "[initial(name)] ([option])"

/obj/item/ship_weapon/parts/missile/examine(mob/user)
	. = ..()
	if(aq_design_slot())
		. += "<span class='notice'>Ustawienie: [aq_design_option]. Stół projektowy pocisków może je zmienić.</span>"

/obj/item/ship_weapon/parts/missile/propulsion_system/aq_design_slot()
	return "engine"

/obj/item/ship_weapon/parts/missile/propulsion_system/aq_default_option()
	return "standardowy"

/obj/item/ship_weapon/parts/missile/guidance_system/aq_design_slot()
	return "seeker"

/obj/item/ship_weapon/parts/missile/guidance_system/aq_default_option()
	return MISSILE_SEEKER_RADAR

// --- Stół projektowy ---

/obj/machinery/missile_design_table
	name = "stół projektowy pocisków"
	desc = "Komputer projektowy zbrojowni: przerabia układ napędowy i układ naprowadzania torped i rakiet według projektu. Połóż część na stole, wybierz ustawienie i kliknij „Przerób”. Alt+klik zdejmuje część."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "tdoppler"
	density = TRUE
	anchored = TRUE
	idle_power_usage = 100
	req_one_access = list(ACCESS_MUNITIONS)
	/// Projekt, nad którym ktoś pracuje
	var/datum/missile_design/draft
	/// Kiedy stół skończy przerabiać część
	var/print_ready = 0
	/// Część leżąca na stole
	var/obj/item/ship_weapon/parts/missile/loaded_part

/obj/machinery/missile_design_table/Initialize(mapload)
	. = ..()
	draft = new

/obj/machinery/missile_design_table/Destroy()
	QDEL_NULL(draft)
	if(loaded_part)
		loaded_part.forceMove(drop_location())
		loaded_part = null
	return ..()

/obj/machinery/missile_design_table/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == loaded_part)
		loaded_part = null
		SStgui.update_uis(src)

/obj/machinery/missile_design_table/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Na stole: [loaded_part ? loaded_part : "nic"].</span>"

/obj/machinery/missile_design_table/attackby(obj/item/I, mob/living/user, params)
	var/obj/item/ship_weapon/parts/missile/part = I
	if(!istype(part) || !part.aq_design_slot())
		return ..()
	if(world.time < print_ready)
		to_chat(user, "<span class='warning'>[src] jeszcze przerabia część.</span>")
		return TRUE
	if(!user.transferItemToLoc(part, src))
		return TRUE
	var/obj/item/old_part = loaded_part
	loaded_part = part
	if(old_part)
		old_part.forceMove(drop_location())
		user.put_in_hands(old_part)
	to_chat(user, "<span class='notice'>Kładziesz [part] na [src].</span>")
	SStgui.update_uis(src)
	return TRUE

/obj/machinery/missile_design_table/AltClick(mob/living/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE))
		return
	eject_part(user)

/obj/machinery/missile_design_table/proc/eject_part(mob/living/user)
	if(!loaded_part)
		return
	if(world.time < print_ready)
		to_chat(user, "<span class='warning'>[src] jeszcze przerabia część.</span>")
		return
	var/obj/item/part = loaded_part
	loaded_part = null
	part.forceMove(drop_location())
	user?.put_in_hands(part)

/obj/machinery/missile_design_table/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MissileDesigner", name)
		ui.open()

/obj/machinery/missile_design_table/ui_data(mob/user)
	var/list/designs = list()
	for(var/datum/missile_design/D as anything in GLOB.missile_designs)
		designs += list(list("index" = D.id, "name" = D.name, "engine" = D.engine, "seeker" = D.seeker))
	var/list/options = list()
	for(var/slot in GLOB.missile_design_options)
		var/list/names = list()
		for(var/option in GLOB.missile_design_options[slot])
			names += option
		options[slot] = names
	var/list/part
	if(loaded_part)
		var/slot = loaded_part.aq_design_slot()
		part = list("name" = "[loaded_part]", "slot" = slot, "option" = loaded_part.aq_design_option, "target" = draft.vars[slot])
	return list(
		"draft" = list("name" = draft.name, "engine" = draft.engine, "seeker" = draft.seeker, "summary" = draft.summary()),
		"designs" = designs,
		"options" = options,
		"part" = part,
		"printing" = world.time < print_ready,
		"can_use" = allowed(user)
	)

/obj/machinery/missile_design_table/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!allowed(usr))
		to_chat(usr, "<span class='warning'>Brak dostępu do zbrojowni.</span>")
		return TRUE
	switch(action)
		if("set_slot")
			var/slot = params["slot"]
			if(!(slot in GLOB.missile_design_options) || !(params["value"] in GLOB.missile_design_options[slot]))
				return TRUE
			draft.vars[slot] = params["value"]
		if("rename")
			var/new_name = reject_bad_name(params["name"], allow_numbers = TRUE, max_length = 32)
			if(new_name)
				draft.name = new_name
		if("save")
			if(length(GLOB.missile_designs) >= MISSILE_DESIGNS_MAX)
				to_chat(usr, "<span class='warning'>Pamięć stołu jest pełna ([MISSILE_DESIGNS_MAX] projektów). Usuń któryś projekt.</span>")
				return TRUE
			var/datum/missile_design/saved = draft.copy()
			saved.id = ++saved.next_id
			GLOB.missile_designs += saved
		if("load")
			var/datum/missile_design/D = find_saved_design(params["index"])
			if(D)
				QDEL_NULL(draft)
				draft = D.copy()
		if("delete")
			var/datum/missile_design/D = find_saved_design(params["index"])
			if(D)
				GLOB.missile_designs -= D
				qdel(D)
		if("rework")
			if(world.time < print_ready || !powered() || !loaded_part)
				return TRUE
			var/slot = loaded_part.aq_design_slot()
			var/option = draft.vars[slot]
			if(option == loaded_part.aq_design_option)
				to_chat(usr, "<span class='notice'>[loaded_part] ma już to ustawienie.</span>")
				return TRUE
			print_ready = world.time + 5 SECONDS
			addtimer(CALLBACK(src, PROC_REF(finish_rework), loaded_part, option), 5 SECONDS)
			playsound(src, 'sound/machines/terminal_processing.ogg', 50, TRUE)
		if("eject")
			eject_part(usr)
	return TRUE

/// Zapisany projekt po trwałym numerze
/obj/machinery/missile_design_table/proc/find_saved_design(id)
	id = text2num(id)
	for(var/datum/missile_design/D as anything in GLOB.missile_designs)
		if(D.id == id)
			return D
	return null

/obj/machinery/missile_design_table/proc/finish_rework(obj/item/ship_weapon/parts/missile/part, option)
	if(QDELETED(src))
		return
	if(QDELETED(part) || part != loaded_part)
		SStgui.update_uis(src)
		return
	part.set_design_option(option)
	playsound(src, 'sound/machines/ping.ogg', 50, TRUE)
	visible_message("<span class='notice'>[src] kończy przerabiać [part].</span>")
	SStgui.update_uis(src) // okno nie ma autoupdate: bez tego przycisk zostawał na „Przerabianie...”

#undef MISSILE_DESIGNS_MAX
#undef MISSILE_SEEKER_NONE
#undef MISSILE_SEEKER_IR
#undef MISSILE_SEEKER_RADAR
#undef MISSILE_SEEKER_COMMAND
#undef MISSILE_IR_MIN_HEAT
#undef MISSILE_RADAR_DECOY_RANGE
