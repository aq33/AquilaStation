// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - sprint (BeeStation#14750): sprint swaps the run speed, costs condition, exhaustion blocks it, walls count as obstacles
/datum/unit_test/sprint

/datum/unit_test/sprint/Run()
	var/mob/living/carbon/human/runner = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/datum/component/carbon_sprint/sprint = runner.GetComponent(/datum/component/carbon_sprint)
	TEST_ASSERT(sprint, "Humans have no sprint component")
	TEST_ASSERT(runner.sprint_stamina, "Humans have no sprint stamina pool")
	TEST_ASSERT(runner.sprint_stamina.current == SPRINT_STAMINA_MAX, "Sprint stamina does not start full")

	var/mob/living/carbon/monkey/monkey = allocate(/mob/living/carbon/monkey)
	TEST_ASSERT(monkey.GetComponent(/datum/component/carbon_sprint) && monkey.sprint_stamina, "Monkeys cannot sprint")

	runner.m_intent = MOVE_INTENT_RUN
	runner.update_move_intent_slowdown()

	// Without the key held nothing happens
	var/turf/next = get_step(runner, EAST)
	SEND_SIGNAL(runner, COMSIG_MOB_CLIENT_PRE_MOVE, next)
	TEST_ASSERT(!sprint.sprinting, "Sprint started without the key held")

	// Key held: the run modifier becomes the sprint one, and the step costs condition
	SEND_SIGNAL(runner, COMSIG_KB_CARBON_SPRINT_DOWN)
	SEND_SIGNAL(runner, COMSIG_MOB_CLIENT_PRE_MOVE, next)
	TEST_ASSERT(sprint.sprinting, "Sprint did not start with the key held")
	var/list/walk_run = runner.has_movespeed_modifier(MOVESPEED_ID_MOB_WALK_RUN_CONFIG_SPEED)
	TEST_ASSERT(walk_run[MOVESPEED_DATA_INDEX_MULTIPLICATIVE_SLOWDOWN] == CONFIG_GET(number/movedelay/sprint_delay), "Sprinting does not use SPRINT_DELAY")
	runner.Move(next, EAST)
	TEST_ASSERT(runner.sprint_stamina.current < SPRINT_STAMINA_MAX, "A sprinted step cost no condition")

	// Letting go restores the run speed
	SEND_SIGNAL(runner, COMSIG_KB_CARBON_SPRINT_UP)
	walk_run = runner.has_movespeed_modifier(MOVESPEED_ID_MOB_WALK_RUN_CONFIG_SPEED)
	TEST_ASSERT(!sprint.sprinting, "Sprint did not stop when the key was released")
	TEST_ASSERT(walk_run[MOVESPEED_DATA_INDEX_MULTIPLICATIVE_SLOWDOWN] == (isnum(CONFIG_GET(number/movedelay/run_delay)) ? CONFIG_GET(number/movedelay/run_delay) : 1), "Run speed was not restored after sprinting")

	// Walking never sprints
	runner.m_intent = MOVE_INTENT_WALK
	SEND_SIGNAL(runner, COMSIG_KB_CARBON_SPRINT_DOWN)
	SEND_SIGNAL(runner, COMSIG_MOB_CLIENT_PRE_MOVE, get_step(runner, EAST))
	TEST_ASSERT(!sprint.sprinting, "Sprint started in walk mode")
	runner.m_intent = MOVE_INTENT_RUN

	// Exhaustion below the threshold: trait, slowdown, no sprint; it lifts above the recovery threshold
	runner.sprint_stamina.adjust(-SPRINT_STAMINA_MAX * 0.7)
	TEST_ASSERT(HAS_TRAIT(runner, TRAIT_EXHAUSTED), "Low condition did not exhaust")
	TEST_ASSERT(runner.has_movespeed_modifier(MOVESPEED_ID_SPRINT_EXHAUSTION), "Exhaustion has no slowdown")
	TEST_ASSERT(!sprint.can_sprint(), "An exhausted mob can sprint")
	runner.sprint_stamina.adjust(SPRINT_STAMINA_MAX * 0.2)
	TEST_ASSERT(HAS_TRAIT(runner, TRAIT_EXHAUSTED), "Exhaustion lifted before the recovery threshold")
	runner.sprint_stamina.adjust(SPRINT_STAMINA_MAX)
	TEST_ASSERT(!HAS_TRAIT(runner, TRAIT_EXHAUSTED), "Exhaustion did not lift at full condition")
	TEST_ASSERT(!runner.has_movespeed_modifier(MOVESPEED_ID_SPRINT_EXHAUSTION), "Exhaustion slowdown stayed")

	// Wall slam obstacles: walls and anchored dense objects yes, mobs and loose objects no
	var/turf/wall = run_loc_floor_top_right
	var/old_type = wall.type
	wall.ChangeTurf(/turf/closed/wall)
	TEST_ASSERT(sprint.is_hard_obstacle(wall), "A wall is not a sprint obstacle")
	wall.ChangeTurf(old_type)
	TEST_ASSERT(!sprint.is_hard_obstacle(monkey), "A mob counts as a sprint obstacle")
	var/obj/structure/closet/crate/crate = allocate(/obj/structure/closet/crate)
	TEST_ASSERT(!sprint.is_hard_obstacle(crate), "A loose crate counts as a sprint obstacle")
	var/obj/structure/window/fulltile/window = allocate(/obj/structure/window/fulltile)
	TEST_ASSERT(sprint.is_hard_obstacle(window), "A window is not a sprint obstacle")

#undef TEST_ASSERT
