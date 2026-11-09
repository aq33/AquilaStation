// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - sprite'y botów z tg: każdy wygląd medibota (apteczka x tryb) i floorbota (kolor skrzynki) ma stan w pliku ikon
/datum/unit_test/aquila_bot_tg_sprites

/datum/unit_test/aquila_bot_tg_sprites/Run()
	var/list/states = icon_states('icons/mob/aibots.dmi')
	for(var/overlay_state in list("medbot_overlay_wheels", "medbot_overlay_on_idle", "medbot_overlay_on_active", "medbot_overlay_incapacitated"))
		TEST_ASSERT(overlay_state in states, "Brak nakładki medibota [overlay_state]")

	var/list/skins = list(null, MEDBOT_SKIN_DEFAULT, MEDBOT_SKIN_BRUTE, MEDBOT_SKIN_BURN, MEDBOT_SKIN_TOXIN, MEDBOT_SKIN_OXY, MEDBOT_SKIN_SURGERY, MEDBOT_SKIN_ADVANCED, MEDBOT_SKIN_RADIATION, MEDBOT_SKIN_SYNDI, MEDBOT_SKIN_BEZERK, MEDBOT_SKIN_ROBOT)
	for(var/skin in skins)
		var/mob/living/simple_animal/bot/medbot/medbot = allocate(/mob/living/simple_animal/bot/medbot, null, skin)
		TEST_ASSERT(medbot.icon_state in states, "Medibot z apteczką [skin || "brak"] ma stan bez grafiki: [medbot.icon_state]")
		medbot.mode = BOT_HEALING
		medbot.update_icon()
		TEST_ASSERT(medbot.icon_state in states, "Leczący medibot z apteczką [skin || "brak"] ma stan bez grafiki: [medbot.icon_state]")
		if(skin)
			TEST_ASSERT(("kit_skin_[skin]" in states) || skin == MEDBOT_SKIN_DEFAULT || skin == MEDBOT_SKIN_BEZERK, "Brak stanu zespołu medibota kit_skin_[skin]")

	for(var/toolbox_color in list("", "r", "y", "g", "s"))
		var/mob/living/simple_animal/bot/floorbot/floorbot = allocate(/mob/living/simple_animal/bot/floorbot, null, toolbox_color)
		floorbot.update_icon()
		TEST_ASSERT(floorbot.icon_state in states, "Floorbot w kolorze '[toolbox_color]' ma stan bez grafiki: [floorbot.icon_state]")
		for(var/suffix in list("floorbot0", "floorbot1", "floorbot-c", "toolbox_tiles", "toolbox_tiles_sensor"))
			TEST_ASSERT("[toolbox_color][suffix]" in states, "Brak stanu [toolbox_color][suffix]")

#undef TEST_ASSERT
