/*
	Freezing
	Freezes the target
*/
/datum/xenoartifact_trait/major/freezing
	label_name = "Freezing"
	label_desc = "Freezing: artefakt wydaje się zawierać elementy zamrażające. Ich aktywacja zamrozi cel."
	flags = XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	cooldown = XENOA_TRAIT_COOLDOWN_SAFE
	conductivity = 12
	weight = 24

/datum/xenoartifact_trait/major/freezing/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/mob/living/target in focus)
		//Pretty much copied from the wizard traps
		to_chat(target, "<span class='danger'><B>Zamarzasz na kość!</B></span>")
		target.Paralyze(20)
		target.adjust_bodytemperature(-300)
		target.apply_status_effect(/datum/status_effect/freon)
	dump_targets()
	clear_focus()
