// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - przyciski mocy genetycznych mają ikonę z Goona i przezroczyste tło, także w starym systemie zaklęć
/datum/unit_test/aquila_goon_genetics_icons

/datum/unit_test/aquila_goon_genetics_icons/Run()
	var/list/old_spells = list(
		/obj/effect/proc_holder/spell/aimed/firebreath,
		/obj/effect/proc_holder/spell/aimed/cryo,
		/obj/effect/proc_holder/spell/targeted/vore,
		/obj/effect/proc_holder/spell/targeted/mindread,
		/obj/effect/proc_holder/spell/self/void,
		/obj/effect/proc_holder/spell/self/self_amputation,
	)
	for(var/spell_type in old_spells)
		var/obj/effect/proc_holder/spell/spell = allocate(spell_type)
		var/datum/action/spell_action/action = spell.action
		TEST_ASSERT(action, "[spell_type] nie ma przycisku akcji")
		TEST_ASSERT(icon_exists(action.icon_icon, action.button_icon_state), "[spell_type]: brak ikony [action.button_icon_state]")
		check_empty_background(action, spell_type)
	// zaklęcia celowane przełączają ikonę na wersję aktywną
	for(var/state in list("firebreath1", "cryokinesis1"))
		TEST_ASSERT(icon_exists('goon/icons/mob/genetics_powers.dmi', state), "Brak aktywnej ikony [state]")

	var/list/new_spells = list(
		/datum/action/cooldown/spell/pointed/paradise_empath,
		/datum/action/cooldown/spell/pointed/paradise_polymorph,
		/datum/action/cooldown/spell/paradise/immolate,
		/datum/action/cooldown/spell/paradise/leap,
		/datum/action/cooldown/spell/adrenaline,
		/datum/action/cooldown/spell/touch/lay_on_hands,
		/datum/action/cooldown/spell/toggle/monke_xray,
	)
	for(var/action_type in new_spells)
		var/datum/action/action = new action_type(null)
		TEST_ASSERT(icon_exists(action.icon_icon, action.button_icon_state), "[action_type]: brak ikony [action.button_icon_state]")
		check_empty_background(action, action_type)
		qdel(action)

/// Tło przycisku musi istnieć i być przezroczyste, bo ramka jest wrysowana w ikonę
/datum/unit_test/aquila_goon_genetics_icons/proc/check_empty_background(datum/action/action, path)
	if(action.button_icon != 'aquila/icons/mob/actions/tlo_puste.dmi' || !icon_exists(action.button_icon, action.background_icon_state))
		Fail("[path]: tło przycisku [action.button_icon]:[action.background_icon_state] zamiast pustego")

#undef TEST_ASSERT
