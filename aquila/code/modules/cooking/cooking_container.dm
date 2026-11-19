// Sprite'y naczyń: Paradise (icons/obj/cooking/containers.dmi), CC BY-SA 3.0.

/obj/effect/cooking_container_lip
	icon = 'aquila/icons/obj/food/cooking/containers.dmi'
	icon_state = "blank"
	vis_flags = VIS_INHERIT_ID

/**
 * Naczynie do gotowania krok po kroku: składniki wkłada się po kolei, a naczynie stawia na kuchence,
 * w piekarniku, na grillu albo we frytkownicy. Postęp trzyma [/datum/cooking/recipe_tracker].
 */
/obj/item/reagent_containers/cooking
	name = "naczynie"
	icon = 'aquila/icons/obj/food/cooking/containers.dmi'
	w_class = WEIGHT_CLASS_SMALL
	volume = 240
	reagent_flags = OPENCONTAINER
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5, 10, 20, 50)
	var/datum/cooking/recipe_tracker/tracker
	/// Czy naczynie ma brzeg rysowany nad zawartością
	var/lip = TRUE
	var/obj/effect/cooking_container_lip/lip_effect
	/// Czas gotowania: urządzenie => ogień => dziesiąte części sekundy
	var/list/cooker_data = list()
	/// Przyimek i nazwa w miejscowniku do opisu przepisu („na patelni”)
	var/preposition = "w"
	var/where_name = "naczyniu"
	/// Czy naczynie stoi na maszynie i jest rysowane w małej wersji
	var/mini = FALSE
	/// Palnik albo komora, na której stoi naczynie
	var/datum/cooking_surface/surface

/obj/item/reagent_containers/cooking/Initialize(mapload)
	. = ..()
	reagents.flags |= NO_REACT
	update_lip_effect()

/obj/item/reagent_containers/cooking/Destroy()
	QDEL_NULL(tracker)
	QDEL_NULL(lip_effect)
	surface = null
	return ..()

/obj/item/reagent_containers/cooking/proc/update_lip_effect()
	QDEL_NULL(lip_effect)
	if(lip)
		lip_effect = new
		lip_effect.icon_state = "[icon_state]_lip"

/obj/item/reagent_containers/cooking/examine(mob/user)
	. = ..()
	if(length(contents))
		. += span_notice("W środku: [english_list(contents)].")
	. += get_recipe_hints()
	. += span_notice("<b>Alt+klik</b>, gdy naczynie nie stoi na maszynie: wysypujesz zawartość.")

/// Podpowiedź: co może z tego wyjść i jaki jest następny krok
/obj/item/reagent_containers/cooking/proc/get_recipe_hints()
	. = list()
	if(!tracker || !tracker.recipe_started)
		return
	var/shown = 0
	for(var/datum/cooking/recipe/recipe as anything in tracker.recipes_last_completed_step)
		var/index = tracker.recipes_last_completed_step[recipe]
		if(index >= length(recipe.steps) || !recipe.product_type)
			continue
		var/datum/cooking/recipe_step/next_step = recipe.steps[index + 1]
		var/atom/product = recipe.product_type
		. += span_notice("Może z tego wyjść: [initial(product.name)]. Następnie: [lowertext(next_step.get_pda_formatted_desc())]")
		if(++shown >= 3)
			break

/obj/item/reagent_containers/cooking/attackby(obj/item/used, mob/user, params)
	if(user.combat_mode)
		return ..()
	var/result = process_item(user, used)
	if(result == COOK_NO_STEPS && (istype(used, /obj/item/reagent_containers) && used.is_open_container()))
		return ..() // zwykłe przelewanie, gdy przepis nie chce tego odczynnika
	return TRUE

/// Próbuje posunąć przepisy w naczyniu przedmiotem albo maszyną, na której stoi
/obj/item/reagent_containers/cooking/proc/process_item(mob/user, obj/used)
	if(!istype(used))
		return COOK_NO_STEPS
	if(!tracker)
		if(!length(cooking_recipes_for(type)))
			return COOK_NO_STEPS
		if(!ismachinery(used) && (length(contents) || reagents.total_volume))
			if(user)
				to_chat(user, span_notice("W [src] coś już jest. Najpierw je opróżnij (Alt+klik)."))
			return COOK_CONTAINER_FULL
		tracker = new(src)
	var/result = tracker.process_item(user, used)
	react_to_process(result, user, used)
	return result

/obj/item/reagent_containers/cooking/proc/react_to_process(result, mob/user, obj/used)
	if(ismachinery(used))
		if(result == COOK_COMPLETE)
			QDEL_NULL(tracker)
			clear_cooking_data()
			update_appearance()
		else if(result == COOK_NO_STEPS && !tracker.recipe_started)
			QDEL_NULL(tracker)
		return
	if(!ismob(user))
		if(result == COOK_COMPLETE)
			QDEL_NULL(tracker)
			clear_cooking_data()
		update_appearance()
		return
	switch(result)
		if(COOK_NO_STEPS)
			if(tracker && !tracker.recipe_started)
				QDEL_NULL(tracker)
				to_chat(user, span_notice("Nie znasz przepisu, który zaczyna się od tego w [src]."))
			else
				to_chat(user, span_notice("To raczej nie pasuje do tego, co gotujesz."))
		if(COOK_SUCCESS, COOK_PARTIAL_SUCCESS)
			if(tracker?.step_reaction_message)
				to_chat(user, span_notice(tracker.step_reaction_message))
		if(COOK_COMPLETE)
			QDEL_NULL(tracker)
			clear_cooking_data()
	update_appearance()

/// Przypalenie: zawartość zamienia się w zakalec
/obj/item/reagent_containers/cooking/proc/handle_burning()
	var/had_contents = length(contents)
	clear()
	if(had_contents)
		new /obj/item/food/badrecipe(src)
	update_appearance()

/obj/item/reagent_containers/cooking/proc/do_empty(mob/user, atom/target)
	var/turf/drop = get_turf(target || src)
	for(var/atom/movable/thing as anything in contents)
		remove_from_visible(thing)
		thing.forceMove(drop)
	reagents.clear_reagents()
	if(user)
		to_chat(user, span_notice("Opróżniasz [src]."))
	QDEL_NULL(tracker)
	clear_cooking_data()
	update_appearance()

/obj/item/reagent_containers/cooking/AltClick(mob/user)
	if(surface || !user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, TRUE))
		return ..()
	if(!length(contents) && !reagents.total_volume)
		return ..()
	do_empty(user)
	return TRUE

/obj/item/reagent_containers/cooking/proc/clear()
	QDEL_LIST(contents)
	reagents.clear_reagents()
	QDEL_NULL(tracker)
	clear_cooking_data()

/obj/item/reagent_containers/cooking/proc/add_cook_time(cooker_id, temperature, amount)
	if(!cooker_data[cooker_id])
		cooker_data[cooker_id] = list()
	cooker_data[cooker_id][temperature] += amount

/obj/item/reagent_containers/cooking/proc/get_cooker_time(cooker_id, temperature)
	var/list/by_temp = cooker_data[cooker_id]
	return by_temp ? (by_temp[temperature] || 0) : 0

/obj/item/reagent_containers/cooking/proc/clear_cooking_data()
	cooker_data.Cut()

/obj/item/reagent_containers/cooking/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	update_appearance()

/obj/item/reagent_containers/cooking/Exited(atom/movable/gone, direction)
	. = ..()
	remove_from_visible(gone)
	if(!QDELETED(src))
		update_appearance()

/obj/item/reagent_containers/cooking/update_overlays()
	. = ..()
	vis_contents -= lip_effect
	for(var/obj/thing in vis_contents)
		remove_from_visible(thing)
	for(var/i = length(contents), i >= 1, i--)
		var/obj/thing = contents[i]
		if(istype(thing))
			add_to_visible(thing)
	if(length(contents) && lip_effect)
		vis_contents += lip_effect

/obj/item/reagent_containers/cooking/proc/add_to_visible(obj/thing)
	thing.pixel_x = 0
	thing.pixel_y = mini ? -1 : 0
	thing.vis_flags = VIS_INHERIT_LAYER | VIS_INHERIT_PLANE | VIS_INHERIT_ID
	thing.blend_mode = BLEND_INSET_OVERLAY
	thing.transform = matrix() * (mini ? 0.5 : 0.6)
	vis_contents += thing

/obj/item/reagent_containers/cooking/proc/remove_from_visible(atom/movable/thing)
	if(!(thing in vis_contents))
		return
	thing.vis_flags = initial(thing.vis_flags)
	thing.blend_mode = initial(thing.blend_mode)
	thing.transform = null
	vis_contents -= thing

/obj/item/reagent_containers/cooking/proc/make_mini()
	mini = TRUE
	icon_state = "[initial(icon_state)]_s"
	update_lip_effect()
	update_appearance()

/obj/item/reagent_containers/cooking/proc/unmake_mini()
	mini = FALSE
	icon_state = initial(icon_state)
	update_lip_effect()
	update_appearance()

/obj/item/reagent_containers/cooking/board
	name = "deska do krojenia"
	desc = "Na niej kroi się, sieka i składa kanapki."
	icon_state = "cutting_board"
	preposition = "na"
	where_name = "desce do krojenia"
	custom_materials = list(/datum/material/wood = 2000)

/obj/item/reagent_containers/cooking/board/make_mini()
	return

/obj/item/reagent_containers/cooking/oven
	name = "naczynie żaroodporne"
	desc = "Wkłada się do niego składniki i wstawia do piekarnika."
	icon_state = "oven_dish"
	where_name = "naczyniu żaroodpornym"
	custom_materials = list(/datum/material/iron = 1500)

/obj/item/reagent_containers/cooking/pan
	name = "patelnia"
	desc = "Zwykła patelnia. Smaży się na niej na kuchence."
	icon_state = "pan"
	preposition = "na"
	where_name = "patelni"
	custom_materials = list(/datum/material/iron = 1000)
	force = 8
	throwforce = 10
	attack_verb = list("uderza", "smaży")
	hitsound = 'sound/weapons/smash.ogg'

/obj/item/reagent_containers/cooking/pot
	name = "rondel"
	desc = "Do gotowania na kuchence: makaronów, gulaszy, sosów. Na zupy jest osobny duży garnek."
	icon_state = "pot"
	where_name = "rondlu"
	custom_materials = list(/datum/material/iron = 1250)
	force = 8
	throwforce = 10
	hitsound = 'sound/weapons/smash.ogg'
	attack_verb = list("uderza", "gotuje")
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/reagent_containers/cooking/deep_basket
	name = "koszyk do frytkownicy"
	desc = "Wkłada się do niego składniki i zanurza we frytkownicy."
	icon_state = "deepfryer_basket"
	where_name = "koszyku do frytkownicy"
	custom_materials = list(/datum/material/iron = 1000)

/obj/item/reagent_containers/cooking/grill_grate
	name = "ruszt"
	desc = "Kładzie się na nim mięso i warzywa, a ruszt na grillu."
	icon_state = "grill_grate"
	preposition = "na"
	where_name = "ruszcie"
	lip = FALSE
	custom_materials = list(/datum/material/iron = 750)

/obj/item/reagent_containers/cooking/bowl
	name = "miska do mieszania"
	desc = "Do mieszania ciasta i sałatek. Nie je się z niej."
	icon_state = "bowl"
	where_name = "misce do mieszania"
	custom_materials = list(/datum/material/iron = 400, /datum/material/glass = 100)

/obj/item/reagent_containers/cooking/bowl/make_mini()
	return
