// AQUILA - tg code/modules/surgery/operations/operation_lobotomy.dm
// Lobotomia (stara wersja: code/modules/surgery/advanced/lobotomy.dm). Zaawansowana operacja: OPERATION_LOCKED,
// odblokowuje ją to samo co starą (legacy_unlocked_by). Zostają nasze efekty: leczy traumy do odporności LOBOTOMY,
// zdejmuje pranie mózgu, w 3 przypadkach na 4 zostawia losową trwałą traumę; porażka: 80 uszkodzeń mózgu i trauma.
// Jak stara wersja działa na każdym mózgu (organicznym i pozytronowym), więc bez osobnej wersji mechanicznej z tg.

/datum/surgery_operation/organ/lobotomy
	name = "lobotomia"
	rnd_name = "Lobotomia"
	desc = "Usuwa większość urazów mózgu pacjenta, ale może wywołać nowy, trwały uraz."
	rnd_desc = "Inwazyjna operacja, która usuwa prawie wszystkie urazy mózgu, ale w zamian może spowodować inny, trwały uraz."
	operation_flags = OPERATION_MORBID | OPERATION_AFFECTS_MOOD | OPERATION_LOCKED | OPERATION_NOTABLE | OPERATION_NO_PATIENT_REQUIRED
	legacy_unlocked_by = list(/datum/surgery/advanced/lobotomy)
	implements = list(
		TOOL_SCALPEL = 1.15,
		/obj/item/melee/transforming/energy/sword = 1.85,
		/obj/item/kitchen/knife = 2.85,
		/obj/item/shard = 4,
		/obj/item = 5,
	)
	time = 10 SECONDS
	target_type = /obj/item/organ/brain
	required_organ_flag = NONE
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/scalpel2.ogg'
	failure_sound = 'sound/surgery/organ2.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_BONE_SAWED
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED

/datum/surgery_operation/organ/lobotomy/get_any_tool()
	return "Dowolny ostry przedmiot"

/datum/surgery_operation/organ/lobotomy/tool_check(obj/item/tool)
	return is_specific_implement(tool, implements) || tool.is_sharp()

/datum/surgery_operation/organ/lobotomy/on_preop(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Zaczynasz przeprowadzać lobotomię mózgu [FORMAT_ORGAN_OWNER(organ)]..."),
		span_notice("[surgeon] zaczyna przeprowadzać lobotomię mózgu [FORMAT_ORGAN_OWNER(organ)]."),
		span_notice("[surgeon] zaczyna operację mózgu [FORMAT_ORGAN_OWNER(organ)]."),
	)
	display_pain(organ.owner, "Głowa pęka ci z niewyobrażalnego bólu!")

/datum/surgery_operation/organ/lobotomy/on_success(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Udaje ci się przeprowadzić lobotomię [FORMAT_ORGAN_OWNER(organ)]."),
		span_notice("[surgeon] pomyślnie przeprowadza lobotomię [FORMAT_ORGAN_OWNER(organ)]!"),
		span_notice("[surgeon] kończy operację mózgu [FORMAT_ORGAN_OWNER(organ)]."),
	)
	display_pain(organ.owner, "Głowa na chwilę zupełnie drętwieje, ból jest przytłaczający!")

	organ.cure_all_traumas(TRAUMA_RESILIENCE_LOBOTOMY)
	if(organ.owner)
		organ.owner.mind?.remove_antag_datum(/datum/antagonist/brainwashed)
	else if(organ.brainmob)
		organ.brainmob.mind?.remove_antag_datum(/datum/antagonist/brainwashed)

	// teraz zobaczmy, jaką mam nadzieję nieważną część mózgu odcięliśmy
	var/roll = rand(0, 3)
	if(roll)
		random_lobotomy_trauma(organ, roll)

/datum/surgery_operation/organ/lobotomy/on_failure(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_warning("Usuwasz nie tę część, powodując dodatkowe obrażenia!"),
		span_notice("[surgeon] bezskutecznie próbuje przeprowadzić lobotomię [FORMAT_ORGAN_OWNER(organ)]!"),
		span_notice("[surgeon] kończy operację mózgu [FORMAT_ORGAN_OWNER(organ)]."),
	)
	display_pain(organ.owner, "Ból głowy tylko się nasila!")
	organ.applyOrganDamage(80)
	random_lobotomy_trauma(organ, rand(1, 3))

/// Trwała trauma po lobotomii: 1 lekka, 2 ciężka (albo specjalna przy pofałdowanej korze), 3 specjalna
/datum/surgery_operation/organ/lobotomy/proc/random_lobotomy_trauma(obj/item/organ/brain/organ, roll)
	var/mob/living/brain_holder = organ.owner || organ.brainmob
	switch(roll)
		if(1)
			organ.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_MAGIC)
		if(2)
			if(brain_holder && HAS_TRAIT(brain_holder, TRAIT_SPECIAL_TRAUMA_BOOST) && prob(50))
				organ.gain_trauma_type(BRAIN_TRAUMA_SPECIAL, TRAUMA_RESILIENCE_MAGIC)
			else
				organ.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_MAGIC)
		if(3)
			organ.gain_trauma_type(BRAIN_TRAUMA_SPECIAL, TRAUMA_RESILIENCE_MAGIC)

/**
 * AQUILA - narzędzie pasuje do konkretnego wpisu z implements (zachowanie TOOL_X albo typ inny niż /obj/item).
 * Dla operacji, w których "dowolny przedmiot" musi spełnić dodatkowy warunek (ostrość, temperatura).
 */
/datum/surgery_operation/proc/is_specific_implement(obj/item/tool, list/implement_list)
	if(tool.tool_behaviour && implement_list[tool.tool_behaviour])
		return TRUE
	for(var/implement in implement_list)
		if(implement == /obj/item || !ispath(implement))
			continue
		if(istype(tool, implement))
			return TRUE
	return FALSE
