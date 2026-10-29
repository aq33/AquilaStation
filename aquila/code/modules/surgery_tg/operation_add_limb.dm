// AQUILA - tg code/modules/surgery/operations/operation_add_limb.dm
// Przyszycie kończyny albo przedmiotu w miejsce brakującej (stara wersja: code/modules/surgery/prosthetic_replacement.dm).
// U nas nie ma kikutów: operacja celuje w pustą strefę, a działa przez przygotowaną klatkę piersiową (targets_missing_limb).
// Zostaje z naszej wersji: kończyny z pojemnika na organy, małpa przyjmie tylko organiczną kończynę małpy, człowiek nie
// przyjmie kończyny zwierzęcej, odrzut 10 (obca rasa 30) toksyn dla organicznych, piła łańcuchowa i ostrze ramienia
// jako zamontowana broń, oozeling nie przyjmuje kończyn, krwawienie ustaje po przyszyciu.

#define OPERATION_REJECTION_DAMAGE "tox_damage"

/datum/surgery_operation/limb/prosthetic_replacement
	name = "przyszycie kończyny"
	desc = "Zastępuje brakującą kończynę protezą albo (w przypadku ręki) dowolnym pasującym przedmiotem."
	implements = list(
		/obj/item/bodypart = 1,
		/obj/item/organ_storage = 1,
		/obj/item = 1,
	)
	time = 3.2 SECONDS
	operation_flags = OPERATION_STANDING_ALLOWED | OPERATION_PRIORITY_NEXT_STEP | OPERATION_NOTABLE | OPERATION_IGNORE_CLOTHES | OPERATION_SELF_OPERABLE
	targets_missing_limb = TRUE
	allow_stumps = TRUE
	/// Przedmioty, które zawsze mogą zastąpić rękę, nawet gdy nie spełniają innych warunków
	var/list/always_accepted_prosthetics = list(
		/obj/item/chainsaw, // klasyk, inaczej za duża
		/obj/item/melee/synthetic_arm_blade, // też za duże
		/obj/item/food/pizzaslice, // he's turning her into a papa john's
	)
	/// Opcje menu radialnego dla każdego typu
	VAR_PRIVATE/list/cached_prosthetic_options

/datum/surgery_operation/limb/prosthetic_replacement/get_recommended_tool()
	return "dowolna kończyna / dowolny przedmiot"

/datum/surgery_operation/limb/prosthetic_replacement/get_any_tool()
	return "Dowolny przedmiot, który może zastąpić rękę"

/datum/surgery_operation/limb/prosthetic_replacement/all_required_strings()
	. = ..()
	. += "kończyny w tej strefie musi brakować"
	. += "klatka piersiowa musi być przygotowana do operacji"

/datum/surgery_operation/limb/prosthetic_replacement/any_required_strings()
	return list("ręce mogą dostać dowolny pasujący przedmiot zamiast kończyny") + ..()

/// AQUILA - kończyna z pojemnika na organy albo sam przedmiot
/datum/surgery_operation/limb/prosthetic_replacement/proc/get_attached_item(obj/item/tool)
	if(istype(tool, /obj/item/organ_storage))
		if(!length(tool.contents))
			return null
		var/obj/item/stored = tool.contents[1]
		return isbodypart(stored) ? stored : null
	return tool

/datum/surgery_operation/limb/prosthetic_replacement/get_radial_options(obj/item/bodypart/chest/chest, obj/item/tool, operating_zone)
	var/obj/item/attached = get_attached_item(tool)
	var/datum/radial_menu_choice/option = LAZYACCESS(cached_prosthetic_options, attached.type)
	if(!option)
		option = new()
		option.name = "przyszycie: [initial(attached.name)]"
		option.info = "Zastępuje brakującą kończynę pacjenta: [initial(attached.name)]."
		option.image = image(attached.type)
		LAZYSET(cached_prosthetic_options, attached.type, option)

	return option

/datum/surgery_operation/limb/prosthetic_replacement/snowflake_check_availability(obj/item/bodypart/chest/chest, mob/living/surgeon, obj/item/tool, operated_zone)
	if(!surgeon.canUnEquip(tool))
		return FALSE
	var/mob/living/carbon/patient = chest.owner
	if(!iscarbon(patient) || isoozeling(patient))
		return FALSE
	var/real_operated_zone = check_zone(operated_zone)
	var/obj/item/attached = get_attached_item(tool)
	if(isnull(attached))
		return FALSE
	if(isbodypart(attached))
		var/obj/item/bodypart/new_limb = attached
		if(real_operated_zone != new_limb.body_zone)
			return FALSE
		// małpa przyjmie tylko organiczną kończynę małpy, człowiek nie przyjmie zwierzęcej
		if(ismonkey(patient))
			if(!IS_ORGANIC_LIMB(new_limb) || new_limb.animal_origin != MONKEY_BODYPART)
				return FALSE
		else if(IS_ORGANIC_LIMB(new_limb) && ishuman(patient) && new_limb.animal_origin)
			return FALSE
	// przedmioty tylko zamiast rąk
	else if(real_operated_zone != BODY_ZONE_L_ARM && real_operated_zone != BODY_ZONE_R_ARM)
		return FALSE
	return TRUE

/datum/surgery_operation/limb/prosthetic_replacement/tool_check(obj/item/tool)
	var/obj/item/attached = get_attached_item(tool)
	if(isnull(attached))
		return FALSE
	if(attached.item_flags & (ABSTRACT|DROPDEL))
		return FALSE
	if(isbodypart(attached))
		return TRUE // to, do czego to służy
	if(is_type_in_list(attached, always_accepted_prosthetics))
		return TRUE // klasyki
	if(attached.w_class < WEIGHT_CLASS_NORMAL || attached.w_class > WEIGHT_CLASS_BULKY)
		return FALSE // za małe albo za duże na rękę
	var/datum/component/two_handed/two_handed = attached.GetComponent(/datum/component/two_handed)
	if(two_handed && (two_handed.wielded || two_handed.require_twohands))
		return FALSE // bez dziwnych przypadków, najpierw puść drugą ręką
	return TRUE

/datum/surgery_operation/limb/prosthetic_replacement/pre_preop(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	// zawsze pełne strefy ciała
	operation_args[OPERATION_TARGET_ZONE] = check_zone(operation_args[OPERATION_TARGET_ZONE])

/datum/surgery_operation/limb/prosthetic_replacement/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/obj/item/attached = get_attached_item(tool)
	var/target_zone = operation_args[OPERATION_TARGET_ZONE]
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz mocować [attached] do ciała [limb.owner] ([strefa_pl(target_zone)])..."),
		span_notice("[surgeon] zaczyna mocować [attached] do ciała [limb.owner] ([strefa_pl(target_zone)])."),
		span_notice("[surgeon] zaczyna coś mocować do ciała [limb.owner] ([strefa_pl(target_zone)])."),
	)
	display_pain(limb.owner, "Czujesz coś dziwnego tam, gdzie powinno być: [strefa_pl(target_zone)]!")

	operation_args[OPERATION_REJECTION_DAMAGE] = 0
	if(isbodypart(attached))
		var/obj/item/bodypart/new_limb = attached
		if(IS_ORGANIC_LIMB(new_limb))
			operation_args[OPERATION_REJECTION_DAMAGE] = 10
			if(ishuman(limb.owner))
				var/mob/living/carbon/human/human_patient = limb.owner
				if(human_patient.dna?.species?.id != new_limb.limb_id)
					operation_args[OPERATION_REJECTION_DAMAGE] = 30

/datum/surgery_operation/limb/prosthetic_replacement/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/mob/living/carbon/patient = limb.owner
	var/target_zone = operation_args[OPERATION_TARGET_ZONE]
	var/obj/item/attached = get_attached_item(tool)
	if(istype(tool, /obj/item/organ_storage))
		tool.icon_state = initial(tool.icon_state)
		tool.desc = initial(tool.desc)
		tool.cut_overlays()
	else if(!surgeon.temporarilyRemoveItemFromInventory(attached))
		to_chat(surgeon, span_warning("Nie potrafisz rozstać się z [attached]!"))
		return
	if(operation_args[OPERATION_REJECTION_DAMAGE] > 0)
		patient.adjustToxLoss(operation_args[OPERATION_REJECTION_DAMAGE])
	var/obj/item/bodypart/new_limb
	if(isbodypart(attached))
		new_limb = handle_bodypart(patient, surgeon, attached, target_zone)
	else if(istype(attached, /obj/item/chainsaw) || istype(attached, /obj/item/melee/synthetic_arm_blade))
		new_limb = handle_mounted_weapon(patient, surgeon, attached, target_zone)
	else
		new_limb = handle_arbitrary_prosthetic(patient, surgeon, attached, target_zone)
	if(isnull(new_limb))
		return
	patient.cauterise_wounds()
	// przygotowanie klatki obejmuje też nową kończynę, żeby dało się ją od razu dokręcić albo przymocować
	var/datum/status_effect/surgery_prepped/prep = patient.has_status_effect(/datum/status_effect/surgery_prepped) || null // u nas FALSE, gdy brak statusu
	prep?.track_surgery(new_limb.body_zone)

/datum/surgery_operation/limb/prosthetic_replacement/proc/handle_bodypart(mob/living/carbon/patient, mob/living/surgeon, obj/item/bodypart/bodypart_to_attach, target_zone)
	bodypart_to_attach.attach_limb(patient)
	display_results(
		surgeon,
		patient,
		span_notice("Udaje ci się wymienić [strefa_pl(target_zone, TRUE)] [patient]."),
		span_notice("[surgeon] pomyślnie wymienia [strefa_pl(target_zone, TRUE)] [patient] na [bodypart_to_attach]!"),
		span_notice("[surgeon] pomyślnie wymienia [strefa_pl(target_zone, TRUE)] [patient]!"),
	)
	display_pain(patient, "Znowu czujesz [strefa_pl(target_zone, TRUE)]!", TRUE)
	return bodypart_to_attach.owner == patient ? bodypart_to_attach : null

/// AQUILA - piły łańcuchowe i ostrza ramienia zostają zamontowaną bronią (jak w starej operacji)
/datum/surgery_operation/limb/prosthetic_replacement/proc/handle_mounted_weapon(mob/living/carbon/patient, mob/living/surgeon, obj/item/weapon, target_zone)
	var/obj/item/bodypart/new_limb = patient.newBodyPart(target_zone, FALSE, FALSE)
	new_limb.is_pseudopart = TRUE
	new_limb.attach_limb(patient)
	var/obj/item/new_arm
	if(istype(weapon, /obj/item/chainsaw/energy/doom))
		new_arm = new /obj/item/mounted_chainsaw/super(patient)
	else if(istype(weapon, /obj/item/chainsaw/energy))
		new_arm = new /obj/item/mounted_chainsaw/energy(patient)
	else if(istype(weapon, /obj/item/chainsaw))
		new_arm = new /obj/item/mounted_chainsaw/normal(patient)
	else
		new_arm = new /obj/item/melee/arm_blade(patient, TRUE, TRUE)
	display_results(
		surgeon,
		patient,
		span_notice("Mocujesz [weapon]."),
		span_notice("[surgeon] kończy mocować [weapon]!"),
		span_notice("[surgeon] kończy procedurę mocowania!"),
	)
	qdel(weapon)
	if(target_zone == BODY_ZONE_R_ARM)
		patient.put_in_r_hand(new_arm)
	else
		patient.put_in_l_hand(new_arm)
	return new_limb

/datum/surgery_operation/limb/prosthetic_replacement/proc/handle_arbitrary_prosthetic(mob/living/carbon/patient, mob/living/surgeon, obj/item/thing_to_attach, target_zone)
	SSblackbox.record_feedback("tally", "arbitrary_prosthetic", 1, initial(thing_to_attach.name))
	var/obj/item/bodypart/new_limb = patient.make_item_prosthetic(thing_to_attach, target_zone, PROSTHETIC_LOOSE_DROP_PROB)
	if(isnull(new_limb))
		thing_to_attach.forceMove(patient.drop_location())
		return null
	new_limb.add_surgical_state(SURGERY_PROSTHETIC_UNSECURED)
	display_results(
		surgeon,
		patient,
		span_notice("Mocujesz [thing_to_attach]."),
		span_notice("[surgeon] kończy mocować [thing_to_attach]!"),
		span_notice("[surgeon] kończy procedurę mocowania!"),
	)
	display_pain(patient, "Czujesz coś bardzo dziwnego, gdy [thing_to_attach] zajmuje miejsce ręki!", TRUE)
	return new_limb

#undef OPERATION_REJECTION_DAMAGE

/// Przedmiot w miejscu ręki trzyma się luźno, dopóki go nie przymocować
/datum/surgery_operation/limb/secure_arbitrary_prosthetic
	name = "przymocowanie protezy"
	desc = "Mocuje przedmiot zastępujący rękę, żeby nie odpadał przy zamachu."
	implements = list(
		/obj/item/stack/medical/suture = 1,
		/obj/item/stack/sticky_tape/surgical = 1.25,
		/obj/item/stack/sticky_tape/super = 1.25,
		/obj/item/stack/sticky_tape = 2,
	)
	time = 4.8 SECONDS
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_STANDING_ALLOWED | OPERATION_IGNORE_CLOTHES
	all_surgery_states_required = SURGERY_PROSTHETIC_UNSECURED

/datum/surgery_operation/limb/secure_arbitrary_prosthetic/get_default_radial_image()
	return get_item_radial_image(/obj/item/stack/medical/suture)

/datum/surgery_operation/limb/secure_arbitrary_prosthetic/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz mocować [limb] do ciała [limb.owner] przy pomocy [tool]..."),
		span_notice("[surgeon] zaczyna mocować [limb] do ciała [limb.owner] przy pomocy [tool]."),
		span_notice("[surgeon] zaczyna coś mocować do ciała [limb.owner]."),
	)
	display_pain(limb.owner, "Coś przyszywa ci ciało do protezy ([strefa_pl(limb.body_zone)])!", !IS_ORGANIC_LIMB(limb))

/datum/surgery_operation/limb/secure_arbitrary_prosthetic/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/datum/component/item_as_prosthetic_limb/prosthetic = limb.GetComponent(/datum/component/item_as_prosthetic_limb)
	prosthetic?.secure()
	limb.remove_surgical_state(SURGERY_PROSTHETIC_UNSECURED)
	display_results(
		surgeon,
		limb.owner,
		span_notice("[capitalize(limb.name)] trzyma się teraz pewnie."),
		span_notice("[surgeon] pewnie mocuje [limb] do ciała [limb.owner]!"),
		span_notice("[surgeon] kończy mocowanie!"),
	)
	display_pain(limb.owner, "Proteza trzyma się teraz pewnie!", !IS_ORGANIC_LIMB(limb))
	limb.owner?.cauterise_wounds()
