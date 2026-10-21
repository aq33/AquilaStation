/datum/antagonist/slaughter
	name = "Demon rzezi"
	show_name_in_check_antagonists = TRUE
	var/objective_verb = "Zabij"
	var/datum/mind/summoner
	banning_key = ROLE_SLAUGHTER_DEMON
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE
	ui_name = "AntagInfoDemon"
	/// Opis demona w oknie AntagInfoDemon
	var/fluff = "Jesteś demonem gniewu, często wciąganym do rzeczywistości przez czarodziejów, by terroryzować ich wrogów."

/datum/antagonist/slaughter/ui_static_data(mob/user)
	var/list/data = ..()
	data["fluff"] = fluff
	data["explain_attack"] = TRUE
	return data

/datum/antagonist/slaughter/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/slaughter/greet()
	. = ..()
	owner.announce_objectives()

/datum/antagonist/slaughter/proc/forge_objectives()
	if(summoner)
		var/datum/objective/assassinate/new_objective = new /datum/objective/assassinate
		new_objective.owner = owner
		new_objective.set_target(summoner)
		new_objective.explanation_text = "[objective_verb] [summoner.name] - osobę, która cię przywołała."
		objectives += new_objective
		log_objective(owner, new_objective.explanation_text)
	var/datum/objective/new_objective2 = new /datum/objective
	new_objective2.owner = owner
	new_objective2.explanation_text = "[objective_verb] [summoner ? "przy okazji wszystkich pozostałych" : "wszystkich"]."
	objectives += new_objective2
	log_objective(owner, new_objective2.explanation_text)

/datum/antagonist/slaughter/laughter
	name = "Demon śmiechu"
	objective_verb = "Przytul i połaskocz"
	fluff = "Jesteś demonem zazdrości, czasem wciąganym do rzeczywistości przez czarodziejów, by siać bezmyślny chaos."
