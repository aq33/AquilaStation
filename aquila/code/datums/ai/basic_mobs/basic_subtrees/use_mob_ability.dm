// AQUILA: port of tgstation code/datums/ai/basic_mobs/basic_subtrees/use_mob_ability.dm (tg 926bf40c5a, same as Bee's)
// with the ability type check of decision D6 (usable_by_ai() below).

/**
 * AQUILA: can an AI controller use this action through Trigger(target = x) and InterceptClickOn()?
 * Mob abilities (mob_cooldown) and spells have both; our other actions (spider abilities, pulse demon, item actions) do not,
 * and a named `target` argument their Trigger() lacks is a runtime, so the ability behaviours refuse them.
 */
/datum/action/proc/usable_by_ai()
	return FALSE

/datum/action/cooldown/mob_cooldown/usable_by_ai()
	return TRUE

/datum/action/cooldown/spell/usable_by_ai()
	return TRUE

/// AQUILA: Trigger(target = target) of an action usable by the AI (tg calls it on any /datum/action/cooldown)
/datum/action/proc/ai_trigger_on(atom/target)
	return FALSE

/datum/action/cooldown/mob_cooldown/ai_trigger_on(atom/target)
	return Trigger(target = target)

/datum/action/cooldown/spell/ai_trigger_on(atom/target)
	return Trigger(target = target)

/**
 * Simple behaviours which simply try to use an ability whenever it is available.
 * For something which wants a target try `targeted_mob_ability`.
 */
/datum/ai_planning_subtree/use_mob_ability
	/// Blackboard key for the ability
	var/ability_key = BB_GENERIC_ACTION
	/// Behaviour to perform using ability
	var/use_ability_behaviour = /datum/ai_behavior/use_mob_ability
	/// If true we terminate planning after trying to use the ability.
	var/finish_planning = FALSE

/datum/ai_planning_subtree/use_mob_ability/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if (!ability_key)
		CRASH("You forgot to tell this mob where to find its ability")

	var/datum/action/using_action = controller.blackboard[ability_key]
	if (!using_action?.usable_by_ai() || !using_action.IsAvailable())
		return

	controller.queue_behavior(use_ability_behaviour, ability_key)
	if (finish_planning)
		return SUBTREE_RETURN_FINISH_PLANNING

/// Uses the ability in the blackboard key on the user. Abilities given to an AI must not sleep in Activate()/cast().
/datum/ai_behavior/use_mob_ability

/datum/ai_behavior/use_mob_ability/perform(delta_time, datum/ai_controller/controller, ability_key)
	var/datum/action/using_action = controller.blackboard[ability_key]
	if (QDELETED(using_action) || !using_action.usable_by_ai())
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(using_action.Trigger())
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
