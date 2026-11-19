// Kontroler i liście drzewa basic botów. Port z tgstation code/modules/mob/living/basic/bots/bot_ai.dm i
// code/datums/ai/bots/bot_subtrees.dm (patrol, wezwanie), plus wspólny schemat pracy Aquili (bot_work.bt.json).

/datum/ai_controller/basic_controller/bot
	behavior_tree_json = "aquila/code/modules/mob/living/basic/bots/bot.bt.json"
	blackboard = list(
		BB_UNREACHABLE_LIST_COOLDOWN = 45 SECONDS,
	)
	ai_movement = /datum/ai_movement/jps
	max_target_distance = 25
	can_idle = FALSE
	/// Klucze czyszczone przy resecie bota
	var/list/reset_keys = list(
		BB_BEACON_TARGET,
		BB_PREVIOUS_BEACON_TARGET,
		BB_BOT_SUMMON_TARGET,
		BB_BOT_WORK_TARGET,
	)

/datum/ai_controller/basic_controller/bot/TryPossessPawn(atom/new_pawn)
	if(!isbasicbot(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE
	. = ..()
	if(. & AI_CONTROLLER_INCOMPATIBLE)
		return
	RegisterSignal(new_pawn, COMSIG_BOT_RESET, PROC_REF(reset_bot))
	RegisterSignal(new_pawn, COMSIG_MOB_AI_MOVEMENT_STARTED, PROC_REF(on_movement_start))

/datum/ai_controller/basic_controller/bot/UnpossessPawn(destroy)
	if(pawn)
		UnregisterSignal(pawn, list(COMSIG_BOT_RESET, COMSIG_MOB_AI_MOVEMENT_STARTED))
	return ..()

/datum/ai_controller/basic_controller/bot/proc/on_movement_start(mob/living/basic/bot/source, atom/target)
	SIGNAL_HANDLER
	if(target == blackboard[BB_BEACON_TARGET])
		source.update_bot_mode(BBOT_PATROL)
	else if(target == blackboard[BB_BOT_WORK_TARGET])
		source.update_bot_mode(BBOT_MOVING)

/datum/ai_controller/basic_controller/bot/proc/add_to_blacklist(atom/target, duration)
	if(QDELETED(target))
		return
	set_blackboard_key_assoc_lazylist(BB_TEMPORARY_IGNORE_LIST, target, TRUE)
	addtimer(CALLBACK(src, PROC_REF(remove_from_blacklist), target), duration || blackboard[BB_UNREACHABLE_LIST_COOLDOWN])

/datum/ai_controller/basic_controller/bot/proc/remove_from_blacklist(atom/target)
	if(QDELETED(target))
		return
	remove_thing_from_blackboard_key(BB_TEMPORARY_IGNORE_LIST, target)

/datum/ai_controller/basic_controller/bot/setup_able_to_run()
	. = ..()
	RegisterSignal(pawn, COMSIG_BOT_MODE_FLAGS_SET, PROC_REF(update_able_to_run))

/datum/ai_controller/basic_controller/bot/clear_able_to_run()
	UnregisterSignal(pawn, COMSIG_BOT_MODE_FLAGS_SET)
	return ..()

/datum/ai_controller/basic_controller/bot/get_able_to_run()
	var/mob/living/basic/bot/bot_pawn = pawn
	if(!(bot_pawn.bot_mode_flags & BOT_MODE_ON))
		return AI_UNABLE_TO_RUN
	return ..()

/datum/ai_controller/basic_controller/bot/get_access()
	var/mob/living/basic/bot/bot_pawn = pawn
	return bot_pawn.access_card

/datum/ai_controller/basic_controller/bot/proc/reset_bot()
	SIGNAL_HANDLER
	cancel_current_plan()
	for(var/key in reset_keys)
		clear_blackboard_key(key)

/// Czy da się dojść do celu (sprawdza ścieżkę, może spać)
/datum/ai_controller/basic_controller/bot/proc/can_reach_target(atom/target, distance = 10, minimum_distance = 0)
	var/turf/pawn_turf = get_turf(pawn)
	var/turf/target_turf = get_turf(target)
	if(!pawn_turf || !target_turf || pawn_turf.z != target_turf.z)
		return FALSE
	if(get_dist(pawn_turf, target_turf) <= max(1, minimum_distance))
		return TRUE
	var/list/path = get_path_to(pawn, target_turf, distance, minimum_distance, get_access(), !HAS_TRAIT(pawn, TRAIT_SPACEWALK))
	return length(path) > 0

/// Ustawia cel, jeśli da się do niego dojść; w przeciwnym razie cel trafia na czarną listę
/datum/ai_controller/basic_controller/bot/proc/set_if_can_reach(key, atom/target, duration, distance = 10, minimum_distance = 0)
	if(can_reach_target(target, distance, minimum_distance))
		set_blackboard_key(key, target)
		return TRUE
	add_to_blacklist(target, duration)
	return FALSE

/**
 * Selektor reaktywny: co tik zaczyna od pierwszego dziecka, więc wyższy priorytet (wezwanie, nowa praca)
 * przerywa niższy (patrol). Zwykły selektor z tg wznawia od działającego dziecka i potrzebuje do tego
 * obserwatorów w dekoratorach; nasze boty mają jeden wspólny układ, więc prościej tak.
 */
/datum/bt_node/composite/selector/reactive
	label = "REACTIVE SELECTOR"

/datum/bt_node/composite/selector/reactive/tick(datum/ai_controller/controller, seconds_per_tick)
	var/previous = running_child_index
	for(var/i in 1 to length(children))
		var/datum/bt_node/child = children[i]
		var/child_result = child.tick(controller, seconds_per_tick)
		if(controller.cancelled_during_tick)
			return BT_FAILURE
		if(child_result == BT_FAILURE)
			continue
		if(previous && previous != i)
			var/datum/bt_node/interrupted = children[previous]
			interrupted.reset_subtree_tick_states()
		running_child_index = (child_result == BT_RUNNING) ? i : 0
		return child_result
	if(previous)
		var/datum/bt_node/interrupted = children[previous]
		interrupted.reset_subtree_tick_states()
	running_child_index = 0
	return BT_FAILURE

/// Przepuszcza, gdy bot może pracować (włączony, bez gracza)
/datum/bt_node/decorator/bot_can_work

/datum/bt_node/decorator/bot_can_work/check_condition(datum/ai_controller/controller)
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	return istype(bot_pawn) && bot_pawn.can_seek_work()

/// Przepuszcza, gdy bot ma flagę trybu
/datum/bt_node/decorator/bot_mode_flag
	var/flag

/datum/bt_node/decorator/bot_mode_flag/check_condition(datum/ai_controller/controller)
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	return !!(bot_pawn.bot_mode_flags & flag)

/// Przepuszcza, gdy bot jest zhakowany (invert = TRUE: gdy nie jest)
/datum/bt_node/decorator/bot_is_emagged

/datum/bt_node/decorator/bot_is_emagged/check_condition(datum/ai_controller/controller)
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	return bot_pawn.is_emagged()

/**
 * Szuka celu pracy: kandydaci od bota (get_work_candidates(), bez spania), potem asynchronicznie sprawdza drogę
 * (get_path_to może spać) i ustawia pierwszy osiągalny w target_key.
 */
/datum/bt_node/ai_behavior/bot_find_work
	var/target_key = BB_BOT_WORK_TARGET
	var/pathing_distance = 25
	time_between_perform = 2 SECONDS
	VAR_PRIVATE/list/candidate_stash

/datum/bt_node/ai_behavior/bot_find_work/perform(seconds_per_tick, datum/ai_controller/basic_controller/bot/controller)
	var/async_flags = handle_async()
	if(async_flags)
		return async_flags
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	if(!istype(controller) || !istype(bot_pawn))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/list/candidates = bot_pawn.get_work_candidates()
	if(!length(candidates))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	candidate_stash = candidates
	return start_async()

/datum/bt_node/ai_behavior/bot_find_work/perform_async(datum/ai_controller/basic_controller/bot/controller)
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	var/atom/found
	for(var/atom/potential_target as anything in candidate_stash)
		if(!async_still_valid())
			return
		if(QDELETED(potential_target))
			continue
		if(controller.set_if_can_reach(target_key, potential_target, distance = pathing_distance, minimum_distance = bot_pawn.work_reach))
			found = potential_target
			break
	if(!async_still_valid())
		return
	if(found)
		bot_pawn.on_work_target_found(found)
	finish_async(found ? AI_BEHAVIOR_SUCCEEDED : AI_BEHAVIOR_FAILED)

/datum/bt_node/ai_behavior/bot_find_work/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	candidate_stash = null

/// Idzie do celu pracy na odległość work_reach bota
/datum/bt_node/ai_behavior/move_to_target/bot_work
	target_key = BB_BOT_WORK_TARGET

/datum/bt_node/ai_behavior/move_to_target/bot_work/setup(datum/ai_controller/controller)
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	required_dist = bot_pawn.work_reach
	return ..()

/datum/bt_node/ai_behavior/move_to_target/bot_work/finish_action(datum/ai_controller/basic_controller/bot/controller, succeeded)
	if(!succeeded && movement_failed && istype(controller))
		var/atom/target = controller.blackboard[target_key]
		controller.clear_blackboard_key(target_key)
		controller.add_to_blacklist(target)
	return ..()

/// Praca nad celem: work_on_target() bota, wołane asynchronicznie (może zawierać do_after)
/datum/bt_node/ai_behavior/bot_perform_work
	var/target_key = BB_BOT_WORK_TARGET
	VAR_PRIVATE/last_result

/datum/bt_node/ai_behavior/bot_perform_work/setup(datum/ai_controller/controller)
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	time_between_perform = bot_pawn.work_interval
	return ..()

/datum/bt_node/ai_behavior/bot_perform_work/perform(seconds_per_tick, datum/ai_controller/controller)
	var/async_flags = handle_async()
	if(async_flags)
		return async_flags
	var/atom/target = controller.blackboard[target_key]
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	if(QDELETED(target) || !bot_pawn.can_seek_work())
		last_result = BOT_WORK_DONE
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(get_dist(bot_pawn, target) > bot_pawn.work_reach)
		last_result = BOT_WORK_OUT_OF_REACH
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	bot_pawn.update_bot_mode(bot_pawn.work_mode)
	return start_async()

/datum/bt_node/ai_behavior/bot_perform_work/perform_async(datum/ai_controller/controller)
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	var/result = bot_pawn.work_on_target(controller.blackboard[target_key])
	if(!async_still_valid())
		return
	last_result = result
	switch(result)
		if(BOT_WORK_CONTINUE)
			// praca trwa: kolejny perform() po work_interval odpali ją znowu
			clear_async()
			modify_cooldown(world.time + bot_pawn.work_interval)
		if(BOT_WORK_DONE)
			finish_async(AI_BEHAVIOR_SUCCEEDED)
		else
			finish_async(AI_BEHAVIOR_FAILED)

/datum/bt_node/ai_behavior/bot_perform_work/finish_action(datum/ai_controller/basic_controller/bot/controller, succeeded)
	. = ..()
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	if(last_result != BOT_WORK_OUT_OF_REACH)
		controller.clear_blackboard_key(target_key)
		if(last_result == BOT_WORK_FAILED && istype(controller))
			controller.add_to_blacklist(target)
		if(istype(bot_pawn) && bot_pawn.mode == bot_pawn.work_mode)
			bot_pawn.update_bot_mode(BBOT_IDLE)
	last_result = null

/// Pogawędka bota bez celu, co jakiś czas
/datum/bt_node/ai_behavior/bot_idle_chatter
	var/chance = 15
	time_between_perform = 30 SECONDS

/datum/bt_node/ai_behavior/bot_idle_chatter/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	if(istype(bot_pawn) && !bot_pawn.client && prob(chance))
		INVOKE_ASYNC(bot_pawn, TYPE_PROC_REF(/mob/living/basic/bot, idle_chatter))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/// Najbliższy nadajnik patrolu na tym pokładzie
/datum/bt_node/ai_behavior/find_first_beacon_target
	var/target_key

/datum/bt_node/ai_behavior/find_first_beacon_target/perform(seconds_per_tick, datum/ai_controller/controller)
	var/closest_distance = INFINITY
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	var/atom/final_target
	var/atom/previous_target = controller.blackboard[BB_PREVIOUS_BEACON_TARGET]
	for(var/obj/machinery/navbeacon/beacon as anything in GLOB.navbeacons["[bot_pawn.z]"])
		if(isnull(beacon.codes?[NAVBEACON_PATROL_NEXT]))
			continue
		var/dist = get_dist(bot_pawn, beacon)
		if(beacon == previous_target || dist <= 1 || dist > closest_distance)
			continue
		closest_distance = dist
		final_target = beacon
	if(isnull(final_target))
		controller.set_blackboard_key(BB_BOT_BEACON_COOLDOWN, world.time + 30 SECONDS)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	controller.set_blackboard_key(target_key, final_target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/// Następny nadajnik z kodu „next_patrol” poprzedniego
/datum/bt_node/ai_behavior/find_next_beacon_target
	var/target_key
	time_between_perform = 5 SECONDS

/datum/bt_node/ai_behavior/find_next_beacon_target/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	var/obj/machinery/navbeacon/prev_beacon = controller.blackboard[BB_PREVIOUS_BEACON_TARGET]
	if(QDELETED(prev_beacon))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/next_location = prev_beacon.codes?[NAVBEACON_PATROL_NEXT]
	var/atom/final_target
	// NSV13: nadajniki całego okrętu, więc patrol przechodzi windami między pokładami
	var/obj/structure/overmap/ship = bot_pawn.get_overmap()
	var/list/beacons = ship ? ship.beacons_in_ship : GLOB.navbeacons["[bot_pawn.z]"]
	for(var/obj/machinery/navbeacon/beacon as anything in beacons)
		if(next_location && beacon.location == next_location)
			final_target = beacon
			break
	if(isnull(final_target))
		controller.clear_blackboard_key(BB_PREVIOUS_BEACON_TARGET)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	controller.set_blackboard_key(BB_PREVIOUS_BEACON_TARGET, final_target)
	controller.set_blackboard_key(target_key, final_target)
	return AI_BEHAVIOR_SUCCEEDED

/// Na nadajniku: zapamiętuje go jako poprzedni
/datum/bt_node/ai_behavior/arrive_at_beacon
	var/target_key

/datum/bt_node/ai_behavior/arrive_at_beacon/perform(seconds_per_tick, datum/ai_controller/controller)
	var/obj/machinery/navbeacon/beacon = controller.blackboard[target_key]
	if(QDELETED(beacon))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(get_dist(controller.pawn, beacon) > 0)
		return AI_BEHAVIOR_INSTANT
	controller.set_blackboard_key(BB_PREVIOUS_BEACON_TARGET, beacon)
	controller.clear_blackboard_key(target_key)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/move_to_target/multiz/beacon/finish_action(datum/ai_controller/controller, succeeded)
	if(!succeeded && movement_failed)
		controller.clear_blackboard_key(target_key)
		controller.set_blackboard_key(BB_BOT_BEACON_COOLDOWN, world.time + 30 SECONDS)
	return ..()

/// Koniec wezwania na miejscu
/datum/bt_node/ai_behavior/complete_summon_travel
	var/target_key

/datum/bt_node/ai_behavior/complete_summon_travel/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(bot_pawn) || QDELETED(target))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(get_dist(bot_pawn, target) > 0)
		return AI_BEHAVIOR_INSTANT
	bot_pawn.calling_ai_ref = null
	bot_pawn.update_bot_mode(BBOT_IDLE)
	controller.clear_blackboard_key(target_key)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/move_to_target/multiz/summon/finish_action(datum/ai_controller/controller, succeeded)
	if(!succeeded && movement_failed)
		var/mob/living/basic/bot/bot_pawn = controller.pawn
		INVOKE_ASYNC(bot_pawn, TYPE_PROC_REF(/mob/living/basic/bot, speak), "Nie mogę dotrzeć na miejsce wezwania.", bot_pawn.radio_channel)
		controller.clear_blackboard_key(target_key)
		bot_pawn.bot_reset()
	return ..()

/// Wezwanie z PDA albo od SI
/datum/bt_node/subtree/bot_respond_to_summon
	behavior_tree_json = "aquila/code/modules/mob/living/basic/bots/bot_respond_to_summon.bt.json"

/// Patrol po nadajnikach
/datum/bt_node/subtree/bot_patrol
	behavior_tree_json = "aquila/code/modules/mob/living/basic/bots/bot_patrol.bt.json"

/// Wspólny schemat pracy: znajdź cel, dojdź, pracuj
/datum/bt_node/subtree/bot_work
	behavior_tree_json = "aquila/code/modules/mob/living/basic/bots/bot_work.bt.json"

// --- Windy dla botów (NSV13): wezwanie i patrol na innym pokładzie

/// Najbliższa winda na tym pokładzie, która jedzie w danym kierunku (UP/DOWN)
/mob/living/basic/bot/proc/find_nearest_bot_elevator(direction)
	var/obj/structure/bot_elevator/best
	for(var/obj/structure/bot_elevator/elevator as anything in GLOB.bot_elevator)
		if(elevator.z != z)
			continue
		if((direction == UP && !elevator.up) || (direction == DOWN && !elevator.down))
			continue
		if(best && get_dist_euclidian(elevator, src) > get_dist_euclidian(best, src))
			continue
		best = elevator
	return best

/**
 * Idzie do celu, także na innym pokładzie: najpierw do windy dla botów w dobrą stronę, wjeżdża, potem dalej.
 * Na tym samym pokładzie działa jak zwykłe move_to_target.
 */
/datum/bt_node/ai_behavior/move_to_target/multiz
	VAR_PRIVATE/obj/structure/bot_elevator/elevator_target

/datum/bt_node/ai_behavior/move_to_target/multiz/perform(seconds_per_tick, datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	var/mob/living/basic/bot/bot_pawn = controller.pawn
	var/turf/target_turf = get_turf(target)
	if(QDELETED(target) || !target_turf || !istype(bot_pawn))
		return AI_BEHAVIOR_FAILED
	if(target_turf.z == bot_pawn.z)
		if(elevator_target)
			elevator_target = null
			tracked_target_reset(controller, target)
		return ..()
	if(movement_failed)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/direction = target_turf.z > bot_pawn.z ? UP : DOWN
	if(!elevator_target || elevator_target.z != bot_pawn.z)
		elevator_target = bot_pawn.find_nearest_bot_elevator(direction)
		if(!elevator_target)
			return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
		controller.ai_movement.start_moving_towards(controller, elevator_target, 0)
	else if(!controller.ai_movement.moving_controllers[controller])
		controller.ai_movement.start_moving_towards(controller, elevator_target, 0)
	if(get_turf(bot_pawn) == get_turf(elevator_target))
		controller.ai_movement.stop_moving_towards(controller)
		var/obj/structure/bot_elevator/next = direction == UP ? elevator_target.up : elevator_target.down
		if(next)
			INVOKE_ASYNC(elevator_target, TYPE_PROC_REF(/obj/structure/bot_elevator, travel), direction == UP, bot_pawn, FALSE, next, FALSE)
		elevator_target = null
	return AI_BEHAVIOR_INSTANT

/datum/bt_node/ai_behavior/move_to_target/multiz/proc/tracked_target_reset(datum/ai_controller/controller, atom/target)
	controller.ai_movement.start_moving_towards(controller, target, required_dist)

/datum/bt_node/ai_behavior/move_to_target/multiz/finish_action(datum/ai_controller/controller, succeeded)
	elevator_target = null
	return ..()
