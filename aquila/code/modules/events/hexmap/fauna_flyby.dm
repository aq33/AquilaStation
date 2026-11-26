// AQUILA - wspólny przelot kosmicznej fauny obok okrętu (etap E5): trasa w kosmosie wzdłuż burty i event z falami stworów
// (wzór: migracje VOREStation code/modules/events/*_migration.dm i nasza migracja karpi). Stwory lecą od miejsca daleko
// w kosmosie, mijają burtę o kilka pól i odlatują na drugą stronę, gdzie znikają. Do środka okrętu nie wlatują.
// VORE spawns its fish at carp landmarks or the map edge and sends them to the map centre, where they stay; ours fly past
// the hull on a route of space turfs and leave, and the event clears the ones still alive when it ends.

/// Przesuwa pole tak, żeby nie leżało przy krawędzi mapy (przejścia między poziomami)
/proc/aquila_hex_inside_map(turf/T)
	if(!T)
		return null
	var/margin = TRANSITIONEDGE + 2
	return locate(clamp(T.x, margin, world.maxx - margin), clamp(T.y, margin, world.maxy - margin), T.z)

/// Pierwsze pole kosmosu na linii od far do near (licząc od far); null, gdy na linii nie ma kosmosu
/proc/aquila_hex_space_on_line(turf/far, turf/near)
	if(!far || !near)
		return null
	for(var/turf/T as anything in getline(far, near))
		if(isspaceturf(T) && !T.density)
			return T

/**
 * Trasa przelotu obok okrętu: lista (start, punkt mijania, koniec) z pól kosmosu albo pusta lista, gdy nie ma okrętu.
 * side - burta, wzdłuż której stwory lecą; travel_dir - kierunek lotu (prostopadły do burty);
 * clearance - ile pól od kadłuba mijają okręt; span - ile pól lecą przed i za punktem mijania.
 */
/proc/aquila_hex_flyby_route(side, travel_dir, clearance = 4, span = 25)
	side ||= pick(GLOB.cardinals)
	if(!travel_dir || travel_dir == side || travel_dir == turn(side, 180))
		travel_dir = pick(turn(side, 90), turn(side, -90))
	var/turf/hull = aquila_hex_ship_hull_turf(side)
	if(!isspaceturf(hull))
		return list()
	var/turf/pass = aquila_hex_inside_map(get_ranged_target_turf(hull, side, clearance))
	var/turf/start = aquila_hex_space_on_line(aquila_hex_inside_map(get_ranged_target_turf(pass, turn(travel_dir, 180), span)), pass)
	var/turf/finish = aquila_hex_space_on_line(aquila_hex_inside_map(get_ranged_target_turf(pass, travel_dir, span)), pass)
	if(!isspaceturf(pass) || !start || !finish)
		return list()
	return list(start, pass, finish)

/// Do amount wolnych pól kosmosu wokół center (center też się liczy)
/proc/aquila_hex_free_space_near(turf/center, amount, range = 2)
	. = list()
	if(!isturf(center))
		return
	for(var/turf/T as anything in RANGE_TURFS(range, center))
		if(length(.) >= amount)
			return
		if(!isspaceturf(T) || T.density || is_blocked_turf(T, TRUE))
			continue
		. += T

/**
 * Przelot stworów obok okrętu: fale grup, każda grupa z innej strony okrętu.
 * Podtypy ustawiają rodzaje stworów, liczebność, fale i ogłoszenia.
 */
/datum/round_event/aquila_hex_fauna_flyby
	fakeable = FALSE
	announceWhen = 1
	startWhen = 5
	endWhen = 90
	/// Rodzaje stworów z wagami
	var/list/fauna_types = list()
	/// Ile grup w jednej fali (od, do)
	var/groups_min = 1
	var/groups_max = 1
	/// Ile stworów w grupie (od, do)
	var/group_min = 1
	var/group_max = 1
	/// Ile fal (pierwsza leci przy starcie)
	var/waves = 1
	/// Co ile ticków kolejna fala
	var/wave_interval = 5
	/// Najwięcej żywych stworów z eventu naraz; kolejna fala czeka, aż będzie miejsce
	var/fauna_cap = 30
	/// Ile pól od kadłuba stwory mijają okręt (od, do)
	var/clearance_min = 3
	var/clearance_max = 6
	/// Ile fal już poleciało
	var/waves_sent = 0
	/// Tick następnej fali
	var/next_wave = 0
	/// Stwory z tego eventu
	var/list/spawned = list()

/datum/round_event/aquila_hex_fauna_flyby/start()
	send_wave()
	if(!length(spawned))
		log_game("[type]: no space route past the ship, cancelling the event.")
		return kill()
	announce_to_ghosts(spawned[1])

/datum/round_event/aquila_hex_fauna_flyby/tick()
	if(waves_sent < 1 || waves_sent >= waves || activeFor < next_wave)
		return
	if(living_fauna() >= fauna_cap)
		return
	send_wave()

/// Żywe stwory z eventu
/datum/round_event/aquila_hex_fauna_flyby/proc/living_fauna()
	. = 0
	for(var/mob/living/fauna as anything in spawned)
		if(fauna.stat != DEAD)
			.++

/// Jedna fala: kilka grup, każda na własnej trasie
/datum/round_event/aquila_hex_fauna_flyby/proc/send_wave()
	waves_sent++
	next_wave = activeFor + wave_interval
	var/sides = shuffle(GLOB.cardinals.Copy())
	for(var/group in 1 to rand(groups_min, groups_max))
		var/room = fauna_cap - living_fauna()
		if(room <= 0)
			return
		// Burta bez kosmosu obok (np. przy krawędzi mapy) nie daje trasy: wtedy próbuje kolejnych burt
		var/list/route
		for(var/attempt in 0 to 2 * length(sides) - 1)
			route = aquila_hex_flyby_route(sides[(group + attempt - 1) % length(sides) + 1], null, rand(clearance_min, clearance_max))
			if(length(route))
				break
		if(!length(route))
			continue
		spawn_group(route[1], min(rand(group_min, group_max), room), route.Copy(2))

/// Grupa amount stworów na wolnych polach kosmosu wokół center, lecąca przez pola route. Zwraca listę stworów.
/datum/round_event/aquila_hex_fauna_flyby/proc/spawn_group(turf/center, amount, list/route)
	if(!isturf(center) || amount <= 0)
		return list()
	. = spawn_at(aquila_hex_free_space_near(center, amount), route)
	if(length(.))
		log_game("[type]: [length(.)] creature(s) spawned at [AREACOORD(center)].")

/// Po jednym stworze na każdym z pól spots, wszystkie lecą przez pola route. Zwraca listę stworów.
/datum/round_event/aquila_hex_fauna_flyby/proc/spawn_at(list/spots, list/route)
	. = list()
	for(var/turf/spot as anything in spots)
		var/fauna_type = pickweight(fauna_types)
		if(!isturf(spot) || !ispath(fauna_type, /mob/living/basic/aquila_void_fauna))
			continue
		. += add_fauna(new fauna_type(spot), route)

/// Dopisuje stwora do eventu i wysyła go w trasę
/datum/round_event/aquila_hex_fauna_flyby/proc/add_fauna(mob/living/basic/aquila_void_fauna/fauna, list/route)
	RegisterSignal(fauna, COMSIG_PARENT_QDELETING, PROC_REF(on_fauna_deleted))
	spawned += fauna
	fauna.fly_by(route)
	return fauna

/datum/round_event/aquila_hex_fauna_flyby/proc/on_fauna_deleted(datum/source)
	SIGNAL_HANDLER
	spawned -= source

/// Koniec eventu: żywe stwory, które jeszcze krążą, odlatują
/datum/round_event/aquila_hex_fauna_flyby/end()
	for(var/mob/living/basic/aquila_void_fauna/fauna as anything in spawned.Copy())
		fauna.leave_flyby()

/datum/round_event/aquila_hex_fauna_flyby/Destroy()
	for(var/datum/fauna as anything in spawned)
		UnregisterSignal(fauna, COMSIG_PARENT_QDELETING)
	spawned.Cut()
	return ..()
