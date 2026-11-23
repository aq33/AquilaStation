// AQUILA - krtań i syntezator mowy (AquilaMed 5, etap 6). Sprite syntezatora: voicebox z Paradise
// (icons/obj/surgery.dmi, CC BY-SA 3.0), krtań narysowana u nas.
// - Rasy z krwią mają krtań, syntetyki (IPC) syntezator mowy w tym samym slocie. Bez niej albo przy zniszczonej nie da
//   się mówić; uszkodzona daje chrypkę (nie da się krzyczeć), ciężko uszkodzona pozwala tylko szeptać.
// - Krtań trzyma głos: wyjęta z ciała zapamiętuje głos właściciela, więc ktoś z przeszczepioną krtanią mówi cudzym
//   głosem (jak zmieniacz głosu w masce). Operacja zmiany głosu ustawia dowolny głos albo przywraca własny.
// - Uszkadza ją mocny cios w głowę, syntezator też impuls EMP. Naprawia operacja strun głosowych (u syntezatora
//   kalibracja śrubokrętem).

/// Share of max health at which the voice is only a whisper
#define AQ_LARYNX_WHISPER_DAMAGE 0.6
/// Brute to the head at or above this can hurt the larynx
#define AQ_LARYNX_HIT_DAMAGE 15

/obj/item/organ/larynx
	name = "krtań"
	desc = "Chrząstki i struny głosowe. Bez nich nie da się mówić."
	icon = 'aquila/icons/obj/medical/organs_med5.dmi'
	icon_state = "larynx"
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_LARYNX
	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY
	low_threshold = STANDARD_ORGAN_THRESHOLD * 0.25
	low_threshold_passed = "<span class='info'>Drapie cię w gardle, głos ci się łamie.</span>"
	high_threshold_passed = "<span class='warning'>Gardło pali przy każdym słowie, ledwo wydobywasz głos.</span>"
	now_failing = "<span class='userdanger'>Nie możesz wydobyć z siebie głosu!</span>"
	now_fixed = "<span class='notice'>Głos wraca.</span>"
	/// The voice others hear, null = the owner's own
	var/voice

/obj/item/organ/larynx/synthesizer
	name = "syntezator mowy"
	desc = "Głośnik z modułem mowy syntetyka. Bez niego syntetyk milczy."
	icon_state = "synthesizer"
	organ_flags = ORGAN_SYNTHETIC
	status = ORGAN_ROBOTIC
	low_threshold_passed = "<span class='info'>Syntezator mowy trzeszczy.</span>"
	high_threshold_passed = "<span class='warning'>Syntezator mowy ledwo działa, głos się rwie.</span>"
	now_failing = "<span class='userdanger'>Syntezator mowy przestał działać!</span>"
	now_fixed = "<span class='notice'>Syntezator mowy znów działa.</span>"

/obj/item/organ/larynx/synthesizer/emp_act(severity)
	. = ..()
	if(!(. & EMP_PROTECT_SELF))
		applyOrganDamage(30 / severity)

/obj/item/organ/larynx/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	RegisterSignal(M, COMSIG_MOB_APPLY_DAMGE, PROC_REF(on_owner_damaged), override = TRUE)
	RegisterSignal(M, COMSIG_LIVING_AQ_PRE_SAY, PROC_REF(on_owner_pre_say), override = TRUE)
	RegisterSignal(M, COMSIG_MOB_SAY, PROC_REF(on_owner_say), override = TRUE)

// The voice is taken only when the larynx leaves a body: a fresh one from spawn speaks with whatever name the
// character gets later from the preferences.
/obj/item/organ/larynx/Remove(mob/living/carbon/M, special = 0)
	UnregisterSignal(M, list(COMSIG_MOB_APPLY_DAMGE, COMSIG_LIVING_AQ_PRE_SAY, COMSIG_MOB_SAY))
	if(!voice && M?.real_name)
		voice = M.real_name
	return ..()

/obj/item/organ/larynx/proc/on_owner_damaged(datum/source, damage, damagetype, def_zone)
	SIGNAL_HANDLER
	if(damagetype != BRUTE || !owner || (organ_flags & ORGAN_SYNTHETIC) || check_zone(aq_damage_zone(def_zone)) != BODY_ZONE_HEAD)
		return
	var/hit = owner.aq_damage_after_armor(damage, def_zone) // hełm chroni krtań
	if(hit >= AQ_LARYNX_HIT_DAMAGE && prob(6))
		applyOrganDamage(hit)

/// Badly hurt: only a whisper
/obj/item/organ/larynx/proc/on_owner_pre_say(datum/source, original_message, message, list/message_mods, datum/language/language, bubble_type, list/spans, forced)
	SIGNAL_HANDLER
	if(!forced && damage >= maxHealth * AQ_LARYNX_WHISPER_DAMAGE)
		message_mods[WHISPER_MODE] = MODE_WHISPER

/// Hoarse: no shouting
/obj/item/organ/larynx/proc/on_owner_say(datum/source, list/speech_args)
	SIGNAL_HANDLER
	if(damage <= low_threshold)
		return
	var/message = speech_args[SPEECH_MESSAGE]
	if(message && message[1] != "*")
		speech_args[SPEECH_MESSAGE] = replacetext(message, "!", ".")

/obj/item/organ/larynx/aq_scan_line()
	if(organ_flags & ORGAN_FAILING)
		return "<b>[capitalize(name)] zniszczona:</b> pacjent nie może mówić."
	if(damage >= maxHealth * AQ_LARYNX_WHISPER_DAMAGE)
		return "<b>[capitalize(name)] ciężko uszkodzona:</b> pacjent tylko szepcze."

/// Species need the larynx (or the synthesizer) to speak
/datum/species/proc/aq_larynx_type()
	if(aq_has_med5_organs())
		return /obj/item/organ/larynx
	if(MOB_ROBOTIC in inherent_biotypes)
		return /obj/item/organ/larynx/synthesizer
	return null

/mob/living/carbon/human/IsVocal()
	. = ..()
	if(!. || !dna?.species?.aq_larynx_type())
		return
	var/obj/item/organ/larynx/larynx = getorganslot(ORGAN_SLOT_LARYNX)
	if(!larynx || (larynx.organ_flags & ORGAN_FAILING))
		return FALSE

/// A transplanted or retuned larynx speaks with its own voice
/mob/living/carbon/human/GetVoice()
	. = ..()
	if(. != real_name)
		return
	var/obj/item/organ/larynx/larynx = getorganslot(ORGAN_SLOT_LARYNX)
	if(larynx?.voice)
		return larynx.voice

// --- Operacje ---

/datum/surgery_operation/organ/repair/larynx
	name = "zszycie strun głosowych"
	rnd_name = "Laryngoplastyka (operacja krtani)"
	desc = "Naprawia uszkodzoną albo zniszczoną krtań i przywraca głos."
	implements = list(TOOL_HEMOSTAT = 1, /obj/item/stack/medical/suture = 1.2, TOOL_WIRECUTTER = 2.85)
	time = 5 SECONDS
	target_type = /obj/item/organ/larynx
	heal_to_percent = 0
	required_damage_percent = 0.1
	repeatable = TRUE
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED
	preop_sound = 'sound/surgery/hemostat1.ogg'
	success_sound = 'sound/surgery/organ1.ogg'

/datum/surgery_operation/organ/repair/larynx/on_success(obj/item/organ/larynx/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	display_results(surgeon, organ.owner, span_notice("Zszywasz struny głosowe [FORMAT_ORGAN_OWNER(organ)]."), span_notice("[surgeon] zszywa struny głosowe [FORMAT_ORGAN_OWNER(organ)]."), span_notice("[surgeon] kończy operację gardła [FORMAT_ORGAN_OWNER(organ)]."))

/datum/surgery_operation/organ/repair/larynx/mechanic
	name = "kalibracja syntezatora mowy"
	rnd_name = "Kalibracja syntezatora mowy"
	desc = "Naprawia uszkodzony syntezator mowy syntetyka."
	implements = list(TOOL_SCREWDRIVER = 1, TOOL_MULTITOOL = 1.2, /obj/item/kitchen/knife = 2.85)
	preop_sound = 'sound/items/screwdriver.ogg'
	success_sound = 'sound/machines/doorclick.ogg'
	required_organ_flag = ORGAN_ROBOTIC
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE | OPERATION_NO_PATIENT_REQUIRED | OPERATION_MECHANIC

/datum/surgery_operation/organ/repair/larynx/mechanic/on_success(obj/item/organ/larynx/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	organ.setOrganDamage(0)
	display_results(surgeon, organ.owner, span_notice("Kalibrujesz syntezator mowy [FORMAT_ORGAN_OWNER(organ)]."), span_notice("[surgeon] kalibruje syntezator mowy [FORMAT_ORGAN_OWNER(organ)]."), span_notice("[surgeon] kończy operację [FORMAT_ORGAN_OWNER(organ)]."))

#define OPERATION_NEW_VOICE "new_voice"

/datum/surgery_operation/organ/larynx_voice
	name = "zmiana głosu"
	rnd_name = "Przestrojenie strun głosowych"
	desc = "Przestraja krtań albo syntezator mowy tak, że pacjent mówi wybranym głosem. Wpisanie własnego imienia przywraca jego głos."
	implements = list(TOOL_HEMOSTAT = 1.15, TOOL_SCREWDRIVER = 1.15, TOOL_WIRECUTTER = 2)
	time = 8 SECONDS
	target_type = /obj/item/organ/larynx
	required_organ_flag = NONE
	operation_flags = OPERATION_NOTABLE
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED
	preop_sound = 'sound/surgery/hemostat1.ogg'
	success_sound = 'sound/surgery/organ1.ogg'

/datum/surgery_operation/organ/larynx_voice/state_check(obj/item/organ/larynx/organ)
	return ishuman(organ.owner) && !(organ.organ_flags & ORGAN_FAILING)

/datum/surgery_operation/organ/larynx_voice/pre_preop(obj/item/organ/larynx/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	operation_args[OPERATION_NEW_VOICE] = reject_bad_name(stripped_input(surgeon, "Jakim głosem ma mówić pacjent? Wpisz imię i nazwisko.", "Zmiana głosu", organ.voice || organ.owner?.real_name, MAX_NAME_LEN))
	return !!operation_args[OPERATION_NEW_VOICE]

/datum/surgery_operation/organ/larynx_voice/on_preop(obj/item/organ/larynx/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(surgeon, organ.owner, span_notice("Zaczynasz przestrajać struny głosowe [FORMAT_ORGAN_OWNER(organ)]..."), span_notice("[surgeon] zaczyna operację gardła [FORMAT_ORGAN_OWNER(organ)]."), span_notice("[surgeon] zaczyna operację gardła [FORMAT_ORGAN_OWNER(organ)]."))
	display_pain(organ.owner, "Gardło ściska ci ostry ból!")

/datum/surgery_operation/organ/larynx_voice/on_success(obj/item/organ/larynx/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/new_voice = operation_args[OPERATION_NEW_VOICE]
	organ.voice = (new_voice == organ.owner?.real_name) ? null : new_voice
	display_results(surgeon, organ.owner, span_notice("Przestrajasz struny głosowe [FORMAT_ORGAN_OWNER(organ)]. Teraz brzmi jak [new_voice]."), span_notice("[surgeon] kończy operację gardła [FORMAT_ORGAN_OWNER(organ)]."), span_notice("[surgeon] kończy operację gardła [FORMAT_ORGAN_OWNER(organ)]."))
	if(organ.owner)
		log_game("[key_name(surgeon)] changed the voice of [key_name(organ.owner)] to '[new_voice]'.")

/datum/surgery_operation/organ/larynx_voice/on_failure(obj/item/organ/larynx/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	organ.applyOrganDamage(20)
	display_results(surgeon, organ.owner, span_warning("Partaczysz i rozrywasz struny głosowe [FORMAT_ORGAN_OWNER(organ)]!"), span_warning("[surgeon] partaczy!"), span_warning("[surgeon] partaczy!"))

#undef OPERATION_NEW_VOICE
#undef AQ_LARYNX_WHISPER_DAMAGE
#undef AQ_LARYNX_HIT_DAMAGE

/datum/design/aq_synthesizer
	name = "Syntezator mowy"
	desc = "Zapasowy syntezator mowy dla syntetyków."
	id = "aq_synthesizer"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 300, /datum/material/glass = 300)
	build_path = /obj/item/organ/larynx/synthesizer
	category = list("Cybernetics", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE
