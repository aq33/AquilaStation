
///////////////////////////////////
/////Non-Board Computer Stuff//////
///////////////////////////////////

/datum/design/intellicard
	name = "System transportu SI intelliCard"
	desc = "Pozwala zbudować intelliCard."
	id = "intellicard"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 1000, /datum/material/gold = 200, /datum/material/copper = 300)
	build_path = /obj/item/aicard
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/paicard
	name = "Karta osobistej sztucznej inteligencji"
	desc = "Pozwala zbudować kartę pAI."
	id = "paicard"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 500, /datum/material/iron = 500, /datum/material/copper = 300)
	build_path = /obj/item/paicard
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/ai_cam_upgrade
	name = "Aktualizacja oprogramowania do inwigilacji SI"
	desc = "Pakiet oprogramowania, dzięki któremu sztuczna inteligencja „słyszy” przez kamery, czytając z ruchu warg."
	id = "ai_cam_upgrade"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 5000, /datum/material/gold = 15000, /datum/material/silver = 15000, /datum/material/diamond = 20000, /datum/material/plasma = 10000, /datum/material/copper = 3000)
	build_path = /obj/item/surveillance_upgrade
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

///////////////////////////////////
//////////Nanite Devices///////////
///////////////////////////////////
/datum/design/nanite_remote
	name = "Pilot nanitów"
	desc = "Pozwala zbudować pilota nanitów."
	id = "nanite_remote"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 500, /datum/material/iron = 500, /datum/material/copper = 200)
	build_path = /obj/item/nanite_remote
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/nanite_scanner
	name = "Skaner nanitów"
	desc = "Pozwala zbudować skaner nanitów."
	id = "nanite_scanner"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 500, /datum/material/iron = 500, /datum/material/copper = 300)
	build_path = /obj/item/nanite_scanner
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

////////////////////////////////////////
//////////Disk Construction Disks///////
////////////////////////////////////////
/datum/design/design_disk
	name = "Dysk z projektami komponentów"
	desc = "Wytwarza dodatkowe dyski do przechowywania projektów urządzeń."
	id = "design_disk"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/iron = 300, /datum/material/glass = 100, /datum/material/copper = 100)
	build_path = /obj/item/disk/design_disk
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/design_disk_adv
	name = "Zaawansowany dysk z projektami komponentów"
	desc = "Wytwarza dodatkowe dyski do przechowywania projektów urządzeń."
	id = "design_disk_adv"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 300, /datum/material/glass = 100, /datum/material/silver=50, /datum/material/copper = 200)
	build_path = /obj/item/disk/design_disk/adv
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/tech_disk
	name = "Dysk z technologiami"
	desc = "Wytwarza dodatkowe dyski do przechowywania danych technologicznych."
	id = "tech_disk"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/iron = 300, /datum/material/glass = 100, /datum/material/copper = 100)
	build_path = /obj/item/disk/tech_disk
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/nanite_disk
	name = "Dysk z programem nanitów"
	desc = "Przechowuje programy nanitów."
	id = "nanite_disk"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 300, /datum/material/glass = 100, /datum/material/copper = 100)
	build_path = /obj/item/disk/nanite_program
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
