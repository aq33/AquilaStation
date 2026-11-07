// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - multiz_levels (tgstation/tgstation#76248): na każdym z-levelu piętro wyżej i niżej wychodzi tak samo jak dawniej z level_trait()
/datum/unit_test/aquila_multiz_levels

/datum/unit_test/aquila_multiz_levels/Run()
	TEST_ASSERT(length(SSmapping.multiz_levels) >= length(SSmapping.z_list), "multiz_levels ([length(SSmapping.multiz_levels)]) krótsze niż z_list ([length(SSmapping.z_list)])")
	var/linked_levels = 0
	for(var/datum/space_level/level as anything in SSmapping.z_list)
		var/z = level.z_value
		var/turf/center = locate(round(world.maxx / 2), round(world.maxy / 2), z)
		TEST_ASSERT(center, "Brak kafelka na środku z-levelu [z]")
		// Dawne SSmapping.get_turf_above/below: przesunięcie z cechy mapy
		var/up_offset = level.traits[ZTRAIT_UP]
		var/down_offset = level.traits[ZTRAIT_DOWN]
		var/turf/old_above = up_offset ? locate(center.x, center.y, z + up_offset) : null
		var/turf/old_below = down_offset ? locate(center.x, center.y, z + down_offset) : null
		if(old_above || old_below)
			linked_levels++
		TEST_ASSERT(GET_TURF_ABOVE(center) == old_above, "Z [z] ([level.name]): GET_TURF_ABOVE dał [GET_TURF_ABOVE(center)], dawniej [old_above]")
		TEST_ASSERT(GET_TURF_BELOW(center) == old_below, "Z [z] ([level.name]): GET_TURF_BELOW dał [GET_TURF_BELOW(center)], dawniej [old_below]")
		TEST_ASSERT(SSmapping.get_turf_above(center) == old_above, "Z [z] ([level.name]): get_turf_above różni się od dawnego wyniku")
		TEST_ASSERT(SSmapping.get_turf_below(center) == old_below, "Z [z] ([level.name]): get_turf_below różni się od dawnego wyniku")
		// Dawne turf.above()/below(): get_step(dawny kafelek, 0)
		TEST_ASSERT(center.above() == get_step(old_above, 0), "Z [z] ([level.name]): above() różni się od dawnego get_step_multiz")
		TEST_ASSERT(center.below() == get_step(old_below, 0), "Z [z] ([level.name]): below() różni się od dawnego get_step_multiz")
		TEST_ASSERT(get_step_multiz(center, UP|NORTH) == get_step(old_above, NORTH), "Z [z] ([level.name]): get_step_multiz(UP|NORTH) różni się od dawnego")
	TEST_ASSERT(linked_levels, "Żaden z-level nie ma połączenia pięter, test niczego nie sprawdził")

	// Przedmiot w pojemniku (z = 0) nie ma piętra wyżej ani niżej, jak dawniej
	var/obj/item/storage/box/box = allocate(/obj/item/storage/box, run_loc_floor_bottom_left)
	var/obj/item/toy/crayon/red/crayon = allocate(/obj/item/toy/crayon/red, box)
	TEST_ASSERT(isnull(SSmapping.get_turf_above(crayon)), "Przedmiot w pojemniku dostał kafelek nad sobą")
	TEST_ASSERT(isnull(SSmapping.get_turf_below(crayon)), "Przedmiot w pojemniku dostał kafelek pod sobą")

#undef TEST_ASSERT
