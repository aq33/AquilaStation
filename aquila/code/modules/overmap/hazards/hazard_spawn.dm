/// AQUILA - rozmieszczenie stref zagrożeń w układach gwiezdnych (typy: hazards/hazard_types.dm).
/// Strefy powstają raz, przy apply_system_effects() (generate_anomaly() 15 s po wczytaniu układu albo badlands),
/// według terenu układu: identyfikator kafla mapy hex (HEX_TERRAIN_* z aq33/AquilaStation#638, w hex_terrain_id),
/// a w układzie bez kafla odpowiednik typu układu NSV (hazard_terrain()). Ten sam teren wybiera warstwę środkową tła
/// (overmap/terrain_background.dm).

/// Szansa (%) na jedną losową strefę w układzie, którego teren nie ma własnej tabeli
#define HAZARD_RANDOM_ZONE_CHANCE 10

/// Kafle mapy hex bez stref zagrożeń: pusta przestrzeń i kafle, których treść daje sama mapa (eventy, miny, sygnał)
GLOBAL_LIST_INIT(hazard_quiet_terrains, list("empty", "signal", "carp", "anom", "wh", "mines"))

/datum/star_system
	/// AQUILA - strefy zagrożeń już rozmieszczone (apply_system_effects() bywa wołane więcej niż raz)
	var/hazards_generated = FALSE
	/// AQUILA - teren kafla mapy hex, na którym leży układ (HEX_TERRAIN_*); null = układ bez kafla
	var/hex_terrain_id

/// Teren układu dla stref i tła: kafel mapy hex, a bez niego odpowiednik typu układu NSV
/datum/star_system/proc/hazard_terrain()
	if(hex_terrain_id)
		return hex_terrain_id
	var/list/sys = system_type
	return system_tag_terrain(islist(sys) ? sys["tag"] : null)

/// Odpowiednik typu układu NSV (tag z starsystem.dm) wśród terenów kafli; null = zwykły układ
/proc/system_tag_terrain(tag)
	switch(tag)
		if("debris", "icefield")
			return "meteor"
		if("pirate", "graveyard")
			return "junk"
		if("nebula", "gas")
			return "nebula"
		if("hazardous")
			return "estorm"
		if("quasar")
			return "storm"
		if("radioactive")
			return "rad"
		if("supernova", "demonstar")
			return "flare"
		if("accretiondisk")
			return "grav"
		if("blackhole")
			return "bh"
	return null

/// Wagi typów stref dla terenu; null = teren bez własnych stref
/proc/get_overmap_hazard_table(terrain)
	switch(terrain)
		if("meteor") // Pole asteroid
			return list(
				/obj/effect/overmap_anomaly/hazard/speed/asteroid_field/minor = 3,
				/obj/effect/overmap_anomaly/hazard/speed/asteroid_field = 4,
				/obj/effect/overmap_anomaly/hazard/speed/asteroid_field/major = 2,
			)
		if("junk") // Złomowisko
			return list(
				/obj/effect/overmap_anomaly/hazard/speed/debris_field = 5,
				/obj/effect/overmap_anomaly/hazard/speed/debris_field/dense = 2,
				/obj/effect/overmap_anomaly/hazard/speed/asteroid_field/minor = 1,
			)
		if("nebula")
			return list(
				/obj/effect/overmap_anomaly/hazard/nebula = 8,
				/obj/effect/overmap_anomaly/hazard/ion_storm = 1,
			)
		if("estorm", "storm") // Burza elektryczna i burza jonowa
			return list(/obj/effect/overmap_anomaly/hazard/ion_storm = 1)
		if("rad")
			return list(/obj/effect/overmap_anomaly/hazard/radiation = 1)
		if("flare") // Aktywność gwiazdy
			return list(/obj/effect/overmap_anomaly/hazard/solar_flare = 1)
		if("grav")
			return list(/obj/effect/overmap_anomaly/hazard/gravity_well = 1)
		if("comet")
			return list(/obj/effect/overmap_anomaly/hazard/speed/debris_field = 1)
		if("bh") // Czarna dziura: jak dawniej w układach NSV
			return list(
				/obj/effect/overmap_anomaly/hazard/speed/debris_field = 3,
				/obj/effect/overmap_anomaly/hazard/ion_storm = 1,
			)
	return null

/// Ile stref dostaje teren z własną tabelą
/proc/get_overmap_hazard_count(terrain)
	switch(terrain)
		if("meteor", "junk", "nebula")
			return rand(1, 3)
		if("storm")
			return rand(2, 3)
		if("estorm", "flare", "rad")
			return rand(1, 2)
		if("grav", "comet")
			return 1
	return rand(0, 2)

/// Rozmieszcza strefy zagrożeń w układzie. Zwraca listę stref utworzonych od razu (w układzie bez nikogo trafiają
/// do nullspace jak inne anomalie; w zajętym spawn_anomaly() nic nie zwraca, strefa i tak powstaje).
/datum/star_system/proc/spawn_hazard_zones(terrain)
	. = list()
	if(!GLOB.overmap_hazards_enabled || (terrain in GLOB.hazard_quiet_terrains))
		return
	var/list/table = get_overmap_hazard_table(terrain)
	var/amount
	if(table)
		amount = get_overmap_hazard_count(terrain)
	else
		if(!prob(HAZARD_RANDOM_ZONE_CHANCE))
			return
		table = list(
			/obj/effect/overmap_anomaly/hazard/speed/asteroid_field/minor = 3,
			/obj/effect/overmap_anomaly/hazard/speed/debris_field = 2,
			/obj/effect/overmap_anomaly/hazard/nebula = 2,
			/obj/effect/overmap_anomaly/hazard/ion_storm = 1,
		)
		amount = 1
	for(var/i in 1 to amount)
		var/zone = SSstar_system.spawn_anomaly(pickweight(table), src)
		if(zone)
			. += zone

/datum/star_system/apply_system_effects()
	. = ..()
	if(hazards_generated)
		return
	hazards_generated = TRUE
	// Układ startowy graczy zostaje spokojny. Kafel mapy hex ma strefy ze swojego terenu, nawet gdy jego pusty układ
	// nie dostaje zwykłych anomalii (STARSYSTEM_NO_ANOMALIES).
	if(name == SSstar_system.player_start_system_name())
		return
	if(!hex_terrain_id && CHECK_BITFIELD(system_traits, STARSYSTEM_NO_ANOMALIES))
		return
	spawn_hazard_zones(hazard_terrain())

#undef HAZARD_RANDOM_ZONE_CHANCE
