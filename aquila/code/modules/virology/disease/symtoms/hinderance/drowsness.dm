
/datum/symptom/acute/drowsness
	name = "Automated Sleeping Syndrome"
	desc = "Makes the infected feel more drowsy."
	stage = 2
	badness = EFFECT_DANGER_HINDRANCE
	severity = 3
	multiplier = 5
	max_multiplier = 10

/datum/symptom/acute/drowsness/activate(mob/living/mob)
	mob.drowsyness = min(mob.drowsyness + (multiplier * power), 40 SECONDS)
