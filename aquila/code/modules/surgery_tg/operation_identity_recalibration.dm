// AQUILA - nowa wersja rekalibracji tożsamości (stara: aquila/code/modules/surgery/identity_recalibration.dm, port BeeStation #12856).
// W tg jej nie ma. Robotyczna klatka piersiowa człowieka (IPC) z otwartą obudową i przygotowaną elektroniką: przeciągnięcie
// karty ID zmienia imię na to z karty (fully_replace_character_name), karta bez nazwiska daje "????". Można ją zrobić na sobie.

/datum/surgery_operation/limb/identity_recalibration
	name = "rekalibracja tożsamości"
	rnd_name = "Rekalibracja tożsamości (zmiana imienia)"
	desc = "Wgrywa do pamięci robotycznego pacjenta nazwisko z przeciągniętej karty ID."
	implements = list(
		/obj/item/card/id = 1,
	)
	time = 1 SECONDS
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_MECHANIC | OPERATION_NOTABLE
	required_bodytype = BODYTYPE_ROBOTIC
	preop_sound = 'sound/machines/terminal_select.ogg'
	success_sound = 'sound/machines/terminal_processing.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT

/datum/surgery_operation/limb/identity_recalibration/get_default_radial_image()
	return get_item_radial_image(/obj/item/card/id)

/datum/surgery_operation/limb/identity_recalibration/all_required_strings()
	return list("operacja na: [strefa_pl(BODY_ZONE_CHEST)]", "pacjent musi być człowiekiem") + ..()

/datum/surgery_operation/limb/identity_recalibration/state_check(obj/item/bodypart/limb)
	return limb.body_zone == BODY_ZONE_CHEST && ishuman(limb.owner)

/datum/surgery_operation/limb/identity_recalibration/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz przeciągać [tool] przez czytnik w obudowie [limb.owner]..."),
		span_notice("[surgeon] zaczyna przeciągać [tool] przez czytnik w obudowie [limb.owner]."),
		span_notice("[surgeon] zaczyna coś robić przy elektronice [limb.owner]."),
	)

/datum/surgery_operation/limb/identity_recalibration/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/card/id/tool, list/operation_args)
	var/mob/living/carbon/human/patient = limb.owner
	var/old_name = patient.real_name
	if(tool.registered_name)
		patient.fully_replace_character_name(old_name, tool.registered_name)
		display_results(
			surgeon,
			patient,
			span_notice("Rekalibrujesz tożsamość [old_name]!"),
			span_notice("[surgeon] rekalibruje tożsamość [old_name] za pomocą [tool]!"),
			span_notice("[surgeon] rekalibruje tożsamość [old_name]!"),
		)
		log_combat(surgeon, patient, "renamed", addition = "changed [old_name]'s name to [tool.registered_name]")
		return
	patient.fully_replace_character_name(old_name, "????")
	to_chat(surgeon, span_warning("Na karcie nie ma zapisanego nazwiska, co powoduje błąd!"))
	log_combat(surgeon, patient, "renamed", addition = "changed [old_name] to ????")
