/datum/design/board/incubator
	name = "Dish Incubator Board"
	desc = "The circuit board for a Dish Incubator."
	id = "incubator"
	build_path = /obj/item/circuitboard/machine/incubator
	category = list("Medical Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/analyzer
	name = "Disease Analyzer Board"
	desc = "The circuit board for a Disease Analyzer."
	id = "diseaseanalyzer"
	build_path = /obj/item/circuitboard/machine/diseaseanalyser
	category = list("Medical Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/centrifuge
	name = "Centrifuge Board"
	desc = "The circuit board for a Centrifuge."
	id = "centrifuge"
	build_path = /obj/item/circuitboard/machine/centrifuge
	category = list("Medical Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/diseasesplicer
	name = "Disease Splicer Board"
	desc = "The circuit board for a Disease Splicer."
	id = "diseasesplicer"
	build_path = /obj/item/circuitboard/computer/diseasesplicer
	category = list("Medical Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/antibodyscanner
	name = "Immunity Scanner"
	id = "antibodyscanner"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/iron = (MINERAL_MATERIAL_AMOUNT / 10)*5, /datum/material/glass = (MINERAL_MATERIAL_AMOUNT / 10))
	build_path = /obj/item/device/antibody_scanner
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/tube
	name = "Tube"
	id = "tube"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/glass = (MINERAL_MATERIAL_AMOUNT / 10)*2)
	build_path = /obj/item/reagent_containers/glass/tube
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/path_data
	name = "Pathology Records Board"
	desc = "The circuit board for a Pathology Records Computer."
	id = "path_data"
	build_path = /obj/item/circuitboard/computer/pathology_data
	category = list("Medical Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_ENGINEERING
