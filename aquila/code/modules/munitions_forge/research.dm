// AQUILA - kuźnia amunicji: płytki maszyn, projekty i wpisy w techwebie.

/obj/item/circuitboard/machine/munitions_crucible
	name = "Munitions Crucible (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/munitions_forge/crucible
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/assembly/igniter = 1)

/obj/item/circuitboard/machine/munitions_basin
	name = "Casting Basin (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/munitions_forge/basin
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/munitions_furnace
	name = "Induction Furnace (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/munitions_forge/furnace
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/assembly/igniter = 1)

/obj/item/circuitboard/machine/munitions_hammer
	name = "Power Hammer (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/munitions_forge/hammer
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/sheet/plasteel = 2)

/obj/item/circuitboard/machine/munitions_assembler
	name = "Munitions Assembler (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/munitions_forge/assembler
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1)

// Jak płytki fabryki rakiet: do zrobienia w protolathe działu uzbrojenia i w drukarce obwodów.
/datum/design/board/munitions_forge
	build_type = PROTOLATHE | IMPRINTER
	materials = list(/datum/material/glass = 1000, /datum/material/copper = 500)
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/board/munitions_forge/crucible
	name = "Machine Design (Munitions Crucible)"
	desc = "Tygiel kuźni amunicji, pobiera materiał z silosu."
	id = "munitions_crucible"
	build_path = /obj/item/circuitboard/machine/munitions_crucible

/datum/design/board/munitions_forge/basin
	name = "Machine Design (Casting Basin)"
	desc = "Basen odlewniczy kuźni amunicji."
	id = "munitions_basin"
	build_path = /obj/item/circuitboard/machine/munitions_basin

/datum/design/board/munitions_forge/furnace
	name = "Machine Design (Induction Furnace)"
	desc = "Piec dogrzewający odlewy kuźni amunicji."
	id = "munitions_furnace"
	build_path = /obj/item/circuitboard/machine/munitions_furnace

/datum/design/board/munitions_forge/hammer
	name = "Machine Design (Power Hammer)"
	desc = "Młot pneumatyczny kuźni amunicji."
	id = "munitions_hammer"
	build_path = /obj/item/circuitboard/machine/munitions_hammer

/datum/design/board/munitions_forge/assembler
	name = "Machine Design (Munitions Assembler)"
	desc = "Monter składający amunicję z części."
	id = "munitions_assembler"
	build_path = /obj/item/circuitboard/machine/munitions_assembler

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
	design_ids += list("munitions_crucible", "munitions_basin", "munitions_furnace", "munitions_hammer", "munitions_assembler", "munition_cast_casings", "munition_cast_shell", "munition_cast_filler", "munition_cast_fuze")

/datum/techweb_node/basic_torpedo_components/New()
	. = ..()
	design_ids += "munition_cast_warhead"
