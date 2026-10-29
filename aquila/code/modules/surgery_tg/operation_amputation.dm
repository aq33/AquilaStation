// AQUILA - tg code/modules/surgery/operations/operation_amputation.dm
// Amputacja (stara wersja: code/modules/surgery/amputation.dm). Zostaje z naszej: można ją zrobić na sobie
// i po odcięciu kikut przestaje krwawić (cauterise_wounds). Pominięte z tg: drewniane protezy (BODYTYPE_PEG),
// nożyce i ząbkowana łopata (nie mamy), nastrój TRAIT_MORBID.

/datum/surgery_operation/limb/amputate
	name = "amputacja kończyny"
	rnd_name = "Dezartykulacja (amputacja)"
	desc = "Odcina kończynę od ciała pacjenta."
	operation_flags = OPERATION_MORBID | OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE | OPERATION_SELF_OPERABLE
	required_bodytype = ~BODYTYPE_ROBOTIC
	implements = list(
		TOOL_SAW = 1,
		TOOL_SCALPEL = 1,
		/obj/item/melee/arm_blade = 1.25,
		/obj/item/fireaxe = 2,
		/obj/item/hatchet = 2.5,
		/obj/item/kitchen/knife/butcher = 4,
	)
	time = 6.4 SECONDS
	preop_sound = list(
		/obj/item/circular_saw = 'sound/surgery/saw.ogg',
		/obj/item = 'sound/surgery/scalpel1.ogg',
	)
	success_sound = 'sound/surgery/organ2.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_BONE_SAWED
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED

/datum/surgery_operation/limb/amputate/get_recommended_tool()
	return TOOL_SAW

/datum/surgery_operation/limb/amputate/get_default_radial_image()
	return image(icon = 'icons/obj/surgery.dmi', icon_state = "saw")

/datum/surgery_operation/limb/amputate/state_check(obj/item/bodypart/limb)
	if(limb.body_zone == BODY_ZONE_CHEST)
		return FALSE
	if(HAS_TRAIT(limb.owner, TRAIT_NODISMEMBER))
		return FALSE
	return TRUE

/datum/surgery_operation/limb/amputate/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz odcinać [FORMAT_LIMB_OWNER(limb)]..."),
		span_notice("[surgeon] zaczyna odcinać [FORMAT_LIMB_OWNER(limb)]!"),
		span_notice("[surgeon] zaczyna odcinać [FORMAT_LIMB_OWNER(limb)] za pomocą [tool]!"),
	)
	display_pain(limb.owner, "Czujesz potworny ból w stawie ([strefa_pl(limb.body_zone)])!")

/datum/surgery_operation/limb/amputate/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/mob/living/carbon/patient = limb.owner
	display_results(
		surgeon,
		patient,
		span_notice("Odcinasz [FORMAT_LIMB_OWNER(limb)]."),
		span_notice("[surgeon] odcina [FORMAT_LIMB_OWNER(limb)]!"),
		span_notice("[surgeon] kończy odcinać [FORMAT_LIMB_OWNER(limb)]."),
	)
	display_pain(patient, "Przestajesz czuć [strefa_pl(limb.body_zone, TRUE)]!")
	limb.drop_limb()
	patient?.cauterise_wounds()

/// Rozkręcenie protezy
/datum/surgery_operation/limb/amputate/mechanic
	name = "demontaż kończyny"
	rnd_name = "Demontaż (amputacja)"
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = OPERATION_MORBID | OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE | OPERATION_SELF_OPERABLE | OPERATION_MECHANIC
	implements = list(
		TOOL_WRENCH = 1,
		TOOL_CROWBAR = 1,
		TOOL_SCALPEL = 2,
		TOOL_SAW = 2,
	)
	time = 2 SECONDS
	preop_sound = 'sound/items/ratchet.ogg'
	success_sound = 'sound/machines/doorclick.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN

/datum/surgery_operation/limb/amputate/mechanic/state_check(obj/item/bodypart/limb)
	// głowa tylko po odkręceniu szkieletu, żeby nikt jej nie zdjął przez pomyłkę
	return ..() && (limb.body_zone != BODY_ZONE_HEAD || LIMB_HAS_SURGERY_STATE(limb, SURGERY_BONE_SAWED))

/datum/surgery_operation/limb/amputate/mechanic/any_required_strings()
	return ..() + list(
		"przy głowie szkielet MUSI być odkręcony",
		"przy innych kończynach stan szkieletu nie ma znaczenia",
	)

/datum/surgery_operation/limb/amputate/mechanic/get_recommended_tool()
	return "[TOOL_WRENCH] / [TOOL_SAW]"
