// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - etap broni statkowej (podawanie, komorowanie) trafia do danych okna z postępem i znika po zakończeniu
/datum/unit_test/weapon_cycle_stage

/datum/unit_test/weapon_cycle_stage/Run()
	var/obj/machinery/ship_weapon/vls/gun = allocate(/obj/machinery/ship_weapon/vls, run_loc_floor_bottom_left)

	gun.cycle_sleep(2, "chamber")
	TEST_ASSERT(isnull(gun.cycle_stage), "A stage shorter than the minimum was shown in the weapon window")

	INVOKE_ASYNC(gun, TYPE_PROC_REF(/obj/machinery/ship_weapon, cycle_sleep), 20, "feed")
	var/list/data = list()
	gun.cycle_stage_ui_data(data)
	TEST_ASSERT(data["cycle_stage"] == "feed", "The weapon window does not see the feed stage")
	TEST_ASSERT(data["cycle_stage_progress"] == 0, "The stage did not start empty ([data["cycle_stage_progress"]])")

	sleep(10)
	data = list()
	gun.cycle_stage_ui_data(data)
	TEST_ASSERT(data["cycle_stage_progress"] > 0 && data["cycle_stage_progress"] < 1, "The stage did not advance mid-way ([data["cycle_stage_progress"]])")
	TEST_ASSERT(data["cycle_stage_time_left"] > 0 && data["cycle_stage_time_left"] < 20, "Wrong time left mid-stage ([data["cycle_stage_time_left"]])")
	TEST_ASSERT(data["cycle_stage_real_time_left"] >= data["cycle_stage_time_left"], "Real time left is shorter than game time left")

	// Nowszy etap w trakcie starszego (start ok. 10, koniec ok. 40): koniec starszego (ok. 20) nie może go skasować.
	// Sprawdzenia mają po 5 ds zapasu od końców etapów, żeby przesunięcie wznowienia o tick nie dawało fałszywych wyników.
	INVOKE_ASYNC(gun, TYPE_PROC_REF(/obj/machinery/ship_weapon, cycle_sleep), 30, "chamber")
	sleep(15)
	TEST_ASSERT(gun.cycle_stage == "chamber", "The end of an older stage cleared a newer one")

	sleep(20)
	data = list()
	gun.cycle_stage_ui_data(data)
	TEST_ASSERT(isnull(data["cycle_stage"]), "The stage stayed in the weapon window after it ended")

#undef TEST_ASSERT
