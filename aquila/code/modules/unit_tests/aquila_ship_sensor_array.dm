// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - matryca sensorów: zasięg zestawów rośnie z zasięgiem matrycy, bez matrycy zostaje krótka kamera
/datum/unit_test/ship_sensor_array
	var/obj/machinery/ship_sensor_array/array
	var/obj/structure/overmap/ship
	var/datum/turf_reservation/site
	var/old_had
	var/list/old_arrays

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

	// Zasięg dochodzi do ustawionego o 1 na cykl, a zestawy skalują się z nim
	array.desired_range = 5
	for(var/i in 1 to 6)
		array.process(2)
	TEST_ASSERT(array.range == 5, "The sensor array didn't ramp up to the desired range ([array.range])")
	TEST_ASSERT(abs(ship.get_sensor_array_mult(SENSOR_TELESCOPE) - 0.5) < 0.001, "Range 5 doesn't give half of the telescope range")

	// Limit sensorów z podziału mocy obcina zasięg
	ship.get_ship_power().limits[SHIP_POWER_SENSORS] = 0.25
	TEST_ASSERT(array.allowed_range() == 5, "A 25% power limit doesn't cap the range at 5 ([array.allowed_range()])")
	ship.get_ship_power().limits[SHIP_POWER_SENSORS] = 1

	// Rozbita matryca: zostaje tylko kamera na 25% zasięgu
	array.take_damage(INFINITY, BRUTE, "bomb", FALSE)
	TEST_ASSERT(!QDELETED(array) && (array.machine_stat & BROKEN), "A destroyed sensor array didn't stay as a wreck")
	TEST_ASSERT(ship.get_sensor_array_mult(SENSOR_TELESCOPE) == 0, "The telescope still works without a sensor array")
	TEST_ASSERT(ship.get_sensor_array_mult(SENSOR_OPTICAL) == 0.25, "The camera doesn't keep a quarter of its range without a sensor array")

	// Przegrzanie wyłącza i uszkadza matrycę
	array.set_machine_stat(array.machine_stat & ~BROKEN)
	array.obj_integrity = array.max_integrity
	array.on = TRUE
	array.heat = 1000
	array.process(2)
	TEST_ASSERT(!array.on, "An overheated sensor array stayed on")
	TEST_ASSERT(array.obj_integrity < array.max_integrity, "An overheated sensor array took no damage")

/datum/unit_test/ship_sensor_array/Destroy()
	QDEL_NULL(array)
	if(ship)
		ship.had_sensor_array = old_had
		ship.sensor_arrays = old_arrays
	QDEL_NULL(site)
	return ..()

#undef TEST_ASSERT
