// AQUILA: port of BeeStation/BeeStation-Hornet code/datums/ai/basic_mobs/basic_subtrees/simple_attack_target.dm (bee/master 0adf0fe9ae)
/datum/ai_planning_subtree/basic_melee_attack_subtree
	/// What do we do in order to attack someone?
	var/datum/ai_behavior/basic_melee_attack/melee_attack_behavior = /datum/ai_behavior/basic_melee_attack
	/// Is this the last thing we do? (if we set a movement target, this will usually be yes)
	var/end_planning = TRUE

/datum/ai_planning_subtree/basic_melee_attack_subtree/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	if(!controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET))
		return
	controller.queue_behavior(melee_attack_behavior, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
	if (end_planning)
		return SUBTREE_RETURN_FINISH_PLANNING //we are going into battle...no distractions.

// AQUILA: basic_ranged_attack_subtree needs /datum/component/ranged_attacks, not ported yet (no ranged basic mobs)
