// AQUILA - tg code/modules/surgery/operations/operation_filter.dm
// Filtrowanie krwi (stara wersja: code/modules/surgery/blood_filter.dm). Zostaje z naszej: każdy cykl usuwa 22% każdej
// substancji (najwyżej 10 j.), porażka to 5 obrażeń. Nasz filtr nie ma listy wyjątków (whitelist z tg), więc usuwa wszystko.

/datum/surgery_operation/limb/filter_blood
	name = "filtrowanie krwi"
	rnd_name = "Hemodializa (filtrowanie krwi)"
	desc = "Usuwa niepożądane substancje z krwi pacjenta."
	implements = list(TOOL_BLOODFILTER = 1)
	time = 2.5 SECONDS
	operation_flags = OPERATION_LOOPING
	required_bodytype = BODYTYPE_ORGANIC
	success_sound = 'sound/machines/ping.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED

/datum/surgery_operation/limb/filter_blood/all_required_strings()
	. = list()
	. += "operacja na klatce piersiowej"
	. += ..()
	. += "pacjent nie może być wysuszony"

/datum/surgery_operation/limb/filter_blood/get_default_radial_image()
	return get_item_radial_image(/obj/item/blood_filter)

/datum/surgery_operation/limb/filter_blood/state_check(obj/item/bodypart/limb)
	return limb.body_zone == BODY_ZONE_CHEST && !HAS_TRAIT(limb.owner, TRAIT_HUSK)

/datum/surgery_operation/limb/filter_blood/can_loop(mob/living/patient, obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	return ..() && has_filterable_chems(limb.owner, tool)

/datum/surgery_operation/limb/filter_blood/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz filtrować krew [limb.owner]..."),
		span_notice("[surgeon] filtruje krew [limb.owner] za pomocą [tool]."),
		span_notice("[surgeon] używa [tool] na klatce piersiowej [limb.owner]."),
	)
	display_pain(limb.owner, "Czujesz pulsujący ból w klatce piersiowej!")

/datum/surgery_operation/limb/filter_blood/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/mob/living/carbon/patient = limb.owner
	if(!patient.reagents?.total_volume)
		display_results(
			surgeon,
			patient,
			span_notice("[tool] błyska: krew [patient] jest czysta."),
			span_notice("[tool] błyska: krew [patient] jest czysta."),
			span_notice("[tool] nie ma substancji do odfiltrowania."),
		)
		return
	for(var/datum/reagent/chem as anything in patient.reagents.reagent_list)
		patient.reagents.remove_reagent(chem.type, min(chem.volume * 0.22, 10))

	display_results(
		surgeon,
		patient,
		span_notice("[tool] pinguje, kończąc cykl filtrowania krwi [patient]."),
		span_notice("[tool] szumi, filtrując krew [patient]."),
		span_notice("[tool] szumi i pompuje."),
	)

	if(surgeon.is_holding_item_of_type(/obj/item/healthanalyzer))
		chemscan(surgeon, patient)

/datum/surgery_operation/limb/filter_blood/on_failure(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_warning("Partaczysz, obijając klatkę piersiową [limb.owner]!"),
		span_warning("[surgeon] partaczy, obijając klatkę piersiową [limb.owner]!"),
		span_warning("[surgeon] partaczy!"),
	)
	limb.receive_damage(5)

/// Czy jest jeszcze co filtrować
/datum/surgery_operation/limb/filter_blood/proc/has_filterable_chems(mob/living/carbon/target, obj/item/bloodfilter)
	if(!length(target.reagents?.reagent_list))
		bloodfilter.audible_message(span_notice("[bloodfilter] pinguje: we krwi [target] nie ma już żadnych substancji."))
		playsound(target, 'sound/machines/ping.ogg', 75, TRUE, falloff_exponent = 12, falloff_distance = 1)
		return FALSE
	return TRUE

/// Płukanie hydrauliki (IPC, protezy)
/datum/surgery_operation/limb/filter_blood/mechanic
	name = "płukanie hydrauliki"
	rnd_name = "Płukanie hydrauliki (filtrowanie krwi)"
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = OPERATION_LOOPING | OPERATION_MECHANIC
