// Nagrzewanie i naczynia w maszynach kuchennych z tg/Bee: piekarnik, płyta grillowa, grill, frytkownica.
// Kuchenka i kuchnia (palniki) są w aquila/code/modules/food_and_drinks/soup/stove.dm.

/// Mnożnik samego rozgrzania (bez części), dla maszyn, które liczą części po swojemu
/obj/machinery/proc/kitchen_warmup_factor()
	if(!kitchen_heat)
		return 1
	return KITCHEN_COLD_SPEED + (1 - KITCHEN_COLD_SPEED) * kitchen_heat.current()

// ---------- Piekarnik ----------

/datum/cooking_surface/oven_chamber
	name = "piekarnik"
	cooker_id = COOKER_OVEN
	allow_toggling = FALSE
	allowed_containers = list(/obj/item/reagent_containers/cooking/oven)

/obj/machinery/oven
	active_power_usage = 40
	var/datum/cooking_surface/oven_chamber/chamber

/obj/machinery/oven/Initialize(mapload)
	chamber = new(src)
	kitchen_heat = new
	. = ..()
	refresh_kitchen_heat()

/obj/machinery/oven/Destroy()
	if(chamber?.container)
		var/obj/item/dish = chamber.container
		dish.forceMove(drop_location())
	QDEL_NULL(chamber)
	QDEL_NULL(kitchen_heat)
	return ..()

/obj/machinery/oven/RefreshParts()
	. = ..()
	refresh_kitchen_heat()

/obj/machinery/oven/get_cooking_surfaces()
	return list(chamber)

/// Szybkość pieczenia: rozgrzanie, laser i ogień
/obj/machinery/oven/proc/oven_speed_factor()
	return kitchen_heat_factor() * COOK_TEMP_SPEED(chamber ? chamber.temperature : COOK_TEMP_MED)

/obj/machinery/oven/begin_processing()
	. = ..()
	kitchen_heat?.set_heating(TRUE)

/obj/machinery/oven/end_processing()
	. = ..()
	kitchen_heat?.set_heating(FALSE)
	if(chamber)
		chamber.on = FALSE

/obj/machinery/oven/examine(mob/user)
	. = ..()
	. += span_notice("Piekarnik jest [kitchen_heat.describe()], ogień [cook_temp_name(chamber.temperature)].")
	if(chamber.container)
		. += span_notice("W środku stoi [chamber.container].")
	. += span_notice("<b>Alt+klik</b>: ogień i minutnik. Naczynie żaroodporne wkładasz do otwartego piekarnika zamiast blachy.")

/obj/machinery/oven/attackby(obj/item/used, mob/user, params)
	if(!istype(used, /obj/item/reagent_containers/cooking))
		return ..()
	if(!chamber.accepts(used))
		to_chat(user, span_warning("[used] nie pasuje do piekarnika. Do pieczenia służy naczynie żaroodporne."))
		return TRUE
	if(!open)
		to_chat(user, span_warning("Najpierw otwórz [src]."))
		return TRUE
	if(used_tray || chamber.container)
		to_chat(user, span_warning("W [src] coś już stoi."))
		return TRUE
	if(user.transferItemToLoc(used, src, silent = FALSE))
		add_dish(used)
		to_chat(user, span_notice("Wstawiasz [used] do [src]."))
	return TRUE

/obj/machinery/oven/proc/add_dish(obj/item/reagent_containers/cooking/oven/dish)
	chamber.set_container(dish)
	dish.pixel_x = -2
	dish.pixel_y = -16
	dish.flags_1 |= IS_ONTOP_1
	dish.vis_flags |= VIS_INHERIT_PLANE
	if(!open)
		dish.vis_flags |= VIS_HIDE
	vis_contents += dish
	RegisterSignal(dish, COMSIG_MOVABLE_MOVED, PROC_REF(dish_moved))
	update_appearance()

/obj/machinery/oven/proc/dish_moved(obj/item/dish, atom/old_loc, dir, forced)
	SIGNAL_HANDLER
	UnregisterSignal(dish, COMSIG_MOVABLE_MOVED)
	dish.flags_1 &= ~IS_ONTOP_1
	dish.vis_flags &= ~(VIS_INHERIT_PLANE | VIS_HIDE)
	dish.pixel_x = dish.base_pixel_x
	dish.pixel_y = dish.base_pixel_y
	vis_contents -= dish
	chamber.clear_container()
	chamber.on = FALSE
	update_appearance()

/obj/machinery/oven/attack_hand(mob/user, list/modifiers)
	var/was_open = open
	. = ..()
	if(open == was_open || !chamber.container)
		return
	if(open)
		chamber.container.vis_flags &= ~VIS_HIDE
		chamber.turn_off()
	else
		chamber.container.vis_flags |= VIS_HIDE
		chamber.turn_on()
		begin_processing()
	update_appearance()

/obj/machinery/oven/process(delta_time)
	. = ..()
	if(open)
		return
	var/working = length(used_tray?.contents)
	if(chamber.container)
		working = TRUE
		chamber.on = TRUE
		chamber.process_cooking(delta_time, kitchen_heat_factor())
	if(working)
		use_power(active_power_usage)

/obj/machinery/oven/update_icon_state()
	. = ..()
	if(!open && chamber?.container)
		icon_state = "oven_on"

/obj/machinery/oven/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, TRUE))
		return ..()
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(cooking_settings_menu), src, user)
	return TRUE

// ---------- Płyta grillowa: tylko nagrzewanie ----------

/obj/machinery/griddle
	active_power_usage = 40

/obj/machinery/griddle/Initialize(mapload)
	kitchen_heat = new
	. = ..()
	refresh_kitchen_heat()

/obj/machinery/griddle/Destroy()
	QDEL_NULL(kitchen_heat)
	return ..()

/obj/machinery/griddle/RefreshParts()
	. = ..()
	refresh_kitchen_heat()

/obj/machinery/griddle/begin_processing()
	. = ..()
	kitchen_heat?.set_heating(TRUE)

/obj/machinery/griddle/end_processing()
	. = ..()
	kitchen_heat?.set_heating(FALSE)

/obj/machinery/griddle/process(delta_time)
	. = ..()
	if(on)
		use_power(active_power_usage)

/obj/machinery/griddle/examine(mob/user)
	. = ..()
	. += span_notice("Płyta jest [kitchen_heat.describe()].")

// ---------- Grill na węgiel: ruszt ----------

/datum/cooking_surface/grill_grate
	name = "ruszt"
	cooker_id = COOKER_GRILL
	allow_toggling = FALSE
	allow_temp_change = FALSE
	allowed_containers = list(/obj/item/reagent_containers/cooking/grill_grate)

/obj/machinery/grill
	var/datum/cooking_surface/grill_grate/grate_surface

/obj/machinery/grill/Initialize(mapload)
	grate_surface = new(src)
	. = ..()

/obj/machinery/grill/Destroy()
	QDEL_NULL(grate_surface)
	return ..()

/obj/machinery/grill/get_cooking_surfaces()
	return list(grate_surface)

/obj/machinery/grill/attackby(obj/item/used, mob/user, params)
	if(istype(used, /obj/item/reagent_containers/cooking))
		if(!grate_surface.accepts(used))
			to_chat(user, span_warning("[used] nie pasuje na grill. Na grill kładzie się ruszt."))
			return TRUE
		if(grilled_item || grate_surface.container)
			to_chat(user, span_warning("Na [src] coś już leży."))
			return TRUE
		if(!grill_fuel)
			to_chat(user, span_notice("Za mało paliwa."))
			return TRUE
		if(user.transferItemToLoc(used, src))
			grate_surface.set_container(used)
			used.pixel_y = 6
			used.flags_1 |= IS_ONTOP_1
			used.vis_flags |= VIS_INHERIT_PLANE
			vis_contents += used
			grill_loop.start()
			to_chat(user, span_notice("Kładziesz [used] na [src]."))
			update_appearance()
		return TRUE
	if(grate_surface.container && IS_EDIBLE(used) && !user.combat_mode)
		return grate_surface.container.attackby(used, user, params)
	return ..()

/obj/machinery/grill/process(delta_time)
	. = ..()
	if(!grate_surface.container || grill_fuel <= 0)
		grate_surface.on = FALSE
		return
	grill_fuel -= 5 * delta_time
	grate_surface.on = TRUE
	grate_surface.process_cooking(delta_time, 1)

/obj/machinery/grill/attack_hand(mob/user, list/modifiers)
	if(grate_surface.container)
		var/obj/item/grate = grate_surface.container
		to_chat(user, span_notice("Zdejmujesz [grate] z [src]."))
		if(!user.put_in_hands(grate))
			grate.forceMove(drop_location())
		return TRUE
	return ..()

/obj/machinery/grill/Exited(atom/movable/gone, direction)
	if(gone == grate_surface?.container)
		grate_surface.clear_container()
		grate_surface.on = FALSE
		vis_contents -= gone
		gone.flags_1 &= ~IS_ONTOP_1
		gone.vis_flags &= ~VIS_INHERIT_PLANE
		gone.pixel_y = gone.base_pixel_y
		grill_loop.stop()
		update_appearance()
	return ..()

/obj/machinery/grill/update_icon_state()
	. = ..()
	if(grate_surface?.container)
		icon_state = "grill"

// ---------- Frytkownica: koszyk i rozgrzewanie oleju ----------

/datum/cooking_surface/fryer_basket
	name = "kosz frytkownicy"
	cooker_id = COOKER_FRYER
	allow_toggling = FALSE
	allow_temp_change = FALSE
	allowed_containers = list(/obj/item/reagent_containers/cooking/deep_basket)

/obj/machinery/deepfryer
	var/datum/cooking_surface/fryer_basket/basket_surface

/obj/machinery/deepfryer/Initialize(mapload)
	basket_surface = new(src)
	kitchen_heat = new
	. = ..()

/obj/machinery/deepfryer/Destroy()
	if(basket_surface?.container)
		var/obj/item/basket = basket_surface.container
		basket.forceMove(drop_location())
	QDEL_NULL(basket_surface)
	QDEL_NULL(kitchen_heat)
	return ..()

/obj/machinery/deepfryer/get_cooking_surfaces()
	return list(basket_surface)

/obj/machinery/deepfryer/examine(mob/user)
	. = ..()
	. += span_notice("Olej jest [kitchen_heat.describe()].")
	if(basket_surface.container)
		. += span_notice("W oleju jest [basket_surface.container].")

/obj/machinery/deepfryer/attackby(obj/item/weapon, mob/user, params)
	if(istype(weapon, /obj/item/reagent_containers/cooking))
		if(!basket_surface.accepts(weapon))
			to_chat(user, span_warning("[weapon] nie pasuje do frytkownicy. Do smażenia w oleju służy koszyk."))
			return TRUE
		if(!reagents.has_reagent(/datum/reagent/consumable/nutriment/fat/oil))
			to_chat(user, span_warning("[src] nie ma oleju do smażenia!"))
			return TRUE
		if(frying || basket_surface.container)
			to_chat(user, span_warning("W [src] coś się już smaży."))
			return TRUE
		if(user.transferItemToLoc(weapon, src))
			basket_surface.set_container(weapon)
			basket_surface.on = TRUE
			kitchen_heat.set_heating(TRUE)
			icon_state = "fryer_on"
			fry_loop.start()
			to_chat(user, span_notice("Zanurzasz [weapon] w [src]."))
		return TRUE
	return ..()

/obj/machinery/deepfryer/start_fry(obj/item/frying_item, mob/user)
	. = ..()
	kitchen_heat?.set_heating(TRUE)

/obj/machinery/deepfryer/reset_frying()
	. = ..()
	if(!basket_surface?.container)
		kitchen_heat?.set_heating(FALSE)

/obj/machinery/deepfryer/process(delta_time)
	. = ..()
	if(!basket_surface.container)
		return
	if(!reagents.has_reagent(/datum/reagent/consumable/nutriment/fat/oil))
		return
	reagents.remove_reagent(/datum/reagent/consumable/nutriment/fat/oil, oil_use * delta_time)
	basket_surface.process_cooking(delta_time, max(fry_speed, 1) * kitchen_warmup_factor())
	if(!frying)
		use_power(active_power_usage)

/obj/machinery/deepfryer/attack_hand(mob/living/user)
	if(basket_surface.container)
		var/obj/item/basket = basket_surface.container
		to_chat(user, span_notice("Wyjmujesz [basket] z [src]."))
		if(!user.put_in_hands(basket))
			basket.forceMove(drop_location())
		return TRUE
	return ..()

/obj/machinery/deepfryer/Exited(atom/movable/gone, direction)
	if(gone == basket_surface?.container)
		basket_surface.clear_container()
		basket_surface.on = FALSE
		if(!frying)
			fry_loop.stop()
			icon_state = "fryer_off"
			kitchen_heat.set_heating(FALSE)
	return ..()
