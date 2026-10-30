//Mag-cat console
/datum/design/board/fighter_launcher
	name = "Projekt komputera (konsola sterowania katapultą elektromagnetyczną)"
	desc = "Pozwala zbudować konsolę sterowania katapultą elektromagnetyczną."
	id = "fighter_launcher_circuit"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 1000)
	build_path = /obj/item/circuitboard/computer/ship/fighter_launcher
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING|DEPARTMENTAL_FLAG_CARGO

//Fighter control console
/datum/design/board/fighter_controller
	name = "Projekt komputera (komputer kontroli myśliwców)"
	desc = "Pozwala zbudować komputer kontroli myśliwców."
	id = "fighter_computer_circuit"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 1000)
	build_path = /obj/item/circuitboard/computer/ship/fighter_controller
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS|DEPARTMENTAL_FLAG_ENGINEERING

//Ordenance computer
/datum/design/board/ord_circuit
	name = "Projekt komputera (konsola monitorowania uzbrojenia)"
	desc = "Pozwala zbudować konsolę monitorowania uzbrojenia."
	id = "ordnance_comp_circuit"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 1000)
	build_path = /obj/item/circuitboard/computer/ship/ordnance_computer
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING|DEPARTMENTAL_FLAG_MUNITIONS

//Broadside Packer Table
/datum/design/board/broadside_packer
	name = "Projekt maszyny (pakowarka pocisków burtowych)"
	desc = "Pozwala zbudować pakowarkę pocisków burtowych."
	id = "broadside_packer"
	build_path = /obj/item/circuitboard/machine/broadside_shell_packer
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200)
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

//FTL Navigation Console
/datum/design/board/navigation
	name = "Projekt komputera (konsola nawigacji FTL)"
	desc = "Pozwala zbudować konsolę nawigacji FTL."
	id = "navigation_console_circuit"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/diamond = 1000)
	build_path = /obj/item/circuitboard/computer/ship/navigation
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

//DRADIS Console
/datum/design/board/dradis_console
	name = "Projekt komputera (konsola DRADIS)"
	desc = "Pozwala zbudować konsolę DRADIS."
	id = "dradis_console"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/diamond = 1000)
	build_path = /obj/item/circuitboard/computer/ship/dradis
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/cargo_dradis_console
	name = "Projekt komputera (konsola dostaw ładunku)"
	desc = "Pozwala zbudować konsolę dostaw ładunku."
	id = "cargo_dradis_console"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/diamond = 1000)
	build_path = /obj/item/circuitboard/computer/ship/dradis/cargo
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

//Helm console
/datum/design/board/helm_circuit
	name = "Projekt komputera (komputer steru)"
	desc = "Pozwala zbudować konsolę steru."
	id = "helm_circuit"
	materials = list(/datum/material/glass = 5000, /datum/material/copper = 500, /datum/material/gold = 1000)
	build_path = /obj/item/circuitboard/computer/ship/helm
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

//TAC console
/datum/design/board/tac_circuit
	name = "Projekt komputera (konsola taktyczna)"
	desc = "Pozwala zbudować konsolę taktyczną."
	id = "tactical_comp_circuit"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 1000)
	build_path = /obj/item/circuitboard/computer/ship/tactical_computer
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

//Astrometrics console
/datum/design/board/astrometrics
	name = "Projekt komputera (komputer astrometryczny)"
	desc = "Pozwala zbudować płytki drukowane do nowego komputera astrometrycznego."
	id = "astrometrics_console"
	build_path = /obj/item/circuitboard/computer/astrometrics
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

//Autoinjector
/datum/design/board/autoinjector
	name = "Projekt maszyny (drukarka autoinjektorów)"
	desc = "Pozwala zbudować płytki drukowane do nowej drukarki autoinjektorów."
	id = "autoinjector"
	build_path = /obj/item/circuitboard/machine/autoinject_printer
	category = list("Medical Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/board/refillable_chem_dispenser
	name = "Projekt maszyny (uzupełniany dozownik chemikaliów)"
	desc = "Płytka drukowana uzupełnianego dozownika chemikaliów."
	id = "refillable_chem_dispenser"
	build_path = /obj/item/circuitboard/machine/refillable_chem_dispenser
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_MEDICAL
	category = list ("Medical Machinery")

//GLORIOUS COFFEEMAKER
/datum/design/board/coffeemaker
	name = "Projekt maszyny (ekspres do kawy)"
	desc = "Płytka drukowana ekspresu do kawy."
	id = "coffeemaker"
	build_path = /obj/item/circuitboard/machine/coffeemaker
	category = list("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE | DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/navbeacon
	name = "Projekt maszyny (radiolatarnia nawigacyjna botów)"
	desc = "Płytka drukowana radiolatarni, która pomaga botom w nawigacji."
	id = "botnavbeacon"
	build_type = IMPRINTER
	build_path = /obj/item/circuitboard/machine/navbeacon
	category = list ("Research Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

// Ammo sorter circuit designs
/datum/design/board/ammo_sorter_computer
	name = "Konsola sortownika amunicji (płytka komputera)"
	desc = "Centralna konsola sterowania sortownikami amunicji."
	id = "ammo_sorter_computer"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 1000, /datum/material/gold = 500)
	build_path = /obj/item/circuitboard/computer/ammo_sorter
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/board/ammo_sorter
	name = "Sortownik amunicji (płytka maszyny)"
	desc = "Przydatny magazyn do masowego przechowywania amunicji. Całą zawartość można wydać z centralnej konsoli."
	id = "ammo_sorter"
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 1000, /datum/material/gold = 500)
	build_path = /obj/item/circuitboard/machine/ammo_sorter
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS
