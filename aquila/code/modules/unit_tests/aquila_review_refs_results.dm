// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - infiltratorzy: 3 wykonane i 2 nieudane cele dawały NONECOMPLETE, bo warunki get_result() miały lukę
/datum/unit_test/aquila_infiltrator_result

/datum/unit_test/aquila_infiltrator_result/Run()
	var/datum/team/infiltrator/team = new
	TEST_ASSERT_EQUAL(infiltrator_result_for(team, 3, 0), INFILTRATION_ALLCOMPLETE, "All objectives done")
	TEST_ASSERT_EQUAL(infiltrator_result_for(team, 1, 1), INFILTRATION_MOSTCOMPLETE, "One objective failed")
	TEST_ASSERT_EQUAL(infiltrator_result_for(team, 3, 2), INFILTRATION_MOSTCOMPLETE, "More objectives done than failed")
	TEST_ASSERT_EQUAL(infiltrator_result_for(team, 2, 2), INFILTRATION_SOMECOMPLETE, "Half of the objectives done")
	TEST_ASSERT_EQUAL(infiltrator_result_for(team, 1, 3), INFILTRATION_SOMECOMPLETE, "Most objectives failed")
	TEST_ASSERT_EQUAL(infiltrator_result_for(team, 0, 2), INFILTRATION_NONECOMPLETE, "Every objective failed")
	QDEL_LIST(team.objectives)
	qdel(team)

/// Gives the team fresh objectives, done ones first, and returns get_result()
/datum/unit_test/aquila_infiltrator_result/proc/infiltrator_result_for(datum/team/infiltrator/team, done, failed)
	QDEL_LIST(team.objectives)
	team.objectives = list()
	for(var/i in 1 to done + failed)
		var/datum/objective/objective = new
		objective.completed = (i <= done)
		team.objectives += objective
	return team.get_result()

/// AQUILA - Dół bingli nie połyka przykręconych rzeczy ani pojazdów, a ankiety na bingla idą po jednej
/datum/unit_test/aquila_bingle_swallow_limits

/datum/unit_test/aquila_bingle_swallow_limits/Run()
	var/turf/left = run_loc_floor_bottom_left
	var/turf/right = get_step(left, EAST)
	var/obj/structure/bingle_hole/hole = allocate(/obj/structure/bingle_hole, left)

	var/obj/item/toy/crayon/red/bolted = allocate(/obj/item/toy/crayon/red, right)
	bolted.anchored = TRUE
	bolted.forceMove(left)
	TEST_ASSERT(!hole.falling[bolted], "Pit swallowed an anchored object")
	var/obj/vehicle/ridden/scooter/scooter = allocate(/obj/vehicle/ridden/scooter, right)
	scooter.forceMove(left)
	TEST_ASSERT(!hole.falling[scooter], "Pit swallowed a vehicle")
	TEST_ASSERT_EQUAL(hole.item_value_consumed, 0, "Refused objects still gave the pit points")

	// Trwa ankieta: kolejne progi czekają w kolejce zamiast otwierać nowe okienka duchom
	hole.current_pit_size = BINGLE_PIT_MAX_SIZE // bez wzrostu w pokoju testowym
	hole.polling_bingle = TRUE
	hole.item_value_consumed = BINGLE_PIT_SPAWN_STEP * 2
	hole.process(2)
	TEST_ASSERT_EQUAL(hole.pending_bingle_spawns, 2, "Thresholds passed during a poll were not queued")
	TEST_ASSERT(hole.polling_bingle, "A second poll started while one was running")
	// Nie puszczamy prawdziwej ankiety przy sprzątaniu
	hole.pending_bingle_spawns = 0
	STOP_PROCESSING(SSobj, hole)

/// AQUILA - nawiedzony przedmiot: usunięty mob znika z blackboardu, zamiast zostać tam jako twarda referencja
/datum/unit_test/aquila_haunted_item_refs

/datum/unit_test/aquila_haunted_item_refs/Run()
	var/turf/left = run_loc_floor_bottom_left
	var/obj/item/wrench/wrench = allocate(/obj/item/wrench, left)
	wrench.AddComponent(/datum/component/haunted_item)
	var/datum/ai_controller/haunted/controller = wrench.ai_controller
	TEST_ASSERT(istype(controller), "Item was not haunted")
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(left, EAST))
	controller.add_hauntee(victim, 5)
	controller.set_blackboard_key(BB_HAUNT_TARGET, victim)
	var/list/hauntee_list = controller.blackboard[BB_TO_HAUNT_LIST]
	TEST_ASSERT(hauntee_list[victim] == 5, "Victim was not added to the haunt list")
	qdel(victim)
	TEST_ASSERT(!(victim in hauntee_list), "Deleted mob stayed on the haunt list")
	TEST_ASSERT(isnull(controller.blackboard[BB_HAUNT_TARGET]), "Deleted mob stayed the haunt target")
	qdel(wrench.GetComponent(/datum/component/haunted_item))

/// AQUILA - rower stacjonarny: odmowa przypięcia nie przenosi celu na rower
/datum/unit_test/aquila_stationarybike_refused_buckle

/datum/unit_test/aquila_stationarybike_refused_buckle/Run()
	var/turf/left = run_loc_floor_bottom_left
	var/turf/right = get_step(left, EAST)
	var/obj/machinery/power/stationarybike/bike = allocate(/obj/machinery/power/stationarybike, left)
	var/obj/structure/chair/chair = allocate(/obj/structure/chair, right)
	var/mob/living/carbon/monkey/runner = allocate(/mob/living/carbon/monkey, right)
	TEST_ASSERT(chair.buckle_mob(runner, TRUE), "Could not buckle the monkey to the chair")
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, get_step(left, NORTH))
	TEST_ASSERT(!bike.user_buckle_mob(runner, user, check_loc = FALSE), "Monkey already on a chair got buckled to the bike")
	TEST_ASSERT_EQUAL(get_turf(runner), right, "Refused buckle still moved the monkey onto the bike")
	TEST_ASSERT_EQUAL(runner.buckled, chair, "Refused buckle took the monkey off its chair")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
