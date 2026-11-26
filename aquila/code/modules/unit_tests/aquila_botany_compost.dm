// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_NOTNULL(a, reason) if (isnull(a)) { return Fail("Expected non-null value: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - kompostownik: 5 plonów po przyspieszeniu rozkłada się w nawóz, a z kompostu wychodzi worek ziemi
/datum/unit_test/aquila_compost_bin

/datum/unit_test/aquila_compost_bin/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/obj/structure/compost_bin/bin = allocate(/obj/structure/compost_bin, origin)
	var/mob/living/carbon/human/gardener = allocate(/mob/living/carbon/human, get_step(origin, EAST))

// Pierwszy plon wrzucony ręką jak przez gracza, reszta prosto do środka
	var/obj/item/food/grown/tomato/first = allocate(/obj/item/food/grown/tomato, get_turf(gardener))
	gardener.put_in_active_hand(first)
	bin.attackby(first, gardener)
	TEST_ASSERT_EQUAL(first.loc, bin, "Plon wrzucony ręką nie trafił do kompostownika")
	for(var/i in 1 to 4)
		var/obj/item/food/grown/tomato/tomato = allocate(/obj/item/food/grown/tomato, origin)
		tomato.forceMove(bin)
	TEST_ASSERT_EQUAL(bin.get_item_count(), 5, "W kompostowniku powinno być 5 plonów")

// Nie-jedzenie nie wchodzi
	var/obj/item/wrench/wrench = allocate(/obj/item/wrench, get_turf(gardener))
	TEST_ASSERT(!bin.is_compostable(wrench), "Klucz uznany za kompostowalny")

	bin.start_composting()
	COOLDOWN_RESET(bin, compost_cooldown) // przyspieszenie: cykl rozkładu od razu
	bin.process(2)
	TEST_ASSERT_EQUAL(bin.get_item_count(), 0, "Plony nie rozłożyły się w jednym cyklu")
	var/compost = bin.reagents.get_reagent_amount(bin.reagent_id)
	TEST_ASSERT(compost >= 10, "5 plonów dało tylko [compost] j. kompostu")

// Worek ziemi zużywa kompost
	bin.reagents.add_reagent(bin.reagent_id, 40)
	var/before = bin.reagents.get_reagent_amount(bin.reagent_id)
	var/obj/item/substrate_bag/bag = bin.take_substrate_bag(origin)
	TEST_ASSERT_NOTNULL(bag, "Kompostownik nie dał worka ziemi mimo [before] j. kompostu")
	TEST_ASSERT(istype(bag, /obj/item/substrate_bag/dirt), "Kompostownik dał [bag.type] zamiast worka ziemi")
	TEST_ASSERT(bin.reagents.get_reagent_amount(bin.reagent_id) < before, "Worek ziemi nie zużył kompostu")
	qdel(bag)

	bin.reagents.clear_reagents()
	TEST_ASSERT(isnull(bin.take_substrate_bag(origin)), "Kompostownik dał worek ziemi bez kompostu")

// Regresja: przy prawie pełnym zbiorniku (299/300) plon zostaje w skrzyni, a kompost nie przepada
	bin.reagents.add_reagent(bin.reagent_id, bin.reagents.maximum_volume - 1)
	var/obj/item/food/grown/tomato/late = allocate(/obj/item/food/grown/tomato, origin)
	late.forceMove(bin)
	COOLDOWN_RESET(bin, compost_cooldown)
	bin.process(2)
	TEST_ASSERT_EQUAL(late.loc, bin, "Plon zniknął, choć jego kompost nie mieścił się w zbiorniku")
	TEST_ASSERT_EQUAL(bin.reagents.total_volume, bin.reagents.maximum_volume - 1, "Zawartość zbiornika zmieniła się mimo braku miejsca")
// Po opróżnieniu zbiornika ten sam plon się rozkłada
	bin.reagents.clear_reagents()
	COOLDOWN_RESET(bin, compost_cooldown)
	bin.process(2)
	TEST_ASSERT(QDELETED(late) || late.loc != bin, "Plon nie rozłożył się po opróżnieniu zbiornika")
	TEST_ASSERT(bin.reagents.get_reagent_amount(bin.reagent_id) > 0, "Po opróżnieniu zbiornika plon nie dał kompostu")


#undef TEST_ASSERT
#undef TEST_ASSERT_NOTNULL
#undef TEST_ASSERT_EQUAL
