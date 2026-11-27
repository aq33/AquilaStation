// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - regression: without a gateway the swarmer event used to do nothing; now it puts one shell in maintenance or cargo
/datum/unit_test/aquila_swarmer_event_without_gateway

/datum/unit_test/aquila_swarmer_event_without_gateway/Run()
	var/old_gateway = GLOB.the_gateway
	GLOB.the_gateway = null
	var/obj/effect/mob_spawn/swarmer/shell_type = /obj/effect/mob_spawn/swarmer
	var/spawner_key = initial(shell_type.name)
	var/list/before = LAZYCOPY(GLOB.mob_spawners[spawner_key])
	var/datum/round_event/spawn_swarmer/event = new(FALSE) // not processing, start() is called by hand
	event.start()
	GLOB.the_gateway = old_gateway
	var/list/new_shells = LAZYCOPY(GLOB.mob_spawners[spawner_key]) - before
	for(var/obj/effect/mob_spawn/swarmer/shell in new_shells)
		allocated += shell
	event.kill()
	TEST_ASSERT_EQUAL(length(new_shells), 1, "The event without a gateway did not put exactly one swarmer shell on the ship")
	var/obj/effect/mob_spawn/swarmer/shell = new_shells[1]
	var/turf/spot = get_turf(shell)
	TEST_ASSERT(spot && is_station_level(spot.z), "The shell is not on the ship")
	TEST_ASSERT(event.valid_area(get_area(spot)), "The shell landed in [get_area(spot)], not in maintenance or cargo")
	TEST_ASSERT(!isgroundlessturf(spot) && !spot.density, "The shell landed on a wall or in space")

	// A spot taken by another spawner or a dense object is never picked
	TEST_ASSERT(!event.valid_turf(spot), "A turf with a shell on it still counts as free")
	TEST_ASSERT(!event.valid_turf(run_loc_floor_bottom_left), "The unit test room counted as maintenance or cargo")

/// AQUILA - swarmers leave the ship's systems alone: engines, ship consoles, guns and ship ammunition, but still eat other items
/datum/unit_test/aquila_swarmer_ship_protection

/datum/unit_test/aquila_swarmer_ship_protection/Run()
	var/mob/living/simple_animal/hostile/swarmer/swarmer = allocate(/mob/living/simple_animal/hostile/swarmer)
	var/list/protected = list(
		allocate(/obj/machinery/ship_thruster),
		allocate(/obj/machinery/computer/ship/helm),
		allocate(/obj/item/ship_weapon/ammunition/broadside_shell),
		allocate(/obj/item/powder_bag),
	)
	for(var/atom/movable/thing as anything in protected)
		TEST_ASSERT(!thing.swarmer_act(swarmer), "A swarmer tried to take apart [thing.type]")
		TEST_ASSERT(!QDELETED(thing), "A swarmer took apart [thing.type]")
	TEST_ASSERT_EQUAL(swarmer.resources, 0, "A swarmer got resources from a protected ship system")

	var/obj/item/wrench/wrench = allocate(/obj/item/wrench)
	wrench.swarmer_act(swarmer)
	TEST_ASSERT(QDELETED(wrench), "A swarmer no longer eats ordinary items")
	TEST_ASSERT_EQUAL(swarmer.resources, 1, "Eating a wrench gave the wrong amount of resources")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
