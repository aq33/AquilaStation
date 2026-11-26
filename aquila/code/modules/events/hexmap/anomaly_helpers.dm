// AQUILA - wspólna baza nowych anomalii z pola anomalii mapy hex (etap E3): bezpieczne wybieranie miejsca i ogłoszenia
// Base for the E3 anomaly events. It reuses /datum/round_event/anomaly (area choice, neutralising with a signaller and
// the analyser, cores) through parent_type, but never runtimes: with no station area or no free floor the event is killed
// and logged instead of the CRASH() in the core setup. Announcements live in one proc, so the cult portal can borrow
// the announcement of another anomaly (TauCeti does the same with its announcement datums).

/datum/round_event/aquila_hex_anomaly
	parent_type = /datum/round_event/anomaly
	startWhen = 10
	announceWhen = 3
	anomaly_path = null
	/// Rodzaj ogłoszenia z aquila_hex_anomaly_announcement()
	var/announce_kind
	/// Obiekt stworzony przez event (zwykle anomalia)
	var/datum/weakref/anomaly_ref

/datum/round_event/aquila_hex_anomaly/setup()
	impact_area = findEventArea()
	if(!impact_area)
		log_game("[type]: no valid area for the anomaly, the event will do nothing.")

/datum/round_event/aquila_hex_anomaly/announce(fake)
	if(!impact_area || !announce_kind)
		return
	priority_announce(aquila_hex_anomaly_announcement(announce_kind, impact_area.name), "Alarm: Anomalia", ANNOUNCER_SPANOMALIES)

/datum/round_event/aquila_hex_anomaly/start()
	var/turf/spawn_turf = aquila_hex_anomaly_turf(impact_area)
	if(!spawn_turf)
		log_game("[type]: no free floor in [impact_area || "no area"], cancelling the event.")
		return kill()
	var/atom/movable/spawned = spawn_anomaly(spawn_turf)
	if(QDELETED(spawned))
		return kill()
	anomaly_ref = WEAKREF(spawned)
	announce_to_ghosts(spawned)
	log_game("[type] spawned [spawned.type] at [AREACOORD(spawn_turf)].")
	return spawned

/// Tworzy obiekt eventu na kaflu (zwykle anomalię anomaly_path)
/datum/round_event/aquila_hex_anomaly/proc/spawn_anomaly(turf/spawn_turf)
	if(!ispath(anomaly_path))
		return null
	return new anomaly_path(spawn_turf)

/// Wolna podłoga (bez kosmosu i bez gęstych obiektów) w obszarze, null gdy brak
/proc/aquila_hex_anomaly_turf(area/target_area)
	if(!target_area)
		return null
	var/list/turfs = list()
	for(var/turf/open/T in get_area_turfs(target_area))
		if(isspaceturf(T) || is_blocked_turf(T, TRUE))
			continue
		turfs += T
	if(length(turfs))
		return pick(turfs)

/// Rodzaje ogłoszeń nowych anomalii (portal kultu udaje jedną z nich)
/proc/aquila_hex_anomaly_kinds()
	var/static/list/kinds = list("bioscrambler", "radiation", "storm", "frost", "gas", "lifebringer", "insanity", "blood", "dimensional")
	return kinds

/// Ogłoszenie anomalii danego rodzaju w obszarze o podanej nazwie
/proc/aquila_hex_anomaly_announcement(kind, area_name)
	switch(kind)
		if("bioscrambler")
			return "Na skanerach dalekiego zasięgu wykryto anomalię bioprzetasowania. Spodziewany punkt uderzenia: [area_name]. Anomalia zamienia kończyny istot żywych na kończyny innych ras. Zalecane skafandry biologiczne."
		if("radiation")
			return "Na skanerach dalekiego zasięgu wykryto anomalię radioaktywną. Spodziewany punkt uderzenia: [area_name]. Anomalia zostawia za sobą szlam jądrowy. Bez skafandra przeciwradiacyjnego trzymać się z daleka."
		if("storm")
			return "Na skanerach dalekiego zasięgu wykryto potężną anomalię burzową. Spodziewany punkt uderzenia: [area_name]. Anomalia razi piorunami wszystko w pobliżu. Na szczęście szybko się wyładuje."
		if("frost")
			return "Na skanerach dalekiego zasięgu wykryto anomalię mrozu. Spodziewany punkt uderzenia: [area_name]. Ubierzcie się ciepło i uważajcie na oblodzone podłogi."
		if("gas")
			return "Na skanerach dalekiego zasięgu wykryto fazującą anomalię gazową. Spodziewany punkt uderzenia: [area_name]. Anomalia wypuszcza chmury nieznanych substancji. Zalecane maski gazowe."
		if("lifebringer")
			return "Na skanerach dalekiego zasięgu wykryto anomalię Dawczyni życia. Spodziewany punkt uderzenia: [area_name]. Z anomalii wychodzą zwierzęta niewiadomego pochodzenia. Nie karmić bez zgody kwatermistrza."
		if("insanity")
			return "Na skanerach dalekiego zasięgu wykryto anomalię zakłócającą psychikę. Spodziewany punkt uderzenia: [area_name]. Fale z anomalii wywołują strach, drgawki i omamy, także za ścianami."
		if("blood")
			return "Na skanerach dalekiego zasięgu wykryto anomalię krwi. Spodziewany punkt uderzenia: [area_name]. Anomalia rani odłamkami i wysysa krew z leżących. Nie kłaść się w pobliżu."
		if("dimensional")
			return "Na skanerach dalekiego zasięgu wykryto niestabilność wymiarową. Spodziewany punkt uderzenia: [area_name]. Anomalia przerabia podłogi, ściany i meble na inny materiał."
	return "Na skanerach dalekiego zasięgu wykryto anomalię. Spodziewany punkt uderzenia: [area_name]."
