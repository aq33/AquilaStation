// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - The biogas plant turns organic reagents and ship sewage (flushed toilets, floor drains) into methane and some CO2
/datum/unit_test/aquila_biogas_plant

/datum/unit_test/aquila_biogas_plant/Run()
	var/sewage_before = GLOB.ship_sewage
	GLOB.ship_sewage = 0
	var/obj/machinery/atmospherics/components/unary/biogas_plant/plant = allocate(/obj/machinery/atmospherics/components/unary/biogas_plant)
	TEST_ASSERT(plant.units_per_tick == 2, "Two tier 1 matter bins should digest 2 units per tick, not [plant.units_per_tick]")

	// Organic reagents become methane and CO2, the rest stays in the tank
	plant.reagents.add_reagent(/datum/reagent/ammonia/urine, 10)
	plant.reagents.add_reagent(/datum/reagent/water, 10)
	var/datum/gas_mixture/output = new(200)
	output.set_temperature(T20C)
	var/digested = plant.ferment(output)
	TEST_ASSERT(digested == 2, "The biogas plant digested [digested] units instead of 2")
	TEST_ASSERT(plant.reagents.get_reagent_amount(/datum/reagent/ammonia/urine) == 8, "Urine was not used up")
	TEST_ASSERT(plant.reagents.get_reagent_amount(/datum/reagent/water) == 8, "Water should drain away at the same rate instead of clogging the tank ([plant.reagents.get_reagent_amount(/datum/reagent/water)] units left)")
	TEST_ASSERT(plant.active_power_usage > plant.idle_power_usage && plant.use_power == ACTIVE_POWER_USE, "A working biogas plant draws no extra power")
	TEST_ASSERT(output.get_moles(GAS_METHANE) > 0, "The biogas plant made no methane from urine")
	TEST_ASSERT(output.get_moles(GAS_CO2) > 0 && output.get_moles(GAS_CO2) < output.get_moles(GAS_METHANE), "Biogas should be mostly methane with some CO2")

	// Without organics it makes nothing
	plant.reagents.clear_reagents()
	plant.reagents.add_reagent(/datum/reagent/water, 10)
	var/methane_before = output.get_moles(GAS_METHANE)
	TEST_ASSERT(!plant.ferment(output), "The biogas plant fermented water")
	TEST_ASSERT(output.get_moles(GAS_METHANE) == methane_before, "Methane appeared from water")
	TEST_ASSERT(plant.reagents.get_reagent_amount(/datum/reagent/water) == 8, "Water alone did not drain away")
	TEST_ASSERT(plant.use_power == IDLE_POWER_USE, "An idle biogas plant still draws working power")
	TEST_ASSERT(plant.reagents.flags & DRAINABLE, "The biogas plant tank cannot be drained by hand")

	// Food thrown in adds its reagents
	var/obj/item/food/meat/slab/slab = allocate(/obj/item/food/meat/slab)
	var/food_volume = get_organic_reagent_volume(slab.reagents)
	TEST_ASSERT(food_volume > 0, "A meat slab has no organic reagents")
	plant.reagents.add_reagent(/datum/reagent/water, plant.reagents.maximum_volume - plant.reagents.total_volume - 1)
	TEST_ASSERT(!plant.add_food(slab), "Food went into a tank too full to hold its reagents")
	TEST_ASSERT(!QDELETED(slab), "Food that did not fit was destroyed")
	plant.reagents.clear_reagents()
	plant.add_food(slab)
	TEST_ASSERT(QDELETED(slab), "The meat slab was not used up")
	TEST_ASSERT(get_organic_reagent_volume(plant.reagents) >= food_volume, "The meat slab reagents did not reach the tank")
	plant.reagents.clear_reagents()

	// A flushed toilet sends its bowl to the ship sewage, which the plant digests on its own
	var/obj/structure/toilet/toilet = allocate(/obj/structure/toilet, get_step(run_loc_floor_bottom_left, EAST))
	toilet.receive_waste(5, 1)
	for(var/attempt in 1 to 50) // a flush can clog the toilet, then the bowl stays full and we try again
		toilet.flushing = FALSE
		toilet.clogged = FALSE
		toilet.reagents.add_reagent(toilet.reagent_id, toilet.reagents.maximum_volume)
		toilet.flush(null, TRUE)
		if(!toilet.clogged)
			break
	TEST_ASSERT(!toilet.bowl_urine && !toilet.bowl_feces, "The toilet kept its bowl after flushing")
	TEST_ASSERT(GLOB.ship_sewage == 15, "A flushed bowl of 5 units of urine and one feces gave [GLOB.ship_sewage] units of sewage instead of 15")
	methane_before = output.get_moles(GAS_METHANE)
	TEST_ASSERT(plant.ferment(output) == 2, "The biogas plant did not take sewage from the ship")
	TEST_ASSERT(GLOB.ship_sewage == 13, "Sewage was not used up ([GLOB.ship_sewage] units left)")
	TEST_ASSERT(output.get_moles(GAS_METHANE) > methane_before, "Sewage made no methane")

	// Clown lube from the bladder does not ferment
	GLOB.ship_sewage = 0
	toilet.receive_waste(5, 0, /datum/reagent/lube)
	toilet.clogged = FALSE
	toilet.flushing = FALSE
	toilet.reagents.add_reagent(toilet.reagent_id, toilet.reagents.maximum_volume)
	toilet.flush(null, TRUE)
	TEST_ASSERT(GLOB.ship_sewage == 0, "Flushed lube became [GLOB.ship_sewage] units of sewage")

	// A clogged toilet overflows onto the floor instead of the sewage
	GLOB.ship_sewage = 0
	toilet.receive_waste(5, 0)
	toilet.clogged = TRUE
	toilet.flushing = FALSE
	toilet.flush(null, TRUE)
	TEST_ASSERT(GLOB.ship_sewage == 0, "An overflowing clogged toilet sent its bowl to the sewage")

	// A floor drain sends the organic share of a puddle to the sewage, water alone adds nothing
	var/turf/drain_turf = get_step(run_loc_floor_bottom_left, NORTH)
	var/obj/structure/drain/drain = allocate(/obj/structure/drain, drain_turf)
	aquila_liquids_cleanup(drain_turf)
	drain_turf.add_liquid(/datum/reagent/water, 100)
	drain.process(1)
	TEST_ASSERT(GLOB.ship_sewage == 0, "A drain sent plain water to the sewage")
	aquila_liquids_cleanup(drain_turf)
	drain_turf.add_liquid(/datum/reagent/ammonia/urine, 100)
	drain.process(1)
	TEST_ASSERT(GLOB.ship_sewage > 0, "A drain sent no urine to the sewage")
	aquila_liquids_cleanup(drain_turf)

	GLOB.ship_sewage = sewage_before
	for(var/obj/effect/decal/cleanable/mess in get_turf(toilet))
		qdel(mess)
	aquila_liquids_cleanup(get_turf(toilet))

#undef TEST_ASSERT
