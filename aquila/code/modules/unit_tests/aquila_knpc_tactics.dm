// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Boarder do testów: bez skalowania trudnością overmapy, AI zatrzymane, sterujemy nim ręcznie
/mob/living/carbon/human/ai_boarder/aquila_test
	difficulty_override = TRUE
	knpc_traits = NONE
	outfit = list(/datum/outfit/job/assistant)

/mob/living/carbon/human/ai_boarder/aquila_test/Initialize(mapload)
	. = ..()
	STOP_PROCESSING(SSfastprocess, GetComponent(/datum/component/knpc))

/// AQUILA - boarder woli strzelającego do niego wroga od bliższego, który nic nie robi
/datum/unit_test/aquila_knpc_target_prefers_shooter

/datum/unit_test/aquila_knpc_target_prefers_shooter/Run()
	var/turf/base = run_loc_floor_bottom_left
	var/mob/living/carbon/human/ai_boarder/aquila_test/boarder = allocate(/mob/living/carbon/human/ai_boarder/aquila_test, locate(base.x + 1, base.y + 1, base.z))
	var/mob/living/carbon/human/idle = allocate(/mob/living/carbon/human, locate(base.x + 3, base.y + 1, base.z))
	var/mob/living/carbon/human/shooter = allocate(/mob/living/carbon/human, locate(base.x + 5, base.y + 1, base.z))
	var/datum/component/knpc/ai = boarder.GetComponent(/datum/component/knpc)
	TEST_ASSERT(ai, "Boarder has no knpc component")
	TEST_ASSERT_EQUAL(ai.pick_target(list(idle, shooter)), idle, "Without other information the closest enemy should be picked")
	ai.current_target = null
	LAZYSET(ai.recent_shooters, WEAKREF(shooter), world.time + 10 SECONDS)
	TEST_ASSERT_EQUAL(ai.pick_target(list(idle, shooter)), shooter, "An enemy that just shot the boarder should be picked over a closer idle one")

/// AQUILA - boarder z bronią palną odsuwa się od wroga, który podszedł za blisko, zamiast iść na niego
/datum/unit_test/aquila_knpc_keeps_distance

/datum/unit_test/aquila_knpc_keeps_distance/Run()
	var/turf/base = run_loc_floor_bottom_left
	var/mob/living/carbon/human/ai_boarder/aquila_test/boarder = allocate(/mob/living/carbon/human/ai_boarder/aquila_test, locate(base.x + 3, base.y + 1, base.z))
	var/mob/living/carbon/human/enemy = allocate(/mob/living/carbon/human, locate(base.x + 1, base.y + 1, base.z))
	var/obj/item/gun/ballistic/automatic/pistol/gun = allocate(/obj/item/gun/ballistic/automatic/pistol)
	boarder.put_in_active_hand(gun)
	TEST_ASSERT(gun.can_shoot(), "Test pistol cannot shoot")
	var/datum/component/knpc/ai = boarder.GetComponent(/datum/component/knpc)
	ai.next_move = 0
	ai.tactical_move(enemy)
	TEST_ASSERT_EQUAL(get_dist(boarder, enemy), 3, "Armed boarder 2 tiles from the enemy should step back to 3 tiles")
	TEST_ASSERT(!length(ai.path), "Armed boarder in range should not keep a path towards the enemy")

/// AQUILA - przy krytycznym zdrowiu medipen wygrywa z walką, przy lekkich ranach nie
/datum/unit_test/aquila_knpc_heals_in_combat

/datum/unit_test/aquila_knpc_heals_in_combat/Run()
	var/mob/living/carbon/human/ai_boarder/aquila_test/boarder = allocate(/mob/living/carbon/human/ai_boarder/aquila_test, run_loc_floor_bottom_left)
	var/obj/item/reagent_containers/hypospray/medipen/survival/pen = allocate(/obj/item/reagent_containers/hypospray/medipen/survival)
	boarder.put_in_inactive_hand(pen)
	var/datum/component/knpc/ai = boarder.GetComponent(/datum/component/knpc)
	var/datum/ai_goal/human/heal_self/heal = locate() in ai.ai_goals
	var/datum/ai_goal/human/engage_targets/engage = locate() in ai.ai_goals
	TEST_ASSERT(heal && engage, "Missing heal_self or engage_targets goal")
	boarder.adjustBruteLoss(boarder.maxHealth * 0.4)
	TEST_ASSERT(heal.check_score(ai) < engage.score, "Lightly wounded boarder should keep fighting instead of healing")
	// Obrażenia rozkładają się na kończyny z limitem, więc dobijamy do progu toksynami
	boarder.adjustToxLoss(boarder.health - boarder.maxHealth * 0.3, forced = TRUE)
	TEST_ASSERT(boarder.health <= boarder.maxHealth * 0.35, "Could not wound the test boarder enough (health [boarder.health])")
	TEST_ASSERT(heal.check_score(ai) > engage.score, "Badly wounded boarder with a medipen should heal even in combat (health [boarder.health], score [heal.check_score(ai)])")

/// AQUILA - boarder wyważający drzwi przebija się przez śluzę bez dostępu, hakujący otwiera ją panelem
/datum/unit_test/aquila_knpc_door_breach

/datum/unit_test/aquila_knpc_door_breach/Run()
	var/turf/base = run_loc_floor_bottom_left
	var/turf/door_turf = locate(base.x + 2, base.y + 1, base.z)
	var/mob/living/carbon/human/ai_boarder/aquila_test/boarder = allocate(/mob/living/carbon/human/ai_boarder/aquila_test, locate(base.x + 1, base.y + 1, base.z))
	var/datum/component/knpc/ai = boarder.GetComponent(/datum/component/knpc)
	var/obj/machinery/door/airlock/door = allocate(/obj/machinery/door/airlock, door_turf)
	door.req_access = list(ACCESS_CAPTAIN)
	TEST_ASSERT(!door.allowed(boarder), "Test boarder should not have access to the test airlock")
	TEST_ASSERT_EQUAL(ai.path_access_card(), boarder.wear_id, "A boarder without breach traits should plan paths with its own ID")

	boarder.knpc_traits = KNPC_IS_DOOR_BASHER
	var/obj/item/card/id/breach_card = ai.path_access_card()
	TEST_ASSERT(breach_card && (ACCESS_CAPTAIN in breach_card.access), "A door basher should plan paths through any station door")
	for(var/i in 1 to 30)
		if(!door.density)
			break
		ai.path = list(door_turf)
		ai.next_door_action = 0
		TEST_ASSERT(ai.handle_blocking_door(), "Door basher did not act on an airlock it has no access to")
	TEST_ASSERT(!door.density, "Door basher failed to force the airlock open in 30 hits")

	door.close()
	door.obj_integrity = door.max_integrity
	TEST_ASSERT(door.density, "Test airlock did not close again")
	boarder.knpc_traits = KNPC_IS_DOOR_HACKER
	ai.path = list(door_turf)
	ai.next_door_action = 0
	TEST_ASSERT(ai.handle_blocking_door(), "Door hacker did not act on an airlock it has no access to")
	TEST_ASSERT(ai.hacking_door, "Door hacker did not start hacking")
	ai.finish_door_hack(WEAKREF(door))
	TEST_ASSERT(!ai.hacking_door, "Hacking flag stayed set after the hack finished")
	TEST_ASSERT(!door.density, "Door hacker failed to open the airlock")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
