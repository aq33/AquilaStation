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

/// Jajko na patelni na palniku: po 10 s na średnim ogniu jest jajko sadzone, potem bez ruszania się przypala
/datum/unit_test/aquila_cooking_stovetop_flow

/datum/unit_test/aquila_cooking_stovetop_flow/Run()
	var/obj/machinery/cooking_stovetop/stovetop = allocate(/obj/machinery/cooking_stovetop, run_loc_floor_bottom_left)
	var/obj/item/reagent_containers/cooking/pan/pan = allocate(/obj/item/reagent_containers/cooking/pan, run_loc_floor_bottom_left)
	var/obj/item/food/egg/egg = allocate(/obj/item/food/egg, run_loc_floor_bottom_left)

	TEST_ASSERT(pan.process_item(null, egg) == COOK_SUCCESS, "Putting an egg into a pan")
	TEST_ASSERT(egg.loc == pan, "The egg did not land in the pan")

	var/datum/cooking_surface/burner/burner = stovetop.burners[1]
	stovetop.place_container(pan, burner)
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
	var/obj/machinery/cooking_stovetop/stovetop = allocate(/obj/machinery/cooking_stovetop, run_loc_floor_bottom_left)
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

	var/datum/cooking_surface/burner/burner = stovetop.burners[2]
	stovetop.place_container(pan, burner)
	burner.turn_on()
	burner.temperature = COOK_TEMP_LOW
	for(var/i in 1 to 21)
		burner.process_cooking(1, 1)
	var/obj/item/food/omelette/omelette = locate() in pan
	TEST_ASSERT(omelette, "No omelette after 20 s on low heat (pan holds: [english_list(pan.contents)])")
	TEST_ASSERT(omelette.cooking_quality >= 1, "Two optional steps did not make the omelette better (quality [omelette.cooking_quality])")

/// Naczynie żaroodporne w piekarniku: ciasto staje się chlebem
/datum/unit_test/aquila_cooking_oven_dish

/datum/unit_test/aquila_cooking_oven_dish/Run()
	var/obj/machinery/oven/oven = allocate(/obj/machinery/oven, run_loc_floor_bottom_left)
	var/obj/item/reagent_containers/cooking/oven/dish = allocate(/obj/item/reagent_containers/cooking/oven, run_loc_floor_bottom_left)
	dish.process_item(null, allocate(/obj/item/food/dough, run_loc_floor_bottom_left))
	dish.forceMove(oven)
	oven.add_dish(dish)
	TEST_ASSERT(oven.chamber.container == dish, "The dish did not go into the oven")
	oven.chamber.turn_on()
	for(var/i in 1 to 41)
		oven.chamber.process_cooking(1, 1)
	TEST_ASSERT(locate(/obj/item/food/bread/plain) in dish, "Dough in the oven dish did not bake into bread (dish holds: [english_list(dish.contents)])")

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

#undef TEST_ASSERT
