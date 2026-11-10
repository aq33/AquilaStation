/// AQUILA - AI battle sandbox, a debug build only (dm.exe -DCBT -DAQ_AI_SANDBOX). Starts a round with nobody on it,
/// puts a Syndicate fleet against the main ship and two Nanotrasen AI frigates, keeps an allied Syndicate fleet one jump away
/// for distress calls, fires the main ship's guns on a script, and records every ship (position, hull, fear, goal, target) every 2 s.
/// The record goes to data/ai_sandbox.json, then the world shuts down. Nothing here is compiled into a normal build.
/// Dream Daemon -params: ai_sandbox_out=<file>, ai_sandbox_nt=<NT fleet size>, ai_sandbox_syn=<Syndicate fleet size>, ai_sandbox_gap=<tiles between the fleets>,
/// ai_sandbox_nt_type=<fleet path>, ai_sandbox_syn_type=<fleet path> (default /datum/fleet/nanotrasen and /datum/fleet),
/// ai_sandbox_legacy=1 (the old game: sensor signatures, overmap scale and AI morale all switched off, for before/after comparisons),
/// ai_sandbox_no_sensors=1 (sensor signatures off), ai_sandbox_no_suites=1 (AI sensor suites off), ai_sandbox_no_sensor_tactics=1 (AI stops using them),
/// ai_sandbox_no_picture / _no_picket / _no_triangulation / _no_ambush =1 (single fleet behaviours off), ai_sandbox_only=<picture|picket|triangulation|ambush|formation> (leave just one of them on),
/// ai_sandbox_fair=1 (the main ship sits out: it does not fire and the AI ignores it, so neither side gets a free invulnerable ally)
#ifdef AQ_AI_SANDBOX

#define AI_SANDBOX_LENGTH (8 MINUTES)
/// Fleet difficulty: destroyers = size / 2, battleships and supply ships = size / 4 each
#define AI_SANDBOX_FLEET_SIZE 8
#define AI_SANDBOX_HELP_SIZE 4
/// Default gap between recorded frames; positions go down this often, so playback is not a slideshow
#define AI_SANDBOX_STEP (0.5 SECONDS)
/// Every this many frames the whole state is written (contacts, sensor ranges, tactic, names);
/// in between only what moves, so the recording stays about the size it was at 2 s per frame
#define AI_SANDBOX_FULL_EVERY 4
#define AI_SANDBOX_GUN_TIME (6 SECONDS)
#define AI_SANDBOX_OUTPUT "data/ai_sandbox.json"

GLOBAL_DATUM(ai_sandbox, /datum/ai_sandbox)

/world/New()
	. = ..()
	Master.sleep_offline_after_initializations = FALSE
	SSticker.start_immediately = TRUE
	SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_addtimer), CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(start_ai_sandbox)), 10 SECONDS))

/proc/start_ai_sandbox()
	GLOB.ai_sandbox = new /datum/ai_sandbox
	GLOB.ai_sandbox.start()

/datum/ai_sandbox
	var/obj/structure/overmap/main
	var/datum/star_system/system
	var/datum/fleet/enemy_fleet
	var/datum/fleet/friendly_fleet
	var/start_time
	var/next_gun = 0
	var/output_file = AI_SANDBOX_OUTPUT
	/// The main ship sits out of the fight
	var/fair = FALSE
	/// list of snapshots: list("t" = seconds, "ships" = list(...))
	var/list/frames = list()
	/// list of list("t", "text")
	var/list/events = list()

/datum/ai_sandbox
	/// Torpedo tactics comparison (ai_torpedo_tactics.dm): torpedoes fired, torpedoes that reached a ship, dodges started
	var/list/torpedo_stats = list("fired" = 0, "hit" = 0)
	/// list of list("t", "id", "name", "faction", "range", "heard"): radar pulses over time
	var/list/pulses = list()
	/// ship ref => world.time of the pulse already written to pulses
	var/list/seen_pulses = list()
	/// Deciseconds between frames, from ai_sandbox_step
	var/step = AI_SANDBOX_STEP
	/// Counts frames, so every AI_SANDBOX_FULL_EVERY-th one carries the whole state
	var/frame_number = 0

/datum/ai_sandbox/proc/event(text)
	events += list(list("t" = round((world.time - start_time) / 10, 0.1), "text" = text))
	log_world("AI SANDBOX: [text]")

/datum/ai_sandbox/proc/start()
	start_time = world.time
	if(world.params["ai_sandbox_out"])
		output_file = world.params["ai_sandbox_out"]
	fair = text2num(world.params["ai_sandbox_fair"]) ? TRUE : FALSE
	if(text2num(world.params["ai_sandbox_legacy"]))
		GLOB.sensor_signature_enabled = FALSE
		GLOB.overmap_scale_enabled = FALSE
		GLOB.ai_morale_enabled = FALSE
		GLOB.ai_sensor_suites_enabled = FALSE
		GLOB.ai_sensor_tactics_enabled = FALSE
		GLOB.ai_fleet_picture_enabled = FALSE
		GLOB.ai_picket_enabled = FALSE
		GLOB.ai_triangulation_enabled = FALSE
		GLOB.ai_ambush_enabled = FALSE
		GLOB.ai_formation_enabled = FALSE
		event("Tryb starej gry: sygnatury, sensory AI, skala overmapy i morale AI wyłączone")
	if(text2num(world.params["ai_sandbox_no_suites"]))
		GLOB.ai_sensor_suites_enabled = FALSE
		event("Zestawy sensorów AI wyłączone")
	if(text2num(world.params["ai_sandbox_no_sensor_tactics"]))
		GLOB.ai_sensor_tactics_enabled = FALSE
		event("Taktyki sensorowe AI wyłączone")
	// Pola widzenia sensorów (ai_sensor_suites.dm): osobno, bo to cecha sensorów, nie zachowanie floty
	if(text2num(world.params["ai_sandbox_no_cones"]))
		GLOB.ai_sensor_cones_enabled = FALSE
		event("Stożki sensorów wyłączone: wszystkie sensory widzą dookoła")
	// Pojedyncze zachowania floty (ai_fleet_picture.dm), żeby dało się pokazać każde osobno
	var/static/list/przelaczniki = list(
		"picture" = "ai_fleet_picture_enabled",
		"picket" = "ai_picket_enabled",
		"triangulation" = "ai_triangulation_enabled",
		"ambush" = "ai_ambush_enabled",
		"formation" = "ai_formation_enabled",
	)
	for(var/nazwa in przelaczniki)
		if(text2num(world.params["ai_sandbox_no_[nazwa]"]))
			GLOB.vars[przelaczniki[nazwa]] = FALSE
			event("Wyłączone: [nazwa]")
	var/tylko = world.params["ai_sandbox_only"]
	if(tylko)
		if(!przelaczniki[tylko])
			event("Nieznana nazwa w ai_sandbox_only: [tylko]")
		else
			for(var/nazwa in przelaczniki)
				if(nazwa != tylko)
					GLOB.vars[przelaczniki[nazwa]] = FALSE
			event("Z zachowań floty zostaje tylko: [tylko]")
	if(text2num(world.params["ai_sandbox_no_sensors"]))
		GLOB.sensor_signature_enabled = FALSE
		event("Sygnatury okrętów wyłączone")
	main = SSstar_system.find_main_overmap()
	system = main?.current_system
	if(!system?.occupying_z || !main.z)
		event("Brak okrętu głównego w załadowanym systemie, koniec.")
		finish()
		return
	var/nt_size = text2num(world.params["ai_sandbox_nt"]) || AI_SANDBOX_FLEET_SIZE
	var/syn_size = text2num(world.params["ai_sandbox_syn"]) || AI_SANDBOX_FLEET_SIZE
	var/gap = text2num(world.params["ai_sandbox_gap"]) || 58
	step = text2num(world.params["ai_sandbox_step"]) || AI_SANDBOX_STEP
	event("System [system], okręt główny [main] na [main.x],[main.y]; floty NT [nt_size], Syndykat [syn_size], odstęp [gap] pól[fair ? ", okręt główny poza walką" : ""]")
	if(fair)
		main.essential = TRUE // AI targeting skips essential ships
	// Two full fleets: Nanotrasen next to the main ship, the Syndicate gap tiles further out
	var/nt_type = text2path(world.params["ai_sandbox_nt_type"])
	var/syn_type = text2path(world.params["ai_sandbox_syn_type"])
	if(!ispath(nt_type, /datum/fleet))
		nt_type = /datum/fleet/nanotrasen
	if(!ispath(syn_type, /datum/fleet))
		syn_type = /datum/fleet
	event("Typy flot: [nt_type] kontra [syn_type]")
	friendly_fleet = spawn_fleet(nt_type, system, nt_size, "Flota Nanotrasen", 12)
	enemy_fleet = spawn_fleet(syn_type, system, syn_size, "Flota Syndykatu", 12 + gap)
	// Flota syndykatu jako obronna, do pokazania zasadzki (ai_fleet_picture.dm);
	// pewniejsze niż podawanie typu floty, bo nie zależy od text2path na parametrze
	if(text2num(world.params["ai_sandbox_defense"]) && enemy_fleet)
		enemy_fleet.fleet_trait = FLEET_TRAIT_DEFENSE
		event("Flota Syndykatu przestawiona na obronną (zasadzka)")
	// One help fleet for each side, in two different systems next door
	var/list/neighbours = list()
	for(var/system_name in system.adjacency_list)
		var/datum/star_system/next = SSstar_system.system_by_id(system_name)
		if(next && !next.hidden && !next.occupying_z)
			neighbours += next
	if(length(neighbours))
		spawn_fleet(/datum/fleet, neighbours[1], AI_SANDBOX_HELP_SIZE, "Syndykacka flota wsparcia")
		spawn_fleet(/datum/fleet/nanotrasen, neighbours[min(2, length(neighbours))], AI_SANDBOX_HELP_SIZE, "Flota wsparcia Nanotrasen")
	tick()

/// A fleet of fleet_type assembled in where; in the battle system its ships are lined up offset tiles east of the main ship
/datum/ai_sandbox/proc/spawn_fleet(fleet_type, datum/star_system/where, size, fleet_name, offset)
	var/datum/fleet/new_fleet = new fleet_type
	new_fleet.name = fleet_name
	where.fleets += new_fleet
	new_fleet.current_system = where
	new_fleet.assemble(where, size)
	if(where == system)
		var/n = 0
		for(var/obj/structure/overmap/OM as anything in new_fleet.all_ships)
			n++
			OM.forceMove(locate(WRAP(main.x + offset + (n % 2) * 6, 1, world.maxx + 1), clamp(main.y + (n - length(new_fleet.all_ships) / 2) * 7, 20, world.maxy - 20), main.z))
	event("[fleet_name] w systemie [where]: [length(new_fleet.all_ships)] okrętów")
	return new_fleet

/datum/ai_sandbox/proc/tick()
	if(world.time > start_time + AI_SANDBOX_LENGTH)
		finish()
		return
	if(!QDELETED(main))
		main.obj_integrity = main.max_integrity // The main ship is only a target and a gun platform here
		if(!fair && world.time >= next_gun)
			next_gun = world.time + AI_SANDBOX_GUN_TIME
			script_fire()
	record()
	addtimer(CALLBACK(src, PROC_REF(tick)), step)

/// The "player" gunner: missiles at range, railgun up close, at the nearest Syndicate ship
/datum/ai_sandbox/proc/script_fire()
	var/obj/structure/overmap/best
	var/best_dist = INFINITY
	for(var/obj/structure/overmap/OM as anything in system.system_contents)
		if(!istype(OM) || OM.z != main.z || OM.faction != "syndicate" || QDELETED(OM))
			continue
		var/dist = overmap_dist(main, OM)
		if(dist < best_dist)
			best_dist = dist
			best = OM
	if(!best || best_dist > 60)
		return
	if(best_dist > 25)
		main.fire_projectile(/obj/item/projectile/guided_munition/missile, best)
	else
		main.fire_projectile(/obj/item/projectile/bullet/railgun_slug, best)

/// Every radar pulse since the last frame, with the ships that heard it (radar_emission.dm)
/datum/ai_sandbox/proc/record_pulses(list/present)
	for(var/obj/structure/overmap/OM as anything in present)
		if(!OM.last_radar_pulse || OM.last_radar_pulse <= seen_pulses["\ref[OM]"])
			continue
		seen_pulses["\ref[OM]"] = OM.last_radar_pulse
		var/list/heard = list()
		for(var/obj/structure/overmap/listener as anything in present)
			if(listener == OM || !listener.get_radar_emission(OM))
				continue
			heard += "\ref[listener]"
		pulses += list(list(
			"t" = round((world.time - start_time) / 10, 0.1),
			"id" = "\ref[OM]",
			"name" = "[OM]",
			"faction" = OM.faction,
			"range" = round(OM.max_tracking_range),
			"heard" = heard,
		))

/datum/ai_sandbox/proc/record()
	var/list/ships = list()
	var/list/present = list()
	var/full = !(frame_number % AI_SANDBOX_FULL_EVERY)
	frame_number++
	for(var/obj/structure/overmap/OM as anything in system.system_contents)
		if(!istype(OM) || QDELETED(OM) || OM.z != main.z || istype(OM, /obj/structure/overmap/asteroid))
			continue
		present += OM
		var/obj/structure/overmap/target = OM.last_target
		// Which sensor holds which contact, and how far this ship could see its reference enemy with each of them.
		// The suite ranges depend on what the TARGET is doing, so they are recorded against one named enemy, not in the abstract.
		var/list/contacts = full ? list() : null
		for(var/obj/structure/overmap/seen as anything in (full ? OM.sensor_contact_suites : null))
			if(QDELETED(seen))
				continue
			contacts += list(list("id" = "\ref[seen]", "s" = OM.sensor_contact_suites[seen]))
		var/list/ranges = null
		var/obj/structure/overmap/reference = (istype(target) && target.faction != OM.faction) ? target : OM.get_ai_nearest_threat()
		if(full && istype(reference) && OM.ai_controlled)
			ranges = list(
				"id" = "\ref[reference]",
				"name" = "[reference]",
				"opt" = round(OM.get_suite_range(SENSOR_OPTICAL, reference), 0.1),
				// Teleskop: jak daleko sięga stożek (bez sprawdzania, czy cel w nim jest), żeby odtwarzacz narysował jego długość
				"tel" = (SENSOR_TELESCOPE in OM.get_sensor_suites()) && GLOB.ai_sensor_cones_enabled ? round(OM.get_telescope_reach(reference), 0.1) : 0,
				"ir" = round(OM.get_suite_range(SENSOR_INFRARED, reference), 0.1),
				"lid" = round(OM.get_suite_range(SENSOR_LIDAR, reference), 0.1),
			)
		var/turf/search_at = (full && OM.ai_search_target) ? OM.patrol_target : null
		// Lekka klatka: tylko to, co sie rusza. Reszte odtwarzacz bierze z ostatniej pelnej klatki.
		var/list/wpis = list(
			"id" = "\ref[OM]",
			"x" = round(OM.x + OM.offset?.a, 0.1),
			"y" = round(OM.y + OM.offset?.e, 0.1),
			"angle" = round(OM.angle),
			"hull" = OM.max_integrity ? round(OM.obj_integrity / OM.max_integrity * 100) : 100,
			"fear" = round(OM.ai_fear),
			"fleeing" = OM.ai_fleeing,
			"silent" = OM.ai_running_silent,
		)
		if(!full)
			ships += list(wpis)
			continue
		// Stożki sensorów (ai_sensor_suites.dm): gdzie patrzy teleskop i czy własny napęd oślepia termikę za rufą
		var/list/stozki = null
		if(OM.ai_controlled && GLOB.ai_sensor_cones_enabled)
			stozki = list(
				"tb" = (SENSOR_TELESCOPE in OM.get_sensor_suites()) ? round(OM.get_telescope_bearing()) : null,
				"irb" = OM.is_infrared_rear_blind() ? 1 : 0,
			)
		ships += list(wpis + list(
			"cones" = stozki,
			"name" = "[OM]",
			"faction" = OM.faction,
			"fleet" = OM.fleet?.name,
			"temperament" = OM.ai_temperament,
			"goal" = OM.current_goal?.name,
			"target" = istype(target) ? "\ref[target]" : null,
			"tiny" = OM.mass <= MASS_TINY,
			"main" = OM == main,
			// Sensors (ai_sensor_suites.dm) and what the ship is doing with them (ai_sensor_use.dm)
			"tactic" = OM.ai_tactic,
			"picket" = OM.fleet?.ai_picket == OM,
			"wait" = OM.is_ai_lying_in_wait(),
			"sig" = round(OM.sensor_signature, 0.01),
			"heat" = round(OM.get_signature_heat(), 0.01),
			"size" = round(OM.get_signature_size(), 0.01),
			"cts" = contacts,
			"rng" = ranges,
			"sx" = search_at ? search_at.x : null,
			"sy" = search_at ? search_at.y : null,
		))
	record_pulses(present)
	frames += list(list("t" = round((world.time - start_time) / 10, 0.1), "full" = full, "ships" = ships))

/datum/ai_sandbox/proc/finish()
	event("Koniec nagrania")
	var/list/out = list("system" = "[system]", "map" = list(world.maxx, world.maxy), "events" = events, "frames" = frames, "torpedoes" = torpedo_stats, "pulses" = pulses,
		"cones" = list("tel_half" = TELESCOPE_HALF_ANGLE, "ir_blind_half" = INFRARED_BLIND_HALF_ANGLE, "enabled" = GLOB.ai_sensor_cones_enabled))
	rustg_file_write(json_encode(out), output_file)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(end_ai_sandbox)), 1 SECONDS)

/proc/end_ai_sandbox()
	del(world)

/// Bridge warnings are what the players would read: put them in the record too
/datum/star_system/warn_player_ships(message)
	GLOB.ai_sandbox?.event("[name]: [message]")
	return ..()

/datum/fleet/note_ai_fleet_event(text)
	GLOB.ai_sandbox?.event("[name]: [text]")
	return ..()

/obj/structure/overmap/announce_ai_escape(message)
	GLOB.ai_sandbox?.event(message)
	return ..()

/obj/structure/overmap/fire_projectile(proj_type, atom/target, pixel_speed = null, user_override = null, firing_flags = NONE, ai_aim = FALSE, miss_chance = 5, max_miss_distance = 5, spread_override = null, projectile_speed = null)
	. = ..()
	if(GLOB.ai_sandbox && istype(., /obj/item/projectile/guided_munition/torpedo))
		GLOB.ai_sandbox.torpedo_stats["fired"]++

/obj/structure/overmap/bullet_act(obj/item/projectile/P)
	if(GLOB.ai_sandbox && istype(P, /obj/item/projectile/guided_munition/torpedo))
		GLOB.ai_sandbox.torpedo_stats["hit"]++
	return ..()

/obj/structure/overmap/start_ai_flight()
	GLOB.ai_sandbox?.event("[src] ([ai_temperament], strach [round(ai_fear)]) przerywa walkę i ucieka")
	return ..()

/obj/structure/overmap/Destroy()
	if(GLOB.ai_sandbox && current_system && z && !ai_escaped && mass > MASS_TINY)
		GLOB.ai_sandbox.event("[src] zniszczony")
	return ..()

#undef AI_SANDBOX_LENGTH
#undef AI_SANDBOX_FLEET_SIZE
#undef AI_SANDBOX_HELP_SIZE
#undef AI_SANDBOX_STEP
#undef AI_SANDBOX_FULL_EVERY
#undef AI_SANDBOX_GUN_TIME
#undef AI_SANDBOX_OUTPUT

#endif
