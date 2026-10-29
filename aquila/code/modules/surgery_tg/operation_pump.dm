// AQUILA - tg code/modules/surgery/operations/operation_pump.dm
// Płukanie żołądka ręką (stara wersja: aquila/code/modules/surgery/stomach_pump.dm, port z Bee). Zostają nasze efekty:
// wymioty (20 jedzenia, ogłuszenie) i usunięcie 67% substancji, porażka to 5 uszkodzeń żołądka i 5 obrażeń.

/datum/surgery_operation/organ/stomach_pump
	name = "płukanie żołądka"
	rnd_name = "Płukanie żołądka"
	desc = "Uciska żołądek pacjenta ręką, wywołując wymioty, które usuwają szkodliwe substancje."
	operation_flags = OPERATION_NOTABLE
	implements = list(
		IMPLEMENT_HAND = 1,
	)
	time = 2 SECONDS
	success_sound = 'sound/surgery/organ2.ogg'
	required_organ_flag = ORGAN_ORGANIC
	target_type = /obj/item/organ/stomach
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT

/datum/surgery_operation/organ/stomach_pump/get_default_radial_image()
	return get_item_radial_image(/obj/item/organ/stomach)

/datum/surgery_operation/organ/stomach_pump/all_required_strings()
	return ..() + list("pacjent nie może być wysuszony")

/datum/surgery_operation/organ/stomach_pump/state_check(obj/item/organ/stomach/organ)
	return !HAS_TRAIT(organ.owner, TRAIT_HUSK)

/datum/surgery_operation/organ/stomach_pump/on_preop(obj/item/organ/stomach/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Zaczynasz uciskać żołądek [organ.owner]..."),
		span_notice("[surgeon] zaczyna uciskać żołądek [organ.owner]."),
		span_notice("[surgeon] zaczyna uciskać klatkę piersiową [organ.owner]."),
	)
	display_pain(organ.owner, "Czujesz okropne chlupotanie w brzuchu! Zaraz zwymiotujesz!")

/datum/surgery_operation/organ/stomach_pump/on_success(obj/item/organ/stomach/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/mob/living/carbon/patient = organ.owner
	display_results(
		surgeon,
		patient,
		span_notice("Zmuszasz [patient] do wymiotów, oczyszczając żołądek z części substancji!"),
		span_notice("[surgeon] zmusza [patient] do wymiotów, oczyszczając żołądek z części substancji!"),
		span_notice("[surgeon] zmusza [patient] do wymiotów!"),
	)
	patient.vomit(20, stun = TRUE)
	patient.reagents?.remove_all(patient.reagents.total_volume * 0.67) // mocniej niż zwykłe wymioty

/datum/surgery_operation/organ/stomach_pump/on_failure(obj/item/organ/stomach/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_warning("Partaczysz i obijasz klatkę piersiową [organ.owner]!"),
		span_warning("[surgeon] partaczy i obija klatkę piersiową [organ.owner]!"),
		span_warning("[surgeon] partaczy!"),
	)
	organ.applyOrganDamage(5)
	organ.owner?.adjustBruteLoss(5)

/// Płukanie przetwornika składników (robotyczny żołądek)
/datum/surgery_operation/organ/stomach_pump/mechanic
	name = "płukanie przetwornika składników"
	rnd_name = "Płukanie przetwornika składników (płukanie żołądka)"
	required_organ_flag = ORGAN_ROBOTIC
	operation_flags = OPERATION_NOTABLE | OPERATION_MECHANIC
