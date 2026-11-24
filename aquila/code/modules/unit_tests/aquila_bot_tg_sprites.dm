// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - sprite'y botów z tg: każdy wygląd medibota (apteczka x tryb) i repairbota (następca floorbota) ma stan w pliku ikon
/datum/unit_test/aquila_bot_tg_sprites

/datum/unit_test/aquila_bot_tg_sprites/Run()
	var/list/states = icon_states('icons/mob/aibots.dmi')
	for(var/overlay_state in list("medbot_overlay_wheels", "medbot_overlay_on_idle", "medbot_overlay_on_active", "medbot_overlay_incapacitated"))
		TEST_ASSERT(overlay_state in states, "Brak nakładki medibota [overlay_state]")

	var/list/skins = list(null, MEDBOT_SKIN_DEFAULT, MEDBOT_SKIN_BRUTE, MEDBOT_SKIN_BURN, MEDBOT_SKIN_TOXIN, MEDBOT_SKIN_OXY, MEDBOT_SKIN_SURGERY, MEDBOT_SKIN_ADVANCED, MEDBOT_SKIN_RADIATION, MEDBOT_SKIN_SYNDI, MEDBOT_SKIN_BEZERK, MEDBOT_SKIN_ROBOT)
	for(var/skin in skins)
		var/mob/living/basic/bot/medbot/medbot = allocate(/mob/living/basic/bot/medbot, run_loc_floor_bottom_left, skin)
		TEST_ASSERT(medbot.icon_state in states, "Medibot z apteczką [skin || "brak"] ma stan bez grafiki: [medbot.icon_state]")
		medbot.update_bot_mode(BBOT_HEALING)
		TEST_ASSERT(medbot.icon_state in states, "Leczący medibot z apteczką [skin || "brak"] ma stan bez grafiki: [medbot.icon_state]")
		if(skin)
			TEST_ASSERT(("kit_skin_[skin]" in states) || skin == MEDBOT_SKIN_DEFAULT || skin == MEDBOT_SKIN_BEZERK, "Brak stanu zespołu medibota kit_skin_[skin]")

	var/list/repair_states = icon_states('aquila/icons/mob/bots/tg_bots.dmi')
	for(var/toolbox_color in list("", "r", "y", "g", "s"))
		var/mob/living/basic/bot/repairbot/repairbot = allocate(/mob/living/basic/bot/repairbot, run_loc_floor_bottom_left, toolbox_color)
		TEST_ASSERT(repairbot.icon_state in repair_states, "Repairbot w kolorze '[toolbox_color]' ma stan bez grafiki: [repairbot.icon_state]")
		TEST_ASSERT(repairbot.get_toolbox_tint(), "Repairbot w kolorze '[toolbox_color]' nie ma barwy skrzynki")
	for(var/overlay_state in list("repairbot0", "repairbot1", "repairbot_box", "repairbot_base_sensor", "repairbot_base_arms", "repairbot_iron_overlay", "repairbot_glass_overlay"))
		TEST_ASSERT(overlay_state in repair_states, "Brak stanu repairbota [overlay_state]")

#undef TEST_ASSERT
