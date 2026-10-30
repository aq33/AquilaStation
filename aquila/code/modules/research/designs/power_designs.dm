/datum/design/board/battery
	name = "Projekt maszyny (bateria eksportowa)"
	desc = "Płytka drukowana baterii eksportowej."
	id = "export_battery"
	materials = list(/datum/material/glass = 3000)
	build_path = /obj/item/circuitboard/machine/battery
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_CARGO
	category = list("Engineering Machinery")
