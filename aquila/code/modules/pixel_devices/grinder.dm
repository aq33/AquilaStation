// Okno młynka w formie urządzenia (port pomysłu polonium14/polonium-station#1287).
// Zastępuje menu radialne: dzbanek z wrzuconymi produktami, naczynie w niszy pod dyszą,
// klawisze MIEL, WYCIŚNIJ, MIESZAJ i WYJMIJ oraz kartka z zawartością.

/obj/machinery/reagentgrinder
	/// world.time końca bieżącej pracy (dla animacji w oknie)
	var/aq_operation_end = 0
	/// "grind", "juice" albo "mix": co młynek właśnie robi
	var/aq_operation = null

/obj/machinery/reagentgrinder/grind(mob/user)
	aq_operation = "grind"
	return ..()

/obj/machinery/reagentgrinder/juice(mob/user)
	aq_operation = "juice"
	return ..()

/obj/machinery/reagentgrinder/mix(mob/user)
	aq_operation = "mix"
	return ..()

/obj/machinery/reagentgrinder/operate_for(time, silent = FALSE, juicing = FALSE)
	aq_operation_end = world.time + time / speed
	. = ..()
	SStgui.update_uis(src)

/obj/machinery/reagentgrinder/stop_operating()
	. = ..()
	aq_operation_end = 0
	SStgui.update_uis(src)

// Pełne nadpisanie (wpis w LEGACY_OVERRIDES.md): menu radialne z core zastępuje okno TGUI
/obj/machinery/reagentgrinder/ui_interact(mob/user, datum/tgui/ui)
	if(isAI(user) && (machine_stat & NOPOWER))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GrinderDevice")
		ui.set_autoupdate(TRUE) // praca i wkładanie produktów
		ui.open()

/obj/machinery/reagentgrinder/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/reagentgrinder/ui_data(mob/user)
	var/list/data = list()
	var/list/items = list()
	for(var/obj/item/thing as anything in holdingitems)
		if(QDELETED(thing))
			continue
		items += list(list(
			"ref" = REF(thing),
			"name" = capitalize(format_text(thing.name)),
			"icon" = pixel_device_icon(thing),
			"grind" = !!(thing.grind_results || thing.is_grindable()),
			"juice" = !!thing.juice_typepath,
		))
	data["items"] = items
	data["limit"] = limit
	data["operating"] = operating
	data["operation"] = aq_operation
	data["time_left"] = operating && aq_operation_end ? max(0, aq_operation_end - world.time) : 0
	data["powered"] = !(machine_stat & NOPOWER)
	data["broken"] = !!(machine_stat & BROKEN)
	data["speed"] = speed
	var/list/vessel = null
	if(beaker)
		var/list/reagents = list()
		for(var/datum/reagent/reagent as anything in beaker.reagents.reagent_list)
			reagents += list(list(
				"name" = capitalize(format_text(reagent.name)),
				"volume" = round(reagent.volume, 0.1),
				"color" = reagent.color,
			))
		vessel = list(
			"name" = capitalize(format_text(beaker.name)),
			"icon" = pixel_device_icon(beaker),
			"volume" = round(beaker.reagents.total_volume, 0.1),
			"max" = beaker.reagents.maximum_volume,
			"color" = beaker.reagents.total_volume ? mix_color_from_reagents(beaker.reagents.reagent_list) : null,
			"reagents" = reagents,
		)
	data["vessel"] = vessel
	var/obj/item/held = user.get_active_held_item()
	data["holding"] = held ? capitalize(format_text(held.name)) : null
	data["silicon"] = issilicon(user)
	return data

/obj/machinery/reagentgrinder/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(operating)
		return
	var/mob/living/user = usr
	switch(action)
		if("grind")
			if(!length(holdingitems))
				return
			grind(user)
			return TRUE
		if("juice")
			if(!length(holdingitems))
				return
			juice(user)
			return TRUE
		if("mix")
			if(!beaker?.reagents.total_volume)
				return
			mix(user)
			return TRUE
		if("eject")
			eject(user)
			update_icon()
			return TRUE
		if("eject_beaker")
			if(!beaker)
				return
			replace_beaker(user)
			return TRUE
		if("eject_item")
			return aq_take_item(user, locate(params["ref"]) in holdingitems)
		// Kliknięcie dzbanka albo pustej niszy z czymś w ręce: jak użycie przedmiotu na młynku
		if("insert")
			return aq_insert_held(user)

/// Okno: jeden produkt z dzbanka do ręki
/obj/machinery/reagentgrinder/proc/aq_take_item(mob/living/user, obj/item/thing)
	if(!thing || !holdingitems[thing] || operating)
		return FALSE
	holdingitems -= thing
	thing.forceMove(drop_location())
	if(isliving(user) && !issilicon(user) && user.Adjacent(src))
		user.put_in_hands(thing)
	return TRUE

/// Okno: przedmiot z ręki do młynka (produkt do dzbanka, naczynie do niszy)
/obj/machinery/reagentgrinder/proc/aq_insert_held(mob/living/user)
	if(operating || !isliving(user) || issilicon(user) || !user.Adjacent(src))
		return FALSE
	var/obj/item/weapon = user.get_active_held_item()
	if(!weapon)
		return FALSE
	// attackby() z czymś innym w trybie walki atakowałby młynek, a okno ma tylko wkładać
	var/is_vessel = istype(weapon, /obj/item/reagent_containers) && !(weapon.item_flags & ABSTRACT) && weapon.is_open_container()
	if(!is_vessel && !istype(weapon, /obj/item/storage/bag) && !weapon.grind_results && !weapon.juice_typepath && !weapon.is_grindable())
		to_chat(user, "<span class='warning'>Nie możesz zmielić [weapon] na odczynniki!</span>")
		return FALSE
	attackby(weapon, user)
	return TRUE
