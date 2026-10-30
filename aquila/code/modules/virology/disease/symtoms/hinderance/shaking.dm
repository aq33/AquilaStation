/datum/symptom/acute/shakey
	name = "World Shaking Syndrome"
	desc = "Attacks the infected's motor output, giving them a sense of vertigo."
	stage = 3
	max_multiplier = 3
	badness = EFFECT_DANGER_HINDRANCE
	severity = 3

/datum/symptom/acute/shakey/activate(mob/living/carbon/mob)
	shake_camera(mob, 5*multiplier)
