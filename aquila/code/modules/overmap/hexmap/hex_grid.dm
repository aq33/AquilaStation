// AQUILA - siatka hex mapy strategicznej. Każdy sektor (1 Sol, 2 neutralny, 3 Syndykat) to osobna mapa,
// jak w oknie mapy gwiezdnej; sektory łączą bramy na szlakach międzysektorowych ze starmap.json.
// Układy z mapy leżą na hexach wyliczonych z ich x, y. Pusty hex dostaje układ dopiero, gdy ktoś do niego skacze.

GLOBAL_DATUM(hexmap, /datum/hexmap)

/// Kierunki sąsiadów we współrzędnych osiowych (q, r)
GLOBAL_LIST_INIT(hex_axial_dirs, list(list(1, 0), list(1, -1), list(0, -1), list(-1, 0), list(-1, 1), list(0, 1)))

/datum/hex
	var/id
	var/sector
	/// Współrzędne offsetowe (kolumna, wiersz) – tak rysuje okno
	var/col
	var/row
	/// Współrzędne osiowe – do odległości i sąsiedztwa
	var/q
	var/r
	var/terrain = HEX_TERRAIN_EMPTY
	/// Układ na tym hexie: z mapy albo pusty układ utworzony przy wejściu
	var/datum/star_system/system
	/// Hexy w innych sektorach, do których prowadzi brama z tego hexa
	var/list/gates
	/// Przybliżone współrzędne starmap.json środka hexa (dla starego kodu, który liczy dist())
	var/approx_x
	var/approx_y

/datum/hex/New(sector, col, row)
	src.sector = sector
	src.col = col
	src.row = row
	q = col - (row - (row & 1)) / 2
	r = row
	id = HEX_ID(sector, col, row)

/datum/hex/proc/is_empty_space()
	return !system || istype(system, /datum/star_system/random/hex_empty)

/// Nazwa do okna i komunikatów
/datum/hex/proc/display_name()
	if(system && !istype(system, /datum/star_system/random/hex_empty))
		return system.name
	return "Pusty kafel [col],[row]"

/datum/hexmap
	/// id -> /datum/hex
	var/list/hexes = list()
	/// "sektor:q:r" -> /datum/hex
	var/list/axial = list()
	/// sektor -> list("cols", "rows", "min_x", "max_y")
	var/list/sectors = list()
	/// nazwa układu -> /datum/hex
	var/list/system_hexes = list()
	var/built = FALSE

/datum/hexmap/proc/hex_by_id(id)
	RETURN_TYPE(/datum/hex)
	return hexes[id]

/datum/hexmap/proc/hex_at(sector, col, row)
	RETURN_TYPE(/datum/hex)
	return hexes[HEX_ID(sector, col, row)]

/datum/hexmap/proc/hex_axial(sector, q, r)
	RETURN_TYPE(/datum/hex)
	return axial["[sector]:[q]:[r]"]

/// Hex, na którym leży układ (także pusty układ hexa)
/datum/hexmap/proc/hex_of_system(datum/star_system/S)
	RETURN_TYPE(/datum/hex)
	if(!S)
		return
	if(S.hex)
		return S.hex
	var/datum/hex/H = system_hexes[S.name]
	if(H)
		return H
	if(place_system(S))
		return S.hex

/**
 * Buduje trzy siatki z układów starmap.json. Wynik zależy tylko od układów z mapy, więc ten sam przy każdym starcie,
 * a zapis kampanii może odnosić się do hexów po identyfikatorze.
 */
/datum/hexmap/proc/build(list/systems_in)
	hexes = list()
	axial = list()
	sectors = list()
	system_hexes = list()
	var/list/by_sector = list()
	for(var/datum/star_system/S as anything in systems_in)
		if(!S || istype(S, /datum/star_system/random))
			continue
		var/sec = S.sector || SECTOR_NEUTRAL
		LAZYADD(by_sector["[sec]"], S)
	for(var/sec in list(SECTOR_SOL, SECTOR_NEUTRAL, SECTOR_SYNDICATE))
		var/list/sec_systems = by_sector["[sec]"]
		if(!length(sec_systems))
			continue
		var/min_x = INFINITY
		var/max_x = -INFINITY
		var/min_y = INFINITY
		var/max_y = -INFINITY
		for(var/datum/star_system/S as anything in sec_systems)
			min_x = min(min_x, S.x)
			max_x = max(max_x, S.x)
			min_y = min(min_y, S.y)
			max_y = max(max_y, S.y)
		for(var/datum/star_system/S as anything in sec_systems) // obszary, w których generatory Badlands losują układy (starsystem.dm)
			switch(S.startup_proc)
				if("STARTUP_PROC_TYPE_BRASIL") // generate_badlands(): x 21–101, y 31–81
					min_x = min(min_x, 20)
					max_x = max(max_x, 102)
					min_y = min(min_y, 30)
					max_y = max(max_y, 82)
				if("STARTUP_PROC_TYPE_BRASIL_LITE") // generate_litelands(): x 26–72, y 126–156
					min_x = min(min_x, 26)
					max_x = max(max_x, 72)
					max_y = max(max_y, 156)
		var/cols = CEILING((max_x - min_x) / HEX_UNITS_PER_HEX, 1) + HEX_MARGIN * 2 + 1
		var/rows = CEILING((max_y - min_y) / (HEX_UNITS_PER_HEX * 0.866), 1) + HEX_MARGIN * 2 + 1
		sectors["[sec]"] = list("cols" = cols, "rows" = rows, "min_x" = min_x, "max_y" = max_y)
		for(var/row in 0 to rows - 1)
			for(var/col in 0 to cols - 1)
				var/datum/hex/H = new(sec, col, row)
				H.approx_x = min_x + (col - HEX_MARGIN + ((row & 1) ? 0.5 : 0)) * HEX_UNITS_PER_HEX
				H.approx_y = max_y - (row - HEX_MARGIN) * HEX_UNITS_PER_HEX * 0.866
				hexes[H.id] = H
				axial["[sec]:[H.q]:[H.r]"] = H
		sortTim(sec_systems, GLOBAL_PROC_REF(cmp_star_system_name))
		for(var/datum/star_system/S as anything in sec_systems)
			place_system(S)
	built = TRUE
	link_gates(systems_in)

/proc/cmp_star_system_name(datum/star_system/a, datum/star_system/b)
	return sorttext(b.name, a.name)

/// Kładzie układ na najbliższym wolnym hexie od jego x, y. Zwraca hex albo nic.
/datum/hexmap/proc/place_system(datum/star_system/S)
	if(!S || S.hex || istype(S, /datum/star_system/random/hex_empty))
		return S?.hex
	var/list/dims = sectors["[S.sector || SECTOR_NEUTRAL]"]
	if(!dims)
		return
	var/col = round((S.x - dims["min_x"]) / HEX_UNITS_PER_HEX + HEX_MARGIN, 1)
	var/row = round((dims["max_y"] - S.y) / (HEX_UNITS_PER_HEX * 0.866) + HEX_MARGIN, 1)
	col = clamp(col, 0, dims["cols"] - 1)
	row = clamp(row, 0, dims["rows"] - 1)
	var/datum/hex/start = hex_at(S.sector || SECTOR_NEUTRAL, col, row)
	var/datum/hex/free = start
	if(start.system)
		free = null
		var/list/queue = list(start)
		var/list/seen = list()
		seen[start] = TRUE
		while(length(queue))
			var/datum/hex/H = queue[1]
			queue.Cut(1, 2)
			if(!H.system)
				free = H
				break
			for(var/datum/hex/N as anything in neighbours(H))
				if(seen[N])
					continue
				seen[N] = TRUE
				queue += N
	if(!free)
		return
	free.system = S
	S.hex = free
	system_hexes[S.name] = free
	return free

/// Bramy: szlaki ze starmap.json łączące układy różnych sektorów
/datum/hexmap/proc/link_gates(list/systems_in)
	for(var/datum/star_system/S as anything in systems_in)
		if(!S?.hex)
			continue
		for(var/other_name in (S.initial_adjacencies || S.adjacency_list))
			var/datum/hex/other = system_hexes[other_name]
			if(!other || other.sector == S.hex.sector)
				continue
			LAZYOR(S.hex.gates, other)
			LAZYOR(other.gates, S.hex)

/// Dokłada układy, które powstały po budowie mapy (Badlands Lite, układy dodane przez admina)
/datum/hexmap/proc/place_new_systems()
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(S.hex || istype(S, /datum/star_system/random/hex_empty))
			continue
		if(istype(S, /datum/star_system/random) && S.hidden)
			continue
		if(place_system(S))
			for(var/other_name in S.adjacency_list) // Badlands Lite łączy się z sektorem tylko szlakami w obrębie sektora
				var/datum/hex/other = system_hexes[other_name]
				if(other && other.sector != S.hex.sector)
					LAZYOR(S.hex.gates, other)
					LAZYOR(other.gates, S.hex)

/// Sąsiedzi w tym samym sektorze
/datum/hexmap/proc/neighbours(datum/hex/H)
	. = list()
	for(var/list/dir as anything in GLOB.hex_axial_dirs)
		var/datum/hex/N = axial["[H.sector]:[H.q + dir[1]]:[H.r + dir[2]]"]
		if(N)
			. += N

/// Odległość w hexach w obrębie sektora (INFINITY między sektorami)
/datum/hexmap/proc/distance(datum/hex/a, datum/hex/b)
	if(a.sector != b.sector)
		return INFINITY
	return (abs(a.q - b.q) + abs(a.r - b.r) + abs(a.q + a.r - b.q - b.r)) / 2

/// Czy z bramy na tym hexie może skoczyć ktoś z tej frakcji (brama w układzie wroga jest zamknięta)
/datum/hexmap/proc/gate_open(datum/hex/H, faction)
	if(!faction || !H.system)
		return TRUE
	return !hex_factions_hostile(faction, H.system.alignment)

/// Sąsiedzi z bramami, przez które ta frakcja może przejść
/datum/hexmap/proc/links(datum/hex/H, faction)
	. = neighbours(H)
	if(LAZYLEN(H.gates) && gate_open(H, faction))
		. += H.gates

/// Koszt przejścia z hexa na sąsiedni, w procentach naładowania
/datum/hexmap/proc/step_cost(datum/hex/from_hex, datum/hex/to_hex)
	return from_hex.sector != to_hex.sector ? HEX_FTL_COST_GATE : HEX_FTL_COST_HEX

/// Teren, przez który nikt nie przelatuje (PR B: czarna dziura)
/datum/hexmap/proc/blocks(datum/hex/H)
	return FALSE

/// Teren, który zatrzymuje skok gracza (PR B: zagrożenia)
/datum/hexmap/proc/stops(datum/hex/H)
	return FALSE

/**
 * Najkrótsza trasa skoku. Zagrożeń nie da się przeskoczyć: trasę liczymy po wszystkich kaflach,
 * a potem ucinamy ją na pierwszym zagrożeniu przed celem.
 * Zwraca list("path" = hexy od startu do miejsca zatrzymania, "full" = cała trasa do celu, "cost", "hexes", "stopped" = hex albo null)
 */
/datum/hexmap/proc/route(datum/hex/start, datum/hex/dest, faction, max_cost = 400)
	if(!start || !dest || start == dest || blocks(dest))
		return
	var/list/dist = list()
	var/list/prev = list()
	dist[start] = 0
	var/list/open = list(start)
	while(length(open))
		var/datum/hex/best
		var/best_d = INFINITY
		for(var/datum/hex/C as anything in open)
			if(dist[C] < best_d)
				best_d = dist[C]
				best = C
		open -= best
		if(best == dest)
			break
		for(var/datum/hex/N as anything in links(best, faction))
			if(blocks(N))
				continue
			var/d = best_d + step_cost(best, N) + ((N != dest && stops(N)) ? 0.01 : 0)
			if(d > max_cost)
				continue
			if(isnull(dist[N]) || d < dist[N])
				dist[N] = d
				prev[N] = best
				open |= N
	if(isnull(dist[dest]))
		return
	var/list/full = list(dest)
	while(full[1] != start)
		full.Insert(1, prev[full[1]])
	var/stop_index = 0
	for(var/i in 2 to length(full) - 1)
		if(stops(full[i]))
			stop_index = i
			break
	var/list/path = stop_index ? full.Copy(1, stop_index + 1) : full.Copy()
	var/cost = 0
	for(var/i in 2 to length(path))
		cost += step_cost(path[i - 1], path[i])
	return list("path" = path, "full" = full, "cost" = cost, "hexes" = length(path) - 1, "stopped" = stop_index ? path[length(path)] : null)

/**
 * Hexy osiągalne z danym budżetem naładowania; zagrożenie kończy trasę, więc za nim nic nie jest osiągalne.
 * Zwraca hex -> koszt.
 */
/datum/hexmap/proc/reachable(datum/hex/from, faction, budget)
	. = list()
	if(!from || budget < HEX_FTL_COST_HEX)
		return
	var/list/dist = list()
	dist[from] = 0
	var/list/open = list(from)
	while(length(open))
		var/datum/hex/best
		var/best_d = INFINITY
		for(var/datum/hex/C as anything in open)
			if(dist[C] < best_d)
				best_d = dist[C]
				best = C
		open -= best
		if(best != from && stops(best))
			continue
		for(var/datum/hex/N as anything in links(best, faction))
			if(blocks(N))
				continue
			var/d = best_d + step_cost(best, N)
			if(d > budget)
				continue
			if(isnull(dist[N]) || d < dist[N])
				dist[N] = d
				open |= N
	for(var/datum/hex/H as anything in dist)
		if(H != from)
			.[H] = dist[H]

/// Układ hexa; pusty hex dostaje go przy pierwszym wejściu
/datum/hexmap/proc/system_for(datum/hex/H)
	RETURN_TYPE(/datum/star_system)
	if(H.system)
		return H.system
	var/datum/star_system/random/hex_empty/S = new(name = "Pusty kafel [H.col],[H.row] ([hex_sector_name(H.sector)])", x = H.approx_x, y = H.approx_y, sector = H.sector)
	S.hex = H
	H.system = S
	SSstar_system.systems += S
	return S

/// Czy frakcje są sobie wrogie (NT, SolGov i WhiteRapids to jeden blok; piraci wrodzy wszystkim; niezależni nikomu)
/proc/hex_factions_hostile(a, b)
	var/static/list/blocs = list("nanotrasen" = "nt", "solgov" = "nt", "whiterapids" = "nt", "syndicate" = "syn", "pirate" = "pir", "unaligned" = "neu")
	var/A = blocs[a]
	var/B = blocs[b]
	if(!A || !B || A == B)
		return FALSE
	if(A == "pir" || B == "pir")
		return TRUE
	if(A == "neu" || B == "neu")
		return FALSE
	return TRUE

/// Nazwa sektora dla graczy
/proc/hex_sector_name(sector)
	switch(sector)
		if(SECTOR_SOL)
			return "Sektor Sol"
		if(SECTOR_NEUTRAL)
			return "Sektor neutralny"
		if(SECTOR_SYNDICATE)
			return "Sektor Syndykatu"
	return "Sektor [sector]"
