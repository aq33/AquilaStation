// AQUILA - tg code/modules/surgery/operations/operation_implant_removal.dm
// Usuwanie implantów (stara wersja: code/modules/surgery/implant_removal.dm + aquila/code/modules/surgery/implant_removal.dm).
// Zostaje z naszej: implant, który się sam niszczy, daje osobny komunikat, a bez pustej kasetki implant przepada (qdel).
// Do tego nasza operacja usuwania ciał obcych (code/modules/surgery/remove_embedded_object.dm), której tg nie ma:
// wyjmuje wbite przedmioty i kule zostające w ciele (bullet_lodging.dm, fragmenty balistyczne detektywa).

/datum/surgery_operation/basic/implant_removal
	name = "usunięcie implantu"
	desc = "Szuka implantu w ciele pacjenta i go usuwa. \
		Implant przepada, chyba że chirurg trzyma w ręce albo ma pod pacjentem pustą kasetkę na implant."
	operation_flags = OPERATION_NOTABLE
	implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_CROWBAR = 1.5,
		/obj/item/kitchen/fork = 2.85,
	)
	time = 6.4 SECONDS
	success_sound = 'sound/surgery/hemostat1.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED

/datum/surgery_operation/basic/implant_removal/get_default_radial_image()
	return get_item_radial_image(/obj/item/implantcase)

/datum/surgery_operation/basic/implant_removal/any_optional_strings()
	return ..() + list("pusta kasetka na implant w ręce albo pod pacjentem zachowa implant")

/datum/surgery_operation/basic/implant_removal/on_preop(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_notice("Szukasz implantu w ciele [patient]..."),
		span_notice("[surgeon] szuka implantu w ciele [patient]."),
		span_notice("[surgeon] szuka czegoś w ciele [patient]."),
	)
	if(LAZYLEN(patient.implants))
		display_pain(patient, "Czujesz ostry ból, gdy [surgeon] grzebie w twoim wnętrzu!")

/datum/surgery_operation/basic/implant_removal/on_success(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/obj/item/implant/implant = LAZYACCESS(patient.implants, 1)
	if(isnull(implant))
		display_results(
			surgeon,
			patient,
			span_warning("Nie możesz niczego znaleźć w ciele [patient]!"),
			span_warning("[surgeon] nie znajduje żadnego implantu w ciele [patient]."),
			span_warning("[surgeon] niczego nie znajduje w ciele [patient]."),
		)
		return

	implant.removed(patient)
	if(QDELETED(implant)) // implant, który się sam niszczy
		display_results(
			surgeon,
			patient,
			span_notice("Usuwasz [implant] z ciała [patient], niszcząc go przy tym!"),
			span_notice("[surgeon] usuwa [implant] z ciała [patient], niszcząc go przy tym!"),
			span_notice("[surgeon] usuwa coś z ciała [patient], niszcząc to przy tym!"),
		)
		return

	display_results(
		surgeon,
		patient,
		span_notice("Pomyślnie usuwasz [implant] z ciała [patient]."),
		span_notice("[surgeon] pomyślnie usuwa [implant] z ciała [patient]!"),
		span_notice("[surgeon] pomyślnie usuwa coś z ciała [patient]!"),
	)
	display_pain(patient, "Czujesz, jak ktoś wyciąga z ciebie [implant.name]!")

	var/obj/item/implantcase/case = get_case(surgeon, patient)
	if(isnull(case))
		qdel(implant)
		return

	case.imp = implant
	implant.forceMove(case)
	case.update_icon()
	display_results(
		surgeon,
		patient,
		span_notice("Umieszczasz [implant] w [case]."),
		span_notice("[surgeon] umieszcza [implant] w [case]!"),
		span_notice("[surgeon] umieszcza to w [case]!"),
	)

/// Pusta kasetka w ręce chirurga albo pod nim czy pacjentem
/datum/surgery_operation/basic/implant_removal/proc/get_case(mob/living/surgeon, mob/living/target)
	var/list/locations = list(
		surgeon.is_holding_item_of_type(/obj/item/implantcase),
		locate(/obj/item/implantcase) in surgeon.loc,
		locate(/obj/item/implantcase) in target.loc,
	)

	for(var/obj/item/implantcase/case in locations)
		if(!case.imp)
			return case

	return null

/// AQUILA - u nas stara wersja miała też odmianę dla protez (IPC)
/datum/surgery_operation/basic/implant_removal/mechanic
	name = "usunięcie implantu z obudowy"
	operation_flags = OPERATION_NOTABLE | OPERATION_MECHANIC
	required_bodytype = BODYTYPE_ROBOTIC
	blocked_biotype = null

// --- Ciała obce (AQUILA) ---

/// Wyjęcie wbitych przedmiotów i kul z kończyny (stare "removal of embedded objects")
/datum/surgery_operation/limb/remove_embedded_objects
	name = "usunięcie ciał obcych"
	desc = "Wyjmuje z kończyny wbite przedmioty i kule, które zostały w ciele, i tamuje krwawienie."
	implements = list(
		IMPLEMENT_HAND = 1,
		TOOL_HEMOSTAT = 1,
		TOOL_WIRECUTTER = 2,
		/obj/item/kitchen/fork = 3,
	)
	time = 3.2 SECONDS
	preop_sound = 'sound/surgery/hemostat1.ogg'
	success_sound = 'sound/surgery/organ2.ogg'
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_PRIORITY_NEXT_STEP
	any_surgery_states_required = ALL_SURGERY_SKIN_STATES

/datum/surgery_operation/limb/remove_embedded_objects/get_default_radial_image()
	return image(icon = 'icons/obj/surgery.dmi', icon_state = "hemostat")

/datum/surgery_operation/limb/remove_embedded_objects/all_required_strings()
	return list("w kończynie musi tkwić ciało obce albo kula") + ..()

/datum/surgery_operation/limb/remove_embedded_objects/state_check(obj/item/bodypart/limb)
	return length(get_foreign_bodies(limb)) > 0

/// Wbite przedmioty i fragmenty pocisków w kończynie
/datum/surgery_operation/limb/remove_embedded_objects/proc/get_foreign_bodies(obj/item/bodypart/limb)
	var/list/foreign_bodies = list()
	for(var/obj/item/embedded in limb.embedded_objects)
		foreign_bodies |= embedded
	// fragmenty balistyczne leżą w kończynie (aquila/code/modules/detectivework/ballistics.dm)
	for(var/obj/item/bullet_fragment/fragment in limb)
		foreign_bodies |= fragment
	return foreign_bodies

/datum/surgery_operation/limb/remove_embedded_objects/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Szukasz ciał obcych w ciele [limb.owner] ([strefa_pl(limb.body_zone)])..."),
		span_notice("[surgeon] szuka ciał obcych w ciele [limb.owner] ([strefa_pl(limb.body_zone)])."),
		span_notice("[surgeon] szuka czegoś w ciele [limb.owner] ([strefa_pl(limb.body_zone)])."),
	)
	display_pain(limb.owner, "Czujesz, jak ktoś grzebie ci w ranie ([strefa_pl(limb.body_zone)])!")

/datum/surgery_operation/limb/remove_embedded_objects/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	var/mob/living/carbon/patient = limb.owner
	patient.cauterise_wounds()
	var/objects = 0
	for(var/obj/item/foreign_body as anything in get_foreign_bodies(limb))
		objects++
		if(foreign_body in limb.embedded_objects)
			patient.remove_embedded_object(foreign_body)
		// komponent embedded przenosi przedmiot asynchronicznie, a fragment, który tylko leżał w kończynie, wyjmujemy sami
		if(!QDELETED(foreign_body) && (foreign_body.loc == limb || foreign_body.loc == patient))
			foreign_body.forceMove(patient.drop_location())

	if(!objects)
		to_chat(surgeon, span_warning("Nie znajdujesz żadnych ciał obcych w ciele [patient] ([strefa_pl(limb.body_zone)])!"))
		return
	display_results(
		surgeon,
		patient,
		span_notice("Pomyślnie usuwasz ciała obce ([objects]) z ciała [patient] ([strefa_pl(limb.body_zone)])."),
		span_notice("[surgeon] pomyślnie usuwa ciała obce ([objects]) z ciała [patient] ([strefa_pl(limb.body_zone)])!"),
		span_notice("[surgeon] pomyślnie usuwa ciała obce ([objects]) z ciała [patient] ([strefa_pl(limb.body_zone)])!"),
	)
