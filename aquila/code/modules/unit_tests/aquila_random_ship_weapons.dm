// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - losowe uzbrojenie: każdy slot ma pasujące warianty, każdy wariant ma swój slot
/datum/unit_test/aquila_random_ship_weapons

/datum/unit_test/aquila_random_ship_weapons/Run()
	var/list/templates = list()
	for(var/datum/map_template/random_room/template_type as anything in subtypesof(/datum/map_template/random_room))
		if(initial(template_type.room_group))
			templates += template_type

	var/list/slot_groups = list()
	for(var/obj/effect/spawner/room/spawner_type as anything in subtypesof(/obj/effect/spawner/room))
		var/group = initial(spawner_type.room_group)
		if(!group)
			continue
		slot_groups |= group
		var/variants = 0
		for(var/datum/map_template/random_room/template_type as anything in templates)
			if(initial(template_type.room_group) != group)
				continue
			TEST_ASSERT(initial(template_type.template_width) == initial(spawner_type.room_width) && initial(template_type.template_height) == initial(spawner_type.room_height), \
				"[template_type] ma inny rozmiar niż slot [spawner_type]")
			variants++
		TEST_ASSERT(variants, "Slot [spawner_type] nie ma żadnego wariantu z room_group \"[group]\"")

	for(var/datum/map_template/random_room/template_type as anything in templates)
		TEST_ASSERT(initial(template_type.room_group) in slot_groups, "[template_type] ma room_group \"[initial(template_type.room_group)]\", którego nie używa żaden spawner")
		// Plik .dmm musi się wczytać i mieć dokładnie zadeklarowany rozmiar
		var/datum/map_template/random_room/loaded = SSmapping.random_room_templates[initial(template_type.room_id)]
		TEST_ASSERT(loaded, "[template_type] nie trafił do SSmapping.random_room_templates")
		TEST_ASSERT(loaded.width == loaded.template_width && loaded.height == loaded.template_height, \
			"[loaded.mappath] ma [loaded.width]x[loaded.height], a [template_type] deklaruje [loaded.template_width]x[loaded.template_height]")

#undef TEST_ASSERT
