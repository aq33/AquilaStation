// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - SLIMECORE z Monkestation: sprzedaż na rynku daje punkty i przesuwa ceny
/datum/unit_test/aquila_slime_market

/datum/unit_test/aquila_slime_market/Run()
	var/datum/slime_market/market = new
	var/old_grey = market.prices[/obj/item/slime_extract/grey]
	var/old_gold = market.prices[/obj/item/slime_extract/gold]
	var/earned = market.sell(/obj/item/slime_extract/grey)
	TEST_ASSERT_EQUAL(earned, round(old_grey), "Sale did not pay the current price")
	TEST_ASSERT_EQUAL(market.points, earned, "Sale did not add the points")
	TEST_ASSERT(market.prices[/obj/item/slime_extract/grey] < old_grey, "Sold extract did not get cheaper")
	TEST_ASSERT(market.prices[/obj/item/slime_extract/gold] > old_gold, "Other extracts did not get more expensive")
	for(var/i in 1 to 300)
		market.sell(/obj/item/slime_extract/grey)
	TEST_ASSERT(market.get_price_ratio(/obj/item/slime_extract/grey) >= 0.1, "Price fell below 10% of the base price")
	STOP_PROCESSING(SSprocessing, market)
	qdel(market)

/// AQUILA - kompresor robi crossbreeda z jednego dorosłego szlama bazowego i dwóch dorosłych szlamów typu
/datum/unit_test/aquila_slime_compressor

/datum/unit_test/aquila_slime_compressor/Run()
	var/obj/machinery/slime_compressor/compressor = allocate(/obj/machinery/slime_compressor)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	compressor.set_machine_stat(compressor.machine_stat & ~NOPOWER)
	var/obj/item/slimecross/recipe = compressor.recipes["burning"]?["blue"]
	TEST_ASSERT(recipe, "No burning blue recipe in the compressor")
	TEST_ASSERT_EQUAL(compressor.effect_to_colour["burning"], "orange", "Burning crossbreeds should need orange slimes")
	compressor.set_recipe(recipe, "blue", "orange")

	var/mob/living/simple_animal/slime/baby = allocate(/mob/living/simple_animal/slime, run_loc_floor_bottom_left, "orange", FALSE)
	TEST_ASSERT(!compressor.try_insert(baby, user), "Compressor accepted a baby slime")
	var/mob/living/simple_animal/slime/wrong = allocate(/mob/living/simple_animal/slime, run_loc_floor_bottom_left, "grey", TRUE)
	TEST_ASSERT(!compressor.try_insert(wrong, user), "Compressor accepted a slime the recipe does not need")

	TEST_ASSERT(compressor.try_insert(allocate(/mob/living/simple_animal/slime, run_loc_floor_bottom_left, "blue", TRUE), user), "Compressor refused the base slime")
	TEST_ASSERT(compressor.try_insert(allocate(/mob/living/simple_animal/slime, run_loc_floor_bottom_left, "orange", TRUE), user), "Compressor refused the first cross slime")
	TEST_ASSERT(!compressor.active, "Compressor started with only one cross slime")
	TEST_ASSERT(compressor.try_insert(allocate(/mob/living/simple_animal/slime, run_loc_floor_bottom_left, "orange", TRUE), user), "Compressor refused the second cross slime")
	TEST_ASSERT(compressor.active, "Compressor did not start with all slimes inside")

	compressor.bonus_extract_chance = 0
	compressor.finish_compressing()
	TEST_ASSERT(locate(recipe) in compressor.drop_location(), "Compressor did not make the crossbreed")
	TEST_ASSERT(!(locate(/mob/living/simple_animal/slime) in compressor), "Slimes stayed inside after compressing")
	for(var/obj/item/slimecross/cross in compressor.drop_location())
		qdel(cross)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
