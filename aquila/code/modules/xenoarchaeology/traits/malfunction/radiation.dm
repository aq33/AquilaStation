/*
	Rapid Particle Emmision
	Irradiates the artifact and targets
*/
/datum/xenoartifact_trait/malfunction/radiation
	label_name = "R.P.E."
	alt_label_name = "Gwałtowna Emisja Cząstek"
	label_desc = "Rapid Particle Emmision: dziwna usterka, która sprawia, że artefakt napromieniowuje siebie i swoje cele."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	register_targets = TRUE

/datum/xenoartifact_trait/malfunction/radiation/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return

	// Promieniowanie z Bee#13442 (wersja z tego PR)
	var/atom/atom_parent = component_parent.parent
	radiation_pulse(atom_parent, max_range = 4, threshold = RAD_FULL_INSULATION, intensity = component_parent.trait_strength * 0.25)

	for(var/atom/target in focus)
		SSradiation.irradiate(target, intensity = 25)

	dump_targets()
	clear_focus()
