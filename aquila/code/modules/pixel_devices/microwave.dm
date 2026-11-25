// Okno mikrofalówki w formie urządzenia (port pomysłu polonium14/polonium-station#1280).
// Zastępuje menu radialne: komora z włożonymi rzeczami na talerzu, wyświetlacz z odliczaniem,
// klawisze START i OPRÓŻNIJ, kartka z listą zawartości. Prawy przycisk nadal od razu włącza mikrofalówkę.

/// Wartości typu z loop() w core (MICROWAVE_NORMAL/MUCK/PRE są tam #undef na końcu pliku)
#define AQ_MICROWAVE_NORMAL 0
#define AQ_MICROWAVE_MUCK 1
#define AQ_MICROWAVE_PRE 2

/obj/machinery/microwave
	/// world.time końca bieżącego pieczenia (dla odliczania w oknie)
	var/aq_cook_end = 0
	/// Długość całego bieżącego pieczenia w decysekundach
	var/aq_cook_length = 0
	/// world.time ostatniego udanego pieczenia (okno pokazuje wtedy GOTOWE)
	var/aq_cook_done_at = 0

/obj/machinery/microwave/loop(type, time, wait = max(12 - 2 * efficiency, 2), mob/user)
	if(time && isnum(wait) && !(machine_stat & (NOPOWER|BROKEN)))
		var/remaining = time * wait
		// Udany start "przed awarią" przechodzi potem w zwykłe pieczenie: 10 cykli o domyślnej długości
		if(type == AQ_MICROWAVE_PRE)
			remaining += 10 * max(12 - 2 * efficiency, 2)
		aq_cook_end = world.time + remaining
		if(!aq_cook_length || aq_cook_length < remaining)
			aq_cook_length = remaining
	return ..()

/obj/machinery/microwave/loop_finish(mob/user)
	. = ..()
	if(!broken)
		aq_cook_done_at = world.time

/obj/machinery/microwave/after_finish_loop()
	aq_cook_end = 0
	aq_cook_length = 0
	. = ..()
	SStgui.update_uis(src)

/obj/machinery/microwave/wzhzhzh()
	aq_cook_done_at = 0 // nowy cykl: GOTOWE z poprzedniego nie może wrócić po przerwaniu
	. = ..()
	SStgui.update_uis(src)

/obj/machinery/microwave/update_appearance(updates)
	. = ..()
	SStgui.update_uis(src)

// Pełne nadpisanie (wpis w LEGACY_OVERRIDES.md): menu radialne z core zastępuje okno TGUI
/obj/machinery/microwave/ui_interact(mob/user, datum/tgui/ui)
	if(panel_open || !anchored)
		return
	if(isAI(user) && (machine_stat & NOPOWER))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		return
	// Zepsuta też się otwiera (pęknięta szyba w oknie): jak w starym menu da się z niej wyjąć zawartość, START jest zablokowany
	ui = new(user, src, "MicrowaveDevice")
	ui.set_autoupdate(TRUE) // odliczanie
	ui.open()
	playsound(src, 'sound/machines/click.ogg', 15, TRUE, -3)

/obj/machinery/microwave/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/microwave/ui_data(mob/user)
	var/list/data = list()
	var/list/items = list()
	for(var/atom/movable/ingredient as anything in ingredients)
		if(QDELETED(ingredient))
			continue
		var/amount = 1
		if(isstack(ingredient))
			var/obj/item/stack/stack = ingredient
			amount = stack.amount
		items += list(list(
			"ref" = REF(ingredient),
			"name" = capitalize(format_text(ingredient.name)),
			"amount" = amount,
			"icon" = pixel_device_icon(ingredient),
			"food" = !!IS_EDIBLE(ingredient),
		))
	data["items"] = items
	data["capacity"] = max_n_of_items
	data["operating"] = operating
	data["open"] = open
	data["dirty"] = dirty
	data["mucking"] = dirty_anim_playing
	data["broken"] = broken
	data["powered"] = !(machine_stat & NOPOWER)
	data["efficiency"] = efficiency
	data["time_left"] = operating && aq_cook_end ? max(0, aq_cook_end - world.time) : 0
	data["time_total"] = aq_cook_length
	data["done_ago"] = aq_cook_done_at && world.time - aq_cook_done_at < 5 SECONDS ? world.time - aq_cook_done_at : null
	data["silicon"] = issilicon(user)
	return data

/obj/machinery/microwave/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(operating || panel_open || !anchored)
		return
	switch(action)
		if("start")
			if(!length(ingredients))
				to_chat(usr, "<span class='warning'>[src] jest pusta.</span>")
				return
			cook(usr)
			return TRUE
		if("eject")
			if(!length(ingredients))
				return
			eject()
			return TRUE
		if("eject_item")
			return aq_take_ingredient(usr, locate(params["ref"]) in ingredients)

/// Okno: jedna rzecz z komory do ręki (krzemowi i ci z daleka dostają ją na podłogę)
/obj/machinery/microwave/proc/aq_take_ingredient(mob/user, atom/movable/ingredient)
	if(!ingredient || !(ingredient in ingredients) || operating)
		return FALSE
	ingredients -= ingredient
	if(isliving(user) && !issilicon(user) && isitem(ingredient) && user.Adjacent(src))
		var/mob/living/taker = user
		if(!taker.put_in_hands(ingredient))
			ingredient.forceMove(drop_location())
	else
		ingredient.forceMove(drop_location())
	update_appearance()
	return TRUE

#undef AQ_MICROWAVE_NORMAL
#undef AQ_MICROWAVE_MUCK
#undef AQ_MICROWAVE_PRE
