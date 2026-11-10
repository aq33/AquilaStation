// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - kosz na śmieci z tg: cały kosz w jednym stanie (bez starej pokrywy skrzyni), otwarty i zamknięty mają grafikę
/datum/unit_test/aquila_tg_kosz

/datum/unit_test/aquila_tg_kosz/Run()
	var/obj/structure/closet/crate/bin/bin = allocate(/obj/structure/closet/crate/bin)
	bin.update_icon()
	TEST_ASSERT_EQUAL(bin.icon_state, "trashbin", "Zamknięty kosz")
	TEST_ASSERT(icon_exists(bin.icon, bin.icon_state), "Brak stanu [bin.icon_state]")
	for(var/mutable_appearance/overlay as anything in bin.overlays)
		TEST_ASSERT(overlay.icon_state != "trashbin_door", "Zamknięty kosz ma starą pokrywę skrzyni")
	bin.open()
	TEST_ASSERT_EQUAL(bin.icon_state, "trashbinopen", "Otwarty kosz")
	TEST_ASSERT(icon_exists(bin.icon, bin.icon_state), "Brak stanu [bin.icon_state]")
	TEST_ASSERT(icon_exists(bin.icon, "trashbin_animate"), "Brak animacji opróżniania kosza")

/// AQUILA - ekspres do kawy z tg: dzbanek w ekspresie pokazuje się jako pusty, pełny albo bluespace'owy
/datum/unit_test/aquila_tg_ekspres

/datum/unit_test/aquila_tg_ekspres/Run()
	var/obj/machinery/coffeemaker/maker = allocate(/obj/machinery/coffeemaker)
	var/obj/item/reagent_containers/glass/coffeepot/pot = allocate(/obj/item/reagent_containers/glass/coffeepot)
	maker.coffeepot = pot
	var/list/overlays = maker.overlay_checks()
	TEST_ASSERT("coffeemaker_pot_empty" in overlays, "Pusty dzbanek: [overlays.Join(", ")]")
	TEST_ASSERT(!("coffeemaker_pot" in overlays), "Został stary stan dzbanka")
	pot.reagents.add_reagent(/datum/reagent/consumable/coffee, 10)
	overlays = maker.overlay_checks()
	TEST_ASSERT("coffeemaker_pot_full" in overlays, "Pełny dzbanek: [overlays.Join(", ")]")
	var/obj/item/reagent_containers/glass/coffeepot/bluespace/bs_pot = allocate(/obj/item/reagent_containers/glass/coffeepot/bluespace)
	maker.coffeepot = bs_pot
	overlays = maker.overlay_checks()
	TEST_ASSERT("coffeemaker_pot_bluespace" in overlays, "Dzbanek bluespace: [overlays.Join(", ")]")
	for(var/state in overlays)
		TEST_ASSERT(icon_exists(maker.icon, state), "Brak stanu nakładki [state]")
	maker.coffeepot = null

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
