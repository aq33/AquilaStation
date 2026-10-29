
/datum/bloodcult_ritual/confuse_crew
	name = "Wprowadź załogę w zamęt"
	desc = "runy i talizmany zamętu...<br>ożyw ich koszmary..."

	ritual_type = "confusion"
	difficulty = "medium"
	personal = TRUE
	reward_achiever = 200
	reward_faction = 2

	keys = list(
		"confusion_carbon",
		"confusion_papered",
		)

/datum/bloodcult_ritual/confuse_crew/key_found(mob/living/extra)
	if (!istype(extra) || !extra.client)
		return FALSE
	return TRUE
