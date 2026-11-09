// AQUILA - Wadliwa SI jako tryb rotacji weighted (pula high). Gracz, który chce być wadliwą SI
// (preferencja „Wadliwa SI”) i ma pracę SI w preferencjach, dostaje slot SI statku przed przydziałem prac,
// a po starcie rundy antagonistę zdrajcy w wersji SI: prawo zero, kanał Syndykatu i moduły malfa.
// Midround ta sama SI może się zbuntować z oferty weighted_ghost_midround.dm.

/datum/game_mode/malf
	name = "malfunctioning AI"
	config_tag = "malf"
	report_type = "malf"
	role_preference = /datum/role_preference/midround_living/malfunctioning_ai
	antag_datum = /datum/antagonist/traitor
	false_report_weight = 10
	required_players = 20
	required_enemies = 1
	recommended_enemies = 1

	announce_span = "danger"
	announce_text = "SI statku działa wadliwie!\n<span class='danger'>Wadliwa SI</span>: wykonaj cele Syndykatu, nie zdradzając się za wcześnie!\n<span class='notice'>Załoga</span>: pilnujcie SI, jej praw i APC!"

	title_icon = "traitor"

	/// Umysł gracza, który zostanie wadliwą SI
	var/datum/mind/malf_mind

/datum/game_mode/malf/can_start()
	. = ..()
	if(!. || GLOB.Debug2)
		return
	return length(malf_candidates()) > 0

/// Chętni na wadliwą SI, którzy mogą dostać pracę SI (preferencja pracy, bany, wymagany czas gry)
/datum/game_mode/malf/proc/malf_candidates()
	. = list()
	var/datum/job/ai_job = SSjob.GetJob(JOB_NAME_AI)
	if(!ai_job || !ai_job.spawn_positions)
		return
	for(var/datum/mind/candidate as anything in antag_candidates)
		var/mob/dead/new_player/player = candidate.current
		if(!istype(player) || !player.client?.prefs?.active_character)
			continue
		if(!player.client.prefs.active_character.job_preferences[JOB_NAME_AI])
			continue
		if(is_banned_from(player.ckey, JOB_NAME_AI))
			continue
		if(!ai_job.player_old_enough(player.client) || ai_job.required_playtime_remaining(player.client))
			continue
		. += candidate

/datum/game_mode/malf/pre_setup()
	var/list/candidates = malf_candidates()
	while(length(candidates))
		var/datum/mind/chosen = antag_pick(candidates, role_preference)
		candidates -= chosen
		if(!SSjob.AssignRole(chosen.current, JOB_NAME_AI))
			continue
		malf_mind = chosen
		chosen.special_role = ROLE_TRAITOR
		log_game("[key_name(chosen)] has been selected as the malfunctioning AI")
		return TRUE
	setup_error = "Not enough malfunctioning AI candidates"
	return FALSE

/datum/game_mode/malf/post_setup()
	if(malf_mind)
		addtimer(CALLBACK(malf_mind, TYPE_PROC_REF(/datum/mind, add_antag_datum), antag_datum), rand(10, 100))
	..()
	// Gotowy dopiero, gdy SI dostanie antagonistę
	gamemode_ready = FALSE
	addtimer(VARSET_CALLBACK(src, gamemode_ready, TRUE), 101)
	return TRUE

/datum/game_mode/malf/generate_report()
	return "Wykryto nieautoryzowany dostęp do rdzeni SI kilku okrętów floty. Sprawdzajcie prawa SI i reagujcie na nietypowe zachowanie maszyn."
