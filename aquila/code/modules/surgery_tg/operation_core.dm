// AQUILA - tg code/modules/surgery/operations/operation_core.dm
// Wyjęcie rdzenia z martwego szlamu (stara wersja: code/modules/surgery/core_removal.dm)

/datum/surgery_operation/basic/core_removal
	name = "wyjęcie rdzenia"
	rnd_name = "Korektomia (wyjęcie rdzenia)"
	desc = "Wyjmuje rdzeń ze szlamu."
	implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_CROWBAR = 1,
	)
	time = 1.6 SECONDS
	operation_flags = OPERATION_IGNORE_CLOTHES | OPERATION_STANDING_ALLOWED
	any_surgery_states_required = ALL_SURGERY_SKIN_STATES
	blocked_biotype = null

/datum/surgery_operation/basic/core_removal/get_default_radial_image()
	return get_item_radial_image(/obj/item/slime_extract/grey)

/datum/surgery_operation/basic/core_removal/all_required_strings()
	return list("operacja na martwym szlamie") + ..()

/datum/surgery_operation/basic/core_removal/state_check(mob/living/patient)
	return isslime(patient) && patient.stat == DEAD

/datum/surgery_operation/basic/core_removal/on_preop(mob/living/simple_animal/slime/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_notice("Zaczynasz wydobywać rdzeń z [patient]..."),
		span_notice("[surgeon] zaczyna wydobywać rdzeń z [patient]."),
		span_notice("[surgeon] zaczyna wydobywać rdzeń z [patient]."),
	)

/datum/surgery_operation/basic/core_removal/on_success(mob/living/simple_animal/slime/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	// AQUILA - tg ma try_extract_cores(), u nas wyjmujemy wszystkie rdzenie jak stary krok, tylko naraz
	var/core_count = patient.cores
	if(core_count <= 0)
		to_chat(surgeon, span_warning("W [patient] nie zostały już żadne rdzenie!"))
		return
	for(var/i in 1 to core_count)
		var/obj/item/slime_extract/item = new patient.coretype(patient.loc)
		if(patient.transformeffects & SLIME_EFFECT_GOLD)
			item.sparkly = TRUE
	patient.cores = 0
	patient.icon_state = "[patient.colour] baby slime dead-nocore"
	display_results(
		surgeon,
		patient,
		span_notice("Wydobywasz z [patient] rdzenie: [core_count]."),
		span_notice("[surgeon] wydobywa z [patient] rdzenie: [core_count]!"),
		span_notice("[surgeon] wydobywa z [patient] rdzenie: [core_count]!"),
	)
