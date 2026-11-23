// AQUILA - nadnercza (AquilaMed 5, etap 6). Sprite: przemalowana trzustka z Goonstation
// (icons/obj/items/organs/pancreas.dmi, CC BY-NC-SA 3.0).
// - Nadnercza trzymają zapas adrenaliny z medycyny 4 (pain/adrenaline.dm): uszkodzone mieszczą mniej, bez nich nie ma
//   adrenaliny wcale, cybernetyczne mieszczą półtora raza więcej.

// --- Nadnercza ---

/obj/item/organ/adrenals
	name = "nadnercza"
	desc = "Dwa małe gruczoły nad nerkami. Wyrzucają adrenalinę, kiedy coś mocno boli."
	icon = 'aquila/icons/obj/medical/organs_med5.dmi'
	icon_state = "adrenals"
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_ADRENALS
	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY
	/// Adrenaline reserve this pair holds when healthy
	var/capacity = 100

/obj/item/organ/adrenals/cybernetic
	name = "nadnercza cybernetyczne"
	desc = "Mechaniczne zbiorniki adrenaliny. Mieszczą jej więcej niż zwykłe, ale impuls EMP potrafi je uszkodzić."
	icon_state = "adrenals-cyber"
	organ_flags = ORGAN_SYNTHETIC
	status = ORGAN_ROBOTIC
	capacity = 150

/obj/item/organ/adrenals/cybernetic/emp_act(severity)
	. = ..()
	if(!(. & EMP_PROTECT_SELF))
		applyOrganDamage(25 / severity)

/// Most adrenaline the glands can hold now
/mob/living/carbon/human/proc/aq_adrenal_capacity()
	if(!dna?.species?.aq_has_med5_organs())
		return 100
	var/obj/item/organ/adrenals/adrenals = getorganslot(ORGAN_SLOT_ADRENALS)
	if(!adrenals || (adrenals.organ_flags & ORGAN_FAILING))
		return 0
	return adrenals.capacity * (1 - 0.6 * adrenals.damage / adrenals.maxHealth)

/datum/design/cybernetic_adrenals
	name = "Nadnercza cybernetyczne"
	desc = "Mechaniczne zbiorniki adrenaliny zamiast nadnerczy."
	id = "aq_cybernetic_adrenals"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 400, /datum/material/glass = 300, /datum/material/silver = 200)
	build_path = /obj/item/organ/adrenals/cybernetic
	category = list("Cybernetics", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
