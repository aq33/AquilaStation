// AQUILA - kto dostaje nowe narządy AquilaMed 5: wszystkie rasy z krwią (bez NOBLOOD i bez ciała syntetyka).
// Rasy bez krwi (plazmalud, szkielety, golemy) nie mają ich wcale; IPC ma syntezator mowy zamiast krtani (larynx.dm).
// Wzór: pęcherz z cieczy (aquila/code/modules/bladder/bladder.dm).

/datum/species
	/// Typy nowych narządów, null = brak
	var/obj/item/organ/kidneys/mutantkidneys = /obj/item/organ/kidneys
	var/obj/item/organ/spleen/mutantspleen = /obj/item/organ/spleen
	var/obj/item/organ/intestines/mutantintestines = /obj/item/organ/intestines
	var/obj/item/organ/adrenals/mutantadrenals = /obj/item/organ/adrenals
	var/obj/item/organ/pancreas/mutantpancreas = /obj/item/organ/pancreas // AquilaMed 6
	var/obj/item/organ/esophagus/mutantesophagus = /obj/item/organ/esophagus // AquilaMed 6
	var/obj/item/organ/aq_spine/mutantspine = /obj/item/organ/aq_spine // AquilaMed 6

/// Does this species get the AquilaMed 5 organs of a body with blood
/datum/species/proc/aq_has_med5_organs()
	return !(NOBLOOD in species_traits) && !(MOB_ROBOTIC in inherent_biotypes)

/// Gives or takes one AquilaMed 5 organ to match the species; replace_current swaps a fitting one for a fresh one too (as the base proc)
/datum/species/proc/aq_regenerate_organ(mob/living/carbon/C, slot, organ_type, replace_current = FALSE)
	var/obj/item/organ/current = C.getorganslot(slot)
	if(current && (!organ_type || replace_current || !istype(current, organ_type))) // brak narządu, inny rodzaj (krtań u IPC) albo wymiana
		current.Remove(C, TRUE)
		qdel(current)
		current = null
	if(!current && organ_type)
		var/obj/item/organ/organ = new organ_type()
		organ.Insert(C)

/datum/species/regenerate_organs(mob/living/carbon/C, datum/species/old_species, replace_current = TRUE)
	. = ..()
	var/wanted = aq_has_med5_organs()
	aq_regenerate_organ(C, ORGAN_SLOT_KIDNEYS, wanted ? mutantkidneys : null, replace_current)
	aq_regenerate_organ(C, ORGAN_SLOT_SPLEEN, wanted ? mutantspleen : null, replace_current)
	aq_regenerate_organ(C, ORGAN_SLOT_INTESTINES, wanted ? mutantintestines : null, replace_current)
	aq_regenerate_organ(C, ORGAN_SLOT_ADRENALS, wanted ? mutantadrenals : null, replace_current)
	aq_regenerate_organ(C, ORGAN_SLOT_PANCREAS, wanted ? mutantpancreas : null, replace_current)
	aq_regenerate_organ(C, ORGAN_SLOT_ESOPHAGUS, wanted ? mutantesophagus : null, replace_current)
	aq_regenerate_organ(C, ORGAN_SLOT_AQ_SPINE, wanted ? mutantspine : null, replace_current)
	aq_regenerate_organ(C, ORGAN_SLOT_LARYNX, aq_larynx_type(), replace_current)
	// Without a stack by choice: none is given, but one a medic implanted later stays (cortical_stack.dm)
	if(!C.has_quirk(/datum/quirk/no_cortical_stack))
		aq_regenerate_organ(C, ORGAN_SLOT_CORTICAL_STACK, wanted ? mutantcorticalstack : null, replace_current)

/mob/living/carbon/monkey/create_internal_organs()
	internal_organs += new /obj/item/organ/kidneys
	internal_organs += new /obj/item/organ/spleen
	internal_organs += new /obj/item/organ/intestines
	internal_organs += new /obj/item/organ/adrenals
	internal_organs += new /obj/item/organ/pancreas
	internal_organs += new /obj/item/organ/esophagus
	internal_organs += new /obj/item/organ/aq_spine
	internal_organs += new /obj/item/organ/larynx
	return ..()

/datum/techweb_node/cyber_organs/New()
	. = ..()
	design_ids += list("aq_cybernetic_kidneys", "aq_cybernetic_spleen", "aq_cybernetic_intestines", "aq_cybernetic_adrenals", "aq_cybernetic_pancreas", "aq_cybernetic_spine", "aq_titanium_bone", "aq_hydraulic_muscle", "aq_synthetic_vessels", "aq_synthesizer")
