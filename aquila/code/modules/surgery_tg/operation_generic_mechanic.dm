// AQUILA - tg code/modules/surgery/operations/operation_generic_mechanic.dm
// Mechaniczne odpowiedniki podstawowych operacji dla robotycznych kończyn (protezy, IPC: bodytype BODYTYPE_ROBOTIC).
// Stare kroki Bee to code/modules/surgery/mechanic_steps.dm (mechanic_open/close, open_hatch, prepare_electronics, mechanic_(un)wrench).

/// Odkręcenie obudowy (odpowiednik nacięcia skóry)
/datum/surgery_operation/limb/mechanical_incision
	name = "odkręcenie obudowy"
	desc = "Odkręca obudowę mechanicznej kończyny, żeby dostać się do środka. \
		Stan: \"skóra nacięta\"."
	implements = list(
		TOOL_SCREWDRIVER = 1,
		TOOL_SCALPEL = 1.33,
		/obj/item/kitchen/knife = 2,
		/obj/item = 10, // około 180% szansy porażki (ucięte do 99%)
	)
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_MECHANIC | OPERATION_NO_PATIENT_REQUIRED
	required_bodytype = BODYTYPE_ROBOTIC
	time = 2.4 SECONDS
	preop_sound = 'sound/items/screwdriver.ogg'
	success_sound = 'sound/items/screwdriver2.ogg'
	any_surgery_states_blocked = ALL_SURGERY_SKIN_STATES
	allow_stumps = TRUE

/datum/surgery_operation/limb/mechanical_incision/get_any_tool()
	return "Dowolny ostry przedmiot"

/datum/surgery_operation/limb/mechanical_incision/get_default_radial_image()
	return get_item_radial_image(/obj/item/screwdriver)

/datum/surgery_operation/limb/mechanical_incision/tool_check(obj/item/tool)
	// cokolwiek ostrego albo pasujące narzędzie
	return (tool.sharpness || implements[tool.tool_behaviour])

/datum/surgery_operation/limb/mechanical_incision/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz odkręcać obudowę ([FORMAT_LIMB_OWNER(limb)])..."),
		span_notice("[surgeon] zaczyna odkręcać obudowę ([FORMAT_LIMB_OWNER(limb)])."),
		span_notice("[surgeon] zaczyna odkręcać obudowę ([FORMAT_LIMB_OWNER(limb)])."),
	)
	display_pain(limb.owner, "Czucie w kończynie ([strefa_pl(limb.body_zone)]) słabnie, gdy ktoś odkręca obudowę.", TRUE)

/datum/surgery_operation/limb/mechanical_incision/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	limb.add_surgical_state(SURGERY_SKIN_CUT)

/// Otwarcie klapy (odpowiednik odciągnięcia skóry i zaciśnięcia naczyń)
/datum/surgery_operation/limb/mechanical_open
	name = "otwarcie klapy"
	desc = "Otwiera klapę mechanicznej kończyny, żeby dostać się do środka. \
		Stany: \"skóra odciągnięta\" i \"naczynia zaciśnięte\"."
	required_bodytype = BODYTYPE_ROBOTIC
	implements = list(
		IMPLEMENT_HAND = 1,
		TOOL_CROWBAR = 1,
	)
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_MECHANIC | OPERATION_NO_PATIENT_REQUIRED
	time = 1 SECONDS
	preop_sound = 'sound/items/ratchet.ogg'
	success_sound = 'sound/machines/doorclick.ogg'
	all_surgery_states_required = SURGERY_SKIN_CUT
	allow_stumps = TRUE

/datum/surgery_operation/limb/mechanical_open/get_default_radial_image()
	return get_item_radial_image(/obj/item/crowbar)

/datum/surgery_operation/limb/mechanical_open/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz otwierać zatrzaski klapy ([FORMAT_LIMB_OWNER(limb)])..."),
		span_notice("[surgeon] zaczyna otwierać zatrzaski klapy ([FORMAT_LIMB_OWNER(limb)])."),
		span_notice("[surgeon] zaczyna otwierać zatrzaski klapy ([FORMAT_LIMB_OWNER(limb)])."),
	)
	display_pain(limb.owner, "Resztki czucia w kończynie ([strefa_pl(limb.body_zone)]) znikają, gdy ktoś otwiera klapę.", TRUE)

/datum/surgery_operation/limb/mechanical_open/on_success(obj/item/bodypart/limb)
	. = ..()
	// skóra i naczynia naraz
	limb.add_surgical_state(SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED)
	limb.remove_surgical_state(SURGERY_SKIN_CUT)

/// Przykręcenie obudowy (odpowiednik zamknięcia nacięcia)
/datum/surgery_operation/limb/mechanical_close
	name = "przykręcenie obudowy"
	desc = "Przykręca obudowę mechanicznej kończyny z powrotem. \
		Czyści większość stanów chirurgicznych."
	required_bodytype = BODYTYPE_ROBOTIC
	implements = list(
		TOOL_SCREWDRIVER = 1,
		TOOL_SCALPEL = 1.33,
		/obj/item/kitchen/knife = 2,
		/obj/item = 10,
	)
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_MECHANIC | OPERATION_NO_PATIENT_REQUIRED
	time = 2.4 SECONDS
	preop_sound = 'sound/items/screwdriver.ogg'
	success_sound = 'sound/items/screwdriver2.ogg'
	any_surgery_states_required = ALL_SURGERY_SKIN_STATES
	allow_stumps = TRUE

/datum/surgery_operation/limb/mechanical_close/get_any_tool()
	return "Dowolny ostry przedmiot"

/datum/surgery_operation/limb/mechanical_close/get_default_radial_image()
	return get_item_radial_image(/obj/item/screwdriver)

/datum/surgery_operation/limb/mechanical_close/tool_check(obj/item/tool)
	// cokolwiek ostrego albo pasujące narzędzie
	return (tool.sharpness || implements[tool.tool_behaviour])

/datum/surgery_operation/limb/mechanical_close/state_check(obj/item/bodypart/limb)
	return LIMB_HAS_SKIN(limb)

/datum/surgery_operation/limb/mechanical_close/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz przykręcać obudowę ([FORMAT_LIMB_OWNER(limb)])..."),
		span_notice("[surgeon] zaczyna przykręcać obudowę ([FORMAT_LIMB_OWNER(limb)])."),
		span_notice("[surgeon] zaczyna przykręcać obudowę ([FORMAT_LIMB_OWNER(limb)])."),
	)
	display_pain(limb.owner, "Czucie w kończynie ([strefa_pl(limb.body_zone)]) powoli wraca, gdy ktoś przykręca obudowę.", TRUE)

/datum/surgery_operation/limb/mechanical_close/on_success(obj/item/bodypart/limb)
	. = ..()
	limb.remove_surgical_state(ALL_SURGERY_STATES_UNSET_ON_CLOSE)
	// AQUILA - jak stary krok przykręcenia obudowy: koniec krwawienia
	limb.owner?.cauterise_wounds()

/// Przygotowanie elektroniki (odpowiednik nacięcia organów)
/datum/surgery_operation/limb/prepare_electronics
	name = "przygotowanie elektroniki"
	desc = "Przygotowuje elektronikę mechanicznej kończyny do operacji. \
		Stan: \"organy nacięte\"."
	required_bodytype = BODYTYPE_ROBOTIC
	implements = list(
		TOOL_MULTITOOL = 1,
		TOOL_HEMOSTAT = 1.33,
	)
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_MECHANIC | OPERATION_NO_PATIENT_REQUIRED
	time = 2.4 SECONDS
	preop_sound = 'sound/surgery/tape_flip.ogg'
	success_sound = 'sound/surgery/taperecorder_close.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_ORGANS_CUT
	allow_stumps = TRUE

/datum/surgery_operation/limb/prepare_electronics/get_default_radial_image()
	return get_item_radial_image(/obj/item/multitool)

/datum/surgery_operation/limb/prepare_electronics/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz przygotowywać elektronikę ([FORMAT_LIMB_OWNER(limb)])..."),
		span_notice("[surgeon] zaczyna przygotowywać elektronikę ([FORMAT_LIMB_OWNER(limb)])."),
		span_notice("[surgeon] zaczyna przygotowywać elektronikę ([FORMAT_LIMB_OWNER(limb)])."),
	)
	display_pain(limb.owner, "Czujesz lekkie brzęczenie ([strefa_pl(limb.body_zone)]), gdy elektronika się restartuje.", TRUE)

/datum/surgery_operation/limb/prepare_electronics/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	limb.add_surgical_state(SURGERY_ORGANS_CUT)

/// Odkręcenie szkieletu (odpowiednik piłowania kości)
/datum/surgery_operation/limb/mechanic_unwrench
	name = "odkręcenie szkieletu"
	desc = "Odkręca szkielet mechanicznej kończyny, żeby dostać się do środka. \
		Stan: \"kość przepiłowana\"."
	required_bodytype = BODYTYPE_ROBOTIC
	implements = list(
		TOOL_WRENCH = 1,
		TOOL_RETRACTOR = 1.33,
	)
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_MECHANIC | OPERATION_NO_PATIENT_REQUIRED
	time = 2.4 SECONDS
	preop_sound = 'sound/items/ratchet.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_BONE_SAWED|SURGERY_BONE_DRILLED
	allow_stumps = TRUE

/datum/surgery_operation/limb/mechanic_unwrench/get_default_radial_image()
	return get_item_radial_image(/obj/item/wrench)

/datum/surgery_operation/limb/mechanic_unwrench/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz odkręcać śruby ([FORMAT_LIMB_OWNER(limb)])..."),
		span_notice("[surgeon] zaczyna odkręcać śruby ([FORMAT_LIMB_OWNER(limb)])."),
		span_notice("[surgeon] zaczyna odkręcać śruby ([FORMAT_LIMB_OWNER(limb)])."),
	)
	display_pain(limb.owner, "Coś szarpie w kończynie ([strefa_pl(limb.body_zone)]), gdy śruby puszczają.", TRUE)

/datum/surgery_operation/limb/mechanic_unwrench/on_success(obj/item/bodypart/limb)
	. = ..()
	limb.add_surgical_state(SURGERY_BONE_SAWED)

/// Przykręcenie szkieletu (odpowiednik zespolenia kości)
/datum/surgery_operation/limb/mechanic_wrench
	name = "przykręcenie szkieletu"
	desc = "Przykręca szkielet mechanicznej kończyny z powrotem. \
		Czyści stan \"kość przepiłowana\"."
	required_bodytype = BODYTYPE_ROBOTIC
	implements = list(
		TOOL_WRENCH = 1,
		TOOL_RETRACTOR = 1.33,
	)
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_MECHANIC | OPERATION_NO_PATIENT_REQUIRED
	time = 2.4 SECONDS
	preop_sound = 'sound/items/ratchet.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_BONE_SAWED
	allow_stumps = TRUE

/datum/surgery_operation/limb/mechanic_wrench/state_check(obj/item/bodypart/limb)
	return LIMB_HAS_BONES(limb)

/datum/surgery_operation/limb/mechanic_wrench/all_required_strings()
	return ..() + list("kończyna musi mieć szkielet")

/datum/surgery_operation/limb/mechanic_wrench/get_default_radial_image()
	return get_item_radial_image(/obj/item/wrench)

/datum/surgery_operation/limb/mechanic_wrench/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz przykręcać śruby ([FORMAT_LIMB_OWNER(limb)])..."),
		span_notice("[surgeon] zaczyna przykręcać śruby ([FORMAT_LIMB_OWNER(limb)])."),
		span_notice("[surgeon] zaczyna przykręcać śruby ([FORMAT_LIMB_OWNER(limb)])."),
	)
	display_pain(limb.owner, "Coś szarpie w kończynie ([strefa_pl(limb.body_zone)]), gdy śruby się dokręcają.", TRUE)

/datum/surgery_operation/limb/mechanic_wrench/on_success(obj/item/bodypart/limb)
	. = ..()
	limb.remove_surgical_state(SURGERY_BONE_SAWED)
