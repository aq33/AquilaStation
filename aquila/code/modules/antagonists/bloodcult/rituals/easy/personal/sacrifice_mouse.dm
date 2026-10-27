
/datum/bloodcult_ritual/sacrifice_mouse
	name = "Złóż w ofierze mysz"
	desc = "gryzoń...<br>ołtarz...<br>i odpowiednie ostrze..."

	ritual_type = "sacrifice"
	difficulty = "easy"
	personal = TRUE
	reward_achiever = 200
	reward_faction = 2

	keys = list("altar_sacrifice_animal")

/datum/bloodcult_ritual/sacrifice_mouse/key_found(mob/living/simple_animal/mouse/extra)
	if(istype(extra))
		return TRUE
	return FALSE
