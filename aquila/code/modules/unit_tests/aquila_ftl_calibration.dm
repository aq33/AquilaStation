// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - kalibracja pylonów FTL: dopasowanie fali przyspiesza ładowanie i zmniejsza szansę wypadku
/datum/unit_test/ftl_calibration
	var/obj/machinery/atmospherics/components/binary/drive_pylon/pylon
	var/obj/machinery/computer/ship/ftl_core/core

/datum/unit_test/ftl_calibration/Run()
	pylon = new(run_loc_floor_bottom_left)
	core = new(run_loc_floor_top_right)
	core.pylons = list(pylon)
	pylon.pylon_state = PYLON_STATE_ACTIVE

	// Idealne dopasowanie
	pylon.cal_target_freq = 4
	pylon.cal_target_phase = 90
	pylon.cal_freq = 4
	pylon.cal_phase = 90
	TEST_ASSERT(pylon.calibration_match() == 1, "A perfectly tuned pylon isn't fully matched")
	TEST_ASSERT(core.calibration_quality() == 1, "A perfectly tuned drive doesn't have full calibration")
	TEST_ASSERT(core.calibration_mishap_chance() == 0, "A perfectly tuned drive can still misjump")
	TEST_ASSERT(abs(core.calibration_charge_mult() - 1.4) < 0.001, "A perfectly tuned drive doesn't charge faster")

	// Faza przez zero: 355° i 5° to prawie to samo
	pylon.cal_target_phase = 355
	pylon.cal_phase = 5
	TEST_ASSERT(pylon.calibration_match() > 0.8, "Phase matching doesn't wrap around 360 degrees")

	// Rozstrojony pylon: zero dopasowania, wolne ładowanie, najwyższa szansa wypadku
	pylon.cal_freq = 8
	pylon.cal_target_freq = 1
	TEST_ASSERT(pylon.calibration_match() == 0, "A badly detuned pylon still matches")
	TEST_ASSERT(abs(core.calibration_charge_mult() - 0.6) < 0.001, "A detuned drive doesn't charge slower")
	TEST_ASSERT(core.calibration_mishap_chance() == 30, "A detuned drive doesn't have the highest misjump chance")

	// Nieaktywny pylon się nie liczy
	pylon.pylon_state = PYLON_STATE_OFFLINE
	TEST_ASSERT(core.calibration_quality() == 0, "An offline pylon counts towards calibration")

	// Fala celu dryfuje w granicach
	for(var/i in 1 to 200)
		pylon.drift_calibration()
	TEST_ASSERT(pylon.cal_target_freq >= 1 && pylon.cal_target_freq <= 8, "The target wave drifted out of range")

/datum/unit_test/ftl_calibration/Destroy()
	// Najpierw pylon (sam wypisuje się z rdzenia), potem rdzeń
	QDEL_NULL(pylon)
	QDEL_NULL(core)
	return ..()

#undef TEST_ASSERT
