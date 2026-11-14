// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - dysze okrętowe: ciąg statku zależy od dysz, które mają prąd, paliwo w zbiornikach statku i nie są rozbite
/datum/unit_test/ship_thrusters
	var/datum/turf_reservation/site
	var/obj/machinery/ship_thruster/large/thruster
	var/obj/machinery/atmospherics/components/unary/shuttle/heater/ship/tank
	var/obj/structure/overmap/ship
	var/old_design
	var/old_forward
	var/list/old_tanks
	var/old_tanks_refresh

/datum/unit_test/ship_thrusters/Run()
	ship = SSstar_system.find_main_overmap()
	TEST_ASSERT(ship, "No main ship to attach the thruster to")
	old_design = ship.engine_thrust_design
	old_forward = ship.last_thrust_forward
	old_tanks = ship.engine_fuel_tanks
	old_tanks_refresh = ship.engine_fuel_tanks_refresh

	// Statek bez dysz okrętowych ma pełny ciąg, a przy samych zepsutych dyszach zostaje ciąg awaryjny
	ship.engine_thrust_design = 0
	TEST_ASSERT_EQUAL(ship.get_engine_thrust_mult(), 1, "A ship without ship thrusters lost thrust")
	ship.engine_thrust_design = 10
	var/old_active = ship.engine_thrust_active
	ship.engine_thrust_active = 0
	TEST_ASSERT_EQUAL(ship.get_engine_thrust_mult(), 0.1, "A ship with every thruster down has no emergency thrust")
	ship.engine_thrust_active = 10
	TEST_ASSERT_EQUAL(ship.get_engine_thrust_mult(), 1, "A ship with every thruster working has reduced thrust")
	ship.engine_thrust_active = old_active
	ship.engine_thrust_design = old_design

	site = SSmapping.RequestBlockReservation(10, 10)
	var/list/bl = site.bottom_left_coords
	var/x0 = bl[1] + 2
	var/y0 = bl[2] + 2
	var/z = bl[3]
	for(var/turf/T as anything in block(locate(x0, y0, z), locate(x0 + 5, y0 + 2, z)))
		T.ChangeTurf(/turf/open/floor/plasteel)

	// Zbiornik zbudowany w trakcie rundy nie daje darmowej plazmy
	tank = new(locate(x0 + 4, y0, z))
	var/datum/gas_mixture/air_contents = tank.airs[1]
	TEST_ASSERT_EQUAL(air_contents.get_moles(tank.gas_type), 0, "A fuel tank built mid-round came with free plasma")
	air_contents.set_moles(tank.gas_type, 100)
	// Zbiornik stoi poza statkiem (rezerwacja), więc podpinamy go do statku na czas testu
	ship.engine_fuel_tanks = list(tank)
	ship.engine_fuel_tanks_refresh = world.time + 1 HOURS
	TEST_ASSERT_EQUAL(ship.get_engine_fuel(), 100, "The ship doesn't see the plasma in its fuel tank")

	thruster = new(locate(x0, y0, z))
	thruster.link_to_ship(ship)
	thruster.set_machine_stat(thruster.machine_stat & ~NOPOWER)
	var/design_with_ours = ship.engine_thrust_design
	TEST_ASSERT(design_with_ours >= thruster.thrust_power, "The registered thruster isn't counted in the ship's design thrust")

	thruster.process(2)
	TEST_ASSERT(thruster.can_fire, "A powered thruster on a fuelled ship can't fire")
	var/active_with_ours = ship.engine_thrust_active

	// Paliwo schodzi tylko przy ciągu
	thruster.process(2)
	TEST_ASSERT_EQUAL(ship.get_engine_fuel(), 100, "The thruster burned plasma while the ship wasn't thrusting")
	ship.last_thrust_forward = 1
	thruster.process(2)
	ship.last_thrust_forward = old_forward
	TEST_ASSERT_EQUAL(round(ship.get_engine_fuel(), 0.01), round(100 - thruster.fuel_per_second * 2, 0.01), "The thruster didn't burn plasma while the ship was thrusting")

	// Bez plazmy dysza nie odpala i statek traci jej ciąg, ale nie ciąg projektowy
	air_contents.set_moles(tank.gas_type, 0)
	thruster.process(2)
	TEST_ASSERT(!thruster.can_fire, "A thruster can still fire with empty fuel tanks")
	TEST_ASSERT_EQUAL(ship.engine_thrust_active, active_with_ours - thruster.thrust_power, "An unfuelled thruster still gives the ship thrust")
	TEST_ASSERT_EQUAL(ship.engine_thrust_design, design_with_ours, "An unfuelled thruster lowered the ship's design thrust")

	// Rozkręcony zbiornik nie daje paliwa
	air_contents.set_moles(tank.gas_type, 100)
	tank.panel_open = TRUE
	TEST_ASSERT_EQUAL(ship.get_engine_fuel(), 0, "A fuel tank with an open panel still feeds the thrusters")
	tank.panel_open = FALSE

	// Zniszczona dysza zostaje jako wrak i po naprawie znowu działa
	thruster.process(2)
	TEST_ASSERT(thruster.can_fire, "A refuelled thruster can't fire")
	thruster.take_damage(INFINITY, BRUTE, "bomb", FALSE)
	TEST_ASSERT(!QDELETED(thruster), "A destroyed thruster was deleted instead of staying as a wreck")
	TEST_ASSERT(thruster.machine_stat & BROKEN, "A destroyed thruster isn't broken")
	TEST_ASSERT(!thruster.can_fire, "A broken thruster can still fire")
	TEST_ASSERT_EQUAL(ship.engine_thrust_active, active_with_ours - thruster.thrust_power, "A broken thruster still gives the ship thrust")
	thruster.finish_repair()
	thruster.process(2)
	TEST_ASSERT(thruster.can_fire, "A repaired thruster can't fire")
	TEST_ASSERT_EQUAL(thruster.obj_integrity, thruster.max_integrity, "A repaired thruster isn't at full integrity")

/datum/unit_test/ship_thrusters/Destroy()
	QDEL_NULL(thruster)
	QDEL_NULL(tank)
	if(ship)
		ship.last_thrust_forward = old_forward
		ship.engine_fuel_tanks = old_tanks
		ship.engine_fuel_tanks_refresh = old_tanks_refresh
		ship.engine_thrust_design = old_design
		ship.recalculate_engine_thrust()
	QDEL_NULL(site)
	return ..()

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
