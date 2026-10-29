/**********************Mine areas**************************/

/area/mine
	icon_state = "mining"
	has_gravity = STANDARD_GRAVITY
	lighting_colour_tube = "#ffe8d2"
	lighting_colour_bulb = "#ffdcb7"
	area_flags = VALID_TERRITORY | UNIQUE_AREA | FLORA_ALLOWED

/area/mine/explored
	name = "Kopalnia"
	icon_state = "explored"
	always_unpowered = TRUE
	requires_power = TRUE
	poweralm = FALSE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	outdoors = TRUE
	flags_1 = NONE
	ambience_index = AMBIENCE_MINING
	min_ambience_cooldown = 70 SECONDS
	max_ambience_cooldown = 220 SECONDS
	sound_environment = SOUND_AREA_STANDARD_STATION
	area_flags = VALID_TERRITORY | UNIQUE_AREA

/area/mine/unexplored
	name = "Kopalnia"
	icon_state = "unexplored"
	always_unpowered = TRUE
	requires_power = TRUE
	poweralm = FALSE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	outdoors = TRUE
	flags_1 = NONE
	ambience_index = AMBIENCE_MINING
	min_ambience_cooldown = 70 SECONDS
	max_ambience_cooldown = 220 SECONDS
	area_flags = VALID_TERRITORY | UNIQUE_AREA | FLORA_ALLOWED | CAVES_ALLOWED

/area/mine/lobby
	name = "Stacja Górnicza"

/area/mine/storage
	name = "Magazyn Stacji Górniczej"

/area/mine/production
	name = "Skrzydło Sterburty Stacji Górniczej"
	icon_state = "mining_production"

/area/mine/abandoned
	name = "Opuszczona Stacja Górnicza"

/area/mine/living_quarters
	name = "Skrzydło Burty Stacji Górniczej"
	icon_state = "mining_living"

/area/mine/eva
	name = "Magazyn EVA Stacji Górniczej"
	icon_state = "mining_eva"

/area/mine/maintenance
	name = "Łączność Stacji Górniczej"
	lighting_colour_tube = "#edfdff"
	lighting_colour_bulb = "#dafffd"

/area/mine/cafeteria
	name = "Kafeteria Stacji Górniczej"

/area/mine/hydroponics
	name = "Hydroponika Stacji Górniczej"

/area/mine/sleeper
	name = "Awaryjny Uśpiacz Stacji Górniczej"

/area/mine/laborcamp
	name = "Obóz Pracy"

/area/mine/laborcamp/security
	name = "Ochrona Obozu Pracy"
	icon_state = "security"
	ambience_index = AMBIENCE_DANGER

//This is a placeholder for the lavaland sci area. Whoever is here after me, I have made you some additional areas to work with.
//You are free to rename these and change their icons. My job is done here.

/area/mine/science
	name = "Placówka Badawcza"
	icon_state = "medresearch"
	requires_power = TRUE	//Remove this when there will be pre-built APCs in the area.

/area/mine/science/shuttledock
	name = "Placówka"

/area/mine/science/xenoarch
	name = "Laboratorium Ksenoarcheologii Placówki"

/area/mine/science/elevator	//for going to lavaland depths if there will be those
	name = "Winda Placówki"

/area/mine/science/experimentor
	name = "Laboratorium Eksperymentatora Placówki"

/area/mine/science/heavyexperiment
	name = "Wzmocniona Komora Placówki"

/area/mine/science/robotics
	name = "Robotyka Placówki"






/**********************Lavaland Areas**************************/

/area/lavaland
	icon_state = "mining"
	has_gravity = STANDARD_GRAVITY
	flags_1 = NONE
	sound_environment = SOUND_AREA_LAVALAND
	area_flags = VALID_TERRITORY | UNIQUE_AREA | FLORA_ALLOWED

/area/lavaland/surface
	name = "Lavaland"
	icon_state = "explored"
	always_unpowered = TRUE
	poweralm = FALSE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	requires_power = TRUE
	ambience_index = AMBIENCE_MINING
	min_ambience_cooldown = 70 SECONDS
	max_ambience_cooldown = 220 SECONDS

/area/lavaland/underground
	name = "Jaskinie Lavalandu"
	icon_state = "unexplored"
	always_unpowered = TRUE
	requires_power = TRUE
	poweralm = FALSE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	ambience_index = AMBIENCE_MINING
	min_ambience_cooldown = 70 SECONDS
	max_ambience_cooldown = 220 SECONDS

/area/lavaland/surface/outdoors
	name = "Pustkowia Lavalandu"
	outdoors = TRUE

/area/lavaland/surface/outdoors/unexplored //monsters and ruins spawn here
	icon_state = "unexplored"
	area_flags = VALID_TERRITORY | UNIQUE_AREA | CAVES_ALLOWED | FLORA_ALLOWED | MOB_SPAWN_ALLOWED

/area/lavaland/surface/outdoors/unexplored/danger //megafauna will also spawn here
	icon_state = "danger"
	area_flags = VALID_TERRITORY | UNIQUE_AREA | CAVES_ALLOWED | FLORA_ALLOWED | MOB_SPAWN_ALLOWED | MEGAFAUNA_SPAWN_ALLOWED
	map_generator = /datum/map_generator/cave_generator/lavaland

/area/lavaland/surface/outdoors/explored
	name = "Obóz Pracy na Lavalandzie"
	area_flags = VALID_TERRITORY | UNIQUE_AREA
