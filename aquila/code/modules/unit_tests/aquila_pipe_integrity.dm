// Makra TEST_ASSERT są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc test modularny ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Sieć rur zbudowana od razu (zwykle buduje ją SSair w kolejnym cyklu)
/proc/aq_test_pipenet(obj/machinery/atmospherics/pipe/pipe)
	if(QDELETED(pipe.parent))
		pipe.parent = new
	if(!(pipe in pipe.parent.members))
		pipe.parent.build_pipeline_blocking(pipe)
	return pipe.parent

/// Ustawia w sieci sam azot o danym ciśnieniu i temperaturze
/proc/aq_test_fill_pipenet(datum/pipeline/net, pressure, temperature)
	net.air.clear()
	net.air.set_temperature(temperature)
	net.air.set_moles(GAS_N2, pressure * net.air.return_volume() / (R_IDEAL_GAS_EQUATION * temperature))

/// AQUILA - wytrzymałość rur (aquila/code/modules/atmospherics/pipe_integrity.dm): rura pęka dopiero przy rażącym
/// przekroczeniu ciśnienia albo temperatury, pęknięta przecieka na kafelek, naprawa zatrzymuje przeciek,
/// plastal podnosi próg dziesięciokrotnie.
/datum/unit_test/aquila_pipe_integrity

/datum/unit_test/aquila_pipe_integrity/Run()
	var/obj/machinery/atmospherics/pipe/simple/pipe = allocate(/obj/machinery/atmospherics/pipe/simple, run_loc_floor_bottom_left)
	var/datum/pipeline/net = aq_test_pipenet(pipe)
	TEST_ASSERT(net?.air, "Rura nie ma sieci z gazem")

	// Praca silników na mapach (RBMK do ok. 10 000 kPa, Stormdrive do ok. 1500 K): bez pęknięcia nawet bez losowania
	aq_test_fill_pipenet(net, 10000, 1500)
	TEST_ASSERT(isnull(net.aq_check_integrity(TRUE)), "Rura pękła przy 10 000 kPa i 1500 K")
	TEST_ASSERT(!pipe.aq_ruptured, "Rura oznaczona jako pęknięta przy zwykłej pracy")

	// Rażące nadciśnienie: pęka
	aq_test_fill_pipenet(net, 60000, T20C)
	TEST_ASSERT(net.aq_check_integrity(TRUE) == pipe, "Rura nie pękła przy 60 000 kPa")
	TEST_ASSERT(pipe.aq_ruptured, "Pęknięta rura nie ma stanu pęknięcia")
	TEST_ASSERT(pipe in net.aq_leaks, "Pęknięta rura nie trafiła na listę przecieków sieci")

	// Przeciek: gaz z sieci trafia na kafelek
	var/turf/open/floor = get_turf(pipe)
	var/floor_moles = floor.air.total_moles()
	var/pipe_moles = net.air.total_moles()
	net.aq_leak_gas()
	TEST_ASSERT(net.air.total_moles() < pipe_moles, "Pęknięta rura nie traci gazu")
	TEST_ASSERT(floor.air.total_moles() > floor_moles, "Gaz z pękniętej rury nie trafił na kafelek")

	// Sieć przebudowana od nowa pamięta pęknięcie (lista liczona z członków)
	net.aq_leaks = null
	net.aq_cached_members = -1
	net.aq_refresh_integrity_cache()
	TEST_ASSERT(pipe in net.aq_leaks, "Przebudowana sieć zgubiła pękniętą rurę")

	// Naprawa zatrzymuje przeciek
	TEST_ASSERT(pipe.aq_repair(), "Naprawa pękniętej rury nie zadziałała")
	TEST_ASSERT(!length(net.aq_leaks), "Naprawiona rura dalej przecieka")

	// Temperatura: pęka powyżej 10 000 K
	aq_test_fill_pipenet(net, 1000, 12000)
	TEST_ASSERT(net.aq_check_integrity(TRUE) == pipe, "Rura nie pękła przy 12 000 K")
	pipe.aq_repair()

	// Wzmocniona rura trzyma 60 000 kPa i 12 000 K
	pipe.aq_reinforce()
	aq_test_fill_pipenet(net, 60000, 12000)
	TEST_ASSERT(isnull(net.aq_check_integrity(TRUE)), "Wzmocniona rura pękła przy 60 000 kPa i 12 000 K")
	// ...ale nie 600 000 kPa
	aq_test_fill_pipenet(net, 600000, T20C)
	TEST_ASSERT(net.aq_check_integrity(TRUE) == pipe, "Wzmocniona rura nie pękła przy 600 000 kPa")
	pipe.aq_repair()
	net.air.clear()

	// Sieć w trakcie przebudowy: opis rury nie czyta null.air
	pipe.parent = null
	TEST_ASSERT(pipe.aq_get_stress() == 0, "Rura bez sieci ma obciążenie")
	pipe.examine(allocate(/mob/living/carbon/human))
	pipe.parent = net

#undef TEST_ASSERT
