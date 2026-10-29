// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - Smoke and smells: pollution spreads, shows up, gets breathed and smelled, and scrubs away
/datum/unit_test/aquila_pollution

/datum/unit_test/aquila_pollution/Run()
	TEST_ASSERT(SSpollution.singletons[/datum/pollutant/smoke], "SSpollution did not create the smoke singleton")
	TEST_ASSERT(!SSpollution.singletons[/datum/pollutant/food], "An abstract pollutant got a singleton")

	var/turf/open/source = run_loc_floor_bottom_left
	var/turf/open/neighbour = get_step(source, EAST)
	TEST_ASSERT(istype(neighbour) && (neighbour in source.atmos_adjacent_turfs), "The test tiles do not share air")

	// Earlier tests may have left smoke or smells around (fires, vomit)
	clear_pollution()

	// Thick smoke shows a haze and spreads to the neighbour
	source.pollute_turf(/datum/pollutant/smoke, 200)
	var/datum/pollution/pollution = source.pollution
	TEST_ASSERT(pollution?.total_amount == 200, "pollute_turf did not add 200 smoke (total [pollution?.total_amount])")
	TEST_ASSERT(pollution.managed_overlay, "Thick smoke has no haze overlay")
	TEST_ASSERT(pollution in SSpollution.active_pollution, "Fresh pollution is not active")
	pollution.process_cell()
	TEST_ASSERT(neighbour.pollution?.total_amount > 0, "Smoke did not spread to the neighbouring tile")
	TEST_ASSERT(source.pollution.total_amount < 200, "Spreading did not take smoke from the source tile")

	// Smelling picks the strongest smell
	var/mob/living/carbon/human/sniffer = allocate(/mob/living/carbon/human, source)
	TEST_ASSERT(source.pollution.smell_act(sniffer) == SSpollution.singletons[/datum/pollutant/smoke], "Smelling thick smoke did not notice it")

	// Breathing exhaust hurts, but far less than in Monke
	source.pollution.add_pollutant(/datum/pollutant/carbon_air_pollution, 100)
	var/obj/item/organ/lungs/lungs = sniffer.getorganslot(ORGAN_SLOT_LUNGS)
	TEST_ASSERT(lungs, "The test human has no lungs")
	sniffer.next_smell = 0
	lungs.handle_pollution_breath(sniffer)
	var/oxyloss = sniffer.getOxyLoss()
	TEST_ASSERT(oxyloss > 0 && oxyloss <= 4, "Breathing exhaust dealt [oxyloss] oxy instead of 2-4")
	TEST_ASSERT(sniffer.next_smell > world.time, "Breathing a smell did not start the passive smell cooldown")

	// Scrubbing everything away deletes the datum
	source.pollution.scrub_amount(INFINITY)
	TEST_ASSERT(QDELETED(pollution) && !source.pollution, "Scrubbing everything left pollution on the tile")

	// The air refresher sprays its fragrance on the aimed tile
	var/obj/item/air_refresher/refresher = allocate(/obj/item/air_refresher, source)
	refresher.afterattack(source, sniffer, TRUE)
	TEST_ASSERT(source.pollution?.pollutants[/datum/pollutant/fragrance/air_refresher] == 200, "The air refresher did not spray 200 fragrance")
	TEST_ASSERT(refresher.uses_remaining == 19, "The air refresher did not use a charge")

	// The janitor scrubber cleans its own tile once screwed down and turned on
	var/obj/machinery/pollution_scrubber/scrubber = allocate(/obj/machinery/pollution_scrubber, source)
	scrubber.anchored = TRUE
	scrubber.on = TRUE
	scrubber.machine_stat = NONE
	var/before = source.pollution.total_amount
	scrubber.process()
	TEST_ASSERT(source.pollution.total_amount < before, "The pollution scrubber did not clean its tile")

/datum/unit_test/aquila_pollution/Destroy()
	clear_pollution()
	return ..()

/datum/unit_test/aquila_pollution/proc/clear_pollution()
	for(var/datum/pollution/pollution as anything in SSpollution.all_polution.Copy())
		qdel(pollution)

#undef TEST_ASSERT
