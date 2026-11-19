// AQUILA - balsamowanie (AquilaMed 5, etap 10).
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
