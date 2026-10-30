// AQUILA - tg code/modules/surgery/operations/operation_bone_repair.dm
// Operacje kości na naszych lekkich ranach (aquila/code/modules/wounds/): zwichnięcie (/blunt/dislocation),
// pęknięcie (/blunt/fracture, w tg "hairline"), złamanie otwarte (/blunt/compound) i pęknięcie czaszki (/cranial_fissure).
// Stare wersje: nastawienie kości + sklejenie w wounds/treatment.dm, rekonstrukcja czaszki w wounds/cranial_fissure.dm.
// Zostaje z naszej: kość nastawia się też retraktorem, hemostatem, łomem i kluczem (gorzej), czaszkę składa się też
// bonesetterem. Pominięte z tg: TRAIT_WOUND_SCANNED (skrócenie czasu po skanie rany, nie mamy).

/datum/wound/blunt/compound
	/// Kość złamania otwartego nastawiona operacyjnie, czeka na żel albo taśmę (tg: reset)
	var/reset = FALSE

/datum/wound/cranial_fissure
	/// Odłamki usunięte, czaszkę można złożyć (tg: prepped)
	var/prepped = FALSE

/// Nastawienie zwichnięcia na stole
/datum/surgery_operation/limb/repair_dislocation
	name = "nastawienie zwichnięcia"
	desc = "Nastawia zwichnięty staw. Jak nastawianie ręką, ale szybciej i pewniej, bo na stole."
	operation_flags = OPERATION_PRIORITY_NEXT_STEP | OPERATION_NO_PATIENT_REQUIRED | OPERATION_AFFECTS_MOOD | OPERATION_STANDING_ALLOWED | OPERATION_IGNORE_CLOTHES
	implements = list(
		TOOL_BONESET = 1,
		TOOL_CROWBAR = 2,
		IMPLEMENT_HAND = 5,
	)
	time = 2.4 SECONDS

/datum/surgery_operation/limb/repair_dislocation/get_default_radial_image()
	return get_item_radial_image(/obj/item/bonesetter)

/datum/surgery_operation/limb/repair_dislocation/all_required_strings()
	return list("kończyna musi być zwichnięta") + ..()

/datum/surgery_operation/limb/repair_dislocation/state_check(obj/item/bodypart/limb)
	return !isnull(locate(/datum/wound/blunt/dislocation) in limb.wounds)

/datum/surgery_operation/limb/repair_dislocation/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz nastawiać zwichnięcie ([FORMAT_LIMB_OWNER(limb)])..."),
		span_notice("[surgeon] zaczyna nastawiać zwichnięcie ([FORMAT_LIMB_OWNER(limb)]) za pomocą [tool]."),
		span_notice("[surgeon] zaczyna nastawiać zwichnięcie ([FORMAT_LIMB_OWNER(limb)])."),
	)
	display_pain(limb.owner, "Staw ([strefa_pl(limb.body_zone)]) pulsuje bólem!")

/datum/surgery_operation/limb/repair_dislocation/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	for(var/datum/wound/blunt/dislocation/dislocation in limb.wounds)
		qdel(dislocation)

	display_results(
		surgeon,
		limb.owner,
		span_notice("Nastawiasz zwichnięcie ([FORMAT_LIMB_OWNER(limb)])."),
		span_notice("[surgeon] nastawia zwichnięcie ([FORMAT_LIMB_OWNER(limb)])!"),
		span_notice("[surgeon] nastawia zwichnięcie ([FORMAT_LIMB_OWNER(limb)])!"),
	)
	display_pain(limb.owner, "[capitalize(strefa_pl(limb.body_zone))] od razu boli mniej!")

/datum/surgery_operation/limb/repair_dislocation/on_failure(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_warning("Nie udaje ci się nastawić zwichnięcia ([FORMAT_LIMB_OWNER(limb)]), tylko pogarszasz sprawę!"),
		span_warning("[surgeon] nie nastawia zwichnięcia ([FORMAT_LIMB_OWNER(limb)]), tylko pogarsza sprawę!"),
		span_warning("[surgeon] nie nastawia zwichnięcia ([FORMAT_LIMB_OWNER(limb)])!"),
	)
	display_pain(limb.owner, "Ból ([strefa_pl(limb.body_zone)]) się nasila!")
	limb.receive_damage(25)

/// Pęknięcie kości (tg: hairline fracture): jeden krok, bonesetter albo żel/taśma
/datum/surgery_operation/limb/repair_hairline
	name = "zespolenie pękniętej kości"
	desc = "Naprawia pękniętą kość pacjenta."
	operation_flags = OPERATION_PRIORITY_NEXT_STEP | OPERATION_NO_PATIENT_REQUIRED
	implements = list(
		TOOL_BONESET = 1,
		/obj/item/stack/medical/bone_gel = 1,
		/obj/item/stack/sticky_tape/surgical = 1,
		/obj/item/stack/sticky_tape/super = 2,
		/obj/item/stack/sticky_tape = 3.33,
	)
	time = 4 SECONDS
	preop_sound = 'sound/surgery/retractor1.ogg'
	success_sound = 'sound/surgery/retractor2.ogg'
	any_surgery_states_required = ALL_SURGERY_SKIN_STATES

/datum/surgery_operation/limb/repair_hairline/get_default_radial_image()
	return get_item_radial_image(/obj/item/bonesetter)

/datum/surgery_operation/limb/repair_hairline/all_required_strings()
	return list("kość musi być pęknięta") + ..()

/datum/surgery_operation/limb/repair_hairline/state_check(obj/item/bodypart/limb)
	return !isnull(locate(/datum/wound/blunt/fracture) in limb.wounds)

/datum/surgery_operation/limb/repair_hairline/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz zespalać kość ([FORMAT_LIMB_OWNER(limb)])..."),
		span_notice("[surgeon] zaczyna zespalać kość ([FORMAT_LIMB_OWNER(limb)]) za pomocą [tool]."),
		span_notice("[surgeon] zaczyna zespalać kość ([FORMAT_LIMB_OWNER(limb)])."),
	)
	display_pain(limb.owner, "Kość ([strefa_pl(limb.body_zone)]) pulsuje bólem!")

/datum/surgery_operation/limb/repair_hairline/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/datum/wound/blunt/fracture/fracture = locate() in limb.wounds
	qdel(fracture)

	display_results(
		surgeon,
		limb.owner,
		span_notice("Zespalasz kość ([FORMAT_LIMB_OWNER(limb)])."),
		span_notice("[surgeon] zespala kość ([FORMAT_LIMB_OWNER(limb)])!"),
		span_notice("[surgeon] kończy operację ([FORMAT_LIMB_OWNER(limb)])."),
	)

/// Złamanie otwarte, krok 1: nastawienie kości
/datum/surgery_operation/limb/reset_compound
	name = "nastawienie złamania otwartego"
	desc = "Nastawia kość przy złamaniu otwartym, przygotowując ją do sklejenia."
	operation_flags = OPERATION_PRIORITY_NEXT_STEP | OPERATION_NO_PATIENT_REQUIRED
	implements = list(
		TOOL_BONESET = 1,
		/obj/item/stack/sticky_tape/surgical = 1.66,
		TOOL_RETRACTOR = 1.66,
		TOOL_HEMOSTAT = 2.2,
		/obj/item/stack/sticky_tape/super = 2.5,
		TOOL_CROWBAR = 3.33,
		/obj/item/stack/sticky_tape = 5,
		TOOL_WRENCH = 5,
	)
	time = 6 SECONDS
	preop_sound = 'sound/surgery/retractor1.ogg'
	success_sound = 'sound/surgery/retractor2.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED

/datum/surgery_operation/limb/reset_compound/get_default_radial_image()
	return get_item_radial_image(/obj/item/bonesetter)

/datum/surgery_operation/limb/reset_compound/all_required_strings()
	return list("kończyna musi mieć złamanie otwarte") + ..()

/datum/surgery_operation/limb/reset_compound/state_check(obj/item/bodypart/limb)
	var/datum/wound/blunt/compound/fracture = locate() in limb.wounds
	if(isnull(fracture) || fracture.reset)
		return FALSE
	return TRUE

/datum/surgery_operation/limb/reset_compound/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz nastawiać kość ([FORMAT_LIMB_OWNER(limb)])..."),
		span_notice("[surgeon] zaczyna nastawiać kość ([FORMAT_LIMB_OWNER(limb)]) za pomocą [tool]."),
		span_notice("[surgeon] zaczyna nastawiać kość ([FORMAT_LIMB_OWNER(limb)])."),
	)
	display_pain(limb.owner, "Ból ([strefa_pl(limb.body_zone)]) jest nie do zniesienia!")

/datum/surgery_operation/limb/reset_compound/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/datum/wound/blunt/compound/fracture = locate() in limb.wounds
	fracture?.reset = TRUE

	display_results(
		surgeon,
		limb.owner,
		span_notice("Nastawiasz kość ([FORMAT_LIMB_OWNER(limb)])."),
		span_notice("[surgeon] nastawia kość ([FORMAT_LIMB_OWNER(limb)]) za pomocą [tool]!"),
		span_notice("[surgeon] nastawia kość ([FORMAT_LIMB_OWNER(limb)])!"),
	)

/// Złamanie otwarte, krok 2: sklejenie nastawionej kości
/datum/surgery_operation/limb/repair_compound
	name = "sklejenie złamania otwartego"
	desc = "Skleja nastawioną kość przy złamaniu otwartym."
	operation_flags = OPERATION_PRIORITY_NEXT_STEP | OPERATION_NO_PATIENT_REQUIRED
	implements = list(
		/obj/item/stack/medical/bone_gel = 1,
		/obj/item/stack/sticky_tape/surgical = 1,
		/obj/item/stack/sticky_tape/super = 2,
		/obj/item/stack/sticky_tape = 3.33,
	)
	time = 4 SECONDS
	any_surgery_states_required = ALL_SURGERY_SKIN_STATES

/datum/surgery_operation/limb/repair_compound/get_default_radial_image()
	return get_item_radial_image(/obj/item/stack/medical/bone_gel)

/datum/surgery_operation/limb/repair_compound/all_required_strings()
	return list("złamanie otwarte musi być nastawione") + ..()

/datum/surgery_operation/limb/repair_compound/state_check(obj/item/bodypart/limb)
	var/datum/wound/blunt/compound/fracture = locate() in limb.wounds
	if(isnull(fracture) || !fracture.reset)
		return FALSE
	return TRUE

/datum/surgery_operation/limb/repair_compound/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz sklejać kość ([FORMAT_LIMB_OWNER(limb)]) za pomocą [tool]..."),
		span_notice("[surgeon] zaczyna sklejać kość ([FORMAT_LIMB_OWNER(limb)]) za pomocą [tool]."),
		span_notice("[surgeon] zaczyna sklejać kość ([FORMAT_LIMB_OWNER(limb)])."),
	)
	display_pain(limb.owner, "Kość ([strefa_pl(limb.body_zone)]) piecze, jakby ktoś polał ją kwasem!")

/datum/surgery_operation/limb/repair_compound/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/datum/wound/blunt/compound/fracture = locate() in limb.wounds
	qdel(fracture)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Sklejasz kość ([FORMAT_LIMB_OWNER(limb)])."),
		span_notice("[surgeon] skleja kość ([FORMAT_LIMB_OWNER(limb)]) za pomocą [tool]!"),
		span_notice("[surgeon] kończy operację ([FORMAT_LIMB_OWNER(limb)])."),
	)

/// Pęknięcie czaszki, krok 1: usunięcie odłamków
/datum/surgery_operation/limb/prepare_cranium_repair
	name = "usunięcie odłamków czaszki"
	desc = "Usuwa odłamki kości z pękniętej czaszki, przygotowując ją do złożenia."
	operation_flags = OPERATION_PRIORITY_NEXT_STEP | OPERATION_NO_PATIENT_REQUIRED
	implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_WIRECUTTER = 2.5,
		TOOL_SCREWDRIVER = 2.5,
	)
	time = 2.4 SECONDS
	preop_sound = 'sound/surgery/hemostat1.ogg'

/datum/surgery_operation/limb/prepare_cranium_repair/get_default_radial_image()
	return image(icon = 'icons/obj/surgery.dmi', icon_state = "hemostat")

/datum/surgery_operation/limb/prepare_cranium_repair/all_required_strings()
	return list("czaszka musi być pęknięta") + ..()

/datum/surgery_operation/limb/prepare_cranium_repair/state_check(obj/item/bodypart/limb)
	var/datum/wound/cranial_fissure/fissure = locate() in limb.wounds
	if(isnull(fissure) || fissure.prepped)
		return FALSE
	return TRUE

/datum/surgery_operation/limb/prepare_cranium_repair/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz wybierać drobne odłamki czaszki [limb.owner || limb]..."),
		span_notice("[surgeon] zaczyna wybierać drobne odłamki czaszki [limb.owner || limb]..."),
		span_notice("[surgeon] zaczyna grzebać w głowie [limb.owner || limb]..."),
	)
	display_pain(limb.owner, "Czujesz się, jakby ktoś kłuł ci mózg odłamkami szkła!")

/datum/surgery_operation/limb/prepare_cranium_repair/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	var/datum/wound/cranial_fissure/fissure = locate() in limb.wounds
	fissure?.prepped = TRUE

/// Pęknięcie czaszki, krok 2: złożenie czaszki
/datum/surgery_operation/limb/repair_cranium
	name = "rekonstrukcja czaszki"
	desc = "Składa pękniętą czaszkę pacjenta."
	operation_flags = OPERATION_PRIORITY_NEXT_STEP | OPERATION_NO_PATIENT_REQUIRED
	implements = list(
		/obj/item/stack/medical/bone_gel = 1,
		/obj/item/stack/sticky_tape/surgical = 1,
		TOOL_BONESET = 1.5,
		/obj/item/stack/sticky_tape/super = 2,
		/obj/item/stack/sticky_tape = 3.33,
	)
	time = 4 SECONDS
	preop_sound = 'sound/surgery/retractor1.ogg'
	success_sound = 'sound/surgery/retractor2.ogg'

/datum/surgery_operation/limb/repair_cranium/get_default_radial_image()
	return get_item_radial_image(/obj/item/stack/medical/bone_gel)

/datum/surgery_operation/limb/repair_cranium/all_required_strings()
	return list("odłamki muszą być usunięte z pękniętej czaszki") + ..()

/datum/surgery_operation/limb/repair_cranium/state_check(obj/item/bodypart/limb)
	var/datum/wound/cranial_fissure/fissure = locate() in limb.wounds
	if(isnull(fissure) || !fissure.prepped)
		return FALSE
	return TRUE

/datum/surgery_operation/limb/repair_cranium/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz składać rozłupaną czaszkę [limb.owner || limb]..."),
		span_notice("[surgeon] zaczyna składać czaszkę [limb.owner || limb] za pomocą [tool]."),
		span_notice("[surgeon] zaczyna operować głowę [limb.owner || limb]."),
	)
	display_pain(limb.owner, "Czujesz, jak kawałki czaszki ocierają się o mózg!")

/datum/surgery_operation/limb/repair_cranium/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/datum/wound/cranial_fissure/fissure = locate() in limb.wounds
	qdel(fissure)

	display_results(
		surgeon,
		limb.owner,
		span_notice("Składasz czaszkę [limb.owner || limb]."),
		span_notice("[surgeon] składa czaszkę [limb.owner || limb] za pomocą [tool]."),
		span_notice("[surgeon] kończy operację głowy [limb.owner || limb]."),
	)
