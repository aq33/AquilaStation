// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - planety: powierzchnia planety wulkanicznej powstaje w rezerwacji z krawędzią, lądowiskami i terenem,
/// a po unload() rezerwacja wraca do puli
/datum/unit_test/planet_surface_generation

/datum/unit_test/planet_surface_generation/Run()
	var/obj/structure/overmap/planet/planet = new(run_loc_floor_top_right, /datum/planet_type/lava)
	var/datum/planet_surface/surface = planet.surface
	TEST_ASSERT(surface, "The planet has no surface datum")
	TEST_ASSERT_EQUAL(surface.state, PLANET_SURFACE_NONE, "The surface was generated before anyone landed")
	TEST_ASSERT(surface.generate(), "The surface didn't generate")
	TEST_ASSERT_EQUAL(surface.state, PLANET_SURFACE_READY, "The surface isn't ready after generating")
	TEST_ASSERT(planet.roomReservation == surface.reservation, "The planet doesn't point at its surface reservation")
	TEST_ASSERT_EQUAL(surface.reservation.overmap_fallback, planet, "Mobs on the surface wouldn't belong to the planet")

	var/turf/bl = surface.bottom_left()
	TEST_ASSERT(istype(bl, /turf/closed/indestructible/rock/planet_edge), "The surface corner isn't the planet edge ([bl.type])")
	// Rezerwacja planety nie zamienia pól na kosmos (ChangeTurf 36 tys. pól zamrażał serwer): każde pole, także krawędź,
	// musi nadpisać generator
	var/reserved_space = 0
	for(var/turf/T as anything in surface.reservation.reserved_turfs)
		if(isspaceturf(T))
			reserved_space++
	TEST_ASSERT_EQUAL(reserved_space, 0, "Space turfs left in the planet reservation (edge or terrain skipped by the generator)")
	// Bez luminosity obszaru gracz widział tylko pola w promieniu see_in_dark, a na planecie grał szum okrętu
	TEST_ASSERT(surface.surface_area.luminosity, "The planet surface area has no luminosity: turfs past see_in_dark render black")
	TEST_ASSERT(!surface.cave_area.luminosity, "Planet caves are lit")
	TEST_ASSERT(!surface.surface_area.ambient_buzz, "The ship ambience hum plays on the planet surface")
	var/space = 0
	var/lava = 0
	var/walls = 0
	var/list/inner = surface.inner_turfs()
	for(var/turf/T as anything in inner)
		if(isspaceturf(T))
			space++
		else if(islava(T))
			lava++
		else if(isclosedturf(T))
			walls++
	TEST_ASSERT_EQUAL(space, 0, "Space turfs left on the planet surface")
	TEST_ASSERT(walls > 0, "The lava planet has no rock (caves)")
	TEST_ASSERT(walls + lava < length(inner), "The lava planet has no walkable ground")

	TEST_ASSERT_EQUAL(length(surface.landing_zones), PLANET_LANDING_ZONES, "Wrong number of landing zones")
	for(var/turf/zone as anything in surface.landing_zones)
		for(var/turf/T as anything in RANGE_TURFS(round(PLANET_LANDING_ZONE_SIZE / 2), zone))
			TEST_ASSERT(isopenturf(T) && !islava(T), "Landing zone [surface.landing_zones[zone]] has blocked ground at [T.x],[T.y] ([T.type])")
			for(var/atom/movable/AM as anything in T)
				TEST_ASSERT(!AM.density || ismob(AM), "Landing zone [surface.landing_zones[zone]] has a dense [AM.type]")
		TEST_ASSERT(zone.loc == surface.surface_area, "Landing zone [surface.landing_zones[zone]] isn't in the planet surface area")

	var/list/reserved = surface.reservation.reserved_turfs.Copy()
	surface.unload()
	TEST_ASSERT_EQUAL(surface.state, PLANET_SURFACE_NONE, "The surface didn't unload")
	TEST_ASSERT(!planet.roomReservation, "The planet still points at a released reservation")
	var/turf/released = reserved[1]
	TEST_ASSERT(isspaceturf(released), "The released surface wasn't turned back into space ([released.type])")
	qdel(planet, TRUE)

/// AQUILA - planety: pogoda planety działa tylko w jej obszarze, a nie na całym poziomie rezerwacji
/datum/unit_test/planet_weather_area

/datum/unit_test/planet_weather_area/Run()
	var/area/planet/surface/lava/planet_area = new
	var/area/planet/surface/lava/other_area = new
	var/turf/inside = run_loc_floor_bottom_left
	var/turf/outside = get_step(inside, EAST)
	var/area/old_inside = inside.loc
	var/area/old_outside = outside.loc
	planet_area.contents += inside
	inside.change_area(old_inside, planet_area)
	other_area.contents += outside
	outside.change_area(old_outside, other_area)
	var/mob/living/carbon/human/in_storm = allocate(/mob/living/carbon/human, inside)
	var/mob/living/carbon/human/sheltered = allocate(/mob/living/carbon/human, outside)

	var/datum/weather/ash_storm/storm = new(list())
	storm.planet_area = planet_area
	storm.telegraph()
	TEST_ASSERT_EQUAL(length(storm.impacted_areas), 1, "The planet storm affects more than its planet")
	TEST_ASSERT(storm.impacted_areas[1] == planet_area, "The planet storm doesn't affect its planet")
	TEST_ASSERT(storm.can_weather_act(in_storm), "The planet storm doesn't hit people on the planet")
	TEST_ASSERT(!storm.can_weather_act(sheltered), "The planet storm hits people outside its planet")
	// Pętle etapów: słaba w zapowiedzi, silna w głównym etapie, pod dachem osobna
	storm.planet_indoor_areas = list(other_area)
	storm.planet_update_playlist()
	TEST_ASSERT(storm.planet_playlist[planet_area] == /datum/looping_sound/weak_outside_ashstorm, "The planet storm telegraph doesn't play the weak outdoor loop")
	TEST_ASSERT(storm.planet_playlist[other_area] == /datum/looping_sound/weak_inside_ashstorm, "The planet storm telegraph doesn't play the weak indoor loop")
	storm.start()
	TEST_ASSERT(storm.planet_playlist[planet_area] == /datum/looping_sound/active_outside_ashstorm, "The planet storm doesn't switch to the strong loop")
	storm.end()
	TEST_ASSERT(isnull(storm.planet_playlist), "The planet storm keeps its loops after ending")
	storm.planet_area = null
	storm.planet_indoor_areas = null

	other_area.contents -= outside
	old_outside.contents += outside
	outside.change_area(other_area, old_outside)
	planet_area.contents -= inside
	old_inside.contents += inside
	inside.change_area(planet_area, old_inside)

/// Zwraca pierwsze pole lądowiska (otwarty grunt planety)
/datum/unit_test/proc/planet_ground_turf(datum/planet_surface/surface)
	for(var/turf/zone as anything in surface.landing_zones)
		return zone

/// AQUILA - planety: każdy typ z biomów planety wulkanicznej (teren, rośliny, obiekty, fauna) da się postawić i usunąć
/datum/unit_test/planet_lava_content

/datum/unit_test/planet_lava_content/Run()
	var/list/atom_types = list()
	var/list/turf_types = list()
	for(var/biome_type in subtypesof(/datum/planet_biome/lava) + typesof(/datum/planet_biome/cave/lava))
		var/datum/planet_biome/biome = get_planet_biome(biome_type)
		turf_types |= biome.open_turf_types
		if(istype(biome, /datum/planet_biome/cave))
			var/datum/planet_biome/cave/cave = biome
			turf_types |= cave.closed_turf_types
		for(var/list/spawn_list in list(biome.flora_spawn_list, biome.feature_spawn_list, biome.mob_spawn_list))
			atom_types |= spawn_list
	var/turf/T = run_loc_floor_bottom_left
	// Plamy z wcześniejszych testów (sprzątanie testu ich nie rusza): lawa usuwa je w trakcie ChangeTurf, a ten przywraca
	// sygnały starego turfu, więc na podłodze zostałaby martwa rejestracja plamy (runtime u następnego, kto tu wejdzie)
	for(var/obj/effect/decal/cleanable/stain in T)
		qdel(stain)
	var/turf_type_before = T.type
	for(var/turf_type in turf_types)
		T = T.ChangeTurf(turf_type)
		TEST_ASSERT(istype(T, turf_type), "Couldn't place [turf_type]")
	T = T.ChangeTurf(turf_type_before)
	for(var/atom_type in atom_types)
		var/atom/movable/thing = new atom_type(run_loc_floor_top_right)
		if(ispath(atom_type, /obj/effect/spawner))
			continue // Spawner stawia swoją zawartość i sam znika
		TEST_ASSERT(!QDELETED(thing), "[atom_type] deleted itself right after spawning")
		qdel(thing)
	// Sprzątanie po spawnerach (anomalie)
	for(var/obj/effect/anomaly/anomaly in run_loc_floor_top_right)
		qdel(anomaly)

/// AQUILA - planety: typ losowej planety zależy od znaczników układu, ozdoby (olbrzymy) dochodzą osobno, a misje
/// wiertnicze wybierają tylko typy z żyłą wymaganej klasy
/datum/unit_test/planet_type_selection

/datum/unit_test/planet_type_selection/Run()
	for(var/planet_type in GLOB.planet_type_prototypes)
		var/datum/planet_type/prototype = GLOB.planet_type_prototypes[planet_type]
		// Wspólni rodzice bez generatora (np. planety karłowate) nie są planetami
		if(prototype.generator_type == /datum/planet_generator)
			continue
		TEST_ASSERT(length(prototype.system_tags) || prototype.type == /datum/planet_type/lava, "[planet_type] never appears in random systems (no system_tags)")
		if(length(prototype.mission_veins))
			TEST_ASSERT(prototype.vein_root, "[planet_type] has mission veins but no vein_root for the mission drill")
			for(var/vein_class in prototype.mission_veins)
				var/vein_type = prototype.get_mission_vein(vein_class)
				TEST_ASSERT(ispath(vein_type, prototype.vein_root), "[planet_type] class [vein_class] vein [vein_type] isn't under its vein_root")
		TEST_ASSERT(prototype.surface_size <= PLANET_SURFACE_SIZE_LARGE, "[planet_type] surface is bigger than the large surface")

	var/list/weights = planet_type_weights(list("demonstar"), FALSE)
	TEST_ASSERT(length(weights), "No planet type fits a demon star system")
	for(var/i in 1 to 10)
		var/picked = pick_planet_type_for_tags(list("demonstar"))
		TEST_ASSERT(weights[picked], "[picked] was picked for a demon star system it doesn't fit")
	TEST_ASSERT(pick_planet_type_for_tags(list("no_such_tag")), "A system with an unknown tag got no planet type")
	TEST_ASSERT(/datum/planet_type/lava in GLOB.fixed_planets_by_system["Tortuga"], "Fixed planets from fixed_systems are missing (Tortuga has no volcanic planet)")

	var/datum/overmap_objective/planet/deep_vein/deep_mission = new
	for(var/i in 1 to 10)
		var/datum/planet_type/picked = GLOB.planet_type_prototypes[deep_mission.pick_planet_type()]
		TEST_ASSERT(picked.get_mission_vein(4), "The deep vein mission picked [picked.type] without a class 4 vein")
	qdel(deep_mission)

/// AQUILA - planety: pogoda planet z Shiptesta działa tylko na planetach, ma swoje nakładki w pliku ikon i nie sypie
/// runtime'ami na człowieku pod gołym niebem
/datum/unit_test/planet_weather_types

/datum/unit_test/planet_weather_types/Run()
	var/list/weather_types = subtypesof(/datum/weather/planet) + /datum/weather/snow_storm/planet
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	for(var/weather_type in weather_types)
		var/datum/weather/weather = new weather_type(list())
		TEST_ASSERT_EQUAL(weather.probability, 0, "[weather_type] can start on its own outside planets")
		var/list/states = icon_states(weather.overlay_icon)
		for(var/overlay in list(weather.telegraph_overlay, weather.weather_overlay, weather.end_overlay))
			if(overlay)
				TEST_ASSERT(overlay in states, "[weather_type] overlay [overlay] is missing from [weather.overlay_icon]")
		for(var/loop_type in list(weather.planet_sound_weak_outside, weather.planet_sound_weak_inside, weather.planet_sound_active_outside, weather.planet_sound_active_inside))
			if(loop_type)
				TEST_ASSERT(ispath(loop_type, /datum/looping_sound), "[weather_type] has a sound loop that isn't a looping sound: [loop_type]")
		weather.weather_act(victim)
		qdel(weather)
	victim.fully_heal(TRUE)

/// Spawner greebla do testu: mała mapa schronu
/obj/effect/greeble_spawner/unit_test
	greeble_map = "_maps/templates/shelter_1.dmm"

/// AQUILA - planety: greeble z biomu wczytuje się na powierzchni, ale nie na lądowisku, a łata trawy rozlewa swój turf
/datum/unit_test/planet_greeble

/datum/unit_test/planet_greeble/Run()
	var/obj/structure/overmap/planet/planet = new(run_loc_floor_top_right, /datum/planet_type/lava)
	var/datum/planet_surface/surface = planet.surface
	TEST_ASSERT(planet_test_fast_surface(planet), "The surface didn't generate")
	var/turf/center = surface.center()
	// Pierwsze miejsce, na którym szablon się mieści (poza lądowiskami, ruinami i krawędzią)
	var/obj/effect/greeble_spawner/free_greeble = new /obj/effect/greeble_spawner/unit_test(center)
	TEST_ASSERT(!QDELETED(free_greeble), "A greeble spawner with a map deleted itself on creation")
	var/datum/map_template/shelter_template = free_greeble.get_template()
	var/turf/free_spot
	for(var/turf/T as anything in surface.inner_turfs())
		if(free_greeble.can_deploy(shelter_template, T, surface))
			free_spot = T
			break
	TEST_ASSERT(free_spot, "No free spot for a greeble on the surface")
	free_greeble.forceMove(free_spot)
	var/turf/zone = surface.landing_zones[1]
	var/obj/effect/greeble_spawner/zone_greeble = new /obj/effect/greeble_spawner/unit_test(zone)
	TEST_ASSERT(!zone_greeble.can_deploy(shelter_template, zone, surface), "A greeble can load on a landing zone")
	var/zone_turf_type = zone.type
	surface.load_greebles()
	TEST_ASSERT(QDELETED(free_greeble) && QDELETED(zone_greeble), "Greeble spawners stay after loading")
	var/loaded_table = FALSE
	for(var/turf/T as anything in RANGE_TURFS(4, free_spot))
		if(locate(/obj/structure/table) in T)
			loaded_table = TRUE
			break
	TEST_ASSERT(loaded_table, "The greeble template didn't load on a free spot")
	TEST_ASSERT_EQUAL(zone.type, zone_turf_type, "A greeble loaded on a landing zone")

	var/obj/effect/greeble_spawner/grass_patch/patch = new(free_spot)
	patch.turf_to_spread = /turf/open/floor/plating/asteroid/dirt
	patch.min_turfs_to_spread = 3
	patch.chance_to_terminate = 0
	patch.terminate_chance_add = 0
	patch.max_turfs_to_spread = 3
	var/turf/patch_start = get_turf(patch)
	surface.load_greebles()
	TEST_ASSERT(QDELETED(patch), "The grass patch spawner stays after spreading")
	TEST_ASSERT(istype(patch_start, /turf/open/floor/plating/asteroid/dirt) || !isopenturf(patch_start), "The grass patch didn't spread its turf")
	TEST_ASSERT(center, "The surface has no center")
	surface.unload()
	qdel(planet, TRUE)

/// Mała powierzchnia bez ruin do testów mechanik planet (ostrzał, kapsuły, misje, greeble): pełne generowanie z ruiną
/// główną sprawdza planet_surface_generation, a tu liczy się czas jednej części CI
/proc/planet_test_fast_surface(obj/structure/overmap/planet/planet)
	planet.planet_type.surface_size = PLANET_SURFACE_SIZE_DWARF
	planet.surface.skip_ruins = TRUE
	return planet.surface.generate()

/// Próbka do ciężkich testów planet (generowanie powierzchni, ruiny, greeble): w zwykłym przebiegu losowe count
/// elementów, więc kolejne przebiegi przechodzą przez całą pulę, a z -DAQUILA_FULL_MAP_TESTS wszystkie (jak testy asteroid
/// górniczych i shipbreakingu). Wszystkie typy, ruiny i greeble naraz to kilkadziesiąt minut jednej części CI.
/proc/planet_test_sample(list/items, count = 1)
#ifdef AQUILA_FULL_MAP_TESTS
	return items.Copy()
#else
	var/list/pool = items.Copy()
	. = list()
	while(length(pool) && length(.) < count)
		var/picked = pick(pool)
		pool -= picked
		. += picked
#endif

/// Czy ruina mieści się jako ruina główna na kwadracie o boku side, w miejscu z place_main_ruin (przy górnej krawędzi)
/proc/planet_ruin_fits_surface(datum/map_template/ruin/ruin, side)
	var/inner_size = side - 2 * PLANET_EDGE_WIDTH
	return ruin.width <= inner_size - 12 && ruin.height <= inner_size / 2

/// Wczytuje ruinę w osobnej, czystej rezerwacji i ją zwalnia. TRUE, jeśli szablon się wczytał.
/proc/planet_test_load_ruin(datum/map_template/ruin/ruin)
	var/datum/turf_reservation/reservation = SSmapping.RequestBlockReservation(ruin.width + 2, ruin.height + 2)
	if(!reservation)
		return FALSE
	var/turf/corner = locate(reservation.bottom_left_coords[1] + 1, reservation.bottom_left_coords[2] + 1, reservation.bottom_left_coords[3])
	// Atmosfera wstrzymana jak przy generowaniu planety: podmuch z rozszczelnionych wraków nie rusza rzeczy przed Initialize
	lazy_template_load_started()
	. = ruin.load(corner, centered = FALSE)
	lazy_template_load_finished()
	// Rezerwacja zwalniana przy działającej atmosferze, jak przy znikaniu powierzchni w grze (zwalnianie przy wstrzymanej
	// atmosferze wywracało auxmos w process_atmos_callbacks)
	qdel(reservation)

/// AQUILA - planety: każda ruina Shiptesta z puli ruin głównych planety wulkanicznej mieści się na planecie i się wczytuje
/datum/unit_test/planet_lava_ruins

/datum/unit_test/planet_lava_ruins/Run()
#ifndef AQUILA_FULL_MAP_TESTS
	// Ciężki test planet (generowanie powierzchni typów, wczytywanie ruin i greebli): w zwykłym CI pomijany, bo cała
	// część testów z planetami nie mieściła się w limicie czasu. Pełny przebieg: -DAQUILA_FULL_MAP_TESTS.
	return
#endif
	var/list/templates = get_planet_lava_ruin_templates()
	TEST_ASSERT(length(templates) >= 5, "Only [length(templates)] Shiptest lava ruins are registered")
	// Każda ruina mieści się jako ruina główna (do szerokości wnętrza bez marginesów i połowy jego wysokości) i wczytuje się
	// we własnej pustej rezerwacji, z atmosferą wstrzymaną jak przy generowaniu planety: ruiny nie nachodzą na siebie,
	// a podmuch z rozszczelnionych wraków nie rusza przedmiotów przed ich Initialize.
	var/obj/structure/overmap/planet/fit_planet = new(run_loc_floor_top_right, /datum/planet_type/lava)
	for(var/name in planet_test_sample(templates, 2))
		var/datum/map_template/ruin/ruin = templates[name]
		// Bez pliku mapy szablon ma rozmiar 0 i „wczytuje się” jako pusta mapa
		TEST_ASSERT(ruin.width && ruin.height, "[name] map file didn't preload ([ruin.mappath])")
		TEST_ASSERT(fit_planet.surface.main_ruin_fits(ruin, PLANET_SURFACE_SIZE), "[name] ([ruin.width]x[ruin.height]) doesn't fit as a main ruin")
		var/datum/turf_reservation/reservation = SSmapping.RequestBlockReservation(ruin.width, ruin.height)
		TEST_ASSERT(reservation, "No room to load [name]")
		var/turf/corner = locate(reservation.bottom_left_coords[1], reservation.bottom_left_coords[2], reservation.bottom_left_coords[3])
		lazy_template_load_started()
		var/loaded = ruin.load(corner)
		lazy_template_load_finished()
		// Rezerwacja zwalniana przy działającej atmosferze, jak przy znikaniu powierzchni w grze (zwalnianie przy wstrzymanej
		// atmosferze wywracało auxmos w process_atmos_callbacks)
		qdel(reservation)
		TEST_ASSERT(loaded, "[name] didn't load")
	qdel(fit_planet, TRUE)

	// Ruina stojąca na innej istniejącej powierzchni nie jest losowana drugi raz (wspólne obszary ruin)
	var/datum/map_template/ruin/shared_ruin = templates[templates[1]]
	var/obj/structure/overmap/planet/first = new(run_loc_floor_top_right, /datum/planet_type/lava)
	var/obj/structure/overmap/planet/second = new(run_loc_floor_top_right, /datum/planet_type/lava)
	TEST_ASSERT(!second.surface.ruin_in_use(shared_ruin), "A ruin counts as used before any surface loaded it")
	first.surface.state = PLANET_SURFACE_READY
	first.surface.loaded_ruins = list(shared_ruin)
	TEST_ASSERT(second.surface.ruin_in_use(shared_ruin), "A ruin standing on another surface can be loaded again")
	first.surface.state = PLANET_SURFACE_NONE
	TEST_ASSERT(!second.surface.ruin_in_use(shared_ruin), "A ruin of an unloaded surface still counts as used")
	first.surface.loaded_ruins = list()
	qdel(first, TRUE)
	qdel(second, TRUE)

// Misje w teście: „okręt” to okolica podłogi testowej (mapa testowa nie należy do głównego okrętu)
/datum/overmap_objective/planet/survey/test
	var/turf/home_turf

/datum/overmap_objective/planet/survey/test/is_delivered(atom/movable/AM)
	return get_dist(AM, home_turf) <= 3 && AM.z == home_turf.z

/datum/overmap_objective/planet/evacuation/test
	var/turf/home_turf

/datum/overmap_objective/planet/evacuation/test/is_delivered(atom/movable/AM)
	return get_dist(AM, home_turf) <= 3 && AM.z == home_turf.z

/// AQUILA - planety: pocisk wycelowany w planetę trafia ją nad środkiem, a uderzenie spada przy znaczniku z lornetki
/datum/unit_test/planet_bombardment

/datum/unit_test/planet_bombardment/Run()
	var/obj/structure/overmap/planet/planet = new(run_loc_floor_bottom_left, /datum/planet_type/lava)
	TEST_ASSERT(planet_test_fast_surface(planet), "The surface didn't generate")
	var/turf/ground = planet_ground_turf(planet.surface)
	TEST_ASSERT(get_planet_of(ground) == planet, "A landing zone turf isn't recognised as the planet surface")
	TEST_ASSERT(!get_planet_of(run_loc_floor_bottom_left), "A ship turf is recognised as a planet surface")

	var/obj/item/projectile/bullet/mac_round/shell = new(planet.center_turf())
	shell.original = planet
	TEST_ASSERT(shell.can_hit_target(planet, TRUE), "A shell above the planet centre can't hit the planet it was fired at")
	shell.original = null
	TEST_ASSERT(!shell.can_hit_target(planet, TRUE), "A shell fired at something else hits the planet it flies over")

	var/obj/effect/planet_laser_target/laser = new(ground, "Tester")
	planet.bullet_act(shell)
	var/obj/effect/temp_visual/planet_strike/strike
	for(var/obj/effect/temp_visual/planet_strike/candidate in range(planet.strike_spread(shell), ground))
		strike = candidate
	TEST_ASSERT(strike, "The bombardment didn't land next to the laser target")
	TEST_ASSERT_EQUAL(strike.projectile_type, shell.type, "The strike doesn't remember the shell type")
	// Bez wybuchu w teście
	strike.projectile_type = null
	strike.damage = 0
	qdel(strike)

	// Niewybuch nie ma głowicy: ginie w atmosferze bez ostrzału
	var/obj/item/projectile/guided_munition/torpedo/dud/dud = new(planet.center_turf())
	planet.bullet_act(dud)
	var/dud_strikes = 0
	for(var/obj/effect/temp_visual/planet_strike/candidate in range(planet.strike_spread(dud), ground))
		dud_strikes++
		candidate.projectile_type = null
		candidate.damage = 0
		qdel(candidate)
	qdel(dud)
	TEST_ASSERT_EQUAL(dud_strikes, 0, "A dud torpedo bombarded the planet")

	// Torpeda opancerzona uwalnia na ziemi swój ładunek (visceratory), jak we wnętrzu okrętu
	var/obj/effect/temp_visual/planet_strike/viscerator_strike = new(ground, /obj/item/projectile/guided_munition/torpedo/viscerator, 75)
	viscerator_strike.strike(ground)
	viscerator_strike.projectile_type = null
	viscerator_strike.damage = 0
	qdel(viscerator_strike)
	var/viscerators = 0
	for(var/mob/living/basic/viscerator/V in ground)
		viscerators++
		qdel(V)
	TEST_ASSERT(viscerators > 0, "The armoured torpedo didn't release its viscerators on the planet")

	qdel(laser)
	qdel(shell)
	planet.surface.unload()
	qdel(planet, TRUE)

/// AQUILA - planety: kapsuła desantowa ląduje tylko na gruncie planety i zabiera siedzącego
/datum/unit_test/planet_drop_pod

/datum/unit_test/planet_drop_pod/Run()
	var/obj/structure/overmap/planet/planet = new(run_loc_floor_top_right, /datum/planet_type/lava)
	TEST_ASSERT(planet_test_fast_surface(planet), "The surface didn't generate")
	var/turf/ground = planet_ground_turf(planet.surface)
	var/obj/machinery/drop_pod_bay/bay = allocate(/obj/machinery/drop_pod_bay, run_loc_floor_bottom_left)
	TEST_ASSERT(bay.can_land_at(ground), "The drop pod can't land on a landing zone")
	TEST_ASSERT(!bay.can_land_at(run_loc_floor_bottom_left), "The drop pod can land inside the ship")
	var/turf/lava
	for(var/turf/open/lava/L in planet.surface.inner_turfs())
		lava = L
		break
	if(lava)
		TEST_ASSERT(!bay.can_land_at(lava), "The drop pod can land in lava")

	var/mob/living/carbon/human/trooper = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	bay.buckle_mob(trooper, TRUE)
	TEST_ASSERT_EQUAL(trooper.buckled, bay, "The trooper didn't sit in the drop pod")
	bay.set_target(trooper, planet, ground, "test")
	bay.machine_stat = NONE
	bay.launch(trooper)
	TEST_ASSERT(istype(trooper.loc, /obj/structure/drop_pod), "The trooper isn't in the drop pod ([trooper.loc?.type])")
	TEST_ASSERT(!bay.ready, "The bay is ready right after launching")
	// Kapsuła leci kilka sekund (tranzyt, spadanie, otwarcie): żołnierz ma wysiąść na planecie
	sleep(15 SECONDS)
	TEST_ASSERT(planet.surface.contains(get_turf(trooper)), "The trooper didn't land on the planet ([AREACOORD(trooper)])")
	TEST_ASSERT(get_dist(trooper, ground) <= 3, "The trooper landed too far from the target")
	trooper.forceMove(run_loc_floor_bottom_left)
	planet.surface.unload()
	qdel(planet, TRUE)

/// AQUILA - planety: badanie planety zalicza się po sondzie i czterech rodzajach próbek na okręcie
/datum/unit_test/planet_survey_mission

/datum/unit_test/planet_survey_mission/Run()
	var/datum/overmap_objective/planet/survey/test/mission = new(SSstar_system.systems[1])
	mission.home_turf = run_loc_floor_bottom_left
	mission.target_planet = new(run_loc_floor_top_right, /datum/planet_type/lava)
	TEST_ASSERT(planet_test_fast_surface(mission.target_planet), "The surface didn't generate")
	mission.setup_site()
	TEST_ASSERT(mission.site, "The survey site wasn't placed")
	TEST_ASSERT(mission.target_planet.surface.contains(get_turf(mission.site)), "The survey site isn't on the planet")
	for(var/sample_type in list("rock", "flora", "fauna"))
		allocate(/obj/item/planet_sample, run_loc_floor_bottom_left, mission.target_planet, sample_type)
	mission.probe_done = TRUE
	mission.check_completion()
	TEST_ASSERT_EQUAL(mission.status, 0, "The survey finished with only three kinds of samples")
	allocate(/obj/item/planet_sample, run_loc_floor_bottom_left, mission.target_planet, "atmosphere")
	mission.check_completion()
	TEST_ASSERT_EQUAL(mission.status, 1, "The survey didn't finish with all samples delivered and the probe done")
	var/obj/structure/overmap/planet/planet = mission.target_planet
	qdel(mission)
	planet.surface.unload()
	qdel(planet, TRUE)

/// AQUILA - planety: ewakuacja stawia schron z kolonistami i zalicza się, gdy trzech jest żywych na okręcie
/datum/unit_test/planet_evacuation_mission

/datum/unit_test/planet_evacuation_mission/Run()
	var/datum/overmap_objective/planet/evacuation/test/mission = new(SSstar_system.systems[1])
	mission.home_turf = run_loc_floor_bottom_left
	mission.target_planet = new(run_loc_floor_top_right, /datum/planet_type/lava)
	TEST_ASSERT(planet_test_fast_surface(mission.target_planet), "The surface didn't generate")
	mission.setup_site()
	TEST_ASSERT(mission.colony_ready, "The colony wasn't set up")
	TEST_ASSERT_EQUAL(length(mission.colonists), 4, "Wrong number of colonists")
	for(var/mob/living/carbon/human/colonist as anything in mission.colonists)
		TEST_ASSERT(mission.target_planet.surface.contains(get_turf(colonist)), "A colonist isn't on the planet")
	mission.check_completion()
	TEST_ASSERT_EQUAL(mission.status, 0, "The evacuation finished with everyone still on the planet")
	for(var/i in 1 to 3)
		var/mob/living/carbon/human/colonist = mission.colonists[i]
		colonist.forceMove(run_loc_floor_bottom_left)
	mission.check_completion()
	TEST_ASSERT_EQUAL(mission.status, 1, "The evacuation didn't finish with three colonists on the ship")
	var/list/colonists = mission.colonists.Copy()
	var/obj/structure/overmap/planet/planet = mission.target_planet
	qdel(mission)
	QDEL_LIST(colonists)
	planet.surface.unload()
	qdel(planet, TRUE)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
