/datum/antagonist/plague_rat
	name = "Plague Rat"
	// AQ: nasz /datum/antagonist nie ma job_rank/antag_hud_name/antag_count_points z tg
	roundend_category = "szczury zarazy"
	antagpanel_category = "Szczur zarazy"
	banning_key = ROLE_PLAGUERAT
	show_in_antagpanel = TRUE

	var/static/datum/team/plague_rat/rats_rats_we_are_the_rats
	var/disease_id
	var/datum/disease/acute/bacteria/plague
	var/turf/invasion

// AQ: nasz panel antagów nie pokazuje ikon podglądu (get_preview_icon z tg), więc pomijamy

/datum/antagonist/plague_rat/on_gain()
	if(!rats_rats_we_are_the_rats)
		rats_rats_we_are_the_rats = new
		rats_rats_we_are_the_rats.setup_diseases()

	rats_rats_we_are_the_rats.add_member(owner)

	disease_id = rats_rats_we_are_the_rats.disease_id
	plague = rats_rats_we_are_the_rats.plague
	invasion = rats_rats_we_are_the_rats.invasion

	if (invasion)
		for(var/datum/mind/M in rats_rats_we_are_the_rats.members)
			M.current.forceMove(invasion)
	owner.current.infect_disease(plague,1, "Plague Mice")
	ADD_TRAIT(owner.current, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

	return ..()

/datum/antagonist/plague_rat/greet()
	. = ..()
	to_chat(owner.current, span_warning("<B>You are a [name]! Carrier of a dangerous Bacteria!</B><BR>Try and spread your contagion across the station!</B><BR> Eating some food can help heal your wounds, always keep an eye out for cheese."))

/datum/antagonist/plague_rat/get_team()
	return rats_rats_we_are_the_rats
