// AQUILA: port of BeeStation/BeeStation-Hornet code/datums/ai/basic_mobs/basic_subtrees/speech_subtree.dm (bee/master 0adf0fe9ae)
/datum/ai_planning_subtree/random_speech
	//The chance of an emote occurring each second
	var/speech_chance = 0
	///Hearable emotes
	var/list/emote_hear
	///Unlike speak_emote, the list of things in this variable only show by themselves with no spoken text. IE: Ian barks, Ian yaps
	var/list/emote_see
	///Possible lines of speech the AI can have
	var/list/speak
	///The sound effects associated with this speech, if any
	var/list/sound

/datum/ai_planning_subtree/random_speech/New()
	. = ..()
	if(LAZYLEN(speak))
		speak = string_list(speak)
	if(LAZYLEN(sound))
		sound = string_list(sound)
	if(LAZYLEN(emote_hear))
		emote_hear = string_list(emote_hear)
	if(LAZYLEN(emote_see))
		emote_see = string_list(emote_see)

/datum/ai_planning_subtree/random_speech/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(!DT_PROB(speech_chance, delta_time))
		return
	speak(controller)

/// Actually perform an action
/datum/ai_planning_subtree/random_speech/proc/speak(datum/ai_controller/controller)
	var/audible_emotes_length = LAZYLEN(emote_hear)
	var/non_audible_emotes_length = LAZYLEN(emote_see)
	var/speak_lines_length = LAZYLEN(speak)

	var/total_choices_length = audible_emotes_length + non_audible_emotes_length + speak_lines_length

	if (total_choices_length == 0)
		return

	var/random_number_in_range = rand(1, total_choices_length)
	var/sound_to_play = length(sound) > 0 ? pick(sound) : null

	if(random_number_in_range <= audible_emotes_length)
		controller.queue_behavior(/datum/ai_behavior/perform_emote, pick(emote_hear), sound_to_play)
	else if(random_number_in_range <= (audible_emotes_length + non_audible_emotes_length))
		controller.queue_behavior(/datum/ai_behavior/perform_emote, pick(emote_see))
	else
		controller.queue_behavior(/datum/ai_behavior/perform_speech, pick(speak), sound_to_play)

// AQUILA: speech subtrees of the families live next to their mobs (Polish lines from our simple animals)
