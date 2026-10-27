/datum/symptom/acute/delightful
	name = "Delightful Effect"
	desc = "A more powerful version of Full Glass. Makes the infected feel delightful."
	stage = 4
	badness = EFFECT_DANGER_HELPFUL
	severity = 0

/datum/symptom/acute/delightful/activate(mob/living/carbon/mob)
	// AQ: nasz komponent nastroju nie ma has_mood_of_category, wiec komunikat leci rzadziej
	if(prob(10))
		to_chat(mob, span_hypnophrase("You feel delightful!"))
	SEND_SIGNAL(mob, COMSIG_ADD_MOOD_EVENT, REF(src), /datum/mood_event/delightful_symptom)

/datum/symptom/acute/delightful/deactivate(mob/living/carbon/mob, datum/disease/acute/disease, safe = FALSE)
	SEND_SIGNAL(mob, COMSIG_CLEAR_MOOD_EVENT, REF(src))
	to_chat(mob, span_warning("You aren't quite sure what you were so happy about."))
