// AQUILA - odpowiednik "eksperymentalnej wymiany organów" abduktorów (code/modules/antagonists/abductor/equipment/abduction_surgery.dm).
// W tg abduktorzy robią to zwykłymi operacjami w wersjach /abductor (przez ubranie, serce bez piłowania kości), które
// są w operation_generic.dm i operation_organ_manip.dm. Tu tylko:
// - odblokowanie wersji /abductor tak jak starej operacji: gatunek abduktora albo implant abduktora (antagoniści
//   abduktorów mają też TRAIT_SURGEON, który odblokowuje wszystko, patrz surgery_bridge.dm),
// - gruczoł wkładany tą operacją dostaje Insert(special = 2), czyli nie startuje od razu (jak stary krok gland_insert).

/datum/surgery_operation/limb/incise_skin/abductor
	legacy_unlocked_by = list(/datum/surgery/organ_extraction)

/datum/surgery_operation/limb/retract_skin/abductor
	legacy_unlocked_by = list(/datum/surgery/organ_extraction)

/datum/surgery_operation/limb/close_skin/abductor
	legacy_unlocked_by = list(/datum/surgery/organ_extraction)

/datum/surgery_operation/limb/clamp_bleeders/abductor
	legacy_unlocked_by = list(/datum/surgery/organ_extraction)

/datum/surgery_operation/limb/unclamp_bleeders/abductor
	legacy_unlocked_by = list(/datum/surgery/organ_extraction)

/datum/surgery_operation/limb/incise_organs/abductor
	legacy_unlocked_by = list(/datum/surgery/organ_extraction)

/datum/surgery_operation/limb/organ_manipulation/internal/abductor
	legacy_unlocked_by = list(/datum/surgery/organ_extraction)

/datum/surgery_operation/limb/organ_manipulation/internal/abductor/get_insert_special(obj/item/organ/organ)
	if(istype(organ, /obj/item/organ/heart/gland))
		return 2 // "special 2 means abductor surgery" (gland.dm)
	return ..()

/// Czy chirurg może robić eksperymentalną wymianę organów abduktorów (te same warunki co stare /datum/surgery/organ_extraction/can_start)
/mob/living/proc/can_abductor_organ_extraction()
	if(!ishuman(src))
		return FALSE
	var/mob/living/carbon/human/human_self = src
	if(isabductor(human_self))
		return TRUE
	return !!(locate(/obj/item/implant/abductor) in human_self.implants)
