// Ogólne liście i dekoratory drzew zachowań, port z tgstation code/datums/ai/generic_behaviors i generic_decorators (tgstation/tgstation@5ee81d6).

// --- generic_behaviors/move_to_target.dm
/// Moves toward a blackboard-keyed target each tick. Succeeds when within required_dist by default.
/// Pass finish_on_arrival = FALSE to keep running indefinitely (used in combat parallels).
/// Pass movement_type to temporarily override the controller's ai_movement; resets to the initial type on finish.
/datum/bt_node/ai_behavior/move_to_target
	/// Set by on_movement_failed() when the movement system gives up pathing.
	VAR_FINAL/movement_failed = FALSE
	/// Blackboard key holding the atom to move toward.
	var/target_key
	/// Distance at which arrival is considered reached.
	var/required_dist = 1
	/// Whether to succeed once within required_dist; FALSE keeps running indefinitely.
	var/finish_on_arrival = TRUE
	/// Optional ai_movement type override; resets to the initial type on finish.
	var/movement_type = null
	/// Tracks the last atom we started moving toward so we can retarget when the key changes.
	VAR_PRIVATE/atom/tracked_target

/datum/bt_node/ai_behavior/move_to_target/setup(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	if(movement_type)
		controller.change_ai_movement_type(movement_type)
	RegisterSignal(controller.pawn, COMSIG_MOB_AI_MOVEMENT_FAILED, PROC_REF(on_movement_failed))
	controller.ai_movement.start_moving_towards(controller, target, required_dist)
	tracked_target = target
	return TRUE

/datum/bt_node/ai_behavior/move_to_target/proc/on_movement_failed(atom/source)
	SIGNAL_HANDLER
	movement_failed = TRUE

/datum/bt_node/ai_behavior/move_to_target/perform(seconds_per_tick, datum/ai_controller/controller)
	if(movement_failed)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_FAILED
	if(target != tracked_target)
		controller.ai_movement.start_moving_towards(controller, target, required_dist)
		tracked_target = target
	else if(!controller.ai_movement.moving_controllers[controller])
		controller.ai_movement.start_moving_towards(controller, target, required_dist)
	if(finish_on_arrival && get_dist(controller.pawn, target) <= required_dist)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_INSTANT

/datum/bt_node/ai_behavior/move_to_target/finish_action(datum/ai_controller/controller, succeeded)
	UnregisterSignal(controller.pawn, COMSIG_MOB_AI_MOVEMENT_FAILED)
	movement_failed = FALSE
	tracked_target = null
	controller.ai_movement.stop_moving_towards(controller)
	if(movement_type)
		controller.change_ai_movement_type(initial(controller.ai_movement))
	return ..()

// --- generic_behaviors/wait.dm
/// Does nothing for a given duration (deciseconds, so use the SECONDS define pls), then succeeds. duration = 0 waits forever.
/datum/bt_node/ai_behavior/wait
	/// world.time when the wait ends. 0 when waiting forever
	VAR_PRIVATE/end_time = 0
	/// How long to wait, in deciseconds. 0 waits forever.
	var/duration = 0

/datum/bt_node/ai_behavior/wait/setup(datum/ai_controller/controller)
	end_time = duration > 0 ? world.time + duration : 0
	return TRUE

/datum/bt_node/ai_behavior/wait/perform(seconds_per_tick, datum/ai_controller/controller)
	if(!end_time || world.time < end_time)
		return AI_BEHAVIOR_INSTANT
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/wait/reset_tick_state()
	end_time = 0
	..()

// --- generic_behaviors/clear_key.dm
/// BT-native version: clears a single blackboard key. Returns INSTANT SUCCESS.
/datum/bt_node/ai_behavior/clear_key
	/// Blackboard key to clear.
	var/key

/datum/bt_node/ai_behavior/clear_key/perform(seconds_per_tick, datum/ai_controller/controller)
	controller.clear_blackboard_key(key)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

// --- generic_behaviors/set_bb_cooldown.dm
/// Sets the given blackboard key to a future timestamp, blocking key_off_cooldown until that time.
/datum/bt_node/ai_behavior/set_bb_cooldown
	/// Blackboard key to write the cooldown timestamp into.
	var/cooldown_key
	/// Cooldown duration, in seconds.
	var/cooldown_duration

/datum/bt_node/ai_behavior/set_bb_cooldown/perform(seconds_per_tick, datum/ai_controller/controller)
	controller.set_blackboard_key(cooldown_key, world.time + cooldown_duration)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

// --- generic_behaviors/succeed.dm
/datum/bt_node/ai_behavior/succeed

/datum/bt_node/ai_behavior/succeed/perform(seconds_per_tick, datum/ai_controller/controller)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

// --- generic_behaviors/fail.dm
/datum/bt_node/ai_behavior/fail

/datum/bt_node/ai_behavior/fail/perform(seconds_per_tick, datum/ai_controller/controller)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

// --- generic_behaviors/cancel_current_plan.dm
/// Cancels the controller's current plan, causing the BT to re-evaluate from the root next tick.
/datum/bt_node/ai_behavior/cancel_current_plan

/datum/bt_node/ai_behavior/cancel_current_plan/perform(seconds_per_tick, datum/ai_controller/controller)
	controller.cancel_current_plan()
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

// --- generic_behaviors/set_bb_key.dm
/// Sets the given blackboard key to a value.
/datum/bt_node/ai_behavior/set_bb_key
	/// Blackboard key to set.
	var/target_key
	/// Value to store in the key.
	var/value

/datum/bt_node/ai_behavior/set_bb_key/perform(seconds_per_tick, datum/ai_controller/controller)
	controller.set_blackboard_key(target_key, value)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

// --- generic_decorators/bb_key_set.dm
/// Is the key set to a non-null value
/datum/bt_node/decorator/bb_key_set
	var/key = null

/datum/bt_node/decorator/bb_key_set/register_observe_signals(atom/pawn)
	RegisterSignals(pawn, list(COMSIG_AI_BLACKBOARD_KEY_SET(key), COMSIG_AI_BLACKBOARD_KEY_CLEARED(key)), PROC_REF(on_signal_changed))
	return TRUE

/datum/bt_node/decorator/bb_key_set/unregister_observe_signals(atom/pawn)
	UnregisterSignal(pawn, list(COMSIG_AI_BLACKBOARD_KEY_SET(key), COMSIG_AI_BLACKBOARD_KEY_CLEARED(key)))

/datum/bt_node/decorator/bb_key_set/check_condition(datum/ai_controller/controller)
	return controller.blackboard_key_exists(key)

// --- generic_decorators/check_cooldown.dm
/// Check if the specified blackboard key is off cooldown.
/datum/bt_node/decorator/key_off_cooldown
	var/cooldown_key

/datum/bt_node/decorator/key_off_cooldown/check_condition(datum/ai_controller/controller)
	var/cooldown_time = controller.blackboard[cooldown_key]
	return isnull(cooldown_time) || cooldown_time <= world.time

/**
 * Checks if a blackboard cooldown key is off cooldown before ticking the child,
 * then sets it when the child finishes  replacing the key_off_cooldown
 *
 * cooldown_duration is in deciseconds (e.g. 30 SECONDS).
 * lock_on_succeed = TRUE (default): lock after child SUCCESS only.
 * lock_on_succeed = FALSE: lock after any completion (SUCCESS or FAILURE).
 */
/datum/bt_node/decorator/cooldown
	var/cooldown_key
	var/cooldown_duration
	var/lock_on_succeed = TRUE

/datum/bt_node/decorator/cooldown/check_condition(datum/ai_controller/controller)
	var/cooldown_time = controller.blackboard[cooldown_key]
	return isnull(cooldown_time) || cooldown_time <= world.time

/datum/bt_node/decorator/cooldown/on_child_complete(datum/ai_controller/controller, result)
	if(!lock_on_succeed || result == BT_SUCCESS)
		controller.set_blackboard_key(cooldown_key, world.time + cooldown_duration)

// --- generic_decorators/random_chance.dm
///Decorator with a probability to pass, useful for things that sometimes happen. Slay queen
/datum/bt_node/decorator/random_chance
	/// 0.0–1.0 float; converted to percentage for prob(). Configure via BT_DECORATOR.
	var/chance = 0.5

/datum/bt_node/decorator/random_chance/check_condition(datum/ai_controller/controller)
	return prob(chance * 100)

// --- generic_decorators/bb_key_true.dm
/// Passes if the given blackboard key equals a true-ey value
/datum/bt_node/decorator/bb_key_true
	var/key

/datum/bt_node/decorator/bb_key_true/check_condition(datum/ai_controller/controller)
	var/result = controller.blackboard[key]
	return !!result

// --- generic_decorators/optional.dm
/// Always reports SUCCESS to the parent, even if the child fails. Lets a sequence continue past a step that's allowed to fail. RUNNING still passes through unchanged.
/datum/bt_node/decorator/optional

/datum/bt_node/decorator/optional/tick(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	if(. == BT_FAILURE)
		return BT_SUCCESS

// --- generic_decorators/is_at_distance.dm
/// Decorator that requires the controller's pawn to be within range of a blackboard target.
/datum/bt_node/decorator/is_at_distance
	/// Blackboard key holding the atom to approach. Must be set on the subtype or via configure().
	var/target_key = null
	/// Minimum distance (inclusive) from target. 0 means no lower bound.
	var/min_distance = -1
	/// Maximum distance (inclusive) from target
	var/maximum_distance = -1
	/// If TRUE, also verifies target.IsReachableBy(pawn) before passing to child.
	var/require_reach = FALSE

/datum/bt_node/decorator/is_at_distance/check_condition(datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE

	var/atom/movable/pawn = controller.pawn
	var/dist = get_dist(pawn, target)
	var/reachable = !require_reach || target.IsReachableBy(pawn)

	return (maximum_distance == -1 || dist <= maximum_distance) && dist >= min_distance && reachable

// --- generic_decorators/bb_key_equals.dm
/// Passes if the given blackboard key equals the expected value.
/datum/bt_node/decorator/bb_key_equals
	var/key
	var/value

/datum/bt_node/decorator/bb_key_equals/check_condition(datum/ai_controller/controller)
	return bb_key_equals(controller, key, value)
