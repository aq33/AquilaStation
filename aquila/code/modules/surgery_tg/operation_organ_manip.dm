// AQUILA - tg code/modules/surgery/operations/operation_organ_manip.dm
// Wkładanie i wyjmowanie organów (stara wersja: code/modules/surgery/organ_manipulation.dm).
// U nas organy siedzą w mobie (internal_organs), a nie w kończynie, więc szukamy ich po strefie.
// Zostaje z naszej wersji: organy z pojemnika na organy (borgi), pozytronowy mózg tylko w robotycznej obudowie IPC,
// pogryzione organy się nie nadają, on_find(), wyciąganie horrora, opór guza thralla, operacja na sobie poza klatką i głową.
// Pominięte z tg: dowolne przedmioty jako organy (arbitrary_item_organ), osobne operacje na organach zewnętrznych
// (ORGAN_EXTERNAL, u nas ogony i skrzydła to zwykłe organy) i nastrój TRAIT_MORBID.

#define OPERATION_REMOVED_ORGAN "removed_organ"

/// Wkładanie i wyjmowanie organów
/datum/surgery_operation/limb/organ_manipulation
	name = "operacja na organach"
	abstract_type = /datum/surgery_operation/limb/organ_manipulation
	operation_flags = OPERATION_MORBID | OPERATION_NOTABLE | OPERATION_NO_PATIENT_REQUIRED
	required_bodytype = BODYTYPE_ORGANIC
	time = 6.4 SECONDS
	/// Opcje menu radialnego dla każdego typu organu
	VAR_PRIVATE/list/cached_organ_manipulation_options

	/// Dźwięk na początku wkładania
	var/insert_preop_sound = 'sound/surgery/organ2.ogg'
	/// Dźwięk na początku wyjmowania
	var/remove_preop_sound = 'sound/surgery/hemostat1.ogg'
	/// Dźwięk po włożeniu
	var/insert_success_sound = 'sound/surgery/organ1.ogg'
	/// Dźwięk po wyjęciu
	var/remove_success_sound = 'sound/surgery/organ2.ogg'

	/// Czym się wkłada organy
	var/list/insert_implements = list(
		/obj/item/organ = 1,
		/obj/item/organ_storage = 1,
	)
	/// Czym się wyjmuje organy
	var/list/remove_implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_CROWBAR = 1.8,
		/obj/item/kitchen/fork = 2.85,
	)

/datum/surgery_operation/limb/organ_manipulation/New()
	. = ..()
	implements = remove_implements + insert_implements

/datum/surgery_operation/limb/organ_manipulation/get_recommended_tool()
	return "[..()] / organ"

/datum/surgery_operation/limb/organ_manipulation/get_default_radial_image()
	return image(icon = 'icons/obj/surgery.dmi', icon_state = "surgery_any")

/// Czy ten organ można wyjąć albo włożyć
/datum/surgery_operation/limb/organ_manipulation/proc/organ_check(obj/item/bodypart/limb, obj/item/organ/organ)
	return TRUE

/// Czy organ pasuje do kończyny i wybranej strefy (wyrostek tylko w pachwinie, nie w klatce)
/datum/surgery_operation/limb/organ_manipulation/proc/zone_check(obj/item/organ/organ, limb_zone, operated_zone)
	SHOULD_CALL_PARENT(TRUE)
	if(limb_zone != check_zone(organ.zone))
		return FALSE
	if(operated_zone != organ.zone)
		return FALSE
	return TRUE

/// Organy, które da się wyjąć z tej kończyny w tej strefie
/datum/surgery_operation/limb/organ_manipulation/proc/get_removable_organs(obj/item/bodypart/limb, operated_zone)
	var/list/removable_organs = list()
	if(!iscarbon(limb.owner))
		return removable_organs
	var/mob/living/carbon/patient = limb.owner
	for(var/obj/item/organ/organ as anything in patient.internal_organs)
		if(!organ_check(limb, organ) || (organ.organ_flags & ORGAN_UNREMOVABLE))
			continue
		if(!zone_check(organ, limb.body_zone, operated_zone))
			continue
		removable_organs += organ
	return removable_organs

/// AQUILA - horror (Yogstation#13033) siedzący w pacjencie, wyciąga się go jak organ
/datum/surgery_operation/limb/organ_manipulation/proc/get_horror(obj/item/bodypart/limb)
	if(isnull(limb.owner))
		return null
	var/mob/living/simple_animal/horror/horror = limb.owner.has_horror_inside()
	if(horror?.victim != limb.owner)
		return null
	return horror

/// Czy jest co wyjąć
/datum/surgery_operation/limb/organ_manipulation/proc/is_remove_available(obj/item/bodypart/limb, operated_zone)
	return length(get_removable_organs(limb, operated_zone)) > 0 || !isnull(get_horror(limb))

/// AQUILA - organ z pojemnika na organy albo sam przedmiot
/datum/surgery_operation/limb/organ_manipulation/proc/get_inserted_organ(obj/item/tool)
	if(istype(tool, /obj/item/organ_storage))
		if(!length(tool.contents))
			return null
		return tool.contents[1]
	return tool

/// Czy da się włożyć ten organ
/datum/surgery_operation/limb/organ_manipulation/proc/is_insert_available(obj/item/bodypart/limb, obj/item/tool, operated_zone)
	var/obj/item/organ/organ = get_inserted_organ(tool)
	if(!isorgan(organ) || !iscarbon(limb.owner))
		return FALSE
	if(!organ_check(limb, organ) || !organ.useable)
		return FALSE
	var/mob/living/carbon/patient = limb.owner
	if(patient.getorganslot(organ.slot))
		return FALSE
	if(!zone_check(organ, limb.body_zone, operated_zone))
		return FALSE
	// AQUILA - pozytronowy mózg tylko w robotycznej obudowie IPC
	if(istype(organ, /obj/item/organ/brain/positron) && (IS_ORGANIC_LIMB(limb) || !isipc(patient)))
		return FALSE
	return TRUE

/datum/surgery_operation/limb/organ_manipulation/proc/is_inserting(obj/item/tool)
	return is_type_in_list(tool, insert_implements)

/datum/surgery_operation/limb/organ_manipulation/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, operated_zone)
	return is_inserting(tool) ? is_insert_available(limb, tool, operated_zone) : is_remove_available(limb, operated_zone)

/datum/surgery_operation/limb/organ_manipulation/get_radial_options(obj/item/bodypart/limb, obj/item/tool, operating_zone)
	return is_inserting(tool) ? get_insert_options(limb, tool, operating_zone) : get_remove_options(limb, operating_zone)

/datum/surgery_operation/limb/organ_manipulation/proc/get_remove_options(obj/item/bodypart/limb, operating_zone)
	var/list/options = list()
	for(var/obj/item/organ/organ as anything in get_removable_organs(limb, operating_zone))
		var/remove_key = "[organ.type]_remove"
		var/datum/radial_menu_choice/option = LAZYACCESS(cached_organ_manipulation_options, remove_key)
		if(!option)
			option = new()
			var/image/option_image = get_generic_limb_radial_image(limb.body_zone)
			option_image.overlays += add_radial_overlays(organ.type)
			option.image = option_image
			option.name = "wyjęcie: [initial(organ.name)]"
			option.info = "Wyjmuje [initial(organ.name)] z ciała pacjenta."
			LAZYSET(cached_organ_manipulation_options, remove_key, option)

		options[option] = list("[OPERATION_ACTION]" = "remove", "[OPERATION_REMOVED_ORGAN]" = organ)

	var/mob/living/simple_animal/horror/horror = get_horror(limb)
	if(horror)
		var/datum/radial_menu_choice/horror_option = LAZYACCESS(cached_organ_manipulation_options, "horror_remove")
		if(!horror_option)
			horror_option = new()
			var/image/horror_option_image = get_generic_limb_radial_image(limb.body_zone)
			horror_option_image.overlays += add_radial_overlays(horror.type)
			horror_option.image = horror_option_image
			horror_option.name = "wyciągnięcie pasożyta"
			horror_option.info = "Wyciąga pasożyta z ciała pacjenta."
			LAZYSET(cached_organ_manipulation_options, "horror_remove", horror_option)
		options[horror_option] = list("[OPERATION_ACTION]" = "remove_horror")

	return options

/datum/surgery_operation/limb/organ_manipulation/proc/get_insert_options(obj/item/bodypart/limb, obj/item/tool)
	var/obj/item/organ/organ = get_inserted_organ(tool)
	var/datum/radial_menu_choice/option = LAZYACCESS(cached_organ_manipulation_options, "[organ.type]_insert")
	if(!option)
		option = new()
		var/image/option_image = get_generic_limb_radial_image(limb.body_zone)
		option_image.overlays += add_radial_overlays(organ.type)
		option.image = option_image
		option.name = "włożenie: [initial(organ.name)]"
		option.info = "Wkłada [initial(organ.name)] do ciała pacjenta."
		LAZYSET(cached_organ_manipulation_options, "[organ.type]_insert", option)

	var/list/result = list()
	result[option] = list("[OPERATION_ACTION]" = "insert")
	return result

/datum/surgery_operation/limb/organ_manipulation/operate_check(mob/living/patient, obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	if(!..())
		return FALSE

	switch(operation_args[OPERATION_ACTION])
		if("remove")
			var/obj/item/organ/organ = operation_args[OPERATION_REMOVED_ORGAN]
			if(QDELETED(organ) || organ.owner != limb.owner)
				return FALSE
		if("remove_horror")
			if(isnull(get_horror(limb)))
				return FALSE
		if("insert")
			if(!is_insert_available(limb, tool, operation_args[OPERATION_TARGET_ZONE]))
				return FALSE

	return TRUE

/datum/surgery_operation/limb/organ_manipulation/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	switch(operation_args[OPERATION_ACTION])
		if("remove")
			var/obj/item/organ/organ = operation_args[OPERATION_REMOVED_ORGAN]
			organ.on_find(surgeon)
			play_operation_sound(limb, surgeon, tool, remove_preop_sound)
			display_results(
				surgeon,
				limb.owner,
				span_notice("Zaczynasz wydobywać [organ] z ciała [limb.owner] ([strefa_pl(organ.zone)])..."),
				span_notice("[surgeon] zaczyna wydobywać [organ] z ciała [limb.owner] ([strefa_pl(organ.zone)])."),
				span_notice("[surgeon] zaczyna coś wydobywać z ciała [limb.owner] ([strefa_pl(organ.zone)])."),
			)
			display_pain(limb.owner, "Czujesz szarpanie ([strefa_pl(limb.body_zone)])!")
		if("remove_horror")
			var/mob/living/simple_animal/horror/horror = get_horror(limb)
			display_results(
				surgeon,
				limb.owner,
				span_notice("Zaczynasz wyciągać [horror] z ciała [limb.owner]..."),
				span_notice("[surgeon] zaczyna wyciągać [horror] z ciała [limb.owner]."),
				span_notice("[surgeon] zaczyna coś wyciągać z ciała [limb.owner]."),
			)
		if("insert")
			var/obj/item/organ/organ = get_inserted_organ(tool)
			play_operation_sound(limb, surgeon, tool, insert_preop_sound)
			display_results(
				surgeon,
				limb.owner,
				span_notice("Zaczynasz wkładać [organ] do ciała [limb.owner] ([strefa_pl(organ.zone)])..."),
				span_notice("[surgeon] zaczyna wkładać [organ] do ciała [limb.owner] ([strefa_pl(organ.zone)])."),
				span_notice("[surgeon] zaczyna coś wkładać do ciała [limb.owner] ([strefa_pl(organ.zone)])."),
			)
			display_pain(limb.owner, "Czujesz, jak ktoś coś w ciebie wkłada ([strefa_pl(limb.body_zone)])!")

/datum/surgery_operation/limb/organ_manipulation/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	switch(operation_args[OPERATION_ACTION])
		if("remove")
			play_operation_sound(limb, surgeon, tool, remove_success_sound)
			on_success_remove_organ(limb, surgeon, operation_args[OPERATION_REMOVED_ORGAN], tool)
		if("remove_horror")
			on_success_remove_horror(limb, surgeon)
		if("insert")
			play_operation_sound(limb, surgeon, tool, insert_success_sound)
			on_success_insert_organ(limb, surgeon, operation_args[OPERATION_TARGET_ZONE], tool)

/datum/surgery_operation/limb/organ_manipulation/proc/on_success_remove_organ(obj/item/bodypart/limb, mob/living/surgeon, obj/item/organ/organ, obj/item/tool)
	var/mob/living/carbon/patient = limb.owner
	// AQUILA - darkspawn z Yogstation: przytomny thrall odpycha operujących
	if(istype(organ, /obj/item/organ/shadowtumor/thrall))
		var/obj/item/organ/shadowtumor/thrall/tumor = organ
		if(tumor.resist(patient))
			return
	display_results(
		surgeon,
		patient,
		span_notice("Pomyślnie wydobywasz [organ] z ciała [patient] ([strefa_pl(organ.zone)])."),
		span_notice("[surgeon] pomyślnie wydobywa [organ] z ciała [patient] ([strefa_pl(organ.zone)])!"),
		span_notice("[surgeon] pomyślnie wydobywa coś z ciała [patient] ([strefa_pl(organ.zone)])!"),
	)
	display_pain(patient, "Ból pulsuje ([strefa_pl(limb.body_zone)]), nie czujesz już [organ.name]!")
	log_combat(surgeon, patient, "surgically removed [organ.name] from")
	organ.Remove(patient)
	organ.forceMove(patient.drop_location())
	// tg: organy od ofiary heretyka reagują na wycięcie (aquila/code/modules/antagonists/heretic/_compat/sacrifice.dm)
	SEND_SIGNAL(organ, COMSIG_ORGAN_SURGICALLY_REMOVED, surgeon, patient, limb.body_zone, tool)

/datum/surgery_operation/limb/organ_manipulation/proc/on_success_remove_horror(obj/item/bodypart/limb, mob/living/surgeon)
	var/mob/living/simple_animal/horror/horror = get_horror(limb)
	if(isnull(horror))
		return
	display_results(
		surgeon,
		limb.owner,
		span_notice("Udało ci się wyciągnąć [horror] z ciała [limb.owner]."),
		span_notice("[surgeon] wyciąga [horror] z ciała [limb.owner]!"),
		span_notice("[surgeon] wyciąga coś z ciała [limb.owner]!"),
	)
	log_combat(surgeon, limb.owner, "surgically removed [horror] from")
	horror.leave_victim()

/datum/surgery_operation/limb/organ_manipulation/proc/on_success_insert_organ(obj/item/bodypart/limb, mob/living/surgeon, operated_zone, obj/item/tool)
	var/obj/item/organ/organ = get_inserted_organ(tool)
	if(!isorgan(organ))
		CRASH("Somehow failed to find a valid organ to insert (inserting: [tool || "null"])")

	if(istype(tool, /obj/item/organ_storage))
		tool.icon_state = initial(tool.icon_state)
		tool.desc = initial(tool.desc)
		tool.cut_overlays()
	else if(organ.loc == surgeon)
		surgeon.temporarilyRemoveItemFromInventory(organ, TRUE)
	organ.Insert(limb.owner, get_insert_special(organ))
	display_results(
		surgeon,
		limb.owner,
		span_notice("Wkładasz [organ] do ciała [limb.owner] ([strefa_pl(organ.zone)])."),
		span_notice("[surgeon] wkłada [organ] do ciała [limb.owner] ([strefa_pl(organ.zone)])!"),
		span_notice("[surgeon] wkłada coś do ciała [limb.owner] ([strefa_pl(organ.zone)])!"),
	)
	display_pain(limb.owner, "Ból pulsuje ([strefa_pl(limb.body_zone)]), gdy nowy organ ([organ.name]) zaczyna pracować!")

/// Argument special dla Insert(). Gruczoły abduktorów wkładane ich operacją dostają 2 (nie startują od razu).
/datum/surgery_operation/limb/organ_manipulation/proc/get_insert_special(obj/item/organ/organ)
	return 0

/// Organy wewnętrzne
/datum/surgery_operation/limb/organ_manipulation/internal
	name = "operacja na organach wewnętrznych"
	desc = "Wkłada albo wyjmuje organy wewnętrzne pacjenta."
	replaced_by = /datum/surgery_operation/limb/organ_manipulation/internal/abductor
	// AQUILA - u nas operację na organach poza klatką i głową można zrobić na sobie
	operation_flags = OPERATION_MORBID | OPERATION_NOTABLE | OPERATION_NO_PATIENT_REQUIRED | OPERATION_SELF_OPERABLE
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT

	var/bone_locked_organs = "mózgu albo organów w klatce piersiowej"

/datum/surgery_operation/limb/organ_manipulation/internal/organ_check(obj/item/bodypart/limb, obj/item/organ/organ)
	// organy w klatce i mózg wymagają przepiłowanej kości
	if(organ.zone == BODY_ZONE_CHEST || organ.slot == ORGAN_SLOT_BRAIN)
		return !LIMB_HAS_BONES(limb) || LIMB_HAS_SURGERY_STATE(limb, SURGERY_BONE_SAWED)
	return TRUE

/datum/surgery_operation/limb/organ_manipulation/internal/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, operated_zone)
	// AQUILA - na sobie tylko poza klatką i głową (jak stara organ_manipulation/soft)
	if(surgeon == limb.owner && !(operation_flags & OPERATION_MECHANIC) && (operated_zone == BODY_ZONE_CHEST || operated_zone == BODY_ZONE_HEAD))
		return FALSE
	return ..()

/datum/surgery_operation/limb/organ_manipulation/internal/any_required_strings()
	return ..() + list(
		"przy operacji [bone_locked_organs] kość MUSI być przepiłowana",
		"przy innych organach stan kości nie ma znaczenia",
	)

/// Organy w protezach i IPC
/datum/surgery_operation/limb/organ_manipulation/internal/mechanic
	name = "operacja na podzespołach protezy"
	required_bodytype = BODYTYPE_ROBOTIC
	remove_implements = list(
		TOOL_CROWBAR = 1,
		TOOL_HEMOSTAT = 1,
		/obj/item/kitchen/fork = 2.85,
	)
	operation_flags = OPERATION_MORBID | OPERATION_NOTABLE | OPERATION_NO_PATIENT_REQUIRED | OPERATION_SELF_OPERABLE | OPERATION_MECHANIC
	replaced_by = null

/// Abduktorzy: przez ubranie i serce bez piłowania
/datum/surgery_operation/limb/organ_manipulation/internal/abductor
	name = "eksperymentalna operacja na organach"
	operation_flags = OPERATION_MORBID | OPERATION_NOTABLE | OPERATION_NO_PATIENT_REQUIRED | OPERATION_IGNORE_CLOTHES | OPERATION_LOCKED | OPERATION_NO_WIKI
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED
	bone_locked_organs = "mózgu albo organów w klatce piersiowej (POZA sercem)"

/datum/surgery_operation/limb/organ_manipulation/internal/abductor/organ_check(obj/item/bodypart/limb, obj/item/organ/organ)
	return (organ.slot == ORGAN_SLOT_HEART) || ..() // serce zawsze, bez względu na kość

#undef OPERATION_REMOVED_ORGAN
