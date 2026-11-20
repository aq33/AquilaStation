// AQUILA - typy planet. Typ mówi, jak planeta wygląda na overmapie, co pokazuje skan, jak generuje się powierzchnia
// (generator i biomy), jaka jest na niej pogoda, jakie ruiny mogą na niej stanąć, jakie żyły dostają misje i w jakich
// układach się pojawia (planet_spawning.dm). Typy z Shiptesta są w biomes/ (tabela biomów) i tutaj (dane typu).

/datum/planet_type
	/// Nazwa typu w opisie planety
	var/name = "planeta"
	/// Opis z bliska (po skanie)
	var/desc = "Planeta."
	/// Stan ikony z nsv13/icons/overmap/stellarbodies/planets.dmi i zabarwienie (null = bez), żeby typy bez własnego
	/// sprite'a różniły się od siebie
	var/overmap_icon_state = "planet_rocky"
	var/overmap_color
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
	/// Bok kwadratu powierzchni (krawędź się wlicza)
	var/surface_size = PLANET_SURFACE_SIZE
	/// Grunt pod lądowiska i miejsca misji (zamiast lawy, skał i głębokiej wody)
	var/ground_turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	/// Wspólny rodzic żył tej planety: wiertło misji pobiera próbki tylko z nich
	var/vein_root
	/// Żyły do misji wiertniczych: klasa (tekst) -> typ albo lista typów z wagami. Klasa "4" to cel Głębokiego odwiertu.
	/// Typ bez żył nie jest celem misji wiertniczych.
	var/list/mission_veins
	/// W jakich układach się pojawia: znacznik układu (tag z system_type albo parallax_property) -> waga
	var/list/system_tags
	/// Nazwane układy z mapy gwiezdnej, w których ta planeta stoi zawsze (nazwy jak w starmap.json)
	var/list/fixed_systems
	/// Ozdoba układu (gazowe olbrzymy): dochodzi obok zwykłej planety, a nie zamiast niej
	var/scenery = FALSE
	/// Czy misje planetarne (kolonia, rozpoznanie) mogą wybrać ten typ
	var/mission_target = TRUE
	/// Typ, który jest tylko wspólnym rodzicem (np. planety karłowate): bez prototypu, nie pojawia się w układach
	var/abstract_type = /datum/planet_type

/// Szablony małych ruin z budżetu (nazwa -> szablon)
/datum/planet_type/proc/get_ruin_templates()
	return list()

/// Szablony ruiny głównej przy górnej krawędzi, jak w Shiptest (nazwa -> szablon). Bez nich ruina główna jest losowana
/// z małych ruin.
/datum/planet_type/proc/get_main_ruin_templates()
	return get_ruin_templates()

/// Pełny opis dla skanu
/datum/planet_type/proc/scan_text()
	return "Typ: [name]. Atmosfera: [atmosphere_desc]. Temperatura: [temperature_desc]. Zagrożenia: [hazard_desc]."

/// Wyposażenie lądowiska po wyczyszczeniu terenu (platformy olbrzymów: barierki, znaczniki, syfon gazu)
/datum/planet_type/proc/decorate_landing_zone(datum/planet_surface/surface, turf/zone_center, radius)
	return

/// Typ żyły danej klasy do misji (null, gdy planeta takiej nie ma)
/datum/planet_type/proc/get_mission_vein(vein_class)
	var/vein = LAZYACCESS(mission_veins, "[vein_class]")
	if(islist(vein))
		return pickweight(vein)
	return vein

/// Wspólne instancje typów planet do wyboru typu (dane typu się nie zmieniają)
GLOBAL_LIST_INIT(planet_type_prototypes, init_planet_type_prototypes())

/proc/init_planet_type_prototypes()
	. = list()
	for(var/datum/planet_type/planet_type as anything in subtypesof(/datum/planet_type))
		if(planet_type == initial(planet_type.abstract_type))
			continue
		.[planet_type] = new planet_type

/// Pole, na którym nie da się stać ani wylądować: ściana, lawa, przepaść, głęboka woda (planet_landing_hazard)
/proc/is_planet_hazard_turf(turf/T)
	if(!isopenturf(T) || islava(T) || ischasm(T))
		return TRUE
	var/turf/open/open_turf = T
	return open_turf.planet_landing_hazard

/datum/planet_type/lava
	sky_state = "lava"
	sky_clouds = "clouds_wisps"
	sky_cloud_color = "#5a4a48"
	sky_atmosphere_color = "#ff7a3a"
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
	vein_root = /obj/structure/vein/lavaland
	mission_veins = list(
		"1" = /obj/structure/vein/lavaland,
		"2" = list(/obj/structure/vein/lavaland/classtwo = 2, /obj/structure/vein/lavaland/classtwo/rare = 1),
		"3" = list(/obj/structure/vein/lavaland/classthree = 2, /obj/structure/vein/lavaland/classthree/rare = 1),
		"4" = /obj/structure/vein/lavaland/classfour,
	)
	system_tags = list("demonstar" = 3, "accretiondisk" = 3, "quasar" = 2, "supernova" = 2, "hazardous" = 1, "pirate" = 1)
	fixed_systems = list("Tortuga", "Ethor", "Bemike", "Demon's Maw")

/datum/planet_type/lava/get_ruin_templates()
	return SSmapping.lava_ruins_templates

/datum/planet_type/lava/get_main_ruin_templates()
	return get_planet_lava_ruin_templates()

// Obszary powierzchni. Nie są UNIQUE_AREA, więc każda planeta tworzy własne instancje (pogoda i lądowiska działają
// na obszarze jednej planety). Stałe, lekko zabarwione światło dzienne jak w Shiptest, jaskinie ciemne. W Shiptest
// każde pole powierzchni świeci (light_power 0,2-1), tu nakładka obszaru: przezroczystość = light_power × 255.

/area/planet/surface
	name = "Powierzchnia Planety"
	icon_state = "explored"
	outdoors = TRUE
	area_flags = CAVES_ALLOWED | FLORA_ALLOWED | MOB_SPAWN_ALLOWED
	lighting_overlay_colour = "#b8c4cf"
	lighting_overlay_opacity = 204
	/// Bez szumu okrętu (domyślny ambient_buzz każdego obszaru): na planecie grał w pętli po wyjściu z promu
	ambient_buzz = null

/area/planet/surface/Initialize(mapload)
	. = ..()
	// Nakładka obszaru tylko rozjaśnia obraz. Widoczność pola w BYOND zależy od luminosity, a obszar z requires_power
	// dostaje 0: bez tego gracz widział tylko pola w promieniu see_in_dark, a dalej czerń (jak w jaskini).
	if(lighting_overlay_opacity)
		luminosity = 1
	// Pogoda ustawia obszarowi alpha i kolor (nakładka opadów), a nakładka światła dziennego jest overlayem obszaru i to
	// dziedziczyła: deszcz przyciemniał dzień z 204 do ok. 60, burze barwiły światło
	if(lighting_overlay)
		cut_overlay(lighting_overlay)
		lighting_overlay.appearance_flags |= RESET_ALPHA | RESET_COLOR
		add_overlay(lighting_overlay)

/area/planet/surface/lava
	name = "Pustkowia Wulkaniczne"
	lighting_overlay_colour = "#cfa98a"
	lighting_overlay_opacity = 153
	sound_environment = SOUND_AREA_LAVALAND

/area/planet/surface/cave
	name = "Jaskinie Planety"
	outdoors = FALSE
	lighting_overlay_opacity = 0

/area/planet/surface/cave/lava
	name = "Jaskinie Wulkaniczne"

/// Krawędź powierzchni planety: dalej nie ma nic
/turf/closed/indestructible/rock/planet_edge
	name = "nieprzebyte skały"
	desc = "Pasmo skał tak strome i gęste, że dalej nie da się przejść. Za nim teren jest niezbadany."
	baseturfs = /turf/closed/indestructible/rock/planet_edge
