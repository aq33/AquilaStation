// AQUILA - testy regresji błędów z recenzji aq33/AquilaStation#638 (mapa hex: skoki, zapis kampanii, wojna, atomówki, misje)
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Outpost 45 (wejście kończy rundę) leży na siatce, ale jest nieprzelotny: ani trasa, ani zasięg skoku do niego nie prowadzą
/datum/unit_test/hexmap_end_system_blocked

/datum/unit_test/hexmap_end_system_blocked/Run()
	if(!GLOB.hexmap?.built)
		return
	var/datum/hex/H
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(S.hex && (S.system_traits & STARSYSTEM_END_ON_ENTER))
			H = S.hex
			break
	if(!H)
		return
	TEST_ASSERT(GLOB.hexmap.blocks(H), "A system that ends the round on entry is not blocked on the hex map")
	var/datum/hex/near
	for(var/datum/hex/N as anything in GLOB.hexmap.neighbours(H))
		if(!GLOB.hexmap.blocks(N))
			near = N
			break
	if(!near)
		return
	TEST_ASSERT(!GLOB.hexmap.route(near, H, "nanotrasen", 5000), "A route leads into [H.system]")
	TEST_ASSERT(!(H in GLOB.hexmap.reachable(near, "nanotrasen", 100)), "[H.system] is in the jump range of a neighbouring hex")

/// Kontratak na odbitą placówkę na pustym kaflu (bez szlaków) rusza z sąsiedniego kafla; dawniej pick() z pustej listy
/datum/unit_test/hexmap_board_station_counterattack

/datum/unit_test/hexmap_board_station_counterattack/Run()
	if(!GLOB.hexmap?.built)
		return
	var/list/free = GLOB.hexmap.free_hexes(SECTOR_NEUTRAL)
	if(!length(free))
		return
	var/datum/hex/spot = free[1]
	var/datum/star_system/random/hex_empty/E = GLOB.hexmap.system_for(spot)
	var/datum/overmap_objective/board_station/O = new(E)
	O.send_counterattack()
	var/datum/fleet/F = O.reinforcements
	var/datum/star_system/where = F?.current_system
	var/datum/hex/where_hex = where?.hex
	if(F)
		O.UnregisterSignal(F, list(COMSIG_PARENT_QDELETING, COMSIG_FLEET_AI_RETREATED)) // misja bez stacji: bez sprawdzania celu
		F.hex_war_dispose()
	qdel(O)
	if(istype(where, /datum/star_system/random/hex_empty) && where != E)
		var/datum/star_system/random/hex_empty/W = where
		W.try_release()
	E.try_release()
	TEST_ASSERT(F, "No counterattack fleet was sent to a station on an empty hex")
	TEST_ASSERT(where == E || (where_hex in GLOB.hexmap.neighbours(spot)), "The counterattack fleet started away from the station ([where])")

/// Własny pocisk gracza w jego kaflu nie schodzi do walki taktycznej z jego okrętem, a wrogi schodzi
/datum/unit_test/hexmap_nuke_own_missile

/datum/unit_test/hexmap_nuke_own_missile/Run()
	var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
	var/datum/hex/here = ship?.current_hex()
	if(!here)
		return
	var/datum/hex_nuke/own = new
	own.faction = ship.faction
	own.hex = here
	var/datum/hex_nuke/enemy = new
	enemy.faction = "syndicate"
	enemy.hex = here
	var/own_hits = own.hits_player(ship, here)
	var/enemy_hits = enemy.hits_player(ship, here)
	qdel(own)
	qdel(enemy)
	TEST_ASSERT(!own_hits, "The player's own missile turned on the player's ship")
	TEST_ASSERT(enemy_hits, "An enemy missile in the player's hex skipped the tactical fight")

/// Atomówki nie da się odpalić w czarną dziurę: pocisk nie ma trasy i przepadłby po cichu razem z torpedą
/datum/unit_test/hexmap_nuke_black_hole

/datum/unit_test/hexmap_nuke_black_hole/Run()
	var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
	if(!ship || !GLOB.hexmap?.built || !GLOB.hex_war?.ready)
		return
	var/datum/hex/hole
	for(var/id in GLOB.hexmap.hexes)
		var/datum/hex/H = GLOB.hexmap.hexes[id]
		if(H.terrain == HEX_TERRAIN_BLACK_HOLE)
			hole = H
			break
	if(!hole)
		return
	var/reason = ship.hex_nuke_blocker(hole)
	TEST_ASSERT(findtext(reason, "nie doleci"), "Firing a nuke into a black hole was not blocked: [reason]")

/// Zapis przed startem wojny (restart w lobby: SStimer stoi, late_setup nie ruszył) zostawia wojnę z poprzedniego zapisu
/datum/unit_test/hexmap_save_before_war_ready

/datum/unit_test/hexmap_save_before_war_ready/Run()
	if(!GLOB.hexmap?.built)
		return
	var/had_save = fexists(HEXMAP_SAVE_PATH)
	var/original = had_save ? rustg_file_read(HEXMAP_SAVE_PATH) : null
	var/list/fake = list("version" = HEXMAP_SAVE_VERSION, "map_name" = SSmapping.config?.map_name, "war" = list("marker" = 7))
	fdel(HEXMAP_SAVE_PATH)
	rustg_file_write(json_encode(fake), HEXMAP_SAVE_PATH)
	var/was_ready = GLOB.hex_war?.ready
	if(GLOB.hex_war)
		GLOB.hex_war.ready = FALSE
	var/path = "data/hexmap_test_before_ready.json"
	SSstar_system.hexmap_write(path)
	if(GLOB.hex_war)
		GLOB.hex_war.ready = was_ready
	var/list/written = hexmap_read_save(path)
	fdel(path)
	fdel(HEXMAP_SAVE_PATH)
	if(had_save)
		rustg_file_write(original, HEXMAP_SAVE_PATH)
	var/list/war = written?["war"]
	TEST_ASSERT_EQUAL(war?["marker"], 7, "A save before the war started wiped the war from the campaign")

/// Rozkaz ataku na układ, w którym flota już stoi, zamienia się w HOLD (dawniej flota stała z ATTACK do końca kampanii)
/datum/unit_test/hexmap_war_attack_own_system

/datum/unit_test/hexmap_war_attack_own_system/Run()
	var/list/pair = hexmap_war_test_pair()
	if(!pair)
		return
	var/datum/star_system/home = pair[1]
	var/list/saved = hexmap_war_test_save(home)
	var/datum/fleet/F = home.spawn_fleet(/datum/fleet/nanotrasen/light, 2)
	F.hex_war_adopt()
	F.hex_war_set_order(HEX_ORDER_ATTACK, home)
	F.move()
	var/order = F.war_order
	var/datum/hex_commander/C = F.commander
	F.commander = null
	F.hex_war_dispose()
	GLOB.hex_war.commanders -= C
	hexmap_war_test_restore(home, saved)
	TEST_ASSERT_EQUAL(order, HEX_ORDER_HOLD, "A fleet ordered to attack the system it stands in kept the attack order")

/// Skok awaryjny w locie jest odrzucany (dawniej bazowy skok z układu null: runtime w jump_start i napęd w stanie skoku)
/datum/unit_test/hexmap_emergency_jump_in_flight

/datum/unit_test/hexmap_emergency_jump_in_flight/Run()
	var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
	var/list/info = SSstar_system.ships[ship]
	if(!ship?.ftl_drive || !info || !ship.current_system)
		return
	var/saved_target = info["target_system"]
	var/saved_next = ship.next_emergency_jump
	info["target_system"] = ship.current_system
	var/result = ship.emergency_jump()
	var/next = ship.next_emergency_jump
	info["target_system"] = saved_target
	ship.next_emergency_jump = saved_next
	TEST_ASSERT(!result && next == saved_next, "An emergency jump started while the ship was in hyperspace")

/// Wyłączone losowe eventy (werb admina, sandbox) wyłączają też eventy z kafli
/datum/unit_test/hexmap_events_respect_toggle

/datum/unit_test/hexmap_events_respect_toggle/Run()
	var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
	var/datum/hex/here = ship?.current_hex()
	if(!here)
		return
	var/saved = CONFIG_GET(flag/allow_random_events)
	CONFIG_SET(flag/allow_random_events, FALSE)
	var/before = ship.hex_last_tile_event
	ship.hex_fire_tile_event(here, TRUE)
	var/after = ship.hex_last_tile_event
	CONFIG_SET(flag/allow_random_events, saved)
	TEST_ASSERT(after == before, "A tile event fired with random events disabled")

/// Pościg za okrętem na pustym kaflu (ukryty, bez szlaków): kursem jest sam cel, po którym flota idzie krokami po kaflach
/datum/unit_test/hexmap_pursuit_to_empty_hex

/datum/unit_test/hexmap_pursuit_to_empty_hex/Run()
	var/list/pair = hexmap_war_test_pair()
	if(!pair)
		return
	var/datum/star_system/home = pair[1]
	var/datum/hex/far
	for(var/datum/hex/H as anything in GLOB.hexmap.free_hexes(home.hex.sector))
		if(GLOB.hexmap.distance(home.hex, H) >= 2)
			far = H
			break
	if(!far)
		return
	var/datum/star_system/random/hex_empty/target = GLOB.hexmap.system_for(far)
	var/list/saved = hexmap_war_test_save(home)
	var/datum/fleet/F = home.spawn_fleet(/datum/fleet/nanotrasen/light, 1)
	var/list/course = F.navigate_to(target)
	var/has_target = islist(course) && (target in course)
	F.hex_war_dispose()
	hexmap_war_test_restore(home, saved)
	target.try_release()
	TEST_ASSERT(has_target, "A fleet found no course to a ship on an empty hex")

/// Eventy stawiające obiekty przy okręcie nie działają w nadprzestrzeni (trafiłyby do starego układu na płaszczyznę gracza)
/datum/unit_test/hexmap_overmap_events_not_in_flight

/datum/unit_test/hexmap_overmap_events_not_in_flight/Run()
	var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
	var/list/info = SSstar_system.ships[ship]
	if(!info || !aquila_hex_ship_settled(ship))
		return
	var/saved_target = info["target_system"]
	info["target_system"] = ship.current_system
	var/in_flight = aquila_hex_ship_settled(ship)
	var/turf/spot = aquila_hex_overmap_spot_beside(ship, 3)
	info["target_system"] = saved_target
	TEST_ASSERT(!in_flight, "A ship in hyperspace counted as settled in a star system")
	TEST_ASSERT(!spot, "An overmap event found a spot beside a ship in hyperspace")

/// Odtworzenie wojny: oblężony układ zostaje przy właścicielu, zajęty przy zdobywcy (zapis "occupied")
/datum/unit_test/hexmap_war_restore_occupation

/datum/unit_test/hexmap_war_restore_occupation/Run()
	if(!GLOB.hex_war)
		return
	var/datum/star_system/target
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(S.hex && !istype(S, /datum/star_system/random) && (S.owner in GLOB.hex_war_factions) && S.alignment == S.owner)
			target = S
			break
	if(!target)
		return
	var/list/saved = hexmap_war_test_save(target)
	var/enemy = target.owner == "syndicate" ? "nanotrasen" : "syndicate"
	// Pozostałe zajęcia zostają bez zmian, żeby test nie ruszał stanu kampanii
	var/list/current = list()
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(S != target && S.hex && !istype(S, /datum/star_system/random/hex_empty) && S.alignment != S.owner)
			current[S.name] = S.alignment
	target.alignment = enemy // jak po spawn_fleet() oblegającej floty
	GLOB.hex_war.restore_occupation(current)
	var/contested = target.alignment
	target.alignment = enemy
	var/list/occupied = current.Copy()
	occupied[target.name] = enemy
	GLOB.hex_war.restore_occupation(occupied)
	var/held = target.alignment
	hexmap_war_test_restore(target, saved)
	TEST_ASSERT_EQUAL(contested, saved[1], "A besieged system came back from the save as taken by the besieger")
	TEST_ASSERT_EQUAL(held, enemy, "An occupied system came back from the save as free")

/// Start rundy w zapisanym układzie wroga przenosi się do przyjaznej stacji albo startu trybu
/datum/unit_test/hexmap_start_not_at_enemy

/datum/unit_test/hexmap_start_not_at_enemy/Run()
	if(!GLOB.hexmap?.built)
		return
	var/datum/star_system/enemy
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(S.hex && !S.hidden && !istype(S, /datum/star_system/random) && hex_factions_hostile("nanotrasen", S.alignment) && !GLOB.hexmap.blocks(S.hex))
			enemy = S
			break
	if(!enemy)
		return
	var/path = "data/hexmap_test_start.json"
	var/list/fake = list("version" = HEXMAP_SAVE_VERSION, "map_name" = SSmapping.config?.map_name, "ship_system" = enemy.name, "ship_hex" = enemy.hex.id)
	fdel(path)
	rustg_file_write(json_encode(fake), path)
	var/datum/star_system/start = SSstar_system.campaign_start_system(SSovermap_mode.mode?.starting_system, path)
	fdel(path)
	TEST_ASSERT(start != enemy, "The round would start in [enemy], held by [enemy.alignment]")

/// Układ dokładany po budowie mapy (Badlands Lite co rundę) omija teren, zamiast go kasować na stałe
/datum/unit_test/hexmap_new_system_keeps_terrain

/datum/unit_test/hexmap_new_system_keeps_terrain/Run()
	if(!GLOB.hexmap?.built)
		return
	var/datum/hex/H
	for(var/id in GLOB.hexmap.hexes)
		var/datum/hex/candidate = GLOB.hexmap.hexes[id]
		if(candidate.system || candidate.terrain == HEX_TERRAIN_EMPTY || candidate.terrain == HEX_TERRAIN_WORMHOLE || GLOB.hexmap.is_edge(candidate))
			continue
		H = candidate
		break
	if(!H)
		return
	var/list/dims = GLOB.hexmap.sectors["[H.sector]"]
	var/datum/star_system/S = new /datum/star_system("Aquila test [world.time]", system_traits = STARSYSTEM_NO_ANOMALIES | STARSYSTEM_NO_ASTEROIDS | STARSYSTEM_NO_WORMHOLE)
	S.sector = H.sector
	S.x = (H.col - HEX_MARGIN) * HEX_UNITS_PER_HEX + dims["min_x"]
	S.y = dims["max_y"] - (H.row - HEX_MARGIN) * HEX_UNITS_PER_HEX * 0.866
	var/terrain_before = H.terrain
	var/datum/hex/placed = GLOB.hexmap.place_system(S)
	var/terrain_after = H.terrain
	var/placed_terrain = placed?.terrain
	if(placed)
		placed.system = null
	GLOB.hexmap.system_hexes -= S.name
	S.hex = null
	qdel(S)
	TEST_ASSERT(placed && placed != H, "A system placed after the map was built took a hex with terrain")
	TEST_ASSERT_EQUAL(terrain_after, terrain_before, "Placing a system wiped the terrain of [H.id]")
	TEST_ASSERT_EQUAL(placed_terrain, HEX_TERRAIN_EMPTY, "The system landed on a hex with terrain")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
