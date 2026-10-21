/*
	Temporal
	Creates a timestop object at the position of the artfiact
*/
/datum/xenoartifact_trait/major/timestop
	label_name = "Temporal"
	label_desc = "Temporal: artefakt wydaje się zawierać elementy czasowe. Ich aktywacja otworzy szczelinę czasową."
	cooldown = XENOA_TRAIT_COOLDOWN_GAMER
	flags = XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	register_targets = FALSE
	weight = 24
	///Maximum time we stop time for
	var/max_time = 10 SECONDS

/datum/xenoartifact_trait/major/timestop/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	var/turf/T = get_turf(component_parent.parent)
	if(!T)
		return
	new /obj/effect/timestop(T, 2, ((component_parent.trait_strength/100)*max_time), component_parent.parent)
