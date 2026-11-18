// AQUILA - „Chcę być celem antagonistów”: gracz z tą opcją jest pierwszym wyborem przy losowaniu celu
// (zabójstwo, ochrona, porwanie itd., każdy cel przez /datum/objective/proc/find_target). Hook w find_target
// (AQ EDIT) bierze go spośród kandydatów, którzy przeszli wszystkie zwykłe filtry, są w grze i nie są jeszcze celem
// innego antagonisty.

/datum/preferences
	/// Gracz chce, żeby antagoniści wybierali go na cel w pierwszej kolejności
	var/antag_target_opt_in = FALSE

/datum/preference/toggle/player/antag_target_opt_in
	db_key = "antag_target_opt_in"
	player_var = "antag_target_opt_in"

/// Czy właściciel umysłu włączył „Chcę być celem antagonistów”. Preferencje zostają po wyjściu z gry.
/proc/wants_to_be_antag_target(datum/mind/candidate)
	if(!candidate?.key)
		return FALSE
	var/datum/preferences/prefs = GLOB.preferences_datums[ckey(candidate.key)]
	return prefs?.antag_target_opt_in ? TRUE : FALSE

/// Czy umysł jest już celem któregoś celu (objective) innego antagonisty
/proc/is_antag_objective_target(datum/mind/candidate)
	for(var/datum/antagonist/antag as anything in GLOB.antagonists)
		for(var/datum/objective/objective as anything in antag.objectives)
			if(objective.target == candidate)
				return TRUE
	return FALSE

/// Kandydaci z listy, którzy sami chcą być celem: tylko obecni w grze (preferencje zostają też po wyjściu)
/// i jeszcze niewybrani przez innego antagonistę, żeby jeden chętny nie zbierał celów wszystkich antagów
/proc/opted_in_antag_targets(list/candidates)
	. = list()
	for(var/datum/mind/candidate as anything in candidates)
		if(!wants_to_be_antag_target(candidate))
			continue
		if(!candidate.current || !GET_CLIENT(candidate.current))
			continue
		if(is_antag_objective_target(candidate))
			continue
		. += candidate
