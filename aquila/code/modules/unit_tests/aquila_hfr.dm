// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - HFR okrojony (plan maszynowni E17): tylko trzy paliwa z naszych gazów, hel z paliw z trytem
/datum/unit_test/aquila_hfr_fuels

/datum/unit_test/aquila_hfr_fuels/Run()
	var/list/expected = list("plasma_o2_fuel", "t2_o2_fuel", "h2_t2_fuel")
	TEST_ASSERT(length(GLOB.hfr_fuels_list) == length(expected), "HFR has [length(GLOB.hfr_fuels_list)] fuels instead of [length(expected)]")
	for(var/id in expected)
		TEST_ASSERT(GLOB.hfr_fuels_list[id], "HFR fuel [id] is missing")
	TEST_ASSERT(GLOB.gas_data.ids[GAS_HELIUM], "Helium is not registered with auxgm")
	for(var/id in GLOB.hfr_fuels_list)
		var/datum/hfr_fuel/fuel = GLOB.hfr_fuels_list[id]
		TEST_ASSERT(length(fuel.requirements) == 2, "HFR fuel [id] has [length(fuel.requirements)] requirements instead of 2")
		TEST_ASSERT(length(fuel.secondary_products) == 6, "HFR fuel [id] has [length(fuel.secondary_products)] secondary products instead of 6")
		for(var/gas_id in fuel.requirements | fuel.primary_products | fuel.secondary_products)
			TEST_ASSERT(GLOB.gas_data.ids[gas_id], "HFR fuel [id] uses gas [gas_id] that does not exist in our atmos")
	var/datum/hfr_fuel/dt = GLOB.hfr_fuels_list["h2_t2_fuel"]
	var/datum/hfr_fuel/to2 = GLOB.hfr_fuels_list["t2_o2_fuel"]
	TEST_ASSERT(dt.primary_products[1] == GAS_HELIUM, "Hydrogen + tritium fusion does not make helium")
	TEST_ASSERT(GAS_HELIUM in to2.primary_products, "Tritium + oxygen fusion does not make helium")

/**
 * Złożony reaktor: każde z trzech paliw w gorącej komorze zużywa paliwo i daje produkty fuzji,
 * a awaryjny wyrzut rdzenia opróżnia komorę i zeruje uszkodzenia.
 */
/datum/unit_test/aquila_hfr_fusion

/datum/unit_test/aquila_hfr_fusion/Run()
	var/turf/T = run_loc_floor_bottom_left
	var/turf/center = locate(T.x + 1, T.y + 1, T.z)
	var/obj/machinery/atmospherics/components/unary/hypertorus/core/core = build_hfr(center)
	TEST_ASSERT(core.check_part_connectivity(), "A correctly built HFR does not see all of its parts")
	core.activate(null)
	TEST_ASSERT(core.active, "HFR did not activate after linking its parts")

	for(var/id in GLOB.hfr_fuels_list)
		var/datum/hfr_fuel/fuel = GLOB.hfr_fuels_list[id]
		core.selected_fuel = fuel
		core.internal_fusion.remove_ratio(1)
		core.moderator_internal.remove_ratio(1)
		core.linked_output.airs[1].remove_ratio(1)
		// Rozruch jak w poradniku: dużo paliwa, plazma w moderatorze, przewodnik ciepła na 500
		for(var/gas_id in fuel.requirements)
			core.internal_fusion.set_moles(gas_id, 2000)
		core.internal_fusion.set_temperature(5000)
		core.moderator_internal.set_moles(GAS_PLASMA, 500)
		core.moderator_internal.set_temperature(300)
		core.start_power = TRUE
		core.heating_conductor = 500
		core.energy = 0
		core.iron_content = 0
		core.critical_threshold_proximity = 0
		var/list/before = list()
		for(var/gas_id in fuel.requirements)
			before[gas_id] = core.internal_fusion.get_moles(gas_id)
		// Kilka cykli wystarczy: w symulacji produkty pojawiają się od drugiego cyklu
		for(var/i in 1 to 5)
			core.fusion_process(2)
		TEST_ASSERT(core.power_level >= 1, "Fuel [id]: a 5000 K fusion mix is at power level [core.power_level]")
		for(var/gas_id in fuel.requirements)
			TEST_ASSERT(core.internal_fusion.get_moles(gas_id) < before[gas_id], "Fuel [id]: fusion did not consume [gas_id] ([core.internal_fusion.get_moles(gas_id)] of [before[gas_id]] mol left)")
		var/made = 0
		for(var/gas_id in fuel.primary_products)
			made += core.internal_fusion.get_moles(gas_id)
		TEST_ASSERT(made > 0, "Fuel [id]: fusion made none of its products ([jointext(fuel.primary_products, ", ")])")
		if(GAS_HELIUM in fuel.primary_products)
			TEST_ASSERT(core.internal_fusion.get_moles(GAS_HELIUM) > 0, "Fuel [id]: fusion made no helium")
		for(var/gas_id in core.moderator_internal.get_gases())
			TEST_ASSERT(gas_id == GAS_PLASMA || (gas_id in fuel.secondary_products), "Fuel [id]: fusion put [gas_id] into the moderator, which is not one of its secondary products")

	// Wyrzut rdzenia
	var/datum/component/core_ejection/ejection = core.GetComponent(/datum/component/core_ejection)
	TEST_ASSERT(ejection, "HFR core has no core ejection component")
	core.critical_threshold_proximity = 0
	TEST_ASSERT(ejection.eject_fault_reason(), "A healthy HFR allows a core ejection")
	core.critical_threshold_proximity = core.emergency_point
	TEST_ASSERT(!ejection.eject_block_reason() && !ejection.eject_fault_reason(), "A damaged HFR with fuel inside refuses a core ejection")
	ejection.purge_core()
	TEST_ASSERT(!core.internal_fusion.total_moles(), "Ejected HFR still has [core.internal_fusion.total_moles()] mol in the fusion chamber")
	TEST_ASSERT(!core.moderator_internal.total_moles(), "Ejected HFR still has [core.moderator_internal.total_moles()] mol in the moderator")
	TEST_ASSERT(core.critical_threshold_proximity == 0, "Ejected HFR is still damaged ([core.critical_threshold_proximity])")
	TEST_ASSERT(ejection.eject_block_reason(), "An empty HFR allows another core ejection")

	core.deactivate()

/// Stawia rdzeń z ośmioma częściami wokół, jak skrzynka rdzenia po użyciu multitoola
/datum/unit_test/aquila_hfr_fusion/proc/build_hfr(turf/center)
	var/list/corner_dirs = list("[NORTHEAST]" = EAST, "[SOUTHEAST]" = SOUTH, "[SOUTHWEST]" = WEST, "[NORTHWEST]" = NORTH)
	for(var/diagonal in corner_dirs)
		var/obj/machinery/hypertorus/corner/corner = allocate(/obj/machinery/hypertorus/corner, get_step(center, text2num(diagonal)))
		corner.dir = corner_dirs[diagonal]
	var/list/sides = list(
		"[NORTH]" = /obj/machinery/atmospherics/components/unary/hypertorus/fuel_input,
		"[EAST]" = /obj/machinery/atmospherics/components/unary/hypertorus/moderator_input,
		"[SOUTH]" = /obj/machinery/atmospherics/components/unary/hypertorus/waste_output,
	)
	for(var/side in sides)
		var/direction = text2num(side)
		var/obj/machinery/atmospherics/components/unary/hypertorus/part = allocate(sides[side], get_step(center, direction), TRUE, direction)
		part.dir = direction
	var/obj/machinery/hypertorus/interface/panel = allocate(/obj/machinery/hypertorus/interface, get_step(center, WEST))
	panel.dir = WEST
	return allocate(/obj/machinery/atmospherics/components/unary/hypertorus/core, center, TRUE)

#undef TEST_ASSERT
