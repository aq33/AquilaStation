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
	name = "kowadło (płytka maszyny)"
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
	name = "Projekt maszyny (kowadło)"
	desc = "Kowadło do kucia odlewów amunicji."
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

/datum/design/forging_hammer
	name = "Młot kowalski"
	desc = "Młot do kucia odlewów amunicji na kowadle."
	id = "forging_hammer"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000)
	build_path = /obj/item/forging_hammer
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/munition_cast
	name = "Forma łusek"
	desc = "Forma odlewnicza na łuski."
	id = "munition_cast_casings"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000)
	build_path = /obj/item/munition_cast/casings
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/munition_cast/shell
	name = "Forma pocisków działowych"
	desc = "Forma odlewnicza na korpusy pocisków działowych."
	id = "munition_cast_shell"
	build_path = /obj/item/munition_cast/shell

/datum/design/munition_cast/filler
	name = "Forma wypełnień"
	desc = "Forma odlewnicza na ładunki."
	id = "munition_cast_filler"
	build_path = /obj/item/munition_cast/filler

/datum/design/munition_cast/fuze
	name = "Forma zapalników"
	desc = "Forma odlewnicza na spłonki i zapalniki."
	id = "munition_cast_fuze"
	build_path = /obj/item/munition_cast/fuze

/datum/design/munition_cast/warhead
	name = "Forma obudów głowic"
	desc = "Forma odlewnicza na obudowy głowic torped i rakiet."
	id = "munition_cast_warhead"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 6000, /datum/material/titanium = 2000)
	build_path = /obj/item/munition_cast/warhead

// Maszyny i podstawowe formy razem z artylerią, forma głowic z głowicami torped.
/datum/techweb_node/advanced_ballistics/New()
	. = ..()
	design_ids += list("munitions_arc_forge", "munitions_anvil", "munitions_assembly_bench", "munitions_electroplater", "munitions_analyzer", "forging_hammer", "munition_cast_casings", "munition_cast_shell", "munition_cast_filler", "munition_cast_fuze")

/datum/techweb_node/basic_torpedo_components/New()
	. = ..()
	design_ids += "munition_cast_warhead"
