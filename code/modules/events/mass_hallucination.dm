/datum/round_event_control/mass_hallucination
	name = "Mass Hallucination"
	typepath = /datum/round_event/mass_hallucination
	weight = 10
	max_occurrences = 2
	min_players = 1

/datum/round_event/mass_hallucination
	fakeable = FALSE

// AQ EDIT START - halucynacje jako efekt statusu (Bee#13095), wybór jak w Bee
/datum/round_event/mass_hallucination/start()
	var/picked_hallucination
	var/list/other_args
	switch(rand(1, 10))
		if(1) // ten sam dźwięk dla wszystkich
			picked_hallucination = get_random_valid_hallucination_subtype(/datum/hallucination/fake_sound/normal)
		if(2) // ten sam dziwny dźwięk
			picked_hallucination = get_random_valid_hallucination_subtype(/datum/hallucination/fake_sound/weird)
		if(3) // to samo ogłoszenie
			picked_hallucination = get_random_valid_hallucination_subtype(/datum/hallucination/station_message)
		if(4) // wszyscy inni wyglądają tak samo
			picked_hallucination = get_random_valid_hallucination_subtype(/datum/hallucination/delusion/preset)
			other_args = list(duration = 30 SECONDS, skip_nearby = FALSE, affects_us = FALSE, affects_others = TRUE, play_wabbajack = FALSE)
		if(5) // tylko halucynujący wygląda inaczej
			picked_hallucination = get_random_valid_hallucination_subtype(/datum/hallucination/delusion/preset)
			other_args = list(duration = 45 SECONDS, skip_nearby = FALSE, affects_us = TRUE, affects_others = FALSE, play_wabbajack = TRUE)
		if(6 to 10)
			picked_hallucination = pick(
				/datum/hallucination/bolts,
				/datum/hallucination/chat,
				/datum/hallucination/death,
				/datum/hallucination/fake_flood,
				/datum/hallucination/fire,
				/datum/hallucination/message,
				/datum/hallucination/oh_yeah,
				/datum/hallucination/xeno_attack,
			)
	if(!picked_hallucination)
		return

	var/list/hallucination_args = list(picked_hallucination, "mass hallucination")
	if(islist(other_args))
		hallucination_args += other_args

	for(var/mob/living/carbon/hallucinating as anything in GLOB.carbon_list)
		if(is_centcom_level(hallucinating.z) || hallucinating.stat == DEAD)
			continue
		if(!hallucinating.client && !is_station_level(hallucinating.z))
			continue
		hallucinating._cause_hallucination(hallucination_args)
// AQ EDIT END
