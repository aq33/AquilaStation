// AQUILA - wspólne procedury plag z mapy hex (etap E7): rozrost od korzenia z twardym limitem (żywy kabel, pleśń),
// wysysanie prądu z APC pomieszczenia, stwory z wentylacji i lista pomieszczeń, w których plaga jeszcze żyje

/**
 * # Rozrastająca się plaga
 * Korzeń (pierwszy kawałek, postawiony bez korzenia) co jakiś czas dokłada nowy kawałek obok losowego kawałka, aż do
 * max_pieces i nie dalej niż max_radius pól od siebie. Rośnie tylko na wolne pola statku, które łączy z kawałkiem
 * powietrze (nie przez ściany, okna i zamknięte drzwi), bez mobów, drzwi i niebezpiecznych obszarów. Zniszczenie
 * korzenia kończy rozrost, a pozostałe kawałki po chwili usychają.
 */
/obj/structure/aquila_hex_spreader
	anchored = TRUE
	density = FALSE
	max_integrity = 30
	/// Korzeń, od którego wszystko rośnie (korzeń wskazuje sam siebie); null, gdy korzeń zginął
	var/obj/structure/aquila_hex_spreader/root
	/// Tylko korzeń: wszystkie żywe kawałki (z nim samym)
	var/list/pieces
	/// Ile kawałków (z korzeniem) może mieć jedna plaga
	var/max_pieces = 30
	/// Najdalej ile pól od korzenia rośnie
	var/max_radius = 6
	/// Szansa (%) na nowy kawałek przy każdym przetworzeniu korzenia (co ok. 2 s)
	var/spread_chance = 25
	/// Typ nowych kawałków; null - ten sam co korzeń
	var/piece_type
	/// Kawałek usycha, bo korzeń zginął
	var/withering = FALSE

/obj/structure/aquila_hex_spreader/Initialize(mapload, obj/structure/aquila_hex_spreader/new_root)
	. = ..()
	if(new_root && !QDELETED(new_root) && new_root.root == new_root)
		root = new_root
		root.pieces += src
		return
	root = src
	pieces = list(src)
	START_PROCESSING(SSobj, src)

/obj/structure/aquila_hex_spreader/Destroy()
	if(root == src)
		STOP_PROCESSING(SSobj, src)
		for(var/obj/structure/aquila_hex_spreader/piece as anything in pieces)
			if(piece != src && !QDELETED(piece))
				piece.root = null
				piece.start_withering()
		pieces = null
	else if(root)
		root.pieces -= src
	root = null
	return ..()

/obj/structure/aquila_hex_spreader/process(delta_time)
	if(root != src || !prob(spread_chance))
		return
	spread()

/// Kawałek bez korzenia usycha po kilkunastu sekundach
/obj/structure/aquila_hex_spreader/proc/start_withering()
	if(withering)
		return
	withering = TRUE
	addtimer(CALLBACK(src, PROC_REF(wither)), rand(5, 30) SECONDS)

/obj/structure/aquila_hex_spreader/proc/wither()
	if(!QDELETED(src))
		visible_message("<span class='notice'>[src] usycha i rozpada się.</span>")
		qdel(src)

/// Tylko korzeń: dokłada jeden kawałek obok losowego kawałka; zwraca nowy kawałek albo null
/obj/structure/aquila_hex_spreader/proc/spread()
	if(root != src || length(pieces) >= max_pieces)
		return null
	var/list/candidates = pieces.Copy()
	for(var/attempt in 1 to 6)
		if(!length(candidates))
			return null
		var/obj/structure/aquila_hex_spreader/from = pick_n_take(candidates)
		var/turf/from_turf = get_turf(from)
		if(!from_turf)
			continue
		for(var/dir in shuffle(GLOB.cardinals.Copy()))
			var/turf/target = get_step(from_turf, dir)
			if(!can_grow_to(from_turf, target))
				continue
			var/grow_type = piece_type || type
			var/obj/structure/aquila_hex_spreader/piece = new grow_type(target, src)
			piece.on_grown(from)
			return piece
	return null

/// Czy z pola from kawałek może wyrosnąć na pole target
/obj/structure/aquila_hex_spreader/proc/can_grow_to(turf/from, turf/target)
	if(!isopenturf(target) || isspaceturf(target) || isgroundlessturf(target) || target.density || target.z != z)
		return FALSE
	if(get_dist(src, target) > max_radius)
		return FALSE
	if(!(target in from.atmos_adjacent_turfs))
		return FALSE
	if(!aquila_hex_spread_turf_ok(target))
		return FALSE
	return !(locate(/obj/structure/aquila_hex_spreader) in target)

/// Wywoływane w nowym kawałku zaraz po wyrośnięciu obok kawałka from
/obj/structure/aquila_hex_spreader/proc/on_grown(obj/structure/aquila_hex_spreader/from)
	return

/// Pole statku, na które może wejść rozrastająca się plaga: bez mobów, drzwi, gęstych obiektów, niebezpiecznych i zamkniętych obszarów
/proc/aquila_hex_spread_turf_ok(turf/T)
	if(!isturf(T))
		return FALSE
	var/area/turf_area = get_area(T)
	if(!turf_area || istype(turf_area, /area/space) || aquila_hex_closed_area_type(turf_area.type))
		return FALSE
	if(locate(/mob/living) in T)
		return FALSE
	if(locate(/obj/machinery/door) in T)
		return FALSE
	return !is_blocked_turf(T, TRUE)

/**
 * Wysysa do amount energii z ogniwa APC pomieszczenia, w którym stoi source; zwraca, ile wyssało (0, gdy pomieszczenie
 * nie ma APC z naładowanym ogniwem). APC doładowuje ogniwo z sieci jak przy każdym poborze, więc plaga z sieci żyje.
 */
/proc/aquila_hex_drain_area_power(atom/source, amount)
	var/area/source_area = get_area(source)
	var/obj/machinery/power/apc/apc = source_area?.get_apc()
	var/obj/item/stock_parts/cell/cell = apc?.cell
	if(!cell || cell.charge <= 0 || amount <= 0)
		return 0
	var/drained = min(amount, cell.charge)
	cell.use(drained)
	return drained

/**
 * Stawia do count stworów typu mob_type na polach z listy (najwyżej per_turf na jednym polu); zwraca listę stworów.
 * Pola zajęte przez innego moba albo drzwi pomija.
 */
/proc/aquila_hex_spawn_on_turfs(list/turfs, count, mob_type, per_turf = 1, message)
	. = list()
	var/list/free = list()
	for(var/turf/T as anything in turfs)
		if(isturf(T) && !QDELETED(T) && !(locate(/obj/machinery/door) in T))
			free += T
	var/list/used = list()
	while(length(.) < count && length(free))
		var/turf/spot = pick(free)
		used[spot]++
		if(used[spot] >= per_turf)
			free -= spot
		var/mob/living/creature = new mob_type(spot)
		if(message)
			creature.visible_message("<span class='warning'>[replacetext(message, "%MOB", "[creature]")]</span>")
		. += creature

/// Nazwy pomieszczeń statku, w których są żywe stwory z listy (puste, gdy nikt nie przeżył); do ogłoszeń na koniec plagi
/proc/aquila_hex_living_areas(list/creatures)
	. = list()
	for(var/datum/weakref/creature_ref as anything in creatures)
		var/mob/living/creature = creature_ref?.resolve()
		if(QDELETED(creature) || creature.stat == DEAD)
			continue
		var/turf/creature_turf = get_turf(creature)
		if(!creature_turf || !is_station_level(creature_turf.z))
			continue
		var/area/creature_area = get_area(creature_turf)
		if(creature_area)
			. |= creature_area.name
