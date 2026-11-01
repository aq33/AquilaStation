// AQUILA - port z Yogstation (yogstation/code/datums/mutations/alcohol.dm)

/datum/mutation/alcohol_tolerance
	name = "Tolerancja alkoholu"
	desc = "Nadaktywna wątroba sprawia, że pacjent lepiej rozkłada alkohol."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Twoja wątroba czuje się wspaniale.</span>"
	text_lose_indication = "<span class='danger'>Twoja wątroba jest smutna.</span>"
	instability = 5
	mutation_traits = list(TRAIT_ALCOHOL_TOLERANCE)

/datum/mutation/alcohol_generate
	name = "Zespół autobrowaru"
	desc = "Organizm pacjenta sam wytwarza alkohol we krwi."
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='danger'>Boli cię wątroba.</span>"
	text_lose_indication = "<span class='notice'>Twoja wątroba czuje się lepiej.</span>"

/datum/mutation/alcohol_generate/on_life()
	if(prob(15))
		owner.reagents?.add_reagent(/datum/reagent/consumable/ethanol, 3)
