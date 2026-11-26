// Makra TEST_ASSERT są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc test modularny ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - urządzenia wysokiego przepływu (aquila/code/modules/atmospherics/high_flow.dm): pompa objętościowa
/// przetłacza w cyklu 3× więcej gazu niż zwykła i pracuje powyżej 9000 kPa, okna dostają podniesione limity,
/// a zwykłe urządzenia zostają przy starych.
/datum/unit_test/aquila_high_flow

/datum/unit_test/aquila_high_flow/Run()
	var/obj/machinery/atmospherics/pipe/simple/pipe = allocate(/obj/machinery/atmospherics/pipe/simple, run_loc_floor_bottom_left)
	var/datum/pipeline/net = aq_test_pipenet(pipe)

	var/obj/machinery/atmospherics/components/binary/volume_pump/normal = allocate(/obj/machinery/atmospherics/components/binary/volume_pump)
	var/obj/machinery/atmospherics/components/binary/volume_pump/aq_high_flow/high = allocate(/obj/machinery/atmospherics/components/binary/volume_pump/aq_high_flow)
	var/list/moved = list()
	for(var/obj/machinery/atmospherics/components/binary/volume_pump/pump as anything in list(normal, high))
		pump.set_machine_stat(pump.machine_stat & ~NOPOWER)
		pump.parents[1] = net
		pump.parents[2] = net
		pump.on = TRUE
		var/datum/gas_mixture/input = pump.airs[1]
		var/datum/gas_mixture/output = pump.airs[2]
		input.clear()
		output.clear()
		input.set_temperature(T20C)
		input.set_moles(GAS_N2, 1000 * input.return_volume() / (R_IDEAL_GAS_EQUATION * T20C))
		output.set_temperature(T20C)
		output.set_moles(GAS_N2, 12000 * output.return_volume() / (R_IDEAL_GAS_EQUATION * T20C))
		var/output_before = output.total_moles()
		pump.process_atmos()
		moved += output.total_moles() - output_before
		pump.parents[1] = null
		pump.parents[2] = null
		input.clear()
		output.clear()
	TEST_ASSERT(moved[1] < 0.01, "Zwykła pompa objętościowa tłoczy powyżej 9000 kPa")
	TEST_ASSERT(moved[2] > 0, "Pompa wysokiego przepływu nie tłoczy przy 12 000 kPa na wyjściu")
	TEST_ASSERT(high.ui_data()["max_rate"] == 600, "Okno pompy wysokiego przepływu nie pokazuje 600 L/s")
	TEST_ASSERT(normal.ui_data()["max_rate"] == MAX_TRANSFER_RATE, "Zwykła pompa objętościowa zmieniła limit")

	var/obj/machinery/atmospherics/components/binary/pump/aq_high_flow/pressure_pump = allocate(/obj/machinery/atmospherics/components/binary/pump/aq_high_flow)
	TEST_ASSERT(pressure_pump.ui_data()["max_pressure"] == MAX_OUTPUT_PRESSURE * 3, "Okno pompy wysokiego ciśnienia nie pokazuje 13 500 kPa")

	var/obj/machinery/atmospherics/components/trinary/filter/aq_high_flow/filter = allocate(/obj/machinery/atmospherics/components/trinary/filter/aq_high_flow)
	TEST_ASSERT(filter.ui_data()["max_rate"] == 600, "Okno filtra wysokiego przepływu nie pokazuje 600 L/s")
	TEST_ASSERT(filter.airs[1].return_volume() == 600, "Filtr wysokiego przepływu ma za małą komorę")

#undef TEST_ASSERT
