// AQUILA - mech modułowy (wzór: CEV Eris, /mob/living/exosuit z wymiennymi korpusami, nogami, rękami i głowami w klasach).
// Uproszczenie: Eris składa mecha z czterech niezależnych części każdej klasy, a jego mech to osobny mob z własnym
// systemem wyposażenia. Na naszym /obj/mecha to wymagałoby przepisania mechów od zera, więc mech modułowy to jedno
// podwozie z czterema zestawami części (ładowacz, lekki, bojowy, ciężki). Zestaw zakłada się na złożonego mecha
// przy otwartej klapie serwisowej; zmienia wygląd (warstwy części Erisa złożone w jeden obraz), pancerz, szybkość,
// wytrzymałość i liczbę slotów. Zdjęty zestaw wraca do ręki.

/obj/mecha/combat/aq_modular
	name = "mech modułowy"
	desc = "Uniwersalna rama egzoszkieletu na wymienne zestawy części: ładowacz, lekki, bojowy albo ciężki. Zestaw zakłada się przy otwartej klapie serwisowej."
	icon = 'aquila/icons/mecha/aq_mecha_modular_loader.dmi'
	icon_state = "aqmod"
	pixel_x = -8
	step_in = 4
	max_integrity = 250
	armor = list("melee" = 30, "bullet" = 15, "laser" = 10, "energy" = 10, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100, "stamina" = 0)
	wreckage = /obj/structure/mecha_wreckage/aq_modular
	internals_req_access = list(ACCESS_MECH_ENGINE, ACCESS_MECH_SCIENCE)
	aq_max_equip_by_category = list(AQ_MECHA_L_ARM = 1, AQ_MECHA_R_ARM = 1, AQ_MECHA_UTILITY = 3, AQ_MECHA_POWER = 1, AQ_MECHA_ARMOR = 1)
	/// Zamontowany zestaw części
	var/obj/item/mecha_parts/aq_modular_kit/kit
	/// Zestaw na start
	var/start_kit = /obj/item/mecha_parts/aq_modular_kit/loader

/obj/mecha/combat/aq_modular/Initialize(mapload)
	. = ..()
	if(start_kit)
		aq_set_kit(new start_kit(src))

/obj/mecha/combat/aq_modular/Destroy()
	QDEL_NULL(kit)
	return ..()

/obj/mecha/combat/aq_modular/Exited(atom/movable/M, atom/newloc)
	if(M == kit)
		kit = null
	return ..()

/obj/mecha/combat/aq_modular/proc/aq_set_kit(obj/item/mecha_parts/aq_modular_kit/new_kit)
	kit = new_kit
	if(new_kit.loc != src)
		new_kit.forceMove(src)
	icon = new_kit.mech_icon
	step_in = new_kit.step_in
	if(aq_overclock)
		aq_overclock_saved_step = step_in
	max_integrity = new_kit.kit_integrity
	obj_integrity = min(obj_integrity, max_integrity)
	armor = getArmor(arglist(new_kit.armor_values))
	if(capacitor)
		armor = armor.modifyRating(energy = capacitor.rating * 5)
	if(aq_plating)
		armor = armor.modifyRating(melee = aq_plating.bonus["melee"], bullet = aq_plating.bonus["bullet"], laser = aq_plating.bonus["laser"])
	force = new_kit.kit_force
	aq_max_equip_by_category = new_kit.slots.Copy()
	aq_equip_by_category = null
	aq_init_slots()
	// Przypisz od nowa sloty zamontowanemu wyposażeniu (co się nie mieści, idzie ponad limit)
	for(var/obj/item/mecha_parts/mecha_equipment/E in equipment)
		var/slot = aq_free_slot_for(E) || AQ_MECHA_SLOT_OVERFLOW
		E.aq_mounted_slot = slot
		var/list/L = aq_equip_by_category[slot]
		L |= E
	update_icon()

/obj/mecha/combat/aq_modular/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/mecha_parts/aq_modular_kit))
		if(construction_state != MECHA_OPEN_HATCH)
			to_chat(user, "<span class='warning'>Zestaw części wymienia się przy otwartej klapie serwisowej.</span>")
			return
		if(!user.transferItemToLoc(W, src))
			return
		var/obj/item/mecha_parts/aq_modular_kit/old = kit
		aq_set_kit(W)
		if(old)
			old.forceMove(drop_location())
			user.put_in_hands(old)
		to_chat(user, "<span class='notice'>Przebudowujesz [src] na zestaw: [kit.name].</span>")
		playsound(src, 'sound/items/ratchet.ogg', 50, TRUE)
		return
	return ..()

/obj/mecha/combat/aq_modular/examine(mob/user)
	. = ..()
	if(kit)
		. += "<span class='notice'>Zestaw części: [kit.name].</span>"

/obj/structure/mecha_wreckage/aq_modular
	name = "wrak mecha modułowego"
	icon = 'aquila/icons/mecha/aq_mecha_modular_loader.dmi'
	icon_state = "aqmod-broken"
	pixel_x = -8

/obj/mecha/combat/aq_modular/obj_destruction(damage_flag)
	if(kit)
		GLOB.aq_wreck_skin_icon = kit.mech_icon
	return ..()

// ---------------------------------------------------------------- zestawy części
/obj/item/mecha_parts/aq_modular_kit
	name = "zestaw części mecha modułowego"
	icon = 'aquila/icons/mecha/aq_mech_construct.dmi'
	icon_state = "aqmod_kit_loader"
	w_class = WEIGHT_CLASS_BULKY
	var/mech_icon = 'aquila/icons/mecha/aq_mecha_modular_loader.dmi'
	var/step_in = 4
	var/kit_integrity = 250
	var/kit_force = 25
	var/list/armor_values = list("melee" = 30, "bullet" = 15, "laser" = 10, "energy" = 10, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100, "stamina" = 0)
	var/list/slots = list(AQ_MECHA_L_ARM = 1, AQ_MECHA_R_ARM = 1, AQ_MECHA_UTILITY = 4, AQ_MECHA_POWER = 1, AQ_MECHA_ARMOR = 1)

/obj/item/mecha_parts/aq_modular_kit/loader
	name = "zestaw części: ładowacz"
	desc = "Korpus z kabiną, mocne ramiona ładowarki, ciężkie nogi i prosta głowa (CEV Eris). Wolny, za to dużo slotów użytkowych."

/obj/item/mecha_parts/aq_modular_kit/light
	name = "zestaw części: lekki"
	desc = "Lekki korpus, smukłe ramiona, szybkie nogi i głowa z czujnikami (CEV Eris). Bardzo szybki, ale łatwo go rozbić."
	icon_state = "aqmod_kit_light"
	mech_icon = 'aquila/icons/mecha/aq_mecha_modular_light.dmi'
	step_in = 2
	kit_integrity = 180
	kit_force = 15
	armor_values = list("melee" = 20, "bullet" = 10, "laser" = 10, "energy" = 5, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100, "stamina" = 0)
	slots = list(AQ_MECHA_L_ARM = 1, AQ_MECHA_R_ARM = 1, AQ_MECHA_UTILITY = 3, AQ_MECHA_POWER = 1, AQ_MECHA_ARMOR = 0)

/obj/item/mecha_parts/aq_modular_kit/combat
	name = "zestaw części: bojowy"
	desc = "Opancerzony korpus, ramiona pod broń, wytrzymałe nogi i głowa z celownikiem (CEV Eris). Zrównoważony mech bojowy."
	icon_state = "aqmod_kit_combat"
	mech_icon = 'aquila/icons/mecha/aq_mecha_modular_combat.dmi'
	step_in = 3
	kit_integrity = 300
	kit_force = 30
	armor_values = list("melee" = 40, "bullet" = 35, "laser" = 25, "energy" = 20, "bomb" = 30, "bio" = 0, "rad" = 30, "fire" = 100, "acid" = 100, "stamina" = 0)
	slots = list(AQ_MECHA_L_ARM = 1, AQ_MECHA_R_ARM = 1, AQ_MECHA_UTILITY = 2, AQ_MECHA_POWER = 1, AQ_MECHA_ARMOR = 2)

/obj/item/mecha_parts/aq_modular_kit/heavy
	name = "zestaw części: ciężki"
	desc = "Masywny korpus, ciężkie ramiona i nogi, opancerzona głowa (CEV Eris). Bardzo wolny, ale wytrzyma prawie wszystko."
	icon_state = "aqmod_kit_heavy"
	mech_icon = 'aquila/icons/mecha/aq_mecha_modular_heavy.dmi'
	step_in = 6
	kit_integrity = 450
	kit_force = 40
	armor_values = list("melee" = 55, "bullet" = 50, "laser" = 40, "energy" = 30, "bomb" = 60, "bio" = 0, "rad" = 50, "fire" = 100, "acid" = 100, "stamina" = 0)
	slots = list(AQ_MECHA_L_ARM = 1, AQ_MECHA_R_ARM = 1, AQ_MECHA_UTILITY = 2, AQ_MECHA_POWER = 1, AQ_MECHA_ARMOR = 3)

// ---------------------------------------------------------------- budowa
/obj/item/mecha_parts/chassis/aq/modular
	name = "rama mecha modułowego"
	construct_type = /datum/component/construction/unordered/mecha_chassis/aq/modular

/obj/item/mecha_parts/part/aq/modular_torso
	name = "korpus mecha modułowego"
	desc = "Uniwersalny korpus z kabiną i gniazdami pod zestawy części."
	icon_state = "aqmod_light_body"

/obj/item/mecha_parts/part/aq/modular_head
	name = "głowa mecha modułowego"
	icon_state = "aqmod_light_head"

/obj/item/mecha_parts/part/aq/modular_arms
	name = "ramiona mecha modułowego"
	icon_state = "aqmod_light_arms"

/obj/item/mecha_parts/part/aq/modular_legs
	name = "nogi mecha modułowego"
	icon_state = "aqmod_light_legs"

/obj/item/circuitboard/mecha/aq_modular/main
	name = "centralny moduł sterowania mecha modułowego (płytka egzoszkieletu)"
	icon_state = "mainboard"

/obj/item/circuitboard/mecha/aq_modular/peripherals
	name = "moduł sterowania peryferiami mecha modułowego (płytka egzoszkieletu)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/aq_modular/targeting
	name = "moduł sterowania uzbrojeniem mecha modułowego (płytka egzoszkieletu)"
	icon_state = "mcontroller"

/datum/component/construction/unordered/mecha_chassis/aq/modular
	result = /datum/component/construction/mecha/aq/modular
	steps = list(
		/obj/item/mecha_parts/part/aq/modular_torso,
		/obj/item/mecha_parts/part/aq/modular_arms,
		/obj/item/mecha_parts/part/aq/modular_legs,
		/obj/item/mecha_parts/part/aq/modular_head,
	)

/datum/component/construction/mecha/aq/modular
	result = /obj/mecha/combat/aq_modular
	base_icon = "aqmod"
	circuit_control = /obj/item/circuitboard/mecha/aq_modular/main
	circuit_periph = /obj/item/circuitboard/mecha/aq_modular/peripherals
	circuit_weapon = /obj/item/circuitboard/mecha/aq_modular/targeting
	inner_plating = /obj/item/stack/sheet/iron
	inner_plating_amount = 10
	outer_plating = /obj/item/stack/sheet/plasteel
	outer_plating_amount = 5
