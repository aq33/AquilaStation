/**
 * Nagrzewanie sprzętu kuchennego: maszyna po włączeniu rozgrzewa się, po wyłączeniu stygnie.
 * Stan liczony z czasu, bez osobnego procesu. Laser w płytce skraca rozgrzewanie i przyspiesza gotowanie.
 */
/datum/kitchen_heat
	/// Stan nagrzania 0–1 w chwili heat_time
	var/heat = 0
	var/heat_time = 0
	var/heating = FALSE
	/// Czas od zimnej do pełnej mocy
	var/warmup = KITCHEN_WARMUP_TIME
	/// Mnożnik szybkości przy pełnej mocy
	var/speed = 1
	/// Średni poziom lasera
	var/rating = 1

/datum/kitchen_heat/proc/current()
	var/elapsed = world.time - heat_time
	if(heating)
		return min(1, heat + elapsed / warmup)
	// Stygnie dwa razy wolniej, niż się nagrzewa
	return max(0, heat - elapsed / (warmup * 2))

/datum/kitchen_heat/proc/set_heating(state)
	if(heating == state)
		return
	heat = current()
	heat_time = world.time
	heating = state

/datum/kitchen_heat/proc/refresh(new_rating)
	heat = current()
	heat_time = world.time
	rating = max(new_rating, 1)
	warmup = KITCHEN_WARMUP_TIME / rating
	speed = 1 + (rating - 1) / 6

/// Mnożnik szybkości gotowania teraz: zimna maszyna gotuje wolno, rozgrzana pełną mocą
/datum/kitchen_heat/proc/factor()
	return speed * (KITCHEN_COLD_SPEED + (1 - KITCHEN_COLD_SPEED) * current())

/datum/kitchen_heat/proc/describe()
	var/value = current()
	if(value >= 1)
		return "rozgrzane do pełnej mocy"
	if(value <= 0)
		return "zimne"
	return "[heating ? "rozgrzewa się" : "stygnie"] ([round(value * 100)]%)"

/obj/machinery/var/datum/kitchen_heat/kitchen_heat

/obj/machinery/proc/kitchen_heat_factor()
	return kitchen_heat ? kitchen_heat.factor() : 1

/// Liczy średni laser z części i ustawia nagrzewanie; maszyny bez lasera mają poziom 1
/obj/machinery/proc/refresh_kitchen_heat()
	if(!kitchen_heat)
		kitchen_heat = new
	var/total = 0
	var/count = 0
	for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
		total += laser.rating
		count++
	kitchen_heat.refresh(count ? total / count : 1)
	for(var/datum/cooking_surface/surface as anything in get_cooking_surfaces())
		surface.parts_rating = kitchen_heat.rating

/// Czy coś w tej maszynie teraz grzeje (palnik, komora); z tego wynika nagrzewanie wspólne dla całej maszyny
/obj/machinery/proc/is_kitchen_active()
	return FALSE

/obj/machinery/proc/update_kitchen_heating()
	kitchen_heat?.set_heating(is_kitchen_active())

/// Palniki i komory tej maszyny (do menu ustawień)
/obj/machinery/proc/get_cooking_surfaces()
	return list()

/**
 * Miejsce na naczynie: palnik kuchenki, komora piekarnika, ruszt grilla, kosz frytkownicy.
 * Ma ogień (niski, średni, wysoki), minutnik i liczy czas gotowania naczynia.
 */
/datum/cooking_surface
	var/name = "palnik"
	var/cooker_id = COOKER_STOVE
	var/obj/machinery/parent
	var/temperature = COOK_TEMP_MED
	var/on = FALSE
	/// Minutnik w dziesiątych sekundy (0 = wyłączony) i ile z niego zostało
	var/timer = 0
	var/timer_left = 0
	/// Naczynie albo garnek z zupą
	var/obj/item/container
	/// Ile czasu na ogniu minęło bez postępu przepisu
	var/burn_progress = 0
	var/allow_temp_change = TRUE
	var/allow_toggling = TRUE
	var/parts_rating = 1
	/// Typy naczyń, które się tu mieszczą
	var/list/allowed_containers

/datum/cooking_surface/New(obj/machinery/parent)
	. = ..()
	src.parent = parent

/datum/cooking_surface/Destroy(force)
	parent = null
	container = null
	return ..()

/datum/cooking_surface/proc/accepts(obj/item/thing)
	return is_type_in_list(thing, allowed_containers)

/// Wywoływane przez maszynę co tick, gdy palnik jest włączony
/datum/cooking_surface/proc/process_cooking(delta_time, speed_factor)
	tick_timer(delta_time)
	var/obj/item/reagent_containers/cooking/pan = container
	if(!istype(pan))
		return
	pan.add_cook_time(cooker_id, temperature, delta_time * 10 * speed_factor)
	var/result = pan.process_item(null, parent)
	if(result == COOK_SUCCESS || result == COOK_COMPLETE)
		burn_progress = 0
		return
	if(!length(pan.contents) && !pan.reagents.total_volume)
		burn_progress = 0
		return
	if(pan.tracker?.waiting_for_cooker(cooker_id))
		return
	burn_progress += delta_time * 10 * speed_factor
	if(burn_progress >= cook_burn_time(temperature))
		burn_progress = 0
		pan.handle_burning()
		parent.visible_message(span_warning("Z: [pan] bucha dym, coś się przypaliło!"))
		var/datum/effect_system/smoke_spread/bad/smoke = new
		smoke.set_up(0, get_turf(parent))
		smoke.start()

/// Odlicza minutnik; wołane co tick dla włączonego palnika albo pracującej komory, niezależnie od zawartości
/datum/cooking_surface/proc/tick_timer(delta_time)
	if(timer && timer_left > 0)
		timer_left -= delta_time * 10
		if(timer_left <= 0)
			ring_alarm()

/datum/cooking_surface/proc/ring_alarm()
	timer_left = 0
	parent.audible_message(span_notice("[parent] dzwoni: minął czas na [name]."))
	playsound(parent, 'sound/machines/ding.ogg', 50, FALSE)

/datum/cooking_surface/proc/turn_on(mob/user)
	if(on)
		return
	on = TRUE
	burn_progress = 0
	timer_left = timer
	playsound(parent, 'sound/items/lighter_on.ogg', 40, TRUE)

/datum/cooking_surface/proc/turn_off(mob/user)
	if(!on)
		return
	on = FALSE
	timer_left = 0
	playsound(parent, 'sound/items/lighter_on.ogg', 40, TRUE)

/datum/cooking_surface/proc/set_container(obj/item/new_container)
	container = new_container
	burn_progress = 0
	var/obj/item/reagent_containers/cooking/pan = new_container
	if(istype(pan))
		pan.surface = src

/datum/cooking_surface/proc/clear_container()
	var/obj/item/reagent_containers/cooking/pan = container
	if(istype(pan))
		pan.surface = null
	container = null
	burn_progress = 0

/datum/cooking_surface/proc/describe()
	. = "[name]: [on ? "włączony" : "wyłączony"], ogień [cook_temp_name(temperature)]"
	if(timer)
		. += ", minutnik [DisplayTimeText(timer)]"
		if(on && timer_left > 0)
			. += " (zostało [DisplayTimeText(timer_left, 1)])"
	if(container)
		. += ". Stoi tu: [container]"

/// Menu kołowe ustawień jednego palnika (Alt+klik na maszynie)
/datum/cooking_surface/proc/settings_menu(mob/user)
	var/list/options = list()
	if(allow_toggling)
		options["Włącz/wyłącz"] = image(icon = 'aquila/icons/obj/food/cooking/radial.dmi', icon_state = "radial_onoff")
	if(allow_temp_change)
		options["Ogień"] = image(icon = 'aquila/icons/obj/food/cooking/radial.dmi', icon_state = "radial_settemp")
	options["Minutnik"] = image(icon = 'aquila/icons/obj/food/cooking/radial.dmi', icon_state = "radial_setalarm")
	var/choice = show_radial_menu(user, parent, options, require_near = TRUE, tooltips = TRUE)
	if(!choice || QDELETED(parent) || !user.canUseTopic(parent, BE_CLOSE))
		return
	switch(choice)
		if("Włącz/wyłącz")
			if(on)
				turn_off(user)
			else
				turn_on(user)
			parent.balloon_alert(user, "[name] [on ? "włączony" : "wyłączony"]")
		if("Ogień")
			var/list/temps = list("niski" = COOK_TEMP_LOW, "średni" = COOK_TEMP_MED, "wysoki" = COOK_TEMP_HIGH)
			var/picked = tgui_input_list(user, "Ogień: [cook_temp_name(temperature)]", "Ogień", temps, cook_temp_name(temperature))
			if(picked && temps[picked] && !QDELETED(parent))
				temperature = temps[picked]
				burn_progress = 0
				parent.balloon_alert(user, "ogień [picked]")
		if("Minutnik")
			var/seconds = tgui_input_number(user, "Po ilu sekundach zadzwonić? 0 wyłącza minutnik.", "Minutnik", timer / 10, 600, 0)
			if(!isnull(seconds) && !QDELETED(parent))
				timer = round(seconds) SECONDS
				timer_left = on ? timer : 0
				parent.balloon_alert(user, timer ? "minutnik [DisplayTimeText(timer)]" : "minutnik wyłączony")
	parent.update_appearance()

/// Alt+klik na maszynie kuchennej: wybór palnika (gdy jest ich kilka), potem jego ustawienia
/proc/cooking_settings_menu(obj/machinery/machine, mob/user)
	var/list/surfaces = machine.get_cooking_surfaces()
	if(!length(surfaces))
		return FALSE
	var/datum/cooking_surface/picked = surfaces[1]
	if(length(surfaces) > 1)
		var/list/options = list()
		var/list/by_name = list()
		for(var/datum/cooking_surface/surface as anything in surfaces)
			var/image/surface_image = surface.container ? image(surface.container) : image(icon = 'aquila/icons/obj/food/cooking/radial.dmi', icon_state = "radial_onoff")
			var/datum/radial_menu_choice/choice = new
			choice.image = surface_image
			choice.info = surface.describe()
			options[surface.name] = choice
			by_name[surface.name] = surface
		var/name_picked = show_radial_menu(user, machine, options, require_near = TRUE, tooltips = TRUE)
		if(!name_picked || !by_name[name_picked])
			return TRUE
		picked = by_name[name_picked]
	picked.settings_menu(user)
	return TRUE
