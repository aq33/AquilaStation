// AQUILA - interfaza bluespace: radio co jakiś czas powtarza starą wiadomość z kanału, z jej pierwotnym nadawcą (port z CEV-Eris code/game/gamemodes/events/space_weather.dm)
// Wiadomości bierzemy z logów serwerów telekomunikacji (log_entries), więc nic w core nie musi ich zapamiętywać.

/datum/round_event_control/aquila_hex_bluespace_interphase
	name = "Interfaza bluespace"
	typepath = /datum/round_event/aquila_hex_bluespace_interphase
	weight = 10
	min_players = 0
	max_occurrences = 2
	earliest_start = 10 MINUTES

/datum/round_event/aquila_hex_bluespace_interphase
	announceWhen = 3
	startWhen = 1
	/// Co ile ticków (2 s) radio powtarza starą wiadomość, jak w Eris
	var/replay_interval = 50

/datum/round_event/aquila_hex_bluespace_interphase/setup()
	endWhen = rand(300, 600) // 10–20 min

/datum/round_event/aquila_hex_bluespace_interphase/announce(fake)
	priority_announce("Struktura bluespace zaczęła się rozpadać, co pozwala na nakładanie się równoległych wszechświatów na różnych płaszczyznach wymiarowych. Brak dodatkowych danych.", "Interfaza bluespace", ANNOUNCER_SPANOMALIES)

/datum/round_event/aquila_hex_bluespace_interphase/tick()
	if(activeFor % replay_interval)
		return
	var/list/replay = pick_replay(ship_servers())
	if(replay)
		broadcast_replay(replay)

/datum/round_event/aquila_hex_bluespace_interphase/end()
	priority_announce("Interfaza bluespace ustabilizowała się.", "Interfaza bluespace")

/// Serwery telekomunikacji na okręcie
/datum/round_event/aquila_hex_bluespace_interphase/proc/ship_servers()
	. = list()
	for(var/obj/machinery/telecomms/server/S in GLOB.telecomms_list)
		if(is_station_level(S.z))
			. += S

/**
 * Losuje starą wiadomość z logów podanych serwerów.
 * Zwraca list("message", "name", "job", "language", "frequency", "server") albo nic, gdy żaden serwer nie ma czytelnego wpisu.
 */
/datum/round_event/aquila_hex_bluespace_interphase/proc/pick_replay(list/servers)
	var/list/candidates = list()
	for(var/obj/machinery/telecomms/server/S as anything in servers)
		if(length(S.log_entries))
			candidates += S
	while(length(candidates))
		var/obj/machinery/telecomms/server/S = pick_n_take(candidates)
		var/list/entries = S.log_entries.Copy()
		while(length(entries))
			var/datum/comm_log_entry/entry = pick_n_take(entries)
			var/list/params = entry.parameters
			if(entry.input_type == "Uszkodzony plik" || !istext(params["message"]) || !length(params["message"]))
				continue // zgubione w kompresji, Eris też by tego nie odczytał
			var/language = params["language"]
			if(!ispath(language, /datum/language))
				language = /datum/language/common
			// serwer działu słucha jednego kanału; wspólny serwer (wszystkie częstotliwości) nadaje na ogólnym
			var/frequency = length(S.freq_listening) == 1 ? S.freq_listening[1] : FREQ_COMMON
			return list(
				"message" = params["message"],
				"name" = params["name"] || "Unknown",
				"job" = params["job"] || "Unknown",
				"language" = language,
				"frequency" = frequency,
				"server" = S,
			)

/// Nadaje powtórkę na okręcie, z pominięciem sieci telekomunikacji (to echo z bluespace, nie nowa rozmowa)
/datum/round_event/aquila_hex_bluespace_interphase/proc/broadcast_replay(list/replay)
	var/obj/machinery/telecomms/server/S = replay["server"]
	if(QDELETED(S))
		return
	var/list/levels = list()
	for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		var/turf/T = locate(1, 1, z)
		if(T)
			levels |= T.get_virtual_z_level()
	if(!length(levels))
		return
	var/atom/movable/virtualspeaker/virt = new(null)
	virt.name = replay["name"]
	virt.job = replay["job"]
	var/datum/signal/subspace/vocal/signal = new(S, replay["frequency"], virt, replay["language"], replay["message"], list(), list(), levels)
	signal.data["compression"] = 0
	signal.broadcast()
	log_game("Bluespace Interphase replayed \"[replay["message"]]\" by [replay["name"]] on [replay["frequency"]].")
