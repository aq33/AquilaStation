// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - drzwi z żywicy (Paradise): są w menu żywicy, nie otwierają się przed załogą, otwierają się przed obcym
/datum/unit_test/aquila_xeno_resin_door

/datum/unit_test/aquila_xeno_resin_door/Run()
	var/obj/effect/proc_holder/alien/resin/resin_power = allocate(/obj/effect/proc_holder/alien/resin)
	TEST_ASSERT(resin_power.structures["drzwi z żywicy"] == /obj/structure/alien/resin/door, "Resin power cannot shape a resin door")

	var/turf/door_turf = run_loc_floor_bottom_left
	var/turf/side_turf = locate(door_turf.x + 1, door_turf.y, door_turf.z)
	var/obj/structure/alien/resin/door/door = allocate(/obj/structure/alien/resin/door, door_turf)
	TEST_ASSERT(door.density && door.opacity, "Resin door starts open")

	var/mob/living/carbon/human/crew = allocate(/mob/living/carbon/human, side_turf)
	TEST_ASSERT(!door.try_to_operate(crew, TRUE), "Resin door opened for the crew")
	TEST_ASSERT(door.density, "Resin door stopped blocking after the crew tried it")

	var/mob/living/carbon/alien/humanoid/drone/xeno = allocate(/mob/living/carbon/alien/humanoid/drone, side_turf)
	TEST_ASSERT(door.try_to_operate(xeno, TRUE), "Resin door did not open for a xenomorph")
	TEST_ASSERT(door.state_open && !door.density && !door.opacity, "Resin door opened for a xenomorph is still blocking")

	// zamknięcie bez moba w przejściu (po operate_update, bez czekania na timer)
	door.operate_update(FALSE)
	door.mobless_try_to_operate()
	TEST_ASSERT(!door.state_open && door.density, "Resin door did not close again")

#undef TEST_ASSERT
