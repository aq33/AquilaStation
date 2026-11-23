// AQUILA: port of tgstation code/datums/ai/basic_mobs/basic_subtrees/run_emote.dm (tg 926bf40c5a). The emote runs through
// INVOKE_ASYNC, so an emote that sleeps cannot hold up the behaviour (tg calls it directly).

/// Intermittently run an emote
/datum/ai_planning_subtree/run_emote
	var/emote_key = BB_EMOTE_KEY
	var/emote_chance_key = BB_EMOTE_CHANCE

/datum/ai_planning_subtree/run_emote/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/emote_chance = controller.blackboard[emote_chance_key] || 0
	if (!SPT_PROB(emote_chance, delta_time))
		return
	controller.queue_behavior(/datum/ai_behavior/run_emote, emote_key)

/// Emote from a blackboard key (an emote key such as "scream", or a list of them)
/datum/ai_behavior/run_emote

/datum/ai_behavior/run_emote/perform(delta_time, datum/ai_controller/controller, emote_key)
	var/mob/living/living_pawn = controller.pawn
	if (!isliving(living_pawn))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/list/emote_list = controller.blackboard[emote_key]
	var/emote
	if (islist(emote_list))
		emote = length(emote_list) ? pick(emote_list) : null
	else
		emote = emote_list

	if(isnull(emote))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	INVOKE_ASYNC(living_pawn, TYPE_PROC_REF(/mob, emote), emote)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
