// AQUILA - tg code/modules/surgery/operations/operation_pacify.dm
// Pacyfikacja (stara wersja: code/modules/surgery/advanced/pacification.dm). Zaawansowana operacja: OPERATION_LOCKED,
// odblokowują ją dyski i projekty /datum/design/surgery (surgery_unlocks.dm). Zostaje nasze zachowanie: trwały pacyfizm (odporność LOBOTOMY),
// porażka daje ciężką traumę. Jak stara wersja działa na każdym mózgu, więc bez osobnej wersji mechanicznej z tg.

/datum/surgery_operation/organ/pacify
	name = "pacyfikacja"
	rnd_name = "Paksopsja (pacyfikacja)"
	desc = "Usuwa z mózgu pacjenta skłonności do agresji."
	rnd_desc = "Operacja, która na stałe tłumi ośrodek agresji w mózgu, przez co pacjent nie chce nikogo bezpośrednio krzywdzić."
	operation_flags = OPERATION_MORBID | OPERATION_LOCKED | OPERATION_NOTABLE | OPERATION_NO_PATIENT_REQUIRED
	implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_SCREWDRIVER = 2.85,
		/obj/item/pen = 6.67,
	)
	time = 4 SECONDS
	preop_sound = 'sound/surgery/hemostat1.ogg'
	success_sound = 'sound/surgery/hemostat1.ogg'
	failure_sound = 'sound/surgery/organ2.ogg'
	required_organ_flag = NONE
	target_type = /obj/item/organ/brain
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_BONE_SAWED
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED

/datum/surgery_operation/organ/pacify/on_preop(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Zaczynasz pacyfikować [FORMAT_ORGAN_OWNER(organ)]..."),
		span_notice("[surgeon] zaczyna naprawiać mózg [FORMAT_ORGAN_OWNER(organ)]."),
		span_notice("[surgeon] zaczyna operację mózgu [FORMAT_ORGAN_OWNER(organ)]."),
	)
	display_pain(organ.owner, "Głowa pęka ci z niewyobrażalnego bólu!")

/datum/surgery_operation/organ/pacify/on_success(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Udaje ci się neurologicznie spacyfikować [FORMAT_ORGAN_OWNER(organ)]."),
		span_notice("[surgeon] naprawia mózg [FORMAT_ORGAN_OWNER(organ)]!"),
		span_notice("[surgeon] kończy operację mózgu [FORMAT_ORGAN_OWNER(organ)]."),
	)
	display_pain(organ.owner, "Głowa pulsuje... sama myśl o przemocy przyprawia cię o mdłości!")
	organ.gain_trauma(/datum/brain_trauma/severe/pacifism, TRAUMA_RESILIENCE_LOBOTOMY)

/datum/surgery_operation/organ/pacify/on_failure(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Partaczysz, przeprogramowując mózg [FORMAT_ORGAN_OWNER(organ)] na odwrót..."),
		span_warning("[surgeon] partaczy, uszkadzając mózg!"),
		span_notice("[surgeon] kończy operację mózgu [FORMAT_ORGAN_OWNER(organ)]."),
	)
	display_pain(organ.owner, "Głowa pulsuje i jest coraz gorzej!")
	organ.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)
