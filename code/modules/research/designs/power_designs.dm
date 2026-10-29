////////////////////////////////////////
//////////////////Power/////////////////
////////////////////////////////////////

/datum/design/basic_cell
	name = "Podstawowe ogniwo zasilające"
	desc = "Podstawowe ogniwo zasilające mieszczące 1 MJ energii."
	id = "basic_cell"
	build_type = PROTOLATHE | AUTOLATHE |MECHFAB
	materials = list(/datum/material/iron = 700, /datum/material/glass = 50, /datum/material/copper = 100)
	construction_time=100
	build_path = /obj/item/stock_parts/cell/empty
	category = list("Misc","Power Designs","Machinery","initial")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/high_cell
	name = "Ogniwo dużej pojemności"
	desc = "Ogniwo zasilające mieszczące 10 MJ energii."
	id = "high_cell"
	build_type = PROTOLATHE | AUTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 700, /datum/material/glass = 60, /datum/material/copper = 100)
	construction_time=100
	build_path = /obj/item/stock_parts/cell/high/empty
	category = list("Misc","Power Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/super_cell
	name = "Ogniwo bardzo dużej pojemności"
	desc = "Ogniwo zasilające mieszczące 20 MJ energii."
	id = "super_cell"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 700, /datum/material/glass = 70, /datum/material/copper = 100)
	construction_time=100
	build_path = /obj/item/stock_parts/cell/super/empty
	category = list("Misc","Power Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/hyper_cell
	name = "Ogniwo hiperpojemne"
	desc = "Ogniwo zasilające mieszczące 30 MJ energii."
	id = "hyper_cell"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 700, /datum/material/gold = 150, /datum/material/silver = 150, /datum/material/glass = 80, /datum/material/copper = 100)
	construction_time=100
	build_path = /obj/item/stock_parts/cell/hyper/empty
	category = list("Misc","Power Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/bluespace_cell
	name = "Ogniwo bluespace"
	desc = "Ogniwo zasilające mieszczące 40 MJ energii."
	id = "bluespace_cell"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 800, /datum/material/gold = 120, /datum/material/glass = 160, /datum/material/diamond = 160, /datum/material/titanium = 300, /datum/material/bluespace = 100, /datum/material/copper = 100)
	construction_time=100
	build_path = /obj/item/stock_parts/cell/bluespace/empty
	category = list("Misc","Power Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/light_replacer
	name = "Wymieniacz żarówek"
	desc = "Urządzenie do automatycznej wymiany oświetlenia. Uzupełniasz je sprawnymi żarówkami."
	id = "light_replacer"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1500, /datum/material/silver = 150, /datum/material/glass = 3000)
	build_path = /obj/item/lightreplacer
	category = list("Power Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/light_replacer_bluespace
	name = "Wymieniacz żarówek bluespace"
	desc = "Urządzenie do automatycznej wymiany oświetlenia z odległości. Uzupełniasz je sprawnymi żarówkami."
	id = "light_replacer_bluespace"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1500, /datum/material/silver = 150, /datum/material/glass = 6000, /datum/material/bluespace = 300)
	build_path = /obj/item/lightreplacer/bluespace
	category = list("Power Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE | DEPARTMENTAL_FLAG_ENGINEERING


/datum/design/inducer
	name = "Wytrzymały induktor"
	desc = "Induktory bezprzewodowo indukują ładunek elektryczny w przedmiocie, dzięki czemu ładujesz ogniwa bez wyjmowania ich. Ten wytrzymały model jest mocniejszy."
	id = "inducer"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 6000, /datum/material/glass = 2000, /datum/material/copper = 200)
	build_path = /obj/item/inducer/eng
	category = list("Power Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/inducer/sci
	name = "Induktor"
	desc = "Induktory bezprzewodowo indukują ładunek elektryczny w przedmiocie, dzięki czemu ładujesz ogniwa bez wyjmowania ich. Ten cywilny model jest słabszy."
	id = "inducersci"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 1000, /datum/material/copper = 100)
	build_path = /obj/item/inducer/sci
	category = list("Power Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/pacman
	name = "Projekt maszyny (przenośny generator typu P.A.C.M.A.N.)"
	desc = "Płytka drukowana przenośnego generatora typu PACMAN."
	id = "pacman"
	build_path = /obj/item/circuitboard/machine/pacman
	category = list("Engineering Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/pacman/super
	name = "Projekt maszyny (przenośny generator typu S.U.P.E.R.P.A.C.M.A.N.)"
	desc = "Płytka drukowana przenośnego generatora typu SUPERPACMAN."
	id = "superpacman"
	build_path = /obj/item/circuitboard/machine/pacman/super
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/pacman/mrs
	name = "Projekt maszyny (przenośny generator typu M.R.S.P.A.C.M.A.N.)"
	desc = "Płytka drukowana przenośnego generatora typu MRSPACMAN."
	id = "mrspacman"
	build_path = /obj/item/circuitboard/machine/pacman/mrs
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING
