// AQUILA - eventy z kafli mapy hex (raport/ftl_mapa_06_plan_pr.md, PR B).
// Decyzje 14.11:
// - wejście na kafel (przylot okrętu gracza) zawsze odpala jeden event z puli kafla, bez minuty startu eventu, z minimum graczy;
// - okręt stojący na kaflu zagrożenia dostaje kolejny event co 8–12 min, nie bliżej niż 4 min od eventu statkowego,
//   a antagonista wypada najwyżej raz na jeden postój;
// - SSevents losuje już tylko eventy statkowe (środowisko i antagoniści przychodzą z kafli);
// - antagoniści z puli kafla losują się razem z eventami od początku rundy, liczy się tylko minimum graczy eventu
//   (bramkę 60 min i braku żywych antagonistów usunięto 14.11 na prośbę użytkownika).

/// Kiedy SSevents ostatnio losował event statkowy
GLOBAL_VAR_INIT(hex_last_ship_event, 0)

/datum/round_event_control
	/// Event odpalany przez kafel mapy hex: pomija earliest_start, reszta warunków zostaje
	var/hex_triggered = FALSE
	/// Szansa (%), że event z puli kafla w ogóle wejdzie do losowania: rzadkie eventy kafli mają mniej niż 100
	var/hex_pool_chance = 100

/datum/round_event_control/canSpawnEvent(players_amt, gamemode)
	if(!hex_triggered)
		return ..()
	var/saved_start = earliest_start
	earliest_start = -1
	. = ..()
	earliest_start = saved_start

/// Typy eventów z antagonistami midround: pule kafli, oferty trybu weighted i pozostałe eventy z antagonistami
/proc/hex_midround_antag_events()
	var/static/list/antag_types
	if(antag_types)
		return antag_types
	antag_types = list()
	hex_terrain(HEX_TERRAIN_EMPTY)
	for(var/id in GLOB.hex_terrains)
		var/datum/hex_terrain/T = GLOB.hex_terrains[id]
		for(var/entry in T.antags)
			if(ispath(entry))
				antag_types[entry] = TRUE
	var/datum/weighted_ghost_midround/offers = hex_weighted_offers()
	for(var/path in offers.common_events() + offers.medium_events() + offers.heavy_events())
		antag_types[path] = TRUE
	for(var/path in list(
		/datum/round_event_control/ninja,
		/datum/round_event_control/zombie_outbreak,
		/datum/round_event_control/obsessed,
		/datum/round_event_control/wizard/imposter,
		text2path("/datum/round_event_control/nightmare"),
	))
		if(path)
			antag_types[path] = TRUE
	return antag_types

/// Eventy środowiska z pul kafli (SSevents ich już nie losuje)
/proc/hex_tile_environment_events()
	var/static/list/env_types
	if(env_types)
		return env_types
	env_types = list()
	hex_terrain(HEX_TERRAIN_EMPTY)
	for(var/id in GLOB.hex_terrains)
		var/datum/hex_terrain/T = GLOB.hex_terrains[id]
		for(var/path in T.events)
			env_types[path] = TRUE
	// Te są w pulach kafli, ale zdarzają się też jako zwykłe eventy statkowe (decyzja 14.11)
	for(var/path in list(
		/datum/round_event_control/aquila_hex_apc_damage,
		/datum/round_event_control/aquila_hex_sensor_jamming,
		/datum/round_event_control/aquila_hex_gravity_failure,
	))
		env_types -= path
	return env_types

/// Eventy, których na mapie hex nie ma wcale: ani z kafli, ani statkowych (decyzje użytkownika 14.11)
/proc/hex_disabled_events()
	var/static/list/disabled = list(
		/datum/round_event_control/zombie_outbreak = TRUE,
		/datum/round_event_control/floor_cluwne = TRUE,
	)
	return disabled

/// Czy SSevents może wylosować ten event (hook AQ EDIT w spawnEvent())
/proc/hex_random_event_allowed(datum/round_event_control/E)
	var/is_antag = hex_midround_antag_events()[E.type]
	if(!GLOB.hexmap?.built)
		return TRUE
	return !is_antag && !hex_tile_environment_events()[E.type] && !hex_disabled_events()[E.type]

/datum/controller/subsystem/events/spawnEvent()
	. = ..()
	GLOB.hex_last_ship_event = world.time

/// Kontrolka eventu danego typu z SSevents
/proc/hex_event_control(path)
	RETURN_TYPE(/datum/round_event_control)
	for(var/datum/round_event_control/E as anything in SSevents.control)
		if(E.type == path)
			return E

/// Warunki eventu bez minuty startu (decyzja 14.11)
/proc/hex_event_can_spawn(datum/round_event_control/E, players)
	E.hex_triggered = TRUE
	. = E.canSpawnEvent(players, SSticker.mode?.config_tag)
	E.hex_triggered = FALSE

/// Oferty trybu weighted (poza tym trybem osobny obiekt tylko do jego procedur: kandydaci i tworzenie wadliwej SI)
/proc/hex_weighted_offers()
	RETURN_TYPE(/datum/weighted_ghost_midround)
	var/static/datum/weighted_ghost_midround/fallback
	if(GLOB.weighted_rotation?.ghost_midround)
		return GLOB.weighted_rotation.ghost_midround
	if(!fallback)
		fallback = new
	return fallback

/// SI, z których może powstać wadliwa SI (jak w ofertach trybu weighted)
/proc/hex_malf_candidates()
	return hex_weighted_offers().malf_ai_candidates()

/**
 * Losuje event z puli kafla (wszystkie z tą samą szansą, rzadkie tylko z szansą hex_pool_chance na wejście do losowania). Gdy nic z puli nie może wystartować, losuje event statkowy.
 * Zwraca kontrolkę eventu, HEX_POOL_MALF albo nic.
 */
/proc/hex_pick_tile_event(datum/hex/H, allow_antags = TRUE, last_event)
	var/datum/hex_terrain/T = H.pool_terrain()
	var/players = get_active_player_count(alive_check = TRUE, afk_check = TRUE, human_check = TRUE)
	var/list/options = list()
	for(var/path in T?.events)
		var/datum/round_event_control/E = hex_event_control(path)
		if(E && E != last_event && prob(E.hex_pool_chance) && hex_event_can_spawn(E, players))
			options += E
	if(allow_antags)
		for(var/entry in T?.antags)
			if(entry == HEX_POOL_MALF)
				if((GLOB.ghost_role_flags & GHOSTROLE_MIDROUND_EVENT) && length(hex_malf_candidates())) // jak w weighted_ghost_midround
					options += HEX_POOL_MALF
				continue
			var/datum/round_event_control/E = hex_event_control(entry)
			if(E && E != last_event && hex_event_can_spawn(E, players))
				options += E
	if(length(options))
		return pick(options)
	for(var/datum/round_event_control/E as anything in SSevents.control)
		if(E.weight <= 0 || E == last_event || !hex_random_event_allowed(E))
			continue
		if(hex_event_can_spawn(E, players))
			options += E
	if(length(options))
		return pick(options)

/proc/hex_is_antag_entry(entry)
	if(entry == HEX_POOL_MALF)
		return TRUE
	var/datum/round_event_control/E = entry
	return istype(E) && hex_midround_antag_events()[E.type]

/// Odpala wylosowany event kafla (śpi 10 s na ewentualne anulowanie przez admina, jak każdy losowy event)
/proc/hex_run_tile_event(entry, datum/hex/H)
	// Event kafla i event statkowy nie wypadają tuż po sobie
	SSevents.scheduled = max(SSevents.scheduled, world.time + HEX_EVENT_SPACING)
	if(entry == HEX_POOL_MALF)
		hex_weighted_offers().make_malf_ai()
		log_game("HEXMAP: tile [H.id] made a malfunctioning AI")
		return
	var/datum/round_event_control/E = entry
	log_game("HEXMAP: tile [H.id] ([H.pool_terrain()?.id]) triggers [E.name] ([E.type])")
	E.hex_triggered = TRUE
	SSevents.TriggerEvent(E)
	E.hex_triggered = FALSE

/obj/structure/overmap
	/// Ostatni event z kafla (nie powtarza się dwa razy z rzędu)
	var/hex_last_tile_event
	/// Na tym postoju wypadł już antagonista
	var/hex_stay_antag = FALSE
	var/hex_stay_timer
	/// Wylot tunelu: przylot tutaj nie przenosi z powrotem
	var/datum/hex/hex_wormhole_exit

/obj/structure/overmap/jump_end(datum/star_system/target_system, misjump = FALSE)
	. = ..()
	if(role == MAIN_OVERMAP)
		hex_move_escorts(target_system)
		hex_on_arrival(target_system)

/// Przylot okrętu gracza na kafel: event z puli, kolejne przy postoju na zagrożeniu, tunel
/obj/structure/overmap/proc/hex_on_arrival(datum/star_system/S)
	if(hex_stay_timer)
		deltimer(hex_stay_timer)
		hex_stay_timer = null
	if(!GLOB.hexmap?.built || SSticker.current_state != GAME_STATE_PLAYING || SSovermap_mode?.already_ended || ftl_drive?.lockout)
		return
	var/datum/hex/H = GLOB.hexmap.hex_of_system(S)
	if(!H)
		return
	// Wylot z tunelu to dalszy ciąg tego samego wejścia: bez drugiego eventu i bez powrotu tunelem
	var/via_wormhole = (H == hex_wormhole_exit)
	hex_wormhole_exit = null
	if(!via_wormhole)
		hex_stay_antag = FALSE
		hex_fire_tile_event(H, TRUE)
		if(H.terrain == HEX_TERRAIN_WORMHOLE && H.wormhole_pair)
			hex_wormhole_exit = H.wormhole_pair
			addtimer(CALLBACK(src, PROC_REF(hex_wormhole_transit), H), 5 SECONDS)
			return
	if(GLOB.hexmap.stops(H))
		hex_stay_timer = addtimer(CALLBACK(src, PROC_REF(hex_stay_tick), H), rand(HEX_STAY_EVENT_MIN, HEX_STAY_EVENT_MAX), TIMER_STOPPABLE)

/obj/structure/overmap/proc/hex_fire_tile_event(datum/hex/H, allow_antags)
	// Wyłącznik losowych eventów (werb admina, sandbox) dotyczy też eventów z kafli: to one przejęły meteory, burze i antagonistów
	if(!CONFIG_GET(flag/allow_random_events))
		return
	var/entry = hex_pick_tile_event(H, allow_antags && !hex_stay_antag, hex_last_tile_event)
	if(!entry)
		return
	hex_last_tile_event = entry
	if(hex_is_antag_entry(entry))
		hex_stay_antag = TRUE
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(hex_run_tile_event), entry, H)

/// Ile jeszcze czekać, żeby event z postoju nie wypadł tuż przy evencie statkowym
/proc/hex_event_spacing_left()
	. = 0
	if(GLOB.hex_last_ship_event && world.time - GLOB.hex_last_ship_event < HEX_EVENT_SPACING)
		. = HEX_EVENT_SPACING - (world.time - GLOB.hex_last_ship_event)
	var/until_ship_event = SSevents.scheduled - world.time
	if(until_ship_event >= 0 && until_ship_event < HEX_EVENT_SPACING)
		. = max(., until_ship_event + HEX_EVENT_SPACING)

/// Kolejny event, dopóki okręt stoi na kaflu zagrożenia
/obj/structure/overmap/proc/hex_stay_tick(datum/hex/H)
	hex_stay_timer = null
	if(current_hex() != H || !GLOB.hexmap.stops(H) || SSovermap_mode?.already_ended || ftl_drive?.lockout)
		return
	if(SSstar_system.ships[src]?["target_system"] || ftl_drive?.ftl_state == FTL_STATE_JUMPING)
		return
	var/wait = hex_event_spacing_left()
	if(wait > 0)
		hex_stay_timer = addtimer(CALLBACK(src, PROC_REF(hex_stay_tick), H), wait, TIMER_STOPPABLE)
		return
	hex_fire_tile_event(H, TRUE)
	hex_stay_timer = addtimer(CALLBACK(src, PROC_REF(hex_stay_tick), H), rand(HEX_STAY_EVENT_MIN, HEX_STAY_EVENT_MAX), TIMER_STOPPABLE)
