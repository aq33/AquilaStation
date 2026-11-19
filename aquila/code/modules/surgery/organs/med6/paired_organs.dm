// AQUILA - lewe i prawe płuco oraz nerka (AquilaMed 6, etap 6). Na wzór Goonstation (code/obj/item/organs/lung.dm,
// kidney.dm: osobne lewe i prawe narządy) i Erisa (para nerek), sprite'y połówek z Goona (CC BY-NC-SA 3.0).
// Różnica względem Goona: tam każda połówka to osobny narząd w osobnym slocie. U nas oddychanie i filtrowanie krwi
// w core zna jeden narząd płuc i jeden nerek, więc para zostaje jednym narządem, który pamięta, które strony ma:
// - operacja „wycięcie jednego płuca/jednej nerki” zostawia w ciele połowę i daje drugą jako osobny narząd do
//   przeszczepu (żywy dawca nerki); „dołączenie” wszywa brakującą stronę z takiego narządu;
// - jedno płuco: płytszy oddech (trochę niedotlenienia przy wysiłku), jedna nerka filtruje słabiej i szybciej się psuje.

/obj/item/organ
	/// AquilaMed 6: this organ is a left and right pair
	var/aq_paired = FALSE
	/// Which sides of the pair it has
	var/aq_sides = AQ_SIDES_BOTH
	/// Name of one half for messages ("płuco", "nerka")
	var/aq_half_name
	/// Icon state prefix of a half in organs_med6.dmi
	var/aq_half_icon

/obj/item/organ/lungs
	aq_half_name = "płuco"
	aq_half_icon = "lung"

/obj/item/organ/kidneys
	aq_paired = TRUE
	aq_half_name = "nerka"
	aq_half_icon = "kidney"

// Only plain human lungs come in halves: species lungs (plasma filter, vacuole) stay one organ
/obj/item/organ/lungs/Initialize(mapload)
	. = ..()
	aq_paired = (type == /obj/item/organ/lungs || type == /obj/item/organ/lungs/cybernetic || type == /obj/item/organ/lungs/cybernetic/upgraded)

/// Sides the pair has
/obj/item/organ/proc/aq_working_sides()
	return !!(aq_sides & AQ_SIDE_LEFT) + !!(aq_sides & AQ_SIDE_RIGHT)

/obj/item/organ/proc/aq_side_name(side)
	return side == AQ_SIDE_LEFT ? "lewe" : "prawe"

/// Shows the half that is left
/obj/item/organ/proc/aq_update_half()
	if(!aq_paired || !aq_half_icon)
		return
	if(aq_sides == AQ_SIDES_BOTH)
		icon = initial(icon)
		icon_state = initial(icon_state)
		name = initial(name)
		return
	var/left = aq_sides & AQ_SIDE_LEFT
	icon = 'aquila/icons/obj/medical/organs_med6.dmi'
	icon_state = "[aq_half_icon]-[left ? "left" : "right"][(organ_flags & ORGAN_SYNTHETIC) ? "-cyber" : ""]"
	if(istype(src, /obj/item/organ/kidneys))
		name = "[left ? "lewa" : "prawa"] [initial(name) == "nerki" ? "nerka" : "nerka cybernetyczna"]"
	else
		name = "[left ? "lewe" : "prawe"] [(organ_flags & ORGAN_SYNTHETIC) ? "płuco cybernetyczne" : "płuco"]"

/// One half in the accusative for surgery messages ("wycinasz lewą nerkę", "wszywasz prawe płuco")
/obj/item/organ/proc/aq_half_accusative()
	var/left = aq_sides & AQ_SIDE_LEFT
	var/cyber = organ_flags & ORGAN_SYNTHETIC
	if(istype(src, /obj/item/organ/kidneys))
		return "[left ? "lewą" : "prawą"] nerkę[cyber ? " cybernetyczną" : ""]"
	return "[left ? "lewe" : "prawe"] płuco[cyber ? " cybernetyczne" : ""]"

/obj/item/organ/examine(mob/user)
	. = ..()
	if(aq_paired && aq_sides != AQ_SIDES_BOTH)
		. += "<span class='notice'>To tylko jedna strona pary. Wszyje się ją pacjentowi, któremu brakuje [(aq_sides & AQ_SIDE_LEFT) ? "lewej" : "prawej"] strony, albo jako jedyną.</span>"

/obj/item/organ/aq_scan_line()
	. = ..()
	if(. || !aq_paired)
		return
	if(aq_sides != AQ_SIDES_BOTH)
		return "Tylko [(aq_sides & AQ_SIDE_LEFT) ? "lewa" : "prawa"] strona: [aq_half_name == "nerka" ? "jedna nerka" : "jedno płuco"]."

// --- Płuca ---

/obj/item/organ/lungs/check_breath(datum/gas_mixture/breath, mob/living/carbon/human/H)
	. = ..()
	if(aq_paired && aq_working_sides() == 1 && H.getOxyLoss() < 20 && !H.failed_last_breath)
		H.adjustOxyLoss(H.m_intent == MOVE_INTENT_RUN ? 0.6 : 0.2)

// --- Nerki ---

/obj/item/organ/kidneys/aq_efficiency()
	. = ..()
	if(aq_sides != AQ_SIDES_BOTH)
		. *= 0.7

/obj/item/organ/kidneys/on_life()
	. = ..()
	// Jedna nerka pracuje za dwie i szybciej się psuje od toksyn
	if(owner && owner.stat != DEAD && aq_sides != AQ_SIDES_BOTH && owner.getToxLoss() > 30 && !(organ_flags & ORGAN_SYNTHETIC))
		applyOrganDamage(0.1)

// --- Operacje ---

/// Takes one side out as its own organ
/datum/surgery_operation/organ/aq_split_pair
	abstract_type = /datum/surgery_operation/organ/aq_split_pair
	desc = "Wycina jedną stronę pary jako osobny narząd: do przeszczepu albo gdy jedna strona jest zniszczona. W ciele zostaje druga."
	implements = list(TOOL_SCALPEL = 1, /obj/item/melee/transforming/energy/sword = 1.5, /obj/item/kitchen/knife = 2.5)
	time = 6 SECONDS
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT
	required_organ_flag = ORGAN_ORGANIC|ORGAN_ROBOTIC
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/organ1.ogg'

/datum/surgery_operation/organ/aq_split_pair/state_check(obj/item/organ/organ)
	return organ.aq_paired && organ.aq_sides == AQ_SIDES_BOTH

/datum/surgery_operation/organ/aq_split_pair/all_required_strings()
	return list("narząd ma obie strony") + ..()

/// The left one, as in a living kidney donation
/datum/surgery_operation/organ/aq_split_pair/proc/pick_side(obj/item/organ/organ)
	return AQ_SIDE_LEFT

/datum/surgery_operation/organ/aq_split_pair/on_preop(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(surgeon, organ.owner, span_notice("Zaczynasz odcinać jedną stronę: [organ]..."), span_notice("[surgeon] zaczyna odcinać część narządu [FORMAT_ORGAN_OWNER(organ)]."), span_notice("[surgeon] zaczyna operację."))
	display_pain(organ.owner, "Czujesz głęboki, ciągnący ból w środku!")

/datum/surgery_operation/organ/aq_split_pair/on_success(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/side = pick_side(organ)
	var/obj/item/organ/half = new organ.type(get_turf(organ.owner || organ))
	half.aq_sides = side
	half.setOrganDamage(organ.damage)
	half.aq_update_half()
	organ.aq_sides &= ~side
	organ.aq_update_half()
	display_results(surgeon, organ.owner, span_notice("Wycinasz [half.aq_half_accusative()]."), span_notice("[surgeon] wycina [half.aq_half_accusative()] [FORMAT_ORGAN_OWNER(organ)]."), span_notice("[surgeon] wycina coś z [FORMAT_ORGAN_OWNER(organ)]."))

/datum/surgery_operation/organ/aq_split_pair/on_failure(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	organ.applyOrganDamage(15)
	display_results(surgeon, organ.owner, span_warning("Nacinasz za głęboko i kaleczysz [organ]!"), span_warning("[surgeon] kaleczy [organ]!"), span_warning("[surgeon] partaczy!"))

/datum/surgery_operation/organ/aq_split_pair/lungs
	name = "wycięcie jednego płuca"
	rnd_name = "Pneumonektomia (wycięcie jednego płuca)"
	target_type = /obj/item/organ/lungs
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT|SURGERY_BONE_SAWED

/datum/surgery_operation/organ/aq_split_pair/kidneys
	name = "wycięcie jednej nerki"
	rnd_name = "Nefrektomia (wycięcie jednej nerki)"
	target_type = /obj/item/organ/kidneys

/// Sews the missing side in from a one-sided organ of the same kind
/datum/surgery_operation/organ/aq_join_pair
	abstract_type = /datum/surgery_operation/organ/aq_join_pair
	desc = "Wszywa brakującą stronę pary z osobnego narządu tego samego rodzaju, który ma tylko tę stronę."
	time = 8 SECONDS
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT
	required_organ_flag = ORGAN_ORGANIC|ORGAN_ROBOTIC
	preop_sound = 'sound/surgery/organ2.ogg'
	success_sound = 'sound/surgery/organ1.ogg'

/datum/surgery_operation/organ/aq_join_pair/state_check(obj/item/organ/organ)
	return organ.aq_paired && organ.aq_sides != AQ_SIDES_BOTH

/datum/surgery_operation/organ/aq_join_pair/all_required_strings()
	return list("w ciele brakuje jednej strony", "w ręce narząd z brakującą stroną") + ..()

/datum/surgery_operation/organ/aq_join_pair/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, obj/item/organ/tool, operated_zone)
	// the surgery hands the organ itself (check_availability), get_operation_target only for a body or a limb
	var/obj/item/organ/organ = isorgan(operating_on) ? operating_on : get_operation_target(operating_on, operated_zone)
	return istype(tool) && istype(organ) && istype(tool, target_type) && tool.aq_paired && tool.aq_sides == (AQ_SIDES_BOTH & ~organ.aq_sides) && tool.status == organ.status

/datum/surgery_operation/organ/aq_join_pair/on_preop(obj/item/organ/organ, mob/living/surgeon, obj/item/organ/tool, list/operation_args)
	display_results(surgeon, organ.owner, span_notice("Zaczynasz wszywać [tool.aq_half_accusative()]..."), span_notice("[surgeon] zaczyna wszywać [tool.aq_half_accusative()] [FORMAT_ORGAN_OWNER(organ)]."), span_notice("[surgeon] zaczyna operację."))
	display_pain(organ.owner, "Czujesz głęboki ucisk w środku!")

/datum/surgery_operation/organ/aq_join_pair/on_success(obj/item/organ/organ, mob/living/surgeon, obj/item/organ/tool, list/operation_args)
	if(QDELETED(tool) || !istype(tool))
		return
	organ.aq_sides |= tool.aq_sides
	organ.setOrganDamage((organ.damage + tool.damage) / 2)
	organ.aq_update_half()
	display_results(surgeon, organ.owner, span_notice("Wszywasz [tool.aq_half_accusative()]. Para znów jest cała."), span_notice("[surgeon] wszywa [tool.aq_half_accusative()] [FORMAT_ORGAN_OWNER(organ)]."), span_notice("[surgeon] kończy operację."))
	qdel(tool)

/datum/surgery_operation/organ/aq_join_pair/lungs
	name = "dołączenie płuca"
	rnd_name = "Przeszczep jednego płuca"
	target_type = /obj/item/organ/lungs
	implements = list(/obj/item/organ/lungs = 1)
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT|SURGERY_BONE_SAWED

/datum/surgery_operation/organ/aq_join_pair/kidneys
	name = "dołączenie nerki"
	rnd_name = "Przeszczep jednej nerki"
	target_type = /obj/item/organ/kidneys
	implements = list(/obj/item/organ/kidneys = 1)
