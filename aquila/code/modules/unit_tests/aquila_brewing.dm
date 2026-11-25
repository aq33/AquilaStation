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

/// Poprawki z review: start bez przepisu, przepełnienie beczki, wysypany owoc nie fermentuje
/datum/unit_test/aquila_brewing_barrel_guards

/datum/unit_test/aquila_brewing_barrel_guards/Run()
	var/obj/structure/fermenting_barrel/barrel = allocate(/obj/structure/fermenting_barrel, run_loc_floor_bottom_left)
	TEST_ASSERT(!barrel.start_brewing(), "A barrel without a recipe started brewing")

	// Jasne piwo: 60 j. wody, 300 j. trunku. 100 j. wody zostawia 40 j., więc trunek się nie mieści
	barrel.selected_recipe = locate(/datum/brewing_recipe/light_beer) in GLOB.brewing_recipes
	barrel.crop_units[/obj/item/food/grown/wheat] = 40
	barrel.crop_units[/obj/item/food/grown/poppy] = 5
	barrel.reagents.add_reagent(/datum/reagent/water, 100)
	TEST_ASSERT(!barrel.start_brewing(), "Light beer started with 40 u of leftover water, so 300 u would not fit")
	barrel.reagents.remove_reagent(/datum/reagent/water, 40)
	var/mob/living/carbon/human/brewer = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	barrel.attack_hand(brewer) // otwarta beczka, jak po wlaniu wody
	TEST_ASSERT(barrel.open, "The barrel did not open before brewing")
	TEST_ASSERT(barrel.start_brewing(), "Light beer did not start with exactly 60 u of water")
	TEST_ASSERT(!barrel.open, "The barrel stayed open while brewing")
	barrel.attack_hand(brewer)
	TEST_ASSERT(!barrel.open, "The barrel opened while brewing")
	// Zlewka sprawdza is_refillable() przed wlaniem, więc zamknięta beczka nie przyjmie płynu
	TEST_ASSERT(!barrel.is_refillable(), "Liquid could still be poured into the barrel while brewing")
	barrel.finish_brewing()
	TEST_ASSERT(barrel.reagents.get_reagent_amount(/datum/reagent/consumable/ethanol/beer/light) == 300, "Light beer did not make the full 300 u")

	// Owoc wrzucony bez przepisu, potem wysypany: zaplanowana fermentacja go nie zużywa
	var/obj/structure/fermenting_barrel/wine_barrel = allocate(/obj/structure/fermenting_barrel, run_loc_floor_bottom_left)
	var/obj/item/food/grown/apple/apple = allocate(/obj/item/food/grown/apple, wine_barrel)
	var/first_insertion = wine_barrel.add_wine_fruit(apple)
	wine_barrel.drop_brewing_ingredients()
	wine_barrel.ferment_inserted(apple, first_insertion)
	TEST_ASSERT(!QDELETED(apple), "A fruit dropped out of the barrel was still turned into wine")
	TEST_ASSERT(!wine_barrel.reagents.total_volume, "A dropped fruit added wine to the barrel")

	// Ten sam owoc wrzucony ponownie bez przepisu: timer ze starego wrzucenia nie fermentuje go,
	// nawet gdy od nowego wrzucenia minął już najkrótszy czas fermentacji (stary timer odpala później niż 80, a wcześniej niż nowy)
	apple.forceMove(wine_barrel)
	var/second_insertion = wine_barrel.add_wine_fruit(apple)
	wine_barrel.ferment_inserted(apple, first_insertion)
	TEST_ASSERT(!QDELETED(apple), "A fruit put back in fermented from the timer of its earlier insertion")
	wine_barrel.ferment_inserted(apple, second_insertion)
	TEST_ASSERT(QDELETED(apple), "A fruit did not ferment from the timer of its last insertion")
	TEST_ASSERT(wine_barrel.reagents.total_volume, "The fermented fruit added no wine")

#undef TEST_ASSERT
