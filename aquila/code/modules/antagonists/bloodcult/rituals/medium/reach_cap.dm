/datum/bloodcult_ritual/reach_cap
	name = "Osiągnij limit"
	desc = "kult musi rosnąć...<br>aż nie będzie mógł dalej..."

	only_once = TRUE
	ritual_type = "conversion"
	difficulty = "medium"
	reward_faction = 400

	keys = list(
		"conversion",
		"converted_prisoner",
		"soulstone",
		"soulstone_prisoner",
		)

/datum/bloodcult_ritual/reach_cap/pre_conditions(datum/antagonist/cult/potential)
	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	if (cult?.CanConvert())
		return TRUE
	return FALSE

/datum/bloodcult_ritual/reach_cap/key_found(extra)
	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	if (cult && !cult.CanConvert())
		return TRUE
	return FALSE
