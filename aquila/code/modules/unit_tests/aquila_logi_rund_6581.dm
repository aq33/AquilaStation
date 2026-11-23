// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - runtime'y z rund 6574-6583: każdy przypadek wywołany tak jak w grze
/datum/unit_test/aquila_logi_rund_6581

/datum/unit_test/aquila_logi_rund_6581/Run()
	// Examine potrafi zwrócić sam tekst zamiast listy
	var/mob/living/carbon/human/viewer = allocate(/mob/living/carbon/human)
	var/obj/item/pen/pen = allocate(/obj/item/pen)
	var/html = viewer.aq_examine_html(pen, "To jest długopis.")
	TEST_ASSERT(findtext(html, "To jest długopis."), "Examine HTML from a string is [html]")
	TEST_ASSERT(viewer.aq_examine_html(pen, null) == "", "Examine returning null still drew a box")

	// Bez krwawienia has_status_effect() nie daje datumu
	TEST_ASSERT(viewer.get_bleed_rate() == 0, "Bleed rate without bleeding is [viewer.get_bleed_rate()]")

	// W stosie naleśników może leżeć ciasto bez stack_name
	var/obj/item/food/pancakes/stack = allocate(/obj/item/food/pancakes)
	var/obj/item/food/pastrybase/base = allocate(/obj/item/food/pastrybase)
	stack.update_snack_overlays(base)
	// Naleśnik z ciastem z craftingu położony na stos: na stos idą tylko naleśniki, ciasto zostaje w swoim naleśniku
	var/obj/item/food/pancakes/crafted = allocate(/obj/item/food/pancakes)
	var/obj/item/food/pancakes/nested = allocate(/obj/item/food/pancakes)
	base.forceMove(crafted)
	nested.forceMove(crafted)
	viewer.put_in_active_hand(crafted)
	stack.attackby(crafted, viewer)
	TEST_ASSERT(crafted.loc == stack && nested.loc == stack, "Stacking a pancake did not move it and its nested pancake onto the stack")
	TEST_ASSERT(base.loc == crafted, "The pastry base of a crafted pancake was moved into the stack (it is at [base.loc])")

	// Konsola myśliwców z filtrem „Only Occupied Ship”: konsola widzi myśliwce tylko z poziomów statku, a mapa testów
	// leży w rezerwacji, więc oba obiekty stoją na poziomie stacji
	var/turf/ship_turf = locate(1, 1, SSmapping.levels_by_trait(ZTRAIT_STATION)[1])
	var/obj/machinery/computer/ship/fighter_controller/console = allocate(/obj/machinery/computer/ship/fighter_controller, ship_turf)
	var/obj/structure/overmap/small_craft/fighter = allocate(/obj/structure/overmap/small_craft/combat/light, ship_turf)
	fighter.faction = console.faction
	fighter.name = "Test fighter 6581"
	fighter.operators = null
	var/list/data = console.ui_data(viewer)
	var/list/names = list()
	for(var/list/entry in data?["fighters"])
		names += entry["name"]
	var/hidden_when_empty = !(fighter.name in names)
	console.current_filters -= "Only Occupied Ship"
	data = console.ui_data(viewer)
	names = list()
	for(var/list/entry in data?["fighters"])
		names += entry["name"]
	fighter.operators = list()
	TEST_ASSERT(hidden_when_empty, "Fighter without operators passed the \"Only Occupied Ship\" filter")
	TEST_ASSERT(fighter.name in names, "The test fighter is not listed by the console at all, so the filter was not exercised")

#undef TEST_ASSERT
