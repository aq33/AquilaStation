// AQUILA - przelot bogatej komety: obok statku pojawia się kometa z rzadkimi rudami do przyciągnięcia magnesem (port z DS13 code/modules/overmap/events.dm, /datum/overmap_event/comet)
// Tu są też pomocnicze procedury do stawiania obiektów overmapy obok okrętu (wreck_graveyard.dm, freighter_attack.dm).

/**
 * Pole overmapy w danej odległości od okrętu, w jednym z podanych kierunków.
 * Domyślnie wschód albo północ: obiekt stoi wtedy lewym dolnym rogiem w tej odległości i nie nachodzi na okręt,
 * a magnes na asteroidy (orange(5) od okrętu) wciąż go widzi.
 */
/proc/aquila_hex_overmap_spot_beside(obj/structure/overmap/near, distance, list/dirs = list(EAST, NORTH))
	if(!near?.current_system || !near.z)
		return null
	for(var/dir in shuffle(dirs.Copy()))
		var/turf/spot = get_turf(near)
		for(var/i in 1 to distance)
			spot = get_step(spot, dir)
		if(spot)
			return spot
	return get_ranged_target_turf(near, pick(dirs), distance)

/// Dodaje obiekt do układu okrętu i stawia go dokładnie na polu (add_ship rozrzuca w promieniu 15 pól)
/proc/aquila_hex_overmap_place(obj/structure/overmap/thing, obj/structure/overmap/near, turf/spot)
	near.current_system.add_ship(thing, spot)
	thing.forceMove(spot)

/// Odległość, z której magnes okrętu sięga obiektu, a obiekt nie nachodzi na okręt
/proc/aquila_hex_magnet_distance(obj/structure/overmap/near)
	return clamp(CEILING(near.bound_width / world.icon_size, 1) + 1, 2, 5)

/// Kometa z lodowym jądrem pełnym rzadkich rud
/obj/structure/overmap/asteroid/large/aquila_rich_comet
	name = "Bogata kometa (rzadkie rudy)"
	desc = "Lodowe jądro komety poprzerastane żyłami cennych rud. Magnes na asteroidy może je przyciągnąć do klatki."
	core_composition = list(
		/turf/closed/mineral/diamond,
		/turf/closed/mineral/uranium,
		/turf/closed/mineral/bscrystal,
		/turf/closed/mineral/gold,
		/turf/closed/mineral/silver,
		/turf/closed/mineral/plasma,
	)

/datum/round_event_control/aquila_hex_rich_comet
	name = "Przelot bogatej komety"
	typepath = /datum/round_event/aquila_hex_rich_comet
	weight = 10
	min_players = 0
	max_occurrences = 3
	earliest_start = 10 MINUTES

/datum/round_event/aquila_hex_rich_comet
	startWhen = 1
	announceWhen = 2
	endWhen = 2
	/// Kometa, która pojawiła się obok statku
	var/obj/structure/overmap/asteroid/large/aquila_rich_comet/comet

/datum/round_event/aquila_hex_rich_comet/start()
	comet = spawn_comet(SSstar_system.find_main_overmap())
	if(!comet)
		log_game("Rich Comet Flyby: the main ship is not in a star system, cancelling the event.")
		return kill()
	announce_to_ghosts(comet)

/datum/round_event/aquila_hex_rich_comet/announce(fake)
	if(!fake && QDELETED(comet))
		return
	priority_announce("Czujniki wykryły przelatującą w pobliżu [station_name()] kometę bogatą w minerały. Jej lodowe jądro kryje złoża rzadkich rud: \
		górnicy mogą ją przyciągnąć magnesem na asteroidy, zanim okręt odleci.", "Przelot bogatej komety")

/datum/round_event/aquila_hex_rich_comet/kill()
	comet = null
	return ..()

/// Stawia kometę w zasięgu magnesu okrętu. Bez okrętu w układzie gwiezdnym nic nie robi.
/datum/round_event/aquila_hex_rich_comet/proc/spawn_comet(obj/structure/overmap/near)
	if(!near?.current_system || !near.z)
		return null
	var/turf/spot = aquila_hex_overmap_spot_beside(near, aquila_hex_magnet_distance(near))
	if(!spot)
		return null
	var/obj/structure/overmap/asteroid/large/aquila_rich_comet/new_comet = new(spot)
	aquila_hex_overmap_place(new_comet, near, spot)
	return new_comet
