// AQUILA - wojna frakcji na mapie hex (część D): obiekty, ekonomia z konwojami, sztab, dowódcy, zapis floty, mgła wojny.
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Dwa widoczne układy z mapy w jednym sektorze, połączone trasą (do testów ekonomii i sztabu)
/proc/hexmap_war_test_pair()
	for(var/datum/star_system/A as anything in SSstar_system.systems)
		if(!A.hex || A.hidden || istype(A, /datum/star_system/random) || length(A.fleets) || A.trader)
			continue
		for(var/datum/star_system/B as anything in SSstar_system.systems)
			if(B == A || !B.hex || B.hidden || istype(B, /datum/star_system/random) || length(B.fleets) || B.trader)
				continue
			if(B.hex.sector != A.hex.sector || GLOB.hexmap.distance(A.hex, B.hex) > 6)
				continue
			if(GLOB.hexmap.route(A.hex, B.hex, "nanotrasen", 5000))
				return list(A, B)

/proc/hexmap_war_test_save(datum/star_system/S)
	return list(S.owner, S.alignment, S.war_facilities, S.war_ore, S.war_parts, S.war_raided_until)

/proc/hexmap_war_test_restore(datum/star_system/S, list/saved)
	S.owner = saved[1]
	S.alignment = saved[2]
	S.war_facilities = saved[3]
	S.war_ore = saved[4]
	S.war_parts = saved[5]
	S.war_raided_until = saved[6]

/// Obiekty z makiety leżą przy układach, a stacja handlowa wynika z handlarza
/datum/unit_test/hexmap_war_facilities

/datum/unit_test/hexmap_war_facilities/Run()
	var/placed = 0
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(length(S.war_facilities))
			placed++
			for(var/id in S.war_facilities)
				TEST_ASSERT(hex_facility_name(id), "[S] has an unknown facility [id]")
		if(S.trader)
			TEST_ASSERT(S.has_facility(HEX_FAC_TRADE), "[S] has a trader but no trade station")
	var/datum/star_system/sol = SSstar_system.system_by_id("Sol")
	if(sol) // mapa testowa może nie mieć tych układów
		TEST_ASSERT(sol.has_facility(HEX_FAC_YARD) && sol.has_facility(HEX_FAC_HQ), "Sol lost its shipyard or headquarters")
		TEST_ASSERT(placed >= 10, "Only [placed] systems have strategic facilities")

/// Kopalnia daje rudę, a nadmiar rudy wyjeżdża konwojem do fabryki tej frakcji
/datum/unit_test/hexmap_war_economy

/datum/unit_test/hexmap_war_economy/Run()
	var/list/pair = hexmap_war_test_pair()
	if(!pair)
		return // brak dwóch układów z trasą na tej mapie
	var/datum/star_system/mine = pair[1]
	var/datum/star_system/factory = pair[2]
	var/list/saved_mine = hexmap_war_test_save(mine)
	var/list/saved_factory = hexmap_war_test_save(factory)
	mine.owner = "nanotrasen"
	mine.alignment = "nanotrasen"
	mine.war_facilities = list(HEX_FAC_MINE)
	mine.war_ore = 5
	factory.owner = "nanotrasen"
	factory.alignment = "nanotrasen"
	factory.war_facilities = list(HEX_FAC_FACTORY)
	factory.war_ore = 0
	factory.war_parts = 0
	var/list/convoys_before = GLOB.hex_war.faction_fleets("nanotrasen", TRUE)
	GLOB.hex_war.economy()
	var/datum/fleet/convoy
	for(var/datum/fleet/F as anything in GLOB.hex_war.faction_fleets("nanotrasen", TRUE) - convoys_before)
		convoy = F
	var/ore_left = mine.war_ore
	var/fail
	if(!convoy)
		fail = "7 ore at a mine sent no convoy to the faction's factory"
	else if(convoy.war_destination != factory)
		fail = "The convoy went to [convoy.war_destination] instead of the factory in [factory]"
	else if(ore_left != 1)
		fail = "The mine kept [ore_left] ore after sending 6 (expected 1)"
	else
		convoy.current_system.fleets -= convoy
		convoy.current_system = factory
		factory.fleets += convoy
		convoy.hex_war_deliver()
		if(factory.war_ore != 6)
			fail = "A delivered convoy left [factory.war_ore] ore at the factory instead of 6"
	if(convoy && !QDELETED(convoy))
		convoy.hex_war_dispose()
	hexmap_war_test_restore(mine, saved_mine)
	hexmap_war_test_restore(factory, saved_factory)
	if(fail)
		return Fail(fail)

/// Sztab wysyła wolną flotę na słabo bronioną wrogą stocznię w zasięgu, a rozbitą flotę do depotu
/datum/unit_test/hexmap_war_staff

/datum/unit_test/hexmap_war_staff/Run()
	var/list/pair = hexmap_war_test_pair()
	if(!pair)
		return
	var/datum/star_system/home = pair[1]
	var/datum/star_system/enemy = pair[2]
	var/list/saved_home = hexmap_war_test_save(home)
	var/list/saved_enemy = hexmap_war_test_save(enemy)
	home.owner = "nanotrasen"
	home.alignment = "nanotrasen"
	home.war_facilities = list(HEX_FAC_DEPOT)
	enemy.owner = "syndicate"
	enemy.alignment = "syndicate"
	enemy.war_facilities = list(HEX_FAC_YARD, HEX_FAC_FACTORY)
	var/datum/fleet/F = home.spawn_fleet(/datum/fleet/nanotrasen/light, 2)
	F.hex_war_adopt()
	F.commander.traits -= list("fanatic", "coward") // fanatyk nie wraca do depotu
	var/fail
	GLOB.hex_war.offensive("nanotrasen", list(F))
	if(F.war_order != HEX_ORDER_ATTACK)
		fail = "A free fleet did not attack an undefended enemy shipyard [GLOB.hexmap.war_distance(home.hex, enemy.hex)] hexes away"
	if(!fail)
		for(var/obj/structure/overmap/OM as anything in F.all_ships)
			OM.obj_integrity = OM.max_integrity * 0.1
		F.hex_war_set_order(HEX_ORDER_IDLE)
		F.current_system.fleets -= F
		F.current_system = enemy
		enemy.fleets += F
		GLOB.hex_war.staff("nanotrasen")
		if(F.war_order != HEX_ORDER_REPAIR || F.war_target != home)
			fail = "A fleet at 10% strength got [F.war_order] ([F.war_target]) instead of going to the depot in [home]"
	if(fail)
		F.commander = null
	F.hex_war_dispose()
	hexmap_war_test_restore(home, saved_home)
	hexmap_war_test_restore(enemy, saved_enemy)
	if(fail)
		return Fail(fail)

/// Dowódca: awans po zwycięstwach, a po utracie floty ucieczka z blizną (słabość zamienia się w zaletę) i urazą
/datum/unit_test/hexmap_war_commander

/datum/unit_test/hexmap_war_commander/Run()
	var/datum/hex_commander/C = GLOB.hex_war.new_commander("syndicate")
	GLOB.hex_war.commanders -= C
	C.rank = 0
	C.traits = list("thin_hull", "aggressive")
	C.add_win()
	C.add_win()
	TEST_ASSERT_EQUAL(C.rank, 1, "Two wins did not promote a captain")
	var/escaped = FALSE
	for(var/i in 1 to 100)
		C.status = HEX_CMD_ACTIVE
		C.traits = list("thin_hull", "aggressive")
		C.scars = list()
		C.grudge = 0
		C.fleet_lost(TRUE)
		if(C.status == HEX_CMD_WOUNDED)
			escaped = TRUE
			break
		TEST_ASSERT_EQUAL(C.status, HEX_CMD_DEAD, "A commander who lost his fleet is neither wounded nor dead")
	TEST_ASSERT(escaped, "A commander never escaped in 100 lost fleets")
	TEST_ASSERT(!C.has_trait("thin_hull") && C.has_trait("armored"), "The weakness did not turn into a scar: [english_list(C.traits)]")
	TEST_ASSERT_EQUAL(length(C.scars), 1, "The scar was not recorded")
	TEST_ASSERT_EQUAL(C.grudge, 1, "Losing to the player's ship gave no grudge")
	TEST_ASSERT(C.return_at > world.time, "A wounded commander has no return time")
	TEST_ASSERT(hex_commander_defence(null, null) == 1, "A fleet without a commander got a defence modifier")

/// Flota sztabu przechodzi przez zapis kampanii z tą samą liczbą okrętów, rozkazem i dowódcą
/datum/unit_test/hexmap_war_save_fleet

/datum/unit_test/hexmap_war_save_fleet/Run()
	var/list/pair = hexmap_war_test_pair()
	if(!pair)
		return
	var/datum/star_system/home = pair[1]
	var/datum/star_system/target = pair[2]
	var/datum/fleet/F = home.spawn_fleet(/datum/fleet/nanotrasen/light, 2)
	F.hex_war_adopt()
	F.hex_war_set_order(HEX_ORDER_DEFEND, target)
	var/ships = F.hex_war_ship_count()
	var/datum/hex_commander/C = F.commander
	var/list/entry
	for(var/list/candidate in GLOB.hex_war.serialize()["fleets"])
		if(candidate["commander"] == C.id)
			entry = candidate
	F.commander = null
	F.hex_war_dispose()
	TEST_ASSERT(entry, "The war save has no entry for an adopted fleet")
	var/list/by_id = list("[C.id]" = C)
	var/list/before = home.fleets.Copy()
	GLOB.hex_war.restore_fleet(entry, by_id)
	var/datum/fleet/restored
	for(var/datum/fleet/R as anything in home.fleets - before)
		restored = R
	TEST_ASSERT(restored, "The saved fleet did not come back")
	var/restored_ships = restored.hex_war_ship_count()
	var/restored_order = restored.war_order
	var/restored_target = restored.war_target
	var/restored_commander = restored.commander
	restored.commander = null
	restored.hex_war_dispose()
	GLOB.hex_war.commanders -= C
	TEST_ASSERT_EQUAL(restored_ships, ships, "The restored fleet has another ship count")
	TEST_ASSERT_EQUAL(restored_order, HEX_ORDER_DEFEND, "The restored fleet lost its order")
	TEST_ASSERT_EQUAL(restored_target, target, "The restored fleet lost its target")
	TEST_ASSERT_EQUAL(restored_commander, C, "The restored fleet lost its commander")

/// Regresja: konwój bez wyznaczonego kursu (plotted_course = FALSE) dochodzi do celu i rozładowuje się bez runtime'u
/datum/unit_test/hexmap_war_convoy_arrival

/datum/unit_test/hexmap_war_convoy_arrival/Run()
	var/list/pair = hexmap_war_test_pair()
	if(!pair)
		return
	var/datum/star_system/from = pair[1]
	var/datum/star_system/dest = pair[2]
	var/datum/hex/goal = dest.hex
	var/datum/hex/next
	for(var/datum/hex/N as anything in GLOB.hexmap.neighbours(goal))
		if(!N.system && N.terrain == HEX_TERRAIN_EMPTY)
			next = N
			break
	if(!next)
		return
	var/list/saved_from = hexmap_war_test_save(from)
	var/list/saved_dest = hexmap_war_test_save(dest)
	from.owner = "nanotrasen"
	from.alignment = "nanotrasen"
	dest.owner = "nanotrasen"
	dest.alignment = "nanotrasen"
	dest.war_ore = 0
	var/datum/star_system/start = GLOB.hexmap.system_for(next)
	var/sent = GLOB.hex_war.send_convoy(start, "nanotrasen", "ore", 6, null, dest)
	var/datum/fleet/convoy
	for(var/datum/fleet/F as anything in start.fleets)
		if(F.war_cargo)
			convoy = F
	var/fail
	if(!sent || !convoy)
		fail = "No convoy was sent next to [dest]"
	else
		convoy.plotted_course = FALSE
		convoy.last_encounter_time = 0
		convoy.move(null, TRUE)
		if(!QDELETED(convoy))
			fail = "A convoy one hex from its destination did not arrive and unload (now in [convoy.current_system])"
			convoy.hex_war_dispose()
		else if(dest.war_ore != 6)
			fail = "The convoy unloaded [dest.war_ore] ore instead of 6"
	hexmap_war_test_restore(from, saved_from)
	hexmap_war_test_restore(dest, saved_dest)
	if(fail)
		return Fail(fail)

/// Mgła wojny: kafel okrętu i jego otoczenie są widoczne, sojusznicza flota nigdy nie jest „ostatnio widziana”
/datum/unit_test/hexmap_war_fog

/datum/unit_test/hexmap_war_fog/Run()
	var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
	var/datum/hex/here = ship?.current_hex()
	if(!here)
		return // okręt w locie albo poza mapą
	var/list/visible = hex_fog_visible(ship)
	TEST_ASSERT(visible[here], "The ship does not see its own hex")
	for(var/datum/hex/H as anything in GLOB.hexmap.hexes_in_range(here, HEX_FOG_SHIP))
		TEST_ASSERT(visible[H], "The ship does not see [H.id], [GLOB.hexmap.distance(here, H)] hexes away")
	for(var/list/entry in hex_fog_fleet_data(ship))
		if(hex_factions_allied(ship.faction, entry["alignment"]))
			TEST_ASSERT(!entry["ghost"], "An allied fleet is shown at its last known position")

/// DEFCON z napięcia wojny, a każda detonacja to DEFCON 1
/datum/unit_test/hexmap_war_defcon

/datum/unit_test/hexmap_war_defcon/Run()
	var/datum/hex_war/W = GLOB.hex_war
	var/saved_tension = W.tension
	var/saved_lock = W.defcon_lock_until
	var/list/results = list()
	W.defcon_lock_until = 0
	for(var/value in list(0, 7, 15, 25))
		W.tension = value
		W.update_defcon()
		results += W.defcon
	W.nuclear_detonation(null)
	var/after_blast = W.defcon
	W.tension = saved_tension
	W.defcon_lock_until = saved_lock
	W.update_defcon()
	TEST_ASSERT_EQUAL(jointext(results, ","), "5,4,3,2", "DEFCON from tension 0/7/15/25")
	TEST_ASSERT_EQUAL(after_blast, 1, "A nuclear detonation did not set DEFCON 1")

/// Wybuch pocisku strategicznego: flota w kaflu traci 3 okręty, flota obok 1, pusty kafel zostaje skażony
/datum/unit_test/hexmap_war_strategic_nuke

/datum/unit_test/hexmap_war_strategic_nuke/Run()
	var/datum/hex/blast
	var/datum/hex/beside
	for(var/id in GLOB.hexmap.hexes)
		var/datum/hex/H = GLOB.hexmap.hexes[id]
		if(H.system || H.terrain != HEX_TERRAIN_EMPTY || length(GLOB.hexmap.neighbours(H)) != 6)
			continue
		for(var/datum/hex/N as anything in GLOB.hexmap.neighbours(H))
			if(!N.system && N.terrain == HEX_TERRAIN_EMPTY)
				beside = N
				break
		if(beside)
			blast = H
			break
	TEST_ASSERT(blast, "No two empty neighbouring hexes")
	var/datum/star_system/blast_system = GLOB.hexmap.system_for(blast)
	var/datum/star_system/beside_system = GLOB.hexmap.system_for(beside)
	var/datum/fleet/A = blast_system.spawn_fleet(/datum/fleet/nanotrasen, 8)
	var/datum/fleet/B = beside_system.spawn_fleet(/datum/fleet/nanotrasen, 8)
	var/ships_a = A.hex_war_ship_count()
	var/ships_b = B.hex_war_ship_count()
	var/saved_tension = GLOB.hex_war.tension
	var/saved_lock = GLOB.hex_war.defcon_lock_until
	var/datum/hex_nuke/N = new
	N.faction = "syndicate"
	N.hex = blast
	N.target_hex = blast
	N.trail = list(blast.id)
	N.impact(null, null)
	var/left_a = QDELETED(A) ? 0 : A.hex_war_ship_count()
	var/left_b = QDELETED(B) ? 0 : B.hex_war_ship_count()
	var/terrain = blast.terrain
	blast.set_terrain(HEX_TERRAIN_EMPTY)
	if(!QDELETED(A))
		A.hex_war_dispose()
	if(!QDELETED(B))
		B.hex_war_dispose()
	GLOB.hex_war.tension = saved_tension
	GLOB.hex_war.defcon_lock_until = saved_lock
	GLOB.hex_war.update_defcon()
	TEST_ASSERT_EQUAL(left_a, max(0, ships_a - 3), "The fleet in the blast hex lost [ships_a - left_a] ships instead of 3")
	TEST_ASSERT_EQUAL(left_b, max(0, ships_b - 1), "The fleet next to the blast lost [ships_b - left_b] ships instead of 1")
	TEST_ASSERT_EQUAL(terrain, HEX_TERRAIN_RADIATION, "An empty hex was not irradiated by the blast")

/// Strzał strategiczny gracza wymaga DEFCON 2 i atomówki w wyrzutni; skrzynia startowa ma atomówkę
/datum/unit_test/hexmap_war_player_nuke

/datum/unit_test/hexmap_war_player_nuke/Run()
	var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
	var/datum/hex/here = ship?.current_hex()
	var/obj/structure/closet/crate/secure/weapon/aquila_nuke/crate = allocate(/obj/structure/closet/crate/secure/weapon/aquila_nuke)
	TEST_ASSERT(locate(/obj/item/ship_weapon/ammunition/torpedo/nuke) in crate.contents, "The starting crate has no nuclear torpedo")
	if(!here)
		return
	var/datum/hex/target
	for(var/datum/hex/H as anything in GLOB.hexmap.hexes_in_range(here, 3))
		target = H
		break
	var/saved_tension = GLOB.hex_war.tension
	var/saved_lock = GLOB.hex_war.defcon_lock_until
	GLOB.hex_war.defcon_lock_until = 0
	GLOB.hex_war.tension = 0
	GLOB.hex_war.update_defcon()
	var/peace = ship.hex_nuke_blocker(target)
	GLOB.hex_war.defcon_lock_until = world.time + 1 MINUTES
	GLOB.hex_war.update_defcon()
	var/war = ship.hex_nuke_blocker(target)
	var/loaded = length(ship.hex_loaded_nukes())
	GLOB.hex_war.tension = saved_tension
	GLOB.hex_war.defcon_lock_until = saved_lock
	GLOB.hex_war.update_defcon()
	TEST_ASSERT(findtext(peace, "DEFCON"), "Firing at DEFCON 5 was not blocked by DEFCON: [peace]")
	if(!loaded)
		TEST_ASSERT(findtext(war, "wyrzutnia"), "Firing without a loaded nuke at DEFCON 1 gave: [war]")

/// Frakcja bez atomówki, z kwaterą główną i fabryką, składa nową z 8 części zamiast wysyłać części do stoczni
/datum/unit_test/hexmap_war_ai_builds_nuke

/datum/unit_test/hexmap_war_ai_builds_nuke/Run()
	var/list/pair = hexmap_war_test_pair()
	if(!pair)
		return
	var/datum/star_system/hq = pair[1]
	var/datum/star_system/factory = pair[2]
	var/list/saved_hq = hexmap_war_test_save(hq)
	var/list/saved_factory = hexmap_war_test_save(factory)
	var/saved_stock = GLOB.hex_war.nuke_stocks["syndicate"]
	var/saved_built = GLOB.hex_war.nuke_built_at["syndicate"]
	hq.owner = "syndicate"
	hq.alignment = "syndicate"
	hq.war_facilities = list(HEX_FAC_HQ)
	// Atomówka powstaje tylko w fabryce przy kwaterze i tylko z części, których nie wysłano do stoczni
	factory.owner = "syndicate"
	factory.alignment = "syndicate"
	factory.war_facilities = list(HEX_FAC_FACTORY, HEX_FAC_HQ)
	factory.war_ore = 6
	factory.war_parts = HEX_WAR_NUKE_PARTS + 2 // +2 z rudy, ewentualny konwój zabiera 4
	GLOB.hex_war.nuke_stocks["syndicate"] = 0
	GLOB.hex_war.nuke_built_at -= "syndicate"
	GLOB.hex_war.economy()
	var/stock = GLOB.hex_war.nuke_stocks["syndicate"]
	var/parts = factory.war_parts
	// Druga atomówka nie wcześniej niż po HEX_WAR_NUKE_COOLDOWN
	GLOB.hex_war.nuke_stocks["syndicate"] = 0
	factory.war_parts = HEX_WAR_NUKE_PARTS * 2
	GLOB.hex_war.economy()
	var/stock_cooldown = GLOB.hex_war.nuke_stocks["syndicate"]
	// Fabryka bez kwatery nie składa atomówek
	GLOB.hex_war.nuke_built_at -= "syndicate"
	factory.war_facilities = list(HEX_FAC_FACTORY)
	factory.war_parts = HEX_WAR_NUKE_PARTS * 2
	GLOB.hex_war.economy()
	var/stock_no_hq = GLOB.hex_war.nuke_stocks["syndicate"]
	GLOB.hex_war.nuke_stocks["syndicate"] = saved_stock
	if(saved_built)
		GLOB.hex_war.nuke_built_at["syndicate"] = saved_built
	else
		GLOB.hex_war.nuke_built_at -= "syndicate"
	hexmap_war_test_restore(hq, saved_hq)
	hexmap_war_test_restore(factory, saved_factory)
	TEST_ASSERT_EQUAL(stock, 1, "A headquarters factory with [HEX_WAR_NUKE_PARTS] spare parts did not build a nuke")
	TEST_ASSERT(parts <= 4, "Building the nuke did not use up [HEX_WAR_NUKE_PARTS] parts ([parts] left)")
	TEST_ASSERT_EQUAL(stock_cooldown, 0, "A faction built a second nuke right after the first one")
	TEST_ASSERT_EQUAL(stock_no_hq, 0, "A factory away from the headquarters built a nuke")

/// Misje trafiają na losowy pusty kafel sektora neutralnego, z dala od okrętu gracza
/datum/unit_test/hexmap_war_missions

/datum/unit_test/hexmap_war_missions/Run()
	var/datum/star_system/S = hex_mission_system(null)
	TEST_ASSERT(istype(S, /datum/star_system/random/hex_empty), "A mission got [S] instead of an empty hex system")
	TEST_ASSERT_EQUAL(S.hex.sector, SECTOR_NEUTRAL, "A mission hex is outside the neutral sector")
	TEST_ASSERT_EQUAL(S.hex.terrain, HEX_TERRAIN_EMPTY, "A mission hex has a hazard on it")
	var/datum/hex/player_hex = SSstar_system.find_main_overmap()?.current_hex()
	if(player_hex?.sector == SECTOR_NEUTRAL)
		TEST_ASSERT(GLOB.hexmap.distance(player_hex, S.hex) >= 3, "A mission hex is right next to the player's ship")
	var/datum/star_system/random/hex_empty/E = S
	E.try_release()
	var/clusters = 0
	for(var/id in GLOB.hexmap.hexes)
		var/datum/hex/H = GLOB.hexmap.hexes[id]
		if(H.terrain != HEX_TERRAIN_ANOMALIES)
			continue
		TEST_ASSERT(H.system, "Anomaly field [id] has no system with a scannable anomaly cluster")
		for(var/obj/effect/overmap_anomaly/aquila_anomaly_cluster/A in H.system.system_contents)
			clusters++
	TEST_ASSERT(clusters, "No anomaly cluster to scan in any anomaly field")

/// Eskorta ze stacji: okręt dołącza do eskorty, skacze za okrętem gracza, a stacja nie sprzedaje ponad limit
/datum/unit_test/hexmap_war_escort

/datum/unit_test/hexmap_war_escort/Run()
	var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
	if(!ship?.current_system)
		return
	var/datum/star_system/home = ship.current_system
	var/obj/structure/overmap/member = ship.hex_add_escort(/obj/structure/overmap/nanotrasen/frigate/ai)
	TEST_ASSERT(member, "Buying an escort gave no ship")
	TEST_ASSERT_EQUAL(ship.hex_escort_count(), 1, "The escort count is off after one purchase")
	var/datum/fleet/aquila_escort/F = member.fleet
	TEST_ASSERT(istype(F) && F.escorting == ship, "The escort ship is not in an escort fleet of the player's ship")
	TEST_ASSERT(!F.move(null, TRUE), "The escort fleet moved on its own")
	var/datum/hex/elsewhere
	for(var/datum/hex/N as anything in GLOB.hexmap.neighbours(home.hex))
		if(!N.system && N.terrain == HEX_TERRAIN_EMPTY)
			elsewhere = N
			break
	var/fail
	if(elsewhere)
		var/datum/star_system/target = GLOB.hexmap.system_for(elsewhere)
		ship.hex_move_escorts(target)
		if(F.current_system != target || !(F in target.fleets) || (F in home.fleets))
			fail = "The escort did not follow the player's ship to [target]"
		ship.hex_move_escorts(home)
	var/datum/trader_item/aquila_escort/item = new
	var/saved_count_ok = ship.hex_escort_count() < HEX_ESCORT_MAX
	for(var/i in 1 to HEX_ESCORT_MAX)
		ship.hex_add_escort(/obj/structure/overmap/nanotrasen/frigate/ai)
	var/full = ship.hex_escort_count() >= HEX_ESCORT_MAX
	qdel(item)
	F.hex_war_dispose()
	if(fail)
		return Fail(fail)
	TEST_ASSERT(saved_count_ok && full, "The escort limit check is off")

/// Strona, która HEX_WAR_END_ROUNDS rund z rzędu kończy bez kwatery głównej, przegrywa wojnę; odbita kwatera zeruje licznik
/datum/unit_test/hexmap_war_campaign_end

/datum/unit_test/hexmap_war_campaign_end/Run()
	var/datum/hex_war/W = GLOB.hex_war
	var/datum/star_system/hq
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(S.owner == "syndicate" && S.has_facility(HEX_FAC_HQ))
			hq = S
			break
	if(!hq)
		return // No Syndicate headquarters on this map
	var/list/saved_lost = W.hq_lost_rounds.Copy()
	var/saved_alignment = hq.alignment
	W.hq_lost_rounds = list("syndicate" = HEX_WAR_END_ROUNDS - 2)
	hq.alignment = "nanotrasen"
	var/first = W.round_end_tally()
	var/second = W.round_end_tally()
	hq.alignment = "syndicate"
	W.round_end_tally()
	var/after_retake = W.hq_lost_rounds["syndicate"]
	W.hq_lost_rounds = saved_lost
	hq.alignment = saved_alignment
	TEST_ASSERT(first != "syndicate", "The war ended one round too early")
	TEST_ASSERT_EQUAL(second, "syndicate", "Losing the headquarters for [HEX_WAR_END_ROUNDS] rounds did not end the war")
	TEST_ASSERT_EQUAL(after_retake, 0, "Retaking the headquarters did not reset the count")
	TEST_ASSERT(findtext(hex_war_end_text("syndicate"), "Nanotrasen wygrywa"), "The end of the war names the wrong winner")


#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
