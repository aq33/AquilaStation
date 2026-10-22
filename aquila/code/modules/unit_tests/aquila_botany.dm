// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - botanika z Bee: odczynnik chwastobójczy w tacy zbija poziom chwastów (u nas on_new() nie woła się dla odczynników bez danych)
/datum/unit_test/aquila_botany_weedkiller

/datum/unit_test/aquila_botany_weedkiller/Run()
	var/obj/item/plant_tray/tray = allocate(/obj/item/plant_tray, run_loc_floor_bottom_left)
	var/datum/component/planter/planter = tray.GetComponent(/datum/component/planter)
	TEST_ASSERT(planter, "Taca nie ma komponentu planter")
	planter.set_substrate(/datum/plant_subtrate/dirt)
	planter.weed_level = 5
	tray.reagents.add_reagent(/datum/reagent/toxin/plantbgone, 10)
	planter.process(1)
	TEST_ASSERT(planter.weed_level < 5, "Plant-B-Gone nie zmniejszył chwastów (poziom [planter.weed_level])")

#undef TEST_ASSERT
