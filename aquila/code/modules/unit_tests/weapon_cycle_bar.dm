// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - etap broni statkowej (podawanie, komorowanie) pokazuje pasek postępu nad bronią i zdejmuje go po zakończeniu
/datum/unit_test/weapon_cycle_bar

/datum/unit_test/weapon_cycle_bar/Run()
	var/obj/machinery/ship_weapon/vls/gun = allocate(/obj/machinery/ship_weapon/vls, run_loc_floor_bottom_left)

	gun.cycle_sleep(2)
	TEST_ASSERT(!gun.cycle_bar, "A stage shorter than the minimum created a progress bar")

	INVOKE_ASYNC(gun, TYPE_PROC_REF(/obj/machinery/ship_weapon, cycle_sleep), 10)
	TEST_ASSERT(gun.cycle_bar, "A weapon stage created no progress bar")
	TEST_ASSERT(gun.cycle_bar in gun.vis_contents, "The progress bar is not shown on the weapon")
	TEST_ASSERT(gun.cycle_bar.icon_state == "prog_bar_0", "The progress bar did not start empty")

	sleep(5)
	var/middle_state = gun.cycle_bar.icon_state
	TEST_ASSERT(middle_state != "prog_bar_0" && middle_state != "prog_bar_100", "The progress bar did not advance mid-stage ([middle_state])")

	sleep(6)
	TEST_ASSERT(gun.cycle_bar.icon_state == "prog_bar_100", "The progress bar did not fill up at the end of the stage")

	sleep(6)
	TEST_ASSERT(!(gun.cycle_bar in gun.vis_contents), "The progress bar stayed on the weapon after the stage")

#undef TEST_ASSERT
