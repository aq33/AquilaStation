// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - ruiny planet: scatter_alien_seeds kładzie 1-2 paczki obcych nasion na wolnej podłodze, nie na zajętych polach, a przy szansie 0 nic
/datum/unit_test/aquila_planet_ruin_seeds

/datum/unit_test/aquila_planet_ruin_seeds/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/turf/free_turf = get_step(origin, EAST)
	var/turf/blocked_turf = get_step(free_turf, EAST)
	allocate(/obj/structure/table, blocked_turf)

	var/list/none = scatter_alien_seeds(list(free_turf, blocked_turf), 0)
	TEST_ASSERT(!length(none), "Przy szansie 0 pojawiły się nasiona")

	var/list/seeds = scatter_alien_seeds(list(free_turf, blocked_turf), 100)
	TEST_ASSERT(length(seeds) == 1, "Na jednym wolnym polu powinna leżeć 1 paczka, jest [length(seeds)]")
	var/obj/item/plant_seeds/preset/alien/packet = seeds[1]
	TEST_ASSERT(istype(packet), "Ruina dała [packet?.type] zamiast obcych nasion")
	TEST_ASSERT(packet.type != packet.abstract_type, "Ruina dała abstrakcyjny typ nasion")
	TEST_ASSERT(packet.loc == free_turf, "Paczka leży na zajętym albo obcym polu ([packet.loc])")
	for(var/obj/item/leftover as anything in seeds)
		qdel(leftover)

#undef TEST_ASSERT
