// AQUILA - księżyc, pole asteroid i słaby sygnał (typy z Shiptesta: moon, asteroid, spaceruin). Wszystkie bez powietrza:
// lądowanie i wyjście tylko w skafandrach, więc nie są celem misji z próbkami flory i atmosfery (mission_target).
// Pole asteroid i słaby sygnał to próżnia z bryłami skał: lądowiska zasypują przestrzeń gruntem asteroidy
// (próżnia ma planet_landing_hazard), a planeta ma krawędź z gęstego pasa asteroid zamiast skał.

/// Ruiny z danej gałęzi typów (nazwa -> szablon), z szablonów wczytanych przez SSmapping
/proc/planet_ruin_templates_of(ruin_type)
	. = list()
	for(var/name in SSmapping.ruins_templates)
		var/datum/map_template/ruin/ruin = SSmapping.ruins_templates[name]
		if(istype(ruin, ruin_type))
			.[name] = ruin

/datum/planet_type/moon
	name = "księżyc"
	desc = "Martwy glob bez powietrza, pokryty regolitem i kraterami po meteorytach. Pod skałą biegną żyły rud, a w kraterach stoją resztki dawnych baz."
	overmap_icon_state = "planet_small"
	overmap_color = "#d4d4dc"
	generator_type = /datum/planet_generator/moon
	surface_area_type = /area/planet/surface/moon
	cave_area_type = /area/planet/surface/cave/moon
	atmosphere_desc = "brak (próżnia)"
	temperature_desc = "skrajne wahania między dniem a nocą"
	hazard_desc = "próżnia, fauna przy żyłach rud (bazyliszki, hivelordy, siarkodemony, karpie)"
	ground_turf_type = /turf/open/floor/plating/asteroid/moon_coarse
	vein_root = /obj/structure/vein/moon
	mission_veins = list(
		"1" = /obj/structure/vein/moon,
		"2" = /obj/structure/vein/moon/classtwo,
		"3" = /obj/structure/vein/moon/classthree,
		"4" = /obj/structure/vein/moon/classfour,
	)
	system_tags = list("safe" = 2, "debris" = 1, "rocks" = 1)
	fixed_systems = list("Sol", "Phobos", "Deimos")
	mission_target = FALSE

/datum/planet_type/moon/get_main_ruin_templates()
	return planet_ruin_templates_of(/datum/map_template/ruin/planet_moon)

/datum/planet_type/asteroid
	name = "pole asteroid"
	desc = "Rój skalnych brył dryfujących w próżni. Większe bryły kryją żyły rud i legowiska karpi."
	overmap_icon_state = "planet_exploded"
	overmap_color = "#b4a996"
	generator_type = /datum/planet_generator/asteroid
	surface_area_type = /area/planet/surface/asteroid
	cave_area_type = /area/planet/surface/cave/asteroid
	edge_turf_type = /turf/closed/indestructible/rock/planet_edge/asteroid
	atmosphere_desc = "brak (próżnia)"
	temperature_desc = "chłód próżni"
	hazard_desc = "próżnia, ławice karpi, fauna górnicza w bryłach (goliaty, bazyliszki, hivelordy)"
	ground_turf_type = /turf/open/floor/plating/asteroid/airless
	vein_root = /obj/structure/vein/asteroid
	mission_veins = list(
		"1" = /obj/structure/vein/asteroid,
		"2" = list(/obj/structure/vein/asteroid/classtwo = 2, /obj/structure/vein/asteroid/classtwo/rare = 1),
		"3" = list(/obj/structure/vein/asteroid/classthree = 2, /obj/structure/vein/asteroid/classthree/rare = 1),
	)
	system_tags = list("debris" = 4, "rocks" = 4)
	fixed_systems = list("Zharkov", "Bemike")
	mission_target = FALSE

/// Słaby sygnał: pole asteroid z ruiną kosmiczną (stacja, wrak, magazyn) jako ruiną główną
/datum/planet_type/asteroid/space_signal
	name = "słaby sygnał"
	desc = "Na skanerach tylko słaby, przerywany sygnał z pola szczątków. Coś tam wciąż nadaje."
	overmap_color = "#7f8ea3"
	hazard_desc = "próżnia, nieznani mieszkańcy źródła sygnału, ławice karpi"
	system_tags = list("pirate" = 3, "hazardous" = 2, "blackhole" = 2, "debris" = 1, "graveyard" = 1)
	fixed_systems = list("Veneto", "Abious I")

/datum/planet_type/asteroid/space_signal/get_main_ruin_templates()
	return planet_ruin_templates_of(/datum/map_template/ruin/planet_space)

/area/planet/surface/moon
	name = "Powierzchnia Księżyca"
	lighting_overlay_colour = "#ffffff"
	ambience_index = AMBIENCE_SPACE
	sound_environment = SOUND_AREA_SPACE

/area/planet/surface/cave/moon
	name = "Jaskinie Księżyca"
	sound_environment = SOUND_AREA_ASTEROID

/area/planet/surface/asteroid
	name = "Pole Asteroid"
	lighting_overlay_colour = "#dfe6ff"
	ambience_index = AMBIENCE_SPACE
	sound_environment = SOUND_AREA_SPACE

/area/planet/surface/cave/asteroid
	name = "Wnętrze Asteroidy"
	sound_environment = SOUND_AREA_ASTEROID
