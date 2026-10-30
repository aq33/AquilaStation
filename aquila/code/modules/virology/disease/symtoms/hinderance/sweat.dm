/datum/symptom/acute/sweat
	name = "Hyper-perspiration Effect"
	desc = "Causes the infected's sweat glands to go into overdrive."
	stage = 3
	badness = EFFECT_DANGER_HINDRANCE
	severity = 2

/datum/symptom/acute/sweat/activate(mob/living/carbon/mob)
	if(prob(30 * power))
		mob.emote("me",1,"is sweating profusely!")

		// AQ: nie mamy plynow rozlewanych po podlodze (liquids ze Skyrata), wiec zostaje sam pot
