// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - pulsar: moc zależy od orbity i osłony jak w Eris, ruch zużywa paliwo, satelita nie wylatuje z mapy,
/// a za słaba osłona albo główna wiązka dają ostrzeżenie tylko przy połączonym mostku
/datum/unit_test/pulsar

/datum/unit_test/pulsar/Run()
	var/obj/machinery/pulsar_console/console = allocate(/obj/machinery/pulsar_console, run_loc_floor_bottom_left)
	var/obj/machinery/power/pulsar_bridge/bridge = allocate(/obj/machinery/power/pulsar_bridge, run_loc_floor_top_right)
	// Mostek mógł się połączyć z inną konsolą (np. z mapy): łączymy je ręcznie
	if(bridge.console && bridge.console != console)
		bridge.console.bridge = null
	bridge.console = console
	console.bridge = bridge

	// Pozycja startowa z Eris. Pulsar leży w (9, 9): round() z jednym argumentem w BYOND zaokrągla w dół, jak w Eris
	console.sat_x = 15
	console.sat_y = 5
	console.shield_power = 45
	TEST_ASSERT(console.pulsar_pos() == 9, "The pulsar should sit at (9, 9), got [console.pulsar_pos()]")
	TEST_ASSERT(console.produced_power() == 49, "Start orbit should give 49% power, got [console.produced_power()]")
	TEST_ASSERT(abs(console.required_shielding() - 39.8) < 0.01, "Start orbit should need 39.8% shielding, got [console.required_shielding()]")
	TEST_ASSERT(abs(console.effective_power() - 26.95) < 0.01, "Effective power with 45% shielding should be 26.95%, got [console.effective_power()]")
	TEST_ASSERT(abs(bridge.output_power() - 25000000 * 0.2695) < 1, "The bridge should output 6.74 MW, got [bridge.output_power()]")

	// Przy wiązce: 150% mocy i 60% osłony; w głównej wiązce: burza
	console.sat_x = 11
	console.sat_y = 10
	TEST_ASSERT(console.on_side_beam() && console.produced_power() == 150, "Next to the beam should give 150% power")
	TEST_ASSERT(console.required_shielding() == 60, "Next to the beam should need 60% shielding")
	TEST_ASSERT(console.on_core_beam(12, 12) && !console.on_core_beam(11, 10), "The core beam is the x == y diagonal")

	// Ruch zużywa paliwo: 4 mole przy czystej plazmie, bez paliwa nie ma ruchu
	console.sat_x = 15
	console.sat_y = 5
	TEST_ASSERT(!console.move_satellite(NORTH), "The satellite moved without a fuel tank")
	var/obj/structure/pulsar_fuel_tank/filled/tank = allocate(/obj/structure/pulsar_fuel_tank/filled, run_loc_floor_bottom_left)
	TEST_ASSERT(console.scan_for_tank() == tank, "The console didn't find the fuel tank in its area")
	TEST_ASSERT(console.thrust_cost() == 4, "Pure plasma should cost 4 moles per move, got [console.thrust_cost()]")
	var/fuel_before = tank.air_contents.total_moles()
	TEST_ASSERT(console.move_satellite(NORTH) && console.sat_y == 6, "The satellite didn't move north")
	TEST_ASSERT(abs(fuel_before - tank.air_contents.total_moles() - 4) < 0.01, "Moving didn't use 4 moles of fuel")

	// Przy krawędzi satelita odbija się z powrotem zamiast wylecieć z mapy
	console.sat_x = 19
	console.move_satellite(EAST, FALSE)
	TEST_ASSERT(console.sat_x == 18, "The satellite left the orbit map instead of bouncing back, x = [console.sat_x]")

	// Za słaba osłona: ostrzeżenie o przeciążeniu, po podniesieniu osłony ostrzeżenie znika
	console.sat_x = 15
	console.sat_y = 5
	console.shield_power = 10
	console.check_events()
	TEST_ASSERT(console.overcharge_at > world.time && !console.overcharge_active, "Too little shielding didn't start the overcharge warning")
	console.shield_power = 60
	console.check_events()
	TEST_ASSERT(!console.overcharge_at, "Raising the shielding didn't cancel the overcharge warning")

	// Główna wiązka: ostrzeżenie o burzy, rozłączony mostek wyłącza wydarzenia
	console.sat_x = 12
	console.sat_y = 12
	console.shield_power = 90
	console.check_events()
	TEST_ASSERT(console.storm_at > world.time, "The core beam didn't start the storm warning")
	bridge.toggle_connection()
	TEST_ASSERT(!console.storm_at, "Disconnecting the bridge didn't stop the storm warning")
	TEST_ASSERT(bridge.output_power() == 0, "A disconnected bridge still outputs power")
	TEST_ASSERT(!bridge.toggle_connection(), "The bridge reconnected before the cooldown")

#undef TEST_ASSERT
