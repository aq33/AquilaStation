// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b][message ? ": [message]" : ""]") }

/// Markingi na kończynach: każdy ma sprite'y, okno postaci zapisuje je w features, ręka rysuje nakładkę, amputowana ręka ją zabiera
/datum/unit_test/aquila_body_markings

/datum/unit_test/aquila_body_markings/Run()
	TEST_ASSERT(length(GLOB.aq_body_markings) >= 200, "Only [length(GLOB.aq_body_markings)] body markings were loaded")
	var/datum/aq_body_marking/arm_marking
	for(var/id in GLOB.aq_body_markings)
		var/datum/aq_body_marking/marking = GLOB.aq_body_markings[id]
		TEST_ASSERT(length(marking.zones), "Marking [id] has no body zones")
		for(var/zone in marking.zones)
			TEST_ASSERT(zone in GLOB.aq_body_marking_zones, "Marking [id] uses unknown zone [zone]")
			if(zone == BODY_ZONE_CHEST)
				TEST_ASSERT(icon_exists(AQ_BODY_MARKINGS_ICON, "[id]_chest_m") && icon_exists(AQ_BODY_MARKINGS_ICON, "[id]_chest_f"), "Marking [id] has no chest sprites")
			else
				TEST_ASSERT(icon_exists(AQ_BODY_MARKINGS_ICON, "[id]_[zone]"), "Marking [id] has no sprite for [zone]")
		if(!arm_marking && (BODY_ZONE_R_ARM in marking.zones))
			arm_marking = marking
	TEST_ASSERT(arm_marking, "No marking can go on the right arm")

	// Okno postaci: dodanie, limit na część ciała, odrzucenie złej strefy
	var/datum/preferences/prefs = new
	prefs.active_character = prefs.character_saves[1]
	prefs.active_character.pref_species = new /datum/species/human
	var/datum/preference_middleware/aq_body_markings/middleware = new(prefs)
	middleware.add_marking(list("zone" = BODY_ZONE_R_ARM, "id" = arm_marking.id), null)
	var/list/saved = aq_markings_decode(prefs.active_character.features[AQ_MARKINGS_FEATURE])
	TEST_ASSERT_EQUAL(length(saved[BODY_ZONE_R_ARM]), 1, "Adding a marking in the window did not save it")
	for(var/i in 1 to AQ_MARKINGS_PER_ZONE + 1)
		middleware.add_marking(list("zone" = BODY_ZONE_R_ARM, "id" = arm_marking.id), null)
	saved = aq_markings_decode(prefs.active_character.features[AQ_MARKINGS_FEATURE])
	TEST_ASSERT_EQUAL(length(saved[BODY_ZONE_R_ARM]), AQ_MARKINGS_PER_ZONE, "A body part took more markings than the limit")
	for(var/i in 2 to AQ_MARKINGS_PER_ZONE)
		middleware.remove_marking(list("zone" = BODY_ZONE_R_ARM, "index" = 2), null)
	middleware.add_marking(list("zone" = "tail", "id" = arm_marking.id), null)
	saved = aq_markings_decode(prefs.active_character.features[AQ_MARKINGS_FEATURE])
	TEST_ASSERT_EQUAL(length(saved[BODY_ZONE_R_ARM]), 1, "Removing markings in the window did not work")
	TEST_ASSERT(isnull(saved["tail"]), "A marking was saved on a body part outside the editor")
	saved[BODY_ZONE_R_ARM][1][2] = "#ff0000"
	prefs.active_character.features[AQ_MARKINGS_FEATURE] = aq_markings_encode(saved)
	qdel(middleware)

	// Zapis i odczyt: features idą do bazy jako JSON
	var/datum/character_save/save = prefs.active_character
	save.features = character_json_decode(json_encode(save.features), list())
	var/list/loaded = aq_markings_decode(save.features[AQ_MARKINGS_FEATURE])
	TEST_ASSERT_EQUAL(loaded[BODY_ZONE_R_ARM]?[1]?[1], arm_marking.id, "The marking was lost after saving the character")
	TEST_ASSERT_EQUAL(loaded[BODY_ZONE_R_ARM]?[1]?[2], "#ff0000", "The marking color was lost after saving the character")
	TEST_ASSERT(!length(aq_markings_decode("{\"r_arm\": \[\[\"no_such_marking\", \"#FFFFFF\"\]\]}")), "An unknown marking passed the check")
	TEST_ASSERT(!length(aq_markings_decode("not json")), "Broken text passed the check")

	// Postać z preferencji: ręka rysuje marking, amputowana ręka go zabiera
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	save.copy_to(dummy)
	var/state = "[arm_marking.id]_[BODY_ZONE_R_ARM]"
	TEST_ASSERT(has_body_marking_overlay(dummy, state, "#ff0000"), "The right arm does not draw its marking")
	var/obj/item/bodypart/r_arm/arm = dummy.get_bodypart(BODY_ZONE_R_ARM)
	TEST_ASSERT(arm, "The dummy has no right arm")
	arm.drop_limb()
	TEST_ASSERT(!has_body_marking_overlay(dummy, state), "The marking stayed on the body after the arm was cut off")
	TEST_ASSERT(length(arm.aq_markings), "The cut off arm lost its marking")
	qdel(arm)

	// Rasa bez markingów ich nie rysuje
	dummy.regenerate_limbs()
	dummy.update_body_parts(TRUE)
	TEST_ASSERT(has_body_marking_overlay(dummy, state, "#ff0000"), "A regrown arm does not draw the marking from DNA")
	dummy.set_species(/datum/species/jelly)
	dummy.update_body_parts(TRUE)
	TEST_ASSERT(!has_body_marking_overlay(dummy, state), "A species without body markings draws them")

/// Czy na warstwie kończyn jest nakładka markingu o tym stanie (i kolorze)
/datum/unit_test/aquila_body_markings/proc/has_body_marking_overlay(mob/living/carbon/human/target, state, color)
	for(var/image/overlay in target.overlays_standing[BODYPARTS_LAYER])
		if(overlay.icon == AQ_BODY_MARKINGS_ICON && overlay.icon_state == state && (!color || overlay.color == color))
			return TRUE
	return FALSE

/// Okno postaci: każdy marking ma podgląd na każdej swojej części ciała, a listy wyboru pokazują polskie nazwy
/datum/unit_test/aquila_body_markings_window

/datum/unit_test/aquila_body_markings_window/Run()
	var/checked = 0
	for(var/id in GLOB.aq_body_markings)
		var/datum/aq_body_marking/marking = GLOB.aq_body_markings[id]
		for(var/zone in marking.zones)
			if(checked >= 40) // pełny arkusz generuje się przy starcie, tu wystarczy próbka
				break
			checked++
			TEST_ASSERT(isicon(aq_marking_preview_icon(marking, zone)), "Marking [id] has no preview for [zone]")
	TEST_ASSERT(checked, "No body markings to preview")

	var/datum/preference/choiced/hair = GLOB.preference_entries_by_key["hair_style_name"]
	var/list/hair_names = hair.get_display_names_with_polish()
	TEST_ASSERT_EQUAL(hair_names["Bald"], "Łysina", "The hairstyle list does not show Polish names")
	TEST_ASSERT("Bald" in hair.get_choices(), "Polish display names replaced the saved hairstyle values")
	var/datum/preference/choiced/voice = GLOB.preference_entries_by_key["speech_voice"]
	TEST_ASSERT_EQUAL(voice.get_display_names_with_polish()["speak_1"], "Głos 1", "Own display names were overwritten by the Polish list")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
