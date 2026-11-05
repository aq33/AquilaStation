// Reverb for areas that had none (/area/sound_environment). NSV13 ship areas were "dry": shots and voices did not echo.
// A subtype keeps its own value, so these only fill the gaps.

/area/nsv
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/nsv/atc
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/nsv/boarding_pod
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/nsv/briefingroom
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/nsv/crew_quarters/heads/maa
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/nsv/engine/engine_room
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/nsv/hanger
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/nsv/hanger/storage
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/nsv/hanger/notkmcstupidhanger/atc
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/nsv/hanger/notkmcstupidhanger/pilot
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/nsv/hanger/notkmcstupidhanger/launchtube
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED

/area/nsv/magazine
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/nsv/shuttle
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/nsv/shuttle/fob/lounge
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/nsv/shuttle/fob/quarters
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/nsv/weapons/artillery
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/nsv/weapons/gauss
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/nsv/weapons/nuclear
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/nsv/weapons/ordnance
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/nsv/weapons/equipment_room
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/nsv/weapons/weapons_secure_storage
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/nsv/weapons/munitions_lounge
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/nsv/weapons/observation_deck
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/nostromo
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/nostromo/maintenance
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED

/area/nostromo/hangar
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/nostromo/galley/coldroom
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/nostromo/crew_quarters
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/hammurabi
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/hammurabi/maintenance
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED

/area/hammurabi/hangar
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/hammurabi/bar
	sound_environment = SOUND_AREA_WOODFLOOR

/area/hammurabi/armoury
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/tcommsat
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/library
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/vacant_room
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/teleporter
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

// Pogłos z kształtu pomieszczenia: obszar z ogólnym pogłosem stacji (SOUND_AREA_STANDARD_STATION) przy pierwszym dźwięku
// dostaje preset według liczby kafelków, szerokości i podłogi. Ręczne wartości powyżej (inne niż ogólny) zostają.

/// Mały pokój: do tylu kafelków
#define AREA_SOUND_SMALL 30
/// Duża hala: od tylu kafelków
#define AREA_SOUND_LARGE 300
/// Większych obszarów nie przeglądamy (koszt jednorazowy), zostają z ogólnym pogłosem
#define AREA_SOUND_MAX_SCAN 3000
/// Korytarz: taka część kafelków ma szerokość najwyżej 3 w jednej osi
#define AREA_SOUND_NARROW_FRACTION 0.6
/// Miękka podłoga (dywan, drewno, trawa): od takiej części kafelków
#define AREA_SOUND_SOFT_FRACTION 0.4

/area
	/// Czy pogłos z kształtu był już policzony
	var/sound_environment_shaped = FALSE

/// Pogłos dla dźwięków słyszanych w tym obszarze
/area/proc/get_sound_environment()
	if(!sound_environment_shaped)
		sound_environment_shaped = TRUE
		if(sound_environment == SOUND_AREA_STANDARD_STATION)
			sound_environment = shape_sound_environment()
	return sound_environment

/// Preset pogłosu z kształtu obszaru
/area/proc/shape_sound_environment()
	var/total = 0
	var/narrow = 0
	var/soft = 0
	for(var/turf/T in src)
		if(isclosedturf(T))
			continue
		total++
		if(total > AREA_SOUND_MAX_SCAN)
			return sound_environment
		if(istype(T, /turf/open/floor/carpet) || istype(T, /turf/open/floor/wood) || istype(T, /turf/open/floor/grass) || istype(T, /turf/open/floor/bamboo))
			soft++
		if(area_sound_open_span(T, NORTH, SOUTH) <= 3 || area_sound_open_span(T, EAST, WEST) <= 3)
			narrow++
	return classify_sound_environment(total, total ? narrow / total : 0, total ? soft / total : 0)

/// Ile kafelków tego obszaru jest otwartych w linii przez T w dwóch przeciwnych kierunkach (najwyżej 7)
/area/proc/area_sound_open_span(turf/T, dir_a, dir_b)
	. = 1
	for(var/dir in list(dir_a, dir_b))
		var/turf/current = T
		for(var/i in 1 to 3)
			current = get_step(current, dir)
			if(!current || isclosedturf(current) || current.loc != src)
				break
			.++

/// Preset z liczby otwartych kafelków i części wąskich oraz miękkich
/proc/classify_sound_environment(turfs, narrow_fraction, soft_fraction)
	var/is_soft = soft_fraction >= AREA_SOUND_SOFT_FRACTION
	if(turfs <= AREA_SOUND_SMALL)
		return is_soft ? SOUND_AREA_SMALL_SOFTFLOOR : SOUND_AREA_SMALL_ENCLOSED
	if(narrow_fraction >= AREA_SOUND_NARROW_FRACTION)
		return is_soft ? SOUND_AREA_LARGE_SOFTFLOOR : SOUND_ENVIRONMENT_HALLWAY
	if(turfs >= AREA_SOUND_LARGE)
		return is_soft ? SOUND_AREA_LARGE_SOFTFLOOR : SOUND_AREA_LARGE_ENCLOSED
	return is_soft ? SOUND_AREA_MEDIUM_SOFTFLOOR : SOUND_AREA_STANDARD_STATION

#undef AREA_SOUND_SMALL
#undef AREA_SOUND_LARGE
#undef AREA_SOUND_MAX_SCAN
#undef AREA_SOUND_NARROW_FRACTION
#undef AREA_SOUND_SOFT_FRACTION
