// AQUILA - kuźnia amunicji: płytki maszyn, projekty i wpisy w techwebie.

/obj/item/circuitboard/machine/munitions_arc_forge
	name = "piec łukowy (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/munitions_forge/arc_forge
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/assembly/igniter = 1)

/obj/item/circuitboard/machine/munitions_anvil
	name = "młot mechaniczny (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/munitions_forge/anvil
	req_components = list(
		/obj/item/stack/sheet/plasteel = 5)

/obj/item/circuitboard/machine/munitions_assembly_bench
	name = "stół montażowy amunicji (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/munitions_forge/assembly_bench
	req_components = list(
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/iron = 5)

/obj/item/circuitboard/machine/munitions_electroplater
	name = "galwanizer amunicji (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/munitions_forge/electroplater
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/glass = 1)

// Jak płytki fabryki rakiet: do zrobienia w protolathe działu uzbrojenia i w drukarce obwodów.
/datum/design/board/munitions_forge
	build_type = PROTOLATHE | IMPRINTER
	materials = list(/datum/material/glass = 1000, /datum/material/copper = 500)
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/board/munitions_forge/arc_forge
	name = "Projekt maszyny (piec łukowy)"
	desc = "Piec łukowy kuźni amunicji, odlewa części z materiału z silosu."
	id = "munitions_arc_forge"
	build_path = /obj/item/circuitboard/machine/munitions_arc_forge

/datum/design/board/munitions_forge/anvil
	name = "Projekt maszyny (młot mechaniczny)"
	desc = "Pneumatyczny młot do kucia odlewów amunicji."
	id = "munitions_anvil"
	build_path = /obj/item/circuitboard/machine/munitions_anvil

/datum/design/board/munitions_forge/assembly_bench
	name = "Projekt maszyny (stół montażowy amunicji)"
	desc = "Stół do składania amunicji z części."
	id = "munitions_assembly_bench"
	build_path = /obj/item/circuitboard/machine/munitions_assembly_bench

/datum/design/board/munitions_forge/electroplater
	name = "Projekt maszyny (galwanizer amunicji)"
	desc = "Galwanizer, który pokrywa zwykłą amunicję materiałem z silosu."
	id = "munitions_electroplater"
	build_path = /obj/item/circuitboard/machine/munitions_electroplater

/datum/design/munitions_analyzer
	name = "Analizator amunicji"
	desc = "Skaner do kuźni amunicji."
	id = "munitions_analyzer"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 200)
	build_path = /obj/item/munitions_analyzer
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

// Maszyny razem z artylerią. Wyroby po dawnych projektach protolathe wymagają tych samych badań (required_node części).
/datum/techweb_node/advanced_ballistics/New()
	. = ..()
	design_ids += list("munitions_arc_forge", "munitions_anvil", "munitions_assembly_bench", "munitions_electroplater", "munitions_analyzer")
