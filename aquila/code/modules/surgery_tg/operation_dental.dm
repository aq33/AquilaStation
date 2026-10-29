// AQUILA - tg code/modules/surgery/operations/operation_dental.dm
// Implant zęba (stara wersja: code/modules/surgery/dental_implant.dm). Zostaje nasze zachowanie: pigułka trafia do
// pacjenta (nie do głowy, tak liczą to dismemberment.dm i head.dm), akcja /datum/action/item_action/hands_free/activate_pill,
// operację można zrobić na sobie, po wciśnięciu pigułki rany się zasklepiają (cauterise_wounds), bez limitu zębów
// (u nas głowa nie liczy zębów). Z tg doszło wyjmowanie implantu (hemostat albo ręka, latarka w ręku pomaga).
// Jak w tg potrzebna jest odciągnięta skóra i nawiercona kość (stara wersja wymagała tylko wiercenia).
// Kroki przed implantem (nacięcie, odciągnięcie, zaciśnięcie, nawiercenie) w strefie ust też da się zrobić na sobie
// (self_operable_zones w operation_generic.dm), bo stara wersja była cała do zrobienia samemu.

/datum/surgery_operation/limb/add_dental_implant
	name = "implant zęba"
	desc = "Wciska pigułkę w ząb pacjenta. Pacjent może ją potem rozgryźć."
	operation_flags = OPERATION_SELF_OPERABLE
	implements = list(
		/obj/item/reagent_containers/pill = 1,
	)
	time = 1.6 SECONDS
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_BONE_DRILLED
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED

/datum/surgery_operation/limb/add_dental_implant/all_required_strings()
	return list("operacja na: [strefa_pl(BODY_ZONE_PRECISE_MOUTH)]") + ..()

/datum/surgery_operation/limb/add_dental_implant/get_default_radial_image()
	return get_item_radial_image(/obj/item/reagent_containers/pill)

/datum/surgery_operation/limb/add_dental_implant/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, tool, operated_zone)
	return operated_zone == BODY_ZONE_PRECISE_MOUTH && (!isitem(tool) || surgeon.canUnEquip(tool))

/datum/surgery_operation/limb/add_dental_implant/state_check(obj/item/bodypart/limb)
	return limb.body_zone == BODY_ZONE_HEAD

/datum/surgery_operation/limb/add_dental_implant/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz wciskać [tool] w [strefa_pl(BODY_ZONE_PRECISE_MOUTH, TRUE)] [limb.owner]..."),
		span_notice("[surgeon] zaczyna wciskać [tool] w [strefa_pl(BODY_ZONE_PRECISE_MOUTH, TRUE)] [limb.owner]."),
		span_notice("[surgeon] zaczyna coś wciskać w [strefa_pl(BODY_ZONE_PRECISE_MOUTH, TRUE)] [limb.owner]."),
	)
	display_pain(limb.owner, "Ktoś wciska ci coś w zęby!")

/datum/surgery_operation/limb/add_dental_implant/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/reagent_containers/pill/tool, list/operation_args)
	var/mob/living/carbon/patient = limb.owner
	patient.cauterise_wounds()
	if(!surgeon.transferItemToLoc(tool, patient, TRUE))
		return

	var/datum/action/item_action/hands_free/activate_pill/pill_action = new(tool)
	pill_action.button.name = "Activate [tool.name]"
	pill_action.target = tool
	pill_action.Grant(patient) // pigułka nie leży w slocie, więc pacjent nie dostaje akcji sam

	display_results(
		surgeon,
		patient,
		span_notice("Wciskasz [tool] w [strefa_pl(BODY_ZONE_PRECISE_MOUTH, TRUE)] [patient]."),
		span_notice("[surgeon] wciska [tool] w [strefa_pl(BODY_ZONE_PRECISE_MOUTH, TRUE)] [patient]!"),
		span_notice("[surgeon] wciska coś w [strefa_pl(BODY_ZONE_PRECISE_MOUTH, TRUE)] [patient]!"),
	)

/datum/surgery_operation/limb/remove_dental_implant
	name = "wyjęcie implantu zęba"
	desc = "Wyjmuje pigułkę z zęba pacjenta."
	implements = list(
		TOOL_HEMOSTAT = 1,
		IMPLEMENT_HAND = 1,
	)
	time = 3.2 SECONDS
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_BONE_DRILLED
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED

/datum/surgery_operation/limb/remove_dental_implant/all_required_strings()
	return list("operacja na: [strefa_pl(BODY_ZONE_PRECISE_MOUTH)]") + ..()

/datum/surgery_operation/limb/remove_dental_implant/get_default_radial_image()
	return get_item_radial_image(/obj/item/hemostat)

/datum/surgery_operation/limb/remove_dental_implant/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, tool, operated_zone)
	return operated_zone == BODY_ZONE_PRECISE_MOUTH

/datum/surgery_operation/limb/remove_dental_implant/state_check(obj/item/bodypart/limb)
	return limb.body_zone == BODY_ZONE_HEAD

/datum/surgery_operation/limb/remove_dental_implant/get_time_modifiers(atom/movable/operating_on, mob/living/surgeon, tool)
	. = ..()
	for(var/obj/item/flashlight/light in surgeon.held_items)
		if(light.on) // widać lepiej
			. *= 0.8
			break

/datum/surgery_operation/limb/remove_dental_implant/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz szukać implantów w zębach [limb.owner]..."),
		span_notice("[surgeon] zaczyna zaglądać [limb.owner] do ust."),
		span_notice("[surgeon] zaczyna oglądać zęby [limb.owner]."),
	)
	display_pain(limb.owner, "Czujesz palce grzebiące ci w zębach.")

/datum/surgery_operation/limb/remove_dental_implant/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/mob/living/carbon/patient = limb.owner
	var/list/pill_actions = list()
	for(var/datum/action/item_action/hands_free/activate_pill/pill_action in patient.actions)
		if(pill_action.target?.loc == patient)
			pill_actions += pill_action
	if(!length(pill_actions))
		display_results(
			surgeon,
			patient,
			span_notice("Nie znajdujesz żadnych implantów w zębach [patient]."),
			span_notice("[surgeon] nie znajduje żadnych implantów w zębach [patient]."),
			span_notice("[surgeon] kończy oglądać zęby [patient]."),
		)
		return

	var/datum/action/item_action/hands_free/activate_pill/picked_action = pick(pill_actions)
	var/obj/item/yoinked = picked_action.target
	qdel(picked_action)
	surgeon.put_in_hands(yoinked)
	display_results(
		surgeon,
		patient,
		span_notice("Ostrożnie wyjmujesz [yoinked] z zębów [patient]."),
		span_notice("[surgeon] ostrożnie wyjmuje [yoinked] z zębów [patient]."),
		span_notice("[surgeon] ostrożnie wyjmuje coś z zębów [patient]."),
	)
