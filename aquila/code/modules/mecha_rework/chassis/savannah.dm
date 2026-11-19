// AQUILA - Savannah-Ivanov (tg, code/modules/vehicles/mecha/combat/savannah_ivanov.dm): dwuosobowy mech bojowy.
// Strzelec (pierwszy w środku) obsługuje uzbrojenie i uderzenie rakietowe Ivanov, kierowca (drugi) prowadzi i skacze (Skyfall).
// Sam pilot robi oba. Różnice wobec tg: Skyfall ląduje na najdalszym wolnym polu do 6 kratek przed mechem
// (bez sterowania cieniem w locie), uderzenie Ivanov to trzy rakiety wokół celu wskazanego następnym kliknięciem.
// Red Sunday (Nova Sector, artefakt z ksenoarcheologii) to cięższa, wolniejsza wersja z własnymi płytami pancerza.

/obj/mecha/combat/aq_savannah
	name = "\improper Savannah-Ivanov"
	desc = "Przeładowany mech, który bez trudu miażdży jednoosobowych przeciwników. Ceną jest to, że potrzebuje dwóch pilotów: kierowcy i strzelca."
	icon = 'aquila/icons/mecha/aq_mecha_tall.dmi'
	icon_state = "savannah_ivanov"
	step_in = 3
	dir_in = SOUTH
	max_integrity = 450
	deflect_chance = 15
	armor = list("melee" = 45, "bullet" = 40, "laser" = 30, "energy" = 30, "bomb" = 40, "bio" = 0, "rad" = 50, "fire" = 100, "acid" = 100, "stamina" = 0)
	facing_modifiers = list(1.5, 1.2, 0.8)
	max_temperature = 30000
	force = 30
	wreckage = /obj/structure/mecha_wreckage/aq_savannah
	internals_req_access = list(ACCESS_MECH_SCIENCE, ACCESS_MECH_SECURITY)
	aq_max_occupants = 2
	aq_max_equip_by_category = list(AQ_MECHA_L_ARM = 1, AQ_MECHA_R_ARM = 1, AQ_MECHA_UTILITY = 3, AQ_MECHA_POWER = 1, AQ_MECHA_ARMOR = 1)
	/// Przedrostek stanów ikony (Red Sunday ma własne)
	var/state_prefix = "savannah_ivanov"
	var/datum/action/innate/mecha/aq_skyfall/skyfall_action = new
	var/datum/action/innate/mecha/aq_ivanov/ivanov_action = new
	/// Następne kliknięcie strzelca wskazuje cel uderzenia Ivanov
	var/ivanov_targeting = FALSE
	var/leaping = FALSE
	COOLDOWN_DECLARE(skyfall_cd)
	COOLDOWN_DECLARE(ivanov_cd)

/obj/mecha/combat/aq_savannah/Destroy()
	. = ..()
	QDEL_NULL(skyfall_action)
	QDEL_NULL(ivanov_action)

/obj/mecha/combat/aq_savannah/update_icon()
	. = ..()
	if(leaping)
		icon_state = "[state_prefix]_leap_1_1"
	else if(occupant && aq_copilot)
		icon_state = "[state_prefix]_1_1"
	else if(occupant)
		icon_state = state_prefix

/obj/mecha/combat/aq_savannah/GrantActions(mob/living/user, human_occupant = 0)
	. = ..()
	ivanov_action.Grant(user, src)
	if(!aq_copilot)
		skyfall_action.Grant(user, src)

/obj/mecha/combat/aq_savannah/RemoveActions(mob/living/user, human_occupant = 0)
	. = ..()
	ivanov_action.Remove(user)
	skyfall_action.Remove(user)

/obj/mecha/combat/aq_savannah/aq_grant_copilot_actions(mob/living/user)
	if(occupant)
		skyfall_action.Remove(occupant)
	skyfall_action.Grant(user, src)

/obj/mecha/combat/aq_savannah/aq_remove_copilot_actions(mob/living/user)
	skyfall_action.Remove(user)
	if(occupant)
		skyfall_action.Grant(occupant, src)

/obj/mecha/combat/aq_savannah/proc/aq_skyfall(mob/living/user)
	if(leaping || completely_disabled)
		return
	if(!COOLDOWN_FINISHED(src, skyfall_cd))
		balloon_alert(user, "skok niegotowy")
		return
	if(!has_charge(1000))
		return
	balloon_alert(user, "ładowanie skoku...")
	if(!do_after(user, 2 SECONDS, target = src))
		return
	use_power(1000)
	aq_adjust_heat(20)
	COOLDOWN_START(src, skyfall_cd, 30 SECONDS)
	var/turf/landing = get_turf(src)
	for(var/i in 1 to 6)
		var/turf/T = get_step(landing, dir)
		if(!T || T.density)
			break
		landing = T
	leaping = TRUE
	density = FALSE
	completely_disabled = TRUE
	update_icon()
	visible_message("<span class='danger'>[src] wystrzeliwuje w górę na dyszach!</span>")
	playsound(src, 'sound/effects/podwoosh.ogg', 70, TRUE)
	animate(src, pixel_z = 200, alpha = 60, time = 1 SECONDS, easing = QUAD_EASING | EASE_OUT)
	addtimer(CALLBACK(src, PROC_REF(aq_skyfall_land), landing), 2 SECONDS)

/obj/mecha/combat/aq_savannah/proc/aq_skyfall_land(turf/landing)
	if(QDELETED(src))
		return
	new /obj/effect/temp_visual/aq_drop_target(landing)
	forceMove(landing)
	animate(src, pixel_z = 0, alpha = 255, time = 0.5 SECONDS, easing = QUAD_EASING | EASE_IN)
	sleep(0.5 SECONDS)
	leaping = FALSE
	density = TRUE
	completely_disabled = FALSE
	update_icon()
	playsound(landing, 'sound/effects/meteorimpact.ogg', 80, TRUE)
	new /obj/effect/temp_visual/explosion/fast(landing)
	for(var/mob/living/L in range(1, landing))
		if(L == occupant || L == aq_copilot || L.loc == src)
			continue
		L.Knockdown(3 SECONDS)
		L.adjustBruteLoss(get_turf(L) == landing ? 50 : 20)
		to_chat(L, "<span class='userdanger'>[src] spada na ciebie z nieba!</span>")
	for(var/obj/structure/S in range(1, landing))
		if(S.density)
			S.take_damage(80, BRUTE, "melee", FALSE)
	log_message("Skyfall landed at [AREACOORD(landing)].", LOG_MECHA)

/obj/mecha/combat/aq_savannah/click_action(atom/target, mob/user, params)
	if(ivanov_targeting && user == occupant)
		ivanov_targeting = FALSE
		INVOKE_ASYNC(src, PROC_REF(aq_ivanov_strike), get_turf(target))
		return
	return ..()

/obj/mecha/combat/aq_savannah/proc/aq_ivanov_strike(turf/target)
	if(!target || !COOLDOWN_FINISHED(src, ivanov_cd) || !has_charge(2000))
		return
	use_power(2000)
	aq_adjust_heat(15)
	COOLDOWN_START(src, ivanov_cd, 2 MINUTES)
	occupant_message("<span class='danger'>Uderzenie Ivanov odpalone!</span>")
	log_message("Ivanov strike at [AREACOORD(target)].", LOG_MECHA)
	playsound(src, 'sound/weapons/grenadelaunch.ogg', 70, TRUE)
	for(var/i in 1 to 3)
		var/turf/T = locate(target.x + rand(-2, 2), target.y + rand(-2, 2), target.z) || target
		new /obj/effect/temp_visual/aq_drop_target(T)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(explosion), T, -1, 1, 2, 3), 1.5 SECONDS + i * 0.4 SECONDS)

/datum/action/innate/mecha/aq_skyfall
	name = "Skyfall"
	desc = "Skok na dyszach na najdalsze wolne pole przed mechem (do 6 kratek), przewracający stojących przy lądowaniu."
	button_icon_state = "mech_thrusters_on"

/datum/action/innate/mecha/aq_skyfall/Activate()
	var/obj/mecha/combat/aq_savannah/S = chassis
	if(!owner || !istype(S))
		return
	if(owner != (S.aq_copilot || S.occupant))
		return
	INVOKE_ASYNC(S, TYPE_PROC_REF(/obj/mecha/combat/aq_savannah, aq_skyfall), owner)

/datum/action/innate/mecha/aq_ivanov
	name = "Uderzenie Ivanov"
	desc = "Następne kliknięcie wskazuje cel salwy trzech rakiet."
	button_icon_state = "mech_smoke"

/datum/action/innate/mecha/aq_ivanov/Activate()
	var/obj/mecha/combat/aq_savannah/S = chassis
	if(!owner || !istype(S) || S.occupant != owner)
		return
	if(!COOLDOWN_FINISHED(S, ivanov_cd))
		S.balloon_alert(owner, "rakiety niegotowe")
		return
	S.ivanov_targeting = !S.ivanov_targeting
	S.occupant_message(S.ivanov_targeting ? "Wskaż cel uderzenia Ivanov." : "Anulowano namierzanie.")

/obj/structure/mecha_wreckage/aq_savannah
	name = "wrak Savannah-Ivanov"
	icon = 'aquila/icons/mecha/aq_mecha_tall.dmi'
	icon_state = "savannah_ivanov-broken"

// ---------------------------------------------------------------- Red Sunday
/obj/mecha/combat/aq_savannah/red_sunday
	name = "\improper Red Sunday"
	desc = "Przeładowany dwuosobowy mech pomalowany na czerwono, z wielkim sierpem i młotem na plecach. Siłowniki są zardzewiałe i ciężkie, ale pancerz robi wrażenie."
	icon_state = "redsunday"
	state_prefix = "redsunday"
	step_in = 6
	max_integrity = 600
	armor = list("melee" = 55, "bullet" = 50, "laser" = 40, "energy" = 35, "bomb" = 50, "bio" = 0, "rad" = 50, "fire" = 100, "acid" = 100, "stamina" = 0)
	facing_modifiers = list(1.6, 1.3, 0.9)
	wreckage = /obj/structure/mecha_wreckage/aq_red_sunday

/obj/structure/mecha_wreckage/aq_red_sunday
	name = "wrak Red Sunday"
	desc = "Poległy towarzysz."
	icon = 'aquila/icons/mecha/aq_mecha_tall.dmi'
	icon_state = "redsunday-broken"

// ---------------------------------------------------------------- budowa
/obj/item/mecha_parts/chassis/aq/savannah
	name = "rama Savannah-Ivanov"
	construct_type = /datum/component/construction/unordered/mecha_chassis/aq/savannah

/obj/item/mecha_parts/chassis/aq/red_sunday
	name = "rama Red Sunday"
	construct_type = /datum/component/construction/unordered/mecha_chassis/aq/red_sunday

/obj/item/mecha_parts/part/aq/savannah_torso
	name = "tors Savannah-Ivanov"
	desc = "Tors Savannah-Ivanov z dwoma fotelami: kierowcy i strzelca."
	icon_state = "savannah_ivanov_harness"

/obj/item/mecha_parts/part/aq/savannah_head
	name = "głowa Savannah-Ivanov"
	desc = "Głowa Savannah-Ivanov z celownikiem rakiet Ivanov."
	icon_state = "savannah_ivanov_head"

/obj/item/mecha_parts/part/aq/savannah_left_arm
	name = "lewe ramię Savannah-Ivanov"
	icon_state = "savannah_ivanov_l_arm"

/obj/item/mecha_parts/part/aq/savannah_right_arm
	name = "prawe ramię Savannah-Ivanov"
	icon_state = "savannah_ivanov_r_arm"

/obj/item/mecha_parts/part/aq/savannah_left_leg
	name = "lewa noga Savannah-Ivanov"
	desc = "Noga z dyszami skokowymi Skyfall."
	icon_state = "savannah_ivanov_l_leg"

/obj/item/mecha_parts/part/aq/savannah_right_leg
	name = "prawa noga Savannah-Ivanov"
	desc = "Noga z dyszami skokowymi Skyfall."
	icon_state = "savannah_ivanov_r_leg"

/obj/item/mecha_parts/part/aq/savannah_armor
	name = "płyty pancerza Savannah-Ivanov"
	icon_state = "savannah_ivanov_armor"

/obj/item/mecha_parts/part/aq/red_sunday_armor
	name = "płyty pancerza Red Sunday"
	desc = "Grube, czerwone płyty z sierpem i młotem. Zamieniają Savannah w Red Sunday."
	icon_state = "savannah_ivanov_armor"
	color = "#c03a2b"

/obj/item/circuitboard/mecha/aq_savannah/main
	name = "centralny moduł sterowania Savannah-Ivanov (płytka egzoszkieletu)"
	icon_state = "mainboard"

/obj/item/circuitboard/mecha/aq_savannah/peripherals
	name = "moduł sterowania peryferiami Savannah-Ivanov (płytka egzoszkieletu)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/aq_savannah/targeting
	name = "moduł sterowania uzbrojeniem Savannah-Ivanov (płytka egzoszkieletu)"
	icon_state = "mcontroller"

/datum/component/construction/unordered/mecha_chassis/aq/savannah
	result = /datum/component/construction/mecha/aq/savannah
	steps = list(
		/obj/item/mecha_parts/part/aq/savannah_torso,
		/obj/item/mecha_parts/part/aq/savannah_left_arm,
		/obj/item/mecha_parts/part/aq/savannah_right_arm,
		/obj/item/mecha_parts/part/aq/savannah_left_leg,
		/obj/item/mecha_parts/part/aq/savannah_right_leg,
		/obj/item/mecha_parts/part/aq/savannah_head,
	)

/datum/component/construction/unordered/mecha_chassis/aq/red_sunday
	result = /datum/component/construction/mecha/aq/savannah/red_sunday
	steps = list(
		/obj/item/mecha_parts/part/aq/savannah_torso,
		/obj/item/mecha_parts/part/aq/savannah_left_arm,
		/obj/item/mecha_parts/part/aq/savannah_right_arm,
		/obj/item/mecha_parts/part/aq/savannah_left_leg,
		/obj/item/mecha_parts/part/aq/savannah_right_leg,
		/obj/item/mecha_parts/part/aq/savannah_head,
	)

/datum/component/construction/mecha/aq/savannah
	result = /obj/mecha/combat/aq_savannah
	base_icon = "savannah_ivanov"
	aq_max_state = 23
	circuit_control = /obj/item/circuitboard/mecha/aq_savannah/main
	circuit_periph = /obj/item/circuitboard/mecha/aq_savannah/peripherals
	circuit_weapon = /obj/item/circuitboard/mecha/aq_savannah/targeting
	inner_plating = /obj/item/stack/sheet/plasteel
	inner_plating_amount = 10
	outer_plating = /obj/item/mecha_parts/part/aq/savannah_armor
	outer_plating_amount = 1

/datum/component/construction/mecha/aq/savannah/red_sunday
	result = /obj/mecha/combat/aq_savannah/red_sunday
	outer_plating = /obj/item/mecha_parts/part/aq/red_sunday_armor
