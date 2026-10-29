
/////////////////////////////////////////
///////////////Bluespace/////////////////
/////////////////////////////////////////

/datum/design/beacon
	name = "Nadajnik lokalizacyjny"
	desc = "Nadajnik lokalizacyjny bluespace."
	id = "beacon"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 150, /datum/material/glass = 100)
	build_path = /obj/item/beacon
	category = list("Bluespace Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SECURITY

/datum/design/dragnetbeacon
	name = "DROPnet"
	desc = "Nadajnik oznaczający miejsce, do którego urządzenia DRAGnet teleportują przestępców."
	id = "dragnetbeacon"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 150, /datum/material/glass = 200)
	build_path = /obj/item/beacon/nettingportal
	category = list("Bluespace Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/bag_holding
	name = "Torba bez dna"
	desc = "Plecak otwierający się na lokalną kieszeń bluespace."
	id = "bag_holding"
	build_type = PROTOLATHE
	materials = list(/datum/material/gold = 3000, /datum/material/diamond = 1500, /datum/material/uranium = 250, /datum/material/bluespace = 2000)
	build_path = /obj/item/storage/backpack/holding
	category = list("Bluespace Designs")
	dangerous_construction = TRUE
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/bluespace_crystal
	name = "Sztuczny kryształ bluespace"
	desc = "Mały niebieski kryształ o mistycznych właściwościach."
	id = "bluespace_crystal"
	build_type = PROTOLATHE
	materials = list(/datum/material/diamond = 1500, /datum/material/plasma = 1500)
	build_path = /obj/item/stack/ore/bluespace_crystal/artificial
	category = list("Bluespace Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/telesci_gps
	name = "Urządzenie GPS"
	desc = "Małe urządzonko, które przez cały czas śledzi swoje położenie."
	id = "telesci_gps"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 1000, /datum/material/copper = 100)
	build_path = /obj/item/gps
	category = list("Bluespace Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_CARGO
	
/datum/design/desynchronizer
	name = "Desynchronizator"
	desc = "Urządzenie, które desynchronizuje użytkownika z czasoprzestrzenią."
	id = "desynchronizer"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500, /datum/material/silver = 1500, /datum/material/bluespace = 1000)
	build_path = /obj/item/desynchronizer
	category = list("Bluespace Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/miningsatchel_holding
	name = "Górnicza torba bez dna"
	desc = "Torba górnicza, która mieści nieskończoną ilość rudy."
	id = "minerbag_holding"
	build_type = PROTOLATHE
	materials = list(/datum/material/gold = 250, /datum/material/uranium = 500) //quite cheap, for more convenience
	build_path = /obj/item/storage/bag/ore/holding
	category = list("Bluespace Designs")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO
	
/datum/design/swapper
	name = "Kwantowy odwracacz spinu"
	desc = "Eksperymentalne urządzenie, które zamienia miejscami dwie istoty, przełączając wartości spinu ich cząstek. Do działania musi być połączone z drugim urządzeniem."
	id = "swapper"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 1000, /datum/material/bluespace = 2000, /datum/material/gold = 1500, /datum/material/silver = 1000)
	build_path = /obj/item/swapper
	category = list("Bluespace Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
