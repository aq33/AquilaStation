/datum/cooking/recipe_step
	/// Krok dodatkowy: można go pominąć, a wykonany poprawia jakość dania
	var/optional = FALSE

/datum/cooking/recipe_step/New(list/options)
	if(options && ("optional" in options))
		optional = options["optional"]

/// Czy użyty przedmiot pasuje do kroku. Zwraca COOK_CHECK_*.
/datum/cooking/recipe_step/proc/check_conditions_met(obj/used_item, datum/cooking/recipe_tracker/tracker)
	return COOK_CHECK_VALID

/// Wykonuje krok. Zwraca listę danych dla trackera (m.in. "message", "quality").
/datum/cooking/recipe_step/proc/follow_step(obj/used_item, datum/cooking/recipe_tracker/tracker, mob/user)
	return list()

/datum/cooking/recipe_step/proc/is_complete(obj/used_item, datum/cooking/recipe_tracker/tracker, list/step_data)
	return TRUE

/// Opis kroku w Książce kucharskiej
/datum/cooking/recipe_step/proc/get_pda_formatted_desc()
	return ""

/// Wkłada przedmiot do naczynia (z ręki albo ze stołu)
/datum/cooking/recipe_step/proc/move_into_container(obj/item/used_item, obj/item/container, mob/user)
	if(!user && ismob(used_item.loc))
		user = used_item.loc
	if(istype(user) && used_item.loc == user)
		if(!user.transferItemToLoc(used_item, container))
			to_chat(user, span_warning("Nie możesz wypuścić [used_item] z ręki!"))
			return FALSE
		return TRUE
	used_item.forceMove(container)
	return TRUE

// ---------- Dodaj przedmiot ----------

/datum/cooking/recipe_step/add_item
	/// Typ albo lista typów (krok „jedno z kilku”)
	var/item_type
	var/exact_path = FALSE
	var/skip_reagents = FALSE
	/// Odczynnika nie przenosimy do dania, bo danie ma już własną odżywkę
	var/list/exclude_reagents = list(/datum/reagent/consumable/nutriment, /datum/reagent/consumable/nutriment/vitamin, /datum/reagent/consumable/nutriment/protein)

/datum/cooking/recipe_step/add_item/New(item_type, list/options)
	src.item_type = item_type
	if(options)
		if("exact" in options)
			exact_path = options["exact"]
		if("skip_reagents" in options)
			skip_reagents = options["skip_reagents"]
		if("exclude_reagents" in options)
			exclude_reagents |= options["exclude_reagents"]
	..(options)

/datum/cooking/recipe_step/add_item/proc/matches(obj/used_item)
	for(var/path in (islist(item_type) ? item_type : list(item_type)))
		if(exact_path ? used_item.type == path : istype(used_item, path))
			return TRUE
	return FALSE

/datum/cooking/recipe_step/add_item/check_conditions_met(obj/used_item, datum/cooking/recipe_tracker/tracker)
	if(!isitem(used_item) || istype(used_item, /obj/item/reagent_containers/cooking))
		return COOK_CHECK_INVALID
	return matches(used_item) ? COOK_CHECK_VALID : COOK_CHECK_INVALID

/datum/cooking/recipe_step/add_item/follow_step(obj/used_item, datum/cooking/recipe_tracker/tracker, mob/user)
	var/obj/item/container = tracker.container
	var/obj/item/stack/stack = used_item
	if(istype(stack))
		if(!stack.use(1))
			return list()
		var/stack_type = stack.type
		new stack_type(container, 1)
		return list("message" = "Dodajesz jedną sztukę: [stack.name].", "stack_added" = stack_type)
	if(!move_into_container(used_item, container, user))
		return list()
	return list("message" = "Wkładasz [used_item] do: [container].")

/datum/cooking/recipe_step/add_item/is_complete(obj/used_item, datum/cooking/recipe_tracker/tracker, list/step_data)
	if(step_data?["stack_added"])
		for(var/path in (islist(item_type) ? item_type : list(item_type)))
			if(ispath(step_data["stack_added"], path))
				return TRUE
	return (used_item in tracker.container.contents)

/datum/cooking/recipe_step/add_item/get_pda_formatted_desc()
	var/list/names = list()
	for(var/path in (islist(item_type) ? item_type : list(item_type)))
		var/atom/item_path = path
		names += initial(item_path.name)
	return "Dodaj: [jointext(names, " / ")]."

// ---------- Dodaj plon ----------

/datum/cooking/recipe_step/add_produce
	var/produce_type

/datum/cooking/recipe_step/add_produce/New(produce_type, list/options)
	src.produce_type = produce_type
	..(options)

/datum/cooking/recipe_step/add_produce/check_conditions_met(obj/used_item, datum/cooking/recipe_tracker/tracker)
	if(!istype(used_item, /obj/item/food/grown))
		return COOK_CHECK_INVALID
	return istype(used_item, produce_type) ? COOK_CHECK_VALID : COOK_CHECK_INVALID

/datum/cooking/recipe_step/add_produce/follow_step(obj/used_item, datum/cooking/recipe_tracker/tracker, mob/user)
	if(!move_into_container(used_item, tracker.container, user))
		return list()
	return list("message" = "Wkładasz [used_item] do: [tracker.container].")

/datum/cooking/recipe_step/add_produce/is_complete(obj/used_item, datum/cooking/recipe_tracker/tracker, list/step_data)
	return (used_item in tracker.container.contents)

/datum/cooking/recipe_step/add_produce/get_pda_formatted_desc()
	var/atom/produce_path = produce_type
	return "Dodaj: [initial(produce_path.name)]."

// ---------- Dodaj odczynnik ----------

/datum/cooking/recipe_step/add_reagent
	var/reagent_type
	var/amount
	/// Ile odczynnika zostaje w daniu (0–1); reszta znika przy gotowaniu
	var/remain_percent = 0

/datum/cooking/recipe_step/add_reagent/New(reagent_type, amount, list/options)
	src.reagent_type = reagent_type
	src.amount = amount
	if(options && ("remain_percent" in options))
		remain_percent = options["remain_percent"]
	..(options)

/datum/cooking/recipe_step/add_reagent/check_conditions_met(obj/used_item, datum/cooking/recipe_tracker/tracker)
	var/obj/item/container = tracker.container
	// Maszyna: krok uznajemy, jeśli odczynnik jest już w naczyniu (kolejność przypraw nie ma znaczenia)
	if(ismachinery(used_item))
		return container.reagents.has_reagent(reagent_type, amount) ? COOK_CHECK_VALID : COOK_CHECK_SILENT
	var/obj/item/reagent_containers/source = used_item
	if(!istype(source) || istype(source, /obj/item/reagent_containers/cooking) || !source.is_open_container())
		return COOK_CHECK_INVALID
	if(!source.reagents?.has_reagent(reagent_type))
		return COOK_CHECK_INVALID
	if(container.reagents.total_volume + amount - container.reagents.get_reagent_amount(reagent_type) > container.reagents.maximum_volume)
		return COOK_CHECK_FULL
	return COOK_CHECK_VALID

/datum/cooking/recipe_step/add_reagent/follow_step(obj/used_item, datum/cooking/recipe_tracker/tracker, mob/user)
	var/obj/item/reagent_containers/source = used_item
	if(!istype(source))
		return list()
	var/missing = max(amount - tracker.container.reagents.get_reagent_amount(reagent_type), 0)
	var/transferred = source.reagents.trans_id_to(tracker.container, reagent_type, min(source.amount_per_transfer_from_this, missing))
	return list("message" = "Wlewasz [round(transferred, 0.1)] j. do: [tracker.container].", "amount" = amount, "reagent_remain_percent" = remain_percent, "reagent_type" = reagent_type)

/datum/cooking/recipe_step/add_reagent/is_complete(obj/used_item, datum/cooking/recipe_tracker/tracker, list/step_data)
	return tracker.container.reagents.has_reagent(reagent_type, amount)

/datum/cooking/recipe_step/add_reagent/get_pda_formatted_desc()
	var/datum/reagent/reagent = GLOB.chemical_reagents_list[reagent_type]
	return "Dodaj [amount] j.: [reagent ? reagent.name : "?"]."

// ---------- Użyj narzędzia na naczyniu (nóż, wałek) ----------

/datum/cooking/recipe_step/use_tool
	var/tool_behaviour

/datum/cooking/recipe_step/use_tool/New(tool_behaviour, list/options)
	src.tool_behaviour = tool_behaviour
	..(options)

/datum/cooking/recipe_step/use_tool/check_conditions_met(obj/used_item, datum/cooking/recipe_tracker/tracker)
	var/obj/item/tool = used_item
	if(!istype(tool) || tool.tool_behaviour != tool_behaviour)
		return COOK_CHECK_INVALID
	return COOK_CHECK_VALID

/datum/cooking/recipe_step/use_tool/follow_step(obj/used_item, datum/cooking/recipe_tracker/tracker, mob/user)
	var/obj/item/tool = used_item
	playsound(tracker.container, tool.usesound || 'sound/weapons/slice.ogg', 40, TRUE)
	switch(tool_behaviour)
		if(TOOL_KNIFE)
			return list("message" = "Kroisz zawartość: [tracker.container].")
		if(TOOL_ROLLINGPIN)
			return list("message" = "Wałkujesz zawartość: [tracker.container].")
	return list("message" = "Używasz [tool] na: [tracker.container].")

/datum/cooking/recipe_step/use_tool/get_pda_formatted_desc()
	switch(tool_behaviour)
		if(TOOL_KNIFE)
			return "Pokrój nożem."
		if(TOOL_ROLLINGPIN)
			return "Rozwałkuj wałkiem."
	return "Użyj narzędzia."

// ---------- Gotuj na maszynie ----------

/datum/cooking/recipe_step/use_machine
	var/time
	var/temperature
	var/cooker_id

/datum/cooking/recipe_step/use_machine/New(temperature, time, list/options)
	src.temperature = temperature
	src.time = time
	..(options)

/datum/cooking/recipe_step/use_machine/check_conditions_met(obj/used_item, datum/cooking/recipe_tracker/tracker)
	var/datum/cooking_surface/surface = tracker.container.surface
	if(!ismachinery(used_item) || !surface || surface.cooker_id != cooker_id)
		return COOK_CHECK_INVALID
	return COOK_CHECK_SILENT

/datum/cooking/recipe_step/use_machine/follow_step(obj/used_item, datum/cooking/recipe_tracker/tracker, mob/user)
	var/datum/cooking_surface/surface = tracker.container.surface
	// Lepszy laser w maszynie poprawia danie
	return list("signal" = COMSIG_COOK_MACHINE_STEP_COMPLETE, "quality" = surface ? max(surface.parts_rating - 1, 0) * 0.25 : 0)

/datum/cooking/recipe_step/use_machine/is_complete(obj/used_item, datum/cooking/recipe_tracker/tracker, list/step_data)
	return tracker.container.get_cooker_time(cooker_id, temperature) >= time

/datum/cooking/recipe_step/use_machine/stove
	cooker_id = COOKER_STOVE

/datum/cooking/recipe_step/use_machine/stove/get_pda_formatted_desc()
	return "Gotuj na kuchence na [cook_temp_adjective(temperature)] ogniu przez [DisplayTimeText(time)]."

/datum/cooking/recipe_step/use_machine/oven
	cooker_id = COOKER_OVEN

/datum/cooking/recipe_step/use_machine/oven/get_pda_formatted_desc()
	return "Piecz w piekarniku na [cook_temp_adjective(temperature)] ogniu przez [DisplayTimeText(time)]."

/datum/cooking/recipe_step/use_machine/grill
	cooker_id = COOKER_GRILL

/datum/cooking/recipe_step/use_machine/grill/get_pda_formatted_desc()
	return "Grilluj na ruszcie przez [DisplayTimeText(time)]."

/datum/cooking/recipe_step/use_machine/fryer
	cooker_id = COOKER_FRYER

/datum/cooking/recipe_step/use_machine/fryer/get_pda_formatted_desc()
	return "Smaż w głębokim oleju przez [DisplayTimeText(time)]."
