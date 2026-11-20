// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Fryzury i zarost z innych kodów: każdy ma swój stan w human_face_extra.dmi i trafił do list wyboru
/datum/unit_test/aquila_extra_hair

/datum/unit_test/aquila_extra_hair/Run()
	var/list/states = icon_states('aquila/icons/mob/human_face_extra.dmi')
	var/hair_count = 0
	for(var/path in subtypesof(/datum/sprite_accessory/hair) + subtypesof(/datum/sprite_accessory/facial_hair))
		var/datum/sprite_accessory/accessory = path
		if(initial(accessory.icon) != 'aquila/icons/mob/human_face_extra.dmi')
			continue
		hair_count++
		TEST_ASSERT(initial(accessory.icon_state) in states, "[path] has no state [initial(accessory.icon_state)] in human_face_extra.dmi")
		var/name = initial(accessory.name)
		var/list/style_list = ispath(path, /datum/sprite_accessory/hair) ? GLOB.hair_styles_list : GLOB.facial_hair_styles_list
		TEST_ASSERT(style_list[name] && style_list[name].type == path, "[path] ([name]) is missing from its style list or shares its name with another style")
	// Po odrzuceniu dubli kształtu (przegląd bloatu, S2) zostało 237 pozycji
	TEST_ASSERT(hair_count >= 230, "Only [hair_count] imported hair and facial hair styles, expected over 230")

#undef TEST_ASSERT
