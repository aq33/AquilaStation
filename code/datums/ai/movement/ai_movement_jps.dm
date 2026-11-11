// AQUILA: synced with BeeStation/BeeStation-Hornet (bee/master 0adf0fe9ae), see "AI core sync" in aquila/LEGACY_OVERRIDES.md
/**
 * This movement datum represents smart-pathing
 */
/datum/ai_movement/jps
	max_pathing_attempts = 20
	var/maximum_length = AI_MAX_PATH_LENGTH

/datum/ai_movement/jps/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)
	. = ..()
	var/atom/movable/moving = controller.pawn
	var/delay = controller.movement_delay

	var/datum/move_loop/loop = SSmove_manager.jps_move(moving,
		current_movement_target,
		delay,
		repath_delay = 0.5 SECONDS,
		max_path_length = maximum_length,
		minimum_distance = controller.get_minimum_distance(),
		id = controller.get_access(), // AQUILA: our jps_move takes an id card, not an access list
		subsystem = SSai_movement,
		extra_info = controller,
	)

	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(pre_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_move))
	RegisterSignal(loop, COMSIG_MOVELOOP_JPS_REPATH, PROC_REF(repath_incoming))

/datum/ai_movement/jps/proc/repath_incoming(datum/move_loop/has_target/jps/source)
	SIGNAL_HANDLER
	var/datum/ai_controller/controller = source.extra_info

	source.id = controller.get_access()
	source.minimum_distance = controller.get_minimum_distance()

/datum/ai_movement/jps/modsuit
	maximum_length = MOD_AI_RANGE
