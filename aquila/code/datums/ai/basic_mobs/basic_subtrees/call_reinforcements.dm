// AQUILA: port of tgstation code/datums/ai/basic_mobs/basic_subtrees/call_reinforcements.dm (tg 926bf40c5a) for the troopers.
// Changes against tg:
// - our retaliate list is Bee's plain lazylist (insert_blackboard_key_lazylist), tg keeps an assoc list with the time;
// - faction_check_mob() instead of tg's faction_check_atom();
// - the mining variant (mining mobs) is the plain call with tg's mining range and cooldown (no target priority strategies);
//   it only fills the retaliate lists (nobody reads the reinforcement target of a mining mob) and never sends the pack after
//   a fellow mining mob (a legion's target can be a hurt friend it wants to heal).

/// Calls all nearby mobs that share a faction to give backup in combat
/datum/ai_planning_subtree/call_reinforcements
	/// Blackboard key containing something to say when calling reinforcements (takes precedence over emotes)
	var/say_key = BB_REINFORCEMENTS_SAY
	/// Blackboard key containing an emote to perform when calling reinforcements
	var/emote_key = BB_REINFORCEMENTS_EMOTE
	/// Reinforcement-calling behavior to use
	var/call_type = /datum/ai_behavior/call_reinforcements

/datum/ai_planning_subtree/call_reinforcements/SelectBehaviors(datum/ai_controller/controller, delta_time)
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

/datum/ai_behavior/call_reinforcements/perform(delta_time, datum/ai_controller/controller)
	var/mob/pawn_mob = controller.pawn
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	for(var/mob/other_mob in oview(reinforcements_range, pawn_mob))
		if(isnull(other_mob.ai_controller) || !pawn_mob.faction_check_mob(other_mob))
			continue
		// Add our current target to their retaliate list so that they'll attack our aggressor
		if(!QDELETED(target))
			other_mob.ai_controller.insert_blackboard_key_lazylist(BB_BASIC_MOB_RETALIATE_LIST, target)
		other_mob.ai_controller.set_blackboard_key(BB_BASIC_MOB_REINFORCEMENT_TARGET, pawn_mob)

	controller.set_blackboard_key(BB_BASIC_MOB_REINFORCEMENTS_COOLDOWN, world.time + cooldown)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/// Mining mobs call often and only the mobs close by (tg's range and cooldown)
/datum/ai_behavior/call_reinforcements/mining
	cooldown = 1 SECONDS
	reinforcements_range = 7

/datum/ai_behavior/call_reinforcements/mining/perform(delta_time, datum/ai_controller/controller)
	var/mob/pawn_mob = controller.pawn
	var/mob/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(ismob(target) && !QDELETED(target) && !pawn_mob.faction_check_mob(target))
		for(var/mob/other_mob in oview(reinforcements_range, pawn_mob))
			if(other_mob == target || isnull(other_mob.ai_controller) || !pawn_mob.faction_check_mob(other_mob))
				continue
			other_mob.ai_controller.insert_blackboard_key_lazylist(BB_BASIC_MOB_RETALIATE_LIST, target)
	controller.set_blackboard_key(BB_BASIC_MOB_REINFORCEMENTS_COOLDOWN, world.time + cooldown)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
