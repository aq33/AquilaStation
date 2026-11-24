// AQUILA - planeta wodna i wodna planeta karłowata z Shiptesta (shiptest-ss13/Shiptest, AGPLv3): code/modules/overmap/
// planets/planet_types.dm (/datum/planet_type/water i /waterball), generator w biomes/water.dm.
// Różnice względem Shiptesta:
// - Shiptest nie ma ruin planety wodnej; tu stają ruiny plaży przerobione na lodowatą atmosferę tej planety
//   (ruins/planet_beach_ruins.dm);
// - lądowiska trafiają na wyspy, a gdy ich brak, generator osusza kwadrat morza do skały (ground_turf_type);
// - wyspy to jaskinie z otwartym niebem, więc mają słabe światło jak powierzchnia (w Shiptest prawie czarne #09121a,
//   tu odrobinę jaśniejsze, żeby dało się coś zobaczyć bez latarki);
// - planeta nie jest celem misji dowództwa: schron i punkt badawczy stawiają się tylko na lądzie powierzchni, którego
//   tu nie ma (wyspy to jaskinie);
// - wodna planeta karłowata to w Shiptest jedno pole morza bez niczego; tu ma rzadkie wysepki z bogatszymi żyłami
//   (cel wypraw górniczych) i sztorm bez końca.

/datum/planet_type/water
	sky_state = "water"
	sky_clouds = "clouds_thick"
	sky_atmosphere_color = "#6fa8ff"
	name = "planeta wodna"
	desc = "Świat w całości przykryty lodowatym, wzburzonym oceanem. Pod wyspami ciągną się jaskinie z kieszeniami powietrza."
	overmap_icon_state = "planet_ocean"
	overmap_color = "#4a6fa8"
	generator_type = /datum/planet_generator/water
	surface_area_type = /area/planet/surface/water
	cave_area_type = /area/planet/surface/cave/water
	atmosphere_desc = "oddychalna, lodowata"
	temperature_desc = "około -18°C, woda bliska zamarzania"
	hazard_desc = "głęboka woda bez lądu, sztormy z piorunami, karpie, pająki i niedźwiedzie w jaskiniach"
	weather_types = list(
		/datum/weather/planet/rain/heavy/storm = 50,
		/datum/weather/planet/rain/heavy/storm/severe = 30,
	)
	weather_delay_min = 3 MINUTES
	weather_delay_max = 6 MINUTES
	ruin_budget = 0
	ground_turf_type = /turf/open/floor/plating/asteroid/waterplanet
	vein_root = /obj/structure/vein/waterplanet
	mission_veins = list(
		"1" = /obj/structure/vein/waterplanet,
		"2" = /obj/structure/vein/waterplanet/classtwo,
		"3" = /obj/structure/vein/waterplanet/classthree,
	)
	mission_target = FALSE
	system_tags = list("planet_earth" = 2, "nebula" = 1)
	fixed_systems = list("Viiman")

/datum/planet_type/water/get_ruin_templates()
	return list()

/datum/planet_type/water/get_main_ruin_templates()
	return get_planet_sea_ruin_templates(/datum/map_template/ruin/planet_water)

/area/planet/surface/water
	name = "Wzburzone Morze"
	lighting_overlay_colour = "#1c3550"
	lighting_overlay_opacity = 255
	sound_environment = SOUND_ENVIRONMENT_FOREST

/// Wyspy i jaskinie pod nimi: wyloty jaskiń mają otwarte niebo, więc słabe światło jak morze
/area/planet/surface/cave/water
	name = "Wyspy i Groty"
	lighting_overlay_colour = "#1c3550"
	lighting_overlay_opacity = 191

/// Wodna planeta karłowata (Shiptest: waterball)
/datum/planet_type/dwarf/water
	sky_state = "water"
	sky_clouds = "clouds"
	sky_atmosphere_color = "#6fa8ff"
	name = "wodna planeta karłowata"
	desc = "Mały świat przykryty chłodną wodą i jeszcze chłodniejszymi sztormami. Z orbity widać tylko kilka wysepek."
	overmap_icon_state = "planet_small"
	overmap_color = "#6f9ed6"
	generator_type = /datum/planet_generator/water/dwarf
	surface_area_type = /area/planet/surface/water
	cave_area_type = /area/planet/surface/cave/water
	atmosphere_desc = "oddychalna, lodowata"
	temperature_desc = "około -18°C, woda bliska zamarzania"
	hazard_desc = "głęboka woda bez lądu, nieustający sztorm z piorunami, karpie"
	weather_types = list(/datum/weather/planet/rain/heavy/storm/intense = 1)
	weather_delay_min = 10 SECONDS
	weather_delay_max = 30 SECONDS
	ground_turf_type = /turf/open/floor/plating/asteroid/waterplanet
	vein_root = /obj/structure/vein/waterplanet
	mission_veins = list(
		"1" = /obj/structure/vein/waterplanet,
		"2" = /obj/structure/vein/waterplanet/classtwo,
		"3" = /obj/structure/vein/waterplanet/classthree,
	)
	mission_target = FALSE
	system_tags = list("safe" = 1, "planet_earth" = 1)
	fixed_systems = list("Arbeia")
