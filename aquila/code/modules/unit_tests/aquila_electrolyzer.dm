// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - The electrolyzer splits water vapor into hydrogen and oxygen, on its cell when not wrenched down
/datum/unit_test/aquila_electrolyzer

/datum/unit_test/aquila_electrolyzer/Run()
	TEST_ASSERT(GLOB.gas_data.ids[GAS_H2], "Hydrogen is not registered with auxgm")
	TEST_ASSERT(GLOB.gas_data.fire_temperatures[GAS_H2], "Hydrogen is not a fuel")
	TEST_ASSERT(GLOB.ship_thruster_fuels[GAS_H2], "Hydrogen is not a ship thruster fuel")

	var/obj/machinery/electrolyzer/electrolyzer = allocate(/obj/machinery/electrolyzer)
	var/datum/gas_mixture/mix = new
	mix.set_moles(GAS_H2O, 10)
	mix.set_temperature(T20C)
	var/split = electrolyzer.electrolyze(mix)
	TEST_ASSERT(split == 1, "The electrolyzer split [split] moles of 10 instead of a tenth")
	TEST_ASSERT(mix.get_moles(GAS_H2O) == 9, "Water vapor was not used up")
	TEST_ASSERT(mix.get_moles(GAS_H2) == 1, "Electrolysis did not make one mole of hydrogen per mole of water")
	TEST_ASSERT(mix.get_moles(GAS_O2) == 0.5, "Electrolysis did not make half a mole of oxygen per mole of water")

	// A working electrolyzer on its cell drains the cell and changes the air on its tile
	var/turf/open/location = get_turf(electrolyzer)
	TEST_ASSERT(istype(location) && location.air, "The test turf has no air")
	var/datum/gas_mixture/original_air = location.air.copy()
	location.air.set_moles(GAS_H2O, 20)
	location.air.set_moles(GAS_H2, 0)
	electrolyzer.on = TRUE
	var/charge = electrolyzer.cell.charge
	electrolyzer.process_atmos()
	TEST_ASSERT(location.air.get_moles(GAS_H2) > 0, "A working electrolyzer made no hydrogen on its tile")
	TEST_ASSERT(electrolyzer.cell.charge < charge, "The electrolyzer worked without using its cell")
	electrolyzer.on = FALSE
	location.air.copy_from(original_air)

#undef TEST_ASSERT
