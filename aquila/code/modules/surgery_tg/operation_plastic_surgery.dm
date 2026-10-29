// AQUILA - tg code/modules/surgery/operations/operation_plastic_surgery.dm
// Chirurgia plastyczna (stara wersja: code/modules/surgery/plastic_surgery.dm). Zostaje nasze zachowanie:
// oszpecenie (TRAIT_DISFIGURED) siedzi na mobie i operacja je usuwa zamiast zmiany wyglądu, nowe imię z listy
// losowych imion gatunku, abduktor dostaje listę "Subject ..." i jedno zwykłe imię, zmienia się tylko real_name
// (jak w starej wersji), potem odświeża się sec HUD. Tylko organiczna głowa.
// Pominięte z tg: nakładanie plastiku i wygląd ze zdjęcia (add_plastic, SURGERY_PLASTIC_APPLIED), bo u nas tego nie było
// i w tg odblokowują to badania, których nie mamy; nastrój TRAIT_MORBID; operacja na odciętej głowie.

#define OPERATION_NEW_NAME "chosen_name"

/datum/surgery_operation/limb/plastic_surgery
	name = "chirurgia plastyczna"
	desc = "Przekształca albo odtwarza twarz pacjenta."
	implements = list(
		TOOL_SCALPEL = 1,
		/obj/item/kitchen/knife = 2,
		TOOL_WIRECUTTER = 2.85,
	)
	time = 6.4 SECONDS
	operation_flags = OPERATION_MORBID | OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE
	required_bodytype = BODYTYPE_ORGANIC
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/scalpel2.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN

/datum/surgery_operation/limb/plastic_surgery/all_required_strings()
	return list("operacja na: [strefa_pl(BODY_ZONE_HEAD)]") + ..()

/datum/surgery_operation/limb/plastic_surgery/get_default_radial_image()
	return get_item_radial_image(/obj/item/scalpel)

/datum/surgery_operation/limb/plastic_surgery/state_check(obj/item/bodypart/limb)
	return limb.body_zone == BODY_ZONE_HEAD && ishuman(limb.owner)

/datum/surgery_operation/limb/plastic_surgery/pre_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/mob/living/carbon/human/patient = limb.owner
	if(HAS_TRAIT_FROM(patient, TRAIT_DISFIGURED, TRAIT_GENERIC))
		return TRUE // przy naprawie oszpecenia nie wybiera się imienia

	var/list/names = list()
	if(isabductor(surgeon))
		for(var/i in 1 to 9)
			names += "Subject [patient.gender == MALE ? "i" : "o"]-[pick("a", "b", "c", "d", "e")]-[rand(10000, 99999)]"
		names += patient.dna.species.random_name(patient.gender, TRUE) // jedno zwykłe imię, gdyby chciał zwykłej operacji
	else
		for(var/i in 1 to 10)
			names += patient.dna.species.random_name(patient.gender, TRUE)

	operation_args[OPERATION_NEW_NAME] = input(surgeon, "Wybierz nowe imię.", "Chirurgia plastyczna") as null|anything in names
	return !!operation_args[OPERATION_NEW_NAME]

/datum/surgery_operation/limb/plastic_surgery/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz zmieniać wygląd [limb.owner]..."),
		span_notice("[surgeon] zaczyna zmieniać wygląd [limb.owner]."),
		span_notice("[surgeon] zaczyna nacinać twarz [limb.owner]."),
	)
	display_pain(limb.owner, "Czujesz tnący ból na twarzy!")

/datum/surgery_operation/limb/plastic_surgery/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/mob/living/carbon/human/patient = limb.owner
	if(HAS_TRAIT_FROM(patient, TRAIT_DISFIGURED, TRAIT_GENERIC))
		REMOVE_TRAIT(patient, TRAIT_DISFIGURED, TRAIT_GENERIC)
		display_results(
			surgeon,
			patient,
			span_notice("Pomyślnie przywracasz wygląd [patient]."),
			span_notice("[surgeon] pomyślnie przywraca wygląd [patient]!"),
			span_notice("[surgeon] kończy operację twarzy [patient]."),
		)
		display_pain(patient, "Ból mija, twarz znowu jest normalna!")
	else if(operation_args[OPERATION_NEW_NAME])
		var/oldname = patient.real_name
		patient.real_name = operation_args[OPERATION_NEW_NAME]
		display_results(
			surgeon,
			patient,
			span_notice("Całkowicie zmieniasz wygląd [oldname], teraz to [patient.real_name]."),
			span_notice("[surgeon] całkowicie zmienia wygląd [oldname], teraz to [patient.real_name]!"),
			span_notice("[surgeon] kończy operację twarzy [patient]."),
		)
		display_pain(patient, "Ból mija, twarz jest nowa i obca!")
	patient.sec_hud_set_ID()

/datum/surgery_operation/limb/plastic_surgery/on_failure(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_warning("Partaczysz, oszpecając [limb.owner]!"),
		span_warning("[surgeon] partaczy, oszpecając [limb.owner]!"),
		span_notice("[surgeon] kończy operację twarzy [limb.owner]."),
	)
	display_pain(limb.owner, "Twarz jest okropnie pocięta i zniekształcona!")
	ADD_TRAIT(limb.owner, TRAIT_DISFIGURED, TRAIT_GENERIC)

#undef OPERATION_NEW_NAME
