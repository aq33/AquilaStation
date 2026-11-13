// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - kropla z gaśnicy, która odbija się od gęstej maszyny, gasi płonącą maszynę i pożar podłogi pod nią
/datum/unit_test/extinguisher_fire_under_machine

/datum/unit_test/extinguisher_fire_under_machine/Run()
	var/turf/open/spray_from = run_loc_floor_bottom_left
	var/turf/open/machine_turf = get_step(spray_from, EAST)
	TEST_ASSERT(istype(machine_turf), "No open turf east of the test room corner")

	var/obj/machinery/computer/machine = allocate(/obj/machinery/computer, machine_turf)
	TEST_ASSERT(machine.density, "The test machine is not dense, so the drop would not bump it")
	machine.resistance_flags |= FLAMMABLE
	machine.fire_act(1000, 100)
	TEST_ASSERT(machine.resistance_flags & ON_FIRE, "The test machine did not catch fire")

	// Magiczny pożar nie rusza atmosfery pokoju testowego
	var/obj/effect/abstract/turf_fire/magical/fire = new(machine_turf)
	TEST_ASSERT(machine_turf.turf_fire == fire, "The floor fire did not start under the machine")

	var/obj/effect/particle_effect/water/extinguisher/drop = new(spray_from)
	drop.create_reagents(5)
	drop.reagents.add_reagent(/datum/reagent/water, 1)
	drop.Move(machine_turf, EAST)
	var/drop_stopped = drop.loc == spray_from
	qdel(drop)

	// Efekty nie są sprzątane po teście, więc pożar usuwamy sami, zanim cokolwiek zawiedzie
	var/fire_survived = !QDELETED(fire)
	if(fire_survived)
		qdel(fire)

	TEST_ASSERT(drop_stopped, "The drop walked into the dense machine instead of bumping it")
	TEST_ASSERT(!(machine.resistance_flags & ON_FIRE), "The burning machine was not extinguished by the drop")
	TEST_ASSERT(!fire_survived, "The floor fire under the machine survived the drop")

#undef TEST_ASSERT
