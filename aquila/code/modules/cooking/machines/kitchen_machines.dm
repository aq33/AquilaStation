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
	update_kitchen_heating()

/obj/machinery/oven/end_processing()
	. = ..()
	if(chamber)
		chamber.on = FALSE
	update_kitchen_heating()

/obj/machinery/oven/is_kitchen_active()
	return !open && (length(used_tray?.contents) || chamber?.container)

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
	if(open == was_open)
		return
	if(open)
		chamber.container?.vis_flags &= ~VIS_HIDE
		chamber.turn_off()
	else if(chamber.container || used_tray)
		chamber.container?.vis_flags |= VIS_HIDE
		chamber.turn_on()
		begin_processing()
	update_kitchen_heating()
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
	else if(working)
		chamber.tick_timer(delta_time)
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

// ---------- Płyta grillowa: grill i kuchenka w jednym ----------
// Na płycie dalej smaży się położone jedzenie. Do tego cztery pola na patelnie, rondle i garnki z zupą.
// Płyta ma jeden włącznik (pokrętło na przodzie albo Alt+klik), jeden ogień i jeden minutnik dla wszystkich pól.

/// Wysokość przedniego panelu z pokrętłem (icon_y): kliknięcie w panel włącza płytę, a nie zdejmuje naczynia
#define GRIDDLE_PANEL_HEIGHT 12

/// Ustawienia całej płyty grillowej (menu Alt+klik): włącznik, ogień i minutnik wspólne dla czterech pól
/datum/cooking_surface/griddle_plate
	name = "płyta"
	on_word = "włączona"
	off_word = "wyłączona"
	can_burn = FALSE

/datum/cooking_surface/griddle_plate/turn_on(mob/user)
	var/obj/machinery/griddle/griddle = parent
	if(griddle.machine_stat & (NOPOWER|BROKEN))
		griddle.balloon_alert(user, "brak zasilania")
		return
	griddle.set_plate(TRUE)

/datum/cooking_surface/griddle_plate/turn_off(mob/user)
	var/obj/machinery/griddle/griddle = parent
	griddle.set_plate(FALSE)

/datum/cooking_surface/griddle_plate/ring_alarm()
	timer_left = 0
	parent.audible_message(span_notice("[parent] dzwoni: minął czas."))
	playsound(parent, 'sound/machines/ding.ogg', 50, FALSE)

/datum/cooking_surface/griddle_plate/describe()
	. = "Płyta jest [on ? on_word : off_word], ogień [cook_temp_name(temperature)]"
	if(timer)
		. += ", minutnik [DisplayTimeText(timer)]"
		if(on && timer_left > 0)
			. += " (zostało [DisplayTimeText(timer_left, 1)])"

/obj/machinery/griddle
	desc = "Płyta do smażenia: kładzie się na niej jedzenie, a na czterech polach stawia patelnie, rondle i garnki z zupą."
	active_power_usage = 40
	var/datum/burner_rack/rack
	/// Wspólne ustawienia płyty: włącznik, ogień, minutnik
	var/datum/cooking_surface/griddle_plate/plate
	var/static/list/burner_offsets = list(list(-7, -5), list(7, -5), list(-7, 4), list(7, 4))
	var/static/list/burner_names = list("lewe przednie pole", "prawe przednie pole", "lewe tylne pole", "prawe tylne pole")

/obj/machinery/griddle/Initialize(mapload)
	rack = new(src, burner_offsets, burner_names, 15, TRUE)
	plate = new(src)
	kitchen_heat = new
	. = ..()
	refresh_kitchen_heat()

/obj/machinery/griddle/Destroy()
	// Wyłączona płyta pozwala machinery/Destroy zdjąć ją z przetwarzania (end_processing), a naczynia schodzą przez on_exited
	on = FALSE
	if(rack)
		rack.turn_all_off()
		var/atom/drop = drop_location()
		if(drop)
			for(var/datum/cooking_surface/burner/burner as anything in rack.burners)
				burner.container?.forceMove(drop)
	QDEL_NULL(rack)
	QDEL_NULL(plate)
	QDEL_NULL(kitchen_heat)
	return ..()

/obj/machinery/griddle/get_cooking_surfaces()
	return list(plate)

/obj/machinery/griddle/RefreshParts()
	. = ..()
	refresh_kitchen_heat()
	// Jakość dań z naczyń liczy się z pola, na którym stoją
	for(var/datum/cooking_surface/burner/burner as anything in rack.burners)
		burner.parts_rating = kitchen_heat.rating

/// Ogień jest jeden dla całej płyty: ustawiony w menu płyty przechodzi na wszystkie pola
/obj/machinery/griddle/kitchen_temperature_set(datum/cooking_surface/surface)
	for(var/datum/cooking_surface/burner/burner as anything in rack.burners)
		burner.temperature = surface.temperature
		burner.burn_progress = 0
	update_appearance()

/// Włącza albo wyłącza całą płytę: smażenie na płycie i wszystkie cztery pola naraz
/obj/machinery/griddle/proc/set_plate(state)
	on = state
	plate.on = state
	plate.timer_left = state ? plate.timer : 0
	for(var/datum/cooking_surface/burner/burner as anything in rack.burners)
		burner.on = state
		burner.timer_left = 0
		burner.burn_progress = 0
		burner.temperature = plate.temperature
	playsound(src, 'sound/items/lighter_on.ogg', 40, TRUE)
	update_grill_audio()
	update_griddle_processing()

/obj/machinery/griddle/is_kitchen_active()
	return on || rack?.any_on()

/obj/machinery/griddle/begin_processing()
	. = ..()
	update_kitchen_heating()

/// Płyta przestaje pracować dopiero, gdy wyłączona jest i płyta, i wszystkie pola
/obj/machinery/griddle/end_processing()
	if(is_kitchen_active() && !QDELING(src))
		update_kitchen_heating()
		return
	. = ..()
	update_kitchen_heating()

/obj/machinery/griddle/proc/update_griddle_processing()
	if(is_kitchen_active())
		begin_processing()
	else
		end_processing()
	update_appearance()

/obj/machinery/griddle/attackby(obj/item/used, mob/user, params)
	if(rack.attackby(used, user, params))
		return TRUE
	if(istype(used, /obj/item/reagent_containers/cooking))
		to_chat(user, span_warning("[used] nie pasuje na płytę. Stawia się na niej patelnię, rondel albo garnek na zupę."))
		return TRUE
	return ..()

/obj/machinery/griddle/attack_hand(mob/user, list/modifiers)
	// Kliknięcie w pokrętło na przodzie włącza i wyłącza płytę, w pole z naczyniem zdejmuje naczynie
	var/icon_y = text2num(LAZYACCESS(modifiers, ICON_Y))
	var/on_panel = !isnull(icon_y) && icon_y <= GRIDDLE_PANEL_HEIGHT
	if(!on_panel && rack.take(user, modifiers))
		return TRUE
	if(!on && (machine_stat & (NOPOWER|BROKEN)))
		balloon_alert(user, "brak zasilania")
		return TRUE
	. = ..()
	if(!.)
		set_plate(on)

/obj/machinery/griddle/Exited(atom/movable/gone, direction)
	. = ..()
	rack?.on_exited(gone)

/obj/machinery/griddle/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, TRUE))
		return ..()
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(cooking_settings_menu), src, user)
	return TRUE

/obj/machinery/griddle/process(delta_time)
	if(machine_stat & (NOPOWER|BROKEN))
		set_plate(FALSE)
		return
	if(on)
		. = ..()
		plate.tick_timer(delta_time)
	var/active = rack.process_burners(delta_time, kitchen_heat_factor())
	if(!on && !active)
		update_griddle_processing()
		return
	var/in_use = 0
	for(var/datum/cooking_surface/burner/burner as anything in rack.burners)
		if(burner.on && burner.container)
			in_use++
	use_power(active_power_usage * ((on ? 1 : 0) + in_use))

/obj/machinery/griddle/update_overlays()
	. = ..()
	// Pokrętło pokazuje ogień: wyłączona płyta, niski, średni, wysoki
	var/knob = "off"
	if(on)
		switch(plate.temperature)
			if(COOK_TEMP_LOW)
				knob = "low"
			if(COOK_TEMP_HIGH)
				knob = "high"
			else
				knob = "med"
	var/mutable_appearance/knob_overlay = mutable_appearance('aquila/icons/obj/machines/griddle_knob.dmi', "knob_[knob]", ABOVE_OBJ_LAYER)
	// Trzecia odmiana płyty ma pokrętło przesunięte w prawo
	if(variant == 3)
		knob_overlay.pixel_x = 5
	. += knob_overlay

/obj/machinery/griddle/examine(mob/user)
	. = ..()
	. += span_notice("[plate.describe()]. Płyta jest [kitchen_heat.describe(TRUE)].")
	for(var/datum/cooking_surface/burner/burner as anything in rack.burners)
		if(burner.container)
			. += span_notice("[capitalize(burner.name)]: stoi tu [burner.container].")
	. += span_notice("Jedzenie kładzie się na płycie. Patelnię, rondel albo garnek na zupę stawiasz kliknięciem w jedno z czterech pól. Kliknięcie w pokrętło na przodzie włącza całą płytę. <b>Alt+klik</b>: włącznik, ogień i minutnik płyty.")

#undef GRIDDLE_PANEL_HEIGHT

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

/obj/machinery/grill/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, TRUE))
		return ..()
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(cooking_settings_menu), src, user)
	return TRUE

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
		if(grate_surface.on)
			grate_surface.turn_off()
		return
	grill_fuel -= 5 * delta_time
	if(!grate_surface.on)
		grate_surface.turn_on()
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

/obj/machinery/deepfryer/RefreshParts()
	. = ..()
	refresh_kitchen_heat()

/obj/machinery/deepfryer/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, TRUE))
		return ..()
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(cooking_settings_menu), src, user)
	return TRUE

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
			basket_surface.turn_on()
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
