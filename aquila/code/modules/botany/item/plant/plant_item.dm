/obj/item/plant
	name = "roślina"
	desc = "Odrobina natury, przeważnie nieruchoma."
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = ""
	flags_1 = IS_ONTOP_1
	appearance_flags = TILE_BOUND | LONG_GLIDE | KEEP_APART | KEEP_TOGETHER
	interaction_flags_item = NONE
	layer = OBJ_LAYER
	w_class = WEIGHT_CLASS_TINY // Hack for storage quirks
	item_flags = NO_PIXEL_RANDOM_DROP
	///Does this plant item skip it's growth cycle
	var/skip_growth = FALSE

/obj/item/plant/Initialize(mapload, _plant_features, _species_id, _plant_name)
	. = ..()
	name = _plant_name || name
	AddComponent(/datum/component/plant, src, _plant_features, _species_id, skip_growth)

/obj/item/plant/attack_hand(mob/user, modifiers)
	. = ..()
	// AQUILA - roślina w tacy przekazuje klik dalej: ciągnięty obiekt jedzie na kliknięty kafel, a pusta ręka zbiera całą tacę
	var/obj/item/plant_tray/tray = loc
	if(istype(tray) && isliving(user))
		var/mob/living/living_user = user
		if(living_user.pulling)
			var/turf/clicked
			if(user.client && LAZYACCESS(modifiers, SCREEN_LOC))
				var/list/click_modifiers = modifiers
				clicked = parse_caught_click_modifiers(click_modifiers.Copy(), get_turf(user.client.eye), user.client)
			living_user.Move_Pulled(clicked || get_turf(tray))
		else if(!tray.harvest_all(living_user) && !.)
			to_chat(user, span_notice("Nic tu jeszcze nie dojrzało. Stan roślin pokaże skaner roślin, a łopatką przeniesiesz roślinę."))
	return FALSE //This item can't be picked up, only with a spade

/obj/item/plant/add_context_self(datum/screentip_context/context, mob/user)
	. = ..()
	if(!isliving(user))
		return
	context.add_left_click_item_action("Przenieś", /obj/item/shovel)

/obj/item/plant/apply_outline(colour)
	return
