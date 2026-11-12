// AQUILA: port of tgstation/tgstation code/datums/ai/movement/ai_movement_complete_stop.dm (tg 926bf40c5a)
// tg freezes the mob with a `freeze` move loop for BB_STATIONARY_SECONDS. Our move manager has no such loop, so this movement
// starts none and stops the one the mob had: nothing moves the mob until stop_and_stare gives it its normal movement back.

/// Come to a complete stop for a set amount of time.
/datum/ai_movement/complete_stop
	max_pathing_attempts = INFINITY // path all you want, you can not escape your fate

/datum/ai_movement/complete_stop/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)
	. = ..()
	var/atom/movable/moving = controller.pawn
	if(!QDELETED(moving))
		SSmove_manager.stop_looping(moving, SSai_movement)

/datum/ai_movement/complete_stop/allowed_to_move(datum/move_loop/source)
	return FALSE
