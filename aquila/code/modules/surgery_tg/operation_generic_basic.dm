// AQUILA - tg code/modules/surgery/operations/operation_generic_basic.dm
// Odpowiedniki podstawowych operacji dla mobów bez kończyn (zwierzęta, szlamy). Stan trzyma /datum/status_effect/basic_surgery_state.

/// Nacięcie skóry moba bez kończyn
/datum/surgery_operation/basic/incise_skin
	name = "nacięcie"
	desc = "Nacina skórę pacjenta, żeby dostać się do środka. \
		Stan: \"skóra odciągnięta\"."
	implements = list(
		TOOL_SCALPEL = 1,
		/obj/item/melee/transforming/energy/sword = 1.33,
		/obj/item/kitchen/knife = 1.5,
		/obj/item/shard = 2.25,
		/obj/item/screwdriver = 5,
		/obj/item/pen = 5,
		/obj/item = 3.33,
	)
	time = 1.6 SECONDS
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/scalpel2.ogg'
	operation_flags = OPERATION_AFFECTS_MOOD
	any_surgery_states_blocked = ALL_SURGERY_SKIN_STATES
	target_zone = null

/datum/surgery_operation/basic/incise_skin/get_any_tool()
	return "Dowolny ostry przedmiot"

/datum/surgery_operation/basic/incise_skin/all_blocked_strings()
	return ..() + list("pacjent nie może mieć złożonej budowy (kończyn)")

/datum/surgery_operation/basic/incise_skin/get_default_radial_image()
	return image(icon = 'icons/obj/surgery.dmi', icon_state = "scalpel")

/datum/surgery_operation/basic/incise_skin/state_check(mob/living/patient)
	return !patient.has_limbs // tylko moby bez kończyn

/datum/surgery_operation/basic/incise_skin/tool_check(obj/item/tool)
	// ostrze albo pasujące narzędzie
	if(tool.sharpness || implements[tool.tool_behaviour])
		return TRUE
	// na życzenie graczy, choć nie są ostre
	if(istype(tool, /obj/item/pen) || istype(tool, /obj/item/screwdriver))
		return TRUE
	return FALSE

/datum/surgery_operation/basic/incise_skin/on_preop(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_notice("Zaczynasz nacinać [patient]..."),
		span_notice("[surgeon] zaczyna nacinać [patient]."),
		span_notice("[surgeon] zaczyna nacinać [patient]."),
	)
	display_pain(patient, "Czujesz ostre dźgnięcie!")

/datum/surgery_operation/basic/incise_skin/on_success(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	patient.apply_status_effect(/datum/status_effect/basic_surgery_state, SURGERY_SKIN_OPEN)

/// Przepiłowanie kości moba bez kończyn
/datum/surgery_operation/basic/saw_bone
	name = "przepiłowanie kości"
	desc = "Przepiłowuje kości pacjenta, żeby dostać się do organów. \
		Stan: \"kość przepiłowana\"."
	implements = list(
		TOOL_SAW = 1,
		/obj/item/melee/arm_blade = 1.33,
		/obj/item/fireaxe = 2,
		/obj/item/hatchet = 2.85,
		/obj/item/kitchen/knife/butcher = 2.85,
		/obj/item = 4,
	)
	time = 5.4 SECONDS
	preop_sound = list(
		/obj/item/circular_saw = 'sound/surgery/saw.ogg',
		/obj/item = 'sound/surgery/scalpel1.ogg',
	)
	success_sound = 'sound/surgery/organ2.ogg'
	operation_flags = OPERATION_AFFECTS_MOOD
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_BONE_SAWED|SURGERY_BONE_DRILLED
	target_zone = null

/datum/surgery_operation/basic/saw_bone/get_any_tool()
	return "Dowolny ostry przedmiot o sporej sile"

/datum/surgery_operation/basic/saw_bone/all_blocked_strings()
	return ..() + list("pacjent nie może mieć złożonej budowy (kończyn)")

/datum/surgery_operation/basic/saw_bone/get_default_radial_image()
	return image(icon = 'icons/obj/surgery.dmi', icon_state = "saw")

/datum/surgery_operation/basic/saw_bone/state_check(mob/living/patient)
	return !patient.has_limbs // tylko moby bez kończyn

/datum/surgery_operation/basic/saw_bone/tool_check(obj/item/tool)
	// ostrze o sporej sile albo pasujące narzędzie
	return ((tool.sharpness && tool.force >= 10) || implements[tool.tool_behaviour])

/datum/surgery_operation/basic/saw_bone/on_preop(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_notice("Zaczynasz przepiłowywać kości [patient]..."),
		span_notice("[surgeon] zaczyna przepiłowywać kości [patient]."),
		span_notice("[surgeon] zaczyna przepiłowywać kości [patient]."),
	)
	display_pain(patient, "Okropny ból rozlewa się w środku!")

/datum/surgery_operation/basic/saw_bone/on_success(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	patient.apply_status_effect(/datum/status_effect/basic_surgery_state, SURGERY_BONE_SAWED)
	patient.apply_damage(patient.maxHealth * 0.5, BRUTE)
	display_results(
		surgeon,
		patient,
		span_notice("Otwierasz piłą [patient]."),
		span_notice("[surgeon] otwiera piłą [patient]!"),
		span_notice("[surgeon] otwiera piłą [patient]!"),
	)
	display_pain(patient, "Czujesz, jakby coś w środku pękło!")

/// Zamknięcie nacięcia moba bez kończyn
/datum/surgery_operation/basic/close_skin
	name = "zamknięcie nacięcia"
	desc = "Zamyka nacięcie skóry pacjenta. \
		Czyści większość stanów chirurgicznych."
	implements = list(
		TOOL_CAUTERY = 1,
		/obj/item/stack/medical/suture = 1,
		/obj/item/gun/energy/laser = 1.15,
		TOOL_WELDER = 1.5,
		/obj/item = 3.33,
	)
	time = 2.4 SECONDS
	preop_sound = list(
		/obj/item/stack/medical/suture = 'sound/surgery/hemostat1.ogg',
		/obj/item = 'sound/surgery/cautery1.ogg',
	)
	success_sound = list(
		/obj/item/stack/medical/suture = 'sound/surgery/hemostat1.ogg',
		/obj/item = 'sound/surgery/cautery2.ogg',
	)
	any_surgery_states_required = ALL_SURGERY_STATES_UNSET_ON_CLOSE // obojętnie co
	target_zone = null

/datum/surgery_operation/basic/close_skin/get_any_tool()
	return "Dowolne źródło ciepła"

/datum/surgery_operation/basic/close_skin/all_blocked_strings()
	return ..() + list("pacjent nie może mieć złożonej budowy (kończyn)")

/datum/surgery_operation/basic/close_skin/get_default_radial_image()
	return image(icon = 'icons/obj/surgery.dmi', icon_state = "cautery")

/datum/surgery_operation/basic/close_skin/state_check(mob/living/patient)
	return !patient.has_limbs // tylko moby bez kończyn

/datum/surgery_operation/basic/close_skin/tool_check(obj/item/tool)
	if(istype(tool, /obj/item/stack/medical/suture))
		return TRUE

	// AQUILA - nasz kauter nie ma temperatury (heat), w tg ma
	if(tool.tool_behaviour == TOOL_CAUTERY)
		return TRUE

	if(istype(tool, /obj/item/gun/energy/laser))
		var/obj/item/gun/energy/laser/lasergun = tool
		return lasergun.cell?.charge > 0

	return tool.is_hot() >= FIRE_MINIMUM_TEMPERATURE_TO_EXIST

/datum/surgery_operation/basic/close_skin/on_preop(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_notice("Zaczynasz zamykać nacięcie [patient]..."),
		span_notice("[surgeon] zaczyna zamykać nacięcie [patient]."),
		span_notice("[surgeon] zaczyna zamykać nacięcie [patient]."),
	)
	display_pain(patient, istype(tool, /obj/item/stack/medical/suture) ? "Coś cię szczypie!" : "Coś cię przypala!")

/datum/surgery_operation/basic/close_skin/on_success(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	// czysta karta
	patient.remove_status_effect(/datum/status_effect/basic_surgery_state)
