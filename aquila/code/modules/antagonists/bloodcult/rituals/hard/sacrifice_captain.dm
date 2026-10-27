
/datum/bloodcult_ritual/sacrifice_captain
	name = "Złóż w ofierze kapitana"
	desc = "kapitan...<br>ołtarz...<br>i odpowiednie ostrze..."

	only_once = TRUE
	ritual_type = "sacrifice"
	difficulty = "hard"
	reward_faction = 500

	keys = list("altar_sacrifice_human")

/datum/bloodcult_ritual/sacrifice_captain/pre_conditions(datum/antagonist/cult/potential)
	if (potential)
		owner = potential
	for(var/mob/M in GLOB.player_list)
		if(M.mind && M.mind.assigned_role == JOB_NAME_CAPTAIN)
			return TRUE
	return FALSE

/datum/bloodcult_ritual/sacrifice_captain/key_found(mob/living/O)
	if (istype(O) && O.mind && O.mind.assigned_role == JOB_NAME_CAPTAIN)
		return TRUE
	return FALSE
