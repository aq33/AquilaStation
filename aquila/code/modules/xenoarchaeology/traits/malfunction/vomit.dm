/*
	Spontaneous Stomach Evacuation
	makes the target puke
*/
/datum/xenoartifact_trait/malfunction/vomit
	label_name = "S.S.E."
	alt_label_name = "Samoistna Ewakuacja Żołądka"
	label_desc = "Spontaneous Stomach Evacuation: dziwna usterka sprawia, że artefakt wywołuje u celu wymioty."
	flags = XENOA_BLUESPACE_TRAIT| XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	register_targets = TRUE

/datum/xenoartifact_trait/malfunction/vomit/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/mob/living/M in focus)
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			C.vomit(distance = rand(1, 2))
		else
			new /obj/effect/decal/cleanable/vomit(get_turf(component_parent.parent))
	dump_targets()
	clear_focus()
