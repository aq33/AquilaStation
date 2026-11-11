// AQUILA - tg basic deer in the grasslands_hunt bitrunning domain (tg 926bf40c5a, decision D9)
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/**
 * Regression: our simple animal deer fled with walk_away(), which nothing cancelled, so a dead deer kept running from the hunter.
 * The basic deer flees from a human it sees through its AI, and dying stops the flight and the movement.
 */
/datum/unit_test/aquila_deer_flees_and_stops_when_dead

/datum/unit_test/aquila_deer_flees_and_stops_when_dead/Run()
	var/mob/living/basic/deer/deer = allocate(/mob/living/basic/deer, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/hunter = allocate(/mob/living/carbon/human, locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	var/datum/ai_controller/controller = deer.ai_controller
	controller.set_ai_status(AI_STATUS_ON)

	var/datum/ai_behavior/find_target = GET_AI_BEHAVIOR(/datum/ai_behavior/find_potential_targets/nearest)
	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[find_target], "The deer did not look for something to flee from")
	controller.ProcessBehavior(1, find_target)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET], hunter, "The deer did not notice the human next to it")

	var/datum/ai_behavior/flee = GET_AI_BEHAVIOR(/datum/ai_behavior/run_away_from_target)
	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[flee], "The deer did not plan to run from the human")
	// process() runs one ready behaviour per call, the other planned ones (looking for grass, trees...) go first
	for(var/i in 1 to 10)
		controller.process(1)
		if(SSmove_manager.processing_on(deer, SSai_movement))
			break
	TEST_ASSERT(SSmove_manager.processing_on(deer, SSai_movement), "The fleeing deer did not start moving")

	deer.death()
	TEST_ASSERT_EQUAL(controller.ai_status, AI_STATUS_OFF, "The dead deer kept its AI on")
	TEST_ASSERT(!length(controller.current_behaviors), "The dead deer kept running behaviours")
	TEST_ASSERT(!SSmove_manager.processing_on(deer, SSai_movement), "The dead deer kept moving")
	TEST_ASSERT(isnull(controller.ai_movement.moving_controllers[controller]), "The dead deer kept a movement target")

/// A living deer pulled by someone does not walk off on its own
/datum/unit_test/aquila_deer_pulled_stays

/datum/unit_test/aquila_deer_pulled_stays/Run()
	var/mob/living/basic/deer/deer = allocate(/mob/living/basic/deer, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/puller = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	var/datum/ai_controller/controller = deer.ai_controller
	TEST_ASSERT(controller.ai_traits & STOP_MOVING_WHEN_PULLED, "The deer AI walks while pulled")
	puller.start_pulling(deer)
	TEST_ASSERT_EQUAL(deer.pulledby, puller, "The human could not pull the deer")
	var/turf/start = deer.loc
	for(var/i in 1 to 20)
		controller.idle_behavior.perform_idle_behavior(10, controller)
	TEST_ASSERT_EQUAL(deer.loc, start, "The pulled deer wandered off")

/// The deer stops and stares at a vehicle, then gets its movement back
/datum/unit_test/aquila_deer_stares_at_vehicles

/datum/unit_test/aquila_deer_stares_at_vehicles/Run()
	var/mob/living/basic/deer/deer = allocate(/mob/living/basic/deer, run_loc_floor_bottom_left)
	var/obj/vehicle/ridden/scooter/scooter = allocate(/obj/vehicle/ridden/scooter, locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	var/datum/ai_controller/controller = deer.ai_controller
	var/datum/ai_movement/normal_movement = controller.ai_movement

	var/datum/ai_behavior/find_scare = GET_AI_BEHAVIOR(/datum/ai_behavior/find_and_set/in_list)
	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[find_scare], "The deer did not look for scary things")
	controller.ProcessBehavior(1, find_scare)
	TEST_ASSERT_EQUAL(controller.blackboard[BB_STATIONARY_CAUSE], scooter, "The deer did not notice the scooter")

	var/datum/ai_behavior/stop_and_stare/stare = GET_AI_BEHAVIOR(/datum/ai_behavior/stop_and_stare)
	controller.SelectBehaviors(1)
	TEST_ASSERT(controller.current_behaviors[stare], "The deer did not stop to stare at the scooter")
	controller.ProcessBehavior(1, stare)
	TEST_ASSERT(istype(controller.ai_movement, /datum/ai_movement/complete_stop), "The staring deer can still move")
	stare.stop_staring(controller, scooter)
	TEST_ASSERT_EQUAL(controller.ai_movement, normal_movement, "The deer did not get its movement back after staring")

/// Deer killed in the grasslands_hunt domain still give the domain its points (3.5 each)
/datum/unit_test/aquila_deer_hunt_domain_points

/datum/unit_test/aquila_deer_hunt_domain_points/Run()
	var/obj/effect/landmark/bitrunning/mob_segment/landmark = allocate(/obj/effect/landmark/bitrunning/mob_segment, run_loc_floor_bottom_left)
	var/datum/lazy_template/virtual_domain/grasslands_hunt/domain = new
	var/datum/modular_mob_segment/deer/segment = new
	segment.probability = 100
	domain.setup_domain(list(landmark))

	var/list/mob_refs = landmark.spawn_mobs(get_turf(landmark), segment)
	TEST_ASSERT_EQUAL(length(mob_refs), 1, "The deer segment did not spawn one deer")
	var/datum/weakref/deer_ref = mob_refs[1]
	var/mob/living/basic/deer/deer = deer_ref.resolve()
	TEST_ASSERT(istype(deer), "The deer segment spawned [deer?.type] instead of a basic deer")

	deer.death()
	TEST_ASSERT_EQUAL(domain.main_crate_points, 3.5, "Killing the deer gave the domain no points")

	qdel(deer)
	qdel(segment)
	qdel(domain)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
