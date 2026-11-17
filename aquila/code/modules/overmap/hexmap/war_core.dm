// AQUILA - wojna frakcji na mapie hex (raport/ftl_mapa_06_plan_pr.md, część D). Co HEX_WAR_TICK: ekonomia
// (kopalnia -> konwój -> fabryka -> konwój -> stocznia), depoty, napady piratów, powroty dowódców i rozkazy sztabów.
// Floty to zwykłe floty NSV (prawdziwe okręty, walka kośćmi poza okiem graczy); sztab tylko wybiera im cel.

GLOBAL_DATUM(hex_war, /datum/hex_war)
/// Frakcje ze sztabem (alignment flot)
GLOBAL_LIST_INIT(hex_war_factions, list("nanotrasen", "solgov", "syndicate", "pirate"))

/datum/star_system
	/// Obiekty strategiczne (HEX_FAC_*); stacja handlowa wynika z obecności handlarza
	var/list/war_facilities
	var/war_ore = 0
	var/war_parts = 0
	/// Do kiedy stacja handlowa nie handluje po napadzie piratów
	var/war_raided_until = 0
	/// Od kiedy piraci mogą ją złupić znowu
	var/war_raid_ready_at = 0

/datum/star_system/proc/has_facility(id)
	if(id == HEX_FAC_TRADE)
		return !!trader
	return (id in war_facilities)

/// Nazwa obiektu dla graczy
/proc/hex_facility_name(id)
	switch(id)
		if(HEX_FAC_MINE)
			return "Kopalnia"
		if(HEX_FAC_FACTORY)
			return "Fabryka"
		if(HEX_FAC_YARD)
			return "Stocznia"
		if(HEX_FAC_DEPOT)
			return "Depot"
		if(HEX_FAC_POST)
			return "Placówka nasłuchowa"
		if(HEX_FAC_HQ)
			return "Kwatera główna"
		if(HEX_FAC_TRADE)
			return "Stacja handlowa"

/// Ta sama strona konfliktu (NT, SolGov i WhiteRapids to jeden blok)
/proc/hex_factions_allied(a, b)
	if(a == b)
		return TRUE
	var/static/list/nt_bloc = list("nanotrasen" = TRUE, "solgov" = TRUE, "whiterapids" = TRUE)
	return nt_bloc[a] && nt_bloc[b]

/// Rozmieszczenie obiektów jak w makiecie v4
/datum/hexmap/proc/place_facilities()
	var/static/list/layout = list(
		"Argo" = list(HEX_FAC_YARD, HEX_FAC_FACTORY), // fabryka na zapleczu: obie fabryki NT z makiety stały na froncie, a Syndykat ma dwie w głębi sektora
		"Orion's Arm" = list(HEX_FAC_DEPOT),
		"Caph" = list(HEX_FAC_MINE),
		"Keid" = list(HEX_FAC_MINE),
		"Alpha Carinae" = list(HEX_FAC_FACTORY),
		"Helios Sigma" = list(HEX_FAC_MINE),
		"Medea" = list(HEX_FAC_FACTORY, HEX_FAC_YARD, HEX_FAC_DEPOT, HEX_FAC_HQ), // makieta nie dawała NT kwatery ani drugiej stoczni; bez stoczni NT nie odbudowywało flot (raport/ftl_mapa_07)
		"Gliese 581-G" = list(HEX_FAC_MINE),
		"Karip" = list(HEX_FAC_MINE),
		"Feliciana" = list(HEX_FAC_POST),
		"Sol" = list(HEX_FAC_FACTORY, HEX_FAC_YARD, HEX_FAC_HQ),
		"Alpha Centauri" = list(HEX_FAC_MINE),
		"Ross 154" = list(HEX_FAC_DEPOT),
		"Sirius" = list(HEX_FAC_YARD),
		"Wolf 359" = list(HEX_FAC_MINE),
		"Barnard's Star" = list(HEX_FAC_MINE),
		"Lalande 21185" = list(HEX_FAC_POST),
		"Rubicon" = list(HEX_FAC_FACTORY, HEX_FAC_DEPOT),
		"Remus" = list(HEX_FAC_MINE),
		"Lombard" = list(HEX_FAC_MINE),
		"Economus" = list(HEX_FAC_YARD),
		"Volsci" = list(HEX_FAC_DEPOT),
		"Lesziru" = list(HEX_FAC_POST),
		"Zalosi" = list(HEX_FAC_MINE),
		"Phobos" = list(HEX_FAC_DEPOT),
		"Deimos" = list(HEX_FAC_FACTORY),
		"Romulus" = list(HEX_FAC_YARD, HEX_FAC_POST),
		"Abassi" = list(HEX_FAC_FACTORY, HEX_FAC_HQ), // w głębi sektora Syndykatu: sztaby AI tu nie sięgają, kwaterę zdobywa okręt gracza (war_end.dm)
		"Dolos Remnants" = list(HEX_FAC_MINE),
		"Oasis Fidei" = list(HEX_FAC_MINE),
		"Tortuga" = list(HEX_FAC_YARD, HEX_FAC_DEPOT, HEX_FAC_HQ),
		"Feaf" = list(HEX_FAC_DEPOT),
		"Zharkov" = list(HEX_FAC_MINE),
		"Arbeia" = list(HEX_FAC_MINE),
	)
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		var/list/facilities = layout[S.name]
		if(facilities)
			S.war_facilities = facilities.Copy()

/datum/hex_war
	/// Wszyscy dowódcy kampanii (także ranni i polegli, do zakładki w konsoli)
	var/list/commanders = list()
	var/next_commander_id = 1
	var/ready = FALSE

/// Start wojny: po spawnie flot układów przejmuje floty (pierwsza runda) albo odtwarza zapis kampanii
/datum/hex_war/proc/setup(list/saved)
	addtimer(CALLBACK(src, PROC_REF(late_setup), saved), HEX_WAR_SETUP_DELAY)

/datum/hex_war/proc/late_setup(list/saved)
	if(!GLOB.hexmap?.built)
		return
	if(!(islist(saved) && restore(saved)))
		for(var/datum/fleet/F as anything in hex_all_fleets())
			if(F.hex_war_adoptable())
				F.hex_war_adopt()
		roll_fortunes()
		// Nowa kampania: frakcja bez floty do przejęcia (SolGov ma na starcie tylko garnizon Sol) dostaje jedną w stoczni albo kwaterze
		for(var/faction in list("nanotrasen", "solgov", "syndicate"))
			if(length(faction_fleets(faction)))
				continue
			var/list/sites = faction_sites(faction, HEX_FAC_YARD) + faction_sites(faction, HEX_FAC_HQ)
			if(length(sites))
				launch_fleet(faction, sites[1])
	restore_nuclear(saved)
	ready = TRUE
	apply_hq_relocations()
	remove_occupied_garrisons()
	setup_nemeses()
	reinforce_hq_garrisons()
	announce_war_end()
	addtimer(CALLBACK(src, PROC_REF(tick)), HEX_WAR_TICK)

/// Start rundy: garnizon nie wraca do układu, który wróg trzymał na koniec poprzedniej rundy (inaczej każde zajęcie
/// cofało się z restartem świata i żadna strona nie utrzymała cudzej kwatery przez HEX_WAR_END_ROUNDS rund)
/datum/hex_war/proc/remove_occupied_garrisons()
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(!S.hex || !(S.owner in GLOB.hex_war_factions) || !hex_factions_hostile(S.owner, S.alignment))
			continue
		for(var/datum/fleet/F as anything in S.fleets.Copy())
			if(QDELETED(F) || F.war_controlled || F.fleet_trait != FLEET_TRAIT_DEFENSE || !hex_factions_allied(F.alignment, S.owner))
				continue
			log_game("HEXWAR: no garrison returns to occupied [S] ([F.name] removed)")
			F.hex_war_dispose()

/// Start rundy: garnizony kwater głównych (floty obronne układu, poza sztabem) są równe najsilniejszemu z nich, najmniej
/// HEX_WAR_HQ_GARRISON okrętów. Inaczej o wyniku wojny decydował układ mapy: Medea miała 2–3 okręty, Rubicon 12.
/datum/hex_war/proc/reinforce_hq_garrisons()
	var/list/garrisons = list() // układ -> okręty garnizonu
	var/target = HEX_WAR_HQ_GARRISON
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(!S.has_facility(HEX_FAC_HQ) || S.owner == "pirate" || hex_factions_hostile(S.owner, S.alignment))
			continue
		var/ships = 0
		for(var/datum/fleet/F as anything in S.fleets)
			if(!QDELETED(F) && F.fleet_trait == FLEET_TRAIT_DEFENSE && hex_factions_allied(F.alignment, S.owner))
				ships += F.hex_war_ship_count()
		garrisons[S] = ships
		target = max(target, ships)
	for(var/datum/star_system/S as anything in garrisons)
		var/missing = target - garrisons[S]
		if(missing <= 0)
			continue
		var/datum/fleet/garrison
		for(var/datum/fleet/F as anything in S.fleets)
			if(!QDELETED(F) && F.fleet_trait == FLEET_TRAIT_DEFENSE && hex_factions_allied(F.alignment, S.owner))
				garrison = F
				break
		if(!garrison) // Abassi nie ma floty w starmap.json, a nowa kwatera po ewakuacji NT też jej nie ma
			garrison = S.spawn_fleet(S.owner == "nanotrasen" ? /datum/fleet/nanotrasen/border/defense : /datum/fleet/light_defense)
			if(!garrison)
				continue
			garrison.alignment = S.owner
			missing = max(0, target - garrison.hex_war_ship_count())
		if(missing)
			garrison.hex_war_add_ships(missing)
		log_game("HEXWAR: [S] headquarters garrison reinforced with [missing] ship(s) to [target]")

/// Wszystkie floty na mapie
/proc/hex_all_fleets()
	. = list()
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		for(var/datum/fleet/F as anything in S.fleets)
			if(!QDELETED(F))
				. += F

/datum/hex_war/proc/tick()
	addtimer(CALLBACK(src, PROC_REF(tick)), HEX_WAR_TICK)
	turn_step(1, TRUE)

/// Jedna tura sztabów (zestaw komory testowej woła ją od razu, bez drugiego timera)
/datum/hex_war/proc/run_turn()
	for(var/step in 1 to turn_step_count())
		if(!turn_step(step))
			return

/datum/hex_war/proc/turn_step_count()
	return length(GLOB.hex_war_factions) + 2

/// Krok tury: 1 – ekonomia i logistyka, potem sztab każdej frakcji, na końcu atomówki i rozliczenia. Zwykła tura z tick()
/// idzie krokami po jednym na tik (chain): sztab jednej frakcji to kilka ms, cała tura w jednym tiku przycinała serwer.
/datum/hex_war/proc/turn_step(step, chain = FALSE)
	if(!GLOB.hexmap?.built || !SSstar_system.enable_npc_combat)
		return FALSE
	var/faction_count = length(GLOB.hex_war_factions)
	if(step == 1)
		economy()
		depots()
		raids()
		commander_returns()
	else if(step <= faction_count + 1)
		staff(GLOB.hex_war_factions[step - 1])
	else
		nuclear_turn()
		mission_rewards()
		var/datum/hex/ship_hex = SSstar_system.find_main_overmap()?.current_hex()
		update_retake_mission(ship_hex)
		track_hq_control(ship_hex)
		track_player_capture()
	if(chain && step < turn_step_count())
		addtimer(CALLBACK(src, PROC_REF(turn_step), step + 1, TRUE), 1)
	return TRUE

/// Floty sztabu frakcji (bez konwojów)
/datum/hex_war/proc/faction_fleets(faction, convoys = FALSE)
	. = list()
	for(var/datum/fleet/F as anything in hex_all_fleets())
		if(F.war_controlled && F.alignment == faction && (!!F.war_cargo == convoys))
			. += F

/// Wrogie floty w układzie
/proc/hex_hostile_fleets_in(datum/star_system/S, faction)
	. = list()
	for(var/datum/fleet/F as anything in S.fleets)
		if(!QDELETED(F) && hex_factions_hostile(faction, F.alignment))
			. += F

/// Układy frakcji z danym obiektem, od najbliższego
/datum/hex_war/proc/faction_sites(faction, facility, datum/star_system/from)
	. = list()
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(!S.hex || S.hidden || S.owner != faction || !S.has_facility(facility))
			continue
		if(hex_factions_hostile(faction, S.alignment))
			continue
		. += S
	if(from?.hex)
		var/list/by_distance = list()
		for(var/datum/star_system/S as anything in .)
			by_distance[S] = GLOB.hexmap.war_distance(from.hex, S.hex)
		sortTim(by_distance, GLOBAL_PROC_REF(cmp_numeric_asc), associative = TRUE)
		. = by_distance.Copy()

// ===== ekonomia =====

/datum/hex_war/proc/economy()
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(!S.hex || !length(S.war_facilities) || !(S.owner in GLOB.hex_war_factions))
			continue
		var/faction = S.owner
		// Zajęty albo atakowany układ nie produkuje
		if(S.alignment != faction || length(hex_hostile_fleets_in(S, faction)))
			continue
		if(S.has_facility(HEX_FAC_MINE))
			S.war_ore = min(S.war_ore + fortune_amount(faction, 2), 30) // magazyn kopalni, gdy konwoje są w drodze
			if(S.war_ore >= 6 && !S.has_facility(HEX_FAC_FACTORY) && send_convoy(S, faction, "ore", 6, HEX_FAC_FACTORY))
				S.war_ore -= 6
		if(S.has_facility(HEX_FAC_FACTORY))
			// 3 rudy na część, najwyżej 2 części na turę
			for(var/i in 1 to 2)
				if(S.war_ore < 3)
					break
				S.war_ore -= 3
				S.war_parts += 1
			if(S.war_parts >= 4 && !S.has_facility(HEX_FAC_YARD) && send_convoy(S, faction, "parts", 4, HEX_FAC_YARD))
				S.war_parts -= 4
		if(S.has_facility(HEX_FAC_YARD) && S.war_parts >= 4)
			if(shipyard_build(S, faction))
				S.war_parts -= 4
		// Atomówka tylko z nadwyżki: części, które zostały w fabryce przy kwaterze, bo stocznia i konwoje ich nie wzięły
		if(S.has_facility(HEX_FAC_FACTORY) && S.has_facility(HEX_FAC_HQ) && S.war_parts >= HEX_WAR_NUKE_PARTS && needs_nuke(faction))
			S.war_parts -= HEX_WAR_NUKE_PARTS
			nuke_stocks[faction] = 1
			nuke_built_at[faction] = world.time
			log_game("HEXWAR: [faction] builds a nuclear missile in [S]")
			if(!S.hidden)
				minor_announce("Wywiad: fabryka w układzie [S] ([hex_war_faction_name(faction)]) złożyła głowicę termojądrową.", "White Rapids EAS")
	// Piraci nie mają kopalń ani fabryk: ich stocznia co jakiś czas wodowuje rajdowców, a łupy dozbrajają floty
	if(length(faction_fleets("pirate")) < HEX_WAR_MAX_PIRATE_FLEETS && prob(40))
		var/list/pirate_yards = faction_sites("pirate", HEX_FAC_YARD)
		if(length(pirate_yards) && launch_fleet("pirate", pirate_yards[1]))
			log_game("HEXWAR: pirates launch raiders from [pirate_yards[1]]")
	for(var/datum/fleet/F as anything in faction_fleets("pirate"))
		// Haracz: piraci trzymający cudzy układ z obiektami albo stacją handlową co turę coś z niego biorą
		var/datum/star_system/held = F.current_system
		if(held && held.owner != "pirate" && held.alignment == "pirate" && (length(held.war_facilities) || held.trader))
			F.war_loot += 1
		if(F.war_loot >= 6 && F.current_system?.owner == "pirate" && F.current_system.has_facility(HEX_FAC_YARD))
			F.war_loot -= 6
			F.hex_war_add_ships(1)
			log_game("HEXWAR: pirates refit [F.name] with their loot")

/// Frakcja bez atomówki z działającą kwaterą główną buduje nową w fabryce przy kwaterze (najwyżej jedna w zapasie, raz na HEX_WAR_NUKE_COOLDOWN)
/datum/hex_war/proc/needs_nuke(faction)
	if(!(faction in nuke_stocks) || nuke_stocks[faction] >= 1)
		return FALSE
	if(nuke_built_at[faction] && world.time - nuke_built_at[faction] < HEX_WAR_NUKE_COOLDOWN)
		return FALSE
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(S.owner == faction && S.alignment == faction && S.has_facility(HEX_FAC_HQ) && !length(hex_hostile_fleets_in(S, faction)))
			return TRUE
	return FALSE

/// Stocznia: 2 okręty dla floty w stoczni albo nowa flota, jeśli frakcja ma ich mniej niż limit
/datum/hex_war/proc/shipyard_build(datum/star_system/yard, faction)
	for(var/datum/fleet/F as anything in yard.fleets)
		if(F.war_controlled && F.alignment == faction && !F.war_cargo && F.hex_war_ship_count() < F.war_max_ships + 2)
			F.hex_war_add_ships(2)
			log_game("HEXWAR: [yard] shipyard adds 2 ships to [F.name]")
			return TRUE
	var/limit = faction == "pirate" ? HEX_WAR_MAX_PIRATE_FLEETS : HEX_WAR_MAX_FLEETS
	if(length(faction_fleets(faction)) >= limit)
		return FALSE
	var/datum/fleet/F = launch_fleet(faction, yard)
	if(!F)
		return FALSE
	log_game("HEXWAR: [yard] shipyard launches [F.name]")
	return TRUE

/// Typy flot, które sztab frakcji wodowuje
/proc/hex_war_fleet_types(faction)
	switch(faction)
		if("nanotrasen")
			return list(/datum/fleet/nanotrasen/light = 2, /datum/fleet/nanotrasen = 1)
		if("solgov")
			return list(/datum/fleet/solgov = 1)
		if("syndicate")
			var/datum/faction/F = SSstar_system.faction_by_id(FACTION_ID_SYNDICATE)
			return F?.fleet_types?.Copy() || list(/datum/fleet/neutral = 1)
		if("pirate")
			return list(/datum/fleet/pirate/raiding = 1)

/// Nowa flota sztabu z nowym dowódcą (albo z podanym, gdy dowódca wraca)
/datum/hex_war/proc/launch_fleet(faction, datum/star_system/where, datum/hex_commander/C, size = 2)
	var/list/types = hex_war_fleet_types(faction)
	if(!length(types) || !where)
		return
	var/fleet_type = pickweight(types)
	var/datum/fleet/F = where.spawn_fleet(fleet_type, size)
	if(!F)
		return
	F.hex_war_adopt(C)
	return F

/// Konwój: mała flota frachtowców, która idzie po kaflach do obiektu docelowego swojej frakcji
/datum/hex_war/proc/send_convoy(datum/star_system/from, faction, cargo, amount, facility, datum/star_system/forced_destination)
	if(faction == "pirate" || length(faction_fleets(faction, TRUE)) >= HEX_WAR_MAX_CONVOYS)
		return FALSE
	var/datum/star_system/dest = forced_destination
	if(!dest)
		var/list/sites = faction_sites(faction, facility, from)
		sites -= from
		if(!length(sites))
			return FALSE
		dest = sites[1]
	if(!GLOB.hexmap.route(from.hex, dest.hex, faction, 5000))
		return FALSE
	var/datum/fleet/aquila_convoy/C = new
	C.alignment = faction
	C.faction_id = (faction == "syndicate") ? FACTION_ID_SYNDICATE : FACTION_ID_NT
	C.faction = SSstar_system.faction_by_id(C.faction_id)
	C.destroyer_types = list(faction == "syndicate" ? /obj/structure/overmap/syndicate/ai/carrier : /obj/structure/overmap/nanotrasen/mining_cruiser/aquila_hex_freighter)
	C.name = "konwój [cargo == "ore" ? "rudy" : "części"] ([hex_war_faction_name(faction)])"
	C.current_system = from
	from.fleets += C
	C.assemble(from, 2)
	C.war_controlled = TRUE
	C.war_order = HEX_ORDER_CONVOY
	C.war_cargo = cargo
	C.war_cargo_amount = amount
	C.war_destination = dest
	C.war_target = dest
	C.war_max_ships = C.hex_war_ship_count()
	log_game("HEXWAR: [faction] convoy of [amount] [cargo] leaves [from] for [dest]")
	return TRUE

/// Nazwa frakcji dla graczy
/proc/hex_war_faction_name(faction)
	switch(faction)
		if("nanotrasen")
			return "Nanotrasen"
		if("solgov")
			return "SolGov"
		if("syndicate")
			return "Syndykat"
		if("pirate")
			return "Piraci"
		if("unaligned")
			return "niezależni"
	return faction

/datum/fleet/aquila_convoy
	name = "konwój"
	fighter_types = list()
	destroyer_types = list(/obj/structure/overmap/nanotrasen/mining_cruiser/aquila_hex_freighter)
	battleship_types = list()
	supply_types = list()
	hide_movements = TRUE
	allow_difficulty_scaling = FALSE
	threat_elevation_allowed = FALSE
	can_reinforce = FALSE
	size = 2
	reward = 0
	taunts = list("Konwój zaopatrzeniowy, nie mamy z wami sporu. Zejdźcie z kursu.")
	greetings = list("Konwój zaopatrzeniowy pozdrawia. Dziękujemy za osłonę.")

/// Konwój dotarł: ładunek trafia do magazynu, frachtowce się rozładowują i znikają z mapy
/datum/fleet/proc/hex_war_deliver()
	var/datum/star_system/S = war_destination
	if(war_cargo == "ore")
		S.war_ore += war_cargo_amount
	else
		S.war_parts += war_cargo_amount
	log_game("HEXWAR: convoy [name] delivered [war_cargo_amount] [war_cargo] to [S]")
	war_cargo = null
	hex_war_dispose()

/// Usuwa flotę razem z okrętami (konwój po rozładunku, floty zastąpione zapisem kampanii). Okręty najpierw odpinamy,
/// bo usunięcie ostatniego przez remove_ship() wołałoby defeat(): ogłoszenie porażki i napięcie wojny za zwykłą dostawę.
/datum/fleet/proc/hex_war_dispose()
	var/list/ships = all_ships.Copy()
	for(var/obj/structure/overmap/OM as anything in ships)
		UnregisterSignal(OM, list(COMSIG_PARENT_QDELETING, COMSIG_SHIP_IFF_CHANGE))
	all_ships.Cut()
	for(var/obj/structure/overmap/OM as anything in ships)
		if(!QDELETED(OM))
			qdel(OM)
	current_system?.fleets -= src
	if(current_system && !length(current_system.fleets))
		current_system.alignment = current_system.owner
	qdel(src)

// ===== depoty i napady =====

/// Flota w sojuszniczym depocie: naprawa 30% kadłubów, a przy brakach okręt więcej
/datum/hex_war/proc/depots()
	for(var/datum/fleet/F as anything in hex_all_fleets())
		if(!F.war_controlled || F.war_cargo)
			continue
		var/datum/star_system/S = F.current_system
		if(!S?.has_facility(HEX_FAC_DEPOT) || !hex_factions_allied(S.owner, F.alignment) || hex_factions_hostile(F.alignment, S.alignment))
			continue
		for(var/obj/structure/overmap/OM as anything in F.all_ships)
			if(!QDELETED(OM))
				OM.obj_integrity = min(OM.max_integrity, OM.obj_integrity + OM.max_integrity * 0.3)
		if(F.hex_war_ship_count() < F.war_max_ships && prob(50))
			F.hex_war_add_ships(1)
		if(F.war_order == HEX_ORDER_REPAIR && F.hex_war_strength() >= 0.9)
			F.hex_war_set_order(HEX_ORDER_IDLE)

/// Piraci na stacji handlowej bez obrońców łupią ją: handel stoi przez HEX_WAR_RAID_TIME
/datum/hex_war/proc/raids()
	for(var/datum/fleet/F as anything in faction_fleets("pirate"))
		var/datum/star_system/S = F.current_system
		if(!S?.trader || S.owner == "pirate" || S.war_raided_until > world.time || S.war_raid_ready_at > world.time)
			continue
		if(length(hex_hostile_fleets_in(S, "pirate")))
			continue
		S.war_raided_until = world.time + HEX_WAR_RAID_TIME
		S.war_raid_ready_at = world.time + HEX_WAR_RAID_COOLDOWN
		F.war_loot += 3
		add_tension(1)
		if(!S.hidden)
			mini_announce("Piraci napadli stację handlową w układzie [S]. Handel wstrzymany na co najmniej 10 minut.", "White Rapids EAS")
		log_game("HEXWAR: [F.name] raids the trade station in [S]")

/datum/trader/attempt_purchase(datum/trader_item/item, mob/living/carbon/user)
	if(system?.war_raided_until > world.time)
		to_chat(user, "<span class='warning'>[name] nie handluje: stację niedawno złupili piraci.</span>")
		return FALSE
	// Limit eskorty sprawdzamy przed pobraniem pieniędzy (war_trade.dm)
	var/obj/structure/overmap/OM = user?.get_overmap()
	if(istype(item, /datum/trader_item/aquila_escort) && OM && OM.hex_escort_count() >= HEX_ESCORT_MAX)
		to_chat(user, "<span class='warning'>Eskorta jest pełna: najwyżej [HEX_ESCORT_MAX] okręty naraz.</span>")
		return FALSE
	return ..()

/// Losowe floty frakcji z send_fleet() zastępują stocznie; misje (override, force) dalej mogą tworzyć floty
/datum/faction/send_fleet(datum/star_system/override = null, custom_difficulty = null, force = FALSE)
	if(GLOB.hexmap?.built && !override && !force)
		return
	return ..()

/// Odległość po kaflach, także między sektorami: przez jedną albo dwie bramy (jak hd() w makiecie)
/datum/hexmap
	/// Odległości przez bramy policzone w tej turze sztabów (geometria się nie zmienia, ale nowe układy mogą dojść)
	var/list/war_distance_cache = list()

/datum/hexmap/proc/war_distance(datum/hex/a, datum/hex/b)
	if(!a || !b)
		return INFINITY
	if(a.sector == b.sector)
		return distance(a, b)
	. = INFINITY
	var/list/entries = war_sector_entries(a, b.sector)
	for(var/datum/hex/E as anything in entries)
		. = min(., entries[E] + distance(E, b))

/// Kafle bram, którymi z kafla a wchodzi się do sektora, z kosztem dojścia (marsz + skok bramą, co najwyżej dwie bramy).
/// Bramy powstają raz przy budowie mapy (link_gates), więc wynik nie zmienia się w trakcie rundy i jest pamiętany na stałe;
/// odległość do konkretnego kafla w sektorze to już tylko minimum po kilku wejściach.
/datum/hexmap/proc/war_sector_entries(datum/hex/a, sector)
	var/key = "[a.id]>[sector]"
	. = war_distance_cache[key]
	if(.)
		return
	var/list/entries = list()
	for(var/datum/hex/G as anything in gate_hexes_in(a.sector))
		var/to_gate = distance(a, G) + 1
		for(var/datum/hex/G2 as anything in G.gates)
			if(G2.sector == sector)
				entries[G2] = min(entries[G2] || INFINITY, to_gate)
				continue
			for(var/datum/hex/K as anything in gate_hexes_in(G2.sector))
				for(var/datum/hex/K2 as anything in K.gates)
					if(K2.sector == sector)
						entries[K2] = min(entries[K2] || INFINITY, to_gate + distance(G2, K) + 1)
	war_distance_cache[key] = entries
	return entries

