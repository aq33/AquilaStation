// AQUILA - kompostownik (wzór: Bubberstation /obj/machinery/compostbin, modular_skyrat/modules/primitive_production/code/hydroponics.dm)
// Drewniana skrzynia bez prądu. Plony, jedzenie i resztki roślin rozkładają się po czasie w nawóz (E-Z-Nutrient),
// który nalewa się zlewką. Za COMPOST_BIN_PER_BAG jednostek można wygrzebać worek ziemi do tacy.

/// Ile kompostu kosztuje worek ziemi
#define COMPOST_BIN_PER_BAG 40
/// Najmniej kompostu z jednej rzeczy (resztki bez odżywek)
#define COMPOST_BIN_MIN_PER_ITEM 2

/obj/structure/compost_bin
	name = "kompostownik"
	desc = "Śmierdząca skrzynia z drewnianych listew. Wrzucasz plony i resztki jedzenia, a po czasie wyjmujesz kompost."
	icon = 'aquila/icons/obj/hydroponics/compost.dmi'
	icon_state = "compost_bin"
	density = TRUE
	anchored = TRUE
	max_integrity = 100
	resistance_flags = FLAMMABLE
	/// Odczynnik, w który zmienia się kompost. Nawóz, który nasze rośliny już rozumieją (leczenie, plant_needs/buffs/fertilizers.dm)
	var/reagent_id = /datum/reagent/plantnutriment/eznutriment
	/// Ile rzeczy rozkłada się w jednym cyklu
	var/processed_items_per_cycle = 5
	/// Ile rzeczy mieści się naraz
	var/max_items = 20
	/// Co ile rozkłada się kolejna porcja
	var/compost_interval = 20 SECONDS
	COOLDOWN_DECLARE(compost_cooldown)

/obj/structure/compost_bin/Initialize(mapload)
	. = ..()
	create_reagents(300, DRAINABLE | AMOUNT_VISIBLE)

/obj/structure/compost_bin/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/compost_bin/examine(mob/user)
	. = ..()
	. += span_notice("W środku rozkłada się: <b>[get_item_count()]/[max_items]</b> rzeczy.")
	. += span_notice("Kompost: <b>[round(reagents.total_volume)]/[reagents.maximum_volume]</b> j. Nalej go zlewką albo wygrzeb ręką worek ziemi (<b>[COMPOST_BIN_PER_BAG]</b> j.).")
	. += span_notice("Łomem rozbierzesz skrzynię na deski.")

/obj/structure/compost_bin/update_overlays()
	. = ..()
	var/volume = reagents?.total_volume
	if(!volume)
		return
	var/level = 1
	if(volume >= reagents.maximum_volume * 2 / 3)
		level = 3
	else if(volume >= reagents.maximum_volume / 3)
		level = 2
	. += mutable_appearance(icon, "[icon_state]-[level]")

/obj/structure/compost_bin/proc/get_item_count()
	. = 0
	for(var/obj/item/item in contents)
		.++

/// Czy to się rozłoży (plony, jedzenie, resztki roślin)
/obj/structure/compost_bin/proc/is_compostable(obj/item/item)
	if(!istype(item, /obj/item/food) && !istype(item, /obj/item/grown))
		return FALSE
	if(SEND_SIGNAL(item, COMSIG_EDIBLE_ON_COMPOST, null) & COMPONENT_EDIBLE_BLOCK_COMPOST)
		return FALSE
	return TRUE

/obj/structure/compost_bin/attackby(obj/item/item, mob/living/user, params)
	if(user.combat_mode)
		return ..()
	if(item.is_refillable())
		return FALSE //nalewanie kompostu w afterattack pojemnika
	if(istype(item, /obj/item/storage/bag))
		if(get_item_count() >= max_items)
			to_chat(user, span_warning("[src] jest pełny, poczekaj, aż zawartość się rozłoży."))
			return TRUE
		var/added = 0
		for(var/obj/item/bag_item in item.contents)
			if(get_item_count() >= max_items)
				break
			if(!is_compostable(bag_item))
				continue
			if(SEND_SIGNAL(item, COMSIG_TRY_STORAGE_TAKE, bag_item, src))
				added++
		if(!added)
			to_chat(user, span_warning("W: [item] nie ma niczego, co by się rozłożyło."))
			return TRUE
		to_chat(user, span_notice("Wysypujesz do: [src] zawartość: [item] ([added])."))
		start_composting()
		return TRUE
	if(is_compostable(item))
		if(get_item_count() >= max_items)
			to_chat(user, span_warning("[src] jest pełny, poczekaj, aż zawartość się rozłoży."))
			return TRUE
		if(!user.transferItemToLoc(item, src))
			return TRUE
		to_chat(user, span_notice("Wrzucasz do: [src] [item]."))
		start_composting()
		return TRUE
	return ..()

/// Wygrzebanie worka ziemi z gotowego kompostu
/obj/structure/compost_bin/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(reagents.get_reagent_amount(reagent_id) < COMPOST_BIN_PER_BAG)
		to_chat(user, span_warning("Za mało kompostu na worek ziemi (potrzeba [COMPOST_BIN_PER_BAG] j.)."))
		return
	to_chat(user, span_notice("Wygrzebujesz kompost z: [src]..."))
	if(!do_after(user, 2 SECONDS, target = src))
		return
	if(!take_substrate_bag(drop_location()))
		return
	playsound(src, 'sound/effects/shovel_dig.ogg', 50, TRUE)
	to_chat(user, span_notice("Napełniasz worek ziemią z kompostu."))
	return TRUE

/// Zużywa kompost i daje worek ziemi. Zwraca worek albo null, gdy kompostu za mało.
/obj/structure/compost_bin/proc/take_substrate_bag(atom/destination)
	if(reagents.get_reagent_amount(reagent_id) < COMPOST_BIN_PER_BAG)
		return null
	reagents.remove_reagent(reagent_id, COMPOST_BIN_PER_BAG)
	update_appearance()
	return new /obj/item/substrate_bag/dirt(destination)

/obj/structure/compost_bin/proc/start_composting()
	if(!get_item_count())
		return
	if(!(datum_flags & DF_ISPROCESSING))
		COOLDOWN_START(src, compost_cooldown, compost_interval)
	START_PROCESSING(SSobj, src)

/obj/structure/compost_bin/process(delta_time)
	if(!get_item_count())
		return PROCESS_KILL
	if(!COOLDOWN_FINISHED(src, compost_cooldown))
		return
	COOLDOWN_START(src, compost_cooldown, compost_interval)
	compost_cycle()
	if(!get_item_count())
		return PROCESS_KILL

/// Jeden cykl rozkładu: do processed_items_per_cycle rzeczy zmienia się w kompost
/obj/structure/compost_bin/proc/compost_cycle()
	var/converted = 0
	for(var/obj/item/item in contents)
		if(converted >= processed_items_per_cycle)
			break
		if(reagents.total_volume >= reagents.maximum_volume)
			break
		if(!convert_to_compost(item))
			break
		converted++
	update_appearance()
	return converted

/obj/structure/compost_bin/proc/convert_to_compost(obj/item/item)
	var/amount = 0
	if(!(item.flags_1 & HOLOGRAM_1))
		amount = COMPOST_BIN_MIN_PER_ITEM
		if(item.reagents)
			amount = max(amount, CEILING(item.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment, TRUE), 1))
	//Przedmiot zostaje w skrzyni, dopóki cały kompost z niego nie zmieści się w zbiorniku (bardzo pożywny daje najwyżej pełny zbiornik)
	amount = min(amount, reagents.maximum_volume)
	if(amount > reagents.maximum_volume - reagents.total_volume)
		return FALSE
	qdel(item)
	if(amount)
		reagents.add_reagent(reagent_id, amount)
	return TRUE

/obj/structure/compost_bin/Exited(atom/movable/gone, direction)
	. = ..()
	if(!QDELETED(src))
		update_appearance()

/obj/structure/compost_bin/crowbar_act(mob/living/user, obj/item/tool)
	to_chat(user, span_notice("Zaczynasz rozbierać: [src]..."))
	if(!tool.use_tool(src, user, 5 SECONDS, volume = 50))
		return TRUE
	deconstruct(TRUE)
	return TRUE

/obj/structure/compost_bin/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/mineral/wood(drop_location(), 10)
		for(var/obj/item/item in contents)
			item.forceMove(drop_location())
	return ..()

/datum/crafting_recipe/compost_bin
	name = "kompostownik"
	result = /obj/structure/compost_bin
	reqs = list(/obj/item/stack/sheet/mineral/wood = 10)
	time = 6 SECONDS
	category = CAT_STRUCTURE
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND

#undef COMPOST_BIN_PER_BAG
#undef COMPOST_BIN_MIN_PER_ITEM
