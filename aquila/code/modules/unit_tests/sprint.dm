// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - sprint (BeeStation#14750): sprint swaps the run speed, costs condition, exhaustion blocks it, walls count as obstacles
/datum/unit_test/sprint

/datum/unit_test/sprint/Run()
	var/mob/living/carbon/human/runner = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/datum/component/carbon_sprint/sprint = runner.GetComponent(/datum/component/carbon_sprint)
	TEST_ASSERT(sprint, "Humans have no sprint component")
	TEST_ASSERT(runner.stamina, "Humans have no stamina pool")
	TEST_ASSERT(runner.stamina.current == STAMINA_MAX, "Stamina does not start full")

	var/mob/living/carbon/monkey/monkey = allocate(/mob/living/carbon/monkey)
	TEST_ASSERT(monkey.GetComponent(/datum/component/carbon_sprint) && monkey.stamina, "Monkeys cannot sprint")

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
	TEST_ASSERT(runner.stamina.current < STAMINA_MAX, "A sprinted step cost no condition")

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
	runner.stamina.adjust(-STAMINA_MAX * 0.7)
	TEST_ASSERT(HAS_TRAIT(runner, TRAIT_EXHAUSTED), "Low condition did not exhaust")
	TEST_ASSERT(runner.has_movespeed_modifier(MOVESPEED_ID_SPRINT_EXHAUSTION), "Exhaustion has no slowdown")
	TEST_ASSERT(!sprint.can_sprint(), "An exhausted mob can sprint")
	runner.stamina.adjust(STAMINA_MAX * 0.2)
	TEST_ASSERT(HAS_TRAIT(runner, TRAIT_EXHAUSTED), "Exhaustion lifted before the recovery threshold")
	runner.stamina.adjust(STAMINA_MAX)
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

/// AQUILA - someone standing in combat mode stops a sprinter like a wall, a sprint dive knocks the target down
/datum/unit_test/sprint_tackle

/datum/unit_test/sprint_tackle/proc/cancel_throw(datum/source, list/arguments)
	SIGNAL_HANDLER
	return COMPONENT_CANCEL_THROW

/datum/unit_test/sprint_tackle/Run()
	var/mob/living/carbon/human/runner = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/bystander = allocate(/mob/living/carbon/human, locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	var/datum/component/carbon_sprint/sprint = runner.GetComponent(/datum/component/carbon_sprint)
	TEST_ASSERT(sprint, "Humans have no sprint component")

	// Combat mode decides whether a person is a sprint obstacle
	bystander.set_combat_mode(FALSE)
	TEST_ASSERT(!sprint.is_hard_obstacle(bystander), "A person without combat mode counts as a sprint obstacle")
	bystander.set_combat_mode(TRUE)
	TEST_ASSERT(sprint.is_hard_obstacle(bystander), "A person in combat mode does not stop a sprinter")
	bystander.Knockdown(1 SECONDS)
	TEST_ASSERT(!sprint.is_hard_obstacle(bystander), "A person lying down stops a sprinter")
	bystander.SetKnockdown(0)

	// Running into them: the runner falls, the person in combat mode stays up
	runner.m_intent = MOVE_INTENT_RUN
	SEND_SIGNAL(runner, COMSIG_KB_CARBON_SPRINT_DOWN)
	sprint.sprinting = TRUE
	sprint.last_sprint_step = world.time
	sprint.sustained_moves = SPRINT_WALLSLAM_MIN_MOVES + 2
	SEND_SIGNAL(runner, COMSIG_MOVABLE_BUMP, bystander)
	// Wywrotka idzie z timera po 1 ticku: przy obciążonym serwerze czekamy na nią do sekundy, nie stałe 2 ticki
	for(var/i in 1 to 10)
		if(runner.IsKnockdown())
			break
		sleep(1)
	TEST_ASSERT(runner.IsKnockdown(), "Running into a person in combat mode did not knock the runner down")
	TEST_ASSERT(!bystander.IsKnockdown(), "The person in combat mode fell over too")
	runner.SetKnockdown(0)

	// A dive comes from the rest button while sprinting in combat mode, and replaces lying down
	var/turf/far = locate(runner.x + 3, runner.y, runner.z)
	runner.set_combat_mode(TRUE)
	sprint.last_sprint_step = world.time - SPRINT_RECENT_STEP_WINDOW - 1
	TEST_ASSERT(!sprint.can_dive(), "Dived without sprinting")
	sprint.sprinting = TRUE
	sprint.last_sprint_step = world.time
	TEST_ASSERT(sprint.can_dive(), "Could not dive from the rest button while sprinting in combat mode")
	runner.set_combat_mode(FALSE)
	TEST_ASSERT(!sprint.can_dive(), "Dived without combat mode")
	runner.set_combat_mode(TRUE)
	runner.Paralyze(1 SECONDS)
	TEST_ASSERT(!sprint.can_dive(), "A paralyzed runner could dive")
	runner.SetParalyzed(0)
	// Clicking the world no longer dives
	runner.ClickOn(far)
	TEST_ASSERT(!sprint.diving && COOLDOWN_FINISHED(sprint, dive_cooldown), "Clicking a tile while sprinting started a dive")

	// A cancelled throw costs nothing and starts no cooldown
	var/stamina_before = runner.stamina.current
	RegisterSignal(runner, COMSIG_MOVABLE_PRE_THROW, PROC_REF(cancel_throw))
	sprint.start_dive(far)
	UnregisterSignal(runner, COMSIG_MOVABLE_PRE_THROW)
	TEST_ASSERT(!sprint.diving, "A cancelled dive stayed in progress")
	TEST_ASSERT(runner.stamina.current == stamina_before, "A cancelled dive cost stamina")
	TEST_ASSERT(COOLDOWN_FINISHED(sprint, dive_cooldown), "A cancelled dive started the cooldown")

	// The rest button while sprinting throws the runner forward instead of laying them down
	runner.setDir(EAST)
	sprint.sprinting = TRUE
	sprint.last_sprint_step = world.time
	sprint.last_sprint_dir = EAST
	RegisterSignal(runner, COMSIG_MOVABLE_PRE_THROW, PROC_REF(cancel_throw))
	runner.lay_down()
	sleep(1)
	UnregisterSignal(runner, COMSIG_MOVABLE_PRE_THROW)
	TEST_ASSERT(!runner.resting, "The rest button laid a sprinting runner down instead of diving")
	// Without combat mode or without a sprint the button lies down as before
	sprint.last_sprint_step = world.time
	runner.set_combat_mode(FALSE)
	runner.lay_down()
	TEST_ASSERT(runner.resting, "The rest button did not lay down a sprinting runner without combat mode")
	runner.set_resting(FALSE)
	runner.set_combat_mode(TRUE)
	sprint.last_sprint_step = world.time - SPRINT_RECENT_STEP_WINDOW - 1
	runner.lay_down()
	TEST_ASSERT(runner.resting, "The rest button did not lay down a runner who was not sprinting")
	runner.set_resting(FALSE)
	// Sprint key released: the button lies down even right after a sprint step
	sprint.last_sprint_step = world.time
	sprint.sprint_key_down = FALSE
	TEST_ASSERT(!sprint.can_dive(), "Dived after the sprint key was released")
	sprint.sprint_key_down = TRUE
	// No dive over a tile without ground: it would carry the runner into space
	var/turf/ahead = get_step(runner, NORTH)
	var/old_turf_type = ahead.type
	ahead.ChangeTurf(/turf/open/space)
	sprint.last_sprint_dir = NORTH
	TEST_ASSERT(!sprint.try_rest_dive(), "Dived towards space")
	ahead.ChangeTurf(old_turf_type)
	sprint.last_sprint_dir = EAST

	// NPCs with combat mode on by default do not stop a sprinter, only people and player-controlled mobs do
	var/mob/living/simple_animal/hostile/morph/npc = allocate(/mob/living/simple_animal/hostile/morph, locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	npc.set_combat_mode(TRUE)
	TEST_ASSERT(!sprint.is_braced_mob(npc), "An NPC with default combat mode counts as a sprint obstacle")

	// The first impact of a dive on a person knocks them down
	bystander.set_combat_mode(FALSE)
	sprint.diving = TRUE
	sprint.on_dive_impact(runner, bystander, null)
	TEST_ASSERT(bystander.IsKnockdown(), "A sprint dive did not knock the target down")
	TEST_ASSERT(!sprint.diving, "The dive did not end on impact")

#undef TEST_ASSERT
