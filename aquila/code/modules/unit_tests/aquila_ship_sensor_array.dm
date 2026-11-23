// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - matryca sensorów: stały zasięg działającej matrycy, limit mocy go obcina, bez matrycy zostaje krótka kamera
/datum/unit_test/ship_sensor_array
	var/obj/machinery/ship_sensor_array/array
	var/obj/structure/overmap/ship
	var/datum/turf_reservation/site
	var/old_had
	var/list/old_arrays
	var/old_sensor_limit

/datum/unit_test/ship_sensor_array/Run()
	ship = SSstar_system.find_main_overmap()
	TEST_ASSERT(ship, "No main ship to attach the sensor array to")
	old_had = ship.had_sensor_array
	old_arrays = ship.sensor_arrays?.Copy()

	// Statek, który nigdy nie miał matrycy, widzi jak dotąd
	ship.had_sensor_array = FALSE
	TEST_ASSERT(ship.get_sensor_array_mult(SENSOR_TELESCOPE) == 1, "A ship without a sensor array lost sensor range")

	// Matryca w próżni (rezerwacja to kosmos)
	site = SSmapping.RequestBlockReservation(5, 5)
	var/list/bl = site.bottom_left_coords
	array = new(locate(bl[1] + 2, bl[2] + 2, bl[3]))
	ship.sensor_arrays = list()
	array.link_to_ship(ship)
	array.set_machine_stat(array.machine_stat & ~NOPOWER)
	TEST_ASSERT(ship.had_sensor_array, "Linking a sensor array didn't mark the ship")
	TEST_ASSERT(array.in_vacuum(), "The sensor array in space isn't in vacuum")

	// Ćwiartki: dziób na wschodzie mapy, prawa burta na południu
	TEST_ASSERT(sensor_array_sector_center(EAST) == 0 && sensor_array_sector_center(SOUTH) == 90 && sensor_array_sector_center(NORTH) == 270, "Sensor array sectors don't follow the bow on the east of the map")
	TEST_ASSERT(sensor_array_sector_name(WEST) == "rufa", "A west-facing sensor array doesn't cover the stern")

	// Działająca matryca od razu ma stały zasięg 6 i stały pobór, a zestawy skalują się z nim
	old_sensor_limit = ship.get_ship_power().limits[SHIP_POWER_SENSORS]
	ship.get_ship_power().limits[SHIP_POWER_SENSORS] = 1
	array.process(2)
	TEST_ASSERT(array.range == 6, "A working sensor array doesn't have the fixed range of 6 ([array.range])")
	TEST_ASSERT(array.active_power_usage == 5400, "A working sensor array doesn't draw the fixed 5.4 kW ([array.active_power_usage])")
	TEST_ASSERT(abs(ship.get_sensor_array_mult(SENSOR_TELESCOPE) - 0.6) < 0.001, "Range 6 doesn't give 60% of the telescope range")

	// Limit sensorów z podziału mocy obcina zasięg
	ship.get_ship_power().limits[SHIP_POWER_SENSORS] = 0.2
	array.process(2)
	TEST_ASSERT(array.range == 4, "A 20% power limit doesn't cap the range at 4 ([array.range])")
	ship.get_ship_power().limits[SHIP_POWER_SENSORS] = old_sensor_limit

	// Rozbita matryca: zostaje tylko kamera na 25% zasięgu
	array.take_damage(INFINITY, BRUTE, "bomb", FALSE)
	TEST_ASSERT(!QDELETED(array) && (array.machine_stat & BROKEN), "A destroyed sensor array didn't stay as a wreck")
	TEST_ASSERT(ship.get_sensor_array_mult(SENSOR_TELESCOPE) == 0, "The telescope still works without a sensor array")
	TEST_ASSERT(ship.get_sensor_array_mult(SENSOR_OPTICAL) == 0.25, "The camera doesn't keep a quarter of its range without a sensor array")
	array.process(2)
	TEST_ASSERT(array.range == 0, "A broken sensor array kept its range ([array.range])")

/datum/unit_test/ship_sensor_array/Destroy()
	QDEL_NULL(array)
	if(ship)
		ship.had_sensor_array = old_had
		ship.sensor_arrays = old_arrays
		if(!isnull(old_sensor_limit))
			ship.get_ship_power().limits[SHIP_POWER_SENSORS] = old_sensor_limit
	QDEL_NULL(site)
	return ..()

#undef TEST_ASSERT
