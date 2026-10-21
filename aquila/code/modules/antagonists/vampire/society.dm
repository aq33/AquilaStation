/// A global list of vampire antag datums that have broken the Masquerade
GLOBAL_LIST_EMPTY(masquerade_breakers)

/// A global list of vampire antag datums in general
GLOBAL_LIST_EMPTY(all_vampires)

//////////////////////////////////////////////////
//////////// ON THE VAMP ANTAG DATUM /////////////
//////////////////////////////////////////////////
/**
 * Resumes society, called when someone is assigned Vampire
**/
/datum/antagonist/vampire/proc/check_start_society()

	if(SSvsociety.can_fire)
		return

	if(length(GLOB.all_vampires) >= 3)
		SSvsociety.can_fire = TRUE
		message_admins("Społeczność wampirów wystartowała, bo aktywnych wampirów jest [length(GLOB.all_vampires)].")
		log_game("Vampire Society has started, as there are [length(GLOB.all_vampires)] vampires active.")

/**
 * Pauses society, called when someone is unassigned Vampire
**/
/datum/antagonist/vampire/proc/check_cancel_society()

	if(!SSvsociety.can_fire)
		return

	if(length(GLOB.all_vampires) < 3)
		SSvsociety.can_fire = FALSE
		message_admins("Społeczność wampirów wstrzymana, bo aktywnych wampirów jest tylko [length(GLOB.all_vampires)].")
		log_game("Vampire Society has paused, as there are only [length(GLOB.all_vampires)] vampires active.")

/**
 * Turns the player into a prince.
**/
/datum/antagonist/vampire/proc/princify()
	SSvsociety.princedatum = WEAKREF(src)

	rank_up(8, TRUE) // Rank up a lot.
	to_chat(owner.current, span_cultbold("Jako prawdziwy Książę czujesz, jak wraca do ciebie część dawnej mocy!"))
	add_team_hud(owner.current, "prince")
	prince = TRUE

	for(var/datum/antagonist/vampire as anything in GLOB.all_vampires)
		to_chat(vampire.owner.current, span_narsiesmall("[owner.name] obejmuje rolę Księcia!"))

	grant_power(new /datum/action/vampire/targeted/scourgify)

	var/datum/objective/vampire/prince/prince_objective = new()
	objectives += prince_objective
	owner.announce_objectives()
	update_static_data_for_all_viewers()

	message_admins("[ADMIN_LOOKUPFLW(owner.current)] zostaje Księciem wampirów. (wynik książęcy: [get_princely_score()], premia za klan/godziny: [my_clan?.princely_score_bonus]/[min(50, owner.current?.client?.get_exp_living(TRUE) / 60) / 10])")
	log_game("[key_name(owner.current)] has become the Vampire Prince. ([get_princely_score()] princely score, with [my_clan?.princely_score_bonus]/[min(50, owner.current?.client?.get_exp_living(TRUE) / 60) / 10] clan/hour bonus.)")

	update_static_data_for_all_viewers() // ensure our new objective shows up in the UI immediately if its open
	tgui_alert(owner.current, "Gratulacje, wybrano cię na Księcia.\nPamiętaj, że wiąże się to z odpowiedzialnością. Twoim zadaniem jest teraz utrzymywać porządek i pilnować przestrzegania Maskarady.", "Witaj, mój Książę.", list("Rozumiem"), 30 SECONDS, TRUE)

/**
 * Turns the player into a scourge.
**/
/datum/antagonist/vampire/proc/scourgify()
	ASSERT(!prince) // Literally how would this happen. Still, just in case.

	rank_up(4, TRUE) // Rank up less.
	to_chat(owner.current, span_cultbold("Jako Bicz Camarilli czerpiesz siłę ze swojego nowego celu!"))
	add_team_hud(owner.current, "scourge")
	scourge = TRUE

	var/datum/objective/vampire/scourge/scourge_objective = new()
	objectives += scourge_objective
	owner.announce_objectives()

	for(var/datum/antagonist/vampire as anything in GLOB.all_vampires)
		to_chat(vampire.owner.current, span_cultbigbold("Z woli Księcia [owner.name] obejmuje funkcję Bicza!"))

	message_admins("[ADMIN_LOOKUPFLW(owner.current)] zostaje Biczem wampirów!")
	log_game("[key_name(owner.current)] has become a Scourge of the Vampires.")
	update_static_data_for_all_viewers() // ensure our new objective shows up in the UI immediately if its open

/**
 * Returns the princyness of this vampire.
 * get the players hours, convert it into a 10 point scale, 0-100 hours.
 * get their clans default princely score. 0-10(mostly).
 * Add those together.
**/
/datum/antagonist/vampire/proc/get_princely_score()
	var/calculated_hour_score = min(50, owner.current?.client?.get_exp_living(TRUE) / 60) / 10

	var/clan_bonus = my_clan?.princely_score_bonus || -10

	return clan_bonus + calculated_hour_score

// We could put this in objectives but like, it's just two tiny hardcoded things. It's fine here.
/datum/objective/vampire/scourge
	name = "Bicz Camarilli"
	explanation_text = "Słuchaj swojego Księcia! Pilnuj porządku! Strzeż Maskarady!"

/datum/objective/vampire/prince
	name = "Książę Camarilli"
	explanation_text = "Rządź innymi Spokrewnionymi żelazną ręką! Za WSZELKĄ cenę strzeż świętości Maskarady!"
