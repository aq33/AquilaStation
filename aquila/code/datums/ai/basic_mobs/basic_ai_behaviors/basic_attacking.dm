// AQUILA: port of BeeStation/BeeStation-Hornet code/datums/ai/basic_mobs/basic_ai_behaviors/basic_attacking.dm (bee/master 0adf0fe9ae)
/// Amount of time to wait before executing attack if not specified
#define DEFAULT_ATTACK_DELAY (0.4 SECONDS)

/datum/ai_behavior/basic_melee_attack
	action_cooldown = 0.2 SECONDS // We gotta check unfortunately often because we're in a race condition with nextmove
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	///do we finish this action after hitting once?
	var/terminate_after_action = FALSE

/datum/ai_behavior/basic_melee_attack/setup(datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	if(!controller.blackboard[targeting_strategy_key])
		CRASH("No targeting strategy was supplied in the blackboard for [controller.pawn]")

	//Hiding location is priority
	var/atom/target = controller.blackboard[hiding_location_key] || controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE

	set_movement_target(controller, target)

/datum/ai_behavior/basic_melee_attack/perform(delta_time, datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	var/atom/target = controller.blackboard[target_key]
	if (isnull(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if (!target.IsReachableBy(controller.pawn))
		controller.clear_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER)
		return AI_BEHAVIOR_INSTANT

	var/can_attack_time = controller.blackboard[BB_BASIC_MOB_MELEE_COOLDOWN_TIMER]
	if (isnull(can_attack_time))
		var/blackboard_delay = controller.blackboard[BB_BASIC_MOB_MELEE_DELAY]
		var/attack_delay = isnull(blackboard_delay) ? DEFAULT_ATTACK_DELAY : blackboard_delay
		controller.set_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER, world.time + attack_delay)
		return AI_BEHAVIOR_INSTANT
	if (can_attack_time > world.time)
		return AI_BEHAVIOR_INSTANT

	if (isliving(controller.pawn))
		var/mob/living/pawn = controller.pawn
		if (world.time < pawn.next_move)
			return AI_BEHAVIOR_INSTANT

	var/datum/targeting_strategy/targeting_strategy = GET_TARGETING_STRATEGY(controller.blackboard[targeting_strategy_key])
	if(!targeting_strategy.can_attack(controller.pawn, target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/hiding_target = targeting_strategy.find_hidden_mobs(controller.pawn, target) //If this is valid, theyre hidden in something!

	controller.set_blackboard_key(hiding_location_key, hiding_target)

	var/atom/final_target = hiding_target || target
	controller.ai_interact(target = final_target, combat_mode = TRUE)

	if(terminate_after_action)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY

/datum/ai_behavior/basic_melee_attack/finish_action(datum/ai_controller/controller, succeeded, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	controller.clear_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER)
	if(!succeeded)
		controller.clear_blackboard_key(target_key)

// AQUILA: basic_ranged_attack needs /datum/component/ranged_attacks, not ported yet (no ranged basic mobs)

#undef DEFAULT_ATTACK_DELAY
