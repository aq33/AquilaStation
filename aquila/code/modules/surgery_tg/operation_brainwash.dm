// AQUILA - tg code/modules/surgery/operations/operation_brainwash.dm
// Pranie mózgu (stara wersja: code/modules/surgery/advanced/brainwashing.dm). Zaawansowana operacja z dysku:
// OPERATION_LOCKED, odblokowują ją dyski i projekty /datum/design/surgery (surgery_unlocks.dm). Zostaje nasze zachowanie: tylko ludzie
// z organicznym mózgiem, implant lojalności kasuje pranie, porażka to 40 uszkodzeń mózgu, cel wpisuje się przed
// operacją. Pominięte z tg: wersja mechaniczna, wersja "uśpiony agent" (u nas nie ma jej źródła), TRAIT_UNCONVERTABLE.
// Jak w starej wersji wystarczy przepiłowana czaszka i zaciśnięte naczynia, bez nacinania organów.

#define OPERATION_OBJECTIVE "objective"

/datum/surgery_operation/organ/brainwash
	name = "pranie mózgu"
	rnd_name = "Neuronalne pranie mózgu"
	desc = "Wszczepia w mózg pacjenta rozkaz, który staje się jego absolutnym priorytetem."
	rnd_desc = "Operacja, która wszczepia rozkaz bezpośrednio w mózg pacjenta i czyni go jego absolutnym priorytetem. \
		Usuwa go implant lojalności."
	implements = list(
		TOOL_HEMOSTAT = 1.15,
		TOOL_WIRECUTTER = 2,
		/obj/item/stack/package_wrap = 2.85,
		/obj/item/stack/cable_coil = 6.67,
	)
	time = 20 SECONDS
	preop_sound = 'sound/surgery/hemostat1.ogg'
	success_sound = 'sound/surgery/hemostat1.ogg'
	failure_sound = 'sound/surgery/organ2.ogg'
	operation_flags = OPERATION_MORBID | OPERATION_NOTABLE | OPERATION_LOCKED
	target_type = /obj/item/organ/brain
	required_organ_flag = ORGAN_ORGANIC
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_BONE_SAWED
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED

/datum/surgery_operation/organ/brainwash/all_required_strings()
	return ..() + list("pacjent musi być człowiekiem")

/datum/surgery_operation/organ/brainwash/state_check(obj/item/organ/brain/organ)
	return ishuman(organ.owner)

/datum/surgery_operation/organ/brainwash/pre_preop(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	operation_args[OPERATION_OBJECTIVE] = stripped_input(surgeon, "Wybierz cel, który chcesz wdrukować w mózg ofiary.", "Pranie mózgu", null, MAX_MESSAGE_LEN)
	return !!operation_args[OPERATION_OBJECTIVE]

/datum/surgery_operation/organ/brainwash/on_preop(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Zaczynasz prać mózg [organ.owner]..."),
		span_notice("[surgeon] zaczyna naprawiać mózg [organ.owner]."),
		span_notice("[surgeon] zaczyna operację mózgu [organ.owner]."),
	)
	display_pain(organ.owner, "Głowa pęka ci z niewyobrażalnego bólu!")

/datum/surgery_operation/organ/brainwash/on_success(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/mob/living/carbon/patient = organ.owner
	if(!patient.mind)
		to_chat(surgeon, span_warning("[patient] nie reaguje na pranie mózgu, jakby nie miał umysłu..."))
		return
	if(HAS_TRAIT(patient, TRAIT_MINDSHIELD))
		to_chat(surgeon, span_warning("Słyszysz ciche brzęczenie urządzenia w mózgu [patient], a pranie mózgu zostaje wymazane."))
		return
	display_results(
		surgeon,
		patient,
		span_notice("Udaje ci się wyprać mózg [patient]."),
		span_notice("[surgeon] naprawia mózg [patient]!"),
		span_notice("[surgeon] kończy operację mózgu [patient]."),
	)
	var/objective = operation_args[OPERATION_OBJECTIVE]
	to_chat(patient, span_userdanger("Twój umysł wypełnia nowy przymus... czujesz, że musisz go słuchać!"))
	brainwash(patient, objective)
	message_admins("[ADMIN_LOOKUPFLW(surgeon)] surgically brainwashed [ADMIN_LOOKUPFLW(patient)] with the objective '[objective]'.")
	log_game("[key_name(surgeon)] surgically brainwashed [key_name(patient)] with the objective '[objective]'.")

/datum/surgery_operation/organ/brainwash/on_failure(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_warning("Partaczysz, obijając tkankę mózgową!"),
		span_warning("[surgeon] partaczy, uszkadzając mózg!"),
		span_notice("[surgeon] kończy operację mózgu [organ.owner]."),
	)
	display_pain(organ.owner, "Głowa pulsuje straszliwym bólem!")
	organ.applyOrganDamage(40)

#undef OPERATION_OBJECTIVE
