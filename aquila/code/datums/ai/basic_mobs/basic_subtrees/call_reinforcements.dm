// AQUILA: port of tgstation code/datums/ai/basic_mobs/basic_subtrees/call_reinforcements.dm (tg 926bf40c5a) for the basic
// mining mobs. We have no target priority strategies (tg's mining variant raises the priority of whoever attacked a mob
// nearby), so the mining call is the plain one with tg's mining range and cooldown: friends of the same faction nearby put
// the attacker on their retaliate list.

/// Calls all nearby mobs that share a faction to give backup in combat
/datum/ai_planning_subtree/call_reinforcements
	/// Blackboard key containing something to say when calling reinforcements (takes precedence over emotes)
	var/say_key = BB_REINFORCEMENTS_SAY
	/// Blackboard key containing an emote to perform when calling reinforcements
	var/emote_key = BB_REINFORCEMENTS_EMOTE
	/// Reinforcement-calling behavior to use
	var/call_type = /datum/ai_behavior/call_reinforcements

/datum/ai_planning_subtree/call_reinforcements/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	if (!decide_to_call(controller) || controller.blackboard[BB_BASIC_MOB_REINFORCEMENTS_COOLDOWN] > world.time)
		return

	var/call_say = controller.blackboard[say_key]
	var/call_emote = controller.blackboard[emote_key]

	if(!isnull(call_say))
		controller.queue_behavior(/datum/ai_behavior/perform_speech, call_say)
	else if(!isnull(call_emote))
		controller.queue_behavior(/datum/ai_behavior/perform_emote, call_emote)

	controller.queue_behavior(call_type)

/// Decides when to call reinforcements, can be overridden for alternate behavior
/datum/ai_planning_subtree/call_reinforcements/proc/decide_to_call(datum/ai_controller/controller)
	return controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET) && ismob(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET])

/datum/ai_planning_subtree/call_reinforcements/mining
	call_type = /datum/ai_behavior/call_reinforcements/mining

/// Call out to all mobs in the specified range for help
/datum/ai_behavior/call_reinforcements
	/// How frequently can we call for reinforcements?
	var/cooldown = 30 SECONDS
	/// Range to call reinforcements from
	var/reinforcements_range = 15

/datum/ai_behavior/call_reinforcements/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/pawn_mob = controller.pawn
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	for(var/mob/other_mob in oview(reinforcements_range, pawn_mob))
		if(!pawn_mob.faction_check_mob(other_mob) || isnull(other_mob.ai_controller))
			continue
		// Add our current target to their retaliate list (our list has no timestamps) so that they'll attack our aggressor
		other_mob.ai_controller.insert_blackboard_key_lazylist(BB_BASIC_MOB_RETALIATE_LIST, target)

	controller.set_blackboard_key(BB_BASIC_MOB_REINFORCEMENTS_COOLDOWN, world.time + cooldown)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/// Mining mobs call often and only the mobs close by (tg's range and cooldown)
/datum/ai_behavior/call_reinforcements/mining
	cooldown = 1 SECONDS
	reinforcements_range = 7
