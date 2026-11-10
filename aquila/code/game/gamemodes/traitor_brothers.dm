// Bracia krwi jako odmiana zdrajcy: tryb traitorbro wypadł z rotacji, a w zwykłym trybie zdrajcy
// dwóch wylosowanych zdrajców może zamiast tego zacząć jako para braci krwi (bez dokładania antagonistów).

/datum/game_mode/traitor
	/// Szansa (%), że dwóch wylosowanych zdrajców zostanie parą braci krwi. Tylko czysty tryb traitor
	var/brother_pair_chance = 50
	/// Drużyny braci zrobione z wylosowanych zdrajców, dostają datumy w post_setup
	var/list/datum/team/brother_team/pre_traitor_brother_teams = list()

/datum/game_mode/traitor/pre_setup()
	. = ..()
	if(!. || type != /datum/game_mode/traitor || !prob(brother_pair_chance))
		return
	var/list/datum/mind/willing = get_players_for_role(/datum/antagonist/brother, /datum/role_preference/antagonist/blood_brother) & pre_traitors
	pair_traitors_as_brothers(willing)

/// Zabiera dwóch zdrajców z listy chętnych i robi z nich drużynę braci krwi. Zwraca drużynę albo null
/datum/game_mode/traitor/proc/pair_traitors_as_brothers(list/datum/mind/willing)
	QDEL_LIST(pre_traitor_brother_teams)
	willing = willing & pre_traitors
	if(length(willing) < 2)
		return null
	var/datum/team/brother_team/team = new
	for(var/i in 1 to 2)
		var/datum/mind/bro = pick_n_take(willing)
		pre_traitors -= bro
		team.add_member(bro)
		bro.special_role = "brother"
		log_game("[key_name(bro)] has been selected as a Brother instead of a traitor")
	pre_traitor_brother_teams += team
	return team

/datum/game_mode/traitor/post_setup()
	for(var/datum/team/brother_team/team in pre_traitor_brother_teams)
		team.pick_meeting_area()
		team.forge_brother_objectives()
		for(var/datum/mind/brother_mind in team.members)
			brother_mind.add_antag_datum(/datum/antagonist/brother, team)
		team.update_name()
	brother_teams += pre_traitor_brother_teams
	pre_traitor_brother_teams = list()
	return ..()

// Stary tryb zostaje w kodzie dla admina (wymuszenie z panelu), ale nie trafia do głosowania
/datum/game_mode/traitor/bros
	votable = FALSE
