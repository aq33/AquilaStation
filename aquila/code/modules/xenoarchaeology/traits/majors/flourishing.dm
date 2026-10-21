/*
	Flourishing
	Ages up plants
*/
/datum/xenoartifact_trait/major/growing
	label_name = "Flourishing"
	label_desc = "Flourishing: artefakt wydaje się zawierać elementy przyspieszające wzrost. Ich aktywacja postarzy rośliny będące celem."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	conductivity = 6
	weight = 6
	///Max amount we increase age by
	var/max_aging = 5

/datum/xenoartifact_trait/major/growing/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/obj/machinery/hydroponics/target in focus)
		target.age += max_aging * (component_parent.trait_strength/100)
	dump_targets()
	clear_focus()

/datum/xenoartifact_trait/major/growing/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("postarzać rośliny"))

//Makes plants younger
/datum/xenoartifact_trait/major/growing/youth
	label_name = "Flourishing Δ"
	label_desc = "Flourishing Δ: artefakt wydaje się zawierać elementy przyspieszające wzrost. Ich aktywacja odmłodzi rośliny będące celem."
	max_aging = -5
	conductivity = 3

/datum/xenoartifact_trait/major/growing/youth/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("odmładzać rośliny"))
