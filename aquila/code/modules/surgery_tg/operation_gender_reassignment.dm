// AQUILA - nowa wersja naszej operacji zmiany płci (stara: aquila/code/modules/surgery/gender_reassignment.dm), w tg jej nie ma.
// Pachwina organicznego człowieka, po odciągnięciu skóry i zaciśnięciu naczyń. Sukces zamienia płeć (kobieta <-> mężczyzna,
// inna płeć staje się kobietą, jak w starej wersji) i zdejmuje niejednoznaczność, porażka losuje płeć i zostawia
// niejednoznaczne genitalia.

/datum/surgery_operation/limb/gender_reassignment
	name = "zmiana płci"
	rnd_name = "Chirurgia rekonstrukcyjna narządów płciowych (zmiana płci)"
	desc = "Przekształca genitalia pacjenta, zmieniając jego płeć."
	implements = list(
		/obj/item/scalpel = 1,
		/obj/item/hatchet = 2,
		TOOL_WIRECUTTER = 2.85,
	)
	time = 6.4 SECONDS
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE
	required_bodytype = BODYTYPE_ORGANIC
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/scalpel2.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED

/datum/surgery_operation/limb/gender_reassignment/get_default_radial_image()
	return get_generic_limb_radial_image(BODY_ZONE_CHEST)

/datum/surgery_operation/limb/gender_reassignment/all_required_strings()
	return list("operacja na: [strefa_pl(BODY_ZONE_PRECISE_GROIN)]", "pacjent musi być człowiekiem") + ..()

/datum/surgery_operation/limb/gender_reassignment/state_check(obj/item/bodypart/limb)
	return limb.body_zone == BODY_ZONE_CHEST && ishuman(limb.owner)

/datum/surgery_operation/limb/gender_reassignment/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, tool, operated_zone)
	return operated_zone == BODY_ZONE_PRECISE_GROIN

/datum/surgery_operation/limb/gender_reassignment/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/target_gender = limb.owner.gender == FEMALE ? "bardziej męsko" : "bardziej kobieco"
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz przekształcać genitalia [limb.owner], by wyglądały [target_gender]."),
		span_notice("[surgeon] zaczyna przekształcać genitalia [limb.owner], by wyglądały [target_gender]."),
		span_notice("[surgeon] zaczyna operację w pachwinie [limb.owner]."),
	)
	display_pain(limb.owner, "Czujesz piekący ból w pachwinie!")

/datum/surgery_operation/limb/gender_reassignment/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/mob/living/carbon/human/patient = limb.owner
	patient.gender_ambiguous = FALSE
	if(patient.gender == FEMALE)
		patient.gender = MALE
		display_results(
			surgeon,
			patient,
			span_notice("Robisz faceta z [patient]!"),
			span_notice("[surgeon] zrobił faceta z [patient]!"),
			span_notice("[surgeon] kończy operację w pachwinie [patient]."),
		)
	else
		patient.gender = FEMALE
		display_results(
			surgeon,
			patient,
			span_notice("Robisz kobietę z [patient]!"),
			span_notice("[surgeon] zrobił kobietę z [patient]!"),
			span_notice("[surgeon] kończy operację w pachwinie [patient]."),
		)
	patient.regenerate_icons()

/datum/surgery_operation/limb/gender_reassignment/on_failure(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/mob/living/carbon/human/patient = limb.owner
	patient.gender_ambiguous = TRUE
	patient.gender = pick(MALE, FEMALE)
	patient.regenerate_icons()
	display_results(
		surgeon,
		patient,
		span_warning("Okaleczasz genitalia [patient], bezpowrotnie!"),
		span_warning("[surgeon] okalecza genitalia [patient], bezpowrotnie!"),
		span_notice("[surgeon] kończy operację w pachwinie [patient]."),
	)
	display_pain(patient, "Pachwina płonie potwornym bólem!")
