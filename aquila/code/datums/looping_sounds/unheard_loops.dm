// AQUILA - pętle dźwiękowe nie grają, gdy w zasięgu nie ma żadnego słuchacza.
// Każdy zasilony komputer gra co 0,5 s, SMES i grzejnik co 0,2 s. Bez tego sprawdzenia każde takie zagranie
// losowało plik, tworzyło /sound i przeszukiwało z-levele w playsound(), choć zwykle nikt go nie słyszał.
// Sprawdzenie jest szersze niż w playsound() (bez hearers() i can_hear()), więc pomija tylko zagrania,
// które i tak nie trafiłyby do nikogo. Pętla dalej tyka, więc po przyjściu gracza gra od następnego zagrania.

/datum/looping_sound
	/// Pomijaj zagranie, gdy w zasięgu nie ma nikogo, kto mógłby je usłyszeć
	var/skip_unheard = TRUE
	/// Z-level, dla którego policzono heard_zs
	var/heard_z
	/// extra_range, dla którego policzono heard_zs
	var/heard_extra_range
	/// Z-levele w zasięgu dźwięku z heard_z (jak w playsound())
	var/list/heard_zs

/datum/looping_sound/sound_loop(starttime)
	if(skip_unheard && !direct && !(max_loops && world.time >= starttime + mid_length * max_loops) && !can_be_heard())
		return
	return ..()

/// Czy playsound() z parenta dotarłby do kogokolwiek (te same listy i odległość co w playsound())
/datum/looping_sound/proc/can_be_heard()
	var/turf/source_turf = get_turf(parent)
	if(!source_turf)
		return FALSE
	var/max_distance = SOUND_RANGE + extra_range
	if(source_turf.z != heard_z || extra_range != heard_extra_range)
		heard_z = source_turf.z
		heard_extra_range = extra_range
		heard_zs = get_zs_in_range(source_turf.z, max_distance / (MULTI_Z_DISTANCE + 1))
	for(var/z in heard_zs)
		for(var/mob/listener as anything in SSmobs.clients_by_zlevel[z])
			if(get_dist(listener, source_turf) <= max_distance)
				return TRUE
		for(var/mob/listener as anything in SSmobs.dead_players_by_zlevel[z])
			if(get_dist(listener, source_turf) <= max_distance)
				return TRUE
	return FALSE

// Gra do wszystkich graczy naraz, niezależnie od położenia
/datum/looping_sound/sacrament
	skip_unheard = FALSE

// Własna lista słuchaczy z playsound_range()
/datum/looping_sound/advanced
	skip_unheard = FALSE
