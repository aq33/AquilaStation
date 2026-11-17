// AQUILA - kto dostaje nowe narządy AquilaMed 5: wszystkie rasy z krwią (bez NOBLOOD i bez ciała syntetyka).
// Rasy bez krwi (plazmalud, szkielety, golemy) nie mają ich wcale; IPC ma syntezator mowy zamiast krtani (larynx.dm).
// Wzór: pęcherz z cieczy (aquila/code/modules/bladder/bladder.dm).

/datum/species
	/// Typy nowych narządów, null = brak
	var/obj/item/organ/kidneys/mutantkidneys = /obj/item/organ/kidneys
	var/obj/item/organ/spleen/mutantspleen = /obj/item/organ/spleen
	var/obj/item/organ/intestines/mutantintestines = /obj/item/organ/intestines
	var/obj/item/organ/adrenals/mutantadrenals = /obj/item/organ/adrenals
	var/obj/item/organ/marrow/mutantmarrow = /obj/item/organ/marrow

/// Does this species get the AquilaMed 5 organs of a body with blood
/datum/species/proc/aq_has_med5_organs()
	return !(NOBLOOD in species_traits) && !(MOB_ROBOTIC in inherent_biotypes)

/// Gives or takes one AquilaMed 5 organ to match the species
/datum/species/proc/aq_regenerate_organ(mob/living/carbon/C, slot, organ_type)
	var/obj/item/organ/current = C.getorganslot(slot)
	if(current && (!organ_type || !istype(current, organ_type))) // brak narządu albo inny rodzaj (krtań u IPC)
		current.Remove(C, TRUE)
		qdel(current)
		current = null
	if(!current && organ_type)
		var/obj/item/organ/organ = new organ_type()
		organ.Insert(C)

/datum/species/regenerate_organs(mob/living/carbon/C, datum/species/old_species, replace_current = TRUE)
	. = ..()
	var/wanted = aq_has_med5_organs()
	aq_regenerate_organ(C, ORGAN_SLOT_KIDNEYS, wanted ? mutantkidneys : null)
	aq_regenerate_organ(C, ORGAN_SLOT_SPLEEN, wanted ? mutantspleen : null)
	aq_regenerate_organ(C, ORGAN_SLOT_INTESTINES, wanted ? mutantintestines : null)
	aq_regenerate_organ(C, ORGAN_SLOT_ADRENALS, wanted ? mutantadrenals : null)
	aq_regenerate_organ(C, ORGAN_SLOT_MARROW, wanted ? mutantmarrow : null)
	aq_regenerate_organ(C, ORGAN_SLOT_LARYNX, aq_larynx_type())
	aq_regenerate_organ(C, ORGAN_SLOT_CORTICAL_STACK, (wanted && !C.has_quirk(/datum/quirk/no_cortical_stack)) ? mutantcorticalstack : null) // cortical_stack.dm

/mob/living/carbon/monkey/create_internal_organs()
	internal_organs += new /obj/item/organ/kidneys
	internal_organs += new /obj/item/organ/spleen
	internal_organs += new /obj/item/organ/intestines
	internal_organs += new /obj/item/organ/adrenals
	internal_organs += new /obj/item/organ/marrow
	internal_organs += new /obj/item/organ/larynx
	return ..()

/datum/techweb_node/cyber_organs/New()
	. = ..()
	design_ids += list("aq_cybernetic_kidneys", "aq_cybernetic_spleen", "aq_cybernetic_intestines", "aq_cybernetic_adrenals", "aq_cybernetic_marrow", "aq_synthesizer")
