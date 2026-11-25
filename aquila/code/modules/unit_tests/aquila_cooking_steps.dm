// Makra asercji z upstreamu są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc ten test ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Każdy przepis krokowy ma naczynie, danie albo odczynnik, kroki i nie kończy się krokiem dodatkowym
/datum/unit_test/aquila_cooking_recipes_valid

/datum/unit_test/aquila_cooking_recipes_valid/Run()
	initialize_cooking_recipes()
	var/count = 0
	for(var/recipe_path in subtypesof(/datum/cooking/recipe))
		var/datum/cooking/recipe/recipe = new recipe_path
		count++
		TEST_ASSERT(ispath(recipe.container_type, /obj/item/reagent_containers/cooking), "[recipe_path] has no cooking container")
		TEST_ASSERT(recipe.product_type || recipe.reagent_type, "[recipe_path] makes nothing")
		TEST_ASSERT(length(recipe.steps), "[recipe_path] has no steps")
		var/datum/cooking/recipe_step/last_step = recipe.steps[length(recipe.steps)]
		TEST_ASSERT(!last_step.optional, "[recipe_path] ends with an optional step, so it can never finish without it")
		for(var/datum/cooking/recipe_step/add_reagent/reagent_step in recipe.steps)
			TEST_ASSERT(GLOB.chemical_reagents_list[reagent_step.reagent_type], "[recipe_path] uses unknown reagent [reagent_step.reagent_type]")
		for(var/datum/cooking/recipe_step/use_machine/machine_step in recipe.steps)
			TEST_ASSERT(machine_step.time > 0, "[recipe_path] has a machine step without time")
	TEST_ASSERT(count, "No step recipes were loaded")
	TEST_ASSERT(length(get_cooking_cookbook()), "Step recipes did not reach the cookbook")

/// Jajko na patelni na polu płyty grillowej: po 10 s na średnim ogniu jest jajko sadzone, potem bez ruszania się przypala
/datum/unit_test/aquila_cooking_stovetop_flow

/datum/unit_test/aquila_cooking_stovetop_flow/Run()
	var/obj/machinery/griddle/stovetop = allocate(/obj/machinery/griddle, run_loc_floor_bottom_left)
	var/obj/item/reagent_containers/cooking/pan/pan = allocate(/obj/item/reagent_containers/cooking/pan, run_loc_floor_bottom_left)
	var/obj/item/food/egg/egg = allocate(/obj/item/food/egg, run_loc_floor_bottom_left)

	TEST_ASSERT(pan.process_item(null, egg) == COOK_SUCCESS, "Putting an egg into a pan")
	TEST_ASSERT(egg.loc == pan, "The egg did not land in the pan")

	var/datum/cooking_surface/burner/burner = stovetop.rack.burners[1]
	stovetop.rack.place_container(pan, burner)
	TEST_ASSERT(burner.container == pan && pan.surface == burner, "The pan is not on the burner")
	burner.turn_on()
	burner.temperature = COOK_TEMP_LOW
	for(var/i in 1 to 12)
		burner.process_cooking(1, 1)
	TEST_ASSERT(!(locate(/obj/item/food/friedegg) in pan), "The egg fried on low heat, but the recipe wants medium")
	TEST_ASSERT(!(locate(/obj/item/food/badrecipe) in pan), "The egg burned on the wrong heat while the recipe was still waiting for the stove")

	burner.temperature = COOK_TEMP_MED
	for(var/i in 1 to 10)
		burner.process_cooking(1, 1)
	var/obj/item/food/friedegg/fried = locate() in pan
	TEST_ASSERT(fried, "No fried egg after 10 s on medium heat (pan holds: [english_list(pan.contents)])")
	TEST_ASSERT(!pan.tracker, "The recipe tracker stayed after the dish was done")

	for(var/i in 1 to 50)
		burner.process_cooking(1, 1)
	TEST_ASSERT(locate(/obj/item/food/badrecipe) in pan, "A fried egg left 50 s on medium heat did not burn")

	// Zdjęcie patelni zwalnia palnik
	pan.forceMove(run_loc_floor_bottom_left)
	TEST_ASSERT(!burner.container && !pan.surface, "Taking the pan off did not free the burner")

/// Kroki dodatkowe poprawiają danie: omlet z olejem i pieprzem jest „dobrze przyrządzony”
/datum/unit_test/aquila_cooking_quality

/datum/unit_test/aquila_cooking_quality/Run()
	var/obj/machinery/griddle/stovetop = allocate(/obj/machinery/griddle, run_loc_floor_bottom_left)
	var/obj/item/reagent_containers/cooking/pan/pan = allocate(/obj/item/reagent_containers/cooking/pan, run_loc_floor_bottom_left)
	var/obj/item/reagent_containers/glass/beaker/oil = allocate(/obj/item/reagent_containers/glass/beaker, run_loc_floor_bottom_left)
	oil.reagents.add_reagent(/datum/reagent/consumable/nutriment/fat/oil, 10)
	oil.amount_per_transfer_from_this = 5
	var/obj/item/reagent_containers/glass/beaker/pepper = allocate(/obj/item/reagent_containers/glass/beaker, run_loc_floor_bottom_left)
	pepper.reagents.add_reagent(/datum/reagent/consumable/blackpepper, 10)

	TEST_ASSERT(pan.process_item(null, oil) == COOK_SUCCESS, "Pouring oil into a pan")
	pan.process_item(null, allocate(/obj/item/food/egg, run_loc_floor_bottom_left))
	pan.process_item(null, allocate(/obj/item/food/egg, run_loc_floor_bottom_left))
	pan.process_item(null, allocate(/obj/item/food/cheese/wedge, run_loc_floor_bottom_left))
	TEST_ASSERT(pan.process_item(null, pepper) == COOK_SUCCESS, "Adding pepper to the omelette")

	var/datum/cooking_surface/burner/burner = stovetop.rack.burners[2]
	stovetop.rack.place_container(pan, burner)
	burner.turn_on()
	burner.temperature = COOK_TEMP_LOW
	for(var/i in 1 to 21)
		burner.process_cooking(1, 1)
	var/obj/item/food/omelette/omelette = locate() in pan
	TEST_ASSERT(omelette, "No omelette after 20 s on low heat (pan holds: [english_list(pan.contents)])")
	TEST_ASSERT(omelette.cooking_quality >= 1, "Two optional steps did not make the omelette better (quality [omelette.cooking_quality])")

/// Naczynie żaroodporne w piekarniku: ciasto z jajkiem staje się chlebem (przepis z Paradise)
/datum/unit_test/aquila_cooking_oven_dish

/datum/unit_test/aquila_cooking_oven_dish/Run()
	var/obj/machinery/oven/oven = allocate(/obj/machinery/oven, run_loc_floor_bottom_left)
	var/obj/item/reagent_containers/cooking/oven/dish = allocate(/obj/item/reagent_containers/cooking/oven, run_loc_floor_bottom_left)
	dish.process_item(null, allocate(/obj/item/food/dough, run_loc_floor_bottom_left))
	dish.process_item(null, allocate(/obj/item/food/egg, run_loc_floor_bottom_left))
	dish.forceMove(oven)
	oven.add_dish(dish)
	TEST_ASSERT(oven.chamber.container == dish, "The dish did not go into the oven")
	oven.chamber.turn_on()
	for(var/i in 1 to 11)
		oven.chamber.process_cooking(1, 1)
	TEST_ASSERT(locate(/obj/item/food/bread/plain) in dish, "Dough and an egg in the oven dish did not bake into bread (dish holds: [english_list(dish.contents)])")

/// Nagrzewanie: zimna maszyna gotuje na 1/4 mocy, rozgrzana na pełnej; laser 4. poziomu: 5 s i ×1,5
/datum/unit_test/aquila_kitchen_heat

/datum/unit_test/aquila_kitchen_heat/Run()
	var/datum/kitchen_heat/heat = new
	TEST_ASSERT(abs(heat.factor() - KITCHEN_COLD_SPEED) < 0.01, "A cold machine cooks at [heat.factor()], expected [KITCHEN_COLD_SPEED]")
	heat.refresh(4)
	TEST_ASSERT(heat.warmup == 5 SECONDS, "Tier 4 lasers warm up in [heat.warmup / 10] s, expected 5 s")
	TEST_ASSERT(abs(heat.speed - 1.5) < 0.01, "Tier 4 lasers cook at x[heat.speed], expected x1.5")
	heat.heat = 1
	heat.heating = TRUE
	heat.heat_time = world.time
	TEST_ASSERT(abs(heat.factor() - 1.5) < 0.01, "A hot tier 4 machine cooks at x[heat.factor()], expected x1.5")
	qdel(heat)

	// Ogień kuchenki ustala temperaturę zupy
	var/obj/machinery/stove/stove = allocate(/obj/machinery/stove, run_loc_floor_bottom_left)
	var/datum/component/stove/stove_component = stove.GetComponent(/datum/component/stove)
	stove_component.burner.temperature = COOK_TEMP_LOW
	TEST_ASSERT(stove_component.soup_target_temperature() < SOUP_WATER_BOILING_POINT, "Low heat would still boil soup")
	stove_component.burner.temperature = COOK_TEMP_HIGH
	TEST_ASSERT(stove_component.soup_target_temperature() > SOUP_BURN_TEMP, "High heat would not burn soup")

/// Minutnik działa też przy zwykłej blasze i przy garnku z zupą; kuchnia stygnie dopiero, gdy wyłączy się i palnik, i piekarnik
/datum/unit_test/aquila_kitchen_timers

/datum/unit_test/aquila_kitchen_timers/Run()
	var/obj/machinery/oven/range/range = allocate(/obj/machinery/oven/range, run_loc_floor_bottom_left)
	var/obj/item/plate/oven_tray/tray = allocate(/obj/item/plate/oven_tray, run_loc_floor_bottom_left)
	allocate(/obj/item/food/dough, tray)
	range.add_tray_to_oven(tray)
	range.chamber.timer = 3 SECONDS
	range.open = FALSE
	range.chamber.turn_on()
	range.begin_processing()
	TEST_ASSERT(range.kitchen_heat.heating, "A closed oven with a tray is not heating")
	for(var/i in 1 to 4)
		range.process(1)
	TEST_ASSERT(range.chamber.timer_left <= 0, "The oven timer did not run out while baking on a tray ([range.chamber.timer_left] ds left)")

	var/datum/component/stove/stove = range.GetComponent(/datum/component/stove)
	stove.turn_on()
	stove.turn_off()
	TEST_ASSERT(range.kitchen_heat.heating, "Turning off the burner cooled down the oven that is still baking")
	range.open = TRUE
	range.end_processing()
	TEST_ASSERT(!range.kitchen_heat.heating, "The range kept heating with the oven open and the burner off")

	var/obj/machinery/stove/soup_stove = allocate(/obj/machinery/stove, run_loc_floor_bottom_left)
	var/datum/component/stove/soup_component = soup_stove.GetComponent(/datum/component/stove)
	var/obj/item/reagent_containers/glass/soup_pot/pot = allocate(/obj/item/reagent_containers/glass/soup_pot, soup_stove)
	soup_component.add_container(pot)
	soup_component.burner.timer = 2 SECONDS
	soup_component.turn_on()
	for(var/i in 1 to 3)
		soup_component.process(1)
	TEST_ASSERT(soup_component.burner.timer_left <= 0, "The burner timer did not run out with a soup pot on it")
	soup_component.turn_off()

/// Woda wlana w dwóch porcjach po 5 j. nie gubi spaghetti; woda wyciągnięta z rondla po zaliczonym kroku blokuje danie do dolania
/datum/unit_test/aquila_cooking_reagent_refill

/datum/unit_test/aquila_cooking_reagent_refill/Run()
	var/obj/machinery/griddle/stovetop = allocate(/obj/machinery/griddle, run_loc_floor_bottom_left)
	var/obj/item/reagent_containers/cooking/pot/pot = allocate(/obj/item/reagent_containers/cooking/pot, run_loc_floor_bottom_left)
	var/obj/item/reagent_containers/glass/beaker/water = allocate(/obj/item/reagent_containers/glass/beaker, run_loc_floor_bottom_left)
	water.reagents.add_reagent(/datum/reagent/water, 10)
	water.amount_per_transfer_from_this = 5

	pot.process_item(null, water)
	pot.process_item(null, water)
	TEST_ASSERT(pot.reagents.get_reagent_amount(/datum/reagent/water) >= 10, "Two 5 u pours did not reach the pot")
	TEST_ASSERT(pot.process_item(null, allocate(/obj/item/food/spaghetti/raw, run_loc_floor_bottom_left)) == COOK_SUCCESS, "Raw spaghetti was rejected after two 5 u pours of water")

	var/datum/cooking_surface/burner/burner = stovetop.rack.burners[1]
	stovetop.rack.place_container(pot, burner)
	burner.turn_on()
	burner.temperature = COOK_TEMP_HIGH
	pot.reagents.remove_reagent(/datum/reagent/water, 10)
	for(var/i in 1 to 16)
		burner.process_cooking(1, 1)
	TEST_ASSERT(!(locate(/obj/item/food/spaghetti/boiledspaghetti) in pot), "Spaghetti boiled although the water was taken out of the pot")
	TEST_ASSERT(locate(/obj/item/food/spaghetti/raw) in pot, "The raw spaghetti vanished when the dish was blocked")

	pot.reagents.add_reagent(/datum/reagent/water, 10)
	for(var/i in 1 to 16)
		burner.process_cooking(1, 1)
	TEST_ASSERT(locate(/obj/item/food/spaghetti/boiledspaghetti) in pot, "No boiled spaghetti after refilling the water (pot holds: [english_list(pot.contents)])")

/// Płyta grillowa to grill i kuchenka w jednym: jeden ogień dla czterech pól, jajko na patelni na polu płyty, garnek z zupą na drugim polu,
/// a położony obok kotlet dalej się smaży, gdy płyta jest włączona
/datum/unit_test/aquila_griddle_burners

/datum/unit_test/aquila_griddle_burners/Run()
	var/obj/machinery/griddle/griddle = allocate(/obj/machinery/griddle, run_loc_floor_bottom_left)
	var/obj/item/reagent_containers/cooking/pan/pan = allocate(/obj/item/reagent_containers/cooking/pan, run_loc_floor_bottom_left)
	pan.process_item(null, allocate(/obj/item/food/egg, run_loc_floor_bottom_left))
	var/obj/item/reagent_containers/glass/soup_pot/pot = allocate(/obj/item/reagent_containers/glass/soup_pot, run_loc_floor_bottom_left)
	pot.reagents.add_reagent(/datum/reagent/water, 50, reagtemp = T20C)

	var/datum/cooking_surface/burner/pan_field = griddle.rack.burners[1]
	var/datum/cooking_surface/burner/pot_field = griddle.rack.burners[4]
	TEST_ASSERT(pan_field.accepts(pan) && pot_field.accepts(pot), "The griddle does not take a pan or a soup pot")
	griddle.rack.place_container(pan, pan_field)
	griddle.rack.place_container(pot, pot_field)
	TEST_ASSERT(pan.loc == griddle && pot.loc == griddle, "The pan and the pot are not on the griddle")

	pan_field.turn_on()
	pot_field.turn_on()
	// Ogień jest jeden dla całej płyty: ustawiony na jednym polu zmienia wszystkie
	pot_field.temperature = COOK_TEMP_LOW
	griddle.kitchen_temperature_set(pot_field)
	var/datum/cooking_surface/burner/other_field = griddle.rack.burners[2]
	TEST_ASSERT(pan_field.temperature == COOK_TEMP_LOW && other_field.temperature == COOK_TEMP_LOW, "Setting the heat on one griddle field did not set the whole griddle")
	pan_field.temperature = COOK_TEMP_MED
	griddle.kitchen_temperature_set(pan_field)
	TEST_ASSERT(pot_field.temperature == COOK_TEMP_MED, "The soup pot field did not follow the griddle heat")
	griddle.update_griddle_processing()
	TEST_ASSERT(griddle.is_kitchen_active(), "The griddle is not working with two fields on")
	for(var/i in 1 to 40)
		griddle.process(1)
		if(locate(/obj/item/food/friedegg) in pan)
			break
	TEST_ASSERT(locate(/obj/item/food/friedegg) in pan, "No fried egg in the pan on the griddle (pan holds: [english_list(pan.contents)])")
	TEST_ASSERT(pot.reagents.chem_temp > T20C + 5, "The soup pot did not heat up on the griddle ([pot.reagents.chem_temp] K)")

	// Zwykłe grillowanie zostaje: wyłączona płyta nie smaży, pola z naczyniami dalej działają
	TEST_ASSERT(!griddle.on, "The griddle surface turned on by itself")
	pan_field.turn_off()
	pot_field.turn_off()
	griddle.update_griddle_processing()
	TEST_ASSERT(!griddle.is_kitchen_active(), "The griddle kept working with everything off")
	pan.forceMove(run_loc_floor_bottom_left)
	TEST_ASSERT(!pan_field.container && pan.transform.a == 1, "Taking the pan off the griddle did not free the field")

/// Płyta z czterema naczyniami: włącznik w menu, brak prądu ją wyłącza, a rozebrana włączona płyta schodzi z przetwarzania i oddaje naczynia w zwykłym wyglądzie
/datum/unit_test/aquila_griddle_teardown

/datum/unit_test/aquila_griddle_teardown/Run()
	var/mob/living/carbon/human/cook = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/machinery/griddle/griddle = allocate(/obj/machinery/griddle, run_loc_floor_bottom_left)
	var/list/pans = list()
	for(var/datum/cooking_surface/burner/field as anything in griddle.rack.burners)
		var/obj/item/reagent_containers/cooking/pan/pan = allocate(/obj/item/reagent_containers/cooking/pan, run_loc_floor_bottom_left)
		griddle.rack.place_container(pan, field)
		pans += pan
	TEST_ASSERT(griddle.kitchen_menu_extras()["Płyta: włącz/wyłącz"], "The griddle settings menu has no switch for the griddle itself")
	griddle.kitchen_menu_extra_chosen("Płyta: włącz/wyłącz", cook)
	TEST_ASSERT(griddle.on, "The griddle with four pans could not be turned on from the menu")

	// Bez prądu płyta i pola się wyłączają, a płyta schodzi z przetwarzania
	var/datum/cooking_surface/burner/first_field = griddle.rack.burners[1]
	first_field.turn_on()
	griddle.machine_stat |= NOPOWER
	griddle.process(1)
	griddle.machine_stat &= ~NOPOWER
	TEST_ASSERT(!griddle.on && !first_field.on, "The griddle stayed on without power")
	TEST_ASSERT(!(griddle in SSmachines.processing), "The griddle kept processing without power")

	griddle.kitchen_menu_extra_chosen("Płyta: włącz/wyłącz", cook)
	first_field.turn_on()
	griddle.update_griddle_processing()
	TEST_ASSERT(griddle in SSmachines.processing, "The griddle that was turned on is not processing")
	var/obj/item/reagent_containers/cooking/pan/first_pan = pans[1]
	qdel(griddle)
	TEST_ASSERT(!(griddle in SSmachines.processing), "A griddle destroyed while on stayed in SSmachines processing")
	for(var/obj/item/reagent_containers/cooking/pan/pan as anything in pans)
		TEST_ASSERT(pan.loc == run_loc_floor_bottom_left, "A pan did not drop out of the destroyed griddle")
		TEST_ASSERT(!pan.mini && pan.transform.a == 1 && !pan.pixel_x && !pan.pixel_y, "A pan from the destroyed griddle kept its small on-griddle look (mini [pan.mini], transform a [pan.transform.a], pixel [pan.pixel_x], [pan.pixel_y])")
		TEST_ASSERT(!(pan.flags_1 & IS_ONTOP_1), "A pan from the destroyed griddle kept IS_ONTOP_1")
	TEST_ASSERT(first_pan.loc == run_loc_floor_bottom_left, "The first pan is gone")

/// Mikser lodów (przepis z Paradise): patyczek, tofu, cukier i sok bananowy w misie zamarzają w lód na patyku i się nie przypalają
/datum/unit_test/aquila_cooking_ice_cream_mixer

/datum/unit_test/aquila_cooking_ice_cream_mixer/Run()
	var/obj/machinery/ice_cream_mixer/mixer = allocate(/obj/machinery/ice_cream_mixer, run_loc_floor_bottom_left)
	var/obj/item/reagent_containers/cooking/icecream_bowl/bowl = allocate(/obj/item/reagent_containers/cooking/icecream_bowl, run_loc_floor_bottom_left)
	var/obj/item/reagent_containers/glass/beaker/sugar = allocate(/obj/item/reagent_containers/glass/beaker, run_loc_floor_bottom_left)
	sugar.reagents.add_reagent(/datum/reagent/consumable/sugar, 5)
	sugar.amount_per_transfer_from_this = 5
	var/obj/item/reagent_containers/glass/beaker/banana = allocate(/obj/item/reagent_containers/glass/beaker, run_loc_floor_bottom_left)
	banana.reagents.add_reagent(/datum/reagent/consumable/banana, 5)
	banana.amount_per_transfer_from_this = 5

	TEST_ASSERT(bowl.process_item(null, allocate(/obj/item/popsicle_stick, run_loc_floor_bottom_left)) == COOK_SUCCESS, "Putting a popsicle stick into the freezing bowl")
	TEST_ASSERT(bowl.process_item(null, allocate(/obj/item/food/tofu, run_loc_floor_bottom_left)) == COOK_SUCCESS, "Adding tofu to the freezing bowl")
	TEST_ASSERT(bowl.process_item(null, sugar) == COOK_SUCCESS, "Pouring sugar into the freezing bowl")
	TEST_ASSERT(bowl.process_item(null, banana) == COOK_SUCCESS, "Pouring banana juice into the freezing bowl")
	mixer.place_container(bowl)
	TEST_ASSERT(mixer.chamber.container == bowl, "The bowl did not go into the mixer")
	mixer.chamber.turn_on()
	for(var/i in 1 to 11)
		mixer.chamber.process_cooking(1, 1)
	var/obj/item/food/popsicle/bananatop/popsicle = locate() in bowl
	TEST_ASSERT(popsicle, "No banana topsicle after 10 s in the mixer (bowl holds: [english_list(bowl.contents)])")
	for(var/i in 1 to 120)
		mixer.chamber.process_cooking(1, 1)
	TEST_ASSERT(!(locate(/obj/item/food/badrecipe) in bowl), "A dessert left in the mixer burned")

	// Foremki z plastiku są w menu craftingu (lista plastiku uzupełniana przed budową menu)
	var/found_mould = FALSE
	for(var/datum/crafting_recipe/recipe as anything in GLOB.crafting_recipes)
		if(recipe.result == /obj/item/reagent_containers/cooking/mould/bear)
			found_mould = TRUE
			break
	TEST_ASSERT(found_mould, "The bear-shaped candy mould is not in the crafting menu")

#undef TEST_ASSERT
