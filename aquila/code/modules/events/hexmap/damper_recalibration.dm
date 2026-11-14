// AQUILA - rekalibracja tłumików bezwładności: na 1,5–4 min tłumiki na okręcie słabną, a wspomaganie bezwładnościowe (IAS) jest niedostępne (port z Nebula13 mods/content/inertia/inertia_failure.dm)

/// Źródło cechy TRAIT_NODAMPENERS nałożonej przez ten event
#define DAMPER_RECALIBRATION_TRAIT "aquila_hex_damper_recalibration"
/// Jaka część tłumienia zostaje w czasie rekalibracji (Nebula odejmuje 5 jednostek tłumienia)
#define DAMPER_RECALIBRATION_KEPT 0.25

/datum/round_event_control/aquila_hex_damper_recalibration
	name = "Inertial Damper Recalibration"
	typepath = /datum/round_event/aquila_hex_damper_recalibration
	weight = 10
	min_players = 0
	max_occurrences = 2
	earliest_start = 10 MINUTES

/datum/round_event/aquila_hex_damper_recalibration
	announceWhen = 1
	startWhen = 1
	/// Okręt, któremu wyłączyliśmy IAS
	var/obj/structure/overmap/affected_ship
	/// Czy IAS był włączony przed eventem
	var/ias_was_on = FALSE

/datum/round_event/aquila_hex_damper_recalibration/setup()
	endWhen = rand(45, 120) // 1,5–4 min

/datum/round_event/aquila_hex_damper_recalibration/announce(fake)
	priority_announce("Trwa rekalibracja tłumików bezwładności okrętu. Do czasu jej zakończenia wspomaganie bezwładnościowe jest niedostępne. Prosimy o ograniczenie użycia silników.", "Tłumiki bezwładności")

/datum/round_event/aquila_hex_damper_recalibration/start()
	affected_ship = SSstar_system.find_main_overmap()
	if(affected_ship)
		ias_was_on = disable_ias(affected_ship)
	for(var/obj/machinery/inertial_dampener/machine as anything in ship_dampeners())
		weaken_dampener(machine)

/datum/round_event/aquila_hex_damper_recalibration/tick()
	// zmiana ustawień tłumika przelicza jego siłę od nowa, więc osłabienie nakładamy co tick
	for(var/obj/machinery/inertial_dampener/machine as anything in ship_dampeners())
		weaken_dampener(machine)

/datum/round_event/aquila_hex_damper_recalibration/end()
	for(var/obj/machinery/inertial_dampener/machine as anything in ship_dampeners())
		restore_dampener(machine)
	if(!QDELETED(affected_ship))
		restore_ias(affected_ship, ias_was_on)
	affected_ship = null
	priority_announce("Rekalibracja tłumików bezwładności zakończona. Wspomaganie bezwładnościowe znów jest dostępne.", "Tłumiki bezwładności")

/// Tłumiki bezwładności na okręcie
/datum/round_event/aquila_hex_damper_recalibration/proc/ship_dampeners()
	. = list()
	for(var/obj/machinery/inertial_dampener/machine as anything in GLOB.inertia_dampeners)
		if(is_station_level(machine.z))
			. += machine

/// Osłabia tłumik: zostaje tylko część jego tłumienia (strengthMultiplier 1 = brak tłumienia)
/datum/round_event/aquila_hex_damper_recalibration/proc/weaken_dampener(obj/machinery/inertial_dampener/machine)
	machine.recalculatePartEfficiency()
	machine.strengthMultiplier = 1 - (1 - machine.strengthMultiplier) * DAMPER_RECALIBRATION_KEPT

/datum/round_event/aquila_hex_damper_recalibration/proc/restore_dampener(obj/machinery/inertial_dampener/machine)
	machine.recalculatePartEfficiency()

/// Wyłącza IAS okrętu i blokuje jego włączenie. Zwraca, czy IAS był włączony.
/datum/round_event/aquila_hex_damper_recalibration/proc/disable_ias(obj/structure/overmap/ship)
	. = ship.inertial_dampeners
	ADD_TRAIT(ship, TRAIT_NODAMPENERS, DAMPER_RECALIBRATION_TRAIT)
	ship.disable_dampeners()

/// Zdejmuje blokadę IAS i włącza go z powrotem, jeśli był włączony przed eventem
/datum/round_event/aquila_hex_damper_recalibration/proc/restore_ias(obj/structure/overmap/ship, was_on)
	REMOVE_TRAIT(ship, TRAIT_NODAMPENERS, DAMPER_RECALIBRATION_TRAIT)
	if(was_on)
		ship.enable_dampeners() // nie włączy się, jeśli blokuje go coś innego (np. czarna dziura)

#undef DAMPER_RECALIBRATION_TRAIT
#undef DAMPER_RECALIBRATION_KEPT
