// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define FREZON_CLOSE(a, b) (abs((a) - (b)) <= max(0.0001, abs(b) * 0.001))

/// AQUILA - Frezon (SS14): made from oxygen and tritium in the cold with nitrogen as a catalyst, cools by turning nitrogen into N2O.
/// The numbers are the SS14 formulas worked out by hand.
/datum/unit_test/aquila_frezon

/datum/unit_test/aquila_frezon/Run()
	TEST_ASSERT(GLOB.gas_data.ids[GAS_FREZON], "Frezon is not registered with auxgm")

	// Production at 50 K: efficiency 50/73.15, the catalyst lets through all 100 moles of oxygen, so 2 moles of tritium react
	var/datum/gas_mixture/cold = new
	cold.set_moles(GAS_O2, 100)
	cold.set_moles(GAS_N2, 10)
	cold.set_moles(GAS_TRITIUM, 5)
	cold.set_temperature(50)
	var/datum/gas_reaction/frezon_production/production = new
	TEST_ASSERT(production.react(cold, null) == REACTING, "Frezon production did not react")
	var/efficiency = 50 / 73.15
	var/oxygen_conversion = 100 / 50 // 2 moles of tritium times 50 oxygen, a fiftieth of it per tick
	var/tritium_conversion = 2 / 50
	var/total = oxygen_conversion + tritium_conversion
	TEST_ASSERT(FREZON_CLOSE(cold.get_moles(GAS_FREZON), total * efficiency), "Production made [cold.get_moles(GAS_FREZON)] frezon, expected [total * efficiency]")
	TEST_ASSERT(FREZON_CLOSE(cold.get_moles(GAS_O2), 100 - oxygen_conversion), "Production used the wrong amount of oxygen")
	TEST_ASSERT(FREZON_CLOSE(cold.get_moles(GAS_TRITIUM), 5 - tritium_conversion), "Production used the wrong amount of tritium")
	TEST_ASSERT(FREZON_CLOSE(cold.get_moles(GAS_N2), 10 + total * (1 - efficiency)), "The lost part did not come back as nitrogen")

	// auxmos runs it below 73.15 K and not above
	var/datum/gas_mixture/cold_pass = new
	cold_pass.set_moles(GAS_O2, 100)
	cold_pass.set_moles(GAS_N2, 10)
	cold_pass.set_moles(GAS_TRITIUM, 5)
	cold_pass.set_temperature(50)
	cold_pass.react()
	TEST_ASSERT(cold_pass.get_moles(GAS_FREZON) > 0, "auxmos did not run frezon production at 50 K")
	var/datum/gas_mixture/warm_pass = new
	warm_pass.set_moles(GAS_O2, 100)
	warm_pass.set_moles(GAS_N2, 10)
	warm_pass.set_moles(GAS_TRITIUM, 5)
	warm_pass.set_temperature(100)
	warm_pass.react()
	TEST_ASSERT(!warm_pass.get_moles(GAS_FREZON), "Frezon was made above 73.15 K")

	// Cooling at room temperature: a share of the frezon and five times as much nitrogen turn into N2O and take 600 kJ per mole
	var/datum/gas_mixture/room = new
	room.set_moles(GAS_FREZON, 1)
	room.set_moles(GAS_N2, 10)
	room.set_temperature(293.15)
	var/list/heats = GLOB.gas_data.specific_heats
	var/old_capacity = heats[GAS_FREZON] * 1 + heats[GAS_N2] * 10
	var/datum/gas_reaction/frezon_coolant/coolant = new
	TEST_ASSERT(coolant.react(room, null) == REACTING, "Frezon cooling did not react")
	var/burn_rate = (293.15 - 23.15) / (373.15 - 23.15) / 20
	var/new_capacity = heats[GAS_FREZON] * (1 - burn_rate) + heats[GAS_N2] * (10 - burn_rate * 5) + heats[GAS_NITROUS] * burn_rate * 6
	var/expected_temperature = (293.15 * old_capacity - burn_rate * 600000) / new_capacity
	TEST_ASSERT(FREZON_CLOSE(room.get_moles(GAS_NITROUS), burn_rate * 6), "Cooling made the wrong amount of N2O")
	TEST_ASSERT(FREZON_CLOSE(room.return_temperature(), expected_temperature), "Cooling left [room.return_temperature()] K, expected [expected_temperature] K")
	TEST_ASSERT(room.return_temperature() < 293.15, "Frezon did not cool the mix")

	// auxmos runs the cooling on its own too
	var/datum/gas_mixture/room_pass = new
	room_pass.set_moles(GAS_FREZON, 1)
	room_pass.set_moles(GAS_N2, 10)
	room_pass.set_temperature(293.15)
	room_pass.react()
	TEST_ASSERT(room_pass.return_temperature() < 293.15, "auxmos did not run frezon cooling")

#undef FREZON_CLOSE
#undef TEST_ASSERT
