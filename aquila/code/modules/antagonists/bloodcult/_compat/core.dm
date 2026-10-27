// AQUILA - warstwa zgodności kultu krwi (Cult 4 z Monkestation/vgstation) z naszą bazą (Bee ~ tg 2020).
// Tu są rzeczy wspólne dla całego portu: mind_ui na umyśle i mobie, ekrany pełnoekranowe, drobne helpery tg.

// ---- mind_ui: przechowywane w umyśle, nie w mobie ----

/datum/mind
	///Aktywne mind_ui tego umysłu (uniqueID => /datum/mind_ui)
	var/list/active_uis = list()

/datum/mind/Destroy()
	RemoveAllUIs()
	QDEL_LIST_ASSOC_VAL(active_uis)
	return ..()

/// Ponownie wysyła wszystkie mind_ui do client.screen (po Login)
/datum/mind/proc/ResendAllUIs()
	for (var/mind_ui in active_uis)
		var/datum/mind_ui/ui = active_uis[mind_ui]
		ui.SendToClient()

/// Zdejmuje wszystkie mind_ui z client.screen (przy Logout)
/datum/mind/proc/RemoveAllUIs()
	for (var/mind_ui in active_uis)
		var/datum/mind_ui/ui = active_uis[mind_ui]
		ui.RemoveFromClient()

/datum/mind/proc/DisplayUI(ui_ID)
	init_mind_ui()
	var/datum/mind_ui/ui
	if (ui_ID in active_uis)
		ui = active_uis[ui_ID]
	else
		if (!(ui_ID in GLOB.mind_ui_id_to_type))
			return
		var/ui_type = GLOB.mind_ui_id_to_type[ui_ID]
		ui = new ui_type(src)
	if (QDELETED(ui))
		return
	if(!ui.Valid())
		ui.Hide()
	else
		ui.Display()

/datum/mind/proc/HideUI(ui_ID)
	if (ui_ID in active_uis)
		var/datum/mind_ui/ui = active_uis[ui_ID]
		ui.Hide()

/datum/mind/proc/UpdateUIScreenLoc()
	for (var/mind_ui in active_uis)
		var/datum/mind_ui/ui = active_uis[mind_ui]
		ui.UpdateUIScreenLoc()

/mob/proc/ResendAllUIs()
	if (mind)
		mind.ResendAllUIs()

/mob/proc/RemoveAllUIs()
	if (mind)
		mind.RemoveAllUIs()

/mob/proc/DisplayUI(ui_ID)
	if (mind)
		mind.DisplayUI(ui_ID)

/mob/proc/HideUI(ui_ID)
	if (mind)
		mind.HideUI(ui_ID)

/mob/proc/UpdateUIScreenLoc()
	if (mind)
		mind.UpdateUIScreenLoc()

/mob/proc/UpdateUIElementIcon(element_type)
	if (client)
		var/obj/abstract/mind_ui_element/element = locate(element_type) in client.screen
		if (element)
			element.UpdateIcon()

/mob/proc/UpdateAllElementIcons()
	if (client)
		for (var/obj/abstract/mind_ui_element/element in client.screen)
			element.UpdateIcon()

/mob/living/Login()
	. = ..()
	ResendAllUIs()

/mob/living/Logout()
	RemoveAllUIs()
	return ..()

/client/MouseDown(object, location, control, params)
	if(istype(object, /obj/abstract/mind_ui_element/hoverable/movable))
		var/obj/abstract/mind_ui_element/hoverable/movable/ui_object = object
		ui_object.MouseDown(location, control, params)
	return ..()

/client/MouseUp(object, location, control, params)
	if(istype(object, /obj/abstract/mind_ui_element/hoverable/movable))
		var/obj/abstract/mind_ui_element/hoverable/movable/ui_object = object
		ui_object.MouseUp(location, control, params)
	return ..()

// ---- ekrany pełnoekranowe kultu ----

/mob/proc/update_fullscreen_alpha(category, alpha = 255, time = 1 SECONDS)
	var/atom/movable/screen/fullscreen/screen = screens[category]
	if(!screen)
		screens -= category
		return
	if (client)
		client.screen -= screen
		animate(screen, alpha = alpha, time = time)
		client.screen += screen

/atom/movable/screen/fullscreen/conversion_border
	icon = 'aquila/icons/bloodcult/screen1_full.dmi'
	icon_state = "conversionoverlay"
	alpha = 0

/atom/movable/screen/fullscreen/confusion_border
	icon = 'aquila/icons/bloodcult/screen1_full.dmi'
	icon_state = "conversionoverlay"
	alpha = 0

/atom/movable/screen/fullscreen/deafmute_border
	icon = 'aquila/icons/bloodcult/screen1_full.dmi'
	icon_state = "conversionoverlay"
	alpha = 0

/atom/movable/screen/fullscreen/astral_border
	icon = 'aquila/icons/bloodcult/screen1_full.dmi'
	icon_state = "astraloverlay"
	alpha = 0

/atom/movable/screen/fullscreen/conversion_red
	icon = 'aquila/icons/bloodcult/screen1.dmi'
	screen_loc = "WEST, SOUTH to EAST, NORTH"
	icon_state = "redoverlay"

/atom/movable/screen/fullscreen/black
	icon = 'aquila/icons/bloodcult/screen1.dmi'
	screen_loc = "WEST, SOUTH to EAST, NORTH"
	icon_state = "black"
	layer = BLIND_LAYER
	alpha = 0

/atom/movable/screen/fullscreen/white
	icon = 'aquila/icons/bloodcult/screen1.dmi'
	screen_loc = "WEST, SOUTH to EAST, NORTH"
	icon_state = "white"
	layer = BLIND_LAYER
	alpha = 0

/atom/movable/screen/fullscreen/narsie_rising
	icon = 'aquila/icons/bloodcult/screen1.dmi'
	screen_loc = "WEST, SOUTH to EAST, NORTH"
	icon_state = "blank"

// ---- drobne helpery z nowszego tg ----

/// Zwraca coś gęstego na turfie (albo sam turf), co blokuje przejście
/turf/proc/check_blocking_content(exclude_mobs = FALSE, source_atom = null, list/ignore_atoms, type_list = FALSE)
	if(density)
		return src
	for(var/atom/movable/movable_content as anything in contents)
		if(movable_content == source_atom)
			continue
		if(length(ignore_atoms))
			if(!type_list && (movable_content in ignore_atoms))
				continue
			else if(type_list && is_type_in_list(movable_content, ignore_atoms))
				continue
		if(movable_content.density && (!exclude_mobs || !ismob(movable_content)))
			if(source_atom && movable_content.CanPass(source_atom, get_dir(src, source_atom)))
				continue
			return movable_content
	return null

/// Bodypart nieaktywnej ręki (tylko węglowe)
/mob/proc/get_inactive_hand()
	return FALSE

/mob/living/carbon/get_inactive_hand()
	var/which_hand = BODY_ZONE_PRECISE_L_HAND
	if((active_hand_index % 2))
		which_hand = BODY_ZONE_PRECISE_R_HAND
	return get_bodypart(check_zone(which_hand))

/// Obraz widoczny tylko dla jednego klienta
/proc/add_client_image(image/image_to_add, client/client)
	if(!client || !image_to_add)
		return
	client.images |= image_to_add

/proc/remove_client_image(image/image_to_remove, client/client)
	if(!client || !image_to_remove)
		return
	client.images -= image_to_remove
