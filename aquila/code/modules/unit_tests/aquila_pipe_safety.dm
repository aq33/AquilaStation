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

/// Buduje od razu sieci urządzeń czekających w kolejce przebudowy SSair (test nie czeka na cykl SSair)
/proc/aq_test_rebuild(list/devices)
	for(var/obj/machinery/atmospherics/device as anything in devices)
		if(QDELETED(device))
			continue
		for(var/datum/pipeline/net as anything in device.get_rebuild_targets())
			net.build_pipeline_blocking(device)
		device.rebuilding = FALSE
		SSair.rebuild_queue -= device

/// Suma moli w sieciach i komorach podanych urządzeń (każda mieszanina liczona raz)
/proc/aq_test_total_moles(list/devices)
	var/list/datum/gas_mixture/counted = list()
	for(var/obj/machinery/atmospherics/device as anything in devices)
		for(var/datum/pipeline/net as anything in device.return_pipenets())
			if(net)
				counted |= net.get_all_connected_airs()
	. = 0
	for(var/datum/gas_mixture/mixture as anything in counted)
		if(mixture)
			. += mixture.total_moles()

/// AQUILA - zacisk rury na środku linii: sąsiedzi dostają dwie osobne sieci z gazem, nic nie ucieka na kafelek,
/// a zdjęty zacisk przywraca rurę tego samego typu i nazwy, która znów łączy linię w jedną sieć.
/datum/unit_test/aquila_pipe_clamp

/datum/unit_test/aquila_pipe_clamp/Run()
	var/turf/west_turf = run_loc_floor_bottom_left
	var/turf/middle_turf = get_step(west_turf, EAST)
	var/turf/east_turf = get_step(middle_turf, EAST)
	var/list/obj/machinery/atmospherics/pipe/simple/line = list()
	for(var/turf/pipe_turf as anything in list(west_turf, middle_turf, east_turf))
		var/obj/machinery/atmospherics/pipe/simple/pipe = new /obj/machinery/atmospherics/pipe/simple/supply/visible(pipe_turf, TRUE, EAST)
		pipe.on_construction(pipe.pipe_color, pipe.piping_layer)
		// jak w grze: SSair buduje sieć, zanim stanie następna rura
		aq_test_rebuild(list(pipe))
		line += pipe
	var/obj/machinery/atmospherics/pipe/simple/west = line[1]
	var/obj/machinery/atmospherics/pipe/simple/middle = line[2]
	var/obj/machinery/atmospherics/pipe/simple/east = line[3]
	middle.name = "rura testowa"
	TEST_ASSERT(west.parent && west.parent == east.parent, "Trzy rury w linii nie tworzą jednej sieci")
	aq_test_fill_pipenet(west.parent, 1000, T20C)
	var/moles_before = west.parent.air.total_moles()
	var/turf/open/middle_floor = middle_turf
	var/floor_moles = middle_floor.air.total_moles()

	var/obj/item/pipe_clamp/clamp_item = allocate(/obj/item/pipe_clamp)
	var/obj/machinery/atmospherics/components/binary/valve/aq_clamp/clamp = middle.aq_apply_clamp(clamp_item)
	aq_test_rebuild(list(west, east, clamp))
	TEST_ASSERT(QDELETED(middle), "Rura nie zniknęła po założeniu zacisku")
	TEST_ASSERT(istype(clamp) && clamp.loc == middle_turf, "Zacisk nie stanął w miejscu rury")
	TEST_ASSERT(!clamp.on, "Założony zacisk nie zamyka przepływu")
	TEST_ASSERT(clamp_item.loc == clamp, "Przedmiot zacisku nie trafił do zacisku")
	TEST_ASSERT(west.parent?.air && east.parent?.air, "Sąsiednie rury zostały bez sieci z gazem")
	TEST_ASSERT(west.parent != east.parent, "Zamknięty zacisk nie rozdzielił linii")
	TEST_ASSERT((west.parent in clamp.parents) && (east.parent in clamp.parents), "Zacisk nie jest połączony z sieciami sąsiadów")
	TEST_ASSERT(abs(aq_test_total_moles(list(west, east, clamp)) - moles_before) < 0.01, "Założenie zacisku zgubiło albo dodało gaz")
	TEST_ASSERT(abs(middle_floor.air.total_moles() - floor_moles) < 0.01, "Przy zakładaniu zacisku gaz uciekł na kafelek")

	clamp.on = TRUE
	var/obj/item/returned = clamp.aq_remove_clamp()
	TEST_ASSERT(returned == clamp_item, "Zdjęty zacisk nie oddał przedmiotu")
	var/obj/machinery/atmospherics/pipe/simple/restored = locate(/obj/machinery/atmospherics/pipe/simple) in middle_turf
	TEST_ASSERT(restored, "Po zdjęciu zacisku nie wróciła rura")
	aq_test_rebuild(list(west, east, restored))
	TEST_ASSERT(restored.type == /obj/machinery/atmospherics/pipe/simple/supply/visible, "Przywrócona rura ma inny typ")
	TEST_ASSERT(restored.name == "rura testowa", "Przywrócona rura zgubiła nazwę")
	TEST_ASSERT(restored.dir == EAST || restored.dir == WEST, "Przywrócona rura ma inny kierunek")
	TEST_ASSERT(west.parent && west.parent == east.parent && restored.parent == west.parent, "Zdjęcie zacisku nie połączyło linii w jedną sieć")
	TEST_ASSERT(abs(west.parent.air.total_moles() - moles_before) < 0.01, "Zdjęcie zacisku zgubiło gaz")

	qdel(clamp_item)
	for(var/obj/machinery/atmospherics/pipe/simple/leftover in list(west, east, restored))
		qdel(leftover)

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

	// Paliwo w sieci rur, nie w komorze iskrownika: iskra podgrzewa całą sieć (sama komora wystygłaby przy wyrównaniu)
	var/obj/machinery/atmospherics/pipe/simple/pipe = allocate(/obj/machinery/atmospherics/pipe/simple, run_loc_floor_top_right)
	var/datum/pipeline/net = aq_test_pipenet(pipe)
	net.air.clear()
	net.air.set_temperature(T20C)
	net.air.set_moles(GAS_PLASMA, 10)
	net.air.set_moles(GAS_O2, 10)
	sparker.parents[1] = net
	sparker.next_spark = 0
	TEST_ASSERT(sparker.aq_spark(), "Iskrownik nie iskrzy przy paliwie w sieci")
	TEST_ASSERT(net.air.return_temperature() >= FIRE_MINIMUM_TEMPERATURE_TO_EXIST, "Iskrownik nie podgrzał sieci rur do zapłonu")
	sparker.parents[1] = null
	net.air.clear()

#undef TEST_ASSERT
