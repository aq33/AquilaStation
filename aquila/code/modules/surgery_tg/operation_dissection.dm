// AQUILA - tg code/modules/surgery/operations/operation_dissection.dm
// Eksperymentalna sekcja (stara wersja: code/modules/surgery/advanced/bioware/experimental_dissection.dm).
// Zaawansowana operacja: OPERATION_LOCKED, odblokowują ją dyski i projekty /datum/design/surgery (surgery_unlocks.dm).
// Zostaje nasze zachowanie: punkty odkryć trafiają od razu do bazy badań (bez notatek badawczych z tg) według naszej
// tabeli, nieudana sekcja daje 20% punktów, zawsze 80 obrażeń w klatkę i TRAIT_DISSECTED, borgi nie mogą jej robić,
// tylko martwe węglowe moby.

/datum/surgery_operation/basic/dissection
	name = "eksperymentalna sekcja"
	rnd_name = "Eksperymentalna androtomia (sekcja)"
	desc = "Przeprowadza eksperymentalną sekcję zwłok i dopisuje odkrycia do bazy badań."
	rnd_desc = "Operacja, która dogłębnie bada biologię zwłok i automatycznie dodaje nowe odkrycia do bazy danych badań."
	implements = list(
		TOOL_SCALPEL = 1.67,
		/obj/item/kitchen/knife = 3.33,
		/obj/item/shard = 6.67,
	)
	time = 12.5 SECONDS
	operation_flags = OPERATION_LOCKED | OPERATION_MORBID | OPERATION_NOTABLE
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED

/datum/surgery_operation/basic/dissection/get_default_radial_image()
	return get_item_radial_image(/obj/item/paper)

/datum/surgery_operation/basic/dissection/all_required_strings()
	return ..() + list("pacjent musi być martwy", "pacjent nie mógł już przejść sekcji", "nie może jej zrobić cyborg")

/datum/surgery_operation/basic/dissection/state_check(mob/living/patient)
	return iscarbon(patient) && patient.stat == DEAD && !HAS_TRAIT(patient, TRAIT_DISSECTED)

/datum/surgery_operation/basic/dissection/snowflake_check_availability(mob/living/patient, mob/living/surgeon, tool, operated_zone)
	// roboty nie są kreatywne (a sekcja nie powinna zawsze się udawać)
	return !iscyborg(surgeon)

/datum/surgery_operation/basic/dissection/on_preop(mob/living/patient, mob/living/surgeon, tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_notice("Zaczynasz przeprowadzać sekcję [patient]."),
		span_notice("[surgeon] zaczyna przeprowadzać sekcję [patient]."),
		span_notice("[surgeon] zaczyna przeprowadzać sekcję [patient]."),
	)

/datum/surgery_operation/basic/dissection/on_success(mob/living/patient, mob/living/surgeon, tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_notice("Przeprowadzasz sekcję [patient] i dodajesz swoje odkrycia do bazy danych badań!"),
		span_notice("[surgeon] przeprowadza sekcję [patient]!"),
		span_notice("[surgeon] przeprowadza sekcję [patient]!"),
	)
	finish_dissection(patient, check_value(patient))

/datum/surgery_operation/basic/dissection/on_failure(mob/living/patient, mob/living/surgeon, tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_warning("Przeprowadzasz sekcję [patient], ale nie znajdujesz niczego szczególnie interesującego."),
		span_notice("[surgeon] przeprowadza sekcję [patient]!"),
		span_notice("[surgeon] przeprowadza sekcję [patient]!"),
	)
	finish_dissection(patient, check_value(patient) * 0.2)

/// Punkty do bazy badań, obrażenia i znacznik, że ciało już było krojone
/datum/surgery_operation/basic/dissection/proc/finish_dissection(mob/living/patient, points)
	if(points)
		SSresearch.science_tech.add_point_list(list(TECHWEB_POINT_TYPE_DISCOVERY = points))
	patient.apply_damage(80, BRUTE, BODY_ZONE_CHEST)
	ADD_TRAIT(patient, TRAIT_DISSECTED, "surgery")

/// Ile punktów odkryć jest warta sekcja (tabela ze starej wersji)
/datum/surgery_operation/basic/dissection/proc/check_value(mob/living/target)
	if(isalienroyal(target))
		return 10000
	if(isalienadult(target))
		return 5000
	if(ismonkey(target))
		return 1000
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		if(human_target.dna?.species)
			if(isabductor(human_target))
				return 8000
			if(isgolem(human_target) || iszombie(human_target))
				return 4000
			if(isjellyperson(human_target) || ispodperson(human_target))
				return 3000
			return 2000
	return 0
