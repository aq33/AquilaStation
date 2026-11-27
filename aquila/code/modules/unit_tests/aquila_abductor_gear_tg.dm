// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - promień zmniejszający i obce omninarzędzie porywaczy (tg): zmniejszenie działa i się cofa, omninarzędzie zmienia narzędzia
/datum/unit_test/aquila_abductor_gear_tg

/datum/unit_test/aquila_abductor_gear_tg/Run()
	var/list/gear_ids = list()
	for(var/datum/abductor_gear/gear as anything in GLOB.abductor_gear)
		gear_ids += initial(gear.id)
	TEST_ASSERT("shrink_ray" in gear_ids, "Abductor console has no shrink ray")
	TEST_ASSERT("omnitool" in gear_ids, "Abductor console has no omnitool")

	// trafienie promieniem zmniejsza człowieka: bez gęstości także po update_mobility(), po zdjęciu wszystko wraca
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/old_resistance = target.physiology.damage_resistance
	var/obj/item/projectile/energy/shrink/beam = allocate(/obj/item/projectile/energy/shrink)
	beam.shrink_time = -1
	beam.on_hit(target)
	var/datum/component/shrink/shrink = target.GetComponent(/datum/component/shrink)
	TEST_ASSERT(shrink, "Shrink ray hit did not shrink the human")
	target.update_mobility()
	TEST_ASSERT(!target.density, "Shrunk human is dense after update_mobility()")
	TEST_ASSERT(target.physiology.damage_resistance == old_resistance - 100, "Shrunk human does not take more damage")
	TEST_ASSERT(target.GetComponent(/datum/component/squashable), "Shrunk human cannot be squashed")
	qdel(shrink)
	TEST_ASSERT(target.density, "Human stayed undense after growing back")
	TEST_ASSERT(target.physiology.damage_resistance == old_resistance, "Damage resistance did not come back after growing back")
	TEST_ASSERT(!target.GetComponent(/datum/component/squashable), "Squashable stayed after growing back")

	// omninarzędzie: start z zestawem technicznym, przełączenie daje medyczny, wybrane narzędzie działa jak narzędzie
	var/obj/item/abductor/alien_omnitool/omnitool = allocate(/obj/item/abductor/alien_omnitool)
	TEST_ASSERT("Łom" in omnitool.tool_list, "Omnitool does not start with the hacking toolset")
	omnitool.set_toolset()
	TEST_ASSERT("Skalpel" in omnitool.tool_list, "Omnitool did not switch to the medical toolset")
	for(var/tool_name in omnitool.tool_list)
		TEST_ASSERT(aquila_omnitool_behaviours()[tool_name], "Omnitool tool [tool_name] has no tool behaviour")
	omnitool.tool_behaviour = aquila_omnitool_behaviours()["Skalpel"]
	TEST_ASSERT(omnitool.tool_behaviour == TOOL_SCALPEL, "Omnitool does not work as a scalpel")

#undef TEST_ASSERT
