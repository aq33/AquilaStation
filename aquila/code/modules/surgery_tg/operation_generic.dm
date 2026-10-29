// AQUILA - tg code/modules/surgery/operations/operation_generic.dm
// Podstawowe operacje przechodzenia między stanami kończyny (nacięcie, odciągnięcie, zaciśnięcie, piłowanie, zamknięcie...).

/// Pierwszy krok prawie każdej operacji: nacięcie skóry
/datum/surgery_operation/limb/incise_skin
	name = "nacięcie skóry"
	desc = "Nacina skórę pacjenta, żeby dostać się do środka. \
		Stan: \"skóra nacięta\"."
	required_bodytype = BODYTYPE_ORGANIC
	replaced_by = /datum/surgery_operation/limb/incise_skin/abductor
	self_operable_zones = list(BODY_ZONE_PRECISE_MOUTH) // AQUILA - implant zęba na sobie
	implements = list(
		TOOL_SCALPEL = 1,
		/obj/item/melee/transforming/energy/sword = 1.33,
		/obj/item/kitchen/knife = 1.5,
		/obj/item/shard = 2.25,
		/obj/item/screwdriver = 5,
		/obj/item/pen = 5,
		/obj/item = 3.33,
	)
	time = 1.6 SECONDS
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/scalpel2.ogg'
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NO_PATIENT_REQUIRED
	any_surgery_states_blocked = ALL_SURGERY_SKIN_STATES
	allow_stumps = TRUE
	/// AQUILA - tg: biostate_blacklist = BIO_CHITIN. U nas pancerz chitynowy mają kończyny obcych.
	var/chitin_allowed = FALSE

/datum/surgery_operation/limb/incise_skin/get_any_tool()
	return "Dowolny ostry przedmiot"

/datum/surgery_operation/limb/incise_skin/get_default_radial_image()
	return image(icon = 'icons/obj/surgery.dmi', icon_state = "scalpel")

/datum/surgery_operation/limb/incise_skin/tool_check(obj/item/tool)
	// ostrze albo pasujące narzędzie
	if(tool.sharpness || (tool.tool_behaviour && implements[tool.tool_behaviour]))
		return TRUE
	// na życzenie graczy, choć nie są ostre
	if(istype(tool, /obj/item/pen) || istype(tool, /obj/item/screwdriver))
		return TRUE
	return FALSE

/datum/surgery_operation/limb/incise_skin/state_check(obj/item/bodypart/limb)
	return chitin_allowed || limb.animal_origin != ALIEN_BODYPART

/datum/surgery_operation/limb/incise_skin/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz nacinać [FORMAT_LIMB_OWNER(limb)]..."),
		span_notice("[surgeon] zaczyna nacinać [FORMAT_LIMB_OWNER(limb)]."),
		span_notice("[surgeon] zaczyna nacinać [FORMAT_LIMB_OWNER(limb)]."),
	)
	display_pain(limb.owner, "Czujesz kłujący ból ([strefa_pl(limb.body_zone)])!")

/datum/surgery_operation/limb/incise_skin/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	limb.add_surgical_state(SURGERY_SKIN_CUT|SURGERY_VESSELS_UNCLAMPED) // przecina też naczynia
	if(!limb.owner || !IS_ORGANIC_LIMB(limb))
		return
	var/mob/living/carbon/patient = limb.owner
	if(HAS_TRAIT(patient, TRAIT_NO_BLOOD) || (ishuman(patient) && (NOBLOOD in patient.dna?.species?.species_traits)))
		return
	display_results(
		surgeon,
		patient,
		span_notice("Wokół nacięcia ([strefa_pl(limb.body_zone)]) [patient] zbiera się krew."),
		span_notice("Wokół nacięcia ([strefa_pl(limb.body_zone)]) [patient] zbiera się krew."),
		span_notice("Wokół nacięcia ([strefa_pl(limb.body_zone)]) [patient] zbiera się krew."),
	)
	// AQUILA - tg: krwawienie liczone ze stanu SURGERY_VESSELS_UNCLAMPED. U nas krwawienie jak w starym kroku nacięcia.
	patient.add_bleeding(BLEED_CUT)

/// Grubsza skóra (obcy)
/datum/surgery_operation/limb/incise_skin/thick
	name = "nacięcie grubej skóry"
	implements = list(
		TOOL_SAW = 1,
		/obj/item/melee/transforming/energy/sword = 1.25,
		/obj/item/fireaxe = 1.5,
		/obj/item/kitchen/knife/butcher = 2.5,
		/obj/item = 5,
	)
	chitin_allowed = TRUE

/datum/surgery_operation/limb/incise_skin/thick/get_any_tool()
	return "Dowolny ostry przedmiot o sporej sile"

/datum/surgery_operation/limb/incise_skin/thick/tool_check(obj/item/tool)
	return ..() && tool.force >= 10

/datum/surgery_operation/limb/incise_skin/thick/state_check(obj/item/bodypart/limb)
	return limb.animal_origin == ALIEN_BODYPART

/datum/surgery_operation/limb/incise_skin/abductor
	operation_flags = parent_type::operation_flags | OPERATION_IGNORE_CLOTHES | OPERATION_LOCKED | OPERATION_NO_WIKI
	required_bodytype = NONE
	chitin_allowed = TRUE // mają laserowe skalpele

/// Odciąga skórę, żeby dostać się do środka
/datum/surgery_operation/limb/retract_skin
	name = "odciągnięcie skóry"
	desc = "Odciąga skórę pacjenta, żeby dostać się do organów. \
		Stan: \"skóra odciągnięta\"."
	operation_flags = OPERATION_NO_PATIENT_REQUIRED
	required_bodytype = BODYTYPE_ORGANIC
	replaced_by = /datum/surgery_operation/limb/retract_skin/abductor
	self_operable_zones = list(BODY_ZONE_PRECISE_MOUTH) // AQUILA - implant zęba na sobie
	implements = list(
		TOOL_RETRACTOR = 1,
		TOOL_SCREWDRIVER = 2.25,
		TOOL_WIRECUTTER = 2.85,
		/obj/item/stack/rods = 2.85,
		/obj/item/kitchen/fork = 2.85,
	)
	time = 2.4 SECONDS
	preop_sound = 'sound/surgery/retractor1.ogg'
	success_sound = 'sound/surgery/retractor2.ogg'
	all_surgery_states_required = SURGERY_SKIN_CUT
	allow_stumps = TRUE

/datum/surgery_operation/limb/retract_skin/get_default_radial_image()
	return image(icon = 'icons/obj/surgery.dmi', icon_state = "retractor")

/datum/surgery_operation/limb/retract_skin/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz odciągać skórę ([FORMAT_LIMB_OWNER(limb)])..."),
		span_notice("[surgeon] zaczyna odciągać skórę ([FORMAT_LIMB_OWNER(limb)])."),
		span_notice("[surgeon] zaczyna odciągać skórę ([FORMAT_LIMB_OWNER(limb)])."),
	)
	display_pain(limb.owner, "Piekący ból rozlewa się ([strefa_pl(limb.body_zone)]), gdy ktoś odciąga ci skórę!")

/datum/surgery_operation/limb/retract_skin/on_success(obj/item/bodypart/limb)
	. = ..()
	// naczynia powinny być już zaciśnięte albo nie; jak nie ma żadnego stanu naczyń (np. przez rany), uznajemy je za otwarte
	limb.add_surgical_state(SURGERY_SKIN_OPEN | (LIMB_HAS_SURGERY_STATE(limb, SURGERY_VESSELS_CLAMPED) ? NONE : SURGERY_VESSELS_UNCLAMPED))
	limb.remove_surgical_state(SURGERY_SKIN_CUT)

/datum/surgery_operation/limb/retract_skin/abductor
	operation_flags = parent_type::operation_flags | OPERATION_IGNORE_CLOTHES | OPERATION_LOCKED | OPERATION_NO_WIKI
	required_bodytype = NONE

/// Zamyka nacięcie
/datum/surgery_operation/limb/close_skin
	name = "zamknięcie nacięcia"
	desc = "Zamyka nacięcie skóry pacjenta. \
		Czyści większość stanów chirurgicznych."
	required_bodytype = BODYTYPE_ORGANIC
	operation_flags = OPERATION_PRIORITY_NEXT_STEP | OPERATION_NO_PATIENT_REQUIRED
	replaced_by = /datum/surgery_operation/limb/close_skin/abductor
	implements = list(
		TOOL_CAUTERY = 1,
		/obj/item/stack/medical/suture = 1,
		/obj/item/gun/energy/laser = 1.15,
		TOOL_WELDER = 1.5,
		/obj/item = 3.33,
	)
	time = 2.4 SECONDS
	preop_sound = list(
		/obj/item/stack/medical/suture = 'sound/surgery/hemostat1.ogg',
		/obj/item = 'sound/surgery/cautery1.ogg',
	)
	success_sound = list(
		/obj/item/stack/medical/suture = 'sound/surgery/hemostat1.ogg',
		/obj/item = 'sound/surgery/cautery2.ogg',
	)
	any_surgery_states_required = ALL_SURGERY_SKIN_STATES
	allow_stumps = TRUE

/datum/surgery_operation/limb/close_skin/get_any_tool()
	return "Dowolne źródło ciepła"

/datum/surgery_operation/limb/close_skin/get_default_radial_image()
	return image(icon = 'icons/obj/surgery.dmi', icon_state = "cautery")

/datum/surgery_operation/limb/close_skin/all_required_strings()
	return ..() + list("kończyna musi mieć skórę")

/datum/surgery_operation/limb/close_skin/state_check(obj/item/bodypart/limb)
	return LIMB_HAS_SKIN(limb)

/datum/surgery_operation/limb/close_skin/tool_check(obj/item/tool)
	if(istype(tool, /obj/item/stack/medical/suture))
		return TRUE

	// AQUILA - nasz kauter nie ma temperatury (heat), w tg ma
	if(tool.tool_behaviour == TOOL_CAUTERY)
		return TRUE

	if(istype(tool, /obj/item/gun/energy/laser))
		var/obj/item/gun/energy/laser/lasergun = tool
		return lasergun.cell?.charge > 0

	return tool.is_hot() >= FIRE_MINIMUM_TEMPERATURE_TO_EXIST

/datum/surgery_operation/limb/close_skin/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz zamykać nacięcie ([FORMAT_LIMB_OWNER(limb)])..."),
		span_notice("[surgeon] zaczyna zamykać nacięcie ([FORMAT_LIMB_OWNER(limb)])."),
		span_notice("[surgeon] zaczyna zamykać nacięcie ([FORMAT_LIMB_OWNER(limb)])."),
	)
	display_pain(limb.owner, istype(tool, /obj/item/stack/medical/suture) ? "Coś szczypie cię ([strefa_pl(limb.body_zone)])!" : "Coś przypala ci ciało ([strefa_pl(limb.body_zone)])!")

/datum/surgery_operation/limb/close_skin/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	if(LIMB_HAS_SURGERY_STATE(limb, SURGERY_BONE_SAWED))
		limb.heal_damage(40)
	// AQUILA - jak stara kauteryzacja (nacięcie, odciągnięcie, zamknięcie): zamyka rany cięte i kłute kończyny
	if(LIMB_HAS_SURGERY_STATE(limb, SURGERY_SKIN_OPEN))
		for(var/datum/wound/wound as anything in limb.wounds?.Copy())
			if(wound.wound_type == WOUND_SLASH || wound.wound_type == WOUND_PIERCE)
				qdel(wound)
	limb.remove_surgical_state(ALL_SURGERY_STATES_UNSET_ON_CLOSE)
	// AQUILA - jak stary krok zamknięcia: koniec krwawienia
	limb.owner?.cauterise_wounds()

/datum/surgery_operation/limb/close_skin/abductor
	operation_flags = parent_type::operation_flags | OPERATION_IGNORE_CLOTHES | OPERATION_LOCKED | OPERATION_NO_WIKI
	required_bodytype = NONE

/// Zaciska krwawiące naczynia
/datum/surgery_operation/limb/clamp_bleeders
	name = "zaciśnięcie naczyń"
	desc = "Zaciska krwawiące naczynia pacjenta, żeby nie tracił krwi. \
		Stan: \"naczynia zaciśnięte\"."
	required_bodytype = BODYTYPE_ORGANIC
	operation_flags = OPERATION_PRIORITY_NEXT_STEP | OPERATION_NO_PATIENT_REQUIRED
	replaced_by = /datum/surgery_operation/limb/clamp_bleeders/abductor
	self_operable_zones = list(BODY_ZONE_PRECISE_MOUTH) // AQUILA - implant zęba na sobie
	implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_WIRECUTTER = 1.67,
		/obj/item/stack/package_wrap = 2.85,
		/obj/item/stack/cable_coil = 6.67,
	)
	time = 2.4 SECONDS
	preop_sound = 'sound/surgery/hemostat1.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_VESSELS_UNCLAMPED
	allow_stumps = TRUE

/datum/surgery_operation/limb/clamp_bleeders/get_default_radial_image()
	return image(icon = 'icons/obj/surgery.dmi', icon_state = "hemostat")

/datum/surgery_operation/limb/clamp_bleeders/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz zaciskać krwawiące naczynia ([FORMAT_LIMB_OWNER(limb)])..."),
		span_notice("[surgeon] zaczyna zaciskać krwawiące naczynia ([FORMAT_LIMB_OWNER(limb)])."),
		span_notice("[surgeon] zaczyna zaciskać krwawiące naczynia ([FORMAT_LIMB_OWNER(limb)])."),
	)
	display_pain(limb.owner, "Czujesz uszczypnięcie, krwawienie ([strefa_pl(limb.body_zone)]) słabnie.")

/datum/surgery_operation/limb/clamp_bleeders/on_success(obj/item/bodypart/limb)
	. = ..()
	// po piłowaniu kości darmowe leczenie
	if(LIMB_HAS_SURGERY_STATE(limb, SURGERY_BONE_SAWED))
		limb.heal_damage(20)
	limb.add_surgical_state(SURGERY_VESSELS_CLAMPED)
	limb.remove_surgical_state(SURGERY_VESSELS_UNCLAMPED)
	// AQUILA - tg zmniejsza krwawienie przez stan naczyń, u nas zdejmujemy krwawienie z nacięcia
	limb.owner?.cauterise_wounds(BLEED_CUT)

/datum/surgery_operation/limb/clamp_bleeders/abductor
	operation_flags = parent_type::operation_flags | OPERATION_IGNORE_CLOTHES | OPERATION_LOCKED | OPERATION_NO_WIKI
	required_bodytype = NONE

/// Zdejmuje zaciski z naczyń
/datum/surgery_operation/limb/unclamp_bleeders
	name = "zdjęcie zacisków"
	desc = "Zdejmuje zaciski z naczyń, krew znowu płynie. \
		Czyści stan \"naczynia zaciśnięte\"."
	required_bodytype = BODYTYPE_ORGANIC
	operation_flags = OPERATION_NO_PATIENT_REQUIRED
	replaced_by = /datum/surgery_operation/limb/unclamp_bleeders/abductor
	implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_WIRECUTTER = 1.67,
		/obj/item/stack/package_wrap = 2.85,
		/obj/item/stack/cable_coil = 6.67,
	)
	time = 2.4 SECONDS
	preop_sound = 'sound/surgery/hemostat1.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED
	allow_stumps = TRUE

/datum/surgery_operation/limb/unclamp_bleeders/get_default_radial_image()
	return image(icon = 'icons/obj/surgery.dmi', icon_state = "hemostat_a")

/datum/surgery_operation/limb/unclamp_bleeders/all_required_strings()
	return ..() + list("kończyna musi mieć naczynia")

/datum/surgery_operation/limb/unclamp_bleeders/state_check(obj/item/bodypart/limb)
	return LIMB_HAS_VESSELS(limb)

/datum/surgery_operation/limb/unclamp_bleeders/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz zdejmować zaciski z naczyń ([FORMAT_LIMB_OWNER(limb)])..."),
		span_notice("[surgeon] zaczyna zdejmować zaciski z naczyń ([FORMAT_LIMB_OWNER(limb)])."),
		span_notice("[surgeon] zaczyna zdejmować zaciski z naczyń ([FORMAT_LIMB_OWNER(limb)])."),
	)
	display_pain(limb.owner, "Czujesz, jak ucisk puszcza i krew znowu płynie ([strefa_pl(limb.body_zone)]).")

/datum/surgery_operation/limb/unclamp_bleeders/on_success(obj/item/bodypart/limb)
	. = ..()
	limb.add_surgical_state(SURGERY_VESSELS_UNCLAMPED)
	limb.remove_surgical_state(SURGERY_VESSELS_CLAMPED)

/datum/surgery_operation/limb/unclamp_bleeders/abductor
	operation_flags = parent_type::operation_flags | OPERATION_IGNORE_CLOTHES | OPERATION_LOCKED | OPERATION_NO_WIKI
	required_bodytype = NONE

/// Przepiłowuje kość, żeby dostać się do organów
/datum/surgery_operation/limb/saw_bones
	name = "przepiłowanie kości"
	desc = "Przepiłowuje kość pacjenta, żeby dostać się do organów. \
		Stan: \"kość przepiłowana\"."
	required_bodytype = BODYTYPE_ORGANIC
	implements = list(
		TOOL_SAW = 1,
		/obj/item/melee/arm_blade = 1.33,
		/obj/item/fireaxe = 2,
		/obj/item/hatchet = 2.85,
		/obj/item/kitchen/knife/butcher = 2.85,
		/obj/item = 4,
	)
	time = 5.4 SECONDS
	preop_sound = list(
		/obj/item/circular_saw = 'sound/surgery/saw.ogg',
		/obj/item = 'sound/surgery/scalpel1.ogg',
	)
	success_sound = 'sound/surgery/organ2.ogg'
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NO_PATIENT_REQUIRED
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_BONE_SAWED|SURGERY_BONE_DRILLED
	allow_stumps = TRUE

/datum/surgery_operation/limb/saw_bones/get_any_tool()
	return "Dowolny ostry przedmiot o sporej sile"

/datum/surgery_operation/limb/saw_bones/get_default_radial_image()
	return image(icon = 'icons/obj/surgery.dmi', icon_state = "saw")

/datum/surgery_operation/limb/saw_bones/tool_check(obj/item/tool)
	// ostrze o sporej sile albo pasujące narzędzie
	return ((tool.sharpness && tool.force >= 10) || (tool.tool_behaviour && implements[tool.tool_behaviour]))

/datum/surgery_operation/limb/saw_bones/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz przepiłowywać kość ([FORMAT_LIMB_OWNER(limb)])..."),
		span_notice("[surgeon] zaczyna przepiłowywać kość ([FORMAT_LIMB_OWNER(limb)])."),
		span_notice("[surgeon] zaczyna przepiłowywać kość ([FORMAT_LIMB_OWNER(limb)])."),
	)
	display_pain(limb.owner, "Okropny ból rozlewa się w środku ([strefa_pl(limb.body_zone)])!")

/datum/surgery_operation/limb/saw_bones/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	limb.add_surgical_state(SURGERY_BONE_SAWED)
	limb.receive_damage(50)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Otwierasz piłą [FORMAT_LIMB_OWNER(limb)]."),
		span_notice("[surgeon] otwiera piłą [FORMAT_LIMB_OWNER(limb)]!"),
		span_notice("[surgeon] otwiera piłą [FORMAT_LIMB_OWNER(limb)]!"),
	)
	display_pain(limb.owner, "Czujesz, jakby coś w środku pękło ([strefa_pl(limb.body_zone)])!")

/// Skleja przepiłowaną albo nawierconą kość
/datum/surgery_operation/limb/fix_bones
	name = "zespolenie kości"
	desc = "Skleja przecięte albo złamane kości pacjenta. \
		Czyści stany \"kość przepiłowana\" i \"kość nawiercona\"."
	required_bodytype = BODYTYPE_ORGANIC
	operation_flags = OPERATION_NO_PATIENT_REQUIRED
	implements = list(
		/obj/item/stack/medical/bone_gel = 1,
		/obj/item/stack/sticky_tape/surgical = 1,
		/obj/item/stack/sticky_tape/super = 2,
		/obj/item/stack/sticky_tape = 3.33,
	)
	time = 4 SECONDS
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_required = ALL_SURGERY_BONE_STATES
	allow_stumps = TRUE

/datum/surgery_operation/limb/fix_bones/get_default_radial_image()
	return image(icon = 'icons/obj/surgery.dmi', icon_state = "bone-gel")

/datum/surgery_operation/limb/fix_bones/all_required_strings()
	return ..() + list("kończyna musi mieć kości")

/datum/surgery_operation/limb/fix_bones/state_check(obj/item/bodypart/limb)
	// AQUILA - tg ukrywa to, gdy stan kości dała rana. Nasze rany nie dają stanów chirurgicznych.
	return LIMB_HAS_BONES(limb)

/datum/surgery_operation/limb/fix_bones/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz zespalać kości ([FORMAT_LIMB_OWNER(limb)])..."),
		span_notice("[surgeon] zaczyna zespalać kości ([FORMAT_LIMB_OWNER(limb)])."),
		span_notice("[surgeon] zaczyna zespalać kości ([FORMAT_LIMB_OWNER(limb)])."),
	)
	display_pain(limb.owner, "Czujesz zgrzytanie, gdy kości wracają na miejsce ([strefa_pl(limb.body_zone)]).")

/datum/surgery_operation/limb/fix_bones/on_success(obj/item/bodypart/limb)
	. = ..()
	// bez skóry zespolenie kości zamyka też operację
	if(!LIMB_HAS_SKIN(limb))
		limb.remove_surgical_state(ALL_SURGERY_STATES_UNSET_ON_CLOSE)
	limb.remove_surgical_state(ALL_SURGERY_BONE_STATES)
	limb.heal_damage(40)

/// Nawierca kość
/datum/surgery_operation/limb/drill_bones
	name = "nawiercenie kości"
	desc = "Nawierca kość pacjenta. \
		Stan: \"kość nawiercona\"."
	required_bodytype = BODYTYPE_ORGANIC
	operation_flags = OPERATION_NO_PATIENT_REQUIRED
	self_operable_zones = list(BODY_ZONE_PRECISE_MOUTH) // AQUILA - implant zęba na sobie
	implements = list(
		TOOL_DRILL = 1,
		/obj/item/powertool/hand_drill = 1.25,
		/obj/item/pickaxe/drill = 1.67,
		TOOL_SCREWDRIVER = 4,
		/obj/item/kitchen/spoon = 5,
		/obj/item = 6.67,
	)
	time = 3 SECONDS
	preop_sound = 'sound/surgery/saw.ogg'
	success_sound = 'sound/surgery/organ2.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_BONE_SAWED|SURGERY_BONE_DRILLED
	allow_stumps = TRUE

/datum/surgery_operation/limb/drill_bones/get_any_tool()
	return "Dowolny ostry przedmiot o sporej sile"

/datum/surgery_operation/limb/drill_bones/get_default_radial_image()
	return image(icon = 'icons/obj/surgery.dmi', icon_state = "drill")

/datum/surgery_operation/limb/drill_bones/tool_check(obj/item/tool)
	// tg: szpiczasty przedmiot o sporej sile. U nas ostrość nie rozróżnia ostrza i szpica.
	return ((tool.sharpness && tool.force >= 10) || (tool.tool_behaviour && implements[tool.tool_behaviour]))

/datum/surgery_operation/limb/drill_bones/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz wiercić w kości ([FORMAT_LIMB_OWNER(limb)])..."),
		span_notice("[surgeon] zaczyna wiercić w kości ([FORMAT_LIMB_OWNER(limb)])."),
		span_notice("[surgeon] zaczyna wiercić w kości ([FORMAT_LIMB_OWNER(limb)])."),
	)
	display_pain(limb.owner, "Przeszywa cię straszny, świdrujący ból ([strefa_pl(limb.body_zone)])!")

/datum/surgery_operation/limb/drill_bones/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	limb.add_surgical_state(SURGERY_BONE_DRILLED)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Nawiercasz [FORMAT_LIMB_OWNER(limb)]."),
		span_notice("[surgeon] nawierca [FORMAT_LIMB_OWNER(limb)]!"),
		span_notice("[surgeon] nawierca [FORMAT_LIMB_OWNER(limb)]!"),
	)

/// Nacina organy w kończynie
/datum/surgery_operation/limb/incise_organs
	name = "nacięcie organów"
	desc = "Nacina tkankę organów pacjenta, żeby można je było przesunąć albo naprawić. \
		Stan: \"organy nacięte\"."
	required_bodytype = BODYTYPE_ORGANIC
	operation_flags = OPERATION_NO_PATIENT_REQUIRED
	replaced_by = /datum/surgery_operation/limb/incise_organs/abductor
	implements = list(
		TOOL_SCALPEL = 1,
		/obj/item/melee/transforming/energy/sword = 1.33,
		/obj/item/kitchen/knife = 1.5,
		/obj/item/shard = 2.25,
		/obj/item/pen = 5,
		/obj/item = 3.33,
	)
	time = 2.4 SECONDS
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/organ1.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_ORGANS_CUT
	allow_stumps = TRUE

/datum/surgery_operation/limb/incise_organs/get_any_tool()
	return "Dowolny ostry przedmiot"

/datum/surgery_operation/limb/incise_organs/get_default_radial_image()
	return image(icon = 'icons/obj/surgery.dmi', icon_state = "scalpel_a")

/datum/surgery_operation/limb/incise_organs/tool_check(obj/item/tool)
	// ostrze albo pasujące narzędzie, ale nie piła - rozszarpie organy
	return (tool.sharpness || (tool.tool_behaviour && implements[tool.tool_behaviour])) && tool.tool_behaviour != TOOL_SAW

/datum/surgery_operation/limb/incise_organs/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz nacinać organy ([FORMAT_LIMB_OWNER(limb)])..."),
		span_notice("[surgeon] zaczyna nacinać organy ([FORMAT_LIMB_OWNER(limb)])."),
		span_notice("[surgeon] zaczyna nacinać organy ([FORMAT_LIMB_OWNER(limb)])."),
	)
	display_pain(limb.owner, "Czujesz kłujący ból ([strefa_pl(limb.body_zone)])!")

/datum/surgery_operation/limb/incise_organs/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	limb.add_surgical_state(SURGERY_ORGANS_CUT)
	limb.receive_damage(10)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Nacinasz organy ([FORMAT_LIMB_OWNER(limb)])."),
		span_notice("[surgeon] nacina organy ([FORMAT_LIMB_OWNER(limb)])!"),
		span_notice("[surgeon] nacina organy ([FORMAT_LIMB_OWNER(limb)])!"),
	)
	display_pain(limb.owner, "Czujesz ostry ból w środku ([strefa_pl(limb.body_zone)])!")

/datum/surgery_operation/limb/incise_organs/abductor
	operation_flags = parent_type::operation_flags | OPERATION_IGNORE_CLOTHES | OPERATION_LOCKED | OPERATION_NO_WIKI
	required_bodytype = NONE

/datum/surgery_operation/limb/incise_organs/abductor/state_check(obj/item/bodypart/limb)
	return TRUE // można nacinać klatkę bez piłowania żeber
