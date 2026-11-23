// AQUILA - pogoda na powierzchni jednej planety. Zwykła pogoda działa na całych poziomach Z, a powierzchnie planet dzielą
// poziom rezerwacji z innymi planetami i z parkingami promów w locie. Pogoda planety dostaje pustą listę poziomów
// (bazowe procedury nie ruszają wtedy żadnego obszaru ani gracza), a te nadpisania dokładają jej jeden obszar planety
// i komunikaty tylko dla ludzi w tym obszarze.
// Z pogody Shiptesta (code/datums/weather/weather.dm, AGPLv3) doszły: pętle dźwiękowe etapów osobno na zewnątrz
// i pod dachem (jaskinie i ruiny planety), grzmoty, gaszenie płonących deszczem, przezroczystość i własny plik ikon
// nakładki. Bez zasłaniania widoku (opacity) z „blocking”: przy całym obszarze kosztowało za dużo, burze to sama nakładka.

/// Co ile pogoda planety odświeża słuchaczy, grzmi i gasi
#define PLANET_WEATHER_TICK (2 SECONDS)

/datum/weather
	/// Obszar powierzchni planety, na którym działa ta pogoda (null = zwykła pogoda na poziomach Z)
	var/area/planet_area
	/// Obszary pod dachem na tej planecie (jaskinie, ruiny): słychać w nich stłumione pętle
	var/list/planet_indoor_areas
	/// Pętle dźwiękowe planety: słaba (zapowiedź i koniec) i silna (główny etap), na zewnątrz i pod dachem
	var/datum/looping_sound/planet_sound_weak_outside
	var/datum/looping_sound/planet_sound_weak_inside
	var/datum/looping_sound/planet_sound_active_outside
	var/datum/looping_sound/planet_sound_active_inside
	/// Szansa na grzmot co PLANET_WEATHER_TICK w głównym etapie
	var/thunder_chance = 0
	/// O ile co PLANET_WEATHER_TICK spadają płomienie płonących na zewnątrz (deszcz)
	var/fire_suppression = 0
	/// Plik ikon nakładki (null = icons/effects/weather_effects.dmi) i jej przezroczystość
	var/overlay_icon
	var/overlay_alpha = 255
	/// Obszar -> typ pętli dla bieżącego etapu (wspólna lista wszystkich słuchaczy)
	var/list/planet_playlist
	var/planet_tick_timer

/datum/weather/Destroy(force)
	planet_stop()
	planet_area = null
	planet_indoor_areas = null
	return ..()

/// Komunikat i dźwięk pogody dla ludzi w obszarze planety
/datum/weather/proc/planet_announce(message, sound_file)
	if(!planet_area || (!message && !sound_file))
		return
	for(var/mob/player as anything in GLOB.player_list)
		if(get_area(player) != planet_area)
			continue
		if(message)
			to_chat(player, message)
		if(sound_file)
			SEND_SOUND(player, sound(sound_file))

/datum/weather/telegraph()
	var/old_stage = stage
	. = ..()
	if(!planet_area || old_stage == STARTUP_STAGE)
		return
	impacted_areas = list(planet_area)
	update_areas()
	planet_announce(telegraph_message, telegraph_sound)
	planet_playlist = list()
	planet_update_playlist()
	planet_tick_timer = addtimer(CALLBACK(src, PROC_REF(planet_tick)), PLANET_WEATHER_TICK, TIMER_LOOP | TIMER_STOPPABLE)
	planet_tick()

/datum/weather/start()
	var/old_stage = stage
	. = ..()
	if(planet_area && old_stage < MAIN_STAGE)
		planet_announce(weather_message, weather_sound)
		planet_update_playlist()

/datum/weather/wind_down()
	var/old_stage = stage
	. = ..()
	if(planet_area && old_stage < WIND_DOWN_STAGE)
		planet_announce(end_message, end_sound)
		planet_update_playlist()

/datum/weather/end()
	var/old_stage = stage
	. = ..()
	if(planet_area && old_stage != END_STAGE)
		planet_stop()

/datum/weather/can_weather_act(mob/living/act_on)
	if(!planet_area)
		return ..()
	if(immunity_type in act_on.weather_immunities)
		return FALSE
	return get_area(act_on) == planet_area

/datum/weather/update_areas()
	. = ..()
	if(!planet_area)
		return
	for(var/area/impacted as anything in impacted_areas)
		if(stage == END_STAGE)
			impacted.alpha = initial(impacted.alpha)
			continue
		impacted.alpha = overlay_alpha
		if(overlay_icon)
			impacted.icon = overlay_icon

/// Pętle bieżącego etapu dla obszarów planety. Lista jest wspólna, więc słuchacze dostają tylko sygnał zmiany.
/datum/weather/proc/planet_update_playlist()
	if(!planet_playlist)
		return
	var/outside_loop = stage == MAIN_STAGE ? planet_sound_active_outside : planet_sound_weak_outside
	var/inside_loop = stage == MAIN_STAGE ? planet_sound_active_inside : planet_sound_weak_inside
	planet_playlist.Cut()
	if(outside_loop)
		planet_playlist[planet_area] = outside_loop
	if(inside_loop)
		for(var/area/indoor as anything in planet_indoor_areas)
			if(indoor)
				planet_playlist[indoor] = inside_loop
	for(var/datum/component/area_sound_manager/manager as anything in planet_sound_managers())
		SEND_SIGNAL(manager.parent, COMSIG_PLANET_WEATHER_CHANGED)

/// Nowi gracze na planecie dostają menedżer dźwięku, w głównym etapie grzmi, deszcz gasi płonących na zewnątrz
/datum/weather/proc/planet_tick()
	if(!planet_area || stage == END_STAGE)
		return
	if(length(planet_playlist))
		var/z_level = planet_area.z
		for(var/mob/player as anything in GLOB.player_list)
			var/turf/player_turf = get_turf(player)
			if(!player_turf || player_turf.z != z_level || !(player_turf.loc in planet_playlist))
				continue
			// Menedżer znika przy zmianie poziomu i wylogowaniu: po powrocie gracz dostaje nowy
			var/datum/component/area_sound_manager/manager = player.GetComponent(/datum/component/area_sound_manager)
			if(manager?.area_to_looping_type == planet_playlist)
				continue
			player.AddComponent(/datum/component/area_sound_manager, planet_playlist, COMSIG_PLANET_WEATHER_CHANGED, COMSIG_MOB_LOGOUT, list(z_level))
	if(stage != MAIN_STAGE)
		return
	if(thunder_chance && prob(thunder_chance))
		planet_thunder()
	if(fire_suppression)
		for(var/mob/living/burning in GLOB.mob_living_list)
			if(burning.on_fire && get_area(burning) == planet_area)
				burning.adjust_fire_stacks(-fire_suppression)
				if(burning.fire_stacks <= 0)
					burning.ExtinguishMob()

/// Grzmot: głośno na zewnątrz, ciszej pod dachem
/datum/weather/proc/planet_thunder()
	var/thunder_sound = pick(
		'aquila/sound/effects/thunder/thunder1.ogg', 'aquila/sound/effects/thunder/thunder2.ogg', 'aquila/sound/effects/thunder/thunder3.ogg',
		'aquila/sound/effects/thunder/thunder4.ogg', 'aquila/sound/effects/thunder/thunder5.ogg', 'aquila/sound/effects/thunder/thunder6.ogg',
		'aquila/sound/effects/thunder/thunder7.ogg', 'aquila/sound/effects/thunder/thunder8.ogg', 'aquila/sound/effects/thunder/thunder9.ogg',
		'aquila/sound/effects/thunder/thunder10.ogg')
	for(var/mob/player as anything in GLOB.player_list)
		var/area/player_area = get_area(player)
		if(player_area == planet_area)
			SEND_SOUND(player, sound(thunder_sound, volume = 65))
		else if(player_area in planet_indoor_areas)
			SEND_SOUND(player, sound(thunder_sound, volume = 35))

/// Koniec pogody: bez pętli i bez timera
/datum/weather/proc/planet_stop()
	if(planet_tick_timer)
		deltimer(planet_tick_timer)
		planet_tick_timer = null
	for(var/datum/component/area_sound_manager/manager as anything in planet_sound_managers())
		qdel(manager)
	planet_playlist = null

/// Menedżery dźwięku graczy grające pętle tej pogody
/datum/weather/proc/planet_sound_managers()
	. = list()
	if(!planet_playlist)
		return
	for(var/mob/player as anything in GLOB.player_list)
		var/datum/component/area_sound_manager/manager = player.GetComponent(/datum/component/area_sound_manager)
		if(manager?.area_to_looping_type == planet_playlist)
			. += manager

// Burza popiołu z Lavalandu ma na planecie te same pętle, które na Lavalandzie gra jej lista ash_storm_sounds
/datum/weather/ash_storm
	planet_sound_weak_outside = /datum/looping_sound/weak_outside_ashstorm
	planet_sound_weak_inside = /datum/looping_sound/weak_inside_ashstorm
	planet_sound_active_outside = /datum/looping_sound/active_outside_ashstorm
	planet_sound_active_inside = /datum/looping_sound/active_inside_ashstorm

// Pętle deszczu i wiatru z Shiptesta (code/datums/looping_sounds/weather.dm). Odstęp między fragmentami równy ich
// długości (Shiptest gra je na zakładkę co 0,75 s, nasza pętla nie skraca dźwięków).

/datum/looping_sound/planet_wind
	mid_sounds = list(
		'aquila/sound/weather/wind/wind1.ogg' = 1,
		'aquila/sound/weather/wind/wind2.ogg' = 1,
		'aquila/sound/weather/wind/wind3.ogg' = 1,
		'aquila/sound/weather/wind/wind4.ogg' = 1,
		'aquila/sound/weather/wind/wind5.ogg' = 1,
		'aquila/sound/weather/wind/wind6.ogg' = 1,
	)
	mid_length = 10 SECONDS
	volume = 50

/datum/looping_sound/planet_wind/indoors
	volume = 30

/datum/looping_sound/planet_rain
	mid_sounds = list(
		'aquila/sound/weather/rain/rain_mid_01.ogg' = 1,
		'aquila/sound/weather/rain/rain_mid_02.ogg' = 1,
		'aquila/sound/weather/rain/rain_mid_03.ogg' = 1,
		'aquila/sound/weather/rain/rain_mid_04.ogg' = 1,
		'aquila/sound/weather/rain/rain_mid_05.ogg' = 1,
		'aquila/sound/weather/rain/rain_mid_06.ogg' = 1,
	)
	mid_length = 2 SECONDS
	start_sound = 'aquila/sound/weather/rain/rain_start.ogg'
	start_length = 6 SECONDS
	end_sound = 'aquila/sound/weather/rain/rain_end.ogg'
	volume = 50

/datum/looping_sound/planet_rain/no_start
	start_sound = null
	start_length = 0

/datum/looping_sound/planet_rain/indoors
	mid_sounds = list(
		'aquila/sound/weather/rain/rain_inside_mid_01.ogg' = 1,
		'aquila/sound/weather/rain/rain_inside_mid_02.ogg' = 1,
		'aquila/sound/weather/rain/rain_inside_mid_03.ogg' = 1,
		'aquila/sound/weather/rain/rain_inside_mid_04.ogg' = 1,
		'aquila/sound/weather/rain/rain_inside_mid_05.ogg' = 1,
		'aquila/sound/weather/rain/rain_inside_mid_06.ogg' = 1,
	)
	start_sound = 'aquila/sound/weather/rain/rain_indoors_start.ogg'
	end_sound = 'aquila/sound/weather/rain/rain_indoors_end.ogg'
	volume = 30

/datum/looping_sound/planet_rain/weak
	mid_sounds = list(
		'aquila/sound/weather/rain/rain_weak_mid_01.ogg' = 1,
		'aquila/sound/weather/rain/rain_weak_mid_02.ogg' = 1,
		'aquila/sound/weather/rain/rain_weak_mid_03.ogg' = 1,
		'aquila/sound/weather/rain/rain_weak_mid_04.ogg' = 1,
		'aquila/sound/weather/rain/rain_weak_mid_05.ogg' = 1,
	)
	start_sound = 'aquila/sound/weather/rain/rain_weak_start.ogg'
	start_length = 12 SECONDS
	end_sound = null
	volume = 40

/datum/looping_sound/planet_rain/weak/indoors
	mid_sounds = list(
		'aquila/sound/weather/rain/rain_weak_inside_mid_01.ogg' = 1,
		'aquila/sound/weather/rain/rain_weak_inside_mid_02.ogg' = 1,
		'aquila/sound/weather/rain/rain_weak_inside_mid_03.ogg' = 1,
		'aquila/sound/weather/rain/rain_weak_inside_mid_04.ogg' = 1,
		'aquila/sound/weather/rain/rain_weak_inside_mid_05.ogg' = 1,
	)
	start_sound = 'aquila/sound/weather/rain/rain_indoors_start.ogg'
	start_length = 6 SECONDS
	end_sound = 'aquila/sound/weather/rain/rain_indoors_end.ogg'
	volume = 30

/datum/looping_sound/planet_rain/storm
	mid_sounds = list(
		'aquila/sound/weather/rain/storm_outdoors_1.ogg' = 1,
		'aquila/sound/weather/rain/storm_outdoors_2.ogg' = 1,
	)
	mid_length = 10 SECONDS
	start_sound = null
	start_length = 0
	end_sound = null
	volume = 50

/datum/looping_sound/planet_rain/storm/indoors
	mid_sounds = list(
		'aquila/sound/weather/rain/storm_indoors_1.ogg' = 1,
		'aquila/sound/weather/rain/storm_indoors_2.ogg' = 1,
	)
	volume = 30

#undef PLANET_WEATHER_TICK
