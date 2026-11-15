// AQUILA - misje na losowych kaflach (raport/ftl_mapa_06_plan_pr.md, część F). Decyzja: misje, które da się przenieść,
// dzieją się na losowych kaflach, żeby załoga zaglądała w różne miejsca mapy:
// - abordaż okrętu i abordaż stacji: losowy pusty kafel sektora neutralnego (zamiast układu z mapy);
// - Opuszczona stacja (aq33/AquilaStation#585): losowy pusty kafel sektora neutralnego;
// - skan anomalii: skupiska anomalii na kaflach pól anomalii;
// - zniszczenie floty: prawdziwe floty z mapy (bez zmian); misje z ładunkiem zostają przy stacjach.
// Część misji ma w nagrodę torpedę termojądrową.

#define HEX_MISSION_NUKE_CHANCE 35
#define HEX_OBJECTIVE_COMPLETED 1

#define HEX_MISSION_MIN_RANGE 4
#define HEX_MISSION_MAX_RANGE 9
#define HEX_MISSION_WIDE_RANGE 12
#define HEX_MISSION_SPACING 4
#define HEX_MISSION_SCAN_RANGE 10

/// Kafel misji. kind wybiera regułę rozmieszczenia (hex_mission_rule); bez kind albo bez pasującego kafla – losowy pusty
/// kafel bez zagrożeń w sektorze, z dala od okrętu gracza. Zwraca układ kafla albo fallback bez mapy hex.
/proc/hex_mission_system(datum/star_system/fallback, kind, sector = SECTOR_NEUTRAL, min_distance = 3)
	if(!GLOB.hexmap?.built)
		return fallback
	var/datum/hex/chosen = kind ? hex_mission_pick(kind) : null
	if(chosen)
		if(chosen.terrain == HEX_TERRAIN_SIGNAL)
			chosen.set_terrain(HEX_TERRAIN_EMPTY) // sygnał prowadził do wraku: na mapie zostaje sam cel misji
		return GLOB.hexmap.system_for(chosen)
	var/datum/hex/player_hex = hex_mission_origin()
	var/list/candidates = list()
	for(var/datum/hex/H as anything in GLOB.hexmap.free_hexes(sector))
		if(player_hex && player_hex.sector == H.sector && GLOB.hexmap.distance(player_hex, H) < min_distance)
			continue
		candidates += H
	if(!length(candidates))
		return fallback
	return GLOB.hexmap.system_for(pick(candidates))

/datum/overmap_objective/board_station/New(datum/star_system/passed_input)
	return ..(passed_input || hex_mission_system(null, "board_station"))

/// Skąd liczyć zasięg misji. Misje startowe powstają, zanim okręt przeleci do układu startowego kampanii
/// (SSovermap_mode.Initialize), więc wtedy liczy się od tego układu, a w trakcie rundy od okrętu.
/proc/hex_mission_origin()
	if(SSticker.current_state < GAME_STATE_PLAYING && SSovermap_mode.mode)
		var/datum/star_system/start = SSstar_system.campaign_start_system(SSovermap_mode.mode.starting_system)
		if(start)
			return start.hex || GLOB.hexmap.hex_of_system(start)
	return SSstar_system.find_main_overmap()?.current_hex()

/// Kafle układów trzymanych przez wrogów NT i przez blok NT: list(wrogie, przyjazne). Front liczy się z bieżącej wojny.
/proc/hex_mission_sides()
	var/list/enemy = list()
	var/list/friendly = list()
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(!S.hex || S.hidden || istype(S, /datum/star_system/random/hex_empty))
			continue
		if(hex_factions_hostile("nanotrasen", S.alignment))
			enemy += S.hex
		else if(hex_factions_allied("nanotrasen", S.alignment))
			friendly += S.hex
	return list(enemy, friendly)

/// Najmniejsza odległość (przez bramy) do kafli z listy; stop_at kończy szukanie, gdy znajdzie się tak bliski
/proc/hex_mission_min_distance(datum/hex/H, list/hexes, stop_at = 0)
	. = INFINITY
	for(var/datum/hex/T as anything in hexes)
		. = min(., GLOB.hexmap.war_distance(H, T))
		if(. <= stop_at)
			return

/// Odległość każdego kafla od najbliższego ze źródeł: jedno przejście wszerz po sąsiadach i bramach (skok bramą = 1 kafel,
/// jak w war_distance) zamiast liczenia odległości do każdego układu osobno dla każdego kafla. kafel -> odległość;
/// kafle dalej niż max_depth nie trafiają do wyniku (reguły i tak sprawdzają tylko bliskie odległości)
/proc/hex_mission_distance_field(list/sources, max_depth = INFINITY)
	var/list/field = list()
	var/list/queue = list()
	for(var/datum/hex/H as anything in sources)
		if(isnull(field[H]))
			field[H] = 0
			queue += H
	var/head = 1
	while(head <= length(queue))
		var/datum/hex/H = queue[head++]
		var/next = field[H] + 1
		if(next > max_depth)
			continue
		for(var/datum/hex/N as anything in GLOB.hexmap.neighbours(H))
			if(isnull(field[N]))
				field[N] = next
				queue += N
		for(var/datum/hex/G as anything in H.gates)
			if(isnull(field[G]))
				field[G] = next
				queue += G
	return field

/// Waga kafla dla rodzaju misji (0 = nie pasuje); losowanie idzie tylko wśród kafli z najwyższą wagą.
/// to_enemy/to_friendly: odległość od najbliższego układu wroga NT i bloku NT.
/proc/hex_mission_rule(kind, datum/hex/H, to_enemy, to_friendly)
	switch(kind)
		if("board_ship") // patrol Syndykatu odcięty od swoich: front, po stronie wroga
			if(H.terrain != HEX_TERRAIN_EMPTY || to_enemy > 2)
				return 0
			return (to_enemy < to_friendly && to_friendly <= 4) ? 1 : 0
		if("board_station") // ukryta placówka w głębi terenu wroga, najchętniej przy polu asteroid albo mgławicy
			if(H.terrain != HEX_TERRAIN_EMPTY || to_enemy > 2 || to_friendly < 5 || to_friendly > 8)
				return 0
			for(var/datum/hex/N as anything in GLOB.hexmap.neighbours(H))
				if(N.terrain == HEX_TERRAIN_ASTEROIDS || N.terrain == HEX_TERRAIN_NEBULA)
					return 2
			return 1
		if("derelict") // wrak w strefie niczyjej: nieznany sygnał albo kafel przy złomowisku
			if(to_enemy < 4)
				return 0
			if(H.terrain == HEX_TERRAIN_SIGNAL)
				return 2
			if(H.terrain != HEX_TERRAIN_EMPTY)
				return 0
			for(var/datum/hex/N as anything in GLOB.hexmap.neighbours(H))
				if(N.terrain == HEX_TERRAIN_JUNK)
					return 1
	return 0

/// Kafel dla rodzaju misji albo null. Zawsze: wolny kafel bez wrogiej floty, nie na brzegu, co najmniej HEX_MISSION_SPACING
/// od innych celów. Zasięg od okrętu luzuje się po kolei: 4–9 kafli, 4–12, od 4 bez limitu.
/proc/hex_mission_pick(kind)
	var/datum/hex/origin = hex_mission_origin()
	var/list/sides = hex_mission_sides()
	var/list/taken = list()
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(S.objective_sector && S.hex)
			taken += S.hex
	// Głębokość tylko taka, jaką sprawdzają reguły: dalej znaczy „daleko” (brak wpisu)
	var/list/fields = list(
		hex_mission_distance_field(sides[1], 4),
		hex_mission_distance_field(sides[2], 8),
		hex_mission_distance_field(taken, HEX_MISSION_SPACING),
	)
	// Najpierw tylko kafle w zasięgu 12 od okrętu; całą mapę przegląda dopiero, gdy w zasięgu nic nie pasuje
	var/list/near = origin ? hex_mission_distance_field(list(origin), HEX_MISSION_WIDE_RANGE) : null
	var/list/candidates = list() // kafel -> list(odległość od okrętu, waga)
	if(near)
		for(var/datum/hex/H as anything in near)
			hex_mission_consider(candidates, kind, H, near[H], fields)
		for(var/max_range in list(HEX_MISSION_MAX_RANGE, HEX_MISSION_WIDE_RANGE))
			var/datum/hex/found = hex_mission_best(candidates, max_range)
			if(found)
				return found
	for(var/id in GLOB.hexmap.hexes)
		var/datum/hex/H = GLOB.hexmap.hexes[id]
		if(!near || isnull(near[H]))
			hex_mission_consider(candidates, kind, H, near ? INFINITY : HEX_MISSION_MIN_RANGE, fields)
	return hex_mission_best(candidates, INFINITY)

/// Dopisuje kafel do kandydatów, jeśli pasuje: wolny, bez wrogiej floty, nie na brzegu, w odstępie od innych celów
/proc/hex_mission_consider(list/candidates, kind, datum/hex/H, range, list/fields)
	if(range < HEX_MISSION_MIN_RANGE)
		return
	if(H.system && (!istype(H.system, /datum/star_system/random/hex_empty) || H.system.objective_sector))
		return
	var/list/to_taken = fields[3]
	if(!isnull(to_taken[H]) && to_taken[H] < HEX_MISSION_SPACING)
		return
	if(GLOB.hexmap.blocks(H) || GLOB.hexmap.is_edge(H))
		return
	if(H.system && length(hex_hostile_fleets_in(H.system, "nanotrasen")))
		return
	var/list/to_enemy = fields[1]
	var/list/to_friendly = fields[2]
	var/weight = hex_mission_rule(kind, H, isnull(to_enemy[H]) ? INFINITY : to_enemy[H], isnull(to_friendly[H]) ? INFINITY : to_friendly[H])
	if(weight)
		candidates[H] = list(range, weight)

/// Losowy kandydat w zasięgu spośród tych z najwyższą wagą
/proc/hex_mission_best(list/candidates, max_range)
	var/best = 0
	var/list/picks = list()
	for(var/datum/hex/H as anything in candidates)
		var/list/info = candidates[H]
		if(info[1] > max_range || info[2] < best)
			continue
		if(info[2] > best)
			best = info[2]
			picks = list()
		picks += H
	if(length(picks))
		return pick(picks)

/// Stacje NT do misji ładunkowych: w układach, które blok NT trzyma, w zasięgu okrętu (9, potem 12 kafli, potem dowolnie),
/// a odbiór co najmniej 3 kafle od miejsca dostawy. Bez pasującej stacji zostaje lista bez zmian.
/proc/hex_mission_stations(list/stations, obj/structure/overmap/away_from)
	if(!GLOB.hexmap?.built || !length(stations))
		return stations
	var/datum/hex/origin = hex_mission_origin()
	var/datum/hex/avoid = away_from?.current_system?.hex
	var/list/held = list() // stacja -> odległość od okrętu
	for(var/obj/structure/overmap/S as anything in stations)
		var/datum/star_system/sys = S?.current_system
		if(!sys?.hex || !hex_factions_allied("nanotrasen", sys.alignment))
			continue
		if(avoid && GLOB.hexmap.war_distance(avoid, sys.hex) < 3)
			continue
		held[S] = origin ? GLOB.hexmap.war_distance(origin, sys.hex) : 0
	for(var/max_range in list(HEX_MISSION_MAX_RANGE, HEX_MISSION_WIDE_RANGE, INFINITY))
		var/list/picks = list()
		for(var/S in held)
			if(held[S] <= max_range)
				picks += S
		if(length(picks))
			return picks
	return stations

/// Cel Armady: układ NT najbliżej wrogiego terenu (nie kwatera i nie układ kończący rundę)
/proc/hex_armada_target(list/names)
	if(!GLOB.hexmap?.built)
		return
	var/list/enemy = hex_mission_sides()[1]
	var/best_distance = INFINITY
	var/list/best = list()
	for(var/name in names)
		var/datum/star_system/S = SSstar_system.system_by_id(name)
		if(!S?.hex || S.hidden || S.has_facility(HEX_FAC_HQ) || (S.system_traits & STARSYSTEM_END_ON_ENTER))
			continue
		var/to_enemy = hex_mission_min_distance(S.hex, enemy)
		if(to_enemy < best_distance)
			best_distance = to_enemy
			best = list()
		if(to_enemy == best_distance)
			best += name
	return length(best) ? pick(best) : null

/// Skan: typ anomalii, którego wymaganą liczbę da się znaleźć w zasięgu okrętu (ukryte układy nie są w astrometrii).
/// Gdy żaden typ nie ma tylu w zasięgu, cel spada do tylu, ile jest najwięcej w zasięgu; bez żadnej w zasięgu – jak dotąd.
/datum/overmap_objective/scan/New()
	. = ..()
	if(status || !GLOB.hexmap?.built)
		return
	var/datum/hex/origin = hex_mission_origin()
	if(!origin)
		return
	var/list/in_range = list()
	for(var/obj/effect/overmap_anomaly/A as anything in GLOB.overmap_anomalies)
		var/datum/star_system/S = A.current_system
		if(!S?.hex || S.hidden || GLOB.hexmap.war_distance(origin, S.hex) > HEX_MISSION_SCAN_RANGE)
			continue
		for(var/kind in anomaly_whitelist)
			if(istype(A, kind))
				in_range[kind] += 1
	var/list/enough = list()
	var/most = 0
	var/most_kind
	for(var/kind in in_range)
		if(in_range[kind] >= target)
			enough += kind
		if(in_range[kind] > most)
			most = in_range[kind]
			most_kind = kind
	var/chosen = length(enough) ? pick(enough) : most_kind
	if(!chosen)
		return
	if(!length(enough))
		target = most
	anomaly_type = chosen
	anomaly_name = get_atom_by_type(GLOB.overmap_anomalies, anomaly_type)?.name

/datum/overmap_objective
	/// Nagroda za wykonanie: torpeda termojądrowa w kapsule
	var/hex_nuke_reward = FALSE
	var/hex_nuke_given = FALSE

/// Część misji płaci atomówką: losowane przy starcie misji, dopisane do opisu
/datum/overmap_objective/proc/hex_roll_nuke_reward()
	if(!GLOB.hexmap?.built || !prob(HEX_MISSION_NUKE_CHANCE))
		return
	hex_nuke_reward = TRUE
	brief = "[brief] W nagrodę Dowództwo przyśle torpedę termojądrową."

/datum/overmap_objective/board_ship/instance()
	. = ..()
	hex_roll_nuke_reward()

/datum/overmap_objective/board_station/instance()
	. = ..()
	hex_roll_nuke_reward()

/datum/overmap_objective/derelict_ruin/instance()
	. = ..()
	hex_roll_nuke_reward()

/// Wykonane misje z nagrodą: atomówka kapsułą na okręt gracza (sprawdzane w turze sztabów)
/datum/hex_war/proc/mission_rewards()
	var/obj/structure/overmap/OM = SSstar_system.find_main_overmap()
	if(!OM || !SSovermap_mode?.mode)
		return
	for(var/datum/overmap_objective/O as anything in SSovermap_mode.mode.objectives)
		if(!O.hex_nuke_reward || O.hex_nuke_given || O.status != HEX_OBJECTIVE_COMPLETED)
			continue
		O.hex_nuke_given = TRUE
		OM.send_supplypod(/obj/item/ship_weapon/ammunition/torpedo/nuke)
		priority_announce("Za wykonanie misji „[O.name]” Dowództwo wysyła kapsułą torpedę termojądrową.", "Dowództwo Floty White Rapids")
		log_game("HEXWAR: mission [O.name] rewarded with a nuclear torpedo")

// ===== skupiska anomalii do skanowania =====

/obj/effect/overmap_anomaly/aquila_anomaly_cluster
	name = "Skupisko anomalii"
	desc = "Splot niestabilnych zjawisk w polu anomalii. Skan albo sonda dadzą sporo danych badawczych."
	icon = 'nsv13/goonstation/icons/effects/overmap_anomalies/tearmed.dmi'
	icon_state = "tear"
	research_points = 6000

/// Pole anomalii od razu dostaje układ ze skupiskiem, żeby misja skanowania je widziała
/datum/hex/proc/hex_spawn_anomaly_cluster()
	var/datum/star_system/S = GLOB.hexmap.system_for(src)
	for(var/obj/effect/overmap_anomaly/aquila_anomaly_cluster/A in S.system_contents)
		return
	SSstar_system.spawn_anomaly(/obj/effect/overmap_anomaly/aquila_anomaly_cluster, S)

#undef HEX_MISSION_NUKE_CHANCE
#undef HEX_OBJECTIVE_COMPLETED
