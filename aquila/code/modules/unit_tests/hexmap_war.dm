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
	// Atut kampanii zmienia wydobycie (war_fortune.dm): test liczy na równe 2 rudy na turę
	var/list/saved_fortunes = GLOB.hex_war.fortunes.Copy()
	GLOB.hex_war.fortunes = list()
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
		if(F.war_cargo == "ore" && F.current_system == mine) // economy() może w tym samym wywołaniu wysłać konwoje z innych kopalni
			convoy = F
	// Najbliższa fabryka NT od kopalni (na mapie mogą być inne, bliższe niż testowa)
	var/list/factories = GLOB.hex_war.faction_sites("nanotrasen", HEX_FAC_FACTORY, mine) - mine
	var/datum/star_system/expected = length(factories) ? factories[1] : factory
	var/ore_left = mine.war_ore
	var/fail
	if(!convoy)
		fail = "7 ore at a mine sent no convoy to the faction's factory"
	else if(convoy.war_destination != expected)
		fail = "The convoy went to [convoy.war_destination] instead of the nearest factory in [expected]"
	else if(ore_left != 1)
		fail = "The mine kept [ore_left] ore after sending 6 (expected 1)"
	else
		// Rozładunek w faktycznym celu konwoju (na mapie może to być inna, bliższa fabryka niż testowa)
		var/list/saved_expected = expected == factory ? null : hexmap_war_test_save(expected)
		var/ore_before = expected.war_ore
		convoy.current_system.fleets -= convoy
		convoy.current_system = expected
		expected.fleets += convoy
		convoy.hex_war_deliver()
		var/delivered = expected.war_ore - ore_before
		if(saved_expected)
			hexmap_war_test_restore(expected, saved_expected)
		if(delivered != 6)
			fail = "A delivered convoy left [delivered] ore at the factory instead of 6"
	if(convoy && !QDELETED(convoy))
		convoy.hex_war_dispose()
	GLOB.hex_war.fortunes = saved_fortunes
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

/// Stary zapis bez "hull": strength liczone na flotę przy wodowaniu przelicza się na ocalałe okręty
/datum/unit_test/hexmap_war_save_old_strength

/datum/unit_test/hexmap_war_save_old_strength/Run()
	var/list/pair = hexmap_war_test_pair()
	if(!pair)
		return
	var/datum/star_system/home = pair[1]
	var/datum/fleet/F = home.spawn_fleet(/datum/fleet/nanotrasen/light, 2)
	F.hex_war_adopt()
	var/datum/hex_commander/C = F.commander
	var/list/entry
	for(var/list/candidate in GLOB.hex_war.serialize()["fleets"])
		if(candidate["commander"] == C.id)
			entry = candidate.Copy()
	F.commander = null
	F.hex_war_dispose()
	TEST_ASSERT(entry, "The war save has no entry for an adopted fleet")
	entry -= "hull"
	entry["ships"] = 2
	entry["max_ships"] = 4
	entry["strength"] = 0.5 // dwa z czterech okrętów, oba całe
	var/list/before = home.fleets.Copy()
	GLOB.hex_war.restore_fleet(entry, list("[C.id]" = C))
	var/datum/fleet/restored
	for(var/datum/fleet/R as anything in home.fleets - before)
		restored = R
	TEST_ASSERT(restored, "The old saved fleet did not come back")
	var/hull = restored.hex_war_hull()
	restored.commander = null
	restored.hex_war_dispose()
	GLOB.hex_war.commanders -= C
	TEST_ASSERT(hull > 0.95, "Two intact ships from an old save came back with [round(hull * 100)]% hull")

/// Zapis z pustą listą flot (wszystkie zginęły) odtwarza dowódców i magazyny; zapis bez listy jest odrzucany
/datum/unit_test/hexmap_war_restore_empty

/datum/unit_test/hexmap_war_restore_empty/Run()
	var/datum/star_system/store
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(S.hex && !S.hidden && !istype(S, /datum/star_system/random))
			store = S
			break
	if(!store)
		return
	var/datum/hex_war/war = new // osobna wojna: dowódcy z zapisu nie trafiają do kampanii
	var/missing = war.restore(list("commanders" = list()))
	// restore() zastępuje floty ze startu rundy; te, które jeszcze nie są pod sztabem, chronimy na czas testu
	var/list/protected = list()
	for(var/datum/fleet/F as anything in hex_all_fleets())
		if(F.hex_war_adoptable())
			F.war_controlled = TRUE
			protected += F
	var/old_ore = store.war_ore
	var/old_parts = store.war_parts
	var/list/commander_entry = list("id" = 3, "faction" = "nanotrasen", "first" = "Jan", "last" = "Próbny", "rank" = 1, "status" = HEX_CMD_ACTIVE, "return_in" = 0)
	var/list/stores = list()
	stores[store.name] = list(7, 8)
	var/ok = war.restore(list("fleets" = list(), "next_id" = 4, "commanders" = list(commander_entry), "stores" = stores))
	var/ore = store.war_ore
	var/parts = store.war_parts
	store.war_ore = old_ore
	store.war_parts = old_parts
	for(var/datum/fleet/F as anything in protected)
		F.war_controlled = FALSE
	var/datum/hex_commander/C = length(war.commanders) ? war.commanders[1] : null
	TEST_ASSERT(!missing, "A save without a fleet list was accepted")
	TEST_ASSERT(ok, "A save with an empty fleet list was rejected")
	TEST_ASSERT_EQUAL(ore, 7, "The store ore did not come back")
	TEST_ASSERT_EQUAL(parts, 8, "The store parts did not come back")
	TEST_ASSERT(C?.id == 3, "The commander did not come back")
	TEST_ASSERT_EQUAL(C.status, HEX_CMD_WOUNDED, "A commander without a fleet did not come back wounded")

/// Ponowne trafienie skażonego kafla: po wygaśnięciu wraca pierwotny teren, także po zapisie i wczytaniu kampanii
/datum/unit_test/hexmap_contamination_rehit

/datum/unit_test/hexmap_contamination_rehit/Run()
	if(!GLOB.hexmap?.built)
		return
	var/datum/hex/H
	for(var/id in GLOB.hexmap.hexes)
		var/datum/hex/candidate = GLOB.hexmap.hexes[id]
		if(!candidate.system && candidate.terrain != HEX_TERRAIN_RADIATION && !GLOB.hexmap.contamination[candidate.id])
			H = candidate
			break
	if(!H)
		return
	var/previous = H.terrain
	GLOB.hexmap.contaminate(H, previous, 10 MINUTES)
	GLOB.hexmap.contaminate(H, H.terrain, 10 MINUTES) // drugie trafienie: teren to już skażenie
	var/list/saved = GLOB.hexmap.save_contamination()
	GLOB.hexmap.decontaminate(H.id)
	var/after_hits = H.terrain
	var/list/reload = list()
	reload[H.id] = saved[H.id]
	GLOB.hexmap.restore_contamination(reload)
	var/after_load = H.terrain
	GLOB.hexmap.decontaminate(H.id)
	var/after_all = H.terrain
	if(H.terrain != previous)
		H.set_terrain(previous)
	TEST_ASSERT_EQUAL(after_hits, previous, "After two hits the tile stayed [after_hits] instead of [previous]")
	TEST_ASSERT_EQUAL(after_load, HEX_TERRAIN_RADIATION, "Loaded contamination did not contaminate the tile")
	TEST_ASSERT_EQUAL(after_all, previous, "After loading the save the tile stayed [after_all] instead of [previous]")

/// Strzał strategiczny nie zabiera atomówki z wyrzutni w trakcie cyklu; bierze ją z drugiej, wolnej wyrzutni
/datum/unit_test/hexmap_nuke_launcher_cycle

/datum/unit_test/hexmap_nuke_launcher_cycle/Run()
	var/obj/machinery/ship_weapon/vls/busy = allocate(/obj/machinery/ship_weapon/vls)
	var/obj/machinery/ship_weapon/vls/free = allocate(/obj/machinery/ship_weapon/vls)
	var/obj/item/ship_weapon/ammunition/torpedo/nuke/busy_nuke = allocate(/obj/item/ship_weapon/ammunition/torpedo/nuke)
	var/obj/item/ship_weapon/ammunition/torpedo/nuke/free_nuke = allocate(/obj/item/ship_weapon/ammunition/torpedo/nuke)
	busy.ammo += busy_nuke
	free.ammo += free_nuke
	busy.state = STATE_CHAMBERING // chamber() śpi z torpedą w ammo
	free.state = STATE_LOADED
	var/list/ready = busy.hex_ready_nukes() + free.hex_ready_nukes()
	busy.state = STATE_LOADED
	var/list/after_cycle = busy.hex_ready_nukes()
	busy.ammo -= busy_nuke
	free.ammo -= free_nuke
	// Zwykłe usunięcie wyrzutni zostawia płytkę i części na podłodze strefy testów, a kolejne testy szukają tam przedmiotów
	qdel(busy, TRUE)
	qdel(free, TRUE)
	TEST_ASSERT(!(busy_nuke in ready), "A nuke was taken from a launcher in the middle of chambering")
	TEST_ASSERT(free_nuke in ready, "The nuke in the second, idle launcher was not offered")
	TEST_ASSERT(busy_nuke in after_cycle, "A loaded launcher after its cycle did not offer its nuke")

/// Pocisk strategiczny zestrzelony w walce taktycznej nie robi nic; trafienie daje skutki strategiczne (skażenie pustego kafla)
/datum/unit_test/hexmap_nuke_tactical_hit

/datum/unit_test/hexmap_nuke_tactical_hit/Run()
	if(!GLOB.hexmap?.built || !GLOB.hex_war)
		return
	var/datum/hex/H
	for(var/id in GLOB.hexmap.hexes)
		var/datum/hex/candidate = GLOB.hexmap.hexes[id]
		if(!candidate.system && candidate.terrain != HEX_TERRAIN_RADIATION && !GLOB.hexmap.contamination[candidate.id])
			H = candidate
			break
	if(!H)
		return
	var/previous = H.terrain
	var/saved_tension = GLOB.hex_war.tension
	var/saved_lock = GLOB.hex_war.defcon_lock_until
	var/obj/item/projectile/guided_munition/torpedo/nuclear/plain = allocate(/obj/item/projectile/guided_munition/torpedo/nuclear)
	plain.hex_detonate(H)
	var/after_plain = H.terrain
	var/obj/item/projectile/guided_munition/torpedo/nuclear/strategic = allocate(/obj/item/projectile/guided_munition/torpedo/nuclear)
	strategic.hex_strategic_faction = "syndicate"
	qdel(strategic) // zestrzelenie: pocisk znika bez trafienia
	var/after_shotdown = H.terrain
	var/obj/item/projectile/guided_munition/torpedo/nuclear/hit = allocate(/obj/item/projectile/guided_munition/torpedo/nuclear)
	hit.hex_strategic_faction = "syndicate"
	hit.hex_detonate(H)
	var/after_hit = H.terrain
	GLOB.hexmap.decontaminate(H.id)
	if(H.terrain != previous)
		H.set_terrain(previous)
	GLOB.hex_war.tension = saved_tension
	GLOB.hex_war.defcon_lock_until = saved_lock
	GLOB.hex_war.update_defcon()
	TEST_ASSERT_EQUAL(after_plain, previous, "A plain nuclear torpedo contaminated the tile")
	TEST_ASSERT_EQUAL(after_shotdown, previous, "A strategic missile shot down in tactical combat contaminated the tile")
	TEST_ASSERT_EQUAL(after_hit, HEX_TERRAIN_RADIATION, "A strategic missile that hit had no strategic effect")

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

/// Nanotrasen po HEX_WAR_END_ROUNDS rundach bez kwatery ewakuuje sztab na zaplecze, przegrywa dopiero po utracie także nowej
/// kwatery; krótkie zajęcie się nie liczy, a tura z okrętem walczącym przy kwaterze nie idzie do rund bez kwatery
/datum/unit_test/hexmap_war_campaign_end

/datum/unit_test/hexmap_war_campaign_end/Run()
	var/datum/hex_war/W = GLOB.hex_war
	var/datum/star_system/hq = W.nt_hq_system()
	var/datum/star_system/fallback = SSstar_system.system_by_id(GLOB.hex_war_nt_fallbacks[1])
	if(!hq || !fallback || fallback.owner != "nanotrasen")
		return // No Nanotrasen headquarters or fallback on this map
	var/list/saved_lost = W.hq_lost_rounds.Copy()
	var/saved_alignment = hq.alignment
	var/saved_fallback_alignment = fallback.alignment
	var/list/saved_hq_facilities = LAZYCOPY(hq.war_facilities)
	var/list/saved_fallback_facilities = LAZYCOPY(fallback.war_facilities)
	var/list/saved_relocations = W.hq_relocations.Copy()
	var/saved_turns = W.round_turns
	var/list/saved_hostile = W.hq_hostile_turns.Copy()
	var/saved_defeated = W.syndicate_defeated
	var/saved_announce = W.pending_evac_announce
	W.syndicate_defeated = FALSE
	W.hq_relocations = list()
	W.hq_lost_rounds = list("nanotrasen" = HEX_WAR_END_ROUNDS - 2)
	W.round_turns = 0
	W.hq_hostile_turns = list()
	fallback.alignment = "nanotrasen"
	hq.alignment = "syndicate"
	var/first = W.round_end_tally()
	var/evacuation = W.round_end_tally()
	var/moved = fallback.has_facility(HEX_FAC_HQ) && !hq.has_facility(HEX_FAC_HQ)
	// Nowa kwatera też w rękach wroga przez HEX_WAR_END_ROUNDS rund: teraz już przegrana
	fallback.alignment = "syndicate"
	var/loser
	for(var/i in 1 to HEX_WAR_END_ROUNDS)
		loser = W.round_end_tally()
	// Okręt walczący przy zajętej kwaterze wstrzymuje licznik
	W.round_turns = 0
	W.hq_hostile_turns = list()
	W.track_hq_control(fallback.hex)
	var/paused = !W.hq_hostile_turns["nanotrasen"]
	// Krótkie zajęcie w chwili zapisu nie liczy się, jeśli przez większość rundy kwatera była w rękach właściciela
	W.hq_lost_rounds = list()
	W.round_turns = 0
	W.hq_hostile_turns = list()
	fallback.alignment = "nanotrasen"
	for(var/i in 1 to 4)
		W.track_hq_control(null)
	fallback.alignment = "syndicate"
	W.track_hq_control(null)
	W.round_end_tally()
	var/after_blip = W.hq_lost_rounds["nanotrasen"]
	W.hq_lost_rounds = saved_lost
	W.hq_relocations = saved_relocations
	W.round_turns = saved_turns
	W.hq_hostile_turns = saved_hostile
	W.syndicate_defeated = saved_defeated
	W.pending_evac_announce = saved_announce
	hq.war_facilities = saved_hq_facilities
	fallback.war_facilities = saved_fallback_facilities
	hq.alignment = saved_alignment
	fallback.alignment = saved_fallback_alignment
	TEST_ASSERT(first != "nanotrasen", "The war ended one round too early")
	TEST_ASSERT(!evacuation, "Losing the first headquarters ended the war instead of evacuating the staff")
	TEST_ASSERT(moved, "The headquarters did not move to [fallback]")
	TEST_ASSERT_EQUAL(loser, "nanotrasen", "Losing the evacuated headquarters as well did not end the war")
	TEST_ASSERT(paused, "A turn with the ship fighting at the headquarters counted towards the defeat")
	TEST_ASSERT(!after_blip, "A headquarters held for most of the round counted as lost because of the last turn")
	TEST_ASSERT(findtext(hex_war_end_text("syndicate"), "Nanotrasen wygrywa"), "The end of the war names the wrong winner")

/// Misja „Odbij kwaterę”: kończy się sukcesem po odbiciu, a nie blokuje końca rundy, gdy reszta misji jest zamknięta
/datum/unit_test/hexmap_war_retake_mission

/datum/unit_test/hexmap_war_retake_mission/Run()
	var/datum/star_system/hq = GLOB.hex_war.nt_hq_system()
	if(!hq)
		return // No Nanotrasen headquarters on this map
	var/saved_alignment = hq.alignment
	var/datum/overmap_objective/aquila_retake_hq/mission = new
	mission.target_system = hq
	hq.alignment = "syndicate"
	mission.check_completion()
	var/open_status = mission.status
	var/list/saved_objectives = SSovermap_mode.mode?.objectives?.Copy()
	if(SSovermap_mode.mode)
		SSovermap_mode.mode.objectives = list(mission)
	mission.check_completion()
	var/alone_status = mission.status
	mission.status = 0
	hq.alignment = "nanotrasen"
	mission.check_completion()
	var/done_status = mission.status
	if(SSovermap_mode.mode)
		SSovermap_mode.mode.objectives = saved_objectives
	hq.alignment = saved_alignment
	qdel(mission)
	if(saved_objectives) // bez trybu overmapy nie ma innych misji do sprawdzenia
		TEST_ASSERT_EQUAL(alone_status, 2, "The retake mission kept the round open with every other objective closed")
	TEST_ASSERT_EQUAL(done_status, 1, "Retaking the headquarters did not complete the mission")
	TEST_ASSERT(open_status == 0 || !saved_objectives, "The retake mission closed while the headquarters was still lost")

/// Kwaterę Syndykatu zdobywa tylko okręt gracza: przy wrogiej flocie nic się nie dzieje, po HEX_WAR_PLAYER_CAPTURE_TURNS turach
/// bez obrony wojna jest wygrana; sztaby AI nie biorą jej za cel
/datum/unit_test/hexmap_war_player_capture

/datum/unit_test/hexmap_war_player_capture/Run()
	var/datum/hex_war/W = GLOB.hex_war
	var/datum/star_system/hq
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(S.owner == "syndicate" && S.has_facility(HEX_FAC_HQ))
			hq = S
			break
	if(!hq)
		return // No Syndicate headquarters on this map
	var/saved_alignment = hq.alignment
	var/saved_defeated = W.syndicate_defeated
	var/saved_turns = W.capture_turns
	var/list/saved_fleets = hq.fleets.Copy()
	W.syndicate_defeated = FALSE
	W.capture_turns = 0
	var/ai_target = W.in_goal("nanotrasen", hq)
	// Z obroną w układzie zdobywanie nie rusza
	var/datum/fleet/guard = new
	guard.alignment = "syndicate"
	guard.current_system = hq
	hq.fleets = list(guard)
	var/defended = W.player_capture_step(hq, "nanotrasen")
	var/defended_turns = W.capture_turns
	// Bez obrony: po HEX_WAR_PLAYER_CAPTURE_TURNS turach kwatera pada
	hq.fleets = list()
	var/captured = FALSE
	for(var/i in 1 to HEX_WAR_PLAYER_CAPTURE_TURNS)
		captured = W.player_capture_step(hq, "nanotrasen")
	var/loser = W.round_end_tally()
	guard.current_system = null
	qdel(guard)
	hq.fleets = saved_fleets
	hq.alignment = saved_alignment
	W.syndicate_defeated = saved_defeated
	W.capture_turns = saved_turns
	TEST_ASSERT(!ai_target, "The Nanotrasen staff took the Syndicate headquarters as a target")
	TEST_ASSERT(!defended && !defended_turns, "The headquarters started to fall with its defence still there")
	TEST_ASSERT(captured, "The headquarters did not fall after [HEX_WAR_PLAYER_CAPTURE_TURNS] turns without defence")
	TEST_ASSERT_EQUAL(loser, "syndicate", "Taking the Syndicate headquarters did not end the war")


/// Konwój wchodzi na kafel obok floty piratów: piraci skaczą za nim (przechwycenie), więc w kaflu konwoju zaczyna się walka
/datum/unit_test/hexmap_war_convoy_intercept

/datum/unit_test/hexmap_war_convoy_intercept/Run()
	var/datum/hex/convoy_hex
	var/datum/hex/hunter_hex
	for(var/id in GLOB.hexmap.hexes)
		var/datum/hex/H = GLOB.hexmap.hexes[id]
		if(H.system || H.terrain != HEX_TERRAIN_EMPTY)
			continue
		for(var/datum/hex/N as anything in GLOB.hexmap.neighbours(H))
			if(!N.system && N.terrain == HEX_TERRAIN_EMPTY)
				hunter_hex = N
				break
		if(hunter_hex)
			convoy_hex = H
			break
	TEST_ASSERT(convoy_hex, "No two empty neighbouring hexes")
	var/datum/star_system/convoy_system = GLOB.hexmap.system_for(convoy_hex)
	var/datum/star_system/hunter_system = GLOB.hexmap.system_for(hunter_hex)
	var/datum/fleet/aquila_convoy/convoy = new
	convoy.alignment = "nanotrasen"
	convoy.faction_id = FACTION_ID_NT
	convoy.war_controlled = TRUE
	convoy.war_cargo = "ore"
	convoy.war_cargo_amount = 6
	convoy.hide_movements = TRUE
	convoy.current_system = convoy_system
	convoy_system.fleets += convoy
	var/datum/fleet/hunter = hunter_system.spawn_fleet(/datum/fleet/pirate/raiding, 1)
	hunter.war_controlled = TRUE
	hunter.hide_movements = TRUE
	hunter.last_encounter_time = world.time - hunter.combat_move_delay - 1
	var/caught = FALSE
	for(var/attempt in 1 to 40) // 50% na próbę
		if(convoy.hex_war_try_intercept())
			caught = TRUE
			break
	// Przechwycony konwój mógł od razu zginąć (HEX_WAR_INTERCEPT_KILL): wtedy łowca stoi w jego dawnym kaflu
	var/same_hex = hunter.current_system == convoy_system
	for(var/datum/fleet/F as anything in list(convoy, hunter))
		if(QDELETED(F))
			continue
		for(var/obj/structure/overmap/OM as anything in F.all_ships.Copy())
			qdel(OM)
		F.current_system?.fleets -= F
		F.current_system = null
		qdel(F)
	SSstar_system.contested_systems -= convoy_system
	for(var/datum/star_system/random/hex_empty/E in list(convoy_system, hunter_system))
		E.try_release()
	TEST_ASSERT(caught, "A pirate fleet next to a convoy never intercepted it")
	TEST_ASSERT(same_hex, "The intercepting fleet did not jump into the convoy's hex")

/// Atuty kampanii: mnożnik zmienia liczbę całkowitą przez szansę na część ułamkową, brak atutu to 1
/datum/unit_test/hexmap_war_fortune

/datum/unit_test/hexmap_war_fortune/Run()
	var/datum/hex_war/W = GLOB.hex_war
	var/list/saved = W.fortunes.Copy()
	W.fortunes = list("syndicate" = 1.25)
	var/total = 0
	var/odd = 0
	for(var/i in 1 to 400)
		var/amount = W.fortune_amount("syndicate", 2)
		total += amount
		if(amount != 2 && amount != 3)
			odd++
	var/plain = W.fortune_of("pirate")
	W.fortunes = saved
	TEST_ASSERT_EQUAL(odd, 0, "Fortune 1.25 on 2 gave something other than 2 or 3")
	TEST_ASSERT(total / 400 > 2.3 && total / 400 < 2.7, "Fortune 1.25 on 2 averaged [total / 400] instead of about 2.5")
	TEST_ASSERT_EQUAL(plain, 1, "A faction without a fortune did not get 1")

/// Piraci wybierają do zajęcia słaby układ bez kwatery głównej, nie swój
/datum/unit_test/hexmap_war_pirate_conquest

/datum/unit_test/hexmap_war_pirate_conquest/Run()
	var/datum/star_system/target
	var/datum/hex/entry
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(!S.hex || S.hidden || istype(S, /datum/star_system/random) || length(S.fleets) || S.has_facility(HEX_FAC_HQ) || S.alignment == "pirate")
			continue
		for(var/datum/hex/N as anything in GLOB.hexmap.neighbours(S.hex))
			if(!N.system && N.terrain == HEX_TERRAIN_EMPTY)
				entry = N
				break
		if(entry)
			target = S
			break
	if(!target)
		return // No undefended system with a free neighbour on this map
	var/datum/star_system/start = GLOB.hexmap.system_for(entry)
	var/datum/fleet/pirates = start.spawn_fleet(/datum/fleet/pirate/raiding, 2)
	pirates.war_controlled = TRUE
	var/datum/star_system/chosen = GLOB.hex_war.pirate_conquest_target(pirates)
	for(var/obj/structure/overmap/OM as anything in pirates.all_ships.Copy())
		qdel(OM)
	start.fleets -= pirates
	pirates.current_system = null
	qdel(pirates)
	var/datum/star_system/random/hex_empty/E = start
	if(istype(E))
		E.try_release()
	TEST_ASSERT(chosen, "Pirates next to the undefended [target] found nothing to take")
	TEST_ASSERT(!chosen.has_facility(HEX_FAC_HQ), "Pirates went for a headquarters ([chosen])")
	TEST_ASSERT(chosen.alignment != "pirate", "Pirates went for their own system ([chosen])")


#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
