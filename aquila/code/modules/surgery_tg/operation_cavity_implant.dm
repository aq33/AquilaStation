// AQUILA - tg code/modules/surgery/operations/operation_cavity_implant.dm
// Przedmioty w jamie ciała (stara wersja: code/modules/surgery/cavity_implant.dm). Zostaje z naszej: można to zrobić
// na sobie, gorące przedmioty (kauter, laser, zapalniczka) i przedmioty przyklejone do ręki się nie nadają.

/// Rozwarcie jamy klatki piersiowej
/datum/surgery_operation/limb/prepare_cavity
	name = "rozwarcie jamy ciała"
	desc = "Rozwiera jamę klatki piersiowej pacjenta, żeby zmieścić w niej przedmiot."
	implements = list(
		TOOL_RETRACTOR = 1,
		TOOL_CROWBAR = 1.5,
	)
	time = 4.8 SECONDS
	operation_flags = OPERATION_SELF_OPERABLE
	preop_sound = 'sound/surgery/retractor1.ogg'
	success_sound = 'sound/surgery/retractor2.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT
	any_surgery_states_blocked = SURGERY_CAVITY_WIDENED

/datum/surgery_operation/limb/prepare_cavity/get_default_radial_image()
	return image(icon = 'icons/obj/surgery.dmi', icon_state = "retractor")

/datum/surgery_operation/limb/prepare_cavity/all_required_strings()
	return list("operacja na klatce piersiowej") + ..()

/datum/surgery_operation/limb/prepare_cavity/state_check(obj/item/bodypart/chest/limb)
	return limb.body_zone == BODY_ZONE_CHEST

/datum/surgery_operation/limb/prepare_cavity/on_preop(obj/item/bodypart/chest/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz rozwierać jamę ciała ([FORMAT_LIMB_OWNER(limb)])..."),
		span_notice("[surgeon] zaczyna rozwierać jamę ciała ([FORMAT_LIMB_OWNER(limb)])."),
		span_notice("[surgeon] zaczyna rozwierać jamę ciała ([FORMAT_LIMB_OWNER(limb)])."),
	)
	display_pain(limb.owner, "Czujesz rozpierający ucisk ([strefa_pl(limb.body_zone)])!")

/datum/surgery_operation/limb/prepare_cavity/on_success(obj/item/bodypart/chest/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	limb.add_surgical_state(SURGERY_CAVITY_WIDENED)

/// Zamknięcie jamy bez wkładania niczego
/datum/surgery_operation/limb/undo_prepare_cavity
	name = "zamknięcie jamy ciała"
	desc = "Przywraca jamę klatki piersiowej pacjenta do normalnego stanu."
	implements = list(
		TOOL_RETRACTOR = 1,
		TOOL_CROWBAR = 1.5,
	)
	time = 4.8 SECONDS
	operation_flags = OPERATION_SELF_OPERABLE
	preop_sound = 'sound/surgery/retractor1.ogg'
	success_sound = 'sound/surgery/retractor2.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT|SURGERY_CAVITY_WIDENED

/datum/surgery_operation/limb/undo_prepare_cavity/get_default_radial_image()
	return image(icon = 'icons/obj/surgery.dmi', icon_state = "retractor")

/datum/surgery_operation/limb/undo_prepare_cavity/all_required_strings()
	return list("operacja na klatce piersiowej") + ..()

/datum/surgery_operation/limb/undo_prepare_cavity/state_check(obj/item/bodypart/chest/limb)
	return limb.body_zone == BODY_ZONE_CHEST

/datum/surgery_operation/limb/undo_prepare_cavity/on_preop(obj/item/bodypart/chest/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz zamykać jamę ciała ([FORMAT_LIMB_OWNER(limb)])..."),
		span_notice("[surgeon] zaczyna zamykać jamę ciała ([FORMAT_LIMB_OWNER(limb)])."),
		span_notice("[surgeon] zaczyna zamykać jamę ciała ([FORMAT_LIMB_OWNER(limb)])."),
	)
	display_pain(limb.owner, "Czujesz ucisk ([strefa_pl(limb.body_zone)])!")

/datum/surgery_operation/limb/undo_prepare_cavity/on_success(obj/item/bodypart/chest/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	limb.remove_surgical_state(SURGERY_CAVITY_WIDENED)

/// Włożenie przedmiotu do jamy
/datum/surgery_operation/limb/cavity_implant
	name = "implant w jamie ciała"
	desc = "Wkłada przedmiot do jamy ciała pacjenta."
	operation_flags = OPERATION_NOTABLE | OPERATION_SELF_OPERABLE
	implements = list(
		/obj/item = 1,
	)
	time = 3.2 SECONDS
	preop_sound = 'sound/surgery/organ1.ogg'
	success_sound = 'sound/surgery/organ2.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT|SURGERY_CAVITY_WIDENED
	/// Przedmioty, które wejdą mimo rozmiaru
	var/list/heavy_cavity_implants

/datum/surgery_operation/limb/cavity_implant/New()
	. = ..()
	heavy_cavity_implants = typecacheof(list(
		/obj/item/transfer_valve,
	))

/datum/surgery_operation/limb/cavity_implant/all_required_strings()
	return list("operacja na klatce piersiowej") + ..()

/datum/surgery_operation/limb/cavity_implant/get_default_radial_image()
	return image(icon = 'icons/obj/surgery.dmi', icon_state = "surgery_chest")

/datum/surgery_operation/limb/cavity_implant/state_check(obj/item/bodypart/chest/limb)
	if(limb.body_zone != BODY_ZONE_CHEST)
		return FALSE
	if(!isnull(limb.cavity_item))
		return FALSE
	return TRUE

/datum/surgery_operation/limb/cavity_implant/snowflake_check_availability(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool, operated_zone)
	if(!surgeon.canUnEquip(tool))
		return FALSE
	// żeby nie wsadzić do środka narzędzia, którym chciało się operować
	if(!IS_ORGANIC_LIMB(limb) && (tool.tool_behaviour in list(TOOL_CROWBAR, TOOL_SCREWDRIVER, TOOL_WRENCH, TOOL_WIRECUTTER, TOOL_WELDER, TOOL_MULTITOOL)))
		return FALSE
	if(IS_ORGANIC_LIMB(limb) && tool.is_surgical_tool())
		return FALSE
	return TRUE

/datum/surgery_operation/limb/cavity_implant/tool_check(obj/item/tool)
	if(tool.w_class > WEIGHT_CLASS_NORMAL && !is_type_in_typecache(tool, heavy_cavity_implants))
		return FALSE
	if(tool.item_flags & (ABSTRACT|DROPDEL))
		return FALSE
	if(HAS_TRAIT(tool, TRAIT_NODROP))
		return FALSE
	if(isorgan(tool) || istype(tool, /obj/item/organ_storage))
		return FALSE // od tego jest operacja na organach
	// AQUILA - jak stara operacja: nic gorącego
	if(tool.tool_behaviour == TOOL_CAUTERY || istype(tool, /obj/item/gun/energy/laser) || tool.is_hot())
		return FALSE
	return TRUE

/datum/surgery_operation/limb/cavity_implant/on_preop(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz wkładać [tool] do ciała [limb.owner] ([strefa_pl(limb.body_zone)])..."),
		span_notice("[surgeon] zaczyna wkładać [tool] do ciała [limb.owner] ([strefa_pl(limb.body_zone)])."),
		span_notice("[surgeon] zaczyna wkładać [tool.w_class > WEIGHT_CLASS_SMALL ? tool : "coś"] do ciała [limb.owner] ([strefa_pl(limb.body_zone)])."),
	)
	display_pain(limb.owner, "Czujesz, jak ktoś coś w ciebie wpycha ([strefa_pl(limb.body_zone)]), boli jak diabli!")

/datum/surgery_operation/limb/cavity_implant/on_success(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	if(!surgeon.transferItemToLoc(tool, limb.owner, TRUE))
		display_results(
			surgeon,
			limb.owner,
			span_warning("Nie możesz zmieścić [tool] w ciele [limb.owner] ([strefa_pl(limb.body_zone)])!"),
			span_warning("[surgeon] nie może zmieścić [tool] w ciele [limb.owner] ([strefa_pl(limb.body_zone)])!"),
			span_warning("[surgeon] nie może zmieścić [tool.w_class > WEIGHT_CLASS_SMALL ? tool : "czegoś"] w ciele [limb.owner] ([strefa_pl(limb.body_zone)])!"),
		)
		return

	limb.cavity_item = tool
	limb.remove_surgical_state(SURGERY_CAVITY_WIDENED)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Wpychasz [tool] do ciała [limb.owner] ([strefa_pl(limb.body_zone)])."),
		span_notice("[surgeon] wpycha [tool] do ciała [limb.owner] ([strefa_pl(limb.body_zone)])!"),
		span_notice("[surgeon] wpycha [tool.w_class > WEIGHT_CLASS_SMALL ? tool : "coś"] do ciała [limb.owner] ([strefa_pl(limb.body_zone)])."),
	)

/// Wyjęcie przedmiotu z jamy
/datum/surgery_operation/limb/undo_cavity_implant
	name = "wyjęcie z jamy ciała"
	desc = "Wyjmuje przedmiot z jamy ciała pacjenta."
	operation_flags = OPERATION_SELF_OPERABLE
	implements = list(
		IMPLEMENT_HAND = 1,
		TOOL_HEMOSTAT = 2,
		TOOL_CROWBAR = 2.5,
		/obj/item/kitchen/fork = 5,
	)
	time = 3.2 SECONDS
	preop_sound = 'sound/surgery/organ1.ogg'
	success_sound = 'sound/surgery/organ2.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT|SURGERY_CAVITY_WIDENED

/datum/surgery_operation/limb/undo_cavity_implant/all_required_strings()
	return list("operacja na klatce piersiowej") + ..()

/datum/surgery_operation/limb/undo_cavity_implant/get_default_radial_image()
	return image(icon = 'icons/obj/surgery.dmi', icon_state = "surgery_chest")

/datum/surgery_operation/limb/undo_cavity_implant/get_radial_options(obj/item/bodypart/chest/limb, obj/item/tool, operating_zone)
	// bez cache, ten sam przedmiot rzadko trafia się dwa razy
	var/datum/radial_menu_choice/option = new()
	option.name = "wyjęcie: [limb.cavity_item]"
	option.info = "Wyjmuje [limb.cavity_item] z jamy ciała pacjenta."
	var/image/option_image = get_generic_limb_radial_image(BODY_ZONE_CHEST)
	option_image.overlays += add_radial_overlays(limb.cavity_item)
	option.image = option_image
	return option

/datum/surgery_operation/limb/undo_cavity_implant/state_check(obj/item/bodypart/chest/limb)
	if(limb.body_zone != BODY_ZONE_CHEST)
		return FALSE
	// w przeciwieństwie do implantów przedmiot w jamie widać od razu
	if(isnull(limb.cavity_item))
		return FALSE
	return TRUE

/datum/surgery_operation/limb/undo_cavity_implant/on_preop(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz wyciągać [limb.cavity_item] z ciała [limb.owner] ([strefa_pl(limb.body_zone)])..."),
		span_notice("[surgeon] zaczyna wyciągać [limb.cavity_item] z ciała [limb.owner] ([strefa_pl(limb.body_zone)])."),
		span_notice("[surgeon] zaczyna coś wyciągać z ciała [limb.owner] ([strefa_pl(limb.body_zone)])."),
	)
	display_pain(limb.owner, "Czujesz ostry ból ([strefa_pl(limb.body_zone)])!")

/datum/surgery_operation/limb/undo_cavity_implant/on_success(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	if(isnull(limb.cavity_item)) // ktoś mógł to wyjąć w trakcie
		display_results(
			surgeon,
			limb.owner,
			span_warning("Nie znajdujesz niczego w ciele [limb.owner] ([strefa_pl(limb.body_zone)])."),
			span_warning("[surgeon] nie znajduje niczego w ciele [limb.owner]."),
			span_warning("[surgeon] nie znajduje niczego w ciele [limb.owner]."),
		)
		return

	var/obj/item/implant = limb.cavity_item
	limb.cavity_item = null
	limb.remove_surgical_state(SURGERY_CAVITY_WIDENED)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Wyciągasz [implant] z ciała [limb.owner] ([strefa_pl(limb.body_zone)])."),
		span_notice("[surgeon] wyciąga [implant] z ciała [limb.owner] ([strefa_pl(limb.body_zone)])!"),
		span_notice("[surgeon] wyciąga [implant.w_class > WEIGHT_CLASS_SMALL ? implant : "coś"] z ciała [limb.owner] ([strefa_pl(limb.body_zone)])!"),
	)
	display_pain(limb.owner, "Czujesz, jak ktoś coś z ciebie wyciąga!")
	surgeon.put_in_hands(implant)
