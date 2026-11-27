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

/// AQUILA - the swarm's end goal: resources of the whole swarm unlock the relay, a relay that survives broadcasts the signal (win),
/// a relay destroyed before that resets the swarm's resources
/datum/unit_test/aquila_swarmer_relay

/datum/unit_test/aquila_swarmer_relay/Run()
	var/mob/living/simple_animal/hostile/swarmer/swarmer = allocate(/mob/living/simple_animal/hostile/swarmer)
	var/datum/mind/mind = new("aquila_swarmer_test")
	mind.current = swarmer
	swarmer.mind = mind
	var/datum/antagonist/swarmer/role = mind.add_antag_datum(/datum/antagonist/swarmer)
	TEST_ASSERT(role, "The swarmer did not get its antagonist datum")
	var/datum/team/swarmers/swarm = role.swarm
	TEST_ASSERT(swarm, "The swarmer is in no swarm")
	TEST_ASSERT(mind in swarm.members, "The swarmer is not a member of its swarm")
	var/datum/objective/swarmer_signal/signal = locate() in role.objectives
	TEST_ASSERT(signal, "The swarmer has no signal objective")
	TEST_ASSERT(!signal.check_completion(), "The signal objective is complete before any relay")
	var/collected_before = swarm.collected

	// Eaten items count for the whole swarm, swarmer shells do not
	var/obj/item/wrench/wrench = allocate(/obj/item/wrench)
	swarmer.Integrate(wrench)
	TEST_ASSERT_EQUAL(swarm.collected, collected_before + 1, "An eaten item did not count for the swarm")
	var/obj/item/deactivated_swarmer/shell = allocate(/obj/item/deactivated_swarmer)
	swarmer.Integrate(shell)
	TEST_ASSERT_EQUAL(swarm.collected, collected_before + 1, "An eaten swarmer shell counted for the swarm")

	// Not enough resources in the swarm: no relay
	swarm.collected = 0
	swarmer.resources = SWARMER_RELAY_COST
	TEST_ASSERT(findtext(swarmer.relay_build_problem(swarm), "dopiero"), "A relay can be built before the swarm collected enough resources")
	swarm.collected = SWARMER_RELAY_RESOURCES
	swarmer.resources = SWARMER_RELAY_COST - 1
	TEST_ASSERT(findtext(swarmer.relay_build_problem(swarm), "własnych zasobów"), "A relay can be built without a full storage")

	// The relay is built, charges and broadcasts the signal
	swarmer.resources = SWARMER_RELAY_COST
	var/obj/structure/swarmer_relay/relay = swarmer.build_relay(swarm)
	TEST_ASSERT(relay, "The swarmer built no relay")
	allocated += relay
	TEST_ASSERT_EQUAL(swarmer.resources, 0, "Building the relay did not cost the swarmer's resources")
	TEST_ASSERT_EQUAL(swarm.relay, relay, "The swarm does not know its relay")
	TEST_ASSERT(relay.time_left() > 0, "The relay is not charging")
	TEST_ASSERT(swarmer.relay_build_problem(swarm), "A second relay can be built while the first one stands")
	TEST_ASSERT(!relay.swarmer_act(swarmer), "A swarmer tried to take apart its own relay")
	relay.broadcast()
	TEST_ASSERT(swarm.signal_sent, "The relay broadcast but the swarm did not send the signal")
	TEST_ASSERT(signal.check_completion(), "The signal objective is not complete after the broadcast")
	TEST_ASSERT(isnull(swarm.relay), "The swarm still waits for a relay that already broadcast")
	qdel(relay)
	TEST_ASSERT(swarm.signal_sent, "Destroying a relay after the broadcast took the win away")

	// A relay destroyed before the broadcast resets the swarm's resources
	var/datum/team/swarmers/other = new
	other.collected = SWARMER_RELAY_RESOURCES
	var/obj/structure/swarmer_relay/lost = allocate(/obj/structure/swarmer_relay)
	lost.start_charging(other)
	TEST_ASSERT_EQUAL(other.relay, lost, "The second swarm does not know its relay")
	qdel(lost)
	TEST_ASSERT(isnull(other.relay), "The swarm still has a destroyed relay")
	TEST_ASSERT_EQUAL(other.relays_destroyed, 1, "The destroyed relay was not counted")
	TEST_ASSERT_EQUAL(other.collected, 0, "The swarm kept its resources after losing the relay")
	TEST_ASSERT(!other.signal_sent, "A destroyed relay sent the signal")

	mind.remove_antag_datum(/datum/antagonist/swarmer)
	swarmer.mind = null
	mind.current = null
	qdel(other)
	if(!length(swarm.members))
		qdel(swarm)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
