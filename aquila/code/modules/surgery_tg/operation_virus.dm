// AQUILA - tg code/modules/surgery/operations/operation_virus.dm
// Wiązanie wirusowe (stara wersja: code/modules/surgery/advanced/viral_bonding.dm). Zaawansowana operacja:
// OPERATION_LOCKED, odblokowuje ją to samo co starą (legacy_unlocked_by). Zostaje nasze zachowanie: można ją zrobić
// na sobie, nosicielem staje się pacjent każdej choroby (także nieuleczalnej). Jak w tg operacja pokazuje się dopiero,
// gdy pacjent ma wszystkie trzy odczynniki (stara wersja w takim przypadku po prostu się nie udawała).

/datum/surgery_operation/basic/viral_bonding
	name = "wiązanie wirusowe"
	rnd_name = "Wiroplastyka (wiązanie wirusowe)"
	desc = "Wymusza symbiozę między pacjentem a wirusem, którym jest zarażony."
	rnd_desc = "Operacja, która wymusza symbiozę wirusa z nosicielem. Choroba przestaje szkodzić pacjentowi, \
		ale ten dalej ją nosi i zaraża innych. Pacjent musi dostać spacylinę, pożywkę dla wirusów i formaldehyd."
	implements = list(
		TOOL_CAUTERY = 1,
		TOOL_WELDER = 2,
		/obj/item = 3.33,
	)
	time = 10 SECONDS
	preop_sound = 'sound/surgery/cautery1.ogg'
	success_sound = 'sound/surgery/cautery2.ogg'
	operation_flags = OPERATION_MORBID | OPERATION_LOCKED | OPERATION_NOTABLE | OPERATION_SELF_OPERABLE
	legacy_unlocked_by = list(/datum/surgery/advanced/viral_bonding)
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED
	/// Potrzebne wszystkie
	var/list/required_chems = list(
		/datum/reagent/medicine/spaceacillin,
		/datum/reagent/consumable/virus_food,
		/datum/reagent/toxin/formaldehyde,
	)

/datum/surgery_operation/basic/viral_bonding/get_any_tool()
	return "Dowolne źródło ciepła"

/datum/surgery_operation/basic/viral_bonding/all_required_strings()
	. = ..()
	. += "pacjent musi mieć wirusa do związania"
	for(var/datum/reagent/chem as anything in required_chems)
		. += "pacjent musi mieć w sobie [initial(chem.name)]"

/datum/surgery_operation/basic/viral_bonding/get_default_radial_image()
	return get_item_radial_image(/obj/item/clothing/mask/surgical)

/datum/surgery_operation/basic/viral_bonding/state_check(mob/living/patient)
	if(!iscarbon(patient) || !LAZYLEN(patient.diseases))
		return FALSE
	for(var/chem in required_chems)
		if(!patient.reagents?.has_reagent(chem))
			return FALSE
	return TRUE

/datum/surgery_operation/basic/viral_bonding/tool_check(obj/item/tool)
	if(tool.tool_behaviour == TOOL_CAUTERY)
		return TRUE
	return tool.is_hot()

/datum/surgery_operation/basic/viral_bonding/on_preop(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_notice("Zaczynasz podgrzewać szpik kostny [patient] za pomocą [tool]..."),
		span_notice("[surgeon] zaczyna podgrzewać szpik kostny [patient] za pomocą [tool]..."),
		span_notice("[surgeon] zaczyna podgrzewać coś w klatce piersiowej [patient] za pomocą [tool]..."),
	)
	display_pain(patient, "Czujesz piekące gorąco rozchodzące się po klatce piersiowej!")

/datum/surgery_operation/basic/viral_bonding/on_success(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_notice("Szpik kostny [patient] zaczyna powoli pulsować. Wiązanie wirusowe zakończone."),
		span_notice("Szpik kostny [patient] zaczyna powoli pulsować."),
		span_notice("[surgeon] kończy operację."),
	)
	display_pain(patient, "Czujesz słabe pulsowanie w klatce piersiowej.")
	for(var/datum/disease/infected_disease as anything in patient.diseases)
		infected_disease.carrier = TRUE
