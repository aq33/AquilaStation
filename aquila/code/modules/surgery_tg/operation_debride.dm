// AQUILA - tg code/modules/surgery/operations/operation_debride.dm
// Usunięcie martwej tkanki z oparzenia (stara wersja: aq_debride w aquila/code/modules/wounds/treatment.dm).
// U nas oparzenie (/datum/wound/burn) nie ma skali zakażenia jak w tg, więc zostaje nasze zachowanie: jedno udane
// cięcie usuwa ranę oparzeniową i zadaje 5 obrażeń, bez pętli. Pominięte z tg: TRAIT_WOUND_SCANNED, sanitization.

/datum/surgery_operation/limb/debride
	name = "usunięcie martwej tkanki"
	rnd_name = "Debridement"
	desc = "Wycina martwą i zakażoną tkankę z oparzenia, żeby rana mogła się zagoić."
	implements = list(
		TOOL_SCALPEL = 1,
		TOOL_HEMOSTAT = 1.66,
		TOOL_SAW = 2.5,
		TOOL_WIRECUTTER = 3.33,
	)
	time = 4 SECONDS
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_PRIORITY_NEXT_STEP | OPERATION_NO_PATIENT_REQUIRED
	preop_sound = list(
		TOOL_SCALPEL = 'sound/surgery/scalpel1.ogg',
		TOOL_HEMOSTAT = 'sound/surgery/hemostat1.ogg',
	)
	success_sound = 'sound/surgery/scalpel2.ogg'
	failure_sound = 'sound/surgery/organ1.ogg'
	required_bodytype = ~BODYTYPE_ROBOTIC

/datum/surgery_operation/limb/debride/get_default_radial_image()
	return image(icon = 'icons/obj/surgery.dmi', icon_state = "scalpel")

/datum/surgery_operation/limb/debride/all_required_strings()
	return list("kończyna musi mieć oparzenie drugiego stopnia albo gorsze") + ..()

/datum/surgery_operation/limb/debride/state_check(obj/item/bodypart/limb)
	return !isnull(limb.get_wound(WOUND_BURN))

/datum/surgery_operation/limb/debride/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz wycinać martwą tkankę ([FORMAT_LIMB_OWNER(limb)])..."),
		span_notice("[surgeon] zaczyna wycinać martwą tkankę ([FORMAT_LIMB_OWNER(limb)]) za pomocą [tool]."),
		span_notice("[surgeon] zaczyna wycinać martwą tkankę ([FORMAT_LIMB_OWNER(limb)])."),
	)
	display_pain(limb.owner, "Oparzenie ([strefa_pl(limb.body_zone)]) piecze jak diabli, jakby ktoś cię dźgał!")

/datum/surgery_operation/limb/debride/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/datum/wound/burn = limb.get_wound(WOUND_BURN)
	qdel(burn)
	limb.owner?.apply_damage(5, BRUTE, limb)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Wycinasz martwą tkankę ([FORMAT_LIMB_OWNER(limb)])."),
		span_notice("[surgeon] wycina martwą tkankę ([FORMAT_LIMB_OWNER(limb)]) za pomocą [tool]!"),
		span_notice("[surgeon] kończy operację ([FORMAT_LIMB_OWNER(limb)])."),
	)

/datum/surgery_operation/limb/debride/on_failure(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_warning("Wycinasz kawałek zdrowej tkanki ([FORMAT_LIMB_OWNER(limb)])."),
		span_warning("[surgeon] wycina kawałek zdrowej tkanki ([FORMAT_LIMB_OWNER(limb)]) za pomocą [tool]!"),
		span_warning("[surgeon] wycina kawałek zdrowej tkanki ([FORMAT_LIMB_OWNER(limb)])!"),
	)
	limb.owner?.apply_damage(rand(4, 8), BRUTE, limb)
