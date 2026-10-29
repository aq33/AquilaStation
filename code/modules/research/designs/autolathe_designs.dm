///////////////////////////////////
//////////Autolathe Designs ///////
///////////////////////////////////

/datum/design/bucket
	name = "Wiadro"
	id = "bucket"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 200)
	build_path = /obj/item/reagent_containers/glass/bucket
	category = list("initial","Tools","Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/mop
	name = "Mop"
	id = "mop"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 1000)
	build_path = /obj/item/mop
	category = list("initial","Tools","Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/broom
	name="Miotła"
	id="pushbroom"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 2000)
	build_path = /obj/item/pushbroom
	category = list("initial","Tools","Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/crowbar
	name = "Kieszonkowy łom"
	id = "crowbar"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 50)
	build_path = /obj/item/crowbar
	category = list("initial","Tools","Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/flashlight
	name = "Latarka"
	id = "flashlight"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 50, /datum/material/glass = 20)
	build_path = /obj/item/flashlight
	category = list("initial","Tools")

/datum/design/extinguisher
	name = "Gaśnica"
	id = "extinguisher"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 90)
	build_path = /obj/item/extinguisher
	category = list("initial","Tools")

/datum/design/pocketfireextinguisher
	name = "Kieszonkowa gaśnica"
	id = "pocketfireextinguisher"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 50, /datum/material/glass = 40)
	build_path = /obj/item/extinguisher/mini
	category = list("initial","Tools")

/datum/design/multitool
	name = "Multitool"
	id = "multitool"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 50, /datum/material/glass = 20)
	build_path = /obj/item/multitool
	category = list("initial","Tools","Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/analyzer
	name = "Analizator gazów"
	id = "analyzer"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 30, /datum/material/glass = 20)
	build_path = /obj/item/analyzer
	category = list("initial","Tools","Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/tscanner
	name = "Skaner T-ray"
	id = "tscanner"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 150)
	build_path = /obj/item/t_scanner
	category = list("initial","Tools","Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/weldingtool
	name = "Spawarka"
	id = "welding_tool"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 70, /datum/material/glass = 20)
	build_path = /obj/item/weldingtool
	category = list("initial","Tools","Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/mini_weldingtool
	name = "Awaryjna spawarka"
	id = "mini_welding_tool"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 30, /datum/material/glass = 10)
	build_path = /obj/item/weldingtool/mini
	category = list("initial","Tools")

/datum/design/screwdriver
	name = "Śrubokręt"
	id = "screwdriver"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 75)
	build_path = /obj/item/screwdriver
	category = list("initial","Tools","Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/wirecutters
	name = "Przecinak do drutu"
	id = "wirecutters"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 80)
	build_path = /obj/item/wirecutters
	category = list("initial","Tools","Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/wrench
	name = "Klucz nastawny"
	id = "wrench"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 150)
	build_path = /obj/item/wrench
	category = list("initial","Tools","Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/plunger
	name = "Przepychacz"
	id = "plunger"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 150)
	build_path = /obj/item/plunger
	category = list("initial","Tools","Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/welding_helmet
	name = "Przyłbica spawalnicza"
	id = "welding_helmet"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 1750, /datum/material/glass = 400)
	build_path = /obj/item/clothing/head/welding
	category = list("initial","Tools")

/datum/design/cable_coil
	name = "Zwój kabla"
	id = "cable_coil"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 10, /datum/material/glass = 5)
	build_path = /obj/item/stack/cable_coil
	category = list("initial","Tools","Tool Designs")
	maxstack = MAXCOIL
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/toolbox
	name = "Skrzynka narzędziowa"
	id = "tool_box"
	build_type = AUTOLATHE
	materials = list(MAT_CATEGORY_RIGID = 500)
	build_path = /obj/item/storage/toolbox
	category = list("initial","Tools")

/datum/design/apc_board
	name = "Moduł sterowania zasilaniem"
	id = "power control"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 100, /datum/material/glass = 100)
	build_path = /obj/item/electronics/apc
	category = list("initial", "Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/airlock_board
	name = "Elektronika śluzy"
	id = "airlock_board"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 50, /datum/material/glass = 50)
	build_path = /obj/item/electronics/airlock
	category = list("initial", "Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/firelock_board
	name = "Obwody grodzi przeciwpożarowej"
	id = "firelock_board"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 50, /datum/material/glass = 50)
	build_path = /obj/item/electronics/firelock
	category = list("initial", "Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/airalarm_electronics
	name = "Elektronika alarmu powietrza"
	id = "airalarm_electronics"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 50, /datum/material/glass = 50)
	build_path = /obj/item/electronics/airalarm
	category = list("initial", "Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/aac_electronics
	name = "Elektronika kontrolera śluzy"
	id = "aac_electronics"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 50, /datum/material/glass = 50)
	build_path = /obj/item/electronics/advanced_airlock_controller
	category = list("initial", "Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/firealarm_electronics
	name = "Elektronika alarmu pożarowego"
	id = "firealarm_electronics"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 50, /datum/material/glass = 50)
	build_path = /obj/item/electronics/firealarm
	category = list("initial", "Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/camera
	name = "Aparat fotograficzny"
	id = "camera"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 50, /datum/material/glass = 100)
	build_path = /obj/item/camera
	category = list("initial", "Misc")

/datum/design/camera_film
	name = "Kaseta z kliszą"
	id = "camera_film"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 10, /datum/material/glass = 10)
	build_path = /obj/item/camera_film
	category = list("initial", "Misc")

/datum/design/earmuffs
	name = "Nauszniki"
	id = "earmuffs"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/clothing/ears/earmuffs
	category = list("initial", "Misc")

/datum/design/pipe_painter
	name = "Malownik rur"
	id = "pipe_painter"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 2000)
	build_path = /obj/item/pipe_painter
	category = list("initial","Tools","Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/airlock_painter
	name = "Malownik śluz"
	id = "airlock_painter"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 50, /datum/material/glass = 50)
	build_path = /obj/item/airlock_painter
	category = list("initial","Tools","Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/airlock_painter/decal/tile
	name = "Natryskiwacz płytek"
	id = "tile_sprayer"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 50, /datum/material/glass = 50)
	build_path = /obj/item/airlock_painter/decal/tile
	category = list("initial","Tools","Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SERVICE

/datum/design/emergency_oxygen
	name = "Awaryjna butla z tlenem"
	id = "emergency_oxygen"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 500)
	build_path = /obj/item/tank/internals/emergency_oxygen/empty
	category = list("initial","Misc","Equipment")

/datum/design/emergency_oxygen_engi
	name = "Powiększona awaryjna butla z tlenem"
	id = "emergency_oxygen_engi"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 750)
	build_path = /obj/item/tank/internals/emergency_oxygen/engi/empty
	category = list("hacked","Misc","Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_CARGO

/datum/design/plasmaman_tank
	name = "Powiększona butla z plazmą do oddychania"
	id = "plasmaman_tank"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 3200)
	build_path = /obj/item/tank/internals/plasmaman/empty
	category = list("hacked","Misc","Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_CARGO

/datum/design/plasmaman_tank_belt
	name = "Butla z plazmą do oddychania noszona przy pasie"
	id = "plasmaman_tank_belt"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 800)
	build_path = /obj/item/tank/internals/plasmaman/belt/empty
	category = list("hacked","Misc","Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_CARGO

/datum/design/iron
	name = "Żelazo"
	id = "iron"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/iron
	category = list("initial","Construction")
	maxstack = 50

/datum/design/glass
	name = "Szkło"
	id = "glass"
	build_type = AUTOLATHE
	materials = list(/datum/material/glass = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/glass
	category = list("initial","Construction")
	maxstack = 50

/datum/design/rglass
	name = "Szkło zbrojone"
	id = "rglass"
	build_type = AUTOLATHE | SMELTER | PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/rglass
	category = list("initial","Construction","Stock Parts")
	maxstack = 50

/datum/design/rods
	name = "Pręt metalowy"
	id = "rods"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 1000)
	build_path = /obj/item/stack/rods
	category = list("initial","Construction")
	maxstack = 50

/datum/design/rcd_ammo
	name = "Wkład ze skompresowaną materią"
	id = "rcd_ammo"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 12000, /datum/material/glass = 8000)
	build_path = /obj/item/rcd_ammo
	category = list("initial","Construction")

/datum/design/kitchen_knife
	name = "Nóż kuchenny"
	id = "kitchen_knife"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 12000)
	build_path = /obj/item/kitchen/knife
	category = list("initial","Dinnerware")

/datum/design/fork
	name = "Widelec"
	id = "fork"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 80)
	build_path = /obj/item/kitchen/fork
	category = list("initial","Dinnerware")

/datum/design/tray
	name = "Taca do serwowania"
	id = "tray"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 3000)
	build_path = /obj/item/storage/bag/tray
	category = list("initial","Dinnerware")

/datum/design/plate
	name = "Talerz"
	id = "plate"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 3500)
	build_path = /obj/item/plate
	category = list("initial","Dinnerware")

/datum/design/bowl
	name = "Miska"
	id = "bowl"
	build_type = AUTOLATHE
	materials = list(/datum/material/glass = 500)
	build_path = /obj/item/reagent_containers/glass/bowl
	category = list("initial","Dinnerware")

/datum/design/drinking_glass
	name = "Szklanka"
	id = "drinking_glass"
	build_type = AUTOLATHE
	materials = list(/datum/material/glass = 500)
	build_path = /obj/item/reagent_containers/food/drinks/drinkingglass
	category = list("initial","Dinnerware")

/datum/design/shot_glass
	name = "Kieliszek"
	id = "shot_glass"
	build_type = AUTOLATHE
	materials = list(/datum/material/glass = 100)
	build_path = /obj/item/reagent_containers/food/drinks/drinkingglass/shotglass
	category = list("initial","Dinnerware")

/datum/design/shaker
	name = "Shaker"
	id = "shaker"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 1500)
	build_path = /obj/item/reagent_containers/food/drinks/shaker
	category = list("initial","Dinnerware")

/datum/design/cultivator
	name = "Pazurki ogrodnicze"
	id = "cultivator"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron=50)
	build_path = /obj/item/cultivator
	category = list("initial","Misc", "Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/plant_analyzer
	name = "Skaner roślin"
	id = "plant_analyzer"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 30, /datum/material/glass = 20)
	build_path = /obj/item/plant_scanner
	category = list("initial","Misc", "Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/shovel
	name = "Łopata"
	id = "shovel"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 50)
	build_path = /obj/item/shovel
	category = list("initial","Misc", "Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/spade
	name = "Łopatka"
	id = "spade"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 50)
	build_path = /obj/item/shovel/spade
	category = list("initial","Misc", "Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/hatchet
	name = "Toporek"
	id = "hatchet"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 15000)
	build_path = /obj/item/hatchet
	category = list("initial","Misc", "Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

/datum/design/foilhat
	name = "Czapka z folii aluminiowej"
	id = "tinfoil_hat"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 5500)
	build_path = /obj/item/clothing/head/foilhat
	category = list("hacked", "Misc")

/datum/design/blood_filter
	name = "Filtr krwi"
	id = "blood_filter"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 1500, /datum/material/silver = 500)
	build_path = /obj/item/blood_filter
	category = list("initial", "Medical", "Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/scalpel
	name = "Skalpel"
	id = "scalpel"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 1000)
	build_path = /obj/item/scalpel
	category = list("initial", "Medical", "Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/circular_saw
	name = "Piła tarczowa"
	id = "circular_saw"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 6000)
	build_path = /obj/item/circular_saw
	category = list("initial", "Medical", "Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/surgicaldrill
	name = "Wiertło chirurgiczne"
	id = "surgicaldrill"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 6000)
	build_path = /obj/item/surgicaldrill
	category = list("initial", "Medical", "Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/retractor
	name = "Retraktor"
	id = "retractor"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 6000, /datum/material/glass = 3000)
	build_path = /obj/item/retractor
	category = list("initial", "Medical", "Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/cautery
	name = "Kauter"
	id = "cautery"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2500, /datum/material/glass = 750)
	build_path = /obj/item/cautery
	category = list("initial", "Medical", "Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/hemostat
	name = "Hemostat"
	id = "hemostat"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 2500)
	build_path = /obj/item/hemostat
	category = list("initial", "Medical", "Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/beaker
	name = "Zlewka"
	id = "beaker"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/glass = 500)
	build_path = /obj/item/reagent_containers/glass/beaker
	category = list("initial", "Medical", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SERVICE

/datum/design/large_beaker
	name = "Duża zlewka"
	id = "large_beaker"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/glass = 2500)
	build_path = /obj/item/reagent_containers/glass/beaker/large
	category = list("initial", "Medical", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SERVICE

/datum/design/healthanalyzer
	name = "Analizator zdrowia"
	id = "healthanalyzer"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 50)
	build_path = /obj/item/healthanalyzer
	category = list("initial", "Medical", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/pillbottle
	name = "Pojemnik na pigułki"
	id = "pillbottle"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 20, /datum/material/glass = 100)
	build_path = /obj/item/storage/pill_bottle
	category = list("initial", "Medical", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/beanbag_slug
	name = "Nabój z woreczkiem"
	id = "beanbag_slug"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 2000)
	build_path = /obj/item/ammo_casing/shotgun/beanbag
	category = list("initial", "Security")

/datum/design/rubbershot
	name = "Nabój z gumowym śrutem"
	id = "rubber_shot"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 4000)
	build_path = /obj/item/ammo_casing/shotgun/rubbershot
	category = list("initial", "Security")

/datum/design/c38b
	name = "Szybkoładowacz (.38 gumowe)"
	id = "c38b"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 16000)
	build_path = /obj/item/ammo_box/c38/match/bouncy
	category = list("initial", "Security")

/datum/design/recorder
	name = "Dyktafon uniwersalny"
	id = "recorder"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 60, /datum/material/glass = 30)
	build_path = /obj/item/taperecorder/empty
	category = list("initial", "Misc")

/datum/design/tape
	name = "Kaseta do dyktafonu"
	id = "tape"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 20, /datum/material/glass = 5)
	build_path = /obj/item/tape/random
	category = list("initial", "Misc")

/datum/design/igniter
	name = "Zapalnik"
	id = "igniter"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 50)
	build_path = /obj/item/assembly/igniter
	category = list("initial", "Misc")

/datum/design/signaler
	name = "Zdalny sygnalizator"
	id = "signaler"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 400, /datum/material/glass = 120)
	build_path = /obj/item/assembly/signaler
	category = list("initial", "T-Comm")

/datum/design/radio_headset
	name = "Słuchawki radiowe"
	id = "radio_headset"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 75)
	build_path = /obj/item/radio/headset
	category = list("initial", "T-Comm")

/datum/design/bounced_radio
	name = "Radio przenośne"
	id = "bounced_radio"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 75, /datum/material/glass = 25)
	build_path = /obj/item/radio/off
	category = list("initial", "T-Comm")

/datum/design/intercom_frame
	name = "Rama interkomu"
	id = "intercom_frame"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 75, /datum/material/glass = 25)
	build_path = /obj/item/wallframe/intercom
	category = list("initial", "T-Comm")

/datum/design/infrared_emitter
	name = "Emiter podczerwieni"
	id = "infrared_emitter"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500)
	build_path = /obj/item/assembly/infra
	category = list("initial", "Misc")

/datum/design/health_sensor
	name = "Czujnik zdrowia"
	id = "health_sensor"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 800, /datum/material/glass = 200)
	build_path = /obj/item/assembly/health
	category = list("initial", "Medical")

/datum/design/timer
	name = "Zegar"
	id = "timer"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 50)
	build_path = /obj/item/assembly/timer
	category = list("initial", "Misc")

/datum/design/voice_analyser
	name = "Analizator głosu"
	id = "voice_analyser"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 50)
	build_path = /obj/item/assembly/voice
	category = list("initial", "Misc")

/datum/design/light_tube
	name = "Świetlówka"
	id = "light_tube"
	build_type = AUTOLATHE
	materials = list(/datum/material/glass = 100)
	build_path = /obj/item/light/tube
	category = list("initial", "Construction")

/datum/design/light_bulb
	name = "Żarówka"
	id = "light_bulb"
	build_type = AUTOLATHE
	materials = list(/datum/material/glass = 100)
	build_path = /obj/item/light/bulb
	category = list("initial", "Construction")

/datum/design/camera_assembly
	name = "Zespół kamery"
	id = "camera_assembly"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 400, /datum/material/glass = 250)
	build_path = /obj/item/wallframe/camera
	category = list("initial", "Construction")

/datum/design/newscaster_frame
	name = "Rama newscastera"
	id = "newscaster_frame"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 14000, /datum/material/glass = 8000)
	build_path = /obj/item/wallframe/newscaster
	category = list("initial", "Construction")

/datum/design/syringe
	name = "Strzykawka"
	id = "syringe"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 10, /datum/material/glass = 20)
	build_path = /obj/item/reagent_containers/syringe
	category = list("initial", "Medical", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/dropper
	name = "Zakraplacz"
	id = "dropper"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 10, /datum/material/glass = 30)
	build_path = /obj/item/reagent_containers/dropper
	category = list("initial", "Medical", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/prox_sensor
	name = "Czujnik zbliżeniowy"
	id = "prox_sensor"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 800, /datum/material/glass = 200)
	build_path = /obj/item/assembly/prox_sensor
	category = list("initial", "Misc")

/datum/design/foam_dart
	name = "Pudełko strzałek piankowych"
	id = "foam_dart"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 500)
	build_path = /obj/item/ammo_box/foambox
	category = list("initial", "Misc")

//hacked autolathe recipes
/datum/design/flamethrower
	name = "Miotacz ognia"
	id = "flamethrower"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 500)
	build_path = /obj/item/flamethrower/full
	category = list("hacked", "Security")

/datum/design/electropack
	name = "Elektropak"
	id = "electropack"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 2500)
	build_path = /obj/item/electropack
	category = list("hacked", "Tools")

/datum/design/large_welding_tool
	name = "Przemysłowa spawarka"
	id = "large_welding_tool"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 70, /datum/material/glass = 60)
	build_path = /obj/item/weldingtool/largetank
	category = list("hacked", "Tools")

/datum/design/handcuffs
	name = "Kajdanki"
	id = "handcuffs"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 500)
	build_path = /obj/item/restraints/handcuffs
	category = list("hacked", "Security")

/datum/design/receiver
	name = "Modułowa komora zamkowa"
	id = "receiver"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 15000)
	build_path = /obj/item/weaponcrafting/receiver
	category = list("hacked", "Security")

/datum/design/shotgun_slug
	name = "Breneka"
	id = "shotgun_slug"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 4000)
	build_path = /obj/item/ammo_casing/shotgun
	category = list("hacked", "Security")

/datum/design/buckshot_shell
	name = "Nabój śrutowy"
	id = "buckshot_shell"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 4000)
	build_path = /obj/item/ammo_casing/shotgun/buckshot
	category = list("hacked", "Security")

/datum/design/shotgun_dart
	name = "Strzałka do strzelby"
	id = "shotgun_dart"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 4000)
	build_path = /obj/item/ammo_casing/shotgun/dart
	category = list("hacked", "Security")

/datum/design/incendiary_slug
	name = "Breneka zapalająca"
	id = "incendiary_slug"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 4000)
	build_path = /obj/item/ammo_casing/shotgun/incendiary
	category = list("hacked", "Security")

/datum/design/riot_dart
	name = "Prewencyjna strzałka piankowa"
	id = "riot_dart"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 1000) //Discount for making individually - no box = less metal!
	build_path = /obj/item/ammo_casing/caseless/foam_dart/riot
	category = list("hacked", "Security")

/datum/design/riot_darts
	name = "Pudełko prewencyjnych strzałek piankowych"
	id = "riot_darts"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 50000) //Comes with 40 darts
	build_path = /obj/item/ammo_box/foambox/riot
	category = list("hacked", "Security")

/datum/design/a357
	name = "Łuska .357"
	id = "a357"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 4000)
	build_path = /obj/item/ammo_casing/a357
	category = list("hacked", "Security")

/datum/design/c10mm
	name = "Pojemnik z amunicją (10mm)"
	id = "c10mm"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 30000)
	build_path = /obj/item/ammo_box/c10mm
	category = list("hacked", "Security")

/datum/design/c45
	name = "Pojemnik z amunicją (.45)"
	id = "c45"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 30000)
	build_path = /obj/item/ammo_box/c45
	category = list("hacked", "Security")

/datum/design/c9mm
	name = "Pojemnik z amunicją (9mm)"
	id = "c9mm"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 30000)
	build_path = /obj/item/ammo_box/c9mm
	category = list("hacked", "Security")

/datum/design/c38
	name = "Szybkoładowacz (.38)"
	id = "c38"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 20000)
	build_path = /obj/item/ammo_box/c38
	category = list("hacked", "Security")

/datum/design/cleaver
	name = "Tasak rzeźnicki"
	id = "cleaver"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 18000)
	build_path = /obj/item/kitchen/knife/butcher
	category = list("hacked", "Dinnerware")

/datum/design/spraycan
	name = "Puszka ze sprayem"
	id = "spraycan"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 100, /datum/material/glass = 100)
	build_path = /obj/item/toy/crayon/spraycan
	category = list("initial", "Tools")

/datum/design/dest_tagger
	name = "Znakownik adresowy"
	id = "dest_tagger"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 250, /datum/material/glass = 125)
	build_path = /obj/item/dest_tagger
	category = list("initial", "Electronics")

/datum/design/handlabeler
	name = "Etykieciarka"
	id = "handlabel"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 150, /datum/material/glass = 125)
	build_path = /obj/item/hand_labeler
	category = list("initial", "Electronics")

/datum/design/geiger
	name = "Licznik Geigera"
	id = "geigercounter"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 150, /datum/material/glass = 150)
	build_path = /obj/item/geiger_counter
	category = list("initial", "Tools")

/datum/design/turret_control_frame
	name = "Rama panelu sterowania wieżyczkami"
	id = "turret_control"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 12000)
	build_path = /obj/item/wallframe/turret_control
	category = list("initial", "Construction")

/datum/design/conveyor_belt
	name = "Taśmociąg"
	id = "conveyor_belt"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 3000)
	build_path = /obj/item/stack/conveyor
	category = list("initial", "Construction")
	maxstack = 30

/datum/design/conveyor_switch
	name = "Przełącznik taśmociągu"
	id = "conveyor_switch"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 450, /datum/material/glass = 190)
	build_path = /obj/item/conveyor_switch_construct
	category = list("initial", "Construction")

/datum/design/laptop
	name = "Obudowa laptopa"
	id = "laptop"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 1000)
	build_path = /obj/item/modular_computer/laptop/buildable
	category = list("initial","Misc")

/datum/design/tablet
	name = "Obudowa tabletu"
	id = "tablet"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1000)
	build_path = /obj/item/modular_computer/tablet
	category = list("initial","Misc")

/datum/design/slime_scanner
	name = "Skaner szlamów"
	id = "slime_scanner"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 300, /datum/material/glass = 200)
	build_path = /obj/item/slime_scanner
	category = list("initial", "Misc")

/datum/design/pet_carrier
	name = "Transporter dla zwierząt"
	id = "pet_carrier"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 7500, /datum/material/glass = 100)
	build_path = /obj/item/pet_carrier
	category = list("initial", "Misc")

/datum/design/miniature_power_cell
	name = "Ogniwo do oprawy oświetleniowej"
	id = "miniature_power_cell"
	build_type = AUTOLATHE
	materials = list(/datum/material/glass = 20)
	build_path = /obj/item/stock_parts/cell/emergency_light
	category = list("initial", "Electronics")

/datum/design/package_wrap
	name = "Papier pakowy"
	id = "package_wrap"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 200, /datum/material/glass = 200)
	build_path = /obj/item/stack/package_wrap
	category = list("initial", "Misc", "Equipment")
	maxstack = 30

/datum/design/holodisk
	name = "Dysk holonagrań"
	id = "holodisk"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 100, /datum/material/glass = 100)
	build_path = /obj/item/disk/holodisk
	category = list("initial", "Misc")

/datum/design/circuit
	name = "Niebieska płytka z obwodami"
	id = "circuit"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/stack/tile/circuit
	category = list("initial", "Misc")
	maxstack = 50

/datum/design/circuitgreen
	name = "Zielona płytka z obwodami"
	id = "circuitgreen"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/stack/tile/circuit/green
	category = list("initial", "Misc")
	maxstack = 50

/datum/design/circuitred
	name = "Czerwona płytka z obwodami"
	id = "circuitred"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/stack/tile/circuit/red
	category = list("initial", "Misc")
	maxstack = 50

/datum/design/price_tagger
	name = "Metkownica"
	id = "price_tagger"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 1500, /datum/material/glass = 500)
	build_path = /obj/item/price_tagger
	category = list("initial", "Misc")

/datum/design/custom_vendor_refill
	name = "Kanister z zapasami do własnego automatu"
	id = "custom_vendor_refill"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 2000)
	build_path = /obj/item/vending_refill/custom
	category = list("initial", "Misc")

/datum/design/toygun
	name = "Pistolet na kapiszony"
	id = "toygun"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 100, /datum/material/glass = 50)
	build_path = /obj/item/toy/gun
	category = list("hacked", "Misc")

/datum/design/capbox
	name = "Pudełko kapiszonów"
	id = "capbox"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 20, /datum/material/glass = 5)
	build_path = /obj/item/toy/ammo/gun
	category = list("hacked", "Misc")

/datum/design/ducts
	name = "Rury na płyny"
	id = "fluid_ducts"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 500)
	build_path = /obj/item/stack/ducts
	category = list("initial", "Construction")
	maxstack = 50

/datum/design/airlock_painter/decal
	name = "Malownik oznaczeń"
	id = "decal_painter"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(/datum/material/iron = 50, /datum/material/glass = 50)
	build_path = /obj/item/airlock_painter/decal
	category = list("initial","Tools","Tool Designs")

/datum/design/cautionsign
	name = "Znak „Mokra podłoga”"
	id = "wetfloorsign"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 50)
	build_path = /obj/item/clothing/suit/caution
	category = list("initial","Misc")
