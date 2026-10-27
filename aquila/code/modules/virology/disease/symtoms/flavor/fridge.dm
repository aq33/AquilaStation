/datum/symptom/acute/fridge
	name = "Refridgerator Syndrome"
	desc = "Causes the infected to shiver at random."
	encyclopedia = "No matter whether the room is cold or hot. This has no effect on their body temperature."
	stage = 2
	max_multiplier = 4
	multiplier = 1
	badness = EFFECT_DANGER_FLAVOR
	severity = 1

/datum/symptom/acute/fridge/activate(mob/living/mob)
	to_chat(mob, span_warning("[pick("You feel cold.", "You shiver.")]"))
	mob.emote("shiver")
	set_body_temp(mob)

/datum/symptom/acute/fridge/proc/set_body_temp(mob/living/mob)
	// AQ: nie mamy homeostazy z tg, więc dreszcze po prostu schładzają ciało
	if(multiplier >= 3) // when unsafe the shivers can cause cold damage
		mob.adjust_bodytemperature(-6 * power)
	else
		mob.adjust_bodytemperature(-6 * power, BODYTEMP_COLD_DAMAGE_LIMIT + 5)
