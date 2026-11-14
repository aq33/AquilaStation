// AQUILA - awaria grawitacji: generatory grawitacji okrętu wyłączają się na 3–12 min, potem wracają te, które działały (port z Baystation12 code/modules/events/gravity.dm)

/datum/round_event_control/aquila_hex_gravity_failure
	name = "Gravity Failure"
	typepath = /datum/round_event/aquila_hex_gravity_failure
	weight = 10
	min_players = 5
	max_occurrences = 2
	earliest_start = 15 MINUTES

/datum/round_event/aquila_hex_gravity_failure
	announceWhen = 5
	startWhen = 1
	/// Generatory, które wyłączyliśmy i które wrócą na koniec
	var/list/disabled_generators = list()

/datum/round_event/aquila_hex_gravity_failure/setup()
	endWhen = rand(90, 360) // 3–12 min

/datum/round_event/aquila_hex_gravity_failure/announce(fake)
	priority_announce("Wykryto skok sprzężenia zwrotnego w układach rozkładu masy. Sztuczną grawitację wyłączono, aby uniknąć przeciążenia systemu.", "Podsystem grawitacji", ANNOUNCER_GRANOMALIES)

/datum/round_event/aquila_hex_gravity_failure/start()
	for(var/obj/machinery/gravity_generator/main/generator in GLOB.machines)
		if(is_station_level(generator.z))
			disable_generator(generator)

/datum/round_event/aquila_hex_gravity_failure/tick()
	// Przeciążenie trwa: generator włączony w czasie awarii od razu znów się wyłącza
	for(var/obj/machinery/gravity_generator/main/generator as anything in disabled_generators.Copy())
		if(QDELETED(generator))
			disabled_generators -= generator
			continue
		if(generator.breaker)
			generator.visible_message("<span class='warning'>[generator] iskrzy i wyłącza się: układy rozkładu masy wciąż są przeciążone!</span>")
			do_sparks(3, TRUE, generator)
			generator.breaker = FALSE
			generator.set_power()

/datum/round_event/aquila_hex_gravity_failure/end()
	restore_all()
	priority_announce("Generatory grawitacji znów działają w normalnych parametrach. Przepraszamy za utrudnienia.", "Podsystem grawitacji")

/datum/round_event/aquila_hex_gravity_failure/kill()
	restore_all() // zatrzymany przez admina przed end(): grawitacja i tak wraca
	return ..()

/// Włącza z powrotem wszystkie wyłączone generatory; lista jest czyszczona, więc drugie wywołanie nic nie robi
/datum/round_event/aquila_hex_gravity_failure/proc/restore_all()
	for(var/obj/machinery/gravity_generator/main/generator as anything in disabled_generators.Copy())
		if(!QDELETED(generator))
			restore_generator(generator)
	disabled_generators.Cut()

/// Wyłącza działający generator od razu (jak w Bay, bez rozładowania) i zapamiętuje go. Zwraca TRUE, jeśli go wyłączył.
/datum/round_event/aquila_hex_gravity_failure/proc/disable_generator(obj/machinery/gravity_generator/main/generator)
	if(!generator.on || !generator.breaker || (generator.machine_stat & BROKEN) || (generator in disabled_generators))
		return FALSE
	disabled_generators += generator
	generator.breaker = FALSE
	generator.charge_count = 0
	generator.set_state(FALSE)
	generator.investigate_log("was shut down by the Gravity Failure event.", INVESTIGATE_GRAVITY)
	return TRUE

/// Włącza wyłącznik generatora z powrotem; generator rozpędza się normalnie
/datum/round_event/aquila_hex_gravity_failure/proc/restore_generator(obj/machinery/gravity_generator/main/generator)
	disabled_generators -= generator
	if(generator.breaker)
		return
	generator.breaker = TRUE
	generator.set_power()
	generator.investigate_log("was turned back on after the Gravity Failure event.", INVESTIGATE_GRAVITY)
