// AQUILA - sztaby frakcji (część D): te same reguły dla NT, SolGov i Syndykatu, różni je tylko cel natarcia; piraci łupią.
// Kolejność: odwrót do depotu, szturm na wrogą kwaterę, obrona i odbicie własnych układów (najwyżej połowa flot), eskorty
// konwojów, natarcie przy przewadze 1,2x, polowanie.
// Rozkaz to cel (war_target), do którego flota idzie kafel po kaflu przez hex_continue_heading().

/datum/fleet
	/// Flota należy do sztabu frakcji
	var/war_controlled = FALSE
	var/war_order = HEX_ORDER_IDLE
	var/war_order_time = 0
	var/datum/star_system/war_target
	/// Eskortowany konwój albo ścigany cel piratów
	var/datum/fleet/war_follow
	var/datum/hex_commander/commander
	/// Okręty przy wodowaniu (depot uzupełnia do tej liczby)
	var/war_max_ships = 0
	/// Łupy piratów
	var/war_loot = 0
	/// Konwój: ładunek, ilość i cel
	var/war_cargo
	var/war_cargo_amount = 0
	var/datum/star_system/war_destination
	/// Mgła wojny: ostatnio widziany kafel i kiedy
	var/war_last_seen_hex
	var/war_last_seen_time = 0
	var/war_last_seen_ships = 0

/// Czy sztab może przejąć tę flotę (garnizony, posiłki, polowania i bossowie zostają poza sztabem)
/datum/fleet/proc/hex_war_adoptable()
	if(war_controlled || fleet_trait == FLEET_TRAIT_DEFENSE || ai_is_reinforcement || !current_system)
		return FALSE
	if(istype(src, /datum/fleet/interdiction) || istype(src, /datum/fleet/solgov/interdiction) || istype(src, /datum/fleet/earthbuster))
		return FALSE
	return (alignment in GLOB.hex_war_factions)

/datum/fleet/proc/hex_war_adopt(datum/hex_commander/C)
	war_controlled = TRUE
	war_max_ships = max(war_max_ships, hex_war_ship_count())
	hex_war_set_order(HEX_ORDER_IDLE)
	if(!C)
		C = GLOB.hex_war.new_commander(alignment)
	C.take_fleet(src)

/datum/fleet/proc/hex_war_set_order(order, datum/star_system/target, datum/fleet/follow)
	war_order = order
	war_target = target
	war_follow = follow
	war_order_time = world.time

/datum/fleet/proc/hex_war_ship_count()
	. = 0
	for(var/obj/structure/overmap/OM as anything in all_ships)
		if(!QDELETED(OM))
			.++

/// Stan floty 0–1: średni stan kadłubów względem okrętów przy wodowaniu
/datum/fleet/proc/hex_war_strength()
	if(!war_max_ships)
		return 1
	var/total = 0
	for(var/obj/structure/overmap/OM as anything in all_ships)
		if(!QDELETED(OM) && OM.max_integrity)
			total += OM.obj_integrity / OM.max_integrity
	return min(1, total / war_max_ships)

/// Siła bojowa do porównań sztabu
/datum/fleet/proc/hex_war_power()
	. = 0
	for(var/obj/structure/overmap/OM as anything in all_ships)
		if(!QDELETED(OM) && OM.max_integrity)
			. += 0.5 + 0.5 * OM.obj_integrity / OM.max_integrity
	if(commander)
		. *= 1 + 0.1 * commander.rank

/datum/fleet/proc/hex_war_add_ships(amount)
	if(!length(destroyer_types) || !current_system)
		return
	for(var/i in 1 to amount)
		var/ship_type = pick(destroyer_types)
		var/obj/structure/overmap/member = new ship_type()
		add_ship(member, "destroyers")

/// Cel ruchu według rozkazu; null = flota stoi albo wędruje jak dotąd
/datum/fleet/proc/hex_war_move_target()
	var/datum/star_system/T = war_target
	if(war_order in list(HEX_ORDER_ESCORT, HEX_ORDER_RAID))
		if(war_follow && !QDELETED(war_follow))
			T = war_follow.current_system
	if(!T || QDELETED(T) || T == current_system)
		return
	return T

/// Flota stoi na miejscu (trzyma zajęty układ, broni, naprawia się, czeka na łup)
/datum/fleet/proc/hex_war_holds()
	if(!war_controlled || war_order == HEX_ORDER_IDLE)
		return FALSE
	return !hex_war_move_target()

/datum/fleet/move(datum/star_system/target, force = FALSE)
	if(istype(src, /datum/fleet/aquila_escort)) // eskorta skacze tylko razem z okrętem gracza (war_trade.dm)
		return FALSE
	// Flota odpowiadająca na wezwanie idzie tylko krokami posiłków (fleet_distress.dm), w tempie przyjętym w ETA
	if(ai_answering && !force)
		addtimer(CALLBACK(src, PROC_REF(move)), rand(minimum_random_move_delay, maximum_random_move_delay))
		return FALSE
	// Rozkaz ataku na układ, w którym flota już stoi: zamiana na HOLD dzieje się zwykle po dojściu (niżej), a tu flota
	// nigdzie nie idzie, więc bez tego stałaby z ATTACK do końca kampanii, poza pulą sztabu
	if(war_controlled && war_order == HEX_ORDER_ATTACK && war_target == current_system)
		hex_war_set_order(HEX_ORDER_HOLD, war_target)
	if(war_controlled && !target && !force && hex_war_holds())
		addtimer(CALLBACK(src, PROC_REF(move)), rand(minimum_random_move_delay, maximum_random_move_delay))
		return FALSE
	// Flota bez wyznaczonego kursu ma plotted_course = FALSE, a move() po dojściu do celu z hex_continue_heading()
	// robi `plotted_course -= target` (runtime). Pusta lista znaczy dla move() to samo co FALSE.
	if(!islist(plotted_course))
		plotted_course = list()
	. = ..()
	if(QDELETED(src))
		return
	if(war_cargo && current_system == war_destination)
		hex_war_deliver()
		return
	if(war_cargo)
		hex_war_try_intercept()
	if(war_order == HEX_ORDER_ATTACK && current_system == war_target)
		hex_war_set_order(HEX_ORDER_HOLD, war_target)

/// Konwój wszedł na kafel: wroga flota sztabu w sąsiednim kaflu może skoczyć za nim i go przechwycić (walka w kaflu konwoju)
/datum/fleet/proc/hex_war_try_intercept()
	var/datum/hex/here = GLOB.hex_war?.fleet_hex(src)
	if(!here)
		return FALSE
	for(var/datum/fleet/hunter as anything in hex_all_fleets())
		if(hunter == src || !hunter.war_controlled || hunter.war_cargo || !hex_factions_hostile(hunter.alignment, alignment))
			continue
		if(hunter.current_system == current_system)
			return FALSE // już tu jest, walka i tak się zacznie
		if(hunter.war_order in list(HEX_ORDER_REPAIR, HEX_ORDER_HOME))
			continue
		var/datum/hex/there = GLOB.hex_war.fleet_hex(hunter)
		if(!there || there.sector != here.sector || GLOB.hexmap.distance(there, here) != 1)
			continue
		if(world.time < hunter.last_encounter_time + hunter.combat_move_delay)
			continue // zajęta własną walką
		if(!prob(hunter.alignment == "pirate" ? HEX_WAR_INTERCEPT_PIRATE : HEX_WAR_INTERCEPT))
			continue
		hunter.move(current_system, force = TRUE)
		log_game("HEXWAR: [hunter.name] intercepts [name] at [here.id]")
		if(hunter.current_system == current_system && prob(HEX_WAR_INTERCEPT_KILL))
			hex_war_convoy_lost(hunter)
		return TRUE
	return FALSE

/// Przechwycony konwój ginie: łup dla piratów, zwycięstwo dla dowódcy łowcy, okręty konwoju znikają
/datum/fleet/proc/hex_war_convoy_lost(datum/fleet/hunter)
	if(hunter.alignment == "pirate")
		hunter.war_loot += war_cargo_amount
	hunter.commander?.add_win(null)
	GLOB.hex_war?.add_tension(1)
	log_game("HEXWAR: convoy [name] was destroyed by [hunter.name]")
	hex_war_dispose()

// ===== sztab =====

/datum/hex_war/proc/is_free(datum/fleet/F)
	if(F.war_order in list(HEX_ORDER_IDLE))
		return TRUE
	// Flota trzymająca zajęty układ po 15 minutach wraca do puli sztabu
	return F.war_order == HEX_ORDER_HOLD && world.time - F.war_order_time > 15 MINUTES

/datum/hex_war/proc/fleet_hex(datum/fleet/F)
	return F.current_system?.hex || GLOB.hexmap.hex_of_system(F.current_system)

/datum/hex_war/proc/dist(datum/fleet/F, datum/star_system/S)
	return GLOB.hexmap.war_distance(fleet_hex(F), S?.hex)

/// Siła floty (wrogiej lub sojuszniczej względem frakcji) w układzie i w promieniu
/datum/hex_war/proc/power_near(datum/star_system/S, faction, radius, hostile = TRUE)
	. = 0
	if(!S?.hex)
		return
	var/list/fleets = staff_fleets || fleet_snapshot()
	var/list/relation = list() // stosunek do frakcji floty liczony raz na wywołanie, nie dla każdej floty
	for(var/datum/fleet/F as anything in fleets)
		if(QDELETED(F))
			continue
		var/key = "[F.alignment]"
		var/ok = relation[key]
		if(isnull(ok))
			ok = hostile ? hex_factions_hostile(faction, F.alignment) : hex_factions_allied(faction, F.alignment)
			relation[key] = ok
		if(!ok)
			continue
		var/list/info = fleets[F]
		if(GLOB.hexmap.war_distance(info[1], S.hex) > radius)
			continue
		. += info[2]

/// Floty bojowe na mapie z kaflem i siłą (bez konwojów): flota -> list(kafel, siła)
/datum/hex_war/proc/fleet_snapshot()
	. = list()
	for(var/datum/fleet/F as anything in hex_all_fleets())
		if(F.war_cargo)
			continue
		var/datum/hex/H = fleet_hex(F)
		if(H)
			.[F] = list(H, F.hex_war_power())

/datum/hex_war/proc/nearest_free(list/fleets, datum/star_system/S, max_distance)
	var/datum/fleet/best
	var/best_d = INFINITY
	for(var/datum/fleet/F as anything in fleets)
		if(!is_free(F) || F.current_system == S)
			continue
		var/d = dist(F, S)
		if(d < best_d && d <= max_distance)
			best_d = d
			best = F
	return best

/datum/hex_war
	/// Floty na czas jednego sztabu (fleet_snapshot): power_near pyta o nie dziesiątki razy, a hex_all_fleets() przegląda
	/// wszystkie układy, kafel i siła floty w trakcie sztabu się nie zmieniają (rozkazy ruszają floty dopiero ich timerem)
	var/list/staff_fleets

/datum/hex_war/proc/staff(faction)
	staff_fleets = fleet_snapshot()
	staff_orders(faction)
	staff_fleets = null

/datum/hex_war/proc/staff_orders(faction)
	var/list/mine = faction_fleets(faction)
	if(!length(mine))
		return
	// 1. odwrót do depotu
	for(var/datum/fleet/F as anything in mine)
		if(F.war_order == HEX_ORDER_REPAIR || F.commander?.has_trait("fanatic"))
			continue
		var/limit = F.commander?.has_trait("coward") ? 0.6 : 0.4
		if(F.hex_war_strength() >= limit)
			continue
		var/list/depots = faction_sites(faction, HEX_FAC_DEPOT, F.current_system)
		if(length(depots))
			F.hex_war_set_order(HEX_ORDER_REPAIR, depots[1])
	if(faction == "pirate")
		pirate_staff(mine)
		return
	// 2. szturm na wrogą kwaterę, zanim wolne floty pójdą bronić (inaczej strona pod ciągłym naciskiem nigdy nie kontratakuje)
	hq_assault(faction, mine)
	// 3. obrona i odbicie własnych układów: na obronę najwyżej połowa flot, reszta zostaje na natarcie
	var/defenders = 0
	for(var/datum/fleet/F as anything in mine)
		if(F.war_order == HEX_ORDER_DEFEND)
			defenders++
	var/max_defenders = max(1, round(length(mine) / 2))
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(!S.hex || S.hidden || (S.owner != faction && S.alignment != faction))
			continue
		var/lost = S.owner == faction && hex_factions_hostile(faction, S.alignment)
		if(!lost && !length(S.war_facilities))
			continue
		var/threat = power_near(S, faction, 2)
		var/defence = power_near(S, faction, 0, FALSE)
		if(!lost && threat <= defence)
			continue
		if(!lost && defenders >= max_defenders)
			continue
		var/datum/fleet/F = nearest_free(mine, S, HEX_WAR_REACH)
		if(F)
			F.hex_war_set_order(lost ? HEX_ORDER_ATTACK : HEX_ORDER_DEFEND, S)
			if(!lost)
				defenders++
	// 4. eskorty zagrożonych konwojów
	for(var/datum/fleet/convoy as anything in faction_fleets(faction, TRUE))
		var/escorted = FALSE
		for(var/datum/fleet/F as anything in mine)
			if(F.war_follow == convoy)
				escorted = TRUE
				break
		if(escorted || !convoy.current_system || !power_near(convoy.current_system, faction, 4))
			continue
		var/datum/fleet/F = nearest_free(mine, convoy.current_system, 4)
		if(F)
			F.hex_war_set_order(HEX_ORDER_ESCORT, null, convoy)
	// 5. natarcie przy przewadze
	offensive(faction, mine)
	// 6. polowanie dowódców z urazą do okrętu gracza
	var/obj/structure/overmap/player = SSstar_system.find_main_overmap()
	var/datum/star_system/player_system = player?.current_system
	for(var/datum/fleet/F as anything in mine)
		if(F.war_order != HEX_ORDER_HUNT)
			continue
		if(player_system?.hex && hex_factions_hostile(faction, player.faction))
			F.war_target = player_system
		else
			F.hex_war_set_order(HEX_ORDER_IDLE)
	// Rozkazy, które się przedawniły
	for(var/datum/fleet/F as anything in mine)
		if(F.war_order == HEX_ORDER_DEFEND && world.time - F.war_order_time > 20 MINUTES)
			F.hex_war_set_order(HEX_ORDER_IDLE)
		if(F.war_order == HEX_ORDER_ESCORT && (!F.war_follow || QDELETED(F.war_follow)))
			F.hex_war_set_order(HEX_ORDER_IDLE)

/// Czy układ jest celem natarcia tej frakcji
/datum/hex_war/proc/in_goal(faction, datum/star_system/S)
	// Kwaterę Syndykatu dobija okręt gracza, nie sztaby AI (war_end.dm)
	if(S.owner == "syndicate" && S.has_facility(HEX_FAC_HQ) && faction != "syndicate")
		return FALSE
	switch(faction)
		if("syndicate")
			return hex_factions_hostile(faction, S.alignment) || S.alignment == "unaligned"
		if("nanotrasen")
			// także w sektorze Syndykatu i w układach niczyich, jak Syndykat; inaczej NT tylko się broniło (raport/ftl_mapa_07)
			return hex_factions_hostile(faction, S.alignment) || S.alignment == "unaligned"
		if("solgov")
			if(!hex_factions_hostile(faction, S.alignment))
				return FALSE
			for(var/datum/star_system/own as anything in SSstar_system.systems)
				if(own.owner == faction && own.hex && GLOB.hexmap.war_distance(own.hex, S.hex) <= 6)
					return TRUE
	return FALSE

/// Szturm na wrogą kwaterę: ocena wartość/obrona w offensive() zawsze wybierałaby słabsze cele, więc kwatera ma osobną fazę.
/// Najbliższe wolne floty w zasięgu (do HEX_WAR_HQ_GROUP) idą razem, jeśli mają HEX_WAR_HQ_ADVANTAGE siły obrony.
/datum/hex_war/proc/hq_assault(faction, list/mine)
	var/list/free = list()
	for(var/datum/fleet/F as anything in mine)
		if(is_free(F))
			free += F
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(!length(free))
			return
		if(!S.hex || S.hidden || !S.has_facility(HEX_FAC_HQ) || !in_goal(faction, S) || already_targeted(mine, S, null))
			continue
		var/defence = 0
		for(var/datum/fleet/D as anything in S.fleets)
			if(!QDELETED(D) && !D.war_cargo && !hex_factions_allied(faction, D.alignment))
				defence += D.hex_war_power()
		var/list/by_distance = list()
		for(var/datum/fleet/F as anything in free)
			var/d = dist(F, S)
			if(d <= HEX_WAR_REACH_HQ)
				by_distance[F] = d
		sortTim(by_distance, GLOBAL_PROC_REF(cmp_numeric_asc), associative = TRUE)
		var/list/group = list()
		var/power = 0
		for(var/datum/fleet/F as anything in by_distance)
			if(length(group) >= HEX_WAR_HQ_GROUP)
				break
			group += F
			power += F.hex_war_power()
		if(!length(group) || power < defence * HEX_WAR_HQ_ADVANTAGE / fortune_of(faction))
			continue
		for(var/datum/fleet/F as anything in group)
			F.hex_war_set_order(HEX_ORDER_ATTACK, S)
			free -= F
		log_game("HEXWAR: [faction] storms the headquarters in [S] with [length(group)] fleet(s), power [power] vs [defence]")

/datum/hex_war/proc/offensive(faction, list/mine)
	var/list/targets = list()
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(!S.hex || S.hidden || istype(S, /datum/star_system/random/hex_empty) || !in_goal(faction, S))
			continue
		var/defence = (S.alignment == "unaligned") ? 1 : 0
		for(var/datum/fleet/F as anything in S.fleets)
			if(!QDELETED(F) && !F.war_cargo && !hex_factions_allied(faction, F.alignment))
				defence += F.hex_war_power()
		var/value = 1 + 2 * length(S.war_facilities) + (S.has_facility(HEX_FAC_FACTORY) ? 2 : 0) + (S.has_facility(HEX_FAC_YARD) ? 2 : 0) + (S.owner == faction ? 3 : 0) + (S.has_facility(HEX_FAC_HQ) ? 6 : 0)
		targets[S] = list(defence, value)
	var/list/free = list()
	for(var/datum/fleet/F as anything in mine)
		if(is_free(F))
			free += F
	while(length(free))
		var/datum/fleet/lead = free[1]
		var/datum/star_system/best
		var/best_score = 0
		for(var/datum/star_system/S as anything in targets)
			var/d = dist(lead, S)
			if(d > (S.has_facility(HEX_FAC_HQ) ? HEX_WAR_REACH_HQ : HEX_WAR_REACH) || already_targeted(mine, S, lead))
				continue
			var/list/info = targets[S]
			var/score = info[2] / (1 + info[1]) / (1 + d * 0.25)
			if(score > best_score)
				best_score = score
				best = S
		if(!best)
			free -= lead
			continue
		var/defence = targets[best][1]
		var/list/group = list(lead)
		var/power = lead.hex_war_power()
		// Frakcja z lepszym atutem kampanii naciera przy mniejszej przewadze (war_fortune.dm)
		var/advantage = HEX_WAR_ADVANTAGE / fortune_of(faction)
		var/is_hq = best.has_facility(HEX_FAC_HQ)
		if(is_hq)
			advantage = HEX_WAR_HQ_ADVANTAGE / fortune_of(faction)
		if(power < defence * advantage)
			for(var/datum/fleet/other as anything in free - lead)
				if(length(group) >= (is_hq ? HEX_WAR_HQ_GROUP : 3) || power >= defence * advantage)
					break
				if(GLOB.hexmap.war_distance(fleet_hex(other), fleet_hex(lead)) <= (is_hq ? HEX_WAR_HQ_GROUP_RANGE : 4))
					group += other
					power += other.hex_war_power()
		if(power >= defence * advantage)
			for(var/datum/fleet/F as anything in group)
				F.hex_war_set_order(HEX_ORDER_ATTACK, best)
				free -= F
			log_game("HEXWAR: [faction] attacks [best] with [length(group)] fleet(s), power [power] vs [defence]")
		else
			free -= lead

/datum/hex_war/proc/already_targeted(list/mine, datum/star_system/S, datum/fleet/except)
	for(var/datum/fleet/F as anything in mine)
		if(F != except && F.war_target == S && F.war_order == HEX_ORDER_ATTACK)
			return TRUE
	return FALSE

/// Piraci: konwoje w zasięgu 5, potem stacje handlowe; z łupem wracają do swojej stoczni
/datum/hex_war/proc/pirate_staff(list/mine)
	var/datum/star_system/home
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(S.owner == "pirate" && S.has_facility(HEX_FAC_YARD))
			home = S
			break
	for(var/datum/fleet/F as anything in mine)
		if(F.war_loot >= 6 && home && !(F.war_order in list(HEX_ORDER_REPAIR, HEX_ORDER_HOME)))
			F.hex_war_set_order(HEX_ORDER_HOME, home)
		if(F.war_order == HEX_ORDER_HOME && F.current_system == home)
			F.hex_war_set_order(HEX_ORDER_IDLE)
		if(F.war_order == HEX_ORDER_RAID && world.time - F.war_order_time > 30 MINUTES)
			F.hex_war_set_order(HEX_ORDER_IDLE)
		// Pościg za konwojem, który już dojechał albo zginął: flota wraca do puli od razu (napad na stację ma war_target)
		if(F.war_order == HEX_ORDER_RAID && !F.war_target && (!F.war_follow || QDELETED(F.war_follow)))
			F.hex_war_set_order(HEX_ORDER_IDLE)
		if(!is_free(F))
			continue
		var/datum/fleet/prey
		var/prey_d = 6
		for(var/datum/fleet/C as anything in hex_all_fleets())
			if(!C.war_cargo || C.alignment == "pirate")
				continue
			var/d = GLOB.hexmap.war_distance(fleet_hex(F), fleet_hex(C))
			if(d < prey_d)
				prey_d = d
				prey = C
		if(prey)
			F.hex_war_set_order(HEX_ORDER_RAID, null, prey)
			continue
		if(prob(HEX_WAR_PIRATE_CONQUEST))
			var/datum/star_system/conquest = pirate_conquest_target(F)
			if(conquest)
				F.hex_war_set_order(HEX_ORDER_ATTACK, conquest)
				log_game("HEXWAR: [F.name] goes to take [conquest]")
				continue
		var/datum/star_system/station
		var/station_d = 11
		for(var/datum/star_system/S as anything in SSstar_system.systems)
			if(!S.trader || !S.hex || S.hidden || S.owner == "pirate" || S.war_raided_until > world.time || S.war_raid_ready_at > world.time)
				continue
			var/d = dist(F, S)
			if(d < station_d)
				station_d = d
				station = S
		if(station)
			F.hex_war_set_order(HEX_ORDER_RAID, station)

/// Piraci zajmują słabe układy w zasięgu 6 kafli: niczyje albo wrogie, bez kwatery głównej, z obroną poniżej siły floty
/datum/hex_war/proc/pirate_conquest_target(datum/fleet/F)
	var/power = F.hex_war_power()
	var/datum/star_system/best
	var/best_score = 0
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(!S.hex || S.hidden || istype(S, /datum/star_system/random/hex_empty) || S.alignment == "pirate" || S.has_facility(HEX_FAC_HQ))
			continue
		var/d = dist(F, S)
		if(d > 6 || already_targeted(faction_fleets("pirate"), S, F))
			continue
		var/defence = 0
		for(var/datum/fleet/other as anything in S.fleets)
			if(!QDELETED(other) && !other.war_cargo && other.alignment != "pirate")
				defence += other.hex_war_power()
		if(defence * HEX_WAR_ADVANTAGE > power)
			continue
		var/score = (1 + length(S.war_facilities) + (S.trader ? 2 : 0)) / (1 + d * 0.3)
		if(score > best_score)
			best_score = score
			best = S
	return best

/// Średni stan kadłubów ocalałych okrętów floty, 0–1 (do zapisu kampanii)
/datum/fleet/proc/hex_war_hull()
	var/total = 0
	var/count = 0
	for(var/obj/structure/overmap/OM as anything in all_ships)
		if(!QDELETED(OM) && OM.max_integrity)
			total += OM.obj_integrity / OM.max_integrity
			count++
	return count ? total / count : 1

