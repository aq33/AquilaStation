// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - Methane sources: swamp gas bubbles on jungle mudlands and the methane gas giant, methane as a ship thruster fuel
/datum/unit_test/aquila_methane

/datum/unit_test/aquila_methane/Run()
	TEST_ASSERT(GLOB.gas_data.ids[GAS_METHANE], "Methane is not registered with auxgm")
	TEST_ASSERT(GLOB.gas_data.fire_temperatures[GAS_METHANE], "Methane is not a fuel")
	TEST_ASSERT(GLOB.ship_thruster_fuels[GAS_METHANE], "Methane is not a ship thruster fuel")

	// A swamp gas bubble lets out methane on its tile and stops at the local cap
	var/obj/structure/swamp_gas/bubble = allocate(/obj/structure/swamp_gas)
	var/turf/open/location = get_turf(bubble)
	TEST_ASSERT(istype(location) && location.air, "The test turf has no air")
	var/datum/gas_mixture/original_air = location.air.copy()
	location.air.set_moles(GAS_METHANE, 0)
	TEST_ASSERT(bubble.release_gas(), "The swamp gas bubble let nothing out")
	TEST_ASSERT(location.air.get_moles(GAS_METHANE) > 0, "The swamp gas bubble let out no methane")
	location.air.set_moles(GAS_METHANE, 1000)
	TEST_ASSERT(!bubble.release_gas(), "The swamp gas bubble went past its local cap")
	location.air.copy_from(original_air)

	// Jungle mudlands spawn the bubbles, the methane giant is a scenery gas giant full of methane
	var/datum/planet_biome/mudlands = new /datum/planet_biome/jungle/mudlands
	TEST_ASSERT(mudlands.feature_spawn_list[/obj/structure/swamp_gas], "Jungle mudlands do not spawn swamp gas bubbles")
	var/datum/planet_type/gas_giant/methane/giant = GLOB.planet_type_prototypes[/datum/planet_type/gas_giant/methane]
	TEST_ASSERT(giant?.scenery, "The methane gas giant is not a scenery planet")
	TEST_ASSERT(!length(giant.fixed_systems), "The methane gas giant took over the fixed systems of the gas giant")
	var/turf/open/chasm/gas_giant/methane/abyss = /turf/open/chasm/gas_giant/methane
	TEST_ASSERT(findtext(initial(abyss.initial_gas_mix), "[GAS_METHANE]="), "The methane gas giant has no methane in its air")

#undef TEST_ASSERT
