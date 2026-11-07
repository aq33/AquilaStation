// Losowy silnik na Trawniku (Serendipity) i Padalcu (Snake), jak na Atlasie (/obj/effect/spawner/room/atlasengine).
// Spawner stoi w lewym dolnym rogu slotu i wybiera szablon o tym samym rozmiarze, dlatego każdy statek ma własny, unikalny rozmiar slotu.
// Kafelki wspólne dla wszystkich wariantów są w szablonach template_noop i zostają z mapy bazowej.

/obj/effect/spawner/room/serendipity_engine
	name = "serendipity engine spawner"
	room_width = 13
	room_height = 19

/obj/effect/spawner/room/snake_engine
	name = "snake engine spawner"
	room_width = 18
	room_height = 10

/datum/map_template/random_room/aq_engine_ser_01
	name = "Trawnik - silnik Tesli"
	room_id = "aq_engine_ser_01_tesla"
	mappath = 'aquila/_maps/random_engines/serendipity_engine_tesla.dmm'
	centerspawner = FALSE
	template_height = 19
	template_width = 13

/datum/map_template/random_room/aq_engine_ser_02
	name = "Trawnik - napęd Stormdrive"
	room_id = "aq_engine_ser_02_stormdrive"
	mappath = 'aquila/_maps/random_engines/serendipity_engine_stormdrive.dmm'
	centerspawner = FALSE
	template_height = 19
	template_width = 13

/datum/map_template/random_room/aq_engine_ser_03
	name = "Trawnik - silnik supermaterii"
	room_id = "aq_engine_ser_03_supermatter"
	mappath = 'aquila/_maps/random_engines/serendipity_engine_supermatter.dmm'
	centerspawner = FALSE
	template_height = 19
	template_width = 13

/datum/map_template/random_room/aq_engine_snk_01
	name = "Padalec - napęd Stormdrive"
	room_id = "aq_engine_snk_01_stormdrive"
	mappath = 'aquila/_maps/random_engines/snake_engine_stormdrive.dmm'
	centerspawner = FALSE
	template_height = 10
	template_width = 18

/datum/map_template/random_room/aq_engine_snk_03
	name = "Padalec - silnik supermaterii"
	room_id = "aq_engine_snk_03_supermatter"
	mappath = 'aquila/_maps/random_engines/snake_engine_supermatter.dmm'
	centerspawner = FALSE
	template_height = 10
	template_width = 18
