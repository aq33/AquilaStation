// AQUILA: port of tgstation/tgstation code/datums/ai/basic_mobs/basic_ai_behaviors/stop_and_stare.dm (tg 926bf40c5a)
// Changes against tg: the mob stops staring at a thing it no longer sees (tg kept the key until the thing was deleted, so a
// deer froze every minute for a vehicle that drove away long ago); the movement it had is stopped before the complete stop
// and given back by a proc that checks the controller still exists (tg's timer called set_movement_target() on it blindly);
// one stare ends the behaviour (tg's never ended while the thing was in view, which stopped all planning: a deer that saw
// a vehicle neither fled nor ate), and the stare_at_thing subtree waits for BB_STATIONARY_NEXT_STARE.

/// Makes a mob simply stop and stare at a movable... yea...
/datum/ai_behavior/stop_and_stare
	behavior_flags = AI_BEHAVIOR_MOVE_AND_PERFORM

/datum/ai_behavior/stop_and_stare/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/movable/target = controller.blackboard[target_key]
	return ismovable(target) && isturf(target.loc) && ismob(controller.pawn)

/datum/ai_behavior/stop_and_stare/get_cooldown(datum/ai_controller/cooldown_for)
	return cooldown_for.blackboard[BB_STATIONARY_COOLDOWN] || action_cooldown

/datum/ai_behavior/stop_and_stare/perform(delta_time, datum/ai_controller/controller, target_key)
	var/atom/movable/target = controller.blackboard[target_key]
	var/mob/pawn_mob = controller.pawn
	// AQUILA: gone out of sight, forget it
	if(!ismovable(target) || !isturf(target.loc) || !can_see(pawn_mob, target, SEARCH_TACTIC_DEFAULT_RANGE))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/turf/pawn_turf = get_turf(pawn_mob)

	pawn_mob.face_atom(target)
	pawn_mob.balloon_alert_to_viewers("zamiera i się gapi...")
	controller.ai_movement.stop_moving_towards(controller) // AQUILA: our move loops are not replaced by the next one
	set_movement_target(controller, pawn_turf, /datum/ai_movement/complete_stop)

	addtimer(CALLBACK(src, PROC_REF(stop_staring), controller, target), (controller.blackboard[BB_STATIONARY_SECONDS] + 1 SECONDS))
	controller.set_blackboard_key(BB_STATIONARY_NEXT_STARE, world.time + get_cooldown(controller))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/stop_and_stare/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	if(!succeeded)
		controller.clear_blackboard_key(target_key)

/// Gives the mob its normal movement back after the stare, and walks it up to the thing if it wants to
/datum/ai_behavior/stop_and_stare/proc/stop_staring(datum/ai_controller/controller, atom/movable/target)
	if(QDELETED(controller) || QDELETED(controller.pawn))
		return
	var/datum/ai_movement/stop = SSai_movement.movement_types[/datum/ai_movement/complete_stop]
	if(controller.ai_movement == stop)
		stop.stop_moving_towards(controller)
		controller.change_ai_movement_type(initial(controller.ai_movement))
	if(controller.blackboard[BB_STATIONARY_MOVE_TO_TARGET] && !QDELETED(target) && controller.ai_status == AI_STATUS_ON)
		set_movement_target(controller, target)
