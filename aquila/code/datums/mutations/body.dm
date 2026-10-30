/datum/mutation/jellybones
	name = "Galaretowate kości"
	desc = "Cała ta joga chyba się opłaciła."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Twoje kości wydają się galaretowate, pewnie dałbyś radę wcisnąć się do szybu wentylacyjnego.</span>"
	text_lose_indication = "<span class='notice'>Twoje kości znów wydają się twarde.</span>"
	difficulty = 14
	instability = 25

/datum/mutation/jellybones/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.ventcrawler = VENTCRAWLER_NUDE

/datum/mutation/jellybones/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.ventcrawler = VENTCRAWLER_NONE

/datum/mutation/breathless
	name = "Bezdech"
	desc = "Pacjent nie musi oddychać."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Twoje płuca wydają się wypełnione powietrzem.</span>"
	text_lose_indication = "<span class='notice'>Twoje płuca znów wydają się puste.</span>"
	difficulty = 14
	instability = 35

/datum/mutation/breathless/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_NOBREATH, GENETIC_MUTATION)

/datum/mutation/breathless/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_NOBREATH, GENETIC_MUTATION)

/datum/mutation/toxicfart
	name = "Toksyczne bąki"
	desc = "Mutacja, przez którą w jelitach pacjenta powstaje plazma."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Twój żołądek wydaje się ciężki.</span>"
	text_lose_indication = "<span class='notice'>Twój żołądek znów wydaje się lekki.</span>"
	difficulty = 16
	instability = 20

/datum/mutation/toxicfart/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_TOXICFART, GENETIC_MUTATION)

/datum/mutation/toxicfart/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_TOXICFART, GENETIC_MUTATION)


/datum/mutation/megafart
	name = "Megabąk"
	desc = "Mutacja, przez którą pacjent puszcza bąki z taką siłą, że odrzuca wszystkich wokół."
	locked = TRUE
	text_gain_indication = "<span class='notice'>Czujesz się wzdęty i pełen gazów.</span>"
	text_lose_indication = "<span class='notice'>Znów czujesz się lekko.</span>"
	instability = 25

/datum/mutation/megafart/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_MEGAFART, GENETIC_MUTATION)

/datum/mutation/megafart/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_MEGAFART, GENETIC_MUTATION)

// Genetyka 2.0: mutacje z changelogu dostępne dla każdego, a składniki receptur do znalezienia w puli
/datum/mutation/thermal
	locked = FALSE

/datum/mutation/catclaws
	name = "Pazury"
	desc = "Na dłoniach pacjenta wyrastają ostre pazury."
	locked = FALSE
	species_allowed = list()

/datum/mutation/firebreath
	desc = "Pradawna mutacja, dzięki której pacjent zieje ogniem."
	locked = FALSE
	species_allowed = list()
