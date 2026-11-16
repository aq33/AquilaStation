// AQUILA - farma dżdżownic (wzór: Skyrat/Bubberstation /obj/structure/wormfarm, modular_skyrat/modules/ashwalkers/code/buildings/wormfarm.dm)
// Beczka z dżdżownicami. Karmiona jedzeniem co pół minuty przerabia jedną porcję na nawóz (mniej niż kompostownik),
// a dżdżownice się mnożą i można je wygrzebać ręką. Nie mamy wędkarstwa, więc dżdżownica nie jest przynętą,
// służy tylko do zakładania kolejnych farm (i można ją zjeść).

/obj/item/food/worm
	name = "dżdżownica"
	desc = "Wijąca się dżdżownica. Chyba nie zamierzasz jej zjeść?"
	icon = 'aquila/icons/obj/hydroponics/compost.dmi'
	icon_state = "worm"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 1)
	tastes = list("mięso" = 1, "robaki" = 1)
	foodtypes = GROSS | MEAT | BUGS
	w_class = WEIGHT_CLASS_TINY

/obj/structure/worm_farm
	name = "farma dżdżownic"
	desc = "Cudownie brudna beczka, w której dżdżownice wiodą szczęśliwe życie."
	icon = 'aquila/icons/obj/hydroponics/compost.dmi'
	icon_state = "worm_farm"
	density = TRUE
	anchored = FALSE
	max_integrity = 100
	resistance_flags = FLAMMABLE
	/// Nawóz, ten sam co z kompostownika
	var/reagent_id = /datum/reagent/plantnutriment/eznutriment
	/// Ile nawozu daje jedna porcja jedzenia
	var/fertilizer_per_food = 5
	/// Ile dżdżownic mieści beczka
	var/max_worm = 10
	/// Ile dżdżownic jest w beczce
	var/current_worm = 0
	/// Ile porcji jedzenia czeka na przerobienie
	var/current_food = 0
	/// Co ile dżdżownice się mnożą i przerabiają porcję jedzenia
	var/worm_interval = 30 SECONDS
	/// Ktoś właśnie karmi albo wygrzebuje dżdżownice
	var/in_use = FALSE
	COOLDOWN_DECLARE(worm_timer)

/obj/structure/worm_farm/Initialize(mapload)
	. = ..()
	create_reagents(100, DRAINABLE | AMOUNT_VISIBLE)
	START_PROCESSING(SSobj, src)
	COOLDOWN_START(src, worm_timer, worm_interval)

/obj/structure/worm_farm/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/worm_farm/process(delta_time)
	if(!COOLDOWN_FINISHED(src, worm_timer))
		return
	COOLDOWN_START(src, worm_timer, worm_interval)
	worm_cycle()

/// Dżdżownice się mnożą i przerabiają jedną porcję jedzenia na nawóz. Potrzebne są co najmniej dwie.
/obj/structure/worm_farm/proc/worm_cycle()
	if(current_worm < 2)
		return
	if(current_worm < max_worm)
		current_worm++
	if(current_food > 0 && reagents.total_volume < reagents.maximum_volume)
		current_food--
		reagents.add_reagent(reagent_id, fertilizer_per_food)

/obj/structure/worm_farm/examine(mob/user)
	. = ..()
	. += span_notice("Dżdżownice w beczce: <b>[current_worm]/[max_worm]</b>.")
	if(current_worm < 2)
		. += span_warning("Potrzeba co najmniej dwóch dżdżownic, żeby się mnożyły i przerabiały jedzenie.")
	else
		. += span_notice("Nakarm je jedzeniem, a dadzą nawóz. Porcje czekające na przerobienie: <b>[current_food]</b>.")
	. += span_notice("Nawóz: <b>[round(reagents.total_volume)]/[reagents.maximum_volume]</b> j. Nalej go zlewką.")
	if(current_worm > 0)
		. += span_notice("Ręką wygrzebiesz dżdżownicę.")

/obj/structure/worm_farm/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(in_use)
		balloon_alert(user, "ktoś już tu grzebie")
		return
	if(current_worm <= 0)
		balloon_alert(user, "nie ma dżdżownic")
		return
	in_use = TRUE
	balloon_alert(user, "wygrzebujesz dżdżownicę")
	if(!do_after(user, 2 SECONDS, target = src) || current_worm <= 0)
		in_use = FALSE
		return
	current_worm--
	var/obj/item/food/worm/worm = new(drop_location())
	user.put_in_hands(worm)
	in_use = FALSE
	return TRUE

/obj/structure/worm_farm/attackby(obj/item/item, mob/living/user, params)
	if(user.combat_mode)
		return ..()
	if(item.is_refillable())
		return FALSE //nalewanie nawozu w afterattack pojemnika
	//dżdżownica to też jedzenie, więc najpierw ona
	if(istype(item, /obj/item/food/worm))
		if(current_worm >= max_worm)
			balloon_alert(user, "beczka jest pełna dżdżownic")
			return TRUE
		qdel(item)
		current_worm++
		balloon_alert(user, "wpuszczasz dżdżownicę")
		return TRUE
	if(istype(item, /obj/item/food))
		INVOKE_ASYNC(src, PROC_REF(feed_food), user, item)
		return TRUE
	if(istype(item, /obj/item/storage/bag))
		INVOKE_ASYNC(src, PROC_REF(feed_bag), user, item)
		return TRUE
	return ..()

/obj/structure/worm_farm/proc/feed_food(mob/living/user, obj/item/food/food)
	if(in_use)
		balloon_alert(user, "ktoś już tu grzebie")
		return
	in_use = TRUE
	balloon_alert(user, "karmisz dżdżownice")
	if(!do_after(user, 1 SECONDS, target = src) || QDELETED(food))
		in_use = FALSE
		return
	qdel(food)
	current_food++
	in_use = FALSE
	balloon_alert(user, "nakarmione, wróć później")

/obj/structure/worm_farm/proc/feed_bag(mob/living/user, obj/item/storage/bag/bag)
	if(in_use)
		balloon_alert(user, "ktoś już tu grzebie")
		return
	in_use = TRUE
	var/fed = 0
	for(var/obj/item/food/food in bag.contents)
		if(istype(food, /obj/item/food/worm))
			continue
		if(!do_after(user, 1 SECONDS, target = src))
			break
		if(QDELETED(food) || food.loc != bag)
			continue
		qdel(food)
		current_food++
		fed++
	in_use = FALSE
	balloon_alert(user, fed ? "nakarmione, wróć później" : "w torbie nie ma jedzenia")

/obj/structure/worm_farm/crowbar_act(mob/living/user, obj/item/tool)
	to_chat(user, span_notice("Zaczynasz rozbierać: [src]..."))
	if(!tool.use_tool(src, user, 5 SECONDS, volume = 50))
		return TRUE
	deconstruct(TRUE)
	return TRUE

/obj/structure/worm_farm/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/mineral/wood(drop_location(), 5)
		for(var/i in 1 to current_worm)
			new /obj/item/food/worm(drop_location())
		current_worm = 0
	return ..()

/datum/crafting_recipe/worm_farm
	name = "farma dżdżownic"
	result = /obj/structure/worm_farm
	reqs = list(
		/obj/item/stack/sheet/mineral/wood = 5,
		/obj/item/food/worm = 2,
	)
	time = 4 SECONDS
	category = CAT_STRUCTURE
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND

/// Dżdżownice z przepisu trafiają do beczki
/datum/crafting_recipe/worm_farm/on_craft_completion(mob/user, atom/result)
	var/obj/structure/worm_farm/farm = result
	if(istype(farm))
		farm.current_worm = reqs[/obj/item/food/worm]

/// Dżdżownice na start pierwszej farmy w automacie NutriMax w hydroponice
/obj/machinery/vending/hydronutrients/Initialize(mapload)
	products[/obj/item/food/worm] = 6
	return ..()
