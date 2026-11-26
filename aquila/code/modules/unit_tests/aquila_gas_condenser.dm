// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - The gas condenser turns gases with a chemistry counterpart into reagents and leaves the rest in the pipe
/datum/unit_test/aquila_gas_condenser

/datum/unit_test/aquila_gas_condenser/Run()
	for(var/gas_id in GLOB.gas_condenser_reagents)
		TEST_ASSERT(GLOB.gas_data.ids[gas_id], "The condenser maps unregistered gas [gas_id]")
		TEST_ASSERT(ispath(GLOB.gas_condenser_reagents[gas_id], /datum/reagent), "The condenser maps [gas_id] to [GLOB.gas_condenser_reagents[gas_id]], which is not a reagent")

	var/obj/machinery/atmospherics/components/unary/gas_condenser/condenser = allocate(/obj/machinery/atmospherics/components/unary/gas_condenser)
	TEST_ASSERT(length(condenser.GetComponents(/datum/component/plumbing/gas_condenser)) == 1, "The condenser has no plumbing output")

	// Frezon becomes the frezon reagent, tritium (no reagent) stays in the pipe
	var/datum/gas_mixture/air = condenser.airs[1]
	air.set_moles(GAS_FREZON, 100)
	air.set_moles(GAS_TRITIUM, 100)
	air.set_temperature(T20C)
	var/made = condenser.condense(air, 1)
	TEST_ASSERT(made > 0, "The condenser made no liquid from frezon")
	var/frezon = condenser.reagents.get_reagent_amount(/datum/reagent/frezon)
	TEST_ASSERT(abs(frezon - made) < 0.01, "The condenser made [made] u but the tank holds [frezon] u of frezon")
	TEST_ASSERT(abs(air.get_moles(GAS_FREZON) - (100 - frezon / condenser.moles_to_reagent)) < 0.01, "Frezon left in the pipe does not match the liquid made (0.2137 u per mole)")
	TEST_ASSERT(abs(air.get_moles(GAS_TRITIUM) - 100) < 0.01, "Tritium, which has no reagent, did not stay in the pipe")

	// The amount per tick follows the power: twice the time, twice the gas
	condenser.reagents.clear_reagents()
	air.set_moles(GAS_FREZON, 100)
	air.set_moles(GAS_TRITIUM, 100)
	var/made_double = condenser.condense(air, 2)
	TEST_ASSERT(made_double > made * 1.5, "Twice the work time condensed [made_double] u instead of about twice [made] u")

	// A full tank condenses nothing and gives the gas back
	condenser.reagents.add_reagent(/datum/reagent/water, condenser.reagents.maximum_volume - condenser.reagents.total_volume)
	var/frezon_moles = air.get_moles(GAS_FREZON)
	TEST_ASSERT(condenser.condense(air, 1) == 0, "A full condenser still made liquid")
	TEST_ASSERT(abs(air.get_moles(GAS_FREZON) - frezon_moles) < 0.01, "A full condenser lost gas")

	// A powered, switched on condenser works from its pipe in process_atmos, a switched off one does not
	condenser.reagents.clear_reagents()
	air.set_moles(GAS_H2O, 100)
	condenser.set_on(FALSE)
	condenser.process_atmos(1)
	TEST_ASSERT(!condenser.reagents.total_volume, "A switched off condenser made liquid")
	condenser.set_on(TRUE)
	condenser.process_atmos(1)
	TEST_ASSERT(condenser.reagents.get_reagent_amount(/datum/reagent/water) > 0, "A switched on condenser made no water from water vapor")
	condenser.set_on(FALSE)

#undef TEST_ASSERT
