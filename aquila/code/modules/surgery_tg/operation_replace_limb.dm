// AQUILA - tg code/modules/surgery/operations/operation_replace_limb.dm
// Augmentacja: wymiana kończyny na robotyczną (stara wersja: code/modules/surgery/limb_augmentation.dm).
// Zostaje z naszej: kończyny z pojemnika na organy (borgi), nie da się augmentować sparaliżowanej kończyny
// ani oozelinga. Pominięte z tg: TRAIT_NO_AUGMENTS, BODYPART_UNREMOVABLE, check_for_frankenstein (nie mamy).

/datum/surgery_operation/limb/replace_limb
	name = "augmentacja kończyny"
	rnd_name = "Augmentacja"
	desc = "Zastępuje kończynę pacjenta robotyczną protezą."
	operation_flags = OPERATION_NOTABLE
	implements = list(
		/obj/item/bodypart = 1,
		/obj/item/organ_storage = 1,
	)
	time = 3.2 SECONDS
	all_surgery_states_required = SURGERY_SKIN_OPEN
	/// Opcje menu radialnego dla każdej protezy
	VAR_PRIVATE/list/cached_augment_options

/datum/surgery_operation/limb/replace_limb/get_recommended_tool()
	return "robotyczna kończyna"

/datum/surgery_operation/limb/replace_limb/get_default_radial_image()
	return get_item_radial_image(/obj/item/bodypart/chest/robot)

/// AQUILA - proteza z pojemnika na organy albo sam przedmiot
/datum/surgery_operation/limb/replace_limb/proc/get_augment(obj/item/tool)
	if(istype(tool, /obj/item/organ_storage))
		if(!length(tool.contents))
			return null
		var/obj/item/stored = tool.contents[1]
		return isbodypart(stored) ? stored : null
	return isbodypart(tool) ? tool : null

/datum/surgery_operation/limb/replace_limb/get_radial_options(obj/item/bodypart/limb, obj/item/tool, operating_zone)
	var/obj/item/bodypart/augment = get_augment(tool)
	var/datum/radial_menu_choice/option = LAZYACCESS(cached_augment_options, augment.type)
	if(!option)
		option = new()
		option.name = "augmentacja: [initial(augment.name)]"
		option.info = "Zastępuje kończynę pacjenta ([initial(limb.name)]) protezą: [initial(augment.name)]."
		option.image = image(augment.type)
		LAZYSET(cached_augment_options, augment.type, option)

	return option

/datum/surgery_operation/limb/replace_limb/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, operated_zone)
	if(!surgeon.canUnEquip(tool))
		return FALSE
	var/obj/item/bodypart/augment = get_augment(tool)
	if(isnull(augment) || limb.body_zone != augment.body_zone)
		return FALSE
	return TRUE

/datum/surgery_operation/limb/replace_limb/state_check(obj/item/bodypart/limb)
	if(isoozeling(limb.owner))
		return FALSE
	if(limb.is_disabled() == BODYPART_DISABLED_PARALYSIS)
		return FALSE
	return TRUE

/datum/surgery_operation/limb/replace_limb/all_blocked_strings()
	return ..() + list("kończyna nie może być sparaliżowana")

/datum/surgery_operation/limb/replace_limb/tool_check(obj/item/tool)
	var/obj/item/bodypart/augment = get_augment(tool)
	if(isnull(augment))
		return FALSE
	if(augment.item_flags & (ABSTRACT|DROPDEL))
		return FALSE
	return !IS_ORGANIC_LIMB(augment)

/datum/surgery_operation/limb/replace_limb/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/obj/item/bodypart/augment = get_augment(tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz augmentować [FORMAT_LIMB_OWNER(limb)]..."),
		span_notice("[surgeon] zaczyna augmentować [FORMAT_LIMB_OWNER(limb)] za pomocą [augment]."),
		span_notice("[surgeon] zaczyna augmentować [FORMAT_LIMB_OWNER(limb)]."),
	)
	display_pain(limb.owner, "Czujesz straszny ból ([strefa_pl(limb.body_zone)])!")

/datum/surgery_operation/limb/replace_limb/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/obj/item/bodypart/augment = get_augment(tool)
	var/mob/living/carbon/patient = limb.owner // za chwilę owner zniknie
	var/zone = limb.body_zone
	if(istype(tool, /obj/item/organ_storage))
		tool.icon_state = initial(tool.icon_state)
		tool.desc = initial(tool.desc)
		tool.cut_overlays()
	else if(!surgeon.temporarilyRemoveItemFromInventory(augment))
		return

	augment.replace_limb(patient, TRUE)
	if(augment.owner != patient)
		display_results(
			surgeon,
			patient,
			span_warning("Nie udaje ci się dopasować [augment] do ciała [patient]!"),
			span_warning("[surgeon] nie umie dopasować [augment] do ciała [patient]!"),
			span_warning("[surgeon] nie umie dopasować [augment] do ciała [patient]!"),
		)
		augment.forceMove(patient.drop_location())
		return

	display_results(
		surgeon,
		patient,
		span_notice("Pomyślnie augmentujesz [strefa_pl(zone, TRUE)] [patient]."),
		span_notice("[surgeon] pomyślnie augmentuje [strefa_pl(zone, TRUE)] [patient] za pomocą [augment]!"),
		span_notice("[surgeon] pomyślnie augmentuje [strefa_pl(zone, TRUE)] [patient]!"),
	)
	display_pain(patient, "Czujesz, jak syntetyczne czucie wypełnia ci [strefa_pl(zone, TRUE)]!", TRUE)
	log_combat(surgeon, patient, "augmented", addition = "by giving him new [augment]")
	// nowa kończyna zostaje przygotowana, żeby dało się ją od razu zamknąć
	var/datum/status_effect/surgery_prepped/prep = patient.has_status_effect(/datum/status_effect/surgery_prepped) || null // u nas FALSE, gdy brak statusu
	prep?.track_surgery(zone)
