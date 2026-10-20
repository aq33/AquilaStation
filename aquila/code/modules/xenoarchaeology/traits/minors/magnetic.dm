/*
	Magnetic
	The artifact attracts metalic objects when activated
*/
/datum/xenoartifact_trait/minor/magnetic
	label_name = "Magnetic"
	label_desc = "Magnetic: konstrukcja artefaktu zdaje się zawierać elementy magnetyczne. Po aktywacji artefakt przyciąga metalowe przedmioty."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 30
	blacklist_traits = list(/datum/xenoartifact_trait/minor/magnetic/push)
	///Maximum magnetic pull
	var/max_pull_steps = 2
	///Maximum range
	var/max_pull_range = 4

/datum/xenoartifact_trait/minor/magnetic/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	var/turf/T = get_turf(component_parent.parent)
	var/pull_steps = max_pull_steps * (component_parent.trait_strength/100)
	var/pull_range = max_pull_range * (component_parent.trait_strength/100)
	for(var/obj/M in orange(pull_range, T))
		if(M.anchored || !(M.flags_1 & CONDUCT_1))
			continue
		INVOKE_ASYNC(src, PROC_REF(magnetize), M, T, pull_steps)
	for(var/mob/living/silicon/S in orange(pull_range, T))
		if(isAI(S))
			continue
		INVOKE_ASYNC(src, PROC_REF(magnetize), S, T, pull_steps)

/datum/xenoartifact_trait/minor/magnetic/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("przyciągać do siebie metalowe przedmioty"))

/datum/xenoartifact_trait/minor/magnetic/proc/magnetize(atom/movable/movable, atom/target, _pull_steps)
	for(var/i in 1 to _pull_steps)
		magnetic_direction(movable, target)
		sleep(1)

/datum/xenoartifact_trait/minor/magnetic/proc/magnetic_direction(atom/movable/movable, atom/target)
	step_towards(movable, target)

//Inverse variant
/datum/xenoartifact_trait/minor/magnetic/push
	label_name = "Magnetic Δ"
	label_desc = "Magnetic Δ: konstrukcja artefaktu zdaje się zawierać elementy magnetyczne. Po aktywacji artefakt odpycha metalowe przedmioty."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/magnetic)
	conductivity = 10

/datum/xenoartifact_trait/minor/magnetic/push/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("odpychać od siebie metalowe przedmioty"))

/datum/xenoartifact_trait/minor/magnetic/push/magnetic_direction(atom/movable/movable, atom/target)
	step_away(movable, target)
