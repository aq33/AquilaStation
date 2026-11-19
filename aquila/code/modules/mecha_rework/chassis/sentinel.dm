// AQUILA - Sentinel (MonkeStation, code/modules/vehicles/mecha/combat/sentinel.dm): superciężki kroczący taran oblężniczy.
// Jedno ramię na działo w wieży (prawego brak), dużo slotów pancerza, burzy ściany, w które wchodzi. Wolny.
// Syntinel to wersja Syndykatu z działem zamiast lasera. W Monke Sentinela nie da się zbudować; u nas ma części
// (przemalowane części Duranda, bo Monke nie ma ich sprite'ów) i projekty w zaawansowanym węźle uzbrojenia mechów.

/obj/mecha/combat/aq_sentinel
	name = "\improper Sentinel"
	desc = "Superciężki kroczący pojazd oblężniczy. Sentinel zamienia umocnienia w gruz."
	icon = 'aquila/icons/mecha/aq_mecha_large.dmi'
	icon_state = "sentinel"
	pixel_x = -24
	step_in = 5
	max_integrity = 400
	deflect_chance = 10
	armor = list("melee" = 10, "bullet" = 35, "laser" = 35, "energy" = 35, "bomb" = 55, "bio" = 0, "rad" = 50, "fire" = 100, "acid" = 100, "stamina" = 0)
	facing_modifiers = list(2, 1, 0.4)
	max_temperature = 60000
	destruction_sleep_duration = 40
	exit_delay = 40
	internal_damage_threshold = 25
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	force = 45
	bumpsmash = TRUE
	wreckage = /obj/structure/mecha_wreckage/aq_sentinel
	internals_req_access = list(ACCESS_MECH_SCIENCE, ACCESS_MECH_SECURITY)
	aq_max_equip_by_category = list(AQ_MECHA_L_ARM = 1, AQ_MECHA_R_ARM = 0, AQ_MECHA_UTILITY = 5, AQ_MECHA_POWER = 1, AQ_MECHA_ARMOR = 3)

/obj/mecha/combat/aq_sentinel/GrantActions(mob/living/user, human_occupant = 0)
	. = ..()
	zoom_action.Grant(user, src)

/obj/mecha/combat/aq_sentinel/RemoveActions(mob/living/user, human_occupant = 0)
	. = ..()
	zoom_action.Remove(user)

/obj/mecha/combat/aq_sentinel/loaded/Initialize(mapload)
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/aq_sentinel_laser(src)
	ME.attach(src)

/obj/mecha/combat/aq_sentinel/syndicate
	name = "\improper Sentinel Syndykatu"
	desc = "Superciężki kroczący pojazd oblężniczy w czerwono-czarnych barwach, z działem zamiast lasera."
	icon_state = "syntinel"
	wreckage = /obj/structure/mecha_wreckage/aq_sentinel/syndicate
	operation_req_access = list(ACCESS_SYNDICATE)
	internals_req_access = list(ACCESS_SYNDICATE)
	aq_antag_chassis = TRUE

/obj/mecha/combat/aq_sentinel/syndicate/loaded/Initialize(mapload)
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/aq_sentinel_cannon(src)
	ME.attach(src)

/obj/structure/mecha_wreckage/aq_sentinel
	name = "wrak Sentinela"
	icon = 'aquila/icons/mecha/aq_mecha_large.dmi'
	icon_state = "sentinel-broken"
	pixel_x = -24

/obj/structure/mecha_wreckage/aq_sentinel/syndicate
	name = "wrak Sentinela Syndykatu"
	icon_state = "syntinel-broken"

// ---------------------------------------------------------------- budowa
/obj/item/mecha_parts/chassis/aq/sentinel
	name = "rama Sentinela"
	construct_type = /datum/component/construction/unordered/mecha_chassis/aq/sentinel

/obj/item/mecha_parts/part/aq/sentinel_torso
	name = "tors Sentinela"
	desc = "Tors Sentinela z wieżą działa."
	icon_state = "sentinel_harness"

/obj/item/mecha_parts/part/aq/sentinel_head
	name = "głowa Sentinela"
	icon_state = "sentinel_head"

/obj/item/mecha_parts/part/aq/sentinel_left_arm
	name = "lewe ramię Sentinela"
	icon_state = "sentinel_l_arm"

/obj/item/mecha_parts/part/aq/sentinel_right_arm
	name = "prawe ramię Sentinela"
	desc = "Wspornik wieży Sentinela. Sam nie trzyma wyposażenia."
	icon_state = "sentinel_r_arm"

/obj/item/mecha_parts/part/aq/sentinel_left_leg
	name = "lewa noga Sentinela"
	icon_state = "sentinel_l_leg"

/obj/item/mecha_parts/part/aq/sentinel_right_leg
	name = "prawa noga Sentinela"
	icon_state = "sentinel_r_leg"

/obj/item/mecha_parts/part/aq/sentinel_armor
	name = "płyty pancerza Sentinela"
	icon_state = "sentinel_armor"

/obj/item/circuitboard/mecha/aq_sentinel/main
	name = "centralny moduł sterowania Sentinela (płytka egzoszkieletu)"
	icon_state = "mainboard"

/obj/item/circuitboard/mecha/aq_sentinel/peripherals
	name = "moduł sterowania peryferiami Sentinela (płytka egzoszkieletu)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/aq_sentinel/targeting
	name = "moduł sterowania uzbrojeniem Sentinela (płytka egzoszkieletu)"
	icon_state = "mcontroller"

/datum/component/construction/unordered/mecha_chassis/aq/sentinel
	result = /datum/component/construction/mecha/aq/sentinel
	steps = list(
		/obj/item/mecha_parts/part/aq/sentinel_torso,
		/obj/item/mecha_parts/part/aq/sentinel_left_arm,
		/obj/item/mecha_parts/part/aq/sentinel_right_arm,
		/obj/item/mecha_parts/part/aq/sentinel_left_leg,
		/obj/item/mecha_parts/part/aq/sentinel_right_leg,
		/obj/item/mecha_parts/part/aq/sentinel_head,
	)

/datum/component/construction/mecha/aq/sentinel
	result = /obj/mecha/combat/aq_sentinel
	base_icon = "sentinel"
	circuit_control = /obj/item/circuitboard/mecha/aq_sentinel/main
	circuit_periph = /obj/item/circuitboard/mecha/aq_sentinel/peripherals
	circuit_weapon = /obj/item/circuitboard/mecha/aq_sentinel/targeting
	inner_plating = /obj/item/stack/sheet/plasteel
	inner_plating_amount = 15
	outer_plating = /obj/item/mecha_parts/part/aq/sentinel_armor
	outer_plating_amount = 1
