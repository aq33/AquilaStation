// AQUILA - pogoda na powierzchni jednej planety. Zwykła pogoda działa na całych poziomach Z, a powierzchnie planet dzielą
// poziom rezerwacji z innymi planetami i z parkingami promów w locie. Pogoda planety dostaje pustą listę poziomów
// (bazowe procedury nie ruszają wtedy żadnego obszaru ani gracza), a te nadpisania dokładają jej jeden obszar planety
// i komunikaty tylko dla ludzi w tym obszarze.

/datum/weather
	/// Obszar powierzchni planety, na którym działa ta pogoda (null = zwykła pogoda na poziomach Z)
	var/area/planet_area

/datum/weather/Destroy(force)
	planet_area = null
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

/datum/weather/start()
	var/old_stage = stage
	. = ..()
	if(planet_area && old_stage < MAIN_STAGE)
		planet_announce(weather_message, weather_sound)

/datum/weather/wind_down()
	var/old_stage = stage
	. = ..()
	if(planet_area && old_stage < WIND_DOWN_STAGE)
		planet_announce(end_message, end_sound)

/datum/weather/can_weather_act(mob/living/act_on)
	if(!planet_area)
		return ..()
	if(immunity_type in act_on.weather_immunities)
		return FALSE
	return get_area(act_on) == planet_area
