// AQUILA - port z Yogstation (yogstation/code/datums/mutations/alcohol.dm)

/datum/mutation/alcohol_tolerance
	name = "Alcohol Tolerance"
	desc = "A hyperactive liver improves the patient's ability to metabolize alcohol."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Twoja wątroba czuje się wspaniale.</span>"
	text_lose_indication = "<span class='danger'>Twoja wątroba jest smutna.</span>"
	instability = 5
	mutation_traits = list(TRAIT_ALCOHOL_TOLERANCE)

/datum/mutation/alcohol_generate
	name = "Auto-brewery Syndrome"
	desc = "The patient's body now naturally produces alcohol into their bloodstream."
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='danger'>Boli cię wątroba.</span>"
	text_lose_indication = "<span class='notice'>Twoja wątroba czuje się lepiej.</span>"

/datum/mutation/alcohol_generate/on_life()
	if(prob(15))
		owner.reagents?.add_reagent(/datum/reagent/consumable/ethanol, 3)
