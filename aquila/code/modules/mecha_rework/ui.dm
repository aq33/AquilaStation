// AQUILA - dane systemów mecha do okna TGUI "Mecha" (panel AqSystemsPane.tsx): sloty, overclock,
// pancerz kierunkowy, płyta pancerza i drugi załogant.

/obj/mecha/ui_data(mob/user)
	var/list/data = ..()
	aq_init_slots()
	var/list/slots = list()
	for(var/key in list(AQ_MECHA_L_ARM, AQ_MECHA_R_ARM, AQ_MECHA_UTILITY, AQ_MECHA_POWER, AQ_MECHA_ARMOR, AQ_MECHA_SLOT_OVERFLOW))
		var/max_slots = (key == AQ_MECHA_SLOT_OVERFLOW) ? 0 : aq_slot_max(key)
		var/list/names = list()
		for(var/obj/item/mecha_parts/mecha_equipment/E in aq_equip_by_category[key])
			names += E.name
		if(!max_slots && !length(names))
			continue
		slots += list(list("key" = key, "name" = aq_mecha_slot_name(key), "used" = length(names), "max" = max_slots, "modules" = names))
	data["aq_slots"] = slots
	data["aq_overclock"] = aq_overclock
	data["aq_overclock_left"] = aq_overclock ? round(max(0, aq_overclock_end - world.time) / 10) : 0
	data["aq_overclock_cooldown"] = round(COOLDOWN_TIMELEFT(src, aq_overclock_cooldown) / 10)
	data["aq_facing"] = list(facing_modifiers[MECHA_FRONT_ARMOUR], facing_modifiers[MECHA_SIDE_ARMOUR], facing_modifiers[MECHA_BACK_ARMOUR])
	data["aq_plating"] = aq_plating?.name
	data["aq_copilot"] = aq_copilot ? "[aq_copilot]" : null
	data["aq_remote"] = !!aq_remote_pilot
	return data

/obj/mecha/ui_act(action, list/params)
	switch(action)
		if("aq_overclock")
			if(usr != occupant || usr.incapacitated())
				return
			aq_set_overclock(!aq_overclock)
			return TRUE
	return ..()
