// AQUILA - powierzchnia planety. Powstaje przy pierwszym lądowaniu (jak w Shiptest: planeta, której nikt nie odwiedza,
// nic nie kosztuje) w kwadracie PLANET_SURFACE_SIZE w rezerwacji turfów. Kolejność jak w Shiptest: krawędź, teren
// z generatora, lądowiska, ruiny, rośliny i zwierzęta, pogoda. Znika, kiedy okręt odlatuje z układu, a na powierzchni
// nie został nikt żywy (planet_lifecycle.dm).

/datum/planet_surface
	var/obj/structure/overmap/planet/planet
	var/datum/planet_type/planet_type
	var/datum/turf_reservation/reservation
	var/area/planet/surface/surface_area
	var/area/planet/surface/cave_area
	var/state = PLANET_SURFACE_NONE
	/// Środki lądowisk -> nazwa lądowiska
	var/list/landing_zones = list()
	/// Pola lądowisk (pole -> TRUE): generator nie stawia na nich roślin ani zwierząt
	var/list/landing_zone_turfs = list()
	/// Bieżąca pogoda i timer następnej
	var/datum/weather/current_weather
	var/weather_timer

/datum/planet_surface/New(obj/structure/overmap/planet/new_planet)
	. = ..()
	planet = new_planet
	planet_type = new_planet.planet_type

/datum/planet_surface/Destroy(force)
	unload()
	planet = null
	planet_type = null
	return ..()

/// Lewy dolny róg kwadratu
/datum/planet_surface/proc/bottom_left()
	if(!reservation)
		return
	return locate(reservation.bottom_left_coords[1], reservation.bottom_left_coords[2], reservation.bottom_left_coords[3])

/// Czy pole leży na powierzchni tej planety (krawędź też się liczy)
/datum/planet_surface/proc/contains(turf/T)
	return T && reservation && SSmapping.used_turfs[T] == reservation

/// Środek powierzchni
/datum/planet_surface/proc/center()
	var/turf/bl = bottom_left()
	if(bl)
		return locate(bl.x + round(PLANET_SURFACE_SIZE / 2), bl.y + round(PLANET_SURFACE_SIZE / 2), bl.z)

/// Pola wewnątrz krawędzi
/datum/planet_surface/proc/inner_turfs()
	var/turf/bl = bottom_left()
	if(!bl)
		return list()
	return block(locate(bl.x + PLANET_EDGE_WIDTH, bl.y + PLANET_EDGE_WIDTH, bl.z), locate(bl.x + PLANET_SURFACE_SIZE - 1 - PLANET_EDGE_WIDTH, bl.y + PLANET_SURFACE_SIZE - 1 - PLANET_EDGE_WIDTH, bl.z))

/// Buduje powierzchnię. Może trwać kilka sekund (CHECK_TICK), więc wołać asynchronicznie.
/datum/planet_surface/proc/generate()
	if(state != PLANET_SURFACE_NONE)
		return state == PLANET_SURFACE_READY
	state = PLANET_SURFACE_GENERATING
	var/start_time = REALTIMEOFDAY
	reservation = SSmapping.RequestBlockReservation(PLANET_SURFACE_SIZE, PLANET_SURFACE_SIZE)
	if(!reservation || QDELETED(src))
		state = PLANET_SURFACE_NONE
		reservation = null
		message_admins("Planeta [planet]: brak miejsca na powierzchnię w rezerwacji.")
		if(planet)
			SEND_SIGNAL(planet, COMSIG_PLANET_SURFACE_READY, FALSE)
		return FALSE
	reservation.overmap_fallback = planet
	planet.roomReservation = reservation
	lazy_template_load_started()
	surface_area = new planet_type.surface_area_type
	surface_area.setup("[surface_area.name] ([planet.name])")
	surface_area.always_unpowered = TRUE
	cave_area = new planet_type.cave_area_type
	cave_area.setup("[cave_area.name] ([planet.name])")
	cave_area.always_unpowered = TRUE

	var/turf/bl = bottom_left()
	var/list/all_turfs = block(bl, locate(bl.x + PLANET_SURFACE_SIZE - 1, bl.y + PLANET_SURFACE_SIZE - 1, bl.z))
	var/list/inner = inner_turfs()
	// Krawędź: nieprzebyte skały
	for(var/turf/T as anything in (all_turfs - inner))
		var/area/old_area = T.loc
		surface_area.contents += T
		T.change_area(old_area, surface_area)
		T.ChangeTurf(planet_type.edge_turf_type, planet_type.edge_turf_type, CHANGETURF_IGNORE_AIR | CHANGETURF_DEFER_CHANGE)
		CHECK_TICK
	var/datum/planet_generator/generator = new planet_type.generator_type(inner[1], PLANET_SURFACE_SIZE - 2 * PLANET_EDGE_WIDTH, surface_area, cave_area)
	generator.generate_turfs(inner)
	for(var/turf/T as anything in all_turfs)
		T.AfterChange(CHANGETURF_IGNORE_AIR)
		CHECK_TICK
	make_landing_zones(inner)
	place_ruins(inner)
	generator.populate_turfs(inner, landing_zone_turfs)
	qdel(generator)
	for(var/turf/T as anything in all_turfs)
		T.air_update_turf()
		CHECK_TICK
	lazy_template_load_finished()
	if(QDELETED(src))
		return FALSE
	state = PLANET_SURFACE_READY
	schedule_weather()
	log_mapping("Planet [planet] surface generated in [(REALTIMEOFDAY - start_time) / 10] s at [AREACOORD(bl)]")
	SEND_SIGNAL(planet, COMSIG_PLANET_SURFACE_READY, TRUE)
	return TRUE

/// Wyznacza lądowiska: kwadraty 31 × 31 z gruntem bez lawy, skał i zwierząt (jak w Bayu). Najpierw szuka miejsc,
/// które już są w większości przejezdne, a jeśli takich nie ma, czyści teren pod lądowisko.
/datum/planet_surface/proc/make_landing_zones(list/inner)
	var/static/list/zone_names = list("Lądowisko Alfa", "Lądowisko Bravo", "Lądowisko Charlie", "Lądowisko Delta")
	var/turf/bl = bottom_left()
	var/radius = round(PLANET_LANDING_ZONE_SIZE / 2)
	var/min_coord = PLANET_EDGE_WIDTH + radius + 2
	var/max_coord = PLANET_SURFACE_SIZE - 1 - PLANET_EDGE_WIDTH - radius - 2
	for(var/i in 1 to PLANET_LANDING_ZONES)
		var/turf/best
		var/best_score = -1
		for(var/attempt in 1 to 20)
			var/turf/candidate = locate(bl.x + rand(min_coord, max_coord), bl.y + rand(min_coord, max_coord), bl.z)
			var/too_close = FALSE
			for(var/turf/other as anything in landing_zones)
				if(get_dist(other, candidate) < PLANET_LANDING_ZONE_SIZE + 4)
					too_close = TRUE
					break
			if(too_close)
				continue
			var/score = 0
			for(var/turf/T as anything in RANGE_TURFS(radius, candidate))
				if(isopenturf(T) && !islava(T))
					score++
			if(score > best_score)
				best = candidate
				best_score = score
			CHECK_TICK
		if(!best)
			continue
		clear_landing_zone(best, radius)
		landing_zones[best] = zone_names[i]

/// Czyści lądowisko: skały i lawa zamieniają się w grunt, rośliny i obiekty bez właściciela znikają
/datum/planet_surface/proc/clear_landing_zone(turf/zone_center, radius)
	var/turf/ground_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	for(var/turf/T as anything in RANGE_TURFS(radius, zone_center))
		if(!contains(T))
			continue
		if(!isopenturf(T) || islava(T))
			T = T.ChangeTurf(ground_type, initial(ground_type.baseturfs), CHANGETURF_IGNORE_AIR)
		T.flags_1 |= NO_RUINS_1
		landing_zone_turfs[T] = TRUE
		for(var/atom/movable/AM as anything in T)
			if(isobj(AM) && AM.density && !istype(AM, /obj/docking_port))
				qdel(AM)
			else if(isanimal_or_basicmob(AM))
				var/mob/living/animal = AM
				if(!animal.client)
					qdel(animal)
		if(T.loc != surface_area)
			var/area/old_area = T.loc
			surface_area.contents += T
			T.change_area(old_area, surface_area)
		CHECK_TICK

/// Stawia ruiny z puli typu planety w środku kwadratu, z dala od lądowisk
/datum/planet_surface/proc/place_ruins(list/inner)
	var/budget = planet_type.ruin_budget
	if(budget <= 0)
		return
	var/list/available = list()
	for(var/key in planet_type.get_ruin_templates())
		var/datum/map_template/ruin/ruin = planet_type.get_ruin_templates()[key]
		if(!istype(ruin) || ruin.unpickable || ruin.always_place || ruin.cost <= 0 || ruin.cost > budget)
			continue
		if(ruin.width > PLANET_SURFACE_SIZE / 2.5 || ruin.height > PLANET_SURFACE_SIZE / 2.5)
			continue
		available[ruin] = ruin.placement_weight
	while(budget > 0 && length(available))
		var/datum/map_template/ruin/ruin = pickweight(available)
		available -= ruin
		if(ruin.cost > budget)
			continue
		if(place_ruin(ruin))
			budget -= ruin.cost
		CHECK_TICK

/// Próbuje postawić jedną ruinę; TRUE, jeśli stanęła
/datum/planet_surface/proc/place_ruin(datum/map_template/ruin/ruin)
	var/turf/bl = bottom_left()
	var/margin = PLANET_EDGE_WIDTH + 2
	for(var/attempt in 1 to 20)
		var/x = bl.x + rand(margin + round(ruin.width / 2), PLANET_SURFACE_SIZE - 1 - margin - round(ruin.width / 2))
		var/y = bl.y + rand(margin + round(ruin.height / 2), PLANET_SURFACE_SIZE - 1 - margin - round(ruin.height / 2))
		var/turf/central = locate(x, y, bl.z)
		var/list/affected = ruin.get_affected_turfs(central, TRUE)
		var/valid = TRUE
		for(var/turf/T as anything in affected)
			if(!contains(T) || (T.flags_1 & NO_RUINS_1) || (T.loc != surface_area && T.loc != cave_area))
				valid = FALSE
				break
		if(!valid)
			continue
		for(var/turf/T as anything in affected)
			for(var/atom/movable/AM as anything in T)
				if(isanimal_or_basicmob(AM) || istype(AM, /obj/structure/flora) || istype(AM, /obj/structure/spawner))
					qdel(AM)
		ruin.load(central, centered = TRUE)
		ruin.loaded++
		for(var/turf/T as anything in ruin.get_affected_turfs(central, TRUE))
			T.flags_1 |= NO_RUINS_1
			// Ruiny Lavalandu mają kawałki pustkowi Lavalandu: na planecie to jej powierzchnia (światło, pogoda)
			if(istype(T.loc, /area/lavaland/surface/outdoors) || istype(T.loc, /area/space))
				var/area/old_area = T.loc
				surface_area.contents += T
				T.change_area(old_area, surface_area)
		log_game("Planet [planet] ruin [ruin.name] placed at [AREACOORD(central)]")
		return TRUE
	return FALSE

/// Następna burza za kilka minut
/datum/planet_surface/proc/schedule_weather()
	if(!length(planet_type.weather_types) || state != PLANET_SURFACE_READY)
		return
	weather_timer = addtimer(CALLBACK(src, PROC_REF(start_weather)), rand(planet_type.weather_delay_min, planet_type.weather_delay_max), TIMER_STOPPABLE)

/datum/planet_surface/proc/start_weather()
	weather_timer = null
	if(state != PLANET_SURFACE_READY || QDELETED(surface_area))
		return
	var/weather_type = pickweight(planet_type.weather_types)
	current_weather = new weather_type(list())
	current_weather.planet_area = surface_area
	current_weather.telegraph()
	weather_timer = addtimer(CALLBACK(src, PROC_REF(start_weather)), current_weather.telegraph_duration + current_weather.weather_duration + current_weather.end_duration + rand(planet_type.weather_delay_min, planet_type.weather_delay_max), TIMER_STOPPABLE)

/// Żywi gracze na powierzchni (z umysłem; martwi i potwory się nie liczą)
/datum/planet_surface/proc/living_players()
	. = list()
	if(!reservation)
		return
	for(var/mob/living/M as anything in GLOB.mob_living_list)
		if(M.stat == DEAD || !M.mind)
			continue
		if(contains(get_turf(M)))
			. += M

/// Usuwa powierzchnię razem z zawartością
/datum/planet_surface/proc/unload()
	if(weather_timer)
		deltimer(weather_timer)
		weather_timer = null
	if(current_weather)
		current_weather.end()
		current_weather.planet_area = null
		current_weather = null
	landing_zones = list()
	landing_zone_turfs = list()
	if(planet?.roomReservation == reservation)
		planet.roomReservation = null
	if(reservation)
		for(var/turf/T as anything in reservation.reserved_turfs)
			for(var/obj/effect/landmark/L in T)
				qdel(L)
		QDEL_NULL(reservation)
	// Puste obszary nie wiszą na listach obszarów (teleporty, admin)
	for(var/area/A as anything in list(surface_area, cave_area))
		if(!A)
			continue
		GLOB.sortedAreas -= A
		for(var/z_key in SSmapping.areas_in_z)
			SSmapping.areas_in_z[z_key] -= A
	surface_area = null
	cave_area = null
	state = PLANET_SURFACE_NONE
