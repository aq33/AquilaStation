// Makra TEST_ASSERT są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc test modularny ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - kanister pęka od wnętrza (aquila/code/modules/atmospherics/machinery/portable/canister.dm):
/// pełny kanister z pompy nie niszczeje, mieszanina ponad 50 000 kPa rozrywa go w kilkudziesięciu cyklach.
/datum/unit_test/aquila_canister_overpressure

/datum/unit_test/aquila_canister_overpressure/Run()
	var/obj/machinery/portable_atmospherics/canister/canister = allocate(/obj/machinery/portable_atmospherics/canister, run_loc_floor_bottom_left)
	// pęknięty kanister wypuszcza gaz na kafelek, a pokój testowy nie jest czyszczony między testami
	var/turf/open/floor = run_loc_floor_bottom_left
	var/datum/gas_mixture/floor_backup = new
	floor_backup.copy_from(floor.air)
	var/datum/gas_mixture/air = canister.air_contents
	var/volume = air.return_volume()

	// 9000 kPa (maks. pompy objętościowej) w 1500 K: bez obrażeń
	air.clear()
	air.set_temperature(1500)
	air.set_moles(GAS_N2, 9000 * volume / (R_IDEAL_GAS_EQUATION * 1500))
	TEST_ASSERT(!canister.aq_take_atmos_damage(), "Kanister niszczeje przy 9000 kPa i 1500 K")
	TEST_ASSERT(canister.obj_integrity == canister.max_integrity, "Kanister stracił integralność przy zwykłym napełnieniu")

	// 80 000 kPa: niszczeje i pęka
	air.clear()
	air.set_temperature(T20C)
	air.set_moles(GAS_N2, 80000 * volume / (R_IDEAL_GAS_EQUATION * T20C))
	for(var/i in 1 to 40)
		if(canister.machine_stat & BROKEN)
			break
		canister.aq_take_atmos_damage()
	TEST_ASSERT(canister.machine_stat & BROKEN, "Kanister z 80 000 kPa nie pękł po 40 cyklach")
	var/released_moles = floor.air.total_moles() - floor_backup.total_moles()
	floor.air.copy_from(floor_backup)
	floor.air_update_turf()
	TEST_ASSERT(canister.air_contents.total_moles() < 1, "Pęknięty kanister nie wypuścił gazu")
	TEST_ASSERT(released_moles > 1, "Gaz z pękniętego kanistra nie trafił na kafelek")

#undef TEST_ASSERT
