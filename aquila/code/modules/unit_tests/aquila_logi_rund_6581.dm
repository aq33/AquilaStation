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

	// Bez krwawienia has_status_effect() nie daje datumu
	TEST_ASSERT(viewer.get_bleed_rate() == 0, "Bleed rate without bleeding is [viewer.get_bleed_rate()]")

	// W stosie naleśników może leżeć ciasto bez stack_name
	var/obj/item/food/pancakes/stack = allocate(/obj/item/food/pancakes)
	var/obj/item/food/pastrybase/base = allocate(/obj/item/food/pastrybase)
	stack.update_snack_overlays(base)

	// Konsola myśliwców z filtrem „Only Occupied Ship”
	var/obj/machinery/computer/ship/fighter_controller/console = allocate(/obj/machinery/computer/ship/fighter_controller)
	LAZYADD(console.current_filters, "Only Occupied Ship")
	var/list/data = console.ui_data(viewer)
	TEST_ASSERT(islist(data?["fighters"]), "Fighter console returned no fighter list")

#undef TEST_ASSERT
