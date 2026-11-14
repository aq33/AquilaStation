// AQUILA - typy planet. Typ mówi, jak planeta wygląda na overmapie, co pokazuje skan, jak generuje się powierzchnia
// (generator i biomy), jaka jest na niej pogoda i jakie ruiny mogą na niej stanąć. Na razie jest tylko planeta
// wulkaniczna; kolejne typy z Shiptesta dojdą, kiedy szkielet będzie sprawdzony w grze.

/datum/planet_type
	/// Nazwa typu w opisie planety
	var/name = "planeta"
	/// Opis z bliska (po skanie)
	var/desc = "Planeta."
	/// Stan ikony z nsv13/icons/overmap/stellarbodies/planets.dmi
	var/overmap_icon_state = "planet_rocky"
	/// Czy da się na niej wylądować (gazowe olbrzymy: nie)
	var/can_land = TRUE
	/// Generator powierzchni
	var/generator_type = /datum/planet_generator
	/// Obszary powierzchni i jaskiń (każda planeta dostaje własne instancje)
	var/surface_area_type = /area/planet/surface
	var/cave_area_type = /area/planet/surface/cave
	/// Pole pod całą powierzchnią, zanim zadziała generator, i krawędź planety
	var/edge_turf_type = /turf/closed/indestructible/rock/planet_edge
	/// Opis atmosfery, temperatury i zagrożeń dla skanu (pokazywany załodze)
	var/atmosphere_desc = "nieznana"
	var/temperature_desc = "nieznana"
	var/hazard_desc = "brak danych"
	/// Pogoda: typ -> waga. Pusta lista = bez pogody
	var/list/weather_types
	/// Przerwa między burzami
	var/weather_delay_min = 5 MINUTES
	var/weather_delay_max = 10 MINUTES
	/// Budżet ruin (koszt ruin z ich szablonów)
	var/ruin_budget = 0

/// Szablony ruin, które mogą stanąć na tym typie planety (nazwa -> szablon)
/datum/planet_type/proc/get_ruin_templates()
	return list()

/// Pełny opis dla skanu
/datum/planet_type/proc/scan_text()
	return "Typ: [name]. Atmosfera: [atmosphere_desc]. Temperatura: [temperature_desc]. Zagrożenia: [hazard_desc]."

/datum/planet_type/lava
	name = "planeta wulkaniczna"
	desc = "Gorący świat bazaltu i rzek lawy, spowity popiołem. Bogaty w rudy, ale burze popiołu zabijają każdego bez osłony."
	overmap_icon_state = "planet_red"
	generator_type = /datum/planet_generator/lava
	surface_area_type = /area/planet/surface/lava
	cave_area_type = /area/planet/surface/cave/lava
	atmosphere_desc = "rzadka, nie do oddychania bez maski"
	temperature_desc = "umiarkowana przy gruncie, lawa i gejzery"
	hazard_desc = "burze popiołu, lawa, wrogia fauna (goliaty, legiony, obserwatorzy)"
	weather_types = list(/datum/weather/ash_storm = 90, /datum/weather/ash_storm/emberfall = 10)
	ruin_budget = 4

/datum/planet_type/lava/get_ruin_templates()
	return SSmapping.lava_ruins_templates

// Obszary powierzchni. Nie są UNIQUE_AREA, więc każda planeta tworzy własne instancje (pogoda i lądowiska działają
// na obszarze jednej planety). Stałe, lekko zabarwione światło jak w Shiptest, jaskinie ciemne.

/area/planet/surface
	name = "Powierzchnia planety"
	icon_state = "explored"
	outdoors = TRUE
	area_flags = CAVES_ALLOWED | FLORA_ALLOWED | MOB_SPAWN_ALLOWED
	lighting_overlay_colour = "#b8c4cf"
	lighting_overlay_opacity = 90

/area/planet/surface/lava
	name = "Pustkowia wulkaniczne"
	lighting_overlay_colour = "#cfa98a"
	sound_environment = SOUND_AREA_LAVALAND

/area/planet/surface/cave
	name = "Jaskinie planety"
	outdoors = FALSE
	lighting_overlay_opacity = 0

/area/planet/surface/cave/lava
	name = "Jaskinie wulkaniczne"

/// Krawędź powierzchni planety: dalej nie ma nic
/turf/closed/indestructible/rock/planet_edge
	name = "nieprzebyte skały"
	desc = "Pasmo skał tak strome i gęste, że dalej nie da się przejść. Za nim teren jest niezbadany."
	baseturfs = /turf/closed/indestructible/rock/planet_edge
