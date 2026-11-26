// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - The oxygen regenerator turns CO2 from its input pipe into oxygen in its output pipe and leaves coal behind
/datum/unit_test/aquila_oxygen_regenerator

/datum/unit_test/aquila_oxygen_regenerator/Run()
	var/obj/machinery/atmospherics/components/binary/oxygen_regenerator/regenerator = allocate(/obj/machinery/atmospherics/components/binary/oxygen_regenerator)
	TEST_ASSERT(regenerator.moles_per_tick == 1, "Two tier 1 manipulators should convert 1 mole per tick, not [regenerator.moles_per_tick]")

	var/datum/gas_mixture/input = new(200)
	input.set_moles(GAS_CO2, 10)
	input.set_moles(GAS_N2, 5)
	input.set_temperature(T20C)
	var/datum/gas_mixture/output = new(200)
	output.set_temperature(T20C)

	var/converted = regenerator.regenerate(input, output)
	TEST_ASSERT(converted == 1, "The regenerator converted [converted] moles instead of 1")
	TEST_ASSERT(input.get_moles(GAS_CO2) == 9, "CO2 was not taken from the input ([input.get_moles(GAS_CO2)] moles left)")
	TEST_ASSERT(input.get_moles(GAS_N2) == 5, "The regenerator took other gases than CO2 from its input")
	TEST_ASSERT(output.get_moles(GAS_O2) == 1, "The regenerator made [output.get_moles(GAS_O2)] moles of oxygen instead of 1")
	TEST_ASSERT(output.get_moles(GAS_CO2) == 0, "CO2 leaked into the output")
	TEST_ASSERT(regenerator.stored_carbon == 0.5, "The regenerator stored [regenerator.stored_carbon] moles of carbon instead of 0.5")

	// Enough carbon drops a piece of coal
	regenerator.stored_carbon = 19.9
	regenerator.regenerate(input, output)
	var/obj/item/stack/sheet/mineral/coal/coal = locate() in regenerator.drop_location()
	TEST_ASSERT(coal, "The regenerator dropped no coal after collecting enough carbon")
	TEST_ASSERT(regenerator.stored_carbon < 1, "The carbon used for the coal stayed stored ([regenerator.stored_carbon] moles)")
	qdel(coal)

	// A full output pipe stops it
	output.set_moles(GAS_O2, 10000)
	var/co2_before = input.get_moles(GAS_CO2)
	TEST_ASSERT(!regenerator.regenerate(input, output), "The regenerator kept pushing into an overpressurized pipe")
	TEST_ASSERT(input.get_moles(GAS_CO2) == co2_before, "CO2 was used up while the output pipe was full")

	// Switched off it does nothing in its own pipes
	var/datum/gas_mixture/own_input = regenerator.airs[1]
	own_input.set_moles(GAS_CO2, 10)
	regenerator.on = FALSE
	regenerator.process_atmos()
	TEST_ASSERT(own_input.get_moles(GAS_CO2) == 10, "A regenerator that is off converted CO2")

#undef TEST_ASSERT

/// AQUILA - Plants grow one and a half times faster with 1-10 kPa of CO2 in their air
/datum/unit_test/aquila_plant_co2_growth

/datum/unit_test/aquila_plant_co2_growth/Run()
	var/turf/open/location = run_loc_floor_bottom_left
	var/obj/item/plant_tray/tray = allocate(/obj/item/plant_tray, location)
	var/datum/component/planter/planter = tray.GetComponent(/datum/component/planter)
	planter.set_substrate(/datum/plant_subtrate/dirt)
	tray.reagents.add_reagent(/datum/reagent/water, 100)
	var/obj/item/plant_seeds/seeds = allocate(/obj/item/plant_seeds/preset/tomato, location)
	var/datum/component/plant/plant = seeds.plant(tray, null, TRUE, null, TRUE)
	if(!plant)
		return Fail("Could not plant a tomato")
	var/datum/plant_feature/fruit/fruit = locate() in plant.plant_features

	var/datum/gas_mixture/original_air = location.air.copy()
	location.air.set_moles(GAS_CO2, 0)
	if(fruit.get_co2_growth_multiplier() != 1)
		return Fail("A tomato in normal air grows [fruit.get_co2_growth_multiplier()] times faster")
	location.air.set_moles(GAS_CO2, 5) // about 5 kPa in a 2500 L tile
	var/greenhouse = fruit.get_co2_growth_multiplier()
	location.air.set_moles(GAS_CO2, 40) // about 40 kPa, too much
	var/too_much = fruit.get_co2_growth_multiplier()
	location.air.copy_from(original_air)
	if(greenhouse != 1.5)
		return Fail("A tomato in 5 kPa of CO2 grows [greenhouse] times faster instead of 1.5")
	if(too_much != 1)
		return Fail("A tomato in 40 kPa of CO2 still grows [too_much] times faster")
