// AQUILA - tg code/modules/surgery/operations/operation_puncture.dm
// Naprawa ran kłutych na naszych ranach (aquila/code/modules/wounds/pierce.dm). U nas rana kłuta nie ma przepływu krwi
// jak w tg, tylko stopnie: każda para "zestawienie naczyń" + "zamknięcie naczyń" obniża ranę o jeden stopień
// (cauterized_into), jak jedno przypalenie, a najlżejszą usuwa. Starą kauteryzację (nacięcie, odciągnięcie, zamknięcie
// usuwa wszystkie rany kłute i cięte kończyny) robi teraz zamknięcie nacięcia po odciągniętej skórze (operation_generic.dm).

/datum/wound/pierce
	/// Naczynia zestawione operacyjnie, czekają na zamknięcie (tg: mend_state)
	var/mend_state = FALSE

/// Krok 1: zestawienie rozerwanych naczyń
/datum/surgery_operation/limb/repair_puncture
	name = "zestawienie naczyń"
	desc = "Zestawia rozerwane naczynia krwionośne przy ranie kłutej, przygotowując je do zamknięcia."
	implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_SCALPEL = 1.15,
		TOOL_WIRECUTTER = 2.5,
	)
	time = 3 SECONDS
	preop_sound = 'sound/surgery/hemostat1.ogg'
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_PRIORITY_NEXT_STEP | OPERATION_NO_PATIENT_REQUIRED
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT

/datum/surgery_operation/limb/repair_puncture/get_default_radial_image()
	return image(icon = 'icons/obj/surgery.dmi', icon_state = "hemostat")

/datum/surgery_operation/limb/repair_puncture/all_required_strings()
	return list("kończyna musi mieć ranę kłutą, jeszcze nieoperowaną") + ..()

/datum/surgery_operation/limb/repair_puncture/state_check(obj/item/bodypart/limb)
	var/datum/wound/pierce/pierce_wound = limb.get_wound(WOUND_PIERCE)
	if(isnull(pierce_wound) || pierce_wound.mend_state)
		return FALSE
	return TRUE

/datum/surgery_operation/limb/repair_puncture/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz zestawiać rozerwane naczynia ([FORMAT_LIMB_OWNER(limb)])..."),
		span_notice("[surgeon] zaczyna zestawiać rozerwane naczynia ([FORMAT_LIMB_OWNER(limb)]) za pomocą [tool]."),
		span_notice("[surgeon] zaczyna zestawiać rozerwane naczynia ([FORMAT_LIMB_OWNER(limb)])."),
	)
	display_pain(limb.owner, "Czujesz straszny, kłujący ból ([strefa_pl(limb.body_zone)])!")

/datum/surgery_operation/limb/repair_puncture/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/datum/wound/pierce/pierce_wound = limb.get_wound(WOUND_PIERCE)
	limb.receive_damage(3)
	pierce_wound?.mend_state = TRUE
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zestawiasz rozerwane naczynia ([FORMAT_LIMB_OWNER(limb)])."),
		span_notice("[surgeon] zestawia rozerwane naczynia ([FORMAT_LIMB_OWNER(limb)]) za pomocą [tool]!"),
		span_notice("[surgeon] zestawia rozerwane naczynia ([FORMAT_LIMB_OWNER(limb)])!"),
	)

/datum/surgery_operation/limb/repair_puncture/on_failure(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_warning("Rozrywasz część naczyń ([FORMAT_LIMB_OWNER(limb)])."),
		span_warning("[surgeon] rozrywa część naczyń ([FORMAT_LIMB_OWNER(limb)]) za pomocą [tool]!"),
		span_warning("[surgeon] rozrywa część naczyń ([FORMAT_LIMB_OWNER(limb)])."),
	)
	limb.receive_damage(rand(4, 8))
	limb.owner?.add_bleeding(BLEED_CUT)

/// Krok 2: zamknięcie zestawionych naczyń
/datum/surgery_operation/limb/seal_veins
	name = "zamknięcie naczyń"
	desc = "Zamyka zestawione naczynia krwionośne pacjenta."
	implements = list(
		TOOL_CAUTERY = 1,
		/obj/item/gun/energy/laser = 1.12,
		TOOL_WELDER = 1.5,
		/obj/item = 3.33,
	)
	time = 3.2 SECONDS
	preop_sound = 'sound/surgery/cautery1.ogg'
	success_sound = 'sound/surgery/cautery2.ogg'
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_PRIORITY_NEXT_STEP | OPERATION_NO_PATIENT_REQUIRED
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT

/datum/surgery_operation/limb/seal_veins/get_default_radial_image()
	return image(icon = 'icons/obj/surgery.dmi', icon_state = "cautery")

/datum/surgery_operation/limb/seal_veins/get_any_tool()
	return "Dowolne źródło ciepła"

/datum/surgery_operation/limb/seal_veins/all_required_strings()
	return list("kończyna musi mieć ranę kłutą z zestawionymi naczyniami") + ..()

/datum/surgery_operation/limb/seal_veins/tool_check(obj/item/tool)
	// AQUILA - nasz kauter nie ma temperatury
	if(tool.tool_behaviour == TOOL_CAUTERY)
		return TRUE
	if(istype(tool, /obj/item/gun/energy/laser))
		var/obj/item/gun/energy/laser/lasergun = tool
		return lasergun.cell?.charge > 0
	return tool.is_hot() >= FIRE_MINIMUM_TEMPERATURE_TO_EXIST

/datum/surgery_operation/limb/seal_veins/state_check(obj/item/bodypart/limb)
	var/datum/wound/pierce/pierce_wound = limb.get_wound(WOUND_PIERCE)
	if(isnull(pierce_wound) || !pierce_wound.mend_state)
		return FALSE
	return TRUE

/datum/surgery_operation/limb/seal_veins/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz zamykać zestawione naczynia ([FORMAT_LIMB_OWNER(limb)])..."),
		span_notice("[surgeon] zaczyna zamykać zestawione naczynia ([FORMAT_LIMB_OWNER(limb)]) za pomocą [tool]."),
		span_notice("[surgeon] zaczyna zamykać zestawione naczynia ([FORMAT_LIMB_OWNER(limb)])."),
	)
	display_pain(limb.owner, "Czujesz pieczenie ([strefa_pl(limb.body_zone)])!")

/datum/surgery_operation/limb/seal_veins/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/datum/wound/pierce/pierce_wound = limb.get_wound(WOUND_PIERCE)
	if(isnull(pierce_wound))
		return
	// jak jedno przypalenie rany (pierce.dm treat()): krwawienie słabnie, rana schodzi o stopień
	limb.owner?.suppress_bloodloss(pierce_wound.initial_bleed)
	var/datum/wound/pierce/remaining = pierce_wound.replace_with(pierce_wound.cauterized_into)
	if(isnull(remaining))
		display_results(
			surgeon,
			limb.owner,
			span_notice("Zamykasz ostatnie rozerwane naczynia ([FORMAT_LIMB_OWNER(limb)])."),
			span_notice("[surgeon] zamyka ostatnie rozerwane naczynia ([FORMAT_LIMB_OWNER(limb)]) za pomocą [tool]!"),
			span_notice("[surgeon] zamyka ostatnie rozerwane naczynia ([FORMAT_LIMB_OWNER(limb)])!"),
		)
		return

	display_results(
		surgeon,
		limb.owner,
		span_notice("Zamykasz część naczyń ([FORMAT_LIMB_OWNER(limb)]), rana wciąż wymaga pracy."),
		span_notice("[surgeon] zamyka część naczyń ([FORMAT_LIMB_OWNER(limb)]) za pomocą [tool]!"),
		span_notice("[surgeon] zamyka część naczyń ([FORMAT_LIMB_OWNER(limb)])!"),
	)
