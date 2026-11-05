//Cold Resistance gives your entire body an orange halo, and makes you immune to the effects of vacuum and cold.
/datum/mutation/space_adaptation
	name = "Adaptacja kosmiczna"
	desc = "Dziwna mutacja, która uodparnia nosiciela na kosmiczną próżnię. Nadal potrzebuje on dopływu tlenu."
	quality = POSITIVE
	difficulty = 16
	text_gain_indication = "<span class='notice'>Twoje ciało robi się ciepłe!</span>"
	instability = 30

/datum/mutation/space_adaptation/New(class_ = MUT_OTHER, timer, datum/mutation/copymut)
	..()
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/effects/genetics.dmi', "fire", -MUTATIONS_LAYER))

/datum/mutation/space_adaptation/get_visual_indicator()
	return visual_indicators[type][1]

/datum/mutation/space_adaptation/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_RESISTCOLD, "space_adaptation")
	ADD_TRAIT(owner, TRAIT_RESISTLOWPRESSURE, "space_adaptation")

/datum/mutation/space_adaptation/on_losing(mob/living/carbon/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_RESISTCOLD, "space_adaptation")
	REMOVE_TRAIT(owner, TRAIT_RESISTLOWPRESSURE, "space_adaptation")

