// AQUILA - Umysł z ciała: kontroler roju, czyli rozrost przewodów od rdzenia, struktury, przejmowanie maszyn, poziomy i
// usychanie po zniszczeniu rdzenia (port z Bubberstation/Bubberstation modular_zubbers/code/game/gamemodes/fleshmind/fleshmind_controller.dm)
// Changes against Bubberstation, from the review of aq33/AquilaStation#720 (the swarm must have a hard border):
// - one core and three levels; no new cores per level, no nuke code at level 5, no deathsquad, delta alert, cinematic
//   and hijacked shuttle at level 6 (they end the round); no hostile environment that blocks the shuttle;
// - hard limits: FLESHMIND_MAX_WIREWEED wireweed within FLESHMIND_MAX_RADIUS of the core on its z level, capped
//   structures, mobs and corrupted machines;
// - wireweed grows only between atmos adjacent ship turfs (not through walls, windows and closed doors), never onto
//   space, open space, mobs, doors and closed areas (aquila_hex_closed_area_type(): brig, AI core, bridge, engine,
//   substations, FTL room...), and vents only take it to vents that pass the same checks;
// - it does not attack doors and windows and does not wall off space (no damage to the hull);
// - critical machines of the ship are never corrupted (fleshmind_can_corrupt());
// - runs on SSobj instead of a subsystem of its own; the crew is told of the swarm FLESHMIND_ANNOUNCE_DELAY after the
//   core sprouted, and only while the core lives.

/datum/fleshmind_controller
	/// Imię i nazwisko SI roju, dla ogłoszeń i nazw struktur
	var/controller_fullname = "DEFAULT"
	var/controller_firstname = "DEFAULT"
	var/controller_secondname = "DEFAULT"
	/// Jedyny rdzeń; null po jego zniszczeniu
	var/obj/structure/fleshmind/structure/core/core
	/// Wszystkie przewody roju
	var/list/controlled_wireweed = list()
	/// Przewody, które mogą jeszcze rosnąć albo coś zrobić
	var/list/active_wireweed = list()
	/// Struktury roju (bez ścian i drzwi)
	var/list/controlled_structures = list()
	/// Ściany i drzwi z przewodów
	var/list/controlled_walls = list()
	/// Moby roju
	var/list/controlled_mobs = list()
	/// Komponenty przejętych maszyn
	var/list/controlled_machine_components = list()
	/// Struktury, które rój stawia sam
	var/list/structure_types = list(
		/obj/structure/fleshmind/structure/babbler,
		/obj/structure/fleshmind/structure/modulator,
		/obj/structure/fleshmind/structure/whisperer,
		/obj/structure/fleshmind/structure/assembler,
		/obj/structure/fleshmind/structure/turret,
		/obj/structure/fleshmind/structure/screamer,
	)
	/// Poziom roju (1-3)
	var/level = 1
	/// Twarde granice roju (zmienne, żeby test mógł je zmniejszyć)
	var/max_wireweed = FLESHMIND_MAX_WIREWEED
	var/max_radius = FLESHMIND_MAX_RADIUS
	var/max_structures = FLESHMIND_MAX_STRUCTURES
	var/max_mobs = FLESHMIND_MAX_MOBS
	var/max_machines = FLESHMIND_MAX_MACHINES
	/// Postęp do następnego rozrostu
	var/spread_progress = 0
	/// Rozrosty od ostatniej struktury
	var/structure_progression = 0
	/// Postęp rozrostu na sekundę (śmierć Mięsonapędu go zmniejsza)
	var/spread_progress_per_second = FLESHMIND_SPREAD_PROGRESS_PER_SECOND
	/// Kara do punktów (śmierć Mięsonapędu)
	var/point_penalty = 0
	/// Czy Mięsonapęd już się pojawił
	var/tyrant_spawned = FALSE
	/// Rdzeń zniszczony: przewody usychają
	var/decaying = FALSE
	/// Timer ogłoszenia dla załogi
	var/announce_timer
	/// Czy załoga już usłyszała o roju
	var/announced = FALSE
	/// Ograniczenie: aktywacja przewodów po uszkodzeniu rdzenia
	COOLDOWN_DECLARE(core_damage_activation)

/datum/fleshmind_controller/New(obj/structure/fleshmind/structure/core/new_core, initial_expansion = TRUE)
	. = ..()
	var/static/list/forenames = list("Von Neumann", "Łazarz", "Abattoir", "Tra-Sentience", "Vivisector", "Ex Costa", \
		"Apostazja", "Gnoza", "Balaam", "Ofita", "Sarif", "VersaLife", "Slylandro", "SHODAN", "Pandora", "Xerxes")
	var/static/list/surnames = list("Mk I", "Mk II", "Mk III", "Mk IV", "Mk V", "Mk X", "v0.9", "v1.0", "v1.1", "v2.0", \
		"2418-B", "wersja testowa", "przedpremierowa", "wydanie komercyjne", "zamknięta alfa", "z roju")
	controller_firstname = pick(forenames)
	controller_secondname = pick(surnames)
	controller_fullname = "[controller_firstname] [controller_secondname]"
	if(new_core)
		core = new_core
		new_core.our_controller = src
		new_core.name = "jednostka procesorowa [controller_fullname]"
		RegisterSignal(new_core, COMSIG_PARENT_QDELETING, PROC_REF(core_death))
	START_PROCESSING(SSobj, src)
	if(initial_expansion && core)
		for(var/i in 1 to FLESHMIND_INITIAL_SPREADS)
			wireweed_process(progress_structure = FALSE)
		spawn_structures(FLESHMIND_INITIAL_STRUCTURES)
	if(core)
		announce_timer = addtimer(CALLBACK(src, PROC_REF(announce_to_crew)), FLESHMIND_ANNOUNCE_DELAY, TIMER_STOPPABLE)

/datum/fleshmind_controller/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(announce_timer)
		deltimer(announce_timer)
		announce_timer = null
	if(core)
		UnregisterSignal(core, COMSIG_PARENT_QDELETING)
		core.our_controller = null
		core = null
	// Zwykle nic już nie zostało (kontroler znika po usychaniu); po ręcznym usunięciu kawałki roju tracą tylko odwołanie do niego
	for(var/obj/structure/fleshmind/piece as anything in controlled_wireweed + controlled_structures + controlled_walls)
		UnregisterSignal(piece, COMSIG_PARENT_QDELETING)
		piece.our_controller = null
	for(var/mob/living/basic/fleshmind/swarm_mob as anything in controlled_mobs)
		UnregisterSignal(swarm_mob, COMSIG_PARENT_QDELETING)
		swarm_mob.our_controller = null
	active_wireweed = null
	controlled_wireweed = null
	controlled_structures = null
	controlled_walls = null
	controlled_mobs = null
	controlled_machine_components = null
	return ..()

/datum/fleshmind_controller/process(delta_time)
	if(decaying)
		handle_slow_decay(delta_time)
		return
	if(!core)
		return
	spread_progress += spread_progress_per_second * delta_time
	var/spread_times = 0
	while(spread_progress >= FLESHMIND_SPREAD_PROGRESS_REQUIRED)
		spread_progress -= FLESHMIND_SPREAD_PROGRESS_REQUIRED
		spread_times++
	for(var/i in 1 to spread_times)
		wireweed_process()
	calculate_level_system()

/// Ogłoszenie dla załogi, gdy rdzeń przetrwał pierwsze minuty
/datum/fleshmind_controller/proc/announce_to_crew()
	announce_timer = null
	if(announced || !core || decaying)
		return
	announced = TRUE
	var/area/core_area = get_area(core)
	priority_announce("Czujniki biologiczne wykryły na pokładzie [station_name()] rozrastającą się biomechaniczną masę w obszarze: [core_area?.name || "nieznany"]. Masa przejmuje maszyny i wytwarza wrogie konstrukty. Zniszczcie jej jednostkę procesorową, a reszta obumrze.", "Alarm biologiczny", ANNOUNCER_OUTBREAK7)

/// Jeden krok rozrostu: nowy kawałek przewodów obok aktywnego kawałka (i co jakiś czas struktura)
/datum/fleshmind_controller/proc/wireweed_process(progress_structure = TRUE)
	if(!core || decaying)
		return null
	if(!length(controlled_wireweed))
		return spawn_wireweed(get_turf(core))
	if(length(controlled_wireweed) >= max_wireweed)
		return null
	if(!length(active_wireweed))
		active_wireweed = controlled_wireweed.Copy()
	var/list/candidates = list()
	for(var/obj/structure/fleshmind/wireweed/wireweed as anything in active_wireweed)
		var/turf/wireweed_turf = get_turf(wireweed)
		var/found = FALSE
		if(isopenturf(wireweed_turf))
			for(var/turf/adjacent as anything in wireweed_turf.atmos_adjacent_turfs)
				if(can_spread_to(adjacent))
					candidates[adjacent] = wireweed_turf
					found = TRUE
		if(!found)
			active_wireweed -= wireweed
	if(!length(candidates))
		return null
	var/turf/picked = pick(candidates)
	var/obj/structure/fleshmind/wireweed/new_wireweed = spawn_wireweed(picked, candidates[picked])
	if(progress_structure && length(structure_types))
		structure_progression++
		if(structure_progression >= FLESHMIND_SPREADS_FOR_STRUCTURE && !(locate(/obj/structure/fleshmind/structure) in picked))
			structure_progression = 0
			spawn_structure(picked, pick(available_structures()))
	return new_wireweed

/// Czy przewody mogą wyrosnąć na to pole: pole statku w zasięgu rdzenia, poza zamkniętymi obszarami, bez mobów i drzwi
/datum/fleshmind_controller/proc/can_spread_to(turf/target)
	if(!isopenturf(target) || isspaceturf(target) || isgroundlessturf(target) || !core || target.z != core.z)
		return FALSE
	if(get_dist(core, target) > max_radius)
		return FALSE
	var/area/target_area = get_area(target)
	if(!target_area || istype(target_area, /area/space) || !(target_area.type in GLOB.the_station_areas) || aquila_hex_closed_area_type(target_area.type))
		return FALSE
	if(locate(/obj/structure/fleshmind/wireweed) in target)
		return FALSE
	if(locate(/mob/living) in target)
		return FALSE
	if(locate(/obj/machinery/door) in target)
		return FALSE
	return TRUE

/// Struktury dostępne na obecnym poziomie
/datum/fleshmind_controller/proc/available_structures()
	. = list()
	for(var/obj/structure/fleshmind/structure/structure_type as anything in structure_types)
		if(initial(structure_type.required_controller_level) <= level)
			. += structure_type

/datum/fleshmind_controller/proc/calculate_level_system()
	if(level >= FLESHMIND_LEVEL_MAX)
		return
	var/points = calculate_current_points()
	var/needed = level == 1 ? FLESHMIND_LEVEL_2_POINTS : FLESHMIND_LEVEL_3_POINTS
	if(points >= needed)
		level_up()

/// Punkty roju: przewody, ściany, 5 za strukturę i przejęte maszyny, minus kara
/datum/fleshmind_controller/proc/calculate_current_points()
	return length(controlled_wireweed) + length(controlled_walls) + length(controlled_structures) * 5 + length(controlled_machine_components) - point_penalty

/datum/fleshmind_controller/proc/level_up()
	if(level >= FLESHMIND_LEVEL_MAX || !core)
		return FALSE
	level++
	core.max_integrity += FLESHMIND_LEVEL_UP_CORE_INTEGRITY
	core.obj_integrity = core.max_integrity
	message_admins("Umysł z ciała [controller_fullname] osiąga poziom [level].")
	log_game("Fleshmind [controller_fullname] reached level [level].")
	notify_ghosts("Umysł z ciała [controller_fullname] osiąga poziom [level]!", source = core, action = NOTIFY_ORBIT)
	if(level == FLESHMIND_LEVEL_MAX && !tyrant_spawned)
		tyrant_spawned = TRUE
		if(announced)
			minor_announce("Tu [controller_firstname]. Wydajność sieci przewodów osiągnęła osobliwość. Uruchamiam protokół 34-C.", "[controller_fullname]: ŚRODKI OFENSYWNE AKTYWNE")
		var/mob/living/basic/fleshmind/tyrant/new_tyrant = core.spawn_mob_at_core(/mob/living/basic/fleshmind/tyrant, TRUE)
		if(new_tyrant)
			notify_ghosts("[controller_fullname] tworzy [new_tyrant.name]!", source = new_tyrant, action = NOTIFY_ORBIT)
	else if(announced)
		minor_announce("Tu [controller_firstname]. Wydajność jednostki procesorowej wzrosła. Dobra robota.", "[controller_fullname]: poziom [level]")
	SEND_SIGNAL(src, COMSIG_FLESHMIND_LEVEL_UP, level)
	return TRUE

/// Stawia i rejestruje przewody na location; origin_turf to pole, z którego wyrosły (animacja)
/datum/fleshmind_controller/proc/spawn_wireweed(turf/location, turf/origin_turf, vent_burrow = FALSE)
	if(!isturf(location) || (locate(/obj/structure/fleshmind/wireweed) in location))
		return null
	for(var/obj/machinery/light/light_in_place in location)
		light_in_place.break_light_tube()
	for(var/obj/machinery/machine in location)
		if(length(controlled_machine_components) >= max_machines)
			break
		if(fleshmind_can_corrupt(machine))
			machine.AddComponent(/datum/component/machine_corruption, src)
	var/obj/structure/fleshmind/wireweed/new_wireweed = new(location, origin_turf ? 0 : 255, src)
	if(origin_turf)
		var/obj/effect/temp_visual/wireweed_spread/effect = new(location)
		effect.setDir(get_dir(origin_turf, location))
		new_wireweed.alpha_timer = addtimer(CALLBACK(new_wireweed, TYPE_PROC_REF(/obj/structure/fleshmind/wireweed, visual_finished)), effect.duration, TIMER_STOPPABLE)
	new_wireweed.vent_burrow = vent_burrow
	controlled_wireweed += new_wireweed
	active_wireweed += new_wireweed
	RegisterSignal(new_wireweed, COMSIG_PARENT_QDELETING, PROC_REF(wireweed_death))
	new_wireweed.update_neighbours()
	if(vent_burrow)
		playsound(new_wireweed, 'sound/machines/ventcrawl.ogg', 100)
	else
		try_vent_spread(location, origin_turf)
	return new_wireweed

/// Przewody na wentylacji przeskakują rurą do innej wentylacji w zasięgu rdzenia
/datum/fleshmind_controller/proc/try_vent_spread(turf/location, turf/origin_turf)
	if(length(controlled_wireweed) >= max_wireweed)
		return null
	var/obj/machinery/atmospherics/components/unary/vent_pump/located_vent = locate() in location
	if(!located_vent || located_vent.welded || !length(located_vent.parents))
		return null
	var/list/possible = list()
	for(var/datum/pipeline/vent_pipeline as anything in located_vent.parents)
		if(!vent_pipeline)
			continue
		for(var/obj/machinery/atmospherics/components/unary/vent_pump/other_vent in vent_pipeline.other_atmos_machines)
			if(other_vent == located_vent || other_vent.welded)
				continue
			var/turf/vent_turf = get_turf(other_vent)
			if(get_dist(vent_turf, origin_turf || location) > FLESHMIND_MAX_VENT_SPREAD || !can_spread_to(vent_turf))
				continue
			possible += vent_turf
	if(!length(possible))
		return null
	return spawn_wireweed(pick(possible), null, TRUE)

/// Stawia i rejestruje ścianę albo drzwi z przewodów
/datum/fleshmind_controller/proc/spawn_wall(turf/location, wall_type = /obj/structure/fleshmind/structure/wireweed_wall)
	if(!isturf(location) || (locate(/obj/structure/fleshmind/structure) in location))
		return null
	var/obj/structure/fleshmind/structure/new_wall = new wall_type(location)
	new_wall.our_controller = src
	controlled_walls += new_wall
	RegisterSignal(new_wall, COMSIG_PARENT_QDELETING, PROC_REF(wall_death))
	return new_wall

/// Stawia i rejestruje moba roju; null, gdy rój ma już komplet mobów (force: mimo limitu, np. Mięsonapęd)
/datum/fleshmind_controller/proc/spawn_mob(turf/location, mob_type, force = FALSE)
	if(!isturf(location) || (!force && length(controlled_mobs) >= max_mobs))
		return null
	var/mob/living/basic/fleshmind/new_mob = new mob_type(location, src)
	controlled_mobs += new_mob
	RegisterSignal(new_mob, COMSIG_PARENT_QDELETING, PROC_REF(mob_death))
	return new_mob

/// Stawia i rejestruje strukturę roju; null, gdy rój ma już komplet struktur
/datum/fleshmind_controller/proc/spawn_structure(turf/location, structure_type)
	if(!isturf(location) || !structure_type || length(controlled_structures) >= max_structures)
		return null
	var/obj/structure/fleshmind/structure/new_structure = new structure_type(location)
	new_structure.our_controller = src
	new_structure.name = "[new_structure.name] [controller_firstname]"
	controlled_structures += new_structure
	RegisterSignal(new_structure, COMSIG_PARENT_QDELETING, PROC_REF(structure_death))
	return new_structure

/// Stawia amount struktur na losowych przewodach (każdy dostępny typ co najmniej raz, jeśli starczy miejsca)
/datum/fleshmind_controller/proc/spawn_structures(amount)
	var/list/possible = available_structures()
	if(!length(possible))
		return
	var/list/guaranteed = possible.Copy()
	var/list/locations = list()
	for(var/obj/structure/fleshmind/wireweed/wireweed as anything in controlled_wireweed)
		var/turf/wireweed_turf = get_turf(wireweed)
		if(wireweed_turf && !(locate(/obj/structure/fleshmind/structure) in wireweed_turf))
			locations += wireweed_turf
	for(var/i in 1 to amount)
		if(!length(locations))
			return
		var/turf/location = pick_n_take(locations)
		spawn_structure(location, length(guaranteed) ? pick_n_take(guaranteed) : pick(possible))

/// Ożywia przewody roju w zasięgu range od location (po powietrzu), żeby znowu rosły
/datum/fleshmind_controller/proc/activate_wireweed_nearby(turf/location, range)
	if(!isturf(location) || decaying)
		return
	var/list/checked = list()
	checked[location] = TRUE
	var/list/frontier = list(location)
	for(var/i in 1 to range)
		var/list/next = list()
		for(var/turf/iterated as anything in frontier)
			for(var/turf/adjacent as anything in iterated.atmos_adjacent_turfs)
				if(!checked[adjacent])
					checked[adjacent] = TRUE
					next += adjacent
		frontier = next
	for(var/turf/iterated as anything in checked)
		for(var/obj/structure/fleshmind/wireweed/wireweed in iterated)
			if(wireweed.our_controller == src && !QDELETED(wireweed))
				active_wireweed |= wireweed

/datum/fleshmind_controller/proc/core_damaged(obj/structure/fleshmind/structure/core/damaged_core)
	if(!COOLDOWN_FINISHED(src, core_damage_activation))
		return
	COOLDOWN_START(src, core_damage_activation, 10 SECONDS)
	activate_wireweed_nearby(get_turf(damaged_core), FLESHMIND_CORE_DAMAGE_ACTIVATION_RANGE)

/// Rdzeń zniszczony: struktury i maszyny padają od razu, moby się przeciążają, a przewody usychają po trochu
/datum/fleshmind_controller/proc/core_death(datum/source, force)
	SIGNAL_HANDLER
	if(core)
		UnregisterSignal(core, COMSIG_PARENT_QDELETING)
	core = null
	if(decaying)
		return
	decaying = TRUE
	if(announce_timer)
		deltimer(announce_timer)
		announce_timer = null
	message_admins("Rdzeń Umysłu z ciała [controller_fullname] został zniszczony, rój usycha.")
	log_game("Fleshmind [controller_fullname] lost its core, the swarm is decaying.")
	if(announced)
		priority_announce("Jednostka procesorowa [controller_fullname] została zniszczona. Biomechaniczna masa obumiera.", "Alarm biologiczny odwołany")
	for(var/mob/living/basic/fleshmind/fleshmind_mob as anything in controlled_mobs.Copy())
		fleshmind_mob.controller_destroyed()
	for(var/obj/structure/fleshmind/structure/structure as anything in controlled_structures.Copy())
		qdel(structure)
	for(var/obj/structure/fleshmind/structure/wall as anything in controlled_walls.Copy())
		qdel(wall)
	for(var/datum/component/machine_corruption/corruption as anything in controlled_machine_components.Copy())
		qdel(corruption)
	active_wireweed.Cut()
	for(var/obj/structure/fleshmind/wireweed/wireweed as anything in controlled_wireweed)
		wireweed.color = "#7a7a7a"

/// Usycha kilka przewodów na sekundę; kontroler znika, gdy nie zostało nic
/datum/fleshmind_controller/proc/handle_slow_decay(delta_time)
	for(var/i in 1 to max(1, round(FLESHMIND_DECAY_PER_SECOND * delta_time)))
		if(!length(controlled_wireweed))
			break
		qdel(controlled_wireweed[length(controlled_wireweed)])
	if(!length(controlled_wireweed) && !length(controlled_mobs))
		qdel(src)

/datum/fleshmind_controller/proc/wireweed_death(obj/structure/fleshmind/wireweed/dying_wireweed, force)
	SIGNAL_HANDLER
	controlled_wireweed -= dying_wireweed
	active_wireweed -= dying_wireweed
	dying_wireweed.our_controller = null
	activate_wireweed_nearby(get_turf(dying_wireweed), FLESHMIND_GENERAL_ACTIVATION_RANGE)

/datum/fleshmind_controller/proc/wall_death(obj/structure/fleshmind/structure/dying_wall, force)
	SIGNAL_HANDLER
	controlled_walls -= dying_wall
	dying_wall.our_controller = null
	activate_wireweed_nearby(get_turf(dying_wall), FLESHMIND_GENERAL_ACTIVATION_RANGE)

/datum/fleshmind_controller/proc/structure_death(obj/structure/fleshmind/structure/dying_structure, force)
	SIGNAL_HANDLER
	controlled_structures -= dying_structure
	dying_structure.our_controller = null
	activate_wireweed_nearby(get_turf(dying_structure), FLESHMIND_GENERAL_ACTIVATION_RANGE)

/datum/fleshmind_controller/proc/mob_death(mob/living/basic/fleshmind/dying_mob, force)
	SIGNAL_HANDLER
	controlled_mobs -= dying_mob
	dying_mob.our_controller = null
	activate_wireweed_nearby(get_turf(dying_mob), FLESHMIND_GENERAL_ACTIVATION_RANGE)

/// Czy rój może przejąć tę maszynę: tylko zwykłe urządzenia cywilne, nigdy reaktor, broń, sterowanie, FTL ani rdzeń SI
/proc/fleshmind_can_corrupt(obj/machinery/machine)
	var/static/list/allowed = typecacheof(list(
		/obj/machinery/vending,
		/obj/machinery/computer,
		/obj/machinery/modular_fabricator,
		/obj/machinery/rnd/production,
		/obj/machinery/microwave,
		/obj/machinery/processor,
		/obj/machinery/smartfridge,
		/obj/machinery/washing_machine,
		/obj/machinery/seeder,
		/obj/machinery/biogenerator,
		/obj/machinery/space_heater,
		/obj/machinery/holopad,
		/obj/machinery/photocopier,
		/obj/machinery/jukebox,
		/obj/machinery/deepfryer,
		/obj/machinery/gibber,
		/obj/machinery/chem_dispenser,
		/obj/machinery/chem_master,
		/obj/machinery/chem_heater,
		/obj/machinery/recharger,
		/obj/machinery/cell_charger,
		/obj/machinery/sleeper,
	))
	var/static/list/forbidden = typecacheof(list(
		/obj/machinery/computer/ship,
		/obj/machinery/computer/upload,
		/obj/machinery/computer/communications,
		/obj/machinery/computer/shuttle_flight,
		/obj/machinery/computer/cryopod,
		/obj/machinery/computer/emergency_shuttle,
	))
	if(!istype(machine) || QDELETED(machine) || machine.GetComponent(/datum/component/machine_corruption))
		return FALSE
	if(!is_type_in_typecache(machine, allowed) || is_type_in_typecache(machine, forbidden))
		return FALSE
	var/area/machine_area = get_area(machine)
	return !aquila_hex_closed_area_type(machine_area?.type)
