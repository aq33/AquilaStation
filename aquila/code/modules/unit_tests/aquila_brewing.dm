// Makra asercji z upstreamu są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc ten test ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Przepisy browaru mają istniejące odczynniki, plony i przedmioty
/datum/unit_test/aquila_brewing_recipes_valid

/datum/unit_test/aquila_brewing_recipes_valid/Run()
	TEST_ASSERT(length(GLOB.brewing_recipes) >= 20, "Only [length(GLOB.brewing_recipes)] brewing recipes loaded")
	for(var/datum/brewing_recipe/recipe as anything in GLOB.brewing_recipes)
		TEST_ASSERT(GLOB.chemical_reagents_list[recipe.reagent_to_brew], "[recipe.type] brews an unknown reagent [recipe.reagent_to_brew]")
		TEST_ASSERT(recipe.display_name, "[recipe.type] has no name")
		TEST_ASSERT(recipe.brew_time > 0 && recipe.brewed_amount > 0, "[recipe.type] has no time or amount")
		TEST_ASSERT(recipe.brewed_amount <= 300, "[recipe.type] brews more than a barrel holds")
		for(var/reagent_type in recipe.needed_reagents)
			TEST_ASSERT(GLOB.chemical_reagents_list[reagent_type], "[recipe.type] needs an unknown reagent [reagent_type]")
		if(recipe.pre_reqs)
			TEST_ASSERT(GLOB.chemical_reagents_list[recipe.pre_reqs], "[recipe.type] has an unknown previous stage [recipe.pre_reqs]")
	var/brewing_entries = 0
	for(var/list/entry as anything in get_cookbook_catalog())
		if(entry["method"] == "Browar")
			brewing_entries++
	TEST_ASSERT(brewing_entries == length(GLOB.brewing_recipes), "The PDA cookbook lists [brewing_entries] of [length(GLOB.brewing_recipes)] brewing recipes")

/// Warzenie: braki blokują start, start zużywa tylko potrzebne płyny, drugi etap zjada pierwszy, eksport ma cenę
/datum/unit_test/aquila_brewing_barrel

/datum/unit_test/aquila_brewing_barrel/Run()
	var/obj/structure/fermenting_barrel/barrel = allocate(/obj/structure/fermenting_barrel, run_loc_floor_bottom_left)
	barrel.selected_recipe = locate(/datum/brewing_recipe/rum) in GLOB.brewing_recipes
	TEST_ASSERT(barrel.selected_recipe, "No rum recipe")
	barrel.reagents.add_reagent(/datum/reagent/water, 150)
	barrel.reagents.add_reagent(/datum/reagent/consumable/sodiumchloride, 5)
	barrel.crop_units[/obj/item/food/grown/sugarcane] = 60
	TEST_ASSERT(!barrel.start_brewing(), "Rum started brewing without the 5 logs")
	for(var/i in 1 to 5)
		allocate(/obj/item/grown/log, barrel)
	TEST_ASSERT(barrel.start_brewing(), "Rum did not start with everything in the barrel: [jointext(barrel.missing_for_recipe(), ", ")]")
	TEST_ASSERT(abs(barrel.reagents.get_reagent_amount(/datum/reagent/water) - 30) < 0.1, "Starting the brew should use 120 of 150 water, [barrel.reagents.get_reagent_amount(/datum/reagent/water)] left")
	TEST_ASSERT(!length(barrel.contents), "The logs stayed in the barrel after starting")
	barrel.finish_brewing()
	TEST_ASSERT(barrel.reagents.get_reagent_amount(/datum/reagent/consumable/ethanol/rum) == 200, "The barrel holds [barrel.reagents.get_reagent_amount(/datum/reagent/consumable/ethanol/rum)] u of rum, expected 200 (barrel: [barrel.reagents.log_list()])")
	TEST_ASSERT(!barrel.brewing && !barrel.selected_recipe, "The barrel is still brewing after finishing")
	TEST_ASSERT(!barrel.reagents.has_reagent(/datum/reagent/consumable/ethanol/grog), "Leftover water reacted with the rum into grog")

	var/datum/export/large/fermenting_barrel/barrel_export = new
	TEST_ASSERT(barrel_export.get_cost(barrel) == 1000, "A barrel with 200 u of rum sells for [barrel_export.get_cost(barrel)], expected 1000 (half of Monke)")

	// Drugi etap: kahlua z rumu zjada cały rum
	barrel.reagents.del_reagent(/datum/reagent/water)
	barrel.selected_recipe = locate(/datum/brewing_recipe/kahlua) in GLOB.brewing_recipes
	barrel.reagents.add_reagent(/datum/reagent/consumable/sugar, 15)
	barrel.reagents.add_reagent(/datum/reagent/consumable/coffee, 60)
	TEST_ASSERT(barrel.start_brewing(), "Kahlua did not start on top of rum: [jointext(barrel.missing_for_recipe(), ", ")]")
	TEST_ASSERT(!barrel.reagents.has_reagent(/datum/reagent/consumable/ethanol/rum), "The second stage did not use up the rum")
	barrel.finish_brewing()
	TEST_ASSERT(barrel.reagents.get_reagent_amount(/datum/reagent/consumable/ethanol/kahlua) == 150, "Kahlua stage made [barrel.reagents.get_reagent_amount(/datum/reagent/consumable/ethanol/kahlua)] u")

	// Pusta beczka nie idzie na sprzedaż
	var/obj/structure/fermenting_barrel/empty_barrel = allocate(/obj/structure/fermenting_barrel, run_loc_floor_bottom_left)
	TEST_ASSERT(!barrel_export.applies_to(empty_barrel, EXPORT_CARGO), "An empty barrel would be sold")
	qdel(barrel_export)

#undef TEST_ASSERT
