// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - lag switches (tgstation#59717, #62999): przełączniki działają pojedynczo i wszystkie naraz, automat rusza tylko swoje
/datum/unit_test/aquila_lag_switch

/datum/unit_test/aquila_lag_switch/Run()
	TEST_ASSERT(SSlag_switch.initialized, "SSlag_switch is not initialized")
	for(var/i in 1 to MEASURES_AMOUNT)
		TEST_ASSERT(SSlag_switch.measures[i] == FALSE, "Lag switch [i] is on at round start")

	TEST_ASSERT(SSlag_switch.set_measure(DISABLE_FOOTSTEPS, TRUE), "Could not enable footsteps switch")
	TEST_ASSERT(SSlag_switch.measures[DISABLE_FOOTSTEPS], "Footsteps switch did not turn on")
	TEST_ASSERT(!SSlag_switch.measures[DISABLE_RUNECHAT], "Enabling one switch changed another")

	SSlag_switch.set_all_measures(FALSE)
	SSlag_switch.set_all_measures(TRUE, automatic = TRUE)
	for(var/i in 1 to MEASURES_AMOUNT)
		var/expected = (i in SSlag_switch.auto_measures)
		TEST_ASSERT(!!SSlag_switch.measures[i] == expected, "Automatic activation set switch [i] to [SSlag_switch.measures[i]]")

	SSlag_switch.set_all_measures(TRUE)
	for(var/i in 1 to MEASURES_AMOUNT)
		TEST_ASSERT(SSlag_switch.measures[i], "Switch [i] stayed off after enabling all")

	SSlag_switch.set_all_measures(FALSE)
	for(var/i in 1 to MEASURES_AMOUNT)
		TEST_ASSERT(!SSlag_switch.measures[i], "Switch [i] stayed on after disabling all")

/datum/unit_test/aquila_lag_switch/Destroy()
	SSlag_switch.set_all_measures(FALSE)
	return ..()

#undef TEST_ASSERT
