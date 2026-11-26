// AQUILA - projektowanie pocisków (rework systemów okrętu, etap D; inspiracja: Nebulous: Fleet Command).
// Silnik (sprint, standardowy, marszowy) i naprowadzanie ustawia się multitoolem na torpedzie albo rakiecie, także
// na obudowie w trakcie składania (menu radialne). Obudowa przekazuje ustawienie gotowej amunicji przy składaniu,
// a amunicja pociskowi przy strzale tą samą drogą co kuźnia amunicji (transfer_forged_munition). Głowica zostaje jak dotąd.
// Naprowadzanie w locie: podczerwień gubi zimny cel i cel w masce, radar daje się ściągnąć wabikowi,
// "z okrętu" leci na cel główny operatora rozpoznania, a pocisk bez naprowadzania leci prosto.

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

/datum/missile_design
	var/engine = "standardowy"
	var/seeker = MISSILE_SEEKER_RADAR

/datum/missile_design/proc/copy()
	var/datum/missile_design/D = new
	D.engine = engine
	D.seeker = seeker
	return D

/// Czy to ustawienie fabryczne (standardowy silnik, radar): takie nie zmienia pocisku
/datum/missile_design/proc/is_default()
	return engine == initial(engine) && seeker == initial(seeker)

/// Mnożnik danej cechy ze wszystkich slotów
/datum/missile_design/proc/mult(stat)
	. = 1
	for(var/slot in list("engine" = engine, "seeker" = seeker))
		var/list/option = GLOB.missile_design_options[slot][vars[slot]]
		if(option && !isnull(option[stat]))
			. *= option[stat]

/// Parametry względem zwykłej torpedy/rakiety, do opisu
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

/// Bez projektu komponent zaczyna od ustawienia fabrycznego (multitool zmienia je potem pozycja po pozycji)
/datum/component/missile_design/Initialize(datum/missile_design/design)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	src.design = design ? design.copy() : new /datum/missile_design
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
	examine_list += "<span class='notice'>Ustawienie: silnik [design.engine], naprowadzanie: [design.seeker].</span>"
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

// --- Ustawianie multitoolem ---

/obj/item/ship_weapon/ammunition/torpedo/multitool_act(mob/living/user, obj/item/I)
	aq_missile_design_multitool(user, I)
	return TRUE

/obj/item/ship_weapon/ammunition/missile/multitool_act(mob/living/user, obj/item/I)
	aq_missile_design_multitool(user, I)
	return TRUE

/obj/item/ship_weapon/ammunition/torpedo/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Multitool ustawia silnik i naprowadzanie.</span>"

/obj/item/ship_weapon/ammunition/missile/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Multitool ustawia silnik i naprowadzanie.</span>"

/// Menu radialne: silnik (3 opcje) i naprowadzanie (4 opcje). Jak dawny stół projektowy: tylko z dostępem do zbrojowni.
/obj/item/ship_weapon/ammunition/proc/aq_missile_design_multitool(mob/living/user, obj/item/I)
	if(!aq_can_tune_missile(user))
		to_chat(user, "<span class='warning'>Ustawianie pocisku wymaga dostępu do zbrojowni.</span>")
		return
	aq_apply_missile_choice(user, I, aq_pick_missile_option(user, I))

/// Czy ten ktoś może ustawiać pociski: dostęp do zbrojowni na identyfikatorze albo silikon
/obj/item/ship_weapon/ammunition/proc/aq_can_tune_missile(mob/living/user)
	if(issilicon(user))
		return TRUE
	var/obj/item/card/id/id = user.get_idcard(TRUE)
	return istype(id) && (ACCESS_MUNITIONS in id.access)

/// Wybór z menu po jego zamknięciu: menu czeka na gracza, więc wszystko sprawdza się jeszcze raz. TRUE, gdy ustawiono.
/obj/item/ship_weapon/ammunition/proc/aq_apply_missile_choice(mob/living/user, obj/item/I, list/choice)
	if(!choice || QDELETED(src) || !user.is_holding(I) || !user.Adjacent(src) || !aq_can_tune_missile(user))
		return FALSE
	if(!aq_set_missile_option(choice[1], choice[2]))
		return FALSE
	I.play_tool_sound(src)
	var/datum/component/missile_design/MD = GetComponent(/datum/component/missile_design)
	var/engine = MD ? MD.design.engine : "standardowy"
	var/seeker = MD ? MD.design.seeker : MISSILE_SEEKER_RADAR
	to_chat(user, "<span class='notice'>Ustawiasz [src]: silnik [engine], naprowadzanie: [seeker].</span>")
	return TRUE

/// Wybór z menu radialnego: list(slot, opcja) albo null
/obj/item/ship_weapon/ammunition/proc/aq_pick_missile_option(mob/living/user, obj/item/I)
	var/static/list/slot_names = list("engine" = "silnik", "seeker" = "naprowadzanie")
	var/static/list/slot_icons = list("engine" = "propulsion", "seeker" = "guidance")
	var/list/items = list()
	var/list/picks = list()
	for(var/slot in GLOB.missile_design_options)
		for(var/option in GLOB.missile_design_options[slot])
			var/label = "[slot_names[slot]]: [option]"
			items[label] = image(icon = 'nsv13/icons/obj/munitions.dmi', icon_state = slot_icons[slot])
			picks[label] = list(slot, option)
	var/label = show_radial_menu(user, src, items, require_near = TRUE, tooltips = TRUE)
	return label ? picks[label] : null

/// Ustawia silnik albo naprowadzanie. Ustawienie fabryczne zdejmuje projekt, żeby amunicja zachowywała się jak dotąd.
/obj/item/ship_weapon/ammunition/proc/aq_set_missile_option(slot, option)
	if(!(slot in GLOB.missile_design_options) || !(option in GLOB.missile_design_options[slot]))
		return FALSE
	var/datum/component/missile_design/MD = GetComponent(/datum/component/missile_design) || AddComponent(/datum/component/missile_design)
	MD.design.vars[slot] = option
	if(MD.design.is_default())
		qdel(MD)
	return TRUE

#undef MISSILE_SEEKER_NONE
#undef MISSILE_SEEKER_IR
#undef MISSILE_SEEKER_RADAR
#undef MISSILE_SEEKER_COMMAND
#undef MISSILE_IR_MIN_HEAT
#undef MISSILE_RADAR_DECOY_RANGE
