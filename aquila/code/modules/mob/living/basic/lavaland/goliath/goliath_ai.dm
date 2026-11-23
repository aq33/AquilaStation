// AQUILA: port of tgstation code/modules/mob/living/basic/lavaland/goliath/goliath_ai.dm (tg 926bf40c5a). Our tentacles stun
// instead of tg's tentacle legcuffs, so "already grabbed" is a stunned target. No digging for roots (our asteroid sand has
// no dug state for it) and no target priority strategy.

/// We won't use tentacles unless we have had the same target for this long
#define MIN_TIME_TO_TENTACLE 3 SECONDS

/datum/ai_controller/basic_controller/goliath
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/call_reinforcements/mining,
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/targeted_mob_ability/goliath_tentacles,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/goliath,
	)

/// Is this target already held down by tentacles (our tentacles stun)
/proc/goliath_target_grabbed(atom/target)
	if (!isliving(target))
		return FALSE
	var/mob/living/living_target = target
	return living_target.IsStun()

/datum/ai_planning_subtree/basic_melee_attack_subtree/goliath
	operational_datums = list(/datum/component/ai_target_timer)
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/goliath

/// Go for the tentacles if they're available
/datum/ai_behavior/basic_melee_attack/goliath

/datum/ai_behavior/basic_melee_attack/goliath/perform(delta_time, datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	var/time_on_target = controller.blackboard[BB_BASIC_MOB_HAS_TARGET_TIME] || 0
	if (time_on_target < MIN_TIME_TO_TENTACLE)
		return ..()
	var/atom/target = controller.blackboard[target_key]
	// Interrupt attack chain to use tentacles, unless the target is already tentacled
	if (ismecha(target) || (isliving(target) && !goliath_target_grabbed(target)))
		var/datum/action/cooldown/using_action = controller.blackboard[BB_GOLIATH_TENTACLES]
		if (using_action?.IsAvailable())
			return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	return ..()

/datum/ai_planning_subtree/targeted_mob_ability/goliath_tentacles
	ability_key = BB_GOLIATH_TENTACLES
	operational_datums = list(/datum/component/ai_target_timer)

/datum/ai_planning_subtree/targeted_mob_ability/goliath_tentacles/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/atom/target = controller.blackboard[target_key]
	if (!(isliving(target) || ismecha(target)) || goliath_target_grabbed(target))
		return // Target can be an item or already grabbed, we don't want to tentacle those
	var/time_on_target = controller.blackboard[BB_BASIC_MOB_HAS_TARGET_TIME] || 0
	if (time_on_target < MIN_TIME_TO_TENTACLE)
		return // We need to spend some time acquiring our target first
	return ..()

#undef MIN_TIME_TO_TENTACLE
