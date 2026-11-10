// Syrena burzy radiacyjnej z BeeStation/BeeStation-Hornet#13796.
// Obszary stacji dostają pętlę syreny na czas burzy (w tunelach serwisowych przytłumioną),
// a gracze słyszą ją przez weather_listener dodawany przy wejściu w moba.

/// obszar -> typ pętli syreny, wypełniane przez /datum/weather/rad_storm/telegraph()
GLOBAL_LIST_EMPTY(rad_storm_sounds)

/datum/looping_sound/rad_alert_inside
	mid_sounds = list('aquila/sound/weather/radstorm/inside/alert.ogg' = 1)
	mid_length = 20
	volume = 100
	extra_range = 30

/datum/looping_sound/rad_alert_outside
	mid_sounds = list('aquila/sound/weather/radstorm/outside/alert.ogg' = 1)
	mid_length = 20
	volume = 100
	extra_range = 30

/mob/Login()
	. = ..()
	AddElement(/datum/element/weather_listener, /datum/weather/rad_storm, ZTRAIT_STATION, GLOB.rad_storm_sounds)
