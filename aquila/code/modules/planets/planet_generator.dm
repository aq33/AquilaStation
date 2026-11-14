// AQUILA - generator powierzchni planet, port _PlanetGenerator.dm i _biome.dm z Shiptesta (shiptest-ss13/Shiptest,
// AGPLv3). Trzy pola szumu Perlina (wysokość, wilgotność, temperatura) wybierają biom z tabeli temperatura × wilgotność,
// a powyżej mountain_height działa tabela biomów jaskiń z automatem komórkowym (ściany i korytarze).
// Różnice względem Shiptesta: generator pracuje na kwadracie powierzchni planety, a nie na całym poziomie Z (automat
// liczony tylko dla tego kwadratu), typy mają własne nazwy (/datum/planet_generator, /datum/planet_biome), bo
// /datum/map_generator i /datum/biome z tg mają u nas inne API, a odstęp mobów działa także dla basic mobów.

/// Losowe przesunięcie współrzędnych przy wyborze biomu: biomy przenikają się na granicach
#define PLANET_BIOME_DRIFT 1

GLOBAL_LIST_EMPTY(planet_biomes)

/// Wspólna instancja biomu danego typu (biomy nie trzymają stanu)
/proc/get_planet_biome(biome_type)
	var/datum/planet_biome/biome = GLOB.planet_biomes[biome_type]
	if(!biome)
		biome = new biome_type
		GLOB.planet_biomes[biome_type] = biome
	return biome

/datum/planet_generator
	/// Większa wartość = większe biomy
	var/perlin_zoom = 65
	/// Powyżej tej „wysokości” pole należy do biomu jaskiń. 1 i więcej wyłącza jaskinie.
	/// Wartości koło 0,5 dają w szumie Perlina widoczne proste linie.
	var/mountain_height = 0.85
	/// Automat komórkowy jaskiń: szansa, że komórka zaczyna jako ściana
	var/initial_closed_chance = 45
	var/smoothing_iterations = 20
	var/birth_limit = 4
	var/death_limit = 3
	/// Tabela temperatura -> wilgotność -> typ biomu
	var/list/biome_table
	/// Ta sama tabela dla jaskiń (inne progi temperatury)
	var/list/cave_biome_table

	var/height_seed
	var/humidity_seed
	var/heat_seed
	/// Wynik automatu jaskiń dla kwadratu planety (wiersz po wierszu, "1" = ściana)
	var/string_gen
	/// Lewy dolny róg i bok kwadratu, na którym pracuje generator
	var/origin_x
	var/origin_y
	var/size
	/// Obszar powierzchni i obszar jaskiń planety
	var/area/surface_area
	var/area/cave_area
	/// Pole -> biom (drift jest losowy, więc biomu nie da się policzyć drugi raz)
	var/list/turf_biome_cache
	/// Postawione obiekty i moby: odstępy między nimi
	var/list/created_features
	var/list/created_mobs

/datum/planet_generator/New(turf/bottom_left, new_size, area/new_surface_area, area/new_cave_area)
	. = ..()
	origin_x = bottom_left.x
	origin_y = bottom_left.y
	size = new_size
	surface_area = new_surface_area
	cave_area = new_cave_area
	height_seed = rand(0, 50000)
	humidity_seed = rand(0, 50000)
	heat_seed = rand(0, 50000)
	if(mountain_height < 1)
		string_gen = rustg_cnoise_generate("[initial_closed_chance]", "[smoothing_iterations]", "[birth_limit]", "[death_limit]", "[size]", "[size]")
	turf_biome_cache = list()

/datum/planet_generator/Destroy(force)
	surface_area = null
	cave_area = null
	turf_biome_cache = null
	created_features = null
	created_mobs = null
	return ..()

/// Zmienia pola na teren biomów (bez obiektów)
/datum/planet_generator/proc/generate_turfs(list/turf/turfs)
	for(var/turf/T as anything in turfs)
		var/datum/planet_biome/biome = get_biome(T)
		var/area/target_area = istype(biome, /datum/planet_biome/cave) ? cave_area : surface_area
		biome.generate_turf(T, target_area, src)
		CHECK_TICK

/// Rośliny, obiekty i moby biomów (bez pól z listy skip: pole -> TRUE)
/datum/planet_generator/proc/populate_turfs(list/turf/turfs, list/skip)
	created_features = list()
	created_mobs = list()
	for(var/turf/T as anything in turfs)
		if(skip?[T])
			continue
		var/datum/planet_biome/biome = turf_biome_cache[T]
		biome?.populate_turf(T, created_features, created_mobs)
		CHECK_TICK
	created_features = null
	created_mobs = null

/// Czy pole jest w ścianie automatu jaskiń
/datum/planet_generator/proc/is_cave_wall(turf/T)
	if(!string_gen)
		return FALSE
	var/index = size * (T.y - origin_y) + (T.x - origin_x) + 1
	if(index < 1 || index > length(string_gen))
		return FALSE
	return text2num(string_gen[index])

/// Biom pola (z pamięci podręcznej albo liczony z szumu)
/datum/planet_generator/proc/get_biome(turf/T)
	if(turf_biome_cache[T])
		return turf_biome_cache[T]
	var/drift_x = (T.x - origin_x + rand(-PLANET_BIOME_DRIFT, PLANET_BIOME_DRIFT)) / perlin_zoom
	var/drift_y = (T.y - origin_y + rand(-PLANET_BIOME_DRIFT, PLANET_BIOME_DRIFT)) / perlin_zoom

	var/humidity_level
	switch(text2num(rustg_noise_get_at_coordinates("[humidity_seed]", "[drift_x]", "[drift_y]")))
		if(0 to 0.2)
			humidity_level = PLANET_BIOME_LOWEST_HUMIDITY
		if(0.2 to 0.4)
			humidity_level = PLANET_BIOME_LOW_HUMIDITY
		if(0.4 to 0.6)
			humidity_level = PLANET_BIOME_MEDIUM_HUMIDITY
		if(0.6 to 0.8)
			humidity_level = PLANET_BIOME_HIGH_HUMIDITY
		else
			humidity_level = PLANET_BIOME_HIGHEST_HUMIDITY

	var/heat = text2num(rustg_noise_get_at_coordinates("[heat_seed]", "[drift_x]", "[drift_y]"))
	var/heat_level
	var/biome_type
	if(text2num(rustg_noise_get_at_coordinates("[height_seed]", "[drift_x]", "[drift_y]")) <= mountain_height)
		switch(heat)
			if(0 to 0.2)
				heat_level = PLANET_BIOME_COLDEST
			if(0.2 to 0.4)
				heat_level = PLANET_BIOME_COLD
			if(0.4 to 0.6)
				heat_level = PLANET_BIOME_WARM
			if(0.6 to 0.65)
				heat_level = PLANET_BIOME_TEMPERATE
			if(0.65 to 0.8)
				heat_level = PLANET_BIOME_HOT
			else
				heat_level = PLANET_BIOME_HOTTEST
		biome_type = biome_table[heat_level][humidity_level]
	else
		switch(heat)
			if(0 to 0.25)
				heat_level = PLANET_BIOME_COLDEST_CAVE
			if(0.25 to 0.5)
				heat_level = PLANET_BIOME_COLD_CAVE
			if(0.5 to 0.75)
				heat_level = PLANET_BIOME_WARM_CAVE
			else
				heat_level = PLANET_BIOME_HOT_CAVE
		biome_type = cave_biome_table[heat_level][humidity_level]
	var/datum/planet_biome/biome = get_planet_biome(biome_type)
	turf_biome_cache[T] = biome
	return biome

/// Biom: teren, rośliny, obiekty i moby jednego kawałka planety
/datum/planet_biome
	/// Ważona lista otwartych pól
	var/list/open_turf_types = list(/turf/open/floor/plating/asteroid/basalt/lava_land_surface = 1)
	/// Ważone listy roślin (bez odstępów), obiektów (co najmniej 7 pól od obiektu tego samego typu) i mobów
	/// (co najmniej 12 pól od innego moba)
	var/list/flora_spawn_list
	var/list/feature_spawn_list
	var/list/mob_spawn_list
	/// Szanse w procentach na otwarte pole
	var/flora_spawn_chance = 2
	var/feature_spawn_chance = 0.1
	var/mob_spawn_chance = 1

/datum/planet_biome/proc/get_turf_type(turf/T, datum/planet_generator/generator)
	return pickweight(open_turf_types)

/datum/planet_biome/proc/generate_turf(turf/T, area/new_area, datum/planet_generator/generator)
	var/area/old_area = T.loc
	if(old_area != new_area)
		new_area.contents += T
		T.change_area(old_area, new_area)
	var/turf/turf_type = get_turf_type(T, generator)
	var/turf/new_turf = T.ChangeTurf(turf_type, initial(turf_type.baseturfs), CHANGETURF_IGNORE_AIR | CHANGETURF_DEFER_CHANGE)
	new_turf.flags_1 &= ~NO_RUINS_1

/datum/planet_biome/proc/populate_turf(turf/T, list/feature_list, list/mob_list)
	if(!isopenturf(T) || islava(T))
		return
	var/area/A = T.loc
	var/area_flags = A.area_flags
	if(!(area_flags & CAVES_ALLOWED))
		return
	var/spawned = FALSE
	if(length(flora_spawn_list) && (area_flags & FLORA_ALLOWED) && prob(flora_spawn_chance))
		var/flora_type = pickweight(flora_spawn_list)
		new flora_type(T)
		spawned = TRUE
	if(length(feature_spawn_list) && (area_flags & FLORA_ALLOWED) && prob(feature_spawn_chance))
		var/feature_type = pickweight(feature_spawn_list)
		var/can_spawn = TRUE
		for(var/atom/other as anything in feature_list)
			if(istype(other, feature_type) && get_dist(T, other) <= 7)
				can_spawn = FALSE
				break
		if(can_spawn)
			feature_list.Insert(1, new feature_type(T))
			spawned = TRUE
	if(spawned || !length(mob_spawn_list) || !(area_flags & MOB_SPAWN_ALLOWED) || !prob(mob_spawn_chance))
		return
	var/mob_type = pickweight(mob_spawn_list)
	for(var/atom/other as anything in mob_list)
		if(get_dist(T, other) <= 12)
			return
	mob_list.Insert(1, new mob_type(T))

/// Biom jaskiń: ściany i korytarze z automatu komórkowego
/datum/planet_biome/cave
	var/list/closed_turf_types = list(/turf/closed/mineral/random/volcanic = 1)

/datum/planet_biome/cave/get_turf_type(turf/T, datum/planet_generator/generator)
	return generator.is_cave_wall(T) ? pickweight(closed_turf_types) : pickweight(open_turf_types)

#undef PLANET_BIOME_DRIFT
