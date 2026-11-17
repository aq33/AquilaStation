// AQUILA - nadnercza i szpik kostny (AquilaMed 5, etap 6). Sprite nadnerczy: przemalowana trzustka z Goonstation
// (icons/obj/items/organs/pancreas.dmi, CC BY-NC-SA 3.0), szpik: kość z naszego icons/obj/mining.dmi z rdzeniem.
// - Nadnercza trzymają zapas adrenaliny z medycyny 4 (pain/adrenaline.dm): uszkodzone mieszczą mniej, bez nich nie ma
//   adrenaliny wcale, cybernetyczne mieszczą półtora raza więcej.
// - Szpik kostny robi krew: tempo odnowy krwi (surgery/organs/heart_blood.dm) zależy od jego zdrowia, cybernetyczny
//   przyspiesza ją o połowę. Uszkadza go promieniowanie i otwarte złamania. Przeszczep tylko od dawcy z tą samą grupą
//   krwi, inaczej szpik jest odrzucany.

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

// --- Szpik kostny ---

/obj/item/organ/marrow
	name = "szpik kostny"
	desc = "Próbka szpiku kostnego. Z niego organizm robi nową krew."
	icon = 'aquila/icons/obj/medical/organs_med5.dmi'
	icon_state = "marrow"
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_MARROW
	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY
	low_threshold_passed = "<span class='info'>Jesteś dziwnie blady i szybko się męczysz.</span>"
	high_threshold_passed = "<span class='warning'>Kręci ci się w głowie przy każdym wysiłku.</span>"
	/// How fast it makes blood when healthy
	var/blood_regeneration_multiplier = 1
	/// Blood type of the body it grew in; another type rejects it
	var/donor_blood_type

/obj/item/organ/marrow/cybernetic
	name = "szpik cybernetyczny"
	desc = "Mechaniczna wytwórnia krwi. Robi ją szybciej niż zwykły szpik, pasuje do każdej grupy krwi, ale impuls EMP potrafi ją uszkodzić."
	icon_state = "marrow-cyber"
	organ_flags = ORGAN_SYNTHETIC
	status = ORGAN_ROBOTIC
	blood_regeneration_multiplier = 1.5

/obj/item/organ/marrow/cybernetic/emp_act(severity)
	. = ..()
	if(!(. & EMP_PROTECT_SELF))
		applyOrganDamage(25 / severity)

// The blood type is taken only when the marrow leaves a body: a fresh organ from spawn fits whatever blood type
// the character gets later from the preferences.
/obj/item/organ/marrow/Remove(mob/living/carbon/M, special = 0)
	if(!donor_blood_type && M?.dna?.blood_type) // the first body is the donor; later removals do not change it
		donor_blood_type = M.dna.blood_type
	return ..()

/obj/item/organ/marrow/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	if(is_rejected())
		to_chat(M, "<span class='warning'>Coś w twoich kościach jest nie tak, organizm walczy z obcym szpikiem.</span>")

/// The body fights marrow of another blood type
/obj/item/organ/marrow/proc/is_rejected()
	return owner && !(organ_flags & ORGAN_SYNTHETIC) && donor_blood_type && owner.dna?.blood_type && owner.dna.blood_type != donor_blood_type

/obj/item/organ/marrow/on_life()
	. = ..()
	if(!owner || owner.stat == DEAD)
		return
	if(is_rejected())
		applyOrganDamage(0.5)
		if(owner.getToxLoss() < 40)
			owner.adjustToxLoss(0.2)
	if(HAS_TRAIT(owner, TRAIT_IRRADIATED) && !(organ_flags & ORGAN_SYNTHETIC))
		applyOrganDamage(0.3)

/obj/item/organ/marrow/proc/get_blood_regeneration_multiplier()
	if(organ_flags & ORGAN_FAILING)
		return 0.2
	return blood_regeneration_multiplier * (1 - 0.6 * damage / maxHealth)

/obj/item/organ/marrow/aq_scan_line()
	if(is_rejected())
		return "<b>Odrzucanie przeszczepu szpiku:</b> grupa krwi dawcy ([donor_blood_type]) nie pasuje. Wymień szpik."

/// Blood regeneration also needs the marrow (heart_blood.dm)
/mob/living/carbon/get_heart_blood_regeneration_multiplier()
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/H = src
	if(!istype(H) || !H.dna?.species?.aq_has_med5_organs())
		return
	var/obj/item/organ/marrow/marrow = getorganslot(ORGAN_SLOT_MARROW)
	. *= marrow ? marrow.get_blood_regeneration_multiplier() : 0.1

/// An open fracture damages the marrow
/datum/wound/blunt/compound/on_apply()
	. = ..()
	var/obj/item/organ/marrow/marrow = victim?.getorganslot(ORGAN_SLOT_MARROW)
	marrow?.applyOrganDamage(10)

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

/datum/design/cybernetic_marrow
	name = "Szpik cybernetyczny"
	desc = "Mechaniczna wytwórnia krwi zamiast szpiku."
	id = "aq_cybernetic_marrow"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 500, /datum/material/glass = 300, /datum/material/gold = 200)
	build_path = /obj/item/organ/marrow/cybernetic
	category = list("Cybernetics", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
