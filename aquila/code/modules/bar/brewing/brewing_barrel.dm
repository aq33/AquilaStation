// AQUILA - browar w drewnianej beczce (code/modules/hydroponics/fermenting_barrel.dm). Alt+klik wybiera trunek
// z przepisu; bez przepisu beczka działa jak dotąd (owoc => wino z tego owocu). Wzór: Monke fermentation_keg,
// z poprawkami: przedmioty są naprawdę wymagane, a start zużywa tylko potrzebne odczynniki, nie całą zawartość.

/obj/structure/fermenting_barrel
	/// Wybrany przepis (null = stary tryb „owoc => wino”)
	var/datum/brewing_recipe/selected_recipe
	var/brewing = FALSE
	var/brew_end = 0
	/// Typ plonu => ile „jednostek plonu” już wrzucono
	var/list/crop_units = list()

/obj/structure/fermenting_barrel/Initialize(mapload)
	. = ..()
	// Jak w Monke: płyny w beczce nie reagują, żeby gotowy trunek nie zmieniał się z resztkami wody w grog
	reagents.flags |= NO_REACT

/obj/structure/fermenting_barrel/Destroy()
	selected_recipe = null
	return ..()

/// Ile „jednostek plonu” daje jeden plon (zwykły 5, lepszy więcej, najwyżej 10)
/proc/brewing_crop_units(obj/item/food/grown/crop)
	return clamp(round(get_fruit_trait_power(crop) * 5), 1, 10)

/obj/structure/fermenting_barrel/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, TRUE))
		return ..()
	INVOKE_ASYNC(src, PROC_REF(brewing_menu), user)
	return TRUE

/obj/structure/fermenting_barrel/proc/brewing_menu(mob/user)
	if(brewing)
		to_chat(user, span_notice("W [src] warzy się: [selected_recipe.display_name]. Zostało [DisplayTimeText(max(brew_end - world.time, 0), 1)]."))
		return
	var/list/options = list()
	if(selected_recipe)
		options["Rozpocznij warzenie: [selected_recipe.display_name]"] = "start"
	options["Bez przepisu (owoce na wino)"] = "none"
	for(var/datum/brewing_recipe/recipe as anything in GLOB.brewing_recipes)
		if(recipe.pre_reqs && !reagents.has_reagent(recipe.pre_reqs))
			continue
		options["[recipe.display_name][recipe.pre_reqs ? " (drugi etap)" : ""]"] = recipe
	var/picked = tgui_input_list(user, "Co warzymy?", "Browar", options)
	if(!picked || QDELETED(src) || brewing || !user.canUseTopic(src, BE_CLOSE))
		return
	var/choice = options[picked]
	if(choice == "start")
		start_brewing(user)
		return
	drop_brewing_ingredients()
	if(choice == "none")
		selected_recipe = null
		to_chat(user, span_notice("[src] działa bez przepisu: wrzucony owoc fermentuje na wino."))
		return
	selected_recipe = choice
	to_chat(user, span_notice("Przepis: [selected_recipe.display_name]. Potrzeba: [jointext(selected_recipe.describe_needs(), ", ")]."))
	if(selected_recipe.helpful_hints)
		to_chat(user, span_notice(selected_recipe.helpful_hints))
	to_chat(user, span_notice("Plony i przedmioty wrzucasz do beczki, płyny wlewasz do otwartej beczki. Potem Alt+klik i „Rozpocznij warzenie”."))

/// Wysypuje plony i przedmioty wrzucone pod poprzedni przepis
/obj/structure/fermenting_barrel/proc/drop_brewing_ingredients()
	for(var/atom/movable/thing as anything in contents)
		thing.forceMove(drop_location())
	crop_units.Cut()

/obj/structure/fermenting_barrel/attackby(obj/item/I, mob/user, params)
	if(brewing && (istype(I, /obj/item/food/grown) || (selected_recipe && is_type_in_list(I, selected_recipe.needed_items))))
		to_chat(user, span_warning("W [src] już coś się warzy."))
		return TRUE
	if(!selected_recipe || brewing)
		return ..()
	var/obj/item/food/grown/crop = I
	if(istype(crop))
		var/crop_type = needed_crop_type(crop)
		if(!crop_type)
			to_chat(user, span_warning("Ten przepis nie potrzebuje: [crop]."))
			return TRUE
		var/units = brewing_crop_units(crop)
		if(!user.transferItemToLoc(crop, src))
			return TRUE
		crop_units[crop_type] += units
		to_chat(user, span_notice("Wrzucasz [crop] do [src] ([crop_units[crop_type]]/[selected_recipe.needed_crops[crop_type]] j.)."))
		return TRUE
	if(is_type_in_list(I, selected_recipe.needed_items))
		if(user.transferItemToLoc(I, src))
			to_chat(user, span_notice("Wkładasz [I] do [src]."))
		return TRUE
	return ..()

/obj/structure/fermenting_barrel/proc/needed_crop_type(obj/item/food/grown/crop)
	for(var/crop_type in selected_recipe.needed_crops)
		if(istype(crop, crop_type))
			return crop_type

/obj/structure/fermenting_barrel/proc/count_items(item_type)
	. = 0
	for(var/obj/item/thing in contents)
		if(istype(thing, item_type))
			.++

/// Lista braków (pusta = można warzyć)
/obj/structure/fermenting_barrel/proc/missing_for_recipe()
	. = list()
	if(!selected_recipe)
		return
	for(var/crop_type in selected_recipe.needed_crops)
		var/atom/crop_path = crop_type
		if(crop_units[crop_type] < selected_recipe.needed_crops[crop_type])
			. += "[initial(crop_path.name)] ([crop_units[crop_type] || 0]/[selected_recipe.needed_crops[crop_type]] j.)"
	for(var/item_type in selected_recipe.needed_items)
		var/atom/item_path = item_type
		var/have = count_items(item_type)
		if(have < selected_recipe.needed_items[item_type])
			. += "[initial(item_path.name)] ([have]/[selected_recipe.needed_items[item_type]] szt.)"
	for(var/reagent_type in selected_recipe.needed_reagents)
		var/datum/reagent/reagent_path = reagent_type
		var/have = reagents.get_reagent_amount(reagent_type)
		if(have < selected_recipe.needed_reagents[reagent_type])
			. += "[initial(reagent_path.name)] ([round(have, 0.1)]/[selected_recipe.needed_reagents[reagent_type]] j.)"
	if(selected_recipe.pre_reqs && !reagents.has_reagent(selected_recipe.pre_reqs))
		var/datum/reagent/previous = selected_recipe.pre_reqs
		. += "gotowy trunek w beczce: [initial(previous.name)]"

/obj/structure/fermenting_barrel/proc/start_brewing(mob/user)
	var/list/missing = missing_for_recipe()
	if(length(missing))
		if(user)
			to_chat(user, span_warning("Brakuje: [jointext(missing, ", ")]."))
		return FALSE
	for(var/atom/movable/thing as anything in contents)
		qdel(thing)
	crop_units.Cut()
	for(var/reagent_type in selected_recipe.needed_reagents)
		reagents.remove_reagent(reagent_type, selected_recipe.needed_reagents[reagent_type])
	if(selected_recipe.pre_reqs)
		reagents.del_reagent(selected_recipe.pre_reqs)
	brewing = TRUE
	brew_end = world.time + selected_recipe.brew_time
	addtimer(CALLBACK(src, PROC_REF(finish_brewing)), selected_recipe.brew_time, TIMER_STOPPABLE)
	playsound(src, 'sound/effects/bubbles.ogg', 50, TRUE)
	if(user)
		to_chat(user, span_notice("Zamykasz [src] i zaczynasz warzyć: [selected_recipe.display_name]. Potrwa to [DisplayTimeText(selected_recipe.brew_time)]."))
	return TRUE

/obj/structure/fermenting_barrel/proc/finish_brewing()
	if(QDELETED(src) || !selected_recipe)
		return
	var/amount = min(selected_recipe.brewed_amount, reagents.maximum_volume - reagents.total_volume)
	reagents.add_reagent(selected_recipe.reagent_to_brew, amount)
	visible_message(span_notice("[src] przestaje bulgotać: [selected_recipe.display_name] gotowe."))
	playsound(src, 'sound/effects/bubbles.ogg', 50, TRUE)
	brewing = FALSE
	selected_recipe = null

/obj/structure/fermenting_barrel/examine(mob/user)
	. = ..()
	if(brewing)
		. += span_notice("Warzy się: [selected_recipe.display_name], zostało [DisplayTimeText(max(brew_end - world.time, 0), 1)].")
	else if(selected_recipe)
		var/list/missing = missing_for_recipe()
		. += span_notice("Przepis: [selected_recipe.display_name]. [length(missing) ? "Brakuje: [jointext(missing, ", ")]." : "Wszystko jest, Alt+klik i „Rozpocznij warzenie”."]")
	. += span_notice("<b>Alt+klik</b>: wybór trunku z przepisu (bez przepisu wrzucony owoc fermentuje na wino).")

/// Beczkę z trunkiem z browaru można sprzedać przez zaopatrzenie (połowa cen Monke)
/datum/export/large/fermenting_barrel
	cost = 1
	unit_name = "beczka trunku"
	message = "Trunek z pokładowego browaru."
	export_types = list(/obj/structure/fermenting_barrel)

/datum/export/large/fermenting_barrel/get_cost(obj/O)
	var/obj/structure/fermenting_barrel/barrel = O
	. = 0
	for(var/datum/reagent/reagent as anything in barrel.reagents?.reagent_list)
		. += brewing_unit_price(reagent.type) * reagent.volume
	return round(.)
