/// AQUILA - rozmieszczenie stref zagrożeń w układach gwiezdnych (typy: hazards/hazard_types.dm).
/// Strefy powstają raz, przy apply_system_effects() (generate_anomaly() 15 s po wczytaniu układu albo badlands),
/// zależnie od typu układu; 0-3 na układ. spawn_hazard_zones(terrain) przyjmuje dowolny "teren": dziś tag typu układu,
/// po mapie FTL z kaflami hex (aq33/AquilaStation#638) można jej podać typ kafla i dopisać go w get_overmap_hazard_table().

/// Szansa (%) na jedną losową strefę w układzie, którego typ nie ma własnej tabeli
#define HAZARD_RANDOM_ZONE_CHANCE 10

/datum/star_system
	/// AQUILA - strefy zagrożeń już rozmieszczone (apply_system_effects() bywa wołane więcej niż raz)
	var/hazards_generated = FALSE

/// Wagi typów stref dla terenu (tag typu układu z starsystem.dm); null = teren bez własnych stref
/proc/get_overmap_hazard_table(terrain)
	switch(terrain)
		if("debris") // "Pole asteroid"
			return list(
				/obj/effect/overmap_anomaly/hazard/speed/asteroid_field/minor = 3,
				/obj/effect/overmap_anomaly/hazard/speed/asteroid_field = 4,
				/obj/effect/overmap_anomaly/hazard/speed/asteroid_field/major = 2,
				/obj/effect/overmap_anomaly/hazard/speed/debris_field = 2,
			)
		if("pirate") // "Szczątki"
			return list(
				/obj/effect/overmap_anomaly/hazard/speed/debris_field = 5,
				/obj/effect/overmap_anomaly/hazard/speed/debris_field/dense = 2,
				/obj/effect/overmap_anomaly/hazard/speed/asteroid_field/minor = 1,
			)
		if("icefield")
			return list(
				/obj/effect/overmap_anomaly/hazard/speed/asteroid_field/minor = 4,
				/obj/effect/overmap_anomaly/hazard/speed/asteroid_field = 3,
			)
		if("nebula")
			return list(
				/obj/effect/overmap_anomaly/hazard/nebula = 8,
				/obj/effect/overmap_anomaly/hazard/ion_storm = 1,
			)
		if("gas")
			return list(
				/obj/effect/overmap_anomaly/hazard/nebula = 4,
				/obj/effect/overmap_anomaly/hazard/ion_storm = 1,
			)
		if("hazardous")
			return list(
				/obj/effect/overmap_anomaly/hazard/ion_storm = 3,
				/obj/effect/overmap_anomaly/hazard/solar_flare = 2,
				/obj/effect/overmap_anomaly/hazard/speed/debris_field = 1,
			)
		if("quasar", "accretiondisk")
			return list(
				/obj/effect/overmap_anomaly/hazard/ion_storm = 4,
				/obj/effect/overmap_anomaly/hazard/solar_flare = 2,
			)
		if("radioactive", "supernova", "demonstar")
			return list(
				/obj/effect/overmap_anomaly/hazard/solar_flare = 4,
				/obj/effect/overmap_anomaly/hazard/ion_storm = 1,
			)
		if("blackhole", "graveyard")
			return list(
				/obj/effect/overmap_anomaly/hazard/speed/debris_field = 3,
				/obj/effect/overmap_anomaly/hazard/ion_storm = 1,
			)
	return null

/// Ile stref dostaje teren z własną tabelą: pola i mgławice zwykle 1-3, reszta 0-2
/proc/get_overmap_hazard_count(terrain)
	switch(terrain)
		if("debris", "pirate", "nebula")
			return rand(1, 3)
	return rand(0, 2)

/// Rozmieszcza strefy zagrożeń w układzie. Zwraca listę stref utworzonych od razu (w układzie bez nikogo trafiają
/// do nullspace jak inne anomalie; w zajętym spawn_anomaly() nic nie zwraca, strefa i tak powstaje).
/datum/star_system/proc/spawn_hazard_zones(terrain)
	. = list()
	if(!GLOB.overmap_hazards_enabled)
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
	// Układ startowy graczy zostaje spokojny
	if(name == SSstar_system.player_start_system_name() || CHECK_BITFIELD(system_traits, STARSYSTEM_NO_ANOMALIES))
		return
	var/list/sys = system_type
	spawn_hazard_zones(islist(sys) ? sys["tag"] : null)

#undef HAZARD_RANDOM_ZONE_CHANCE
