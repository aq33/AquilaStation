/datum/symptom/acute/confusion
	name = "Topographical Cretinism"
	desc = "Attacks the infected's ability to differentiate left and right."
	stage = 3
	badness = EFFECT_DANGER_HINDRANCE
	severity = 3
	max_multiplier = 5
	symptom_delay_min = 1
	symptom_delay_max = 5

/datum/symptom/acute/confusion/activate(mob/living/carbon/mob)
	to_chat(mob, span_warning("You have trouble telling right and left apart all of a sudden!"))
	mob.confused = min(mob.confused + (1 SECONDS * power * multiplier), 20 SECONDS)
