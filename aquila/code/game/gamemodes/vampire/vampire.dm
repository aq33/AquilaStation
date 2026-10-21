// Tryby rundy dla wampira z BeeStation (/datum/antagonist/vampire). Bee daje go przez dynamic,
// u nas zostają stare tryby "vampire" i "traitorvamp" (config + weighted).

/datum/game_mode/vampire
	name = "vampire"
	config_tag = "vampire"
	report_type = "vampire"
	role_preference = /datum/role_preference/antagonist/vampire
	antag_datum = /datum/antagonist/vampire
	false_report_weight = 1
	restricted_jobs = list(JOB_NAME_AI, JOB_NAME_CYBORG, JOB_NAME_CURATOR)
	protected_jobs = list(JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN, JOB_NAME_HEADOFPERSONNEL, JOB_NAME_RESEARCHDIRECTOR, JOB_NAME_CHIEFENGINEER, JOB_NAME_CHIEFMEDICALOFFICER, JOB_NAME_SECURITYOFFICER, JOB_NAME_CHAPLAIN, JOB_NAME_DETECTIVE, JOB_NAME_WARDEN, JOB_NAME_BRIGPHYSICIAN, JOB_NAME_PILOT, JOB_NAME_MASTERATARMS) //AQ EDIT: NSV pilots and master at arms
	required_players = 15
	required_enemies = 1
	recommended_enemies = 3

	announce_text = "Na pokładzie stacji są wampiry!\n\
		+	<span class='danger'>Wampiry</span>: żerujcie na załodze, zachowajcie Maskaradę i wykonajcie swoje cele!\n\
		+	<span class='notice'>Załoga</span>: znajdźcie nieumarłych i przebijcie ich kołkami!"

	/// Twardy limit wampirów, gdy skalowanie jest wyłączone
	var/vampires_possible = 4
	var/num_modifier = 0
	var/list/datum/mind/pre_vamps = list()

/datum/game_mode/vampire/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += JOB_NAME_ASSISTANT

	var/num_vamps = 1
	var/tsc = CONFIG_GET(number/traitor_scaling_coeff)
	if(tsc)
		num_vamps = max(1, min(round(num_players() / (tsc * 2)) + 2 + num_modifier, round(num_players() / tsc) + num_modifier))
	else
		num_vamps = max(1, min(num_players(), vampires_possible))

	for(var/j in 1 to num_vamps)
		if(!length(antag_candidates))
			break
		var/datum/mind/vamp = antag_pick(antag_candidates, /datum/role_preference/antagonist/vampire)
		antag_candidates -= vamp
		pre_vamps += vamp
		vamp.special_role = ROLE_VAMPIRE
		vamp.restricted_roles = restricted_jobs
		log_game("[key_name(vamp)] has been selected as a Vampire")

	return length(pre_vamps) > 0

/datum/game_mode/vampire/post_setup()
	for(var/datum/mind/vamp in pre_vamps)
		vamp.add_antag_datum(/datum/antagonist/vampire)
	return ..()

/datum/game_mode/vampire/generate_report()
	return "Kilka stacji w sąsiednich sektorach zgłosiło statystycznie anomalny wzrost przypadków kosmicznej wścieklizny. Bądźcie przygotowani na wynikające z tego nagłe przypadki medyczne. Ochrona powinna eskortować zarażonych członków załogi do ambulatorium i zgłaszać \
	wszelkie nietypowe obserwacje Centralnemu Dowództwu bezpiecznym kanałem."

/datum/game_mode/traitor/vampire
	name = "traitor+vampire"
	config_tag = "traitorvamp"
	report_type = "traitorvamp"
	false_report_weight = 10
	traitors_possible = 3
	restricted_jobs = list(JOB_NAME_AI, JOB_NAME_CYBORG, JOB_NAME_CURATOR)
	required_players = 15
	required_enemies = 1
	recommended_enemies = 3
	reroll_friendly = 1
	num_modifier = -2 // mniej zdrajców, bo są wampiry

	var/list/datum/mind/pre_vamps = list()
	/// Twardy limit wampirów, gdy skalowanie jest wyłączone
	var/const/vampire_amt = 2

/datum/game_mode/traitor/vampire/announce()
	to_chat(world, "<B>Obecny tryb gry to: Zdrajca+Wampir!</B>")
	to_chat(world, "<B>Na stacji są wampiry, a do tego agenci Syndykatu działający we własnym interesie! Nie pozwólcie, by wampirom i zdrajcom się udało!</B>")

/datum/game_mode/traitor/vampire/can_start()
	if(!..())
		return FALSE
	var/list/possible_vampires = get_players_for_role(/datum/antagonist/vampire, /datum/role_preference/antagonist/vampire)
	return length(possible_vampires) >= required_enemies

/datum/game_mode/traitor/vampire/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += JOB_NAME_ASSISTANT

	// kapelan nie może być wampirem w traitor+vamp
	var/list/vampire_restricted_jobs = restricted_jobs + JOB_NAME_CHAPLAIN
	restricted_jobs += JOB_NAME_CHAPLAIN
	var/list/datum/mind/possible_vamps = get_players_for_role(/datum/antagonist/vampire, /datum/role_preference/antagonist/vampire)
	restricted_jobs -= JOB_NAME_CHAPLAIN

	var/num_vamp = 1
	var/tsc = CONFIG_GET(number/traitor_scaling_coeff)
	if(tsc)
		num_vamp = max(1, min(round(num_players() / (tsc * 4)) + 2, round(num_players() / (tsc * 2))))
	else
		num_vamp = max(1, min(num_players(), vampire_amt / 2))

	if(!length(possible_vamps))
		return FALSE
	var/list/old_antag_candidates = antag_candidates.Copy()
	for(var/j in 1 to num_vamp)
		if(!length(possible_vamps))
			break
		var/datum/mind/vamp = antag_pick(possible_vamps, /datum/role_preference/antagonist/vampire)
		possible_vamps -= vamp
		antag_candidates -= vamp
		pre_vamps += vamp
		vamp.special_role = ROLE_VAMPIRE
		vamp.restricted_roles = vampire_restricted_jobs
	antag_candidates = old_antag_candidates
	return ..()

/datum/game_mode/traitor/vampire/post_setup()
	for(var/datum/mind/vamp in pre_vamps)
		vamp.add_antag_datum(/datum/antagonist/vampire)
	return ..()

/datum/game_mode/traitor/vampire/make_antag_chance(mob/living/carbon/human/character) // wampiry z latejoinu
	var/tsc = CONFIG_GET(number/traitor_scaling_coeff)
	var/vampcap
	if(tsc)
		vampcap = min(round(length(GLOB.joined_player_list) / (tsc * 4)) + 2, round(length(GLOB.joined_player_list) / (tsc * 2)))
	else
		vampcap = max(1, vampire_amt / 2)
	var/vamp_count = length(get_antag_minds(/datum/antagonist/vampire))
	if(vamp_count >= vampcap)
		return ..()
	if(vamp_count <= (vampcap - 2) || (tsc && prob(100 / (tsc * 4))))
		if(!QDELETED(character) && character.mind && character.client?.should_include_for_role(
			banning_key = ROLE_VAMPIRE,
			role_preference_key = /datum/role_preference/antagonist/vampire,
		))
			if(!(character.job in restricted_jobs) && character.job != JOB_NAME_CHAPLAIN)
				character.mind.add_antag_datum(/datum/antagonist/vampire)
	return ..()

/datum/game_mode/traitor/vampire/generate_report()
	return "Otrzymaliśmy niejasne raporty o współpracy Syndykatu z demonem z bluespace. \
			Uważajcie na agentów Syndykatu i trzymajcie kapelana w gotowości."

/datum/role_preference/antagonist/vampire
	name = "Wampir"
	antag_datum = /datum/antagonist/vampire
