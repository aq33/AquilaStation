// AQUILA - odhuskowanie i balsamowanie (AquilaMed 5, etap 10).
// - Odhuskowanie: ciało spalone na wiór (husk) da się odbudować operacją, gdy we krwi ma co najmniej 5 j. rezadonu
//   albo 10 j. syntetycznego ciała (zwłoki nie metabolizują, więc lek czeka w ciele). Jak przy leczeniu chemią oparzenia muszą
//   być poniżej progu odhuskowania. Ciała wyssanego przez zmiennokształtnego to nie ratuje.
// - Balsamowanie: 10 j. formaldehydu wprowadzone operacją do zwłok zatrzymuje gnicie narządów na stałe, nawet gdy
//   formaldehyd z krwi zniknie. Ciało dalej da się ożywić i sklonować.

#define AQ_EMBALMED_TRAIT "aq_embalmed"

/// Organs of an embalmed body do not rot
/obj/item/organ/on_death()
	if(owner && HAS_TRAIT(owner, TRAIT_AQ_EMBALMED))
		return
	return ..()

/mob/living/carbon/human/examine(mob/user)
	. = ..()
	if(stat == DEAD && HAS_TRAIT(src, TRAIT_AQ_EMBALMED))
		. += "<span class='notice'>Ciało jest zabalsamowane i pachnie formaldehydem.</span>"

/datum/surgery_operation/limb/aq_unhusk
	name = "odbudowa tkanek (odhuskowanie)"
	catalog_sections = list(SURGERY_SECTION_CHEST)
	rnd_name = "Odbudowa zwęglonych tkanek"
	desc = "Odbudowuje ciało spalone na wiór. We krwi musi być co najmniej 5 j. rezadonu albo 10 j. syntetycznego ciała, a oparzenia poniżej progu odhuskowania."
	implements = list(TOOL_HEMOSTAT = 1, TOOL_SCALPEL = 1.5, /obj/item/kitchen/knife = 3)
	time = 8 SECONDS
	operation_flags = OPERATION_NOTABLE | OPERATION_MORBID
	all_surgery_states_required = SURGERY_SKIN_OPEN
	required_bodytype = BODYTYPE_ORGANIC
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/organ1.ogg'

/datum/surgery_operation/limb/aq_unhusk/all_required_strings()
	return list("operacja na klatce piersiowej", "ciało spalone na wiór (nie przez zmiennokształtnego)", "we krwi 5 j. rezadonu albo 10 j. syntetycznego ciała", "oparzenia poniżej [THRESHOLD_UNHUSK]") + ..()

/datum/surgery_operation/limb/aq_unhusk/state_check(obj/item/bodypart/limb)
	var/mob/living/carbon/patient = limb.owner
	if(limb.body_zone != BODY_ZONE_CHEST || !patient || !HAS_TRAIT(patient, TRAIT_HUSK) || HAS_TRAIT_FROM(patient, TRAIT_HUSK, CHANGELING_DRAIN))
		return FALSE
	return patient.getFireLoss() < THRESHOLD_UNHUSK && patient.reagents && (patient.reagents.get_reagent_amount(/datum/reagent/medicine/rezadone) >= 5 || patient.reagents.get_reagent_amount(/datum/reagent/medicine/synthflesh) >= 10)

/datum/surgery_operation/limb/aq_unhusk/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(surgeon, limb.owner, span_notice("Zaczynasz zdzierać zwęgloną tkankę z [limb.owner]..."), span_notice("[surgeon] zaczyna zdzierać zwęgloną tkankę z [limb.owner]."), span_notice("[surgeon] zaczyna operację [limb.owner]."))

/datum/surgery_operation/limb/aq_unhusk/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/mob/living/carbon/patient = limb.owner
	if(!state_check(limb))
		return
	if(patient.reagents.get_reagent_amount(/datum/reagent/medicine/rezadone) >= 5)
		patient.reagents.remove_reagent(/datum/reagent/medicine/rezadone, 5)
	else
		patient.reagents.remove_reagent(/datum/reagent/medicine/synthflesh, 10)
	REMOVE_TRAIT_NOT_FROM(patient, TRAIT_HUSK, list(CHANGELING_DRAIN))
	REMOVE_TRAIT(patient, TRAIT_DISFIGURED, "husk")
	patient.update_body()
	if(ishuman(patient)) // as /mob/living/carbon/human/cure_husk: the hair comes back too
		var/mob/living/carbon/human/human_patient = patient
		human_patient.update_hair()
	display_results(surgeon, patient, span_notice("Odbudowujesz tkanki [patient], ciało znowu wygląda jak ciało."), span_notice("[surgeon] odbudowuje tkanki [patient]!"), span_notice("[surgeon] kończy operację [patient]."))

/datum/surgery_operation/limb/aq_embalm
	name = "balsamowanie"
	catalog_sections = list(SURGERY_SECTION_CHEST)
	rnd_name = "Balsamowanie zwłok"
	desc = "Wprowadza do zwłok 10 j. formaldehydu z pojemnika. Narządy przestają gnić na stałe, a ciało dalej da się ożywić i sklonować."
	implements = list(/obj/item/reagent_containers = 1)
	time = 6 SECONDS
	operation_flags = OPERATION_MORBID
	all_surgery_states_required = SURGERY_SKIN_OPEN
	required_bodytype = BODYTYPE_ORGANIC
	success_sound = 'sound/effects/spray.ogg'

/datum/surgery_operation/limb/aq_embalm/all_required_strings()
	return list("operacja na klatce piersiowej", "pacjent nie żyje", "pojemnik z 10 j. formaldehydu") + ..()

/datum/surgery_operation/limb/aq_embalm/get_default_radial_image()
	return image(icon = 'icons/obj/chemical.dmi', icon_state = "bottle")

/datum/surgery_operation/limb/aq_embalm/state_check(obj/item/bodypart/limb)
	return limb.body_zone == BODY_ZONE_CHEST && limb.owner?.stat == DEAD && !HAS_TRAIT(limb.owner, TRAIT_AQ_EMBALMED)

/datum/surgery_operation/limb/aq_embalm/tool_check(obj/item/tool)
	var/obj/item/reagent_containers/container = tool
	return istype(container) && container.reagents?.get_reagent_amount(/datum/reagent/toxin/formaldehyde) >= 10

/datum/surgery_operation/limb/aq_embalm/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(surgeon, limb.owner, span_notice("Zaczynasz balsamować zwłoki [limb.owner]..."), span_notice("[surgeon] zaczyna balsamować zwłoki [limb.owner]."), span_notice("[surgeon] zaczyna operację [limb.owner]."))

/datum/surgery_operation/limb/aq_embalm/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/obj/item/reagent_containers/container = tool
	if(!limb.owner || !container.reagents || container.reagents.get_reagent_amount(/datum/reagent/toxin/formaldehyde) < 10)
		return
	container.reagents.trans_id_to(limb.owner, /datum/reagent/toxin/formaldehyde, 10)
	ADD_TRAIT(limb.owner, TRAIT_AQ_EMBALMED, AQ_EMBALMED_TRAIT)
	display_results(surgeon, limb.owner, span_notice("Balsamujesz zwłoki [limb.owner]. Narządy nie będą już gnić."), span_notice("[surgeon] balsamuje zwłoki [limb.owner]."), span_notice("[surgeon] kończy operację [limb.owner]."))

#undef AQ_EMBALMED_TRAIT
