// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - GLOB.huds is a positional list: every HUD define must point at the HUD written for it, and nothing may sit past the last define
/datum/unit_test/aquila_huds_indices

/datum/unit_test/aquila_huds_indices/Run()
	// Pairs instead of an associative literal: numeric keys in list() do not compile on 516
	var/list/expected = list(
		list(DATA_HUD_SECURITY_BASIC, /datum/atom_hud/data/human/security/basic),
		list(DATA_HUD_SECURITY_ADVANCED, /datum/atom_hud/data/human/security/advanced),
		list(DATA_HUD_MEDICAL_BASIC, /datum/atom_hud/data/human/medical/basic),
		list(DATA_HUD_MEDICAL_ADVANCED, /datum/atom_hud/data/human/medical/advanced),
		list(DATA_HUD_DIAGNOSTIC_BASIC, /datum/atom_hud/data/diagnostic/basic),
		list(DATA_HUD_DIAGNOSTIC_ADVANCED, /datum/atom_hud/data/diagnostic/advanced),
		list(DATA_HUD_ABDUCTOR, /datum/atom_hud/abductor),
		list(DATA_HUD_SENTIENT_DISEASE, /datum/atom_hud/sentient_disease),
		list(DATA_HUD_AI_DETECT, /datum/atom_hud/ai_detector),
		list(ANTAG_HUD_CULT, /datum/atom_hud/antag),
		list(ANTAG_HUD_OPS, /datum/atom_hud/antag),
		list(ANTAG_HUD_TRAITOR, /datum/atom_hud/antag/hidden),
		list(ANTAG_HUD_CHANGELING, /datum/atom_hud/antag/hidden),
		list(ANTAG_HUD_HERETIC, /datum/atom_hud/antag/hidden),
		list(ANTAG_HUD_BLOODLING, /datum/atom_hud/antag),
		list(DATA_HUD_SQUAD, /datum/atom_hud/data/human/squad_hud),
		list(ANTAG_HUD_VAMPIRE, /datum/atom_hud/antag),
		list(ANTAG_HUD_PARADOX_CLONE, /datum/atom_hud/antag/hidden),
	)
	var/highest_index = 0
	for(var/list/pair as anything in expected)
		var/index = pair[1]
		var/expected_type = pair[2]
		highest_index = max(highest_index, index)
		TEST_ASSERT(index <= length(GLOB.huds), "HUD index [index] ([expected_type]) is past the end of GLOB.huds ([length(GLOB.huds)])")
		var/datum/atom_hud/hud = GLOB.huds[index]
		TEST_ASSERT(hud?.type == expected_type, "GLOB.huds\[[index]\] is [hud?.type || "null"], expected [expected_type]")
	// Drużyny (gang, hivemind, overthrow, lunatyk, arena) dopisują swoje HUD-y na końcu w trakcie rundy, więc tylko dolna granica
	TEST_ASSERT(length(GLOB.huds) >= highest_index, "GLOB.huds has [length(GLOB.huds)] entries, the highest HUD define is [highest_index]")

#undef TEST_ASSERT
