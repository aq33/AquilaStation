/// Sends a fake chat message to the hallucinator.
/datum/hallucination/chat
	random_hallucination_weight = 100
	hallucination_tier = HALLUCINATION_TIER_COMMON

	/// If TRUE, we force the message to be hallucinated from common radio. Only set in New()
	var/force_radio
	/// If set, a message we force to be picked, rather than an auto-generated message. Only set in New()
	var/specific_message

/datum/hallucination/chat/New(mob/living/hallucinator, force_radio = FALSE, specific_message)
	src.force_radio = force_radio
	src.specific_message = specific_message
	return ..()

/datum/hallucination/chat/start()
	// tgstation/tgstation#89865: mówi ktoś, kto zna język, który rozumie halucynujący (trup mówi czymkolwiek)
	var/mob/living/carbon/human/speaker
	var/datum/language_holder/our_holder = hallucinator.get_language_holder()
	var/list/understood_languages = our_holder.understood_languages
	var/understood_language

	if(!force_radio)
		var/list/valid_humans = list()
		var/list/valid_corpses = list()
		for(var/mob/living/carbon/human/nearby_human in view(hallucinator))
			if(nearby_human == hallucinator)
				continue
			if(nearby_human.stat == DEAD)
				valid_corpses += nearby_human
				continue
			valid_humans += nearby_human

		for(var/mob/living/carbon/human/nearby_human in shuffle(valid_humans))
			var/datum/language_holder/their_holder = nearby_human.get_language_holder()
			var/list/shared_languages = their_holder.spoken_languages & understood_languages
			if(!length(shared_languages))
				continue
			speaker = nearby_human
			understood_language = pick(shared_languages)
			break

		if(isnull(speaker) && length(valid_corpses))
			speaker = pick(valid_corpses)

	// Get person to affect if radio hallucination
	var/is_radio = force_radio || isnull(speaker)
	if(is_radio)
		for(var/mob/living/carbon/human/existing_human in shuffle(GLOB.alive_mob_list))
			if(existing_human == hallucinator || !existing_human.mind)
				continue
			var/datum/language_holder/their_holder = existing_human.get_language_holder()
			var/list/shared_languages = their_holder.spoken_languages & understood_languages
			if(!length(shared_languages))
				continue
			speaker = existing_human
			understood_language = pick(shared_languages)
			break

	if(isnull(speaker))
		return FALSE
	if(!understood_language)
		understood_language = hallucinator.get_random_understood_language()

	// Time to generate a message.
	// Spans of our message
	var/spans = list(speaker.speech_span)

	// Contents of our message
	var/chosen = specific_message
	// If we didn't have a preset one, let's make one up.
	if(!chosen)
		if(is_radio)
			chosen = pick(list("Pomocy!",
				"[pick_list_replacements(HALLUCINATION_FILE, "people")] jest [pick_list_replacements(HALLUCINATION_FILE, "accusations")]!",
				"[pick_list_replacements(HALLUCINATION_FILE, "threat")] – [pick_list_replacements(HALLUCINATION_FILE, "location")][prob(50)?"!":"!!"]",
				"[pick("Gdzie jest [hallucinator.first_name()]?", "Ustawcie [hallucinator.first_name()] do aresztowania!")]",
				"[pick("Wezwijcie prom","SI, wezwij prom","Niech ktoś wezwie prom","Wezwać prom")]!",
				"SI [pick("zbuntowana", "nie żyje")]!!",
				"Borgi się zbuntowały!",
			))
		else
			chosen = pick(list("[pick_list_replacements(HALLUCINATION_FILE, "suspicion")]",
				"[pick_list_replacements(HALLUCINATION_FILE, "conversation")]",
				"[pick_list_replacements(HALLUCINATION_FILE, "greetings")][hallucinator.first_name()]!",
				"[pick_list_replacements(HALLUCINATION_FILE, "getout")]",
				"[pick_list_replacements(HALLUCINATION_FILE, "weird")]",
				"[pick_list_replacements(HALLUCINATION_FILE, "didyouhearthat")]",
				"[pick_list_replacements(HALLUCINATION_FILE, "doubt")]",
				"[pick_list_replacements(HALLUCINATION_FILE, "aggressive")]",
				"[pick_list_replacements(HALLUCINATION_FILE, "help")]!!",
				"[pick_list_replacements(HALLUCINATION_FILE, "escape")]",
				"Jestem zarażony, [pick_list_replacements(HALLUCINATION_FILE, "infection_advice")]!",
			))

		chosen = capitalize(chosen)

	chosen = replacetext(chosen, "%TARGETNAME%", hallucinator.first_name())

	// Log the message
	feedback_details += "Type: [is_radio ? "Radio" : "Talk"], Source: [speaker.real_name], Message: [chosen]"

	var/plus_runechat = (hallucinator.client?.prefs?.toggles & PREFTOGGLE_RUNECHAT_GLOBAL)

	// Display the message
	if(!is_radio && !plus_runechat)
		var/image/speech_overlay = image('icons/mob/talk.dmi', speaker, "default0", layer = ABOVE_MOB_LAYER)
		flick_overlay(speech_overlay, list(hallucinator.client), 3 SECONDS)

	if(plus_runechat)
		create_chat_message(speaker = speaker, message_language = understood_language, raw_message = chosen, spans = spans)

	// And actually show them the message, for real.
	var/message = hallucinator.compose_message(speaker, understood_language, chosen, is_radio ? "[FREQ_COMMON]" : null, spans, face_name = TRUE)
	to_chat(hallucinator, message)

	// Then clean up.
	qdel(src)
	return TRUE
