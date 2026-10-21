/datum/action/vampire/exactitude
	name = "Precyzja"
	desc = "Skup moc w dłoniach, żeby atakować z nadnaturalną precyzją."
	button_icon_state = "power_exactitude"
	power_explanation = "Napełnia twoje dłonie nadnaturalną precyzją. Nie działa w rękawicach.\n\
						Używaj w trybie walki. Uderzając pięścią, automatycznie trafisz najbliższą istotę. Najlepiej w ogóle nie ruszać przy tym myszką."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	sol_multiplier = 2
	cooldown_time = 30 SECONDS
	vitaecost = 25
	constant_vitaecost = 3

	// Ref to the item
	var/datum/weakref/item_ref
	var/mob/living/carbon/carbon_owner

/datum/action/vampire/exactitude/Grant()
	. = ..()
	carbon_owner = owner

/datum/action/vampire/exactitude/can_use()
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/carbon_owner = owner

	if(carbon_owner.gloves)
		if(istype(carbon_owner.gloves, /obj/item/clothing/gloves/rapid/vampire))
			return TRUE
		owner.balloon_alert(owner, "masz na sobie rękawice!")
		return FALSE

/datum/action/vampire/exactitude/activate_power()
	. = ..()

	var/obj/item/clothing/gloves/rapid/vampire/the_gloves = new /obj/item/clothing/gloves/rapid/vampire()

	item_ref = WEAKREF(the_gloves)

	carbon_owner.equip_to_slot_or_del(the_gloves, ITEM_SLOT_GLOVES)

/datum/action/vampire/exactitude/deactivate_power()
	. = ..()
	var/obj/item/clothing/gloves/rapid/vampire/the_gloves = item_ref?.resolve()
	if(the_gloves)
		qdel(the_gloves)
	item_ref = null
