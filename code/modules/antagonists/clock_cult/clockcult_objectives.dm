/datum/objective/clockcult
	name = "służba Rat'varowi"
	explanation_text = "Chroń Niebiańską Bramę, by Rat'var mógł oświecić ten świat!"

/datum/objective/clockcult/check_completion()
	return GLOB.ratvar_risen || ..()
