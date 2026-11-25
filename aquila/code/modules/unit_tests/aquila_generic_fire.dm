// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define FIRE_CLOSE(a, b) (abs((a) - (b)) <= max(0.001, abs(b) * 0.005))

/// AQUILA - Gas fires burn the same in DM (libauxmos.so on the server and CI) and in Rust (auxmos.dll with citadel_reactions).
/// Every case is checked against the same hand calculation: oxidizer and fuel shares, FIRE_MAXIMUM_BURN_RATE and Hess's law with the products.
/datum/unit_test/aquila_generic_fire

/// One fuel burning in oxygen, calculated by hand. Returns gas id -> moles left, plus "temp".
/datum/unit_test/aquila_generic_fire/proc/expected_fire(fuel, fuel_moles, oxygen_moles, temperature)
	var/datum/auxgm/data = GLOB.gas_data
	var/datum/gas/fuel_datum = data.datums[fuel]
	var/datum/gas/oxygen_datum = data.datums[GAS_O2]
	var/oxygen_share = oxygen_moles * max(0, 1 - oxygen_datum.oxidation_temperature / temperature)
	var/oxidation_power = oxygen_share * oxygen_datum.oxidation_rate
	var/fuel_share = fuel_moles * max(0, 1 - fuel_datum.fire_temperature / temperature)
	var/ratio = oxidation_power / (fuel_share / fuel_datum.fire_burn_rate)
	if(ratio > 1)
		oxygen_share /= ratio
	else
		fuel_share *= ratio
	var/burned_oxygen = 0.2 * oxygen_share
	var/burned_fuel = 0.2 * fuel_share
	var/list/result = list()
	result[fuel] = fuel_moles - burned_fuel
	result[GAS_O2] = oxygen_moles - burned_oxygen
	var/delta_enthalpy = burned_fuel * fuel_datum.enthalpy + burned_oxygen * oxygen_datum.enthalpy
	var/capacity = fuel_datum.specific_heat * result[fuel] + oxygen_datum.specific_heat * result[GAS_O2]
	var/total = result[fuel] + result[GAS_O2]
	for(var/product in fuel_datum.fire_products)
		var/datum/gas/product_datum = data.datums[product]
		var/made = fuel_datum.fire_products[product] * burned_fuel
		result[product] += made
		delta_enthalpy -= made * product_datum.enthalpy
		capacity += product_datum.specific_heat * made
		total += made
	var/initial = temperature * (fuel_datum.specific_heat * fuel_moles + oxygen_datum.specific_heat * oxygen_moles + R_IDEAL_GAS_EQUATION * (fuel_moles + oxygen_moles))
	result["temp"] = (initial + delta_enthalpy) / (capacity + R_IDEAL_GAS_EQUATION * total)
	return result

/// Compares a burned mix with expected_fire(), returns a failure description or null
/datum/unit_test/aquila_generic_fire/proc/compare_fire(datum/gas_mixture/air, list/expected, label)
	for(var/key in expected)
		var/actual = key == "temp" ? air.return_temperature() : air.get_moles(key)
		if(!FIRE_CLOSE(actual, expected[key]))
			return "[label]: [key] is [actual], expected [expected[key]]"
	return null

/datum/unit_test/aquila_generic_fire/Run()
	// The DM proc on its own, with products: tritium burns into water vapor, whose enthalpy of formation adds heat
	var/datum/gas_mixture/tritium_mix = new
	tritium_mix.set_moles(GAS_TRITIUM, 10)
	tritium_mix.set_moles(GAS_O2, 50)
	tritium_mix.set_temperature(1000)
	var/datum/gas_reaction/genericfire/fire = new
	TEST_ASSERT(fire.react(tritium_mix, null) == REACTING, "The DM generic fire did not burn tritium in oxygen")
	var/failure = compare_fire(tritium_mix, expected_fire(GAS_TRITIUM, 10, 50, 1000), "DM tritium fire")
	TEST_ASSERT(!failure, failure)
	TEST_ASSERT(tritium_mix.return_temperature() > 1000, "Burning tritium did not heat the mix")

	// The whole reaction pass (Rust on Windows, DM on Linux): only the generic fire matches hot nitrogen in oxygen
	var/datum/gas_mixture/nitrogen_mix = new
	nitrogen_mix.set_moles(GAS_N2, 20)
	nitrogen_mix.set_moles(GAS_O2, 20)
	nitrogen_mix.set_temperature(3000)
	nitrogen_mix.react()
	failure = compare_fire(nitrogen_mix, expected_fire(GAS_N2, 20, 20, 3000), "Reaction pass nitrogen fire")
	TEST_ASSERT(!failure, failure)

	// Hydrogen burns only in the generic fire, so the reaction pass is the Rust or the DM fire, whichever this build has
	var/datum/gas_mixture/hydrogen_mix = new
	hydrogen_mix.set_moles(GAS_H2, 20)
	hydrogen_mix.set_moles(GAS_O2, 20)
	hydrogen_mix.set_temperature(800)
	hydrogen_mix.react()
	failure = compare_fire(hydrogen_mix, expected_fire(GAS_H2, 20, 20, 800), "Reaction pass hydrogen fire")
	TEST_ASSERT(!failure, failure)
	TEST_ASSERT(hydrogen_mix.return_temperature() > 800, "Burning hydrogen did not heat the mix")

	// Methane: the enthalpy of formation is negative, so only Hess's law with the products makes it heat (about 802 kJ per mole)
	var/datum/gas_mixture/methane_mix = new
	methane_mix.set_moles(GAS_METHANE, 10)
	methane_mix.set_moles(GAS_O2, 40)
	methane_mix.set_temperature(800)
	methane_mix.react()
	failure = compare_fire(methane_mix, expected_fire(GAS_METHANE, 10, 40, 800), "Reaction pass methane fire")
	TEST_ASSERT(!failure, failure)
	TEST_ASSERT(methane_mix.return_temperature() > 800, "Burning methane did not heat the mix")

	// auxmos keeps reactions in a map keyed by priority: two reactions with the same priority silently drop one of them
	var/list/priorities = list()
	for(var/datum/gas_reaction/reaction as anything in SSair.gas_reactions)
		var/key = "[reaction.priority]"
		TEST_ASSERT(!priorities[key], "[reaction.type] has the same priority ([key]) as [priorities[key]], auxmos would run only one of them")
		priorities[key] = reaction.type

	// Ignition counts every fuel from the gas data, not only plasma and tritium
	var/datum/gas_mixture/ignition = new
	ignition.set_moles(GAS_TRITIUM, 2)
	TEST_ASSERT(ignition.aq_fire_fuel_moles(FIRE_MINIMUM_TEMPERATURE_TO_EXIST) == 2, "Tritium does not count as fuel for ignition")
	TEST_ASSERT(ignition.aq_fire_fuel_moles(100) == 0, "Fuel counts below its fire temperature")

	// Air alarms know every gas, with the thresholds from its data
	var/obj/machinery/airalarm/alarm = allocate(/obj/machinery/airalarm)
	for(var/gas in GLOB.gas_data.ids)
		TEST_ASSERT(alarm.TLV[gas], "The air alarm has no thresholds for [gas]")

	// Canister export pays the price from the gas data
	var/obj/machinery/portable_atmospherics/canister/canister = allocate(/obj/machinery/portable_atmospherics/canister)
	var/datum/export/large/gas_canister/export = new
	var/empty_worth = export.get_cost(canister)
	canister.air_contents.set_moles(GAS_BZ, 10)
	TEST_ASSERT(FIRE_CLOSE(export.get_cost(canister) - empty_worth, 10 * GLOB.gas_data.prices[GAS_BZ]), "Canister export does not use the BZ price from the gas data")
	TEST_ASSERT(GLOB.gas_data.prices[GAS_BZ] == 4, "The BZ export price changed")

#undef FIRE_CLOSE
#undef TEST_ASSERT
