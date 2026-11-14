// AQUILA - mapa hex (aquila/code/modules/overmap/hexmap/): siatka, trasy, koszt skoku, puste kafle, ruch flot,
// start rundy z zapisu kampanii i stacja końca rundy.
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

#define HEXMAP_TEST_SAVE "data/unit_test_hexmap.json"
#define HEXMAP_TEST_MAP_CONFIG "data/unit_test_map_config.json"

/// Każdy układ z mapy leży na własnym hexie swojego sektora, a szlaki między sektorami są bramami
/datum/unit_test/hexmap_grid

/datum/unit_test/hexmap_grid/Run()
	TEST_ASSERT(GLOB.hexmap?.built, "The hex map was not built at load")
	var/list/taken = list()
	var/placed = 0
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(S.hidden || istype(S, /datum/star_system/random))
			continue
		TEST_ASSERT(S.hex, "[S] has no hex")
		TEST_ASSERT(!taken[S.hex], "[S] and [taken[S.hex]] share the hex [S.hex.id]")
		taken[S.hex] = S
		placed++
		TEST_ASSERT_EQUAL(S.hex.system, S, "The hex of [S] points at another system")
		TEST_ASSERT_EQUAL(S.hex.sector, S.sector || SECTOR_NEUTRAL, "[S] was put into another sector")
		for(var/other_name in S.initial_adjacencies)
			var/datum/star_system/other = SSstar_system.system_by_id(other_name)
			if(other?.hex && other.hex.sector != S.hex.sector)
				TEST_ASSERT(other.hex in S.hex.gates, "The lane [S] - [other] between sectors is not a gate")
	TEST_ASSERT(placed, "No star system was placed on the hex map")
	var/datum/hex/inner
	for(var/id in GLOB.hexmap.hexes)
		var/datum/hex/H = GLOB.hexmap.hexes[id]
		if(length(GLOB.hexmap.neighbours(H)) == 6)
			inner = H
			break
	TEST_ASSERT(inner, "No hex has six neighbours")
	for(var/datum/hex/N as anything in GLOB.hexmap.neighbours(inner))
		TEST_ASSERT_EQUAL(GLOB.hexmap.distance(inner, N), 1, "A neighbour of [inner.id] is not one hex away ([N.id])")

/// Skok o 3 kafle kosztuje cały napęd, czwarty kafel jest poza zasięgiem, brama kosztuje 2/3, a brama w układzie wroga jest zamknięta
/datum/unit_test/hexmap_route

/datum/unit_test/hexmap_route/Run()
	var/datum/hex/start
	var/datum/hex/three_away
	var/datum/hex/four_away
	for(var/id in GLOB.hexmap.hexes)
		var/datum/hex/H = GLOB.hexmap.hexes[id]
		if(length(GLOB.hexmap.neighbours(H)) != 6)
			continue
		three_away = null
		four_away = null
		for(var/datum/hex/other as anything in GLOB.hexmap.hexes_in_range(H, 4))
			var/d = GLOB.hexmap.distance(H, other)
			if(d == 3 && !three_away)
				three_away = other
			if(d == 4 && !four_away)
				four_away = other
		if(three_away && four_away)
			start = H
			break
	TEST_ASSERT(start, "No hex with room for a three hex jump")
	var/list/route = GLOB.hexmap.route(start, three_away, null)
	TEST_ASSERT(route, "No route three hexes across empty space")
	TEST_ASSERT_EQUAL(route["hexes"], 3, "A jump three hexes away has another length")
	TEST_ASSERT(abs(route["cost"] - HEX_FTL_FULL_CHARGE) < 0.01, "Three hexes should take the full charge, took [route["cost"]]")
	var/list/reach = GLOB.hexmap.reachable(start, null, HEX_FTL_FULL_CHARGE)
	TEST_ASSERT(reach[three_away], "A hex three away is out of reach with a full drive")
	TEST_ASSERT(!reach[four_away], "A hex four away is in reach with a full drive")

	var/datum/hex/gate
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(S.hex && LAZYLEN(S.hex.gates))
			gate = S.hex
			break
	if(!gate)
		return // No sectors linked in this run
	var/datum/hex/other_side = gate.gates[1]
	var/list/through = GLOB.hexmap.route(gate, other_side, null)
	TEST_ASSERT(through, "No route through the gate [gate.id] - [other_side.id]")
	TEST_ASSERT_EQUAL(through["hexes"], 1, "Going through a gate is not one jump")
	TEST_ASSERT(abs(through["cost"] - HEX_FTL_COST_GATE) < 0.01, "A gate should cost [HEX_FTL_COST_GATE], cost [through["cost"]]")
	var/saved_alignment = gate.system.alignment
	gate.system.alignment = "syndicate"
	var/list/closed = GLOB.hexmap.route(gate, other_side, "nanotrasen", HEX_FTL_COST_GATE)
	gate.system.alignment = saved_alignment
	TEST_ASSERT(!closed, "A Nanotrasen ship went through a gate in a Syndicate held system")

/// Pusty kafel dostaje układ przy wejściu i oddaje go, gdy nic w nim nie zostało
/datum/unit_test/hexmap_empty_hex

/datum/unit_test/hexmap_empty_hex/Run()
	var/datum/hex/empty
	for(var/id in GLOB.hexmap.hexes)
		var/datum/hex/H = GLOB.hexmap.hexes[id]
		if(!H.system)
			empty = H
			break
	TEST_ASSERT(empty, "The hex map has no empty hex")
	var/datum/star_system/random/hex_empty/S = GLOB.hexmap.system_for(empty)
	TEST_ASSERT(istype(S), "An empty hex got a [S?.type] instead of an empty hex system")
	TEST_ASSERT_EQUAL(S.hex, empty, "The empty hex system does not know its hex")
	TEST_ASSERT_EQUAL(empty.system, S, "The hex does not point at its new system")
	TEST_ASSERT(S in SSstar_system.systems, "The empty hex system is not in SSstar_system.systems")
	TEST_ASSERT(S.hidden, "An empty hex system shows up on old star maps")
	TEST_ASSERT(S.try_release(), "An unused empty hex system was not released")
	TEST_ASSERT(!empty.system, "The hex still points at its released system")
	TEST_ASSERT(!(S in SSstar_system.systems), "A released empty hex system stayed in SSstar_system.systems")

/// Skok po hexach zabiera część ładunku, zostawia napęd włączony i rusza cooldown; skok za ostatnią część ładunku gasi napęd
/datum/unit_test/hexmap_jump_charge

/datum/unit_test/hexmap_jump_charge/Run()
	var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
	var/obj/machinery/computer/ship/ftl_core/drive = ship?.ftl_drive
	if(!drive)
		return // No main ship with a drive on this map
	var/thirring = istype(drive, /obj/machinery/computer/ship/ftl_core)
	var/obj/machinery/computer/ship/ftl_computer/legacy = drive
	var/full = thirring ? drive.req_charge : legacy.spoolup_time
	var/saved_progress = drive.progress
	var/saved_state = drive.ftl_state
	var/saved_active = drive.active
	var/was_processing = drive.datum_flags & DF_ISPROCESSING
	// Other tests may leave the main ship in flight (sabre_gets_towed jumps it); this test is about the drive, not the flight
	var/list/info = SSstar_system.ships[ship]
	var/saved_target = info?["target_system"]
	if(info)
		info["target_system"] = null
	var/fail = check_charge(ship, drive, full)
	if(info)
		info["target_system"] = saved_target
	drive.progress = saved_progress
	drive.ftl_state = saved_state
	drive.active = saved_active
	if(thirring)
		drive.cooldown = FALSE
	ship.hex_cooldown_until = 0
	ship.hex_pending_cost = 0
	ship.hex_pending_hexes = 0
	if(!was_processing)
		STOP_PROCESSING(SSmachines, drive)
	if(fail)
		return Fail(fail)

/datum/unit_test/hexmap_jump_charge/proc/check_charge(obj/structure/overmap/ship, obj/machinery/computer/ship/ftl_core/drive, full)
	drive.progress = full
	drive.active = TRUE
	drive.ftl_state = FTL_STATE_JUMPING
	ship.hex_set_pending(HEX_FTL_COST_HEX, 1)
	if(!ship.hex_on_departure(FALSE))
		return "A hex jump was not handled on departure"
	if(abs(ship.hex_charge() - HEX_FTL_COST_HEX * 2) > 0.01)
		return "One hex should leave [HEX_FTL_COST_HEX * 2]% charge, left [ship.hex_charge()]%"
	if(!drive.active || drive.ftl_state == FTL_STATE_IDLE)
		return "The drive turned off after a jump that did not use up its charge"
	if(ship.hex_cooldown_until <= world.time)
		return "No cooldown after a hex jump"
	if(!ship.hex_jump_blocker(HEX_FTL_COST_HEX))
		return "A jump was allowed during the cooldown"
	ship.hex_cooldown_until = 0
	if(ship.hex_jump_blocker(HEX_FTL_COST_HEX * 2))
		return "Two thirds of the charge did not allow a two hex jump: [ship.hex_jump_blocker(HEX_FTL_COST_HEX * 2)]"
	if(!ship.hex_jump_blocker(HEX_FTL_FULL_CHARGE))
		return "A jump that costs more than the charge left was allowed"
	drive.ftl_state = FTL_STATE_JUMPING
	ship.hex_set_pending(HEX_FTL_COST_HEX * 2, 2)
	ship.hex_on_departure(FALSE)
	if(ship.hex_charge() > 0.01)
		return "The last of the charge was not used up: [ship.hex_charge()]%"
	if(drive.active)
		return "The drive stayed on with no charge left (engineering has to turn it back on)"
	ship.hex_set_pending(HEX_FTL_COST_HEX, 1)
	if(ship.hex_on_departure(TRUE))
		return "An emergency jump was counted as a hex jump"
	if(ship.hex_pending_cost)
		return "An emergency jump left a pending hex jump cost"
	ship.hex_set_pending(0, 3)
	if(abs(ship.hex_travel_minutes(99) - (HEX_FTL_TRAVEL_BASE + HEX_FTL_TRAVEL_PER_HEX * 3) / (1 MINUTES)) > 0.001)
		return "A three hex flight takes [ship.hex_travel_minutes(99)] minutes"
	// A plan left over from a jump that interdiction stopped does not carry over to the next, unrelated jump
	ship.hex_pending_time = world.time - 10 MINUTES
	if(ship.hex_travel_minutes(99) != 99)
		return "A stale hex jump plan changed the flight time of another jump"
	ship.hex_set_pending(HEX_FTL_COST_HEX, 1)
	ship.hex_pending_time = world.time - 10 MINUTES
	if(ship.hex_on_departure(FALSE))
		return "A stale hex jump plan took charge on another jump"

/// Flota AI idzie do celu kafel po kaflu i pamięta cel między ruchami
/datum/unit_test/hexmap_fleet_step

/datum/unit_test/hexmap_fleet_step/Run()
	var/datum/star_system/home
	var/datum/star_system/target
	var/datum/star_system/player_system = SSstar_system.find_main_overmap()?.current_system
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(!S.hex || S.hidden || S == player_system || length(S.fleets) || istype(S, /datum/star_system/random))
			continue
		for(var/datum/star_system/T as anything in SSstar_system.systems)
			if(T == S || !T.hex || T.hidden || T == player_system || istype(T, /datum/star_system/random) || T.hex.sector != S.hex.sector)
				continue
			if(GLOB.hexmap.distance(S.hex, T.hex) >= 3 && GLOB.hexmap.route(S.hex, T.hex, null, 5000))
				home = S
				target = T
				break
		if(home)
			break
	if(!home)
		return // No two systems far enough apart in this run
	var/list/empty_before = list()
	for(var/datum/star_system/random/hex_empty/E in SSstar_system.systems)
		empty_before += E
	var/saved_alignment = home.alignment
	var/saved_mission = home.mission_sector
	var/datum/fleet/fleet = new
	fleet.can_reinforce = FALSE
	fleet.hide_movements = TRUE
	fleet.current_system = home
	home.fleets += fleet
	var/moved = fleet.move(target, TRUE)
	var/datum/star_system/step = fleet.current_system
	var/fail
	if(!moved)
		fail = "The fleet did not move"
	else if(step == target)
		fail = "The fleet jumped [GLOB.hexmap.distance(home.hex, target.hex)] hexes at once"
	else if(GLOB.hexmap.distance(home.hex, step.hex) != 1)
		fail = "The fleet's step was not to a neighbouring hex"
	else if(GLOB.hexmap.distance(step.hex, target.hex) >= GLOB.hexmap.distance(home.hex, target.hex))
		fail = "The fleet's step did not bring it closer to its target"
	else if(fleet.hex_heading != target)
		fail = "The fleet forgot where it was going"
	else if(!(fleet in step.fleets) || (fleet in home.fleets))
		fail = "The fleet lists were not updated by the step"
	else if(fleet.hex_continue_heading() != target)
		fail = "The next move would not continue to the target"
	step?.fleets -= fleet
	home.fleets -= fleet
	fleet.current_system = null
	home.alignment = saved_alignment
	home.mission_sector = saved_mission
	qdel(fleet)
	for(var/datum/star_system/random/hex_empty/E in SSstar_system.systems)
		if(!(E in empty_before))
			E.try_release()
	if(fail)
		return Fail(fail)

/// Ten sam okręt zaczyna rundę tam, gdzie skończył poprzednią; inny okręt zaczyna od startu trybu
/datum/unit_test/hexmap_campaign_start

/datum/unit_test/hexmap_campaign_start/Run()
	var/datum/star_system/start = SSstar_system.system_by_id("Argo")
	var/datum/star_system/saved
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(S.hex && !S.hidden && S != start && !istype(S, /datum/star_system/random))
			saved = S
			break
	if(!saved)
		return
	var/map_name = SSmapping.config?.map_name
	write_save(map_name, saved.hex.id, saved.name)
	var/datum/star_system/got = SSstar_system.campaign_start_system("Argo", HEXMAP_TEST_SAVE)
	if(got != saved)
		fdel(HEXMAP_TEST_SAVE)
		return Fail("The same ship started in [got] instead of [saved], where it ended the last round")
	write_save("Inny okręt", saved.hex.id, saved.name)
	got = SSstar_system.campaign_start_system("Argo", HEXMAP_TEST_SAVE)
	if(got != start)
		fdel(HEXMAP_TEST_SAVE)
		return Fail("Another ship started in [got] instead of the mode's start [start]")
	var/datum/hex/empty
	for(var/id in GLOB.hexmap.hexes)
		var/datum/hex/H = GLOB.hexmap.hexes[id]
		if(!H.system)
			empty = H
			break
	write_save(map_name, empty.id, null)
	var/datum/star_system/random/hex_empty/in_space = SSstar_system.campaign_start_system("Argo", HEXMAP_TEST_SAVE)
	fdel(HEXMAP_TEST_SAVE)
	var/ok = istype(in_space) && in_space.hex == empty
	if(istype(in_space))
		in_space.try_release()
	TEST_ASSERT(ok, "A ship that ended the round in empty space did not start in that hex")

/datum/unit_test/hexmap_campaign_start/proc/write_save(map_name, hex_id, system_name)
	fdel(HEXMAP_TEST_SAVE)
	rustg_file_write(json_encode(list("version" = HEXMAP_SAVE_VERSION, "map_name" = map_name, "ship_hex" = hex_id, "ship_system" = system_name)), HEXMAP_TEST_SAVE)

/// Koniec rundy: najbliższa przyjazna stacja, a stacja zajęta przez wroga nie jest przyjazna
/datum/unit_test/hexmap_return_station

/datum/unit_test/hexmap_return_station/Run()
	var/datum/star_system/station
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(GLOB.hexmap.is_friendly_station(S))
			station = S
			break
	if(!station)
		return // No friendly trading station in this run
	TEST_ASSERT_EQUAL(GLOB.hexmap.nearest_friendly_station(station.hex), station, "From a friendly station the nearest one should be itself")
	var/saved_alignment = station.alignment
	station.alignment = "syndicate"
	var/still_friendly = GLOB.hexmap.is_friendly_station(station)
	station.alignment = saved_alignment
	TEST_ASSERT(!still_friendly, "A station occupied by the Syndicate still counts as friendly")

/// Regression: "return_system" from a map's JSON was written into starmap_path (code/datums/map_config.dm)
/datum/unit_test/hexmap_map_config_return_system

/datum/unit_test/hexmap_map_config_return_system/Run()
	var/list/json = list(
		"map_name" = "Unit test",
		"map_path" = "map_files/debug",
		"map_file" = "runtimestation.dmm",
		"mine_disable" = TRUE,
		"return_system" = "Testowy układ",
	)
	fdel(HEXMAP_TEST_MAP_CONFIG)
	rustg_file_write(json_encode(json), HEXMAP_TEST_MAP_CONFIG)
	var/datum/map_config/config = new
	var/default_starmap = config.starmap_path
	config.LoadConfig(HEXMAP_TEST_MAP_CONFIG)
	fdel(HEXMAP_TEST_MAP_CONFIG)
	TEST_ASSERT_EQUAL(config.return_system, "Testowy układ", "The map's return system was not loaded")
	TEST_ASSERT_EQUAL(config.starmap_path, default_starmap, "The map's return system was written into the starmap path")

/// Regression: the astrometrics console inherits the navigation console and builds on its ui_data(); it must keep the old format
/// (its window went blank when the navigation console switched to the hex map)
/datum/unit_test/hexmap_astrometrics_data

/datum/unit_test/hexmap_astrometrics_data/Run()
	var/turf/inside = SSmapping.get_station_center()
	if(!inside || !SSstar_system.find_main_overmap())
		return
	var/obj/machinery/computer/ship/navigation/astrometrics/astro = allocate(/obj/machinery/computer/ship/navigation/astrometrics, inside)
	var/obj/machinery/computer/ship/navigation/nav = allocate(/obj/machinery/computer/ship/navigation, inside)
	if(!astro.has_overmap() || !nav.has_overmap())
		return // The test turf is not inside the main ship
	var/list/astro_data = astro.ui_data(null)
	TEST_ASSERT(!("ship" in astro_data), "The astrometrics console got the hex map data")
	TEST_ASSERT("travelling" in astro_data, "The astrometrics console lost its own star map data")
	var/list/nav_data = nav.ui_data(null)
	TEST_ASSERT("ship" in nav_data, "The navigation console does not send the hex map data")

/// Regression: save() wrote initial(S.hidden), always 0 for systems loaded from JSON, so every save revealed hidden systems
/datum/unit_test/hexmap_save_keeps_hidden

/datum/unit_test/hexmap_save_keeps_hidden/Run()
	var/datum/star_system/hidden_system
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(S.hidden && !istype(S, /datum/star_system/random))
			hidden_system = S
			break
	if(!hidden_system)
		return // No hidden system on this starmap
	var/path = "config/starmap/unit_test_hidden.json"
	var/result = SSstar_system.save(path)
	var/list/saved = fexists(path) ? json_decode(rustg_file_read(path)) : null
	fdel(path)
	TEST_ASSERT_EQUAL(result, 0, "The test save failed")
	var/found = FALSE
	for(var/list/entry as anything in saved)
		if(entry["name"] == hidden_system.name)
			found = TRUE
			TEST_ASSERT(entry["hidden"], "The hidden system [hidden_system] was saved as visible")
	TEST_ASSERT(found, "[hidden_system] is missing from the save")

#undef HEXMAP_TEST_SAVE
#undef HEXMAP_TEST_MAP_CONFIG
#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
