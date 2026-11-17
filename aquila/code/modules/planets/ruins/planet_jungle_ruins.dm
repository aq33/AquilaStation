// AQUILA: ruiny i greeble planet dżunglowych przeniesione z Shiptesta (shiptest-ss13/Shiptest, kod AGPLv3, mapy jak kod,
// grafiki CC BY-SA 3.0): _maps/RandomRuins/JungleRuins/, _maps/templates/greebles/jungle/, code/datums/ruins/jungle.dm,
// code/datums/mapgen/greebles/jungleplanet.dm i łaty trawy z code/datums/mapgen/greeble.dm.
// Zasady przeróbki jak przy planecie lodowej (ruins/planet_ice_ruins.dm). Wielka Dziura ma, jak w Shiptest, wagę 0:
// nie wypada losowo, wypada jej wersja zajęta przez piratów.

/datum/map_template/ruin/planet_jungle
	prefix = "aquila/_maps/RandomRuins/PlanetJungle/"
	cost = 10

/datum/map_template/ruin/planet_jungle/syndicate
	name = "Bunkier Maruderów"
	id = "planet_jungle_syndicate"
	description = "Bunkier atomowy z czasów Wojny Międzykorporacyjnej. Kiedyś należał do Maruderów Gorlex, dziś zajmuje go Klika Ramziego."
	suffix = "planet_jungle_syndicate.dmm"

/datum/map_template/ruin/planet_jungle/swampfever
	name = "Splądrowane Bagno SRM"
	id = "planet_jungle_swampfever"
	description = "Splądrowana osada SRM opanowana przez bandę zbirów. Zjedli mieszkańców."
	suffix = "planet_jungle_swampfever.dmm"

/datum/map_template/ruin/planet_jungle/bombed_starport
	name = "Opuszczona Baza Lotnicza"
	id = "planet_jungle_bombed_starport"
	description = "Opuszczona baza lotnicza z czasów wojny, częściowo zniszczona i z powrotem zajęta przez Klikę Ramziego."
	suffix = "planet_jungle_bombed_starport.dmm"

/datum/map_template/ruin/planet_jungle/cavecrew
	name = "Kryjówka w Jaskini"
	id = "planet_jungle_cavecrew"
	description = "Baza piratów ukryta w jaskini. Nie wyglądają na przyjaznych."
	suffix = "planet_jungle_cavecrew.dmm"

/datum/map_template/ruin/planet_jungle/serene_hunts
	name = "Łowisko Serene"
	id = "planet_jungle_serene_hunts"
	description = "Najlepszy ośrodek łowiecki Serene Outdoors. Był nim, dopóki zwierzęta nie uciekły."
	suffix = "planet_jungle_serene_hunts.dmm"

/datum/map_template/ruin/planet_jungle/bighole
	name = "Wielka Dziura"
	id = "planet_jungle_bighole"
	description = "Ogromny odwiert CLIP-LAND w dżungli, w którym bada się i pobiera próbki bogactw planety."
	suffix = "planet_jungle_bighole.dmm"
	placement_weight = 0

/datum/map_template/ruin/planet_jungle/bighole_frontiersmen
	name = "Zajęta Wielka Dziura"
	id = "planet_jungle_bighole_frontiersmen"
	description = "Ogromny odwiert CLIP-LAND w dżungli, napadnięty przez piratów."
	suffix = "planet_jungle_bighole_frontiersmen.dmm"

/datum/map_template/ruin/planet_jungle/depot
	name = "Skład Zaopatrzenia N&S"
	id = "planet_jungle_depot"
	description = "Wojenny skład zaopatrzenia, w którym zostały już tylko roboty."
	suffix = "planet_jungle_depot.dmm"

/// Ruiny tego typu planety (nazwa -> szablon) z szablonów wczytanych przez SSmapping
GLOBAL_LIST_EMPTY(planet_jungle_ruin_templates)

/proc/get_planet_jungle_ruin_templates()
	if(!length(GLOB.planet_jungle_ruin_templates))
		for(var/name in SSmapping.ruins_templates)
			var/datum/map_template/ruin/ruin = SSmapping.ruins_templates[name]
			if(istype(ruin, /datum/map_template/ruin/planet_jungle))
				GLOB.planet_jungle_ruin_templates[name] = ruin
	return GLOB.planet_jungle_ruin_templates

// Greeble (spawnery stawiane przez biomy, wagi map jak w Shiptest)

/obj/effect/greeble_spawner/jungle
	greeble_maps = list(
		"aquila/_maps/greebles/jungle/greeble_jungle_1.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_2.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_3.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_4.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_5.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_6.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_7.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_8.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_9.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_10.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_11.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_12.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_13.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_14.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_15.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_16.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_17.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_18.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_19.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_20.dmm" = 1,
		"aquila/_maps/greebles/jungle/greeble_jungle_21.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_22.dmm" = 1,
		"aquila/_maps/greebles/jungle/greeble_jungle_23.dmm" = 1,
		"aquila/_maps/greebles/jungle/greeble_jungle_24.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_25.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_26.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_27.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_28.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_29.dmm" = 1,
		"aquila/_maps/greebles/jungle/greeble_jungle_30.dmm" = 5,
	)

/// Greeble jaskiń
/obj/effect/greeble_spawner/jungle/cave
	greeble_maps = list(
		"aquila/_maps/greebles/jungle/greeble_junglecave_1.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_junglecave_2.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_junglecave_3.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_junglecave_4.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_junglecave_5.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_junglecave_6.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_junglecave_7.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_junglecave_8.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_junglecave_9.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_junglecave_10.dmm" = 5,
	)

/// Greeble z anomaliami
/obj/effect/greeble_spawner/jungle/anomaly
	greeble_maps = list(
		"aquila/_maps/greebles/jungle/greeble_jungle_anomaly_1.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_anomaly_2.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_anomaly_3.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_anomaly_4.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_anomaly_5.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_anomaly_6.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_anomaly_7.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_anomaly_8.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_anomaly_9.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_anomaly_10.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_anomaly_11.dmm" = 5,
		"aquila/_maps/greebles/jungle/greeble_jungle_anomaly_12.dmm" = 5,
	)

/// Łata ciemnej trawy dżungli (pędzel 3 x 3 po polach takiego typu jak startowe)
/obj/effect/greeble_spawner/grass_patch/dark_jungle
	name = "spawner łaty ciemnej trawy dżungli"
	turf_to_spread = /turf/open/floor/plating/asteroid/dirt/grass/jungle/dark
	big_brush = TRUE
	only_spread_on_spawning_turf = TRUE
	max_turfs_to_spread = 16
	min_turfs_to_spread = 3
	patch_direction_locked = FALSE
	chance_to_terminate = 0
	terminate_chance_add = 3

/obj/effect/greeble_spawner/grass_patch/dark_jungle/thin
	big_brush = FALSE
	patch_direction_locked = TRUE

/// Łata żółtej trawy
/obj/effect/greeble_spawner/grass_patch/yellow_jungle
	name = "spawner łaty żółtej trawy"
	turf_to_spread = /turf/open/floor/plating/asteroid/dirt/grass/jungle/yellow
	max_turfs_to_spread = 5
	min_turfs_to_spread = 2
	chance_to_terminate = 5
	terminate_chance_add = 8

// Obszary ruin. Pomieszczenia z APC (unpowered = zasilanie z APC ruiny), powered = zawsze zasilone, jak w Shiptest.

/area/ruin/unpowered/planet_jungle/airbase
	name = "Opuszczona Baza Lotnicza"
	icon_state = "away"

/area/ruin/unpowered/planet_jungle/airbase/armory
	name = "Baza Lotnicza – Zbrojownia"
	icon_state = "armory"

/area/ruin/unpowered/planet_jungle/airbase/cargo
	name = "Baza Lotnicza – Magazyn"
	icon_state = "cargo_warehouse"

/area/ruin/unpowered/planet_jungle/airbase/dorms
	name = "Baza Lotnicza – Część Mieszkalna"
	icon_state = "away"

/area/ruin/unpowered/planet_jungle/airbase/engineering
	name = "Baza Lotnicza – Inżynieria"
	icon_state = "engine"

/area/ruin/unpowered/planet_jungle/airbase/hangar
	name = "Baza Lotnicza – Hangar"
	icon_state = "away"

/area/ruin/unpowered/planet_jungle/airbase/med
	name = "Baza Lotnicza – Ambulatorium"
	icon_state = "medbay"

/area/ruin/unpowered/planet_jungle/airbase/shed
	name = "Baza Lotnicza – Szopa"
	icon_state = "away"

/area/ruin/unpowered/planet_jungle/airbase/tower
	name = "Baza Lotnicza – Wieża Dowodzenia"
	icon_state = "away"

/area/ruin/unpowered/planet_jungle/airbase/turrets
	name = "Baza Lotnicza – Stanowiska Dział"
	icon_state = "away"

/area/ruin/unpowered/planet_jungle/bighole/ferry
	name = "Wielka Dziura – Uzbrojony Prom"
	icon_state = "away"

/area/ruin/unpowered/planet_jungle/bighole/vent
	name = "Wielka Dziura – Wymiennik Powietrza"
	icon_state = "away"

/area/ruin/unpowered/planet_jungle/cavecrew
	name = "Kryjówka w Jaskini"
	icon_state = "away"

/area/ruin/unpowered/planet_jungle/cavecrew/bridge
	name = "Kryjówka w Jaskini – Mostek"
	icon_state = "bridge"

/area/ruin/unpowered/planet_jungle/cavecrew/cargo
	name = "Kryjówka w Jaskini – Ładownia"
	icon_state = "away"

/area/ruin/unpowered/planet_jungle/cavecrew/dormitories
	name = "Kryjówka w Jaskini – Sypialnie"
	icon_state = "crew_quarters"

/area/ruin/unpowered/planet_jungle/cavecrew/engineering
	name = "Kryjówka w Jaskini – Inżynieria"
	icon_state = "engine"

/area/ruin/unpowered/planet_jungle/cavecrew/hallway
	name = "Kryjówka w Jaskini – Korytarz"
	icon_state = "hallC"

/area/ruin/unpowered/planet_jungle/cavecrew/ship
	name = "Kryjówka w Jaskini – Statek"
	icon_state = "away"

/area/ruin/unpowered/planet_jungle/depot/canteen
	name = "Skład N&S – Stołówka"
	icon_state = "kitchen"

/area/ruin/unpowered/planet_jungle/depot/electrical
	name = "Skład N&S – Rozdzielnia"
	icon_state = "engine"

/area/ruin/unpowered/planet_jungle/depot/offices
	name = "Skład N&S – Biura"
	icon_state = "away"

/area/ruin/unpowered/planet_jungle/depot/residential
	name = "Skład N&S – Część Mieszkalna"
	icon_state = "away"

/area/ruin/unpowered/planet_jungle/depot/supply_office
	name = "Skład N&S – Biuro Zaopatrzenia"
	icon_state = "bridge"

/area/ruin/unpowered/planet_jungle/depot/warehouse_1
	name = "Skład N&S – Magazyn 1"
	icon_state = "cargo_warehouse"

/area/ruin/unpowered/planet_jungle/depot/warehouse_2
	name = "Skład N&S – Magazyn 2"
	icon_state = "cargo_warehouse"

/area/ruin/unpowered/planet_jungle/depot/warehouse_3
	name = "Skład N&S – Magazyn 3"
	icon_state = "cargo_warehouse"

/area/ruin/unpowered/planet_jungle/swamp
	name = "Bagno SRM – Budynek Główny"
	icon_state = "away"

/area/ruin/unpowered/planet_jungle/swamp/butchery
	name = "Bagno SRM – Szopa Rzeźnika"
	icon_state = "away"

/area/ruin/unpowered/planet_jungle/swamp/colligne
	name = "Bagno SRM – Pokład Colligne"
	icon_state = "away"

/area/ruin/unpowered/planet_jungle/swamp/crew
	name = "Bagno SRM – Kwatery Myśliwych"
	icon_state = "crew_quarters"

/area/ruin/unpowered/planet_jungle/swamp/flamebearer
	name = "Bagno SRM – Pokład Płomieniarza"
	icon_state = "away"

/area/ruin/unpowered/planet_jungle/syndifort
	name = "Bunkier Maruderów"
	icon_state = "away"

/area/ruin/unpowered/planet_jungle/syndifort/armory
	name = "Bunkier Maruderów – Zbrojownia"
	icon_state = "armory"

/area/ruin/unpowered/planet_jungle/syndifort/atmos
	name = "Bunkier Maruderów – Filtracja Powietrza"
	icon_state = "away"

/area/ruin/unpowered/planet_jungle/syndifort/canteen
	name = "Bunkier Maruderów – Stołówka"
	icon_state = "kitchen"

/area/ruin/unpowered/planet_jungle/syndifort/dorms
	name = "Bunkier Maruderów – Sypialnie"
	icon_state = "crew_quarters"

/area/ruin/unpowered/planet_jungle/syndifort/electrical
	name = "Bunkier Maruderów – Rozdzielnia"
	icon_state = "engine"

/area/ruin/unpowered/planet_jungle/syndifort/jerry
	name = "Bunkier Maruderów – Sterownia"
	icon_state = "away"

/area/ruin/unpowered/planet_jungle/syndifort/medical
	name = "Bunkier Maruderów – Izba Chorych"
	icon_state = "medbay"

/area/ruin/unpowered/planet_jungle/syndifort/storage
	name = "Bunkier Maruderów – Magazyn"
	icon_state = "cargo_warehouse"

/area/ruin/powered/planet_jungle/bighole/canteen
	name = "Wielka Dziura – Stołówka"
	icon_state = "kitchen"

/area/ruin/powered/planet_jungle/bighole/cargo
	name = "Wielka Dziura – Magazyn"
	icon_state = "cargo_warehouse"

/area/ruin/powered/planet_jungle/bighole/dormitory
	name = "Wielka Dziura – Sypialnia"
	icon_state = "crew_quarters"

/area/ruin/powered/planet_jungle/bighole/electrical
	name = "Wielka Dziura – Rozdzielnia"
	icon_state = "engine"

/area/ruin/powered/planet_jungle/bighole/lab
	name = "Wielka Dziura – Laboratorium Geologiczne"
	icon_state = "away"

/area/ruin/powered/planet_jungle/bighole/medbay
	name = "Wielka Dziura – Ambulatorium"
	icon_state = "medbay"

/area/ruin/powered/planet_jungle/bighole/office
	name = "Wielka Dziura – Biuro Łączności"
	icon_state = "bridge"

/area/ruin/powered/planet_jungle/bighole/secoffice
	name = "Wielka Dziura – Biuro Ochrony"
	icon_state = "bridge"

/area/ruin/powered/planet_jungle/bighole/shed
	name = "Wielka Dziura – Szopa Techniczna"
	icon_state = "away"

/area/ruin/powered/planet_jungle/hunts/barn
	name = "Łowisko Serene – Stodoła"
	icon_state = "away"

/area/ruin/powered/planet_jungle/hunts/canteen
	name = "Łowisko Serene – Restauracja"
	icon_state = "kitchen"

/area/ruin/powered/planet_jungle/hunts/gate
	name = "Łowisko Serene – Brama"
	icon_state = "away"

/area/ruin/powered/planet_jungle/hunts/gun_shop
	name = "Łowisko Serene – Sklep Myśliwski"
	icon_state = "away"

/area/ruin/powered/planet_jungle/hunts/hotel
	name = "Łowisko Serene – Hotel"
	icon_state = "away"

/area/ruin/powered/planet_jungle/hunts/sec
	name = "Łowisko Serene – Punkt Kontrolny"
	icon_state = "away"

/area/ruin/powered/planet_jungle/hunts/shed
	name = "Łowisko Serene – Szopa Gajowego"
	icon_state = "away"

/area/ruin/powered/planet_jungle/hunts/shuttle
	name = "Łowisko Serene – Prom"
	icon_state = "away"

/area/ruin/powered/planet_jungle/hunts/toilet
	name = "Łowisko Serene – Umywalnia"
	icon_state = "away"
