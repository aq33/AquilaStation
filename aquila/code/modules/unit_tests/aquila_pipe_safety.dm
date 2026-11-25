// Makra TEST_ASSERT są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc test modularny ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - zawór odcinający (aquila/code/modules/atmospherics/pipe_safety.dm) zamyka się, gdy w jego sieci
/// pęknie rura, trzyma zamknięcie przed ręcznym otwarciem i otwiera się sam po zespawaniu.
/datum/unit_test/aquila_shutoff_valve

/datum/unit_test/aquila_shutoff_valve/Run()
	var/obj/machinery/atmospherics/pipe/simple/pipe = allocate(/obj/machinery/atmospherics/pipe/simple, run_loc_floor_bottom_left)
	var/datum/pipeline/net = aq_test_pipenet(pipe)
	var/obj/machinery/atmospherics/components/binary/valve/digital/aq_shutoff/valve = allocate(/obj/machinery/atmospherics/components/binary/valve/digital/aq_shutoff, run_loc_floor_top_right)
	valve.set_machine_stat(valve.machine_stat & ~NOPOWER)
	valve.parents[1] = net
	valve.parents[2] = net
	TEST_ASSERT(valve.on, "Zawór odcinający nie startuje otwarty")

	valve.process_atmos()
	TEST_ASSERT(valve.on, "Zawór zamknął się bez przecieku")

	pipe.aq_rupture()
	valve.process_atmos()
	TEST_ASSERT(!valve.on, "Zawór nie zamknął się przy pękniętej rurze w sieci")
	TEST_ASSERT(valve.aq_auto_closed, "Zawór nie zapamiętał zamknięcia przez automat")

	pipe.aq_repair()
	valve.process_atmos()
	TEST_ASSERT(valve.on, "Zawór nie otworzył się po naprawie rury")

	// Bez automatu przeciek nie zamyka zaworu
	valve.aq_auto = FALSE
	pipe.aq_rupture()
	valve.process_atmos()
	TEST_ASSERT(valve.on, "Zawór z wyłączonym automatem zamknął się sam")
	pipe.aq_repair()
	valve.parents[1] = null
	valve.parents[2] = null

/// AQUILA - zacisk rury zamienia prosty odcinek w zamknięty zawór i zdjęty przywraca rurę z tym samym kierunkiem.
/datum/unit_test/aquila_pipe_clamp

/datum/unit_test/aquila_pipe_clamp/Run()
	var/turf/clamp_turf = run_loc_floor_bottom_left
	var/obj/machinery/atmospherics/pipe/simple/pipe = new(clamp_turf, TRUE, EAST)
	aq_test_pipenet(pipe)
	var/obj/item/pipe_clamp/clamp_item = allocate(/obj/item/pipe_clamp)

	var/obj/machinery/atmospherics/components/binary/valve/aq_clamp/clamp = pipe.aq_apply_clamp(clamp_item)
	TEST_ASSERT(QDELETED(pipe), "Rura nie zniknęła po założeniu zacisku")
	TEST_ASSERT(istype(clamp) && clamp.loc == clamp_turf, "Zacisk nie stanął w miejscu rury")
	TEST_ASSERT(!clamp.on, "Założony zacisk nie zamyka przepływu")
	TEST_ASSERT(clamp.dir == EAST || clamp.dir == WEST, "Zacisk ma inny kierunek niż rura")
	TEST_ASSERT(clamp_item.loc == clamp, "Przedmiot zacisku nie trafił do zacisku")

	clamp.on = TRUE
	var/obj/item/returned = clamp.aq_remove_clamp()
	TEST_ASSERT(returned == clamp_item, "Zdjęty zacisk nie oddał przedmiotu")
	var/obj/machinery/atmospherics/pipe/simple/restored = locate() in clamp_turf
	TEST_ASSERT(restored, "Po zdjęciu zacisku nie wróciła rura")
	TEST_ASSERT(restored.dir == EAST || restored.dir == WEST, "Przywrócona rura ma inny kierunek")
	qdel(restored)

/// AQUILA - iskrownik rurowy zapala mieszankę z paliwem i tlenem, nie grzeje gazu bez paliwa i ma przerwę między iskrami.
/datum/unit_test/aquila_pipe_sparker

/datum/unit_test/aquila_pipe_sparker/Run()
	var/obj/machinery/atmospherics/components/unary/aq_sparker/sparker = allocate(/obj/machinery/atmospherics/components/unary/aq_sparker)
	sparker.set_machine_stat(sparker.machine_stat & ~NOPOWER)
	var/datum/gas_mixture/air = sparker.airs[1]

	air.clear()
	air.set_temperature(T20C)
	air.set_moles(GAS_N2, 20)
	TEST_ASSERT(sparker.aq_spark(), "Iskrownik nie iskrzy")
	TEST_ASSERT(air.return_temperature() < T20C + 1, "Iskrownik podgrzał gaz bez paliwa")
	TEST_ASSERT(!sparker.aq_spark(), "Iskrownik iskrzy bez przerwy")

	sparker.next_spark = 0
	air.clear()
	air.set_temperature(T20C)
	air.set_moles(GAS_PLASMA, 10)
	air.set_moles(GAS_O2, 10)
	TEST_ASSERT(sparker.aq_spark(), "Iskrownik nie iskrzy przy mieszance")
	TEST_ASSERT(air.return_temperature() >= FIRE_MINIMUM_TEMPERATURE_TO_EXIST, "Iskrownik nie podgrzał mieszanki do zapłonu")
	air.clear()

#undef TEST_ASSERT
