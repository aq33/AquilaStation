// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - upieczone, zgrillowane albo podgrzane jedzenie ma reagenty surowca, a nie swoje + surowca (surowy płat 8u dawał stek 16u)
/datum/unit_test/aquila_food_cooking_reagents

/datum/unit_test/aquila_food_cooking_reagents/Run()
	var/turf/cook_turf = run_loc_floor_bottom_left

	// Grill
	var/obj/item/food/meat/slab/slab = allocate(/obj/item/food/meat/slab, cook_turf)
	var/raw_volume = slab.reagents.total_volume
	TEST_ASSERT(raw_volume > 0, "Surowy płat mięsa nie ma reagentów")
	var/datum/component/grillable/grillable = slab.GetComponent(/datum/component/grillable)
	TEST_ASSERT(grillable, "Płat mięsa nie ma komponentu grillable")
	grillable.FinishGrilling(cook_turf)
	var/obj/item/food/meat/steak/steak = locate(/obj/item/food/meat/steak) in cook_turf
	TEST_ASSERT(steak, "Grillowanie płata nie dało steku")
	var/steak_volume = steak.reagents.total_volume
	qdel(steak)
	TEST_ASSERT_EQUAL(steak_volume, raw_volume, "Stek z grilla ma inną ilość reagentów niż surowy płat")

	// Mikrofalówka
	var/obj/item/food/meat/rawcrab/raw_crab = allocate(/obj/item/food/meat/rawcrab, cook_turf)
	raw_volume = raw_crab.reagents.total_volume
	SEND_SIGNAL(raw_crab, COMSIG_ITEM_MICROWAVE_ACT, null)
	var/obj/item/food/meat/crab/crab = locate(/obj/item/food/meat/crab) in cook_turf
	TEST_ASSERT(crab, "Mikrofalówka nie zrobiła z surowego kraba mięsa kraba")
	var/crab_volume = crab.reagents.total_volume
	qdel(crab)
	TEST_ASSERT_EQUAL(crab_volume, raw_volume, "Krab z mikrofalówki ma inną ilość reagentów niż surowy")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
