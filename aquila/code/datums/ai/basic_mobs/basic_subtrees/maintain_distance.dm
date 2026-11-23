// AQUILA: port of tgstation code/datums/ai/basic_mobs/basic_subtrees/maintain_distance.dm (tg 926bf40c5a) for the basic
// mining mobs (hivelord, legion, watcher). Without tg's backstep movement (the mob turns while stepping away) and without
// cover_minimum_distance, which nothing here uses; the global is_blocked_turf() instead of tg's turf proc.

/// Step away if too close, or towards if too far
/datum/ai_planning_subtree/maintain_distance
	/// Blackboard key holding atom we want to stay away from
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET
	/// How far do we look for our target?
	var/view_distance = 10
	/// the run away behavior we will use
	var/run_away_behavior = /datum/ai_behavior/step_away

/datum/ai_planning_subtree/maintain_distance/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	if(LAZYLEN(living_pawn.do_afters))
		return

	var/atom/target = controller.blackboard[target_key]
	if (!isliving(target) || !can_see(controller.pawn, target, view_distance))
		return // Don't run away from cucumbers, they're not snakes
	var/range = get_dist(controller.pawn, target)

	var/minimum_distance = controller.blackboard[BB_RANGED_SKIRMISH_MIN_DISTANCE] || 4
	var/maximum_distance = controller.blackboard[BB_RANGED_SKIRMISH_MAX_DISTANCE] || 6

	if (range < minimum_distance)
		controller.queue_behavior(run_away_behavior, target_key, minimum_distance)
		return
	if (range > maximum_distance)
		controller.queue_behavior(/datum/ai_behavior/pursue_to_range, target_key, maximum_distance)
		return

/// Take one step away
/datum/ai_behavior/step_away
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	required_distance = 0
	action_cooldown = 0.2 SECONDS

/datum/ai_behavior/step_away/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/current_target = controller.blackboard[target_key]
	if (QDELETED(current_target))
		return FALSE

	var/mob/living/our_pawn = controller.pawn
	our_pawn.face_atom(current_target)

	var/turf/next_step = get_step_away(controller.pawn, current_target)
	if (!isnull(next_step) && !is_blocked_turf(next_step, exclude_mobs = TRUE))
		set_movement_target(controller, next_step)
		return TRUE

	var/list/all_dirs = GLOB.alldirs.Copy()
	all_dirs -= get_dir(controller.pawn, next_step)
	all_dirs -= get_dir(controller.pawn, current_target)
	shuffle_inplace(all_dirs)

	for (var/dir in all_dirs)
		next_step = get_step(controller.pawn, dir)
		if (!isnull(next_step) && !is_blocked_turf(next_step, exclude_mobs = TRUE))
			set_movement_target(controller, next_step)
			return TRUE
	return FALSE

/datum/ai_behavior/step_away/perform(seconds_per_tick, datum/ai_controller/controller)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/// Pursue a target until we are within a provided range
/datum/ai_behavior/pursue_to_range
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION | AI_BEHAVIOR_MOVE_AND_PERFORM

/datum/ai_behavior/pursue_to_range/setup(datum/ai_controller/controller, target_key, range)
	. = ..()
	var/atom/current_target = controller.blackboard[target_key]
	if (QDELETED(current_target))
		return FALSE
	if (get_dist(controller.pawn, current_target) <= range)
		return FALSE
	set_movement_target(controller, current_target)

/datum/ai_behavior/pursue_to_range/perform(seconds_per_tick, datum/ai_controller/controller, target_key, range)
	var/atom/current_target = controller.blackboard[target_key]
	if (!QDELETED(current_target) && get_dist(controller.pawn, current_target) > range)
		return AI_BEHAVIOR_INSTANT
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
