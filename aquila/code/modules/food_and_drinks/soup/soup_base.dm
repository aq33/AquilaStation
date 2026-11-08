// AQUILA - zupy jako odczynniki z tgstation/tgstation#74205 (z poprawkami tgstation/tgstation#74882 i #78120).
// Do garnka (soup_pot) wlewa się wodę i wrzuca składniki; garnek na kuchence się grzeje i zachodzi reakcja.
// Różnice względem tg: nasze on_reaction() ma dwa argumenty, więc listę składników zakłada pierwszy krok reakcji;
// required_other u nas znaczy ekstrakt szlamu, więc zupa sprawdza garnek w pre_reaction_other_checks();
// wygląd miski z zupy bierze się z bowl_icon_state odczynnika (tg: glass_style).

/// Abstract parent for soup reagents.
/// These are the majority result from soup recipes,
/// but bear in mind it will(should) have other reagents along side it.
/datum/reagent/consumable/nutriment/soup
	name = "Zupa"
	nutriment_factor = 12 * REAGENTS_METABOLISM // Slightly less to that of nutriment as soups will come with nutriments in tow
	/// Stan ikony miski z tą zupą (aquila/icons/obj/food/soup/soupsalad_tg.dmi)
	var/bowl_icon_state

/**
 * ## Soup base chemical reaction.
 *
 * Keep in mind one serving of soup is roughly 20-25 units. Try to aim to have each reaction worth 3 servings of soup (60u - 90u).
 * By default soup reactions require 50 units of water, and they will also inherent the reagents of the ingredients used.
 */
/datum/chemical_reaction/food/soup
	required_temp = 450
	optimal_temp = 480
	overheat_temp = SOUP_BURN_TEMP
	optimal_ph_min = 1
	optimal_ph_max = 14
	thermic_constant = 10
	required_reagents = null
	mob_react = FALSE
	required_container = /obj/item/reagent_containers/glass/soup_pot
	mix_message = "Z parującego garnka zupy dochodzi przyjemny zapach."
	reaction_tags = REACTION_TAG_FOOD | REACTION_TAG_EASY

	/// An assoc list of what ingredients are necessary to how much is needed
	var/list/required_ingredients
	/// Tracks the total number of ingredient items needed, for calculating multipliers
	var/total_ingredient_max

	/// Multiplier applied to all reagents transfered from reagents to pot when the soup is cooked
	var/ingredient_reagent_multiplier = 0.8
	/// What percent of nutriment is converted to "soup" (what percent does not stay final product)?
	var/percentage_of_nutriment_converted = 0.25

/datum/chemical_reaction/food/soup/pre_reaction_other_checks(datum/reagents/holder)
	var/obj/item/reagent_containers/glass/soup_pot/pot = holder.my_atom
	if(!istype(pot))
		return FALSE
	if(!length(required_ingredients))
		return TRUE

	var/list/reqs_copy = required_ingredients.Copy()
	for(var/obj/item/ingredient as anything in pot.added_ingredients)
		for(var/ingredient_type in required_ingredients)
			if(!istype(ingredient, ingredient_type))
				continue
			if(isstack(ingredient))
				var/obj/item/stack/stack_ingredient = ingredient
				reqs_copy[ingredient_type] -= stack_ingredient.amount
			else
				reqs_copy[ingredient_type] -= 1
			break // tgstation/tgstation#78120: jeden przedmiot liczy się do jednego wymagania

	for(var/fulfilled in reqs_copy)
		if(reqs_copy[fulfilled] > 0)
			return FALSE
	return TRUE

/// U nas on_reaction() nie dostaje equilibrium, więc składniki zapisuje pierwszy krok reakcji
/datum/chemical_reaction/food/soup/proc/start_tracking(datum/reagents/holder, datum/equilibrium/reaction)
	if(isnull(total_ingredient_max))
		total_ingredient_max = 0
		for(var/ingredient_type in required_ingredients)
			total_ingredient_max += required_ingredients[ingredient_type]

	var/obj/item/reagent_containers/glass/soup_pot/pot = holder.my_atom
	var/list/tracked_ingredients = list()
	for(var/obj/item/ingredient as anything in pot.added_ingredients)
		tracked_ingredients[WEAKREF(ingredient)] = ingredient.reagents?.total_volume || 1
		ingredient.reagents?.chem_temp = holder.chem_temp
	reaction.data["ingredients"] = tracked_ingredients

/datum/chemical_reaction/food/soup/reaction_step(datum/reagents/holder, datum/equilibrium/reaction, delta_t, delta_ph, step_reaction_vol)
	if(!length(required_ingredients))
		return
	if(isnull(reaction.data["ingredients"]))
		start_tracking(holder, reaction)

	var/obj/item/reagent_containers/glass/soup_pot/pot = holder.my_atom
	var/list/cached_ingredients = reaction.data["ingredients"]
	var/num_current_ingredients = length(pot.added_ingredients)
	var/num_cached_ingredients = length(cached_ingredients)

	// Clamp multiplier to ingredient number
	reaction.multiplier = min(reaction.multiplier, num_current_ingredients / max(total_ingredient_max, 1))

	// An ingredient was removed during the mixing process. Stop, we can't verify the reaction is correct still.
	if(num_current_ingredients < num_cached_ingredients)
		return END_REACTION

	// An ingredient was added mid mix
	else if(num_current_ingredients > num_cached_ingredients)
		for(var/obj/item/new_ingredient as anything in pot.added_ingredients)
			var/datum/weakref/new_ref = WEAKREF(new_ingredient)
			if(cached_ingredients[new_ref])
				continue
			new_ingredient.reagents?.chem_temp = holder.chem_temp
			cached_ingredients[new_ref] = new_ingredient.reagents?.total_volume || 1

	for(var/datum/weakref/ingredient_ref as anything in cached_ingredients)
		var/obj/item/ingredient = ingredient_ref.resolve()
		if(QDELETED(ingredient) || ingredient.loc != holder.my_atom)
			return END_REACTION

		if(reaction.data["boiled_over"])
			continue

		// Transfer 20% of the initial reagent volume of the ingredient to the soup
		transfer_ingredient_reagents(ingredient, holder, max(cached_ingredients[ingredient_ref] * 0.2, 2))

		// Uh oh we reached the top of the pot, the soup's gonna boil over.
		if(holder.total_volume >= holder.maximum_volume * 0.95)
			boil_over(holder)
			reaction.data["boiled_over"] = TRUE

/datum/chemical_reaction/food/soup/reaction_finish(datum/reagents/holder, datum/equilibrium/reaction, react_vol)
	. = ..()
	var/obj/item/reagent_containers/glass/soup_pot/pot = holder.my_atom
	if(!istype(pot))
		CRASH("[pot ? "Non-pot atom" : "Null pot"]) made it to the end of the [type] reaction chain.")
	reaction.data["ingredients"] = null

	for(var/obj/item/ingredient as anything in pot.added_ingredients)
		// Let's not mess with fireproof / indestructible items.
		if(ingredient.resistance_flags & (FIRE_PROOF|INDESTRUCTIBLE))
			continue

		// Things that had reagents or ingredients in the soup will get deleted
		if(!isnull(ingredient.reagents) || is_type_in_list(ingredient, required_ingredients))
			transfer_ingredient_reagents(ingredient, holder)
			qdel(ingredient)

		// Everything else will just get fried
		else
			ingredient.AddElement(/datum/element/fried_item, 30)

	LAZYNULL(pot.added_ingredients)
	pot.update_appearance(UPDATE_OVERLAYS)

/datum/chemical_reaction/food/soup/proc/transfer_ingredient_reagents(obj/item/ingredient, datum/reagents/holder, amount)
	var/datum/reagents/ingredient_pool = ingredient.reagents
	if(isnull(ingredient_pool) || ingredient_pool.total_volume <= 0)
		return
	if(isnull(amount))
		amount = ingredient_pool.total_volume

	// Some of the nutriment goes into "creating the soup reagent" itself, gets deleted.
	ingredient_pool.remove_reagent(/datum/reagent/consumable/nutriment, amount * percentage_of_nutriment_converted)
	ingredient_pool.remove_reagent(/datum/reagent/consumable/nutriment/vitamin, amount * percentage_of_nutriment_converted)
	// The other half of the nutriment, and the rest of the reagents, will get put directly into the pot
	ingredient_pool.trans_to(holder, amount, ingredient_reagent_multiplier, no_react = TRUE)

/datum/chemical_reaction/food/soup/proc/boil_over(datum/reagents/holder)
	var/obj/item/reagent_containers/glass/soup_pot/pot = holder.my_atom
	var/turf/below_pot = get_turf(pot)
	below_pot.visible_message(span_warning("[pot] zaczyna kipieć!"))
	// Trochę rozlewa się po podłodze
	var/datum/reagents/spill = new(holder.total_volume * 0.1)
	holder.trans_to(spill, holder.total_volume * 0.1, no_react = TRUE)
	spill.reaction(below_pot, TOUCH)
	qdel(spill)

/// This subtype is only for easy mapping / spawning in specific types of soup. Do not use it anywhere else.
/obj/item/reagent_containers/glass/bowl/soup
	var/initial_reagent
	var/initial_portion = SOUP_SERVING_SIZE

/obj/item/reagent_containers/glass/bowl/soup/Initialize(mapload)
	. = ..()
	if(initial_reagent)
		reagents.add_reagent(initial_reagent, initial_portion)

/// Miska wygląda jak zupa, która ma w niej przewagę (tg: glass_style)
/obj/item/reagent_containers/glass/bowl/on_reagent_change(changetype)
	. = ..()
	var/datum/reagent/consumable/nutriment/soup/soup = reagents?.get_master_reagent()
	if(istype(soup) && soup.bowl_icon_state)
		icon = 'aquila/icons/obj/food/soup/soupsalad_tg.dmi'
		icon_state = soup.bowl_icon_state
		name = "miska: [lowertext(soup.name)]"
		desc = soup.description
		return
	icon = initial(icon)
	icon_state = initial(icon_state)
	name = initial(name)
	desc = initial(desc)

/// Garnek na zupę
/obj/item/reagent_containers/glass/soup_pot
	name = "garnek"
	desc = "Wysoki garnek do mieszania i gotowania wszelkich zup."
	icon = 'aquila/icons/obj/food/soup/soup_pot.dmi'
	icon_state = "pot"
	base_icon_state = "pot"
	volume = 200
	possible_transfer_amounts = list(20, 50, 100, 200)
	amount_per_transfer_from_this = 50
	reagent_flags = OPENCONTAINER
	custom_materials = list(/datum/material/iron = 5000)
	w_class = WEIGHT_CLASS_BULKY
	custom_price = 80
	/// Max number of ingredients we can add
	var/max_ingredients = 24
	/// A lazylist of all the ingredients we have added
	var/list/obj/item/added_ingredients

/obj/item/reagent_containers/glass/soup_pot/Destroy()
	LAZYNULL(added_ingredients)
	return ..()

/obj/item/reagent_containers/glass/soup_pot/examine(mob/user)
	. = ..()
	. += span_notice("Zmieści jeszcze <b>[max_ingredients - LAZYLEN(added_ingredients)]</b> składników i <b>[reagents.maximum_volume - reagents.total_volume]</b> jednostek płynów.")
	if(LAZYLEN(added_ingredients))
		var/list/ingredient_amounts = list()
		for(var/obj/item/ingredient as anything in added_ingredients)
			ingredient_amounts[ingredient.name] += 1
		var/list/names = list()
		for(var/ingredient_name in ingredient_amounts)
			names += "[ingredient_amounts[ingredient_name]]× [ingredient_name]"
		. += span_notice("W środku: [english_list(names, and_text = " i ")].")
	if(reagents.total_volume > 0 && reagents.chem_temp > SOUP_WATER_BOILING_POINT)
		. += span_notice("Zawartość wrze.")
	if(reagents.is_reacting)
		. += span_warning("Właśnie się gotuje!")
	. += span_notice("Składnik wyjmiesz [user.secondary_click_text()] pustą ręką.")

/obj/item/reagent_containers/glass/soup_pot/Exited(atom/movable/gone, direction)
	. = ..()
	LAZYREMOVE(added_ingredients, gone)

/obj/item/reagent_containers/glass/soup_pot/attackby(obj/item/attacking_item, mob/user, params)
	if(!can_add_ingredient(attacking_item))
		return ..()

	if(LAZYLEN(added_ingredients) >= max_ingredients)
		balloon_alert(user, "za dużo składników!")
		return TRUE
	if(!user.transferItemToLoc(attacking_item, src))
		balloon_alert(user, "nie da się tego dodać!")
		return TRUE

	var/atom/balloon_loc = ismachinery(loc) ? loc : src
	balloon_loc.balloon_alert(user, "dodano składnik")
	user.face_atom(balloon_loc)
	LAZYADD(added_ingredients, attacking_item)
	update_appearance(UPDATE_OVERLAYS)
	reagents.handle_reactions()
	return TRUE

/obj/item/reagent_containers/glass/soup_pot/attack_hand_secondary(mob/user, list/modifiers)
	if(!LAZYLEN(added_ingredients))
		return SECONDARY_ATTACK_CALL_NORMAL

	var/obj/item/removed = added_ingredients[1]
	removed.forceMove(get_turf(src))
	user.put_in_hands(removed)
	var/atom/balloon_loc = ismachinery(loc) ? loc : src
	balloon_loc.balloon_alert(user, "wyjęto składnik")
	user.face_atom(balloon_loc)
	update_appearance(UPDATE_OVERLAYS)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/reagent_containers/glass/soup_pot/proc/can_add_ingredient(obj/item/ingredient)
	// Let default reagent handling take this
	if(ingredient.is_open_container())
		return FALSE
	// Too big for the pot
	if(ingredient.w_class >= WEIGHT_CLASS_BULKY)
		return FALSE
	if(ingredient.item_flags & (ABSTRACT|DROPDEL))
		return FALSE
	return TRUE

// Wylanie wszystkiego z garnka wyrzuca też składniki (tg: COMSIG_REAGENTS_CLEAR_REAGENTS)
/obj/item/reagent_containers/glass/soup_pot/on_reagent_change(changetype)
	. = ..()
	if(changetype == CLEAR_REAGENTS && LAZYLEN(added_ingredients))
		dump_ingredients()
	update_appearance(UPDATE_OVERLAYS)

/obj/item/reagent_containers/glass/soup_pot/proc/dump_ingredients(atom/drop_loc = drop_location())
	for(var/obj/item/ingredient as anything in added_ingredients)
		ingredient.forceMove(drop_loc)
		ingredient.pixel_x += rand(-4, 4)
		ingredient.pixel_y += rand(-4, 4)
		ingredient.SpinAnimation(loops = 1)
	update_appearance(UPDATE_OVERLAYS)

/obj/item/reagent_containers/glass/soup_pot/update_overlays()
	. = ..()
	if(!LAZYLEN(added_ingredients) && reagents?.total_volume <= 0)
		return
	var/mutable_appearance/filled_overlay = mutable_appearance(icon, "[base_icon_state]_filling_overlay")
	var/list/food_reagents = list()
	for(var/obj/item/ingredient as anything in added_ingredients)
		if(isnull(ingredient.reagents))
			continue
		food_reagents |= ingredient.reagents.reagent_list
	// Bez kanału alfa z koloru odczynnika: woda (#AAAAAA77) była w garnku prawie niewidoczna
	filled_overlay.color = copytext(mix_color_from_reagents(reagents.reagent_list + food_reagents), 1, 8)
	. += filled_overlay

/// Chochla: nabiera porcję zupy z garnka i przelewa do miski (u nas łyżki nie nabierają płynów)
/obj/item/reagent_containers/glass/soup_ladle
	name = "chochla"
	desc = "Czym jest chochla, jeśli nie śmiesznie wielką łyżką?"
	icon = 'aquila/icons/obj/food/soup/kitchen_ladle.dmi'
	icon_state = "ladle"
	item_state = "spoon"
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	volume = SOUP_SERVING_SIZE + 5
	possible_transfer_amounts = list(SOUP_SERVING_SIZE)
	amount_per_transfer_from_this = SOUP_SERVING_SIZE
	reagent_flags = OPENCONTAINER
	w_class = WEIGHT_CLASS_SMALL
	custom_price = 20
	fill_icon_thresholds = null

// Pusta chochla nabiera z garnka. Zwykłe szkło przy otwartym pojemniku zawsze przelewa do niego, więc pusta chochla tylko zgłaszała, że jest pusta.
/obj/item/reagent_containers/glass/soup_ladle/afterattack(obj/target, mob/user, proximity)
	if(!proximity || reagents.total_volume || !target.is_drainable() || !check_allowed_items(target, target_self = TRUE))
		return ..()
	if(!target.reagents?.total_volume)
		to_chat(user, span_warning("[target] jest pusty!"))
		return
	var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this, transfered_by = user)
	to_chat(user, span_notice("Nabierasz chochlą [trans] j. z [target]."))
	playsound(src, 'aquila/sound/items/pour.ogg', 15, TRUE)

/obj/item/reagent_containers/glass/soup_ladle/update_icon_state()
	icon_state = reagents?.total_volume ? "ladle_filled" : "ladle"
	return ..()

/obj/item/reagent_containers/glass/soup_ladle/on_reagent_change(changetype)
	. = ..()
	update_appearance(UPDATE_ICON_STATE)
