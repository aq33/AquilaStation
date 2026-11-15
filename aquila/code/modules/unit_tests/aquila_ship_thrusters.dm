// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - dysze okrętowe: ciąg statku zależy od dysz, które mają prąd, plazmę w podgrzewaczach za sobą i nie są rozbite
/datum/unit_test/ship_thrusters
	var/datum/turf_reservation/site
	var/obj/machinery/ship_thruster/large/thruster
	var/obj/machinery/atmospherics/components/unary/shuttle/heater/ship/tank
	var/obj/structure/overmap/ship
	var/old_design
	var/old_forward
	/// Obszar rezerwacji, do którego wracają pola za dyszą
	var/area/old_area
	var/list/powered_turfs

/datum/unit_test/ship_thrusters/Run()
	ship = SSstar_system.find_main_overmap()
	TEST_ASSERT(ship, "No main ship to attach the thruster to")
	old_design = ship.engine_thrust_design
	old_forward = ship.last_thrust_forward

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

	// Dysza 2x2 z wylotem na zachód, podgrzewacz dwa kafle za nią (jak za ścianą rufy)
	tank = new(locate(x0 + 3, y0 + 1, z))
	var/datum/gas_mixture/air_contents = tank.airs[1]
	TEST_ASSERT_EQUAL(air_contents.get_moles(tank.gas_type), 0, "A heater built mid-round came with free plasma")
	air_contents.set_moles(tank.gas_type, 100)
	thruster = new(locate(x0, y0, z))
	thruster.link_to_ship(ship)

	// Regresja: dysza stoi w próżni (obszar bez prądu) i bierze prąd z zasilanego obszaru statku za sobą
	// (Bez obszaru za dyszą wynik zależy od otoczenia: zapasowe szukanie w promieniu znajduje obszary innych testów)
	old_area = get_area(locate(x0 + 2, y0, z))
	var/area/testroom/engine_room = new
	powered_turfs = block(locate(x0 + 2, y0, z), locate(x0 + 5, y0 + 2, z))
	for(var/turf/T as anything in powered_turfs)
		engine_room.contents += T
	TEST_ASSERT(istype(get_area(thruster), old_area.type), "The test moved the thruster itself out of its space area")
	thruster.power_change()
	TEST_ASSERT(thruster.powered() && !(thruster.machine_stat & NOPOWER), "A thruster in space doesn't take power from the powered ship area behind it")
	TEST_ASSERT(tank in thruster.get_heaters(), "The thruster doesn't find the heater two tiles behind it")
	TEST_ASSERT_EQUAL(thruster.get_fuel(), 100, "The thruster doesn't see the plasma in its heater")
	var/design_with_ours = ship.engine_thrust_design
	TEST_ASSERT(design_with_ours >= thruster.thrust_power, "The registered thruster isn't counted in the ship's design thrust")

	thruster.process(2)
	TEST_ASSERT(thruster.can_fire, "A powered thruster with a fuelled heater can't fire")
	var/active_with_ours = ship.engine_thrust_active

	// Paliwo schodzi tylko przy ciągu
	thruster.process(2)
	TEST_ASSERT_EQUAL(thruster.get_fuel(), 100, "The thruster burned plasma while the ship wasn't thrusting")
	ship.last_thrust_forward = 1
	thruster.process(2)
	ship.last_thrust_forward = old_forward
	TEST_ASSERT(abs((thruster.get_fuel()) - (100 - thruster.fuel_per_second * 2)) < 0.01, "The thruster didn't burn plasma while the ship was thrusting")

	// Bez plazmy dysza nie odpala i statek traci jej ciąg, ale nie ciąg projektowy
	air_contents.set_moles(tank.gas_type, 0)
	thruster.process(2)
	TEST_ASSERT(!thruster.can_fire, "A thruster can still fire with an empty heater")
	TEST_ASSERT_EQUAL(ship.engine_thrust_active, active_with_ours - thruster.thrust_power, "An unfuelled thruster still gives the ship thrust")
	TEST_ASSERT_EQUAL(ship.engine_thrust_design, design_with_ours, "An unfuelled thruster lowered the ship's design thrust")

	// Rozkręcony podgrzewacz nie daje paliwa
	air_contents.set_moles(tank.gas_type, 100)
	tank.panel_open = TRUE
	TEST_ASSERT_EQUAL(thruster.get_fuel(), 0, "A heater with an open panel still feeds the thruster")
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

	// Mieszanka: czysta plazma daje pełny ciąg, utleniacz dokłada premię do limitu, nadmiar nie daje więcej
	TEST_ASSERT_EQUAL(ship_thruster_mix_quality(1, 1, 0), 1, "Pure plasma doesn't give full thrust")
	TEST_ASSERT(abs((ship_thruster_mix_quality(1, 1, 1)) - (1.15)) < 0.001, "Half the ideal oxygen doesn't give half the bonus")
	TEST_ASSERT(abs((ship_thruster_mix_quality(1, 1, 2)) - (1.3)) < 0.001, "Plasma with ideal oxygen doesn't give the full bonus")
	TEST_ASSERT(abs((ship_thruster_mix_quality(1, 1, 4)) - (1.3)) < 0.001, "Extra oxygen gives more than the full bonus")
	TEST_ASSERT(abs((ship_thruster_mix_quality(1, 1.15, 2)) - (1.495)) < 0.001, "Tritium with ideal oxygen isn't the best mix")
	TEST_ASSERT_EQUAL(ship_thruster_mix_quality(0, 0, 5), 0, "A mix without fuel gives thrust")

	// Podtlenek azotu liczy się za dwa mole tlenu, a dysza z lepszą mieszanką daje statkowi więcej ciągu
	air_contents.set_moles(tank.gas_type, 100)
	air_contents.set_moles(GAS_NITROUS, 100)
	thruster.process(2)
	TEST_ASSERT(abs((thruster.fuel_quality) - (1.3)) < 0.001, "Nitrous oxide doesn't count as twice the oxygen")
	TEST_ASSERT(abs((ship.engine_thrust_active) - (active_with_ours + thruster.thrust_power * 0.3)) < 0.001, "A better mix doesn't give the ship more thrust")

	// Dysza spala całą mieszankę: utleniacz i gaz obojętny schodzą razem z paliwem
	air_contents.set_moles(GAS_NITROUS, 0)
	air_contents.set_moles(GAS_O2, 200)
	air_contents.set_moles(GAS_N2, 50)
	ship.last_thrust_forward = 1
	thruster.process(2)
	ship.last_thrust_forward = old_forward
	var/burned_part = thruster.fuel_per_second * 2 / 100
	TEST_ASSERT(abs((air_contents.get_moles(GAS_O2)) - (200 * (1 - burned_part))) < 0.01, "The thruster didn't burn the oxidizer with the fuel")
	TEST_ASSERT(abs((air_contents.get_moles(GAS_N2)) - (50 * (1 - burned_part))) < 0.01, "Inert gas stays in the heater and clogs it")

	// Sam gaz obojętny nie jest paliwem
	air_contents.set_moles(tank.gas_type, 0)
	air_contents.set_moles(GAS_O2, 0)
	thruster.process(2)
	TEST_ASSERT(!thruster.can_fire, "A thruster fires on inert gas alone")

	// Regresja: dysza, która w rozliczanym okresie nie dawała ciągu (can_fire FALSE), nie płaci za ten okres
	ship.last_thrust_forward = 0
	air_contents.set_moles(GAS_O2, 0)
	air_contents.set_moles(tank.gas_type, thruster.fuel_per_second) // starczy na 1 s, nie na 2
	thruster.thrust_seen = ship.aq_thrust_seconds
	ship.aq_thrust_seconds += 0.5
	thruster.process(2)
	TEST_ASSERT(abs(air_contents.get_moles(tank.gas_type) - thruster.fuel_per_second) < 0.01, "A thruster that gave no thrust paid fuel for the period")

	// Regresja: krótki manewr między tickami spala paliwo, nawet gdy zostało go za mało na pełny tick
	thruster.can_fire = TRUE // w rozliczanym okresie dysza dawała ciąg
	thruster.thrust_seen = ship.aq_thrust_seconds
	ship.aq_thrust_seconds += 0.5
	thruster.process(2)
	TEST_ASSERT(abs(air_contents.get_moles(tank.gas_type) - thruster.fuel_per_second * 0.5) < 0.01, "A short manoeuvre with little fuel left was free ([air_contents.get_moles(tank.gas_type)] mol left)")

/datum/unit_test/ship_thrusters/Destroy()
	QDEL_NULL(thruster)
	QDEL_NULL(tank)
	if(ship)
		ship.last_thrust_forward = old_forward
		ship.engine_thrust_design = old_design
		ship.recalculate_engine_thrust()
	if(old_area)
		for(var/turf/T as anything in powered_turfs)
			old_area.contents += T
	QDEL_NULL(site)
	return ..()

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
