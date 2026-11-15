// AQUILA - projektowanie pocisków (rework systemów okrętu, etap D; inspiracja: Nebulous: Fleet Command).
// Na stole projektowym w zbrojowni składa się projekt: kadłub, silnik i naprowadzanie. Stół drukuje chip
// projektu, który wkłada się do obudowy torpedy albo rakiety przy składaniu (przed spawaniem). Gotowa amunicja
// niesie projekt (komponent missile_design), a przy strzale przekazuje go pociskowi tą samą drogą co kuźnia
// amunicji (transfer_forged_munition). Głowica bojowa zostaje fizyczną częścią, jak dotąd.
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
	"body" = list(
		"lekki" = list("speed" = 0.9, "integrity" = 0.6),
		"standardowy" = list(),
		"opancerzony" = list("speed" = 1.15, "integrity" = 1.8)
	),
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
	var/body = "standardowy"
	var/engine = "standardowy"
	var/seeker = MISSILE_SEEKER_RADAR

/datum/missile_design/proc/copy()
	var/datum/missile_design/D = new
	D.name = name
	D.body = body
	D.engine = engine
	D.seeker = seeker
	return D

/// Mnożnik danej cechy ze wszystkich slotów
/datum/missile_design/proc/mult(stat)
	. = 1
	for(var/slot in list("body" = body, "engine" = engine, "seeker" = seeker))
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
	examine_list += "<span class='notice'>Projekt „[design.name]”: kadłub [design.body], silnik [design.engine], naprowadzanie: [design.seeker].</span>"
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

// --- Chip projektu ---

/obj/item/missile_design_chip
	name = "chip projektu pocisku"
	desc = "Zaprogramowany na stole projektowym. Włóż go do obudowy torpedy albo rakiety przed spawaniem."
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	w_class = WEIGHT_CLASS_TINY
	var/datum/missile_design/design

/obj/item/missile_design_chip/Destroy()
	QDEL_NULL(design)
	return ..()

/obj/item/missile_design_chip/examine(mob/user)
	. = ..()
	if(design)
		var/list/s = design.summary()
		. += "<span class='notice'>Projekt „[design.name]”: kadłub [design.body], silnik [design.engine], naprowadzanie: [design.seeker].</span>"
		. += "<span class='notice'>Prędkość ×[s["speed"]], zasięg ×[s["range"]], odporność ×[s["integrity"]].</span>"

// --- Obudowy: chip przed spawaniem ---

/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/missile_design_chip))
		return insert_missile_design_chip(I, user)
	return ..()

/obj/item/ship_weapon/ammunition/missile/missile_casing/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/missile_design_chip))
		return insert_missile_design_chip(I, user)
	return ..()

/obj/item/ship_weapon/ammunition/proc/insert_missile_design_chip(obj/item/missile_design_chip/chip, mob/user)
	if(!chip.design)
		to_chat(user, "<span class='warning'>[chip] jest pusty.</span>")
		return TRUE
	if(GetComponent(/datum/component/missile_design))
		to_chat(user, "<span class='warning'>W [src] jest już zaprogramowany projekt.</span>")
		return TRUE
	AddComponent(/datum/component/missile_design, chip.design)
	to_chat(user, "<span class='notice'>Wkładasz [chip] do [src]. Projekt: „[chip.design.name]”.</span>")
	qdel(chip)
	return TRUE

// --- Stół projektowy ---

/obj/machinery/missile_design_table
	name = "stół projektowy pocisków"
	desc = "Komputer projektowy zbrojowni: składa projekt torpedy albo rakiety i drukuje jego chip."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "tdoppler"
	density = TRUE
	anchored = TRUE
	idle_power_usage = 100
	req_one_access = list(ACCESS_MUNITIONS)
	/// Projekt, nad którym ktoś pracuje
	var/datum/missile_design/draft
	/// Kiedy stół skończy drukować
	var/print_ready = 0

/obj/machinery/missile_design_table/Initialize(mapload)
	. = ..()
	draft = new

/obj/machinery/missile_design_table/Destroy()
	QDEL_NULL(draft)
	return ..()

/obj/machinery/missile_design_table/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MissileDesigner", name)
		ui.open()

/obj/machinery/missile_design_table/ui_data(mob/user)
	var/list/designs = list()
	for(var/datum/missile_design/D as anything in GLOB.missile_designs)
		designs += list(list("index" = D.id, "name" = D.name, "body" = D.body, "engine" = D.engine, "seeker" = D.seeker))
	var/list/options = list()
	for(var/slot in GLOB.missile_design_options)
		var/list/names = list()
		for(var/option in GLOB.missile_design_options[slot])
			names += option
		options[slot] = names
	return list(
		"draft" = list("name" = draft.name, "body" = draft.body, "engine" = draft.engine, "seeker" = draft.seeker, "summary" = draft.summary()),
		"designs" = designs,
		"options" = options,
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
		if("print")
			if(world.time < print_ready || !powered())
				return TRUE
			print_ready = world.time + 5 SECONDS
			addtimer(CALLBACK(src, PROC_REF(finish_print), draft.copy()), 5 SECONDS)
			playsound(src, 'sound/machines/terminal_processing.ogg', 50, TRUE)
	return TRUE

/// Zapisany projekt po trwałym numerze
/obj/machinery/missile_design_table/proc/find_saved_design(id)
	id = text2num(id)
	for(var/datum/missile_design/D as anything in GLOB.missile_designs)
		if(D.id == id)
			return D
	return null

/obj/machinery/missile_design_table/proc/finish_print(datum/missile_design/design)
	if(QDELETED(src))
		qdel(design)
		return
	var/obj/item/missile_design_chip/chip = new(drop_location())
	chip.design = design
	chip.name = "chip projektu „[design.name]”"
	playsound(src, 'sound/machines/ping.ogg', 50, TRUE)
	visible_message("<span class='notice'>[src] wydaje chip projektu „[design.name]”.</span>")
	SStgui.update_uis(src) // okno nie ma autoupdate: bez tego przycisk zostawał na „Drukowanie...”

#undef MISSILE_DESIGNS_MAX
#undef MISSILE_SEEKER_NONE
#undef MISSILE_SEEKER_IR
#undef MISSILE_SEEKER_RADAR
#undef MISSILE_SEEKER_COMMAND
#undef MISSILE_IR_MIN_HEAT
#undef MISSILE_RADAR_DECOY_RANGE
