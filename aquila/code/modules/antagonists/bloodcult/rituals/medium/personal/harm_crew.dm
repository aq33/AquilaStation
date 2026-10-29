
/datum/bloodcult_ritual/harm_crew
	name = "Rań załogę"
	desc = "dzierż broń kultu...<br>przelej ich krew...<br>przypal ich skórę..."

	ritual_type = "harm"
	difficulty = "medium"
	personal = TRUE
	reward_achiever = 200
	reward_faction = 2

	keys = list(
		"attack_tome",
		"attack_cultblade",
		"attack_blooddagger",
		"attack_construct",
		"attack_shade",
		"attack_ritualknife",
		)

	var/targets = 3
	var/list/hit_targets = list()

/datum/bloodcult_ritual/harm_crew/init_ritual()
	hit_targets = list()

/datum/bloodcult_ritual/harm_crew/update_desc()
	desc = "dzierż broń kultu...<br>przelej ich krew...<br>przypal ich skórę...<br>jeszcze co najmniej [targets - hit_targets.len] różnych osób..."

/datum/bloodcult_ritual/harm_crew/key_found(mob/living/L)
	if (!istype(L) || !L.mind || IS_CULTIST(L))
		return FALSE
	if (L.mind in hit_targets)
		return FALSE
	hit_targets += L.mind
	if(hit_targets.len >= targets)
		return TRUE
	return FALSE
