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
	engine_type = ENGINE_CHOICE_TESLA
	centerspawner = FALSE
	template_height = 19
	template_width = 13

/datum/map_template/random_room/aq_engine_ser_02
	name = "Trawnik - napęd Stormdrive"
	room_id = "aq_engine_ser_02_stormdrive"
	mappath = 'aquila/_maps/random_engines/serendipity_engine_stormdrive.dmm'
	engine_type = ENGINE_CHOICE_STORMDRIVE
	centerspawner = FALSE
	template_height = 19
	template_width = 13

/datum/map_template/random_room/aq_engine_ser_03
	name = "Trawnik - silnik supermaterii"
	room_id = "aq_engine_ser_03_supermatter"
	mappath = 'aquila/_maps/random_engines/serendipity_engine_supermatter.dmm'
	engine_type = ENGINE_CHOICE_SUPERMATTER
	centerspawner = FALSE
	template_height = 19
	template_width = 13

/datum/map_template/random_room/aq_engine_snk_01
	name = "Padalec - napęd Stormdrive"
	room_id = "aq_engine_snk_01_stormdrive"
	mappath = 'aquila/_maps/random_engines/snake_engine_stormdrive.dmm'
	engine_type = ENGINE_CHOICE_STORMDRIVE
	centerspawner = FALSE
	template_height = 10
	template_width = 18

/datum/map_template/random_room/aq_engine_snk_03
	name = "Padalec - silnik supermaterii"
	room_id = "aq_engine_snk_03_supermatter"
	mappath = 'aquila/_maps/random_engines/snake_engine_supermatter.dmm'
	engine_type = ENGINE_CHOICE_SUPERMATTER
	centerspawner = FALSE
	template_height = 10
	template_width = 18

// Reaktor fuzyjny HFR (plan maszynowni E18). Tylko z wyboru inżynierów: spawned = TRUE wyłącza szablon z losowania
// przy wczytaniu mapy (pickweight zamienia wagę 0 na 1), a engine_choice_variants() bierze go mimo to.
/datum/map_template/random_room/aq_engine_atl_hfr
	name = "Atlas - reaktor fuzyjny HFR"
	room_id = "aq_engine_atl_hfr"
	mappath = 'aquila/_maps/random_engines/atlas_engine_hfr.dmm'
	engine_type = ENGINE_CHOICE_HFR
	spawned = TRUE
	centerspawner = FALSE
	template_height = 18
	template_width = 22

/datum/map_template/random_room/aq_engine_ser_hfr
	name = "Trawnik - reaktor fuzyjny HFR"
	room_id = "aq_engine_ser_hfr"
	mappath = 'aquila/_maps/random_engines/serendipity_engine_hfr.dmm'
	engine_type = ENGINE_CHOICE_HFR
	spawned = TRUE
	centerspawner = FALSE
	template_height = 19
	template_width = 13

/datum/map_template/random_room/aq_engine_snk_hfr
	name = "Padalec - reaktor fuzyjny HFR"
	room_id = "aq_engine_snk_hfr"
	mappath = 'aquila/_maps/random_engines/snake_engine_hfr.dmm'
	engine_type = ENGINE_CHOICE_HFR
	spawned = TRUE
	centerspawner = FALSE
	template_height = 10
	template_width = 18
