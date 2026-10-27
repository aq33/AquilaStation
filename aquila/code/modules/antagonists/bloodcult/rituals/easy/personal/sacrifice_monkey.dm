
/datum/bloodcult_ritual/sacrifice_monkey
	name = "Złóż w ofierze małpę"
	desc = "małpa...<br>ołtarz...<br>i odpowiednie ostrze..."

	ritual_type = "sacrifice"
	difficulty = "easy"
	personal = TRUE
	reward_achiever = 200
	reward_faction = 2

	keys = list("altar_sacrifice_monkey")

/datum/bloodcult_ritual/sacrifice_monkey/key_found(extra)
	return TRUE
