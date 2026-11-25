// AQUILA - sloty kategorii wyposażenia na naszym /obj/mecha (wzór: max_equip_by_category z tg i BeeStation).
// Ramiona L/P mieszczą po jednym module, użytkowe/zasilanie/pancerz mają limity per podwozie.
// Rdzeń dalej trzyma wszystko w liście equipment, sloty to dodatkowa warstwa (aq_equip_by_category).

/obj/mecha
	/// Limity slotów podwozia (klucze AQ_MECHA_*). Wartości jak w tg, z poprawkami pod nasze podwozia.
	var/list/aq_max_equip_by_category = list(AQ_MECHA_L_ARM = 1, AQ_MECHA_R_ARM = 1, AQ_MECHA_UTILITY = 2, AQ_MECHA_POWER = 1, AQ_MECHA_ARMOR = 0)
	/// Zamontowane wyposażenie według slotów (klucz => lista)
	var/list/aq_equip_by_category

/obj/item/mecha_parts/mecha_equipment
	/// Jaki slot zajmuje: AQ_MECHA_SLOT_ARM, AQ_MECHA_UTILITY, AQ_MECHA_POWER, AQ_MECHA_ARMOR albo AQ_MECHA_SLOT_NONE. null = z reguły (wybieralne na ramię, reszta użytkowe)
	var/aq_slot
	/// Slot, w którym moduł siedzi teraz
	var/aq_mounted_slot

/obj/item/mecha_parts/mecha_equipment/proc/aq_get_slot()
	if(aq_slot)
		return aq_slot
	return selectable ? AQ_MECHA_SLOT_ARM : AQ_MECHA_UTILITY

/// Polska nazwa slotu do okna i opisów
/proc/aq_mecha_slot_name(slot)
	switch(slot)
		if(AQ_MECHA_L_ARM)
			return "lewe ramię"
		if(AQ_MECHA_R_ARM)
			return "prawe ramię"
		if(AQ_MECHA_SLOT_ARM)
			return "ramię"
		if(AQ_MECHA_UTILITY)
			return "użytkowe"
		if(AQ_MECHA_POWER)
			return "zasilanie"
		if(AQ_MECHA_ARMOR)
			return "pancerz"
		if(AQ_MECHA_SLOT_OVERFLOW)
			return "ponad limit"
	return "bez slotu"

/obj/mecha/Initialize(mapload)
	aq_init_slots()
	return ..()

/obj/mecha/proc/aq_init_slots()
	if(aq_equip_by_category)
		return
	aq_equip_by_category = list()
	var/total = 0
	for(var/key in aq_max_equip_by_category)
		aq_equip_by_category[key] = list()
		total += aq_max_equip_by_category[key]
	aq_equip_by_category[AQ_MECHA_SLOT_OVERFLOW] = list()
	aq_equip_by_category[AQ_MECHA_SLOT_NONE] = list()
	aq_update_max_equip()

/// Rdzeń (i kilka starszych can_attach bez ..()) sprawdza equipment.len < max_equip: suma slotów plus moduły bez slotu
/obj/mecha/proc/aq_update_max_equip()
	var/total = 0
	for(var/key in aq_max_equip_by_category)
		total += aq_max_equip_by_category[key]
	max_equip = total + length(aq_equip_by_category?[AQ_MECHA_SLOT_NONE]) + length(aq_equip_by_category?[AQ_MECHA_SLOT_OVERFLOW])

/obj/mecha/proc/aq_slot_used(key)
	aq_init_slots()
	var/list/L = aq_equip_by_category[key]
	return length(L)

/obj/mecha/proc/aq_slot_max(key)
	return aq_max_equip_by_category[key] || 0

/// Wolny slot dla modułu albo null
/obj/mecha/proc/aq_free_slot_for(obj/item/mecha_parts/mecha_equipment/equip)
	aq_init_slots()
	var/slot = equip.aq_get_slot()
	if(slot == AQ_MECHA_SLOT_NONE)
		return AQ_MECHA_SLOT_NONE
	if(slot == AQ_MECHA_SLOT_ARM)
		if(aq_slot_used(AQ_MECHA_L_ARM) < aq_slot_max(AQ_MECHA_L_ARM))
			return AQ_MECHA_L_ARM
		if(aq_slot_used(AQ_MECHA_R_ARM) < aq_slot_max(AQ_MECHA_R_ARM))
			return AQ_MECHA_R_ARM
		return null
	if(aq_slot_used(slot) < aq_slot_max(slot))
		return slot
	return null

/obj/item/mecha_parts/mecha_equipment/can_attach(obj/mecha/M)
	if(!M.aq_free_slot_for(src))
		return FALSE
	return ..()

/obj/item/mecha_parts/mecha_equipment/try_attach_part(mob/user, obj/mecha/M)
	if(!M.aq_free_slot_for(src))
		var/slot = aq_get_slot()
		to_chat(user, "<span class='warning'>[M] nie ma wolnego slotu ([aq_mecha_slot_name(slot)]: [slot == AQ_MECHA_SLOT_ARM ? "[M.aq_slot_used(AQ_MECHA_L_ARM) + M.aq_slot_used(AQ_MECHA_R_ARM)]/[M.aq_slot_max(AQ_MECHA_L_ARM) + M.aq_slot_max(AQ_MECHA_R_ARM)]" : "[M.aq_slot_used(slot)]/[M.aq_slot_max(slot)]"]).</span>")
		return FALSE
	return ..()

/obj/item/mecha_parts/mecha_equipment/attach(obj/mecha/M)
	var/slot = M.aq_free_slot_for(src) || AQ_MECHA_SLOT_OVERFLOW
	. = ..()
	aq_mounted_slot = slot
	var/list/L = M.aq_equip_by_category[slot]
	L |= src
	M.aq_update_max_equip()

/obj/item/mecha_parts/mecha_equipment/proc/aq_clear_slot()
	if(!chassis || !aq_mounted_slot)
		aq_mounted_slot = null
		return
	var/list/L = chassis.aq_equip_by_category?[aq_mounted_slot]
	L?.Remove(src)
	aq_mounted_slot = null
	chassis.aq_update_max_equip()

/obj/item/mecha_parts/mecha_equipment/detach(atom/moveto = null)
	var/obj/mecha/old = chassis
	var/old_slot = aq_mounted_slot
	. = ..()
	if(old && !chassis) // odłączone
		var/list/L = old.aq_equip_by_category?[old_slot]
		L?.Remove(src)
		aq_mounted_slot = null
		old.aq_update_max_equip()

/obj/item/mecha_parts/mecha_equipment/Destroy()
	aq_clear_slot()
	return ..()

/obj/mecha/examine(mob/user)
	. = ..()
	aq_init_slots()
	var/arms = aq_slot_used(AQ_MECHA_L_ARM) + aq_slot_used(AQ_MECHA_R_ARM)
	var/arms_max = aq_slot_max(AQ_MECHA_L_ARM) + aq_slot_max(AQ_MECHA_R_ARM)
	. += "<span class='notice'>Sloty: ramiona [arms]/[arms_max], użytkowe [aq_slot_used(AQ_MECHA_UTILITY)]/[aq_slot_max(AQ_MECHA_UTILITY)], zasilanie [aq_slot_used(AQ_MECHA_POWER)]/[aq_slot_max(AQ_MECHA_POWER)], pancerz [aq_slot_used(AQ_MECHA_ARMOR)]/[aq_slot_max(AQ_MECHA_ARMOR)].</span>"

// ---------------------------------------------------------------- limity podwozi (tg: Ripley 4 użytkowe, Gygax 3, Marauder 5...)
/obj/mecha/working/ripley
	aq_max_equip_by_category = list(AQ_MECHA_L_ARM = 1, AQ_MECHA_R_ARM = 1, AQ_MECHA_UTILITY = 4, AQ_MECHA_POWER = 1, AQ_MECHA_ARMOR = 1)

/obj/mecha/working/ripley/firefighter
	aq_max_equip_by_category = list(AQ_MECHA_L_ARM = 1, AQ_MECHA_R_ARM = 1, AQ_MECHA_UTILITY = 4, AQ_MECHA_POWER = 1, AQ_MECHA_ARMOR = 2)

/obj/mecha/working/ripley/deathripley
	aq_max_equip_by_category = list(AQ_MECHA_L_ARM = 1, AQ_MECHA_R_ARM = 1, AQ_MECHA_UTILITY = 4, AQ_MECHA_POWER = 1, AQ_MECHA_ARMOR = 2)

/obj/mecha/working/lockermech
	aq_max_equip_by_category = list(AQ_MECHA_L_ARM = 1, AQ_MECHA_R_ARM = 1, AQ_MECHA_UTILITY = 0, AQ_MECHA_POWER = 0, AQ_MECHA_ARMOR = 0)

/obj/mecha/medical/odysseus
	aq_max_equip_by_category = list(AQ_MECHA_L_ARM = 1, AQ_MECHA_R_ARM = 1, AQ_MECHA_UTILITY = 3, AQ_MECHA_POWER = 1, AQ_MECHA_ARMOR = 1)

/obj/mecha/combat/gygax
	aq_max_equip_by_category = list(AQ_MECHA_L_ARM = 1, AQ_MECHA_R_ARM = 1, AQ_MECHA_UTILITY = 3, AQ_MECHA_POWER = 1, AQ_MECHA_ARMOR = 1)

/obj/mecha/combat/gygax/dark
	aq_max_equip_by_category = list(AQ_MECHA_L_ARM = 1, AQ_MECHA_R_ARM = 1, AQ_MECHA_UTILITY = 4, AQ_MECHA_POWER = 1, AQ_MECHA_ARMOR = 1)

/obj/mecha/combat/durand
	aq_max_equip_by_category = list(AQ_MECHA_L_ARM = 1, AQ_MECHA_R_ARM = 1, AQ_MECHA_UTILITY = 3, AQ_MECHA_POWER = 1, AQ_MECHA_ARMOR = 1)

/obj/mecha/combat/honker
	aq_max_equip_by_category = list(AQ_MECHA_L_ARM = 1, AQ_MECHA_R_ARM = 1, AQ_MECHA_UTILITY = 4, AQ_MECHA_POWER = 1, AQ_MECHA_ARMOR = 0)

/obj/mecha/combat/honker/dark
	aq_max_equip_by_category = list(AQ_MECHA_L_ARM = 1, AQ_MECHA_R_ARM = 1, AQ_MECHA_UTILITY = 3, AQ_MECHA_POWER = 1, AQ_MECHA_ARMOR = 2)

/obj/mecha/combat/marauder
	aq_max_equip_by_category = list(AQ_MECHA_L_ARM = 1, AQ_MECHA_R_ARM = 1, AQ_MECHA_UTILITY = 5, AQ_MECHA_POWER = 1, AQ_MECHA_ARMOR = 1)

/obj/mecha/combat/marauder/mauler
	aq_max_equip_by_category = list(AQ_MECHA_L_ARM = 1, AQ_MECHA_R_ARM = 1, AQ_MECHA_UTILITY = 4, AQ_MECHA_POWER = 1, AQ_MECHA_ARMOR = 1)

/obj/mecha/combat/phazon
	aq_max_equip_by_category = list(AQ_MECHA_L_ARM = 1, AQ_MECHA_R_ARM = 1, AQ_MECHA_UTILITY = 3, AQ_MECHA_POWER = 1, AQ_MECHA_ARMOR = 2)

/obj/mecha/combat/reticence
	aq_max_equip_by_category = list(AQ_MECHA_L_ARM = 1, AQ_MECHA_R_ARM = 1, AQ_MECHA_UTILITY = 3, AQ_MECHA_POWER = 1, AQ_MECHA_ARMOR = 1)

// ---------------------------------------------------------------- sloty obecnego wyposażenia
/obj/item/mecha_parts/mecha_equipment/mining_scanner
	aq_slot = AQ_MECHA_UTILITY

/obj/item/mecha_parts/mecha_equipment/repair_droid
	aq_slot = AQ_MECHA_UTILITY

/obj/item/mecha_parts/mecha_equipment/thrusters
	aq_slot = AQ_MECHA_UTILITY

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	aq_slot = AQ_MECHA_POWER

/obj/item/mecha_parts/mecha_equipment/generator
	aq_slot = AQ_MECHA_POWER

/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster
	aq_slot = AQ_MECHA_ARMOR

/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster
	aq_slot = AQ_MECHA_ARMOR

/obj/item/mecha_parts/mecha_equipment/ripleyupgrade
	aq_slot = AQ_MECHA_SLOT_NONE

// can_attach bez ..() (sprawdzają tylko equipment.len): dokładamy sprawdzenie slotu
/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma/can_attach(obj/mecha/M)
	return ..() && M.aq_free_slot_for(src)

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/smart_foam/can_attach(obj/mecha/M)
	return ..() && M.aq_free_slot_for(src)

/obj/item/mecha_parts/mecha_equipment/drill/makeshift/can_attach(obj/mecha/M)
	return ..() && M.aq_free_slot_for(src)

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/makeshift/can_attach(obj/mecha/M)
	return ..() && M.aq_free_slot_for(src)

/obj/item/mecha_parts/mecha_equipment/weapon/energy/makeshift/can_attach(obj/mecha/M)
	return ..() && M.aq_free_slot_for(src)
