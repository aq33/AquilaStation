// AQUILA - test złoża gazu i ekstraktora (planets/drill/gas_vein.dm, gas_extractor.dm): ekstraktor na złożu tłoczy gaz
// do rury z sieci albo z ogniwa, bez prądu nie, staje przy 4500 kPa, wyczerpane złoże się zapada, a wiertło rudy
// złoża nie bierze. Cykle wywołuje wprost (process(2) to jeden cykl SSmachines), bez czekania na czas gry.

#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/datum/unit_test/aquila_gas_extractor

/datum/unit_test/aquila_gas_extractor/Run()
	var/turf/T = run_loc_floor_bottom_left
	var/obj/structure/vein/gas/lava/vein = allocate(/obj/structure/vein/gas/lava)
	var/start_moles = vein.remaining_moles()
	TEST_ASSERT(start_moles >= 9000, "Złoże wylosowało za mało gazu: [start_moles]")
	TEST_ASSERT(vein.reserve.get_moles(GAS_PLASMA) > 0, "Złoże wulkaniczne nie ma plazmy")
	TEST_ASSERT(!length(vein.vein_contents), "Złoże gazu wylosowało rudy")

	var/obj/machinery/atmospherics/components/unary/gas_extractor/extractor = allocate(/obj/machinery/atmospherics/components/unary/gas_extractor)
	extractor.on_construction()
	TEST_ASSERT(extractor.our_vein == vein && vein.our_extractor == extractor, "Ekstraktor nie przypiął się do złoża pod sobą")
	TEST_ASSERT(!extractor.cell, "Ekstraktor z płytki ma ogniwo")
	var/datum/gas_mixture/air = extractor.airs[1]

	// Bez prądu: obszar bez zasilania i bez ogniwa
	var/area/test_area = get_area(T)
	var/old_requires_power = test_area.requires_power
	var/old_power_environ = test_area.power_environ
	test_area.requires_power = TRUE
	test_area.power_environ = FALSE
	extractor.on = TRUE
	extractor.process(2)
	var/unpowered_moles = air.total_moles()
	var/unpowered_reserve = vein.remaining_moles()
	var/unpowered_extracting = extractor.extracting

	// Z ogniwa: jeden cykl to 50 mol/s przez 2 s, złoże maleje, fauna się budzi
	extractor.cell = new /obj/item/stock_parts/cell/high(extractor)
	var/charge_before = extractor.cell.charge
	extractor.process(2)
	var/cell_moles = air.total_moles()
	var/cell_reserve = vein.remaining_moles()
	var/cell_used = charge_before - extractor.cell.charge
	var/cell_spawning = vein.currently_spawning
	test_area.requires_power = old_requires_power
	test_area.power_environ = old_power_environ

	TEST_ASSERT(unpowered_moles == 0 && unpowered_reserve == start_moles && !unpowered_extracting, "Ekstraktor pracował bez prądu: [unpowered_moles] mol w rurze")
	TEST_ASSERT(abs(cell_moles - 100) < 0.5, "Cykl z ogniwa dał [cell_moles] mol zamiast 100")
	TEST_ASSERT(abs((start_moles - cell_reserve) - cell_moles) < 0.5, "Gaz w rurze nie ubył ze złoża")
	TEST_ASSERT(air.get_moles(GAS_PLASMA) > 0, "W rurze nie ma plazmy ze złoża")
	TEST_ASSERT(cell_used > 0, "Praca z ogniwa nie zużyła ładunku")
	TEST_ASSERT(extractor.extracting && cell_spawning, "Pracujący ekstraktor nie budzi fauny złoża")
	TEST_ASSERT(vein.get_working_machine() == extractor, "Złoże nie widzi pracującego ekstraktora")

	// Z sieci obszaru (pokój testowy jest zasilany): ogniwo nietknięte, gaz dalej płynie
	var/charge_grid = extractor.cell.charge
	extractor.process(2)
	TEST_ASSERT(air.total_moles() > cell_moles, "Ekstraktor nie pracuje z sieci")
	TEST_ASSERT(extractor.cell.charge == charge_grid, "Ekstraktor brał z ogniwa mimo zasilania z sieci")

	// Pełna rura: staje przy 4500 kPa i nie budzi fauny
	for(var/i in 1 to 20)
		extractor.process(2)
	TEST_ASSERT(air.return_pressure() <= extractor.target_pressure + 1, "Ciśnienie przekroczyło limit: [air.return_pressure()] kPa")
	TEST_ASSERT(air.return_pressure() >= extractor.target_pressure - 1, "Ekstraktor nie dobił do limitu: [air.return_pressure()] kPa")
	TEST_ASSERT(!extractor.extracting && !vein.currently_spawning, "Ekstraktor przy pełnej rurze dalej wydobywa")

	// Wiertło rudy nie staje na złożu gazu
	var/obj/machinery/drill/drill = allocate(/obj/machinery/drill)
	var/obj/item/wrench/wrench = allocate(/obj/item/wrench)
	var/mob/living/carbon/human/tester = allocate(/mob/living/carbon/human)
	drill.wrench_act_drill(tester, wrench)
	TEST_ASSERT(!drill.anchored && !drill.our_vein, "Wiertło rudy przypięło się do złoża gazu")

	// Wyczerpanie: złoże się zapada, ekstraktor staje i zostaje bez złoża
	air.remove(air.total_moles())
	vein.reserve.remove(vein.remaining_moles() - 10)
	extractor.process(2)
	TEST_ASSERT(QDELETED(vein), "Wyczerpane złoże się nie zapadło")
	TEST_ASSERT(!extractor.on && !extractor.extracting && !extractor.our_vein, "Ekstraktor po wyczerpaniu złoża dalej na nim pracuje")
	TEST_ASSERT(abs(air.total_moles() - 10) < 0.5, "Resztka złoża nie trafiła do rury")

#undef TEST_ASSERT
