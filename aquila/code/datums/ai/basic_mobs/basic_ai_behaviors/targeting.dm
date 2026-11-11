// AQUILA: port of BeeStation/BeeStation-Hornet code/datums/ai/basic_mobs/basic_ai_behaviors/targeting.dm (bee/master 0adf0fe9ae)
// AQUILA: Bee waits for targets with an ai_target_tracking proximity field and also targets hostile machines
// (hostile_machine element, turrets). Neither is ported: like the spatial grid (decision D4) the field is left for later,
// so the behaviour polls with hearers(). AQUILA: every empty scan doubles the wait (2, 4, 8, 16, 30 s), a found target or
// an attack on the mob resets it (/datum/ai_controller/basic_controller/proc/reset_target_search_backoff()).

/datum/ai_behavior/find_potential_targets
	action_cooldown = 2 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	/// How far can we see stuff?
	var/vision_range = 9
	/// Blackboard key for aggro range, uses vision range if not specified
	var/aggro_range_key = BB_AGGRO_RANGE

/datum/ai_behavior/find_potential_targets/get_cooldown(datum/ai_controller/cooldown_for)
	var/empty_scans = cooldown_for.blackboard[BB_FIND_TARGETS_EMPTY_SCANS]
	if(!empty_scans)
		return action_cooldown
	return min(action_cooldown * (2 ** min(empty_scans, 5)), FIND_TARGETS_MAX_BACKOFF)

/datum/ai_behavior/find_potential_targets/perform(delta_time, datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	var/mob/living/living_mob = controller.pawn
	var/datum/targeting_strategy/targeting_strategy = GET_TARGETING_STRATEGY(controller.blackboard[targeting_strategy_key])

	if(!targeting_strategy)
		CRASH("No targeting strategy was supplied in the blackboard for [controller.pawn]")

	var/atom/current_target = controller.blackboard[target_key]
	if (targeting_strategy.can_attack(living_mob, current_target, vision_range))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/aggro_range = controller.blackboard[aggro_range_key] || vision_range

	controller.clear_blackboard_key(target_key)

	var/list/potential_targets = hearers(aggro_range, get_turf(controller.pawn)) - living_mob //Remove self, so we don't suicide

	if(!potential_targets.len)
		controller.add_blackboard_key(BB_FIND_TARGETS_EMPTY_SCANS, 1)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/list/filtered_targets = list()

	for(var/atom/pot_target in potential_targets)
		if(targeting_strategy.can_attack(living_mob, pot_target))//Can we attack it?
			filtered_targets += pot_target
			continue

	if(!filtered_targets.len)
		controller.add_blackboard_key(BB_FIND_TARGETS_EMPTY_SCANS, 1)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.clear_blackboard_key(BB_FIND_TARGETS_EMPTY_SCANS)
	var/atom/target = pick_final_target(controller, filtered_targets)
	controller.set_blackboard_key(target_key, target)

	var/atom/potential_hiding_location = targeting_strategy.find_hidden_mobs(living_mob, target)

	if(potential_hiding_location) //If they're hiding inside of something, we need to know so we can go for that instead initially.
		controller.set_blackboard_key(hiding_location_key, potential_hiding_location)

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/find_potential_targets/finish_action(datum/ai_controller/controller, succeeded, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	if (succeeded)
		controller.CancelActions() // On retarget cancel any further queued actions so that they will setup again with new target
		controller.modify_cooldown(src, get_cooldown(controller))

/// Returns the desired final target from the filtered list of targets
/datum/ai_behavior/find_potential_targets/proc/pick_final_target(datum/ai_controller/controller, list/filtered_targets)
	return pick(filtered_targets)

/// Targets with the trait specified by the BB_TARGET_PRIORITY_TRAIT blackboard key will be prioritized over the rest.
/datum/ai_behavior/find_potential_targets/prioritize_trait

/datum/ai_behavior/find_potential_targets/prioritize_trait/pick_final_target(datum/ai_controller/controller, list/filtered_targets)
	var/priority_targets = list()
	for(var/atom/target as anything in filtered_targets)
		if(HAS_TRAIT(target, controller.blackboard[BB_TARGET_PRIORITY_TRAIT]))
			priority_targets += target
	if(length(priority_targets))
		return pick(priority_targets)
	return ..()

/datum/ai_behavior/find_potential_targets/bigger_range
	vision_range = 16
