// AQUILA: random_speech/blackboard and random_speech/when_has_target from tgstation code/datums/ai/basic_mobs/basic_subtrees/speech_subtree.dm
// and mimic_ai.dm (tg 926bf40c5a). Bee's speech subtree has only the lists on the subtree; these read the lines from the
// BB_BASIC_MOB_SPEAK_LINES blackboard key (an assoc list: BB_EMOTE_SAY, BB_EMOTE_HEAR, BB_EMOTE_SEE, BB_EMOTE_SOUND,
// BB_SPEAK_CHANCE) and fall back to the subtree's own lists without it.

/// Speech taken from the blackboard, so one controller serves mobs with different lines (clowns, vending machine mimics)
/datum/ai_planning_subtree/random_speech/blackboard

/datum/ai_planning_subtree/random_speech/blackboard/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/list/speech_lines = controller.blackboard[BB_BASIC_MOB_SPEAK_LINES]
	if(!islist(speech_lines))
		return ..()
	var/chance = speech_lines[BB_SPEAK_CHANCE]
	if(!DT_PROB(isnull(chance) ? speech_chance : chance, delta_time))
		return
	speak_from_lines(controller, speech_lines)

/// Picks a line or an emote from the blackboard lists
/datum/ai_planning_subtree/random_speech/blackboard/proc/speak_from_lines(datum/ai_controller/controller, list/speech_lines)
	var/list/say_lines = speech_lines[BB_EMOTE_SAY]
	var/list/hear_lines = speech_lines[BB_EMOTE_HEAR]
	var/list/see_lines = speech_lines[BB_EMOTE_SEE]
	var/list/sounds = speech_lines[BB_EMOTE_SOUND]
	var/total = LAZYLEN(say_lines) + LAZYLEN(hear_lines) + LAZYLEN(see_lines)
	if(!total)
		return
	var/roll = rand(1, total)
	var/sound_to_play = LAZYLEN(sounds) ? pick(sounds) : null
	if(roll <= LAZYLEN(hear_lines))
		controller.queue_behavior(/datum/ai_behavior/perform_emote, pick(hear_lines), sound_to_play)
	else if(roll <= LAZYLEN(hear_lines) + LAZYLEN(see_lines))
		controller.queue_behavior(/datum/ai_behavior/perform_emote, pick(see_lines))
	else
		controller.queue_behavior(/datum/ai_behavior/perform_speech, pick(say_lines), sound_to_play)

/// Speaks only while the mob has a target
/datum/ai_planning_subtree/random_speech/blackboard/when_has_target
	/// target key
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET

/datum/ai_planning_subtree/random_speech/blackboard/when_has_target/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(!controller.blackboard_key_exists(target_key))
		return
	return ..()
