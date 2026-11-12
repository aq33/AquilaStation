// AQUILA - operations on a broken spine (aquila/code/modules/wounds/spinal.dm), in the pattern of the skull
// reconstruction in operation_bone_repair.dm: step one sets the vertebrae in place, step two fuses them.
// After the second step the nerves regrow by themselves (the wound heals over a few minutes).

/// Broken spine, step 1: setting the vertebrae
/datum/surgery_operation/limb/stabilize_spine
	name = "stabilizacja kręgosłupa"
	catalog_sections = list(SURGERY_SECTION_CHEST, SURGERY_SECTION_WOUNDS)
	desc = "Nastawia złamane kręgi, żeby nie uciskały rdzenia. Przygotowuje kręgosłup do zespolenia."
	operation_flags = OPERATION_PRIORITY_NEXT_STEP
	implements = list(
		TOOL_BONESET = 1,
		TOOL_RETRACTOR = 2,
		TOOL_CROWBAR = 3,
	)
	time = 5 SECONDS
	preop_sound = 'sound/surgery/retractor1.ogg'
	success_sound = 'sound/surgery/retractor2.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED

/datum/surgery_operation/limb/stabilize_spine/get_default_radial_image()
	return get_item_radial_image(/obj/item/bonesetter)

/datum/surgery_operation/limb/stabilize_spine/all_required_strings()
	return list("kręgosłup musi być złamany") + ..()

/datum/surgery_operation/limb/stabilize_spine/state_check(obj/item/bodypart/limb)
	var/datum/wound/spinal/fracture/fracture = locate() in limb.wounds
	return fracture && !fracture.stabilized

/datum/surgery_operation/limb/stabilize_spine/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz nastawiać złamane kręgi [limb.owner]..."),
		span_notice("[surgeon] zaczyna nastawiać kręgosłup [limb.owner] za pomocą [tool]."),
		span_notice("[surgeon] zaczyna operować plecy [limb.owner]."),
	)
	display_pain(limb.owner, "Kręgosłup przeszywa ból, jakby ktoś wbijał w niego gwóźdź!")

/datum/surgery_operation/limb/stabilize_spine/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/datum/wound/spinal/fracture/fracture = locate() in limb.wounds
	fracture?.stabilize()
	display_results(
		surgeon,
		limb.owner,
		span_notice("Nastawiasz kręgi [limb.owner]. Teraz trzeba je zespolić."),
		span_notice("[surgeon] nastawia kręgosłup [limb.owner]."),
		span_notice("[surgeon] kończy pierwszy etap operacji pleców [limb.owner]."),
	)

/datum/surgery_operation/limb/stabilize_spine/on_failure(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_warning("Kręgi wyślizgują ci się spod narzędzia i trą o rdzeń!"),
		span_warning("[surgeon] nie trafia w kręgi [limb.owner]!"),
		span_warning("[surgeon] nie trafia w kręgi [limb.owner]!"),
	)
	display_pain(limb.owner, "Kręgosłup płonie bólem!")
	limb.receive_damage(15)

/// Broken spine, step 2: fusing the vertebrae
/datum/surgery_operation/limb/fuse_spine
	name = "zespolenie kręgów"
	catalog_sections = list(SURGERY_SECTION_CHEST, SURGERY_SECTION_WOUNDS)
	desc = "Zespala nastawione kręgi. Po operacji nerwy odrastają przez kilka minut, szybciej z mannitolem albo neuryną."
	operation_flags = OPERATION_PRIORITY_NEXT_STEP
	implements = list(
		/obj/item/stack/medical/bone_gel = 1,
		/obj/item/stack/sticky_tape/surgical = 1,
		/obj/item/stack/sticky_tape/super = 2,
		/obj/item/stack/sticky_tape = 3.33,
	)
	time = 5 SECONDS
	preop_sound = 'sound/surgery/retractor1.ogg'
	success_sound = 'sound/surgery/retractor2.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED

/datum/surgery_operation/limb/fuse_spine/get_default_radial_image()
	return get_item_radial_image(/obj/item/stack/medical/bone_gel)

/datum/surgery_operation/limb/fuse_spine/all_required_strings()
	return list("złamany kręgosłup musi być ustabilizowany") + ..()

/datum/surgery_operation/limb/fuse_spine/state_check(obj/item/bodypart/limb)
	var/datum/wound/spinal/fracture/fracture = locate() in limb.wounds
	return fracture && fracture.stabilized && !fracture.treated

/datum/surgery_operation/limb/fuse_spine/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz zespalać kręgi [limb.owner] za pomocą [tool]..."),
		span_notice("[surgeon] zaczyna zespalać kręgosłup [limb.owner] za pomocą [tool]."),
		span_notice("[surgeon] zaczyna operować plecy [limb.owner]."),
	)
	display_pain(limb.owner, "Plecy pieką, jakby ktoś wylał na nie kwas!")

/datum/surgery_operation/limb/fuse_spine/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/datum/wound/spinal/fracture/fracture = locate() in limb.wounds
	fracture?.fuse()
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zespalasz kręgi [limb.owner]. Nerwy potrzebują kilku minut, żeby odrosnąć."),
		span_notice("[surgeon] zespala kręgosłup [limb.owner]."),
		span_notice("[surgeon] kończy operację pleców [limb.owner]."),
	)
