// AQUILA - port z tgstation (code/datums/mutations/adaptation.dm)
// Nasza Space Adaptation zostaje; adaptacje z tg wykluczają się z nią i między sobą.

/datum/mutation/adaptation
	name = "Adaptation"
	desc = "The subject gains immunity to damage from extreme temperatures. Does not protect from vacuums."
	quality = POSITIVE
	difficulty = 16
	text_gain_indication = "<span class='notice'>Twoje ciało czuje się normalnie!</span>"
	instability = 25
	locked = TRUE // rodzic, nie do zdobycia
	/// Stan ikony aury w aquila/icons/mutations/tg/effects.dmi
	var/aura_icon_state

/datum/mutation/adaptation/New(class_ = MUT_OTHER, timer, datum/mutation/copymut)
	..()
	conflicts = typesof(/datum/mutation/adaptation) + /datum/mutation/space_adaptation
	if(aura_icon_state && !(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('aquila/icons/mutations/tg/effects.dmi', aura_icon_state, -MUTATIONS_LAYER))

/datum/mutation/adaptation/get_visual_indicator()
	if(!aura_icon_state)
		return
	return visual_indicators[type][1]

/datum/mutation/adaptation/cold
	name = "Cold Adaptation"
	desc = "The subject gains immunity to damage from low temperature environments."
	text_gain_indication = "<span class='notice'>Twoje ciało jest przyjemnie chłodne.</span>"
	text_lose_indication = "<span class='notice'>Chłód opuszcza twoje ciało.</span>"
	mutation_traits = list(TRAIT_RESISTCOLD)
	aura_icon_state = "cold"
	locked = FALSE

/datum/mutation/adaptation/heat
	name = "Heat Adaptation"
	desc = "The subject gains immunity to damage from high temperatures (including fire), as well as resistance to ash storms."
	text_gain_indication = "<span class='notice'>Twoje ciało jest orzeźwiająco ciepłe.</span>"
	text_lose_indication = "<span class='notice'>Ciepło opuszcza twoje ciało.</span>"
	mutation_traits = list(TRAIT_RESISTHEAT)
	aura_icon_state = "fire"
	locked = FALSE
	/// Czy to my dodaliśmy odporność na burze popiołu
	var/added_ash_immunity = FALSE

/datum/mutation/adaptation/heat/on_acquiring(mob/living/carbon/owner)
	if(..())
		return TRUE
	if(!("ash" in owner.weather_immunities))
		owner.weather_immunities += "ash"
		added_ash_immunity = TRUE

/datum/mutation/adaptation/heat/on_losing(mob/living/carbon/owner)
	if(..())
		return TRUE
	if(added_ash_immunity)
		owner.weather_immunities -= "ash"
		added_ash_immunity = FALSE

/datum/mutation/adaptation/thermal
	name = "Thermal Adaptation"
	desc = "The subject gains immunity to damage from both low and high temperature environments. \
		Does not protect from high or low pressure environments, nor does it provide resistance to ash storms."
	difficulty = 32
	text_gain_indication = "<span class='notice'>Twoje ciało ma przyjemną, pokojową temperaturę.</span>"
	text_lose_indication = "<span class='notice'>Twoje ciało znów czuje temperaturę otoczenia.</span>"
	instability = 35
	mutation_traits = list(TRAIT_RESISTHEAT, TRAIT_RESISTCOLD)
	aura_icon_state = "thermal"
	locked = TRUE // przepis

/datum/mutation/adaptation/pressure
	name = "Pressure Adaptation"
	desc = "The subject gains immunity to damage from both low and high pressure environments. \
		Does not protect from temperature, including the cold of space."
	text_gain_indication = "<span class='notice'>Twoje ciało czuje się imponująco sprężone.</span>"
	text_lose_indication = "<span class='notice'>Ciśnienie w twoim ciele wraca do normy.</span>"
	mutation_traits = list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTHIGHPRESSURE)
	aura_icon_state = "pressure"
	locked = FALSE
