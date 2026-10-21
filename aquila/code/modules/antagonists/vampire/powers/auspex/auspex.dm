/datum/discipline/auspex
	name = "Postrzeganie"
	discipline_explanation = "Postrzeganie to dyscyplina, która daje wampirom nadnaturalne zmysły, pozwalając patrzeć znacznie dalej i widzieć rzeczy, których lepiej nie oglądać.\n\
		Szczególną więź mają z nią Malkavianie, w głębi duszy jasnowidze."
	icon_state = "auspex"

	// Lists of abilities granted per level
	level_1 = list(/datum/action/vampire/auspex)
	level_2 = list(/datum/action/vampire/auspex/two)
	level_3 = list(/datum/action/vampire/auspex/three)
	level_4 = list(/datum/action/vampire/auspex/four)

/datum/discipline/auspex/malkavian
	level_5 = list(/datum/action/vampire/auspex/four, /datum/action/vampire/astral_projection)

/**
 *	# Auspex
 *
 *	Level 1 - Raise sightrange by 2, project sight 2 tiles ahead.
 *	Level 2 - Raise sightrange by 3, project sight 4 tiles ahead. Meson Vision
 *	Level 3 - Raise sightrange by 5, project sight 6 tiles ahead.
 *	Level 4 - Raise sightrange by 7, project sight 8 tiles ahead. Xray Vision
 *	Level 5 - For Malkavians: Gain ability to astral project like a wizard.
 */
/datum/action/vampire/auspex
	name = "Postrzeganie"
	desc = "Wyczuwaj bezpośrednio vitae każdej istoty i wyostrzonymi zmysłami poszerz swoje pole widzenia."
	button_icon_state = "power_auspex"
	power_explanation = "- Poziom 1: Po aktywacji widzisz dalej. \n\
					- Poziom 2: Po aktywacji widzisz dalej i wyczuwasz ściany oraz układ pomieszczeń. \n\
					- Poziom 3: Po aktywacji nadal masz widzenie mezonowe, jak na poziomie 2, ale z jeszcze większym zasięgiem. \n\
					- Poziom 4: Po aktywacji widzisz dalej i wyczuwasz wszystko w polu widzenia, patrząc przez ściany i bariery jak przez szkło."
	power_flags = BP_AM_TOGGLE | BP_AM_STATIC_COOLDOWN
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 20
	constant_vitaecost = 0.75
	cooldown_time = 10 SECONDS
	var/add_meson = FALSE
	var/add_xray = FALSE
	var/zoom_out_amt = 2
	var/zoom_amt = 6


	var/looking = FALSE
	var/mob/listeningTo

/datum/action/vampire/auspex/two
	name = "Postrzeganie"
	vitaecost = 20
	constant_vitaecost = 1
	zoom_out_amt = 4
	zoom_amt = 7
	add_meson = TRUE

/datum/action/vampire/auspex/three
	name = "Postrzeganie"
	vitaecost = 20
	constant_vitaecost = 1.25
	zoom_out_amt = 6
	zoom_amt = 8
	add_meson = TRUE

/datum/action/vampire/auspex/four
	name = "Postrzeganie"
	vitaecost = 20
	constant_vitaecost = 1.5
	zoom_out_amt = 10
	zoom_amt = 10
	add_xray = TRUE

/datum/action/vampire/auspex/activate_power()
	. = ..()
	if(!looking)
		lookie()

/datum/action/vampire/auspex/deactivate_power()
	. = ..()
	if(looking)
		unlooky()

/datum/action/vampire/auspex/proc/lookie()
	SIGNAL_HANDLER

	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(deactivate_power))
	listeningTo = owner
	if(!owner?.client)
		return
	var/client/C = owner.client
	var/_x = 0
	var/_y = 0
	switch(owner.dir)
		if(NORTH)
			_y = zoom_amt
		if(EAST)
			_x = zoom_amt
		if(SOUTH)
			_y = -zoom_amt
		if(WEST)
			_x = -zoom_amt

	C.change_view(get_zoomed_view(world.view, zoom_out_amt))
	C.pixel_x = ICON_SIZE_X * _x
	C.pixel_y = ICON_SIZE_Y * _y
	looking = TRUE

	if(add_meson)
		if(HAS_TRAIT(owner, TRAIT_MESON_VISION))
			return
		else
			ADD_TRAIT(owner, TRAIT_MESON_VISION, "Auspex")
			owner.update_sight()
			return

	if(add_xray)
		if(HAS_TRAIT(owner, TRAIT_XRAY_VISION))
			return
		else
			ADD_TRAIT(owner, TRAIT_XRAY_VISION, "Auspex")
			owner.update_sight()
			return

/datum/action/vampire/auspex/proc/unlooky()
	SIGNAL_HANDLER

	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
		listeningTo = null
	if(owner?.client)
		var/client/C = owner.client
		C.change_view(CONFIG_GET(string/default_view))
		owner.client.pixel_x = 0
		owner.client.pixel_y = 0

	looking = FALSE

	if(HAS_TRAIT_FROM(owner, TRAIT_MESON_VISION, "Auspex"))
		REMOVE_TRAIT(owner, TRAIT_MESON_VISION, "Auspex")

	if(HAS_TRAIT_FROM(owner, TRAIT_XRAY_VISION, "Auspex"))
		REMOVE_TRAIT(owner, TRAIT_XRAY_VISION, "Auspex")

	owner.update_sight()

/datum/action/vampire/auspex/Destroy()
	listeningTo = null
	return ..()
