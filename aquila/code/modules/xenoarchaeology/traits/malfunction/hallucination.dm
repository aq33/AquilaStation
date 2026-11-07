/*
	Mass Hallucinatory Injection
	Makes the target/s hallucinate
*/
/datum/xenoartifact_trait/malfunction/hallucination
	label_name = "M.H.I."
	alt_label_name = "Masowa Iniekcja Halucynacyjna"
	label_desc = "Mass Hallucinatory Injection: artefakt wywołuje u celu halucynacje."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_PLASMA_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	register_targets = TRUE

/datum/xenoartifact_trait/malfunction/hallucination/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/mob/living/target in focus)
		if(!iscarbon(target))
			continue
		target.cause_hallucination(get_random_hallucination(HALLUCINATION_TIER_RARE), "xenoartifact malfunction")
	dump_targets()
	clear_focus()
