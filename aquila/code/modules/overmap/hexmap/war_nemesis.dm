// AQUILA - nemezis: bossowie z mapy gwiezdnej (SSV Fist of Sol w Romulusie, SGV Alicorn w Veneto, Komitet Powitalny
// w Dolos Remnants) mają stałych dowódców w systemie dowódców wojny. Flota bossa stoi w swoim układzie jak garnizon
// (poza sztabem), a jej dowódca ma imię, cechy, historię i urazę jak inni. Pokonany ucieka i wraca po czasie
// z odbudowanym okrętem do swojego układu albo ginie i nie wraca do końca kampanii.
// Komitet Powitalny poluje: okręt gracza przelatujący przez kafel floty albo obok niej ściąga ją w pościg po sektorze
// (rozkaz HEX_ORDER_HUNT, krok po kroku przez move() i hex_next_step()), a po kilku skokach flota wraca do Dolos.

/// id nemezis -> dowódca, jego flota i układ
GLOBAL_LIST_INIT(hex_nemeses, list(
	"fistofsol" = list(
		"faction" = "syndicate",
		"first" = "Lucan",
		"last" = "Draven",
		"nick" = "Młot Sol",
		"rank" = 3,
		"traits" = list("strategist", "armored", "vengeful"),
		"fleet" = /datum/fleet/syndicate/fistofsol_boss,
		"home" = "Romulus",
	),
	"alicorn" = list(
		"faction" = "hostile",
		"first" = "Seraphine",
		"last" = "Vael",
		"nick" = "Miliard",
		"rank" = 3,
		"traits" = list("cunning", "cautious"),
		"fleet" = /datum/fleet/hostile/alicorn_boss,
		"home" = "Veneto",
	),
	"dolos" = list(
		"faction" = "syndicate",
		"first" = "Silas",
		"last" = "Kertesz",
		"nick" = "Grabarz",
		"rank" = 3,
		"traits" = list("strategist", "cunning", "fanatic"),
		"fleet" = /datum/fleet/dolos/boss,
		"home" = "Dolos Remnants",
	),
))

/datum/hex_commander
	/// Nemezis: id z GLOB.hex_nemeses. Dowodzi tylko swoim bossem i wraca tylko do swojego układu.
	var/nemesis

/datum/fleet
	/// Boss nemezis rusza w pościg za okrętem gracza przelatującym obok i odpuszcza po tylu skokach (0 = nie poluje)
	var/nemesis_hunt_steps = 0
	/// Ile skoków pościgu jeszcze zostało
	var/nemesis_hunt_left = 0
	var/nemesis_hunt_timer
	/// Kroki powrotu, w których flota nie ruszyła się z miejsca (walka, interdykcja, brak trasy)
	var/nemesis_stuck_steps = 0

/// Komitet Powitalny Dolos jako boss nemezis: 8 okrętów zamiast 25 z /datum/fleet/dolos (więcej niż Fist of Sol
/// i Alicorn razem, a AI nie radziło sobie z fizyką i ostrzałem tylu okrętów). Pozostałość z Oasis Fidei połączono
/// z nim w jednego bossa, więc ma też jej drwinę i muzykę.
/datum/fleet/dolos/boss
	size = FLEET_DIFFICULTY_HARD
	threat_elevation_allowed = FALSE
	audio_cues = list(/datum/soundtrack_song/bee/future_perception, /datum/soundtrack_song/bee/finale)
	taunts = list("Nie myślcie, że nie wyciągnęliśmy wniosków z waszej ostatniej próby.", "Nie zawiedziemy ponownie", "Wasza przestarzała broń MAC nie ma z nami szans. Szykujcie się na zniszczenie.", "<pre>\[BŁĄD DESZYFRACJI]</pre>")
	nemesis_hunt_steps = 4

// Alicorn i jego myśliwce mają frakcję okrętów "hostile". Flota z frakcją Syndykatu dostawała z domyślnych list
// niszczyciel i krążownik Syndykatu, które strzelały do Alicorna, a flota uznawała okręty Syndykatu za swoje.
/datum/fleet/hostile/alicorn_boss
	alignment = "hostile"
	destroyer_types = list()
	battleship_types = list()

/// Stały dowódca bossa: z zapisu kampanii albo nowy
/datum/hex_war/proc/nemesis_commander(id)
	for(var/datum/hex_commander/existing as anything in commanders)
		if(existing.nemesis == id)
			return existing
	var/list/info = GLOB.hex_nemeses[id]
	if(!info)
		return
	var/datum/hex_commander/C = new
	C.id = next_commander_id++
	C.nemesis = id
	C.faction = info["faction"]
	C.first_name = info["first"]
	C.last_name = info["last"]
	C.nickname = info["nick"]
	C.rank = info["rank"]
	var/list/traits = info["traits"]
	C.traits = traits.Copy()
	commanders += C
	return C

/// Flota bossa danego typu w układzie
/proc/hex_nemesis_fleet(datum/star_system/S, fleet_type)
	for(var/datum/fleet/F as anything in S?.fleets)
		if(!QDELETED(F) && istype(F, fleet_type))
			return F

/// Start rundy, po zapisie i garnizonach: boss dostaje swojego dowódcę. Ranny albo poległy dowódca nie stoi w układzie,
/// a boss, którego brakuje w mapie gwiezdnej trwającej kampanii (zapisanej przed jego dodaniem), pojawia się w układzie.
/datum/hex_war/proc/setup_nemeses()
	remove_remnant()
	for(var/id in GLOB.hex_nemeses)
		var/list/info = GLOB.hex_nemeses[id]
		var/datum/star_system/home = SSstar_system.system_by_id(info["home"])
		if(!home?.hex)
			continue
		var/datum/hex_commander/C = nemesis_commander(id)
		var/datum/fleet/boss = hex_nemesis_fleet(home, info["fleet"])
		if(C.status != HEX_CMD_ACTIVE)
			boss?.hex_war_dispose()
			continue
		if(!boss)
			// Układ trzyma wróg (garnizon nie wrócił do zajętego układu): dowódca odbije go później
			if(hex_factions_hostile(home.owner, home.alignment))
				C.status = HEX_CMD_WOUNDED
				C.return_at = world.time + rand(HEX_WAR_RETURN_MIN, HEX_WAR_RETURN_MAX)
				continue
			boss = home.spawn_fleet(info["fleet"])
			if(!boss)
				continue
		C.take_fleet(boss)
	// Cel trybu trudnego postawiony przed startem wojny (Oczyść Dolos Remnants): boss jest celem zamiast Pozostałości
	for(var/id in GLOB.hex_nemeses)
		var/datum/star_system/home = SSstar_system.system_by_id(GLOB.hex_nemeses[id]["home"])
		if(hex_nemesis_objective(home))
			nemesis_objective_boss(id)

/// Ranny nemezis wraca z odbudowanym okrętem do swojego układu, a nie do stoczni frakcji jak zwykli dowódcy
/datum/hex_war/proc/nemesis_return(datum/hex_commander/C)
	var/list/info = GLOB.hex_nemeses[C.nemesis]
	if(!info)
		return
	var/datum/star_system/home = SSstar_system.system_by_id(info["home"])
	if(!home)
		return
	// Flota bossa bez dowódcy (cel trybu trudnego pod nieobecność rannego) dostaje go z powrotem zamiast drugiej floty
	var/datum/fleet/F = hex_nemesis_fleet(home, info["fleet"])
	if(F?.commander)
		F = null
	if(!F)
		var/held = home.alignment
		F = home.spawn_fleet(info["fleet"])
		if(!F)
			return
		// Jak przy ruchu floty (fleet.move): przy wrogiej flocie w układzie zajmie go dopiero zwycięzca walki
		if(F.hex_occupation_blocked(home))
			home.alignment = held
	C.take_fleet(F)
	C.add_history("wrócił do układu [home]")
	if(home.hidden)
		return
	if(C.grudge)
		mini_announce("Wywiad: [C.rank_name()] [C.full_name()] wraca do układu [home] na odbudowanym okręcie i szuka zemsty na [station_name()].", "White Rapids EAS")
	else
		mini_announce("Wywiad: [C.rank_name()] [C.full_name()] wraca do układu [home] na odbudowanym okręcie.", "White Rapids EAS")

/// Pozostałość połączona z Komitetem Powitalnym Dolos w jednego bossa: znika z Oasis Fidei, także z mapy gwiezdnej
/// kampanii zapisanej przed tą zmianą (fleet_type układu wraca do zapisu przy każdym końcu rundy)
/datum/hex_war/proc/remove_remnant()
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(S.fleet_type && ispath(text2path("[S.fleet_type]"), /datum/fleet/remnant))
			S.fleet_type = null
		for(var/datum/fleet/remnant/F in S.fleets.Copy())
			log_game("HEXWAR: the Remnant fleet in [S] was removed (merged into the Dolos nemesis)")
			F.hex_war_dispose()

// Zapasowa mapa gwiezdna z kodu (gdy starmap.json się nie wczyta): Pozostałość też nie stoi w Oasis Fidei
/datum/star_system/sector4/laststand
	fleet_type = null

// ===== pościg nemezis =====

/// Okręt gracza wyszedł z nadprzestrzeni: kafel przylotu i kafle, przez które leciał (trasa z hex_jump)
/obj/structure/overmap/hex_on_arrival(datum/star_system/S)
	. = ..()
	var/list/path = hex_flight_path
	hex_flight_path = null
	var/datum/hex/H = GLOB.hexmap?.hex_of_system(S)
	if(!H || !GLOB.hex_war?.ready || SSticker.current_state != GAME_STATE_PLAYING || SSovermap_mode?.already_ended)
		return
	var/list/hexes = list(H)
	// Kafle, przez które okręt przeleciał, bez kafla wylotu: odlot spod bossa to nie przelot obok niego
	if(length(path) >= 2 && path[length(path)] == H)
		hexes |= path.Copy(2)
	GLOB.hex_war.nemesis_sighting(src, S, hexes)

/// Boss nemezis, który poluje, widzi okręt gracza na swoim kaflu albo obok i rusza za nim
/datum/hex_war/proc/nemesis_sighting(obj/structure/overmap/ship, datum/star_system/arrived, list/hexes)
	for(var/datum/hex_commander/C as anything in commanders)
		if(!C.nemesis || C.status != HEX_CMD_ACTIVE)
			continue
		var/datum/fleet/F = C.fleet
		if(!F || QDELETED(F) || !F.nemesis_hunt_steps || F.war_order != HEX_ORDER_IDLE)
			continue
		if(!hex_factions_hostile(F.alignment, ship.faction) || hex_nemesis_objective(F.nemesis_home()))
			continue
		if(!F.nemesis_spots(hexes))
			continue
		F.nemesis_start_hunt(arrived)
		F.nemesis_schedule_hunt(HEX_NEMESIS_HUNT_FIRST)
		C.add_history("ruszył w pościg za okrętem [station_name()]")
		log_game("HEXWAR: nemesis [F.name] hunts [ship] from [F.current_system]")
		mini_announce("Wywiad: [C.rank_name()] [C.full_name()] rusza w pościg za [station_name()].", "White Rapids EAS")

/// Układ, do którego boss wraca po pościgu
/datum/fleet/proc/nemesis_home()
	var/list/info = GLOB.hex_nemeses[commander?.nemesis]
	return info ? SSstar_system.system_by_id(info["home"]) : null

/// Któryś z kafli jest kaflem floty albo sąsiednim (w tym samym sektorze)
/datum/fleet/proc/nemesis_spots(list/hexes)
	var/datum/hex/here = GLOB.hexmap?.hex_of_system(current_system)
	if(!here)
		return FALSE
	for(var/datum/hex/H as anything in hexes)
		if(H && GLOB.hexmap.distance(here, H) <= 1)
			return TRUE
	return FALSE

/datum/fleet/proc/nemesis_start_hunt(datum/star_system/prey)
	nemesis_hunt_left = nemesis_hunt_steps
	hex_war_set_order(HEX_ORDER_HUNT, prey)

/datum/fleet/proc/nemesis_schedule_hunt(delay)
	if(nemesis_hunt_timer)
		deltimer(nemesis_hunt_timer)
	nemesis_hunt_timer = addtimer(CALLBACK(src, PROC_REF(nemesis_hunt_step)), delay, TIMER_STOPPABLE)

/// Krok pościgu: celem jest układ okrętu gracza w tym samym sektorze, a w czasie jego lotu ostatni znany
/datum/fleet/proc/nemesis_hunt_step()
	nemesis_hunt_timer = null
	if(QDELETED(src) || !current_system)
		return
	var/datum/star_system/prey = war_target
	if(war_order == HEX_ORDER_HUNT)
		var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
		var/datum/hex/ship_hex = ship?.current_hex()
		var/datum/hex/here = GLOB.hexmap.hex_of_system(current_system)
		if(!ship || !hex_factions_hostile(alignment, ship.faction) || (ship_hex && ship_hex.sector != here?.sector))
			prey = null // okręt zniknął, zmienił stronę albo uciekł bramą do innego sektora
		else if(ship_hex)
			prey = GLOB.hexmap.system_for(ship_hex)
	nemesis_hunt_move(prey)
	if(!QDELETED(src) && war_order != HEX_ORDER_IDLE)
		nemesis_schedule_hunt(rand(HEX_NEMESIS_HUNT_STEP_MIN, HEX_NEMESIS_HUNT_STEP_MAX))

/**
 * Jeden krok pościgu albo powrotu do układu bossa. prey = układ ściganego okrętu, null = zgubiony.
 * Boss nie odpuszcza w trakcie walki z okrętem (prey w jego układzie), nawet po wyczerpaniu skoków.
 * Zwraca TRUE, gdy flota przeszła kafel.
 */
/datum/fleet/proc/nemesis_hunt_move(datum/star_system/prey)
	var/datum/star_system/home = nemesis_home()
	if(war_order == HEX_ORDER_HUNT)
		if(!prey || (nemesis_hunt_left <= 0 && prey != current_system))
			nemesis_end_hunt(home)
		else
			war_target = prey
	if(war_order == HEX_ORDER_HOME && current_system == home)
		hex_war_set_order(HEX_ORDER_IDLE)
	if(!(war_order in list(HEX_ORDER_HUNT, HEX_ORDER_HOME)))
		return FALSE
	var/datum/star_system/T = hex_war_move_target()
	if(!T)
		return FALSE
	if(current_system.check_conflict_status()) // walka flot AI w układzie: zostaje
		nemesis_note_stuck()
		return FALSE
	if(length(all_ships) && (SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CHECK_INTERDICT, pick(all_ships)) & (WEAK_INTERDICT|STRONG_INTERDICT)))
		nemesis_note_stuck()
		return FALSE
	var/datum/star_system/before = current_system
	move(T, TRUE)
	if(QDELETED(src))
		return FALSE
	if(current_system == before)
		nemesis_note_stuck()
		return FALSE
	nemesis_stuck_steps = 0
	if(war_order == HEX_ORDER_HUNT)
		nemesis_hunt_left--
	else if(current_system == home)
		hex_war_set_order(HEX_ORDER_IDLE)
	return TRUE

/// Powrót nie posuwa się naprzód: po HEX_NEMESIS_STUCK_LIMIT próbach boss zostaje tam, gdzie jest, i znów może polować
/// (kroki pościgu nie liczą się tu, bo pościg kończy się sam po nemesis_hunt_steps skokach)
/datum/fleet/proc/nemesis_note_stuck()
	if(war_order != HEX_ORDER_HOME)
		return
	nemesis_stuck_steps++
	if(nemesis_stuck_steps < HEX_NEMESIS_STUCK_LIMIT)
		return
	nemesis_stuck_steps = 0
	hex_war_set_order(HEX_ORDER_IDLE)
	log_game("HEXWAR: nemesis [name] could not get home and waits in [current_system]")

/// Koniec pościgu: boss wraca do swojego układu (bez układu zostaje tam, gdzie jest)
/datum/fleet/proc/nemesis_end_hunt(datum/star_system/home)
	nemesis_hunt_left = 0
	if(!home || home == current_system)
		hex_war_set_order(HEX_ORDER_IDLE)
		return
	hex_war_set_order(HEX_ORDER_HOME, home)
	if(!commander)
		return
	commander.add_history("przerwał pościg")
	log_game("HEXWAR: nemesis [name] gives up the hunt and returns to [home]")
	mini_announce("Wywiad: [commander.rank_name()] [commander.full_name()] przerywa pościg i wraca do układu [home].", "White Rapids EAS")

// ===== tryb trudny =====

/// Trwający cel trybu trudnego „Oczyść Dolos Remnants” w tym układzie: boss nemezis jest jego celem
/proc/hex_nemesis_objective(datum/star_system/S)
	if(!S)
		return
	for(var/datum/overmap_objective/clear_system/dolos/O in SSovermap_mode?.mode?.objectives)
		if(O.instanced && O.status == 0 && O.system_name == S.name) // 0: w toku (STATUS_INPROGRESS z overmap_mode.dm)
			return O

/**
 * Cel trybu trudnego „Oczyść Dolos Remnants” (rubicon.dm, hook AQ EDIT): na mapie hex celem jest boss nemezis tego
 * układu zamiast Pozostałości. Zwraca TRUE, gdy cel ma nie stawiać Pozostałości: boss już stoi albo stanie w układzie
 * przy starcie wojny (setup_nemeses()).
 */
/proc/hex_nemesis_objective_boss(datum/star_system/S)
	if(!GLOB.hexmap?.built || !GLOB.hex_war || !S)
		return FALSE
	for(var/id in GLOB.hex_nemeses)
		if(GLOB.hex_nemeses[id]["home"] != S.name)
			continue
		if(GLOB.hex_war.ready)
			GLOB.hex_war.nemesis_objective_boss(id)
		return TRUE
	return FALSE

/// Boss nemezis układu S żyje i jest poza nim (pościg albo droga powrotna)
/proc/hex_nemesis_boss_away(datum/star_system/S)
	if(!GLOB.hex_war || !S)
		return FALSE
	for(var/datum/hex_commander/C as anything in GLOB.hex_war.commanders)
		if(!C.nemesis || GLOB.hex_nemeses[C.nemesis]?["home"] != S.name)
			continue
		var/datum/fleet/F = C.fleet
		return C.status == HEX_CMD_ACTIVE && F && !QDELETED(F) && F.current_system != S
	return FALSE

// Cel trybu trudnego włączonego w trakcie rundy, gdy boss Dolos ściga okręt: Dolos jest pusty, bo boss dopiero wraca.
// Cel czeka, aż boss stanie w układzie (i zostanie pokonany) albo padnie po drodze.
/datum/overmap_objective/clear_system/dolos/check_completion()
	. = ..()
	if(status == 1 && hex_nemesis_boss_away(target_system))
		status = 0

/// Boss jest celem trybu trudnego: przerywa pościg i wraca, a pod nieobecność rannego albo poległego dowódcy
/// w układzie staje jego flota bez dowódcy, żeby cel miał z kim walczyć
/datum/hex_war/proc/nemesis_objective_boss(id)
	var/list/info = GLOB.hex_nemeses[id]
	var/datum/star_system/home = SSstar_system.system_by_id(info?["home"])
	if(!home)
		return
	var/datum/hex_commander/C = nemesis_commander(id)
	var/datum/fleet/F = C.fleet
	if(C.status == HEX_CMD_ACTIVE && F && !QDELETED(F))
		if(F.war_order == HEX_ORDER_HUNT)
			F.nemesis_end_hunt(home)
		return
	if(hex_nemesis_fleet(home, info["fleet"]))
		return
	home.spawn_fleet(info["fleet"])
