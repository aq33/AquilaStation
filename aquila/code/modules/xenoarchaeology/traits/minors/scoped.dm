/*
	Scoped
	Increases target range
*/
/datum/xenoartifact_trait/minor/scoped
	material_desc = "celowniczy"
	label_name = "Scoped"
	label_desc = "Scoped: konstrukcja artefaktu zdaje się zawierać elementy celownicze. Dzięki nim artefakt ma większy zasięg."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	extra_target_range = 9
	weight = 10
	conductivity = 15

/datum/xenoartifact_trait/minor/scoped/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_MATERIAL)
