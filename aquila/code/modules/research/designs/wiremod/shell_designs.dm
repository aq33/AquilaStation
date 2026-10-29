/datum/design/wiremod_shell
	build_type = PROTOLATHE | COMPONENT_PRINTER
	category = list(WIREMOD_CIRCUITRY, WIREMOD_SHELLS)

/datum/design/wiremod_shell/compact_remote
	name = "Compact Remote Shell"
	id = "compact_remote_shell"
	desc = "Ręczna obudowa z jednym dużym przyciskiem."
	build_path = /obj/item/compact_remote
	materials = list(/datum/material/glass =MINERAL_MATERIAL_AMOUNT, /datum/material/iron =MINERAL_MATERIAL_AMOUNT * 2.5)

/datum/design/wiremod_shell/controller
	name = "Controller Shell"
	id = "controller_shell"
	desc = "Ręczna obudowa z kilkoma przyciskami."
	build_path = /obj/item/controller
	materials = list(/datum/material/glass =MINERAL_MATERIAL_AMOUNT, /datum/material/iron = MINERAL_MATERIAL_AMOUNT*3.5)

/datum/design/wiremod_shell/scanner
	name = "Scanner Shell"
	id = "scanner_shell"
	desc = "Ręczna obudowa skanera, która skanuje obiekty."
	build_path = /obj/item/wiremod_scanner
	materials = list(/datum/material/glass =MINERAL_MATERIAL_AMOUNT, /datum/material/iron = MINERAL_MATERIAL_AMOUNT*3.5)

/datum/design/wiremod_shell/keyboard
	name = "Keyboard Shell"
	id = "keyboard_shell"
	desc = "Ręczna obudowa, która pozwala użytkownikowi wpisać tekst."
	build_path = /obj/item/keyboard_shell
	materials = list(/datum/material/glass =MINERAL_MATERIAL_AMOUNT, /datum/material/iron = MINERAL_MATERIAL_AMOUNT*5)

/datum/design/wiremod_shell/gun
	name = "Gun Shell"
	id = "gun_shell"
	desc = "Ręczna obudowa, która strzela pociskami i zwraca trafione obiekty."
	build_path = /obj/item/gun/energy/wiremod_gun
	materials = list(/datum/material/glass =MINERAL_MATERIAL_AMOUNT, /datum/material/iron = MINERAL_MATERIAL_AMOUNT*5, /datum/material/plasma =(MINERAL_MATERIAL_AMOUNT / 10))

/datum/design/wiremod_shell/bot
	name = "Bot Shell"
	id = "bot_shell"
	desc = "Nieruchoma obudowa, która mieści więcej komponentów. Ma port USB do łączenia z komputerami i maszynami."
	build_path = /obj/item/shell/bot
	materials = list(/datum/material/glass =MINERAL_MATERIAL_AMOUNT, /datum/material/iron = MINERAL_MATERIAL_AMOUNT*5)

/datum/design/wiremod_shell/money_bot
	name = "Money Bot Shell"
	id = "money_bot_shell"
	desc = "Nieruchoma obudowa podobna do zwykłej obudowy bota, ale przyjmuje i wydaje pieniądze."
	build_path = /obj/item/shell/money_bot
	materials = list(/datum/material/glass =MINERAL_MATERIAL_AMOUNT, /datum/material/iron = MINERAL_MATERIAL_AMOUNT*5, /datum/material/gold =(MINERAL_MATERIAL_AMOUNT / 10)*0.5)

/datum/design/wiremod_shell/drone
	name = "Drone Shell"
	id = "drone_shell"
	desc = "Obudowa, która potrafi sama się poruszać."
	build_path = /obj/item/shell/drone
	materials = list(
		/datum/material/glass =MINERAL_MATERIAL_AMOUNT,
		/datum/material/iron = MINERAL_MATERIAL_AMOUNT*5.5,
		/datum/material/gold =(MINERAL_MATERIAL_AMOUNT / 10)*5,
	)

/datum/design/wiremod_shell/server
	name = "Server Shell"
	id = "server_shell"
	desc = "Bardzo duża obudowa, której nie da się przesunąć. Mieści najwięcej komponentów."
	materials = list(
		/datum/material/glass =MINERAL_MATERIAL_AMOUNT * 2.5,
		/datum/material/iron = MINERAL_MATERIAL_AMOUNT*7.5,
		/datum/material/gold =(MINERAL_MATERIAL_AMOUNT / 2) * 1.5,
	)
	build_path = /obj/item/shell/server

/datum/design/wiremod_shell/airlock
	name = "Airlock Shell"
	id = "door_shell"
	desc = "Obudowa drzwi, której po złożeniu nie da się przesunąć."
	materials = list(
		/datum/material/glass =MINERAL_MATERIAL_AMOUNT * 2.5,
		/datum/material/iron = MINERAL_MATERIAL_AMOUNT*7.5,
	)
	build_path = /obj/item/shell/airlock

/datum/design/wiremod_shell/dispenser
	name = "Dispenser Shell"
	id = "dispenser_shell"
	desc = "Obudowa dozownika, która wydaje przedmioty."
	materials = list(
		/datum/material/glass =MINERAL_MATERIAL_AMOUNT * 2.5,
		/datum/material/iron = MINERAL_MATERIAL_AMOUNT*7.5,
	)
	build_path = /obj/item/shell/dispenser

/datum/design/wiremod_shell/bci
	name = "Brain-Computer Interface Shell"
	id = "bci_shell"
	desc = "Implant umieszczany w głowie, pozwalający sterować układami za pomocą mózgu."
	materials = list(
		/datum/material/glass =MINERAL_MATERIAL_AMOUNT,
		/datum/material/iron = MINERAL_MATERIAL_AMOUNT*4,
	)
	build_path = /obj/item/shell/bci

/datum/design/wiremod_shell/scanner_gate
	name = "Scanner Gate Shell"
	id = "scanner_gate_shell"
	desc = "Obudowa bramki skanującej, która wykonuje średnio dokładne skany przechodzących osób."
	materials = list(
		/datum/material/glass = MINERAL_MATERIAL_AMOUNT*2,
		/datum/material/iron = MINERAL_MATERIAL_AMOUNT*6,
	)
	build_path = /obj/item/shell/scanner_gate

/datum/design/wiremod_shell/assembly
	name = "Assembly Shell"
	id = "assembly_shell"
	desc = "Obudowa zespołu, którą można podłączyć do przewodów i innych zespołów."
	materials = list(/datum/material/glass =MINERAL_MATERIAL_AMOUNT, /datum/material/iron =MINERAL_MATERIAL_AMOUNT * 2.5)
	build_path = /obj/item/assembly/wiremod

/datum/design/wiremod_shell/mod_module
	name = "MOD Module Shell"
	id = "mod_module_shell"
	desc = "Moduł-obudowa, który pozwala włożyć układ scalony do MODsuitu i połączyć go z kombinezonem."
	materials = list(/datum/material/glass = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/mod/module/circuit

/datum/design/wiremod_shell/undertile
	name = "Under-tile Shell"
	id = "undertile_shell"
	desc = "Mała obudowa, która mieści się pod podłogą."
	materials = list(
		/datum/material/glass=(MINERAL_MATERIAL_AMOUNT / 2),
		/datum/material/iron=MINERAL_MATERIAL_AMOUNT*2.5,
	)
	build_path = /obj/item/undertile_circuit


/datum/design/wiremod_shell/wallmount
	name = "Wall-mounted Shell"
	id = "wallmount_shell"
	desc = "Duża obudowa do zamontowania na ścianie."
	materials = list(
		/datum/material/glass=MINERAL_MATERIAL_AMOUNT,
		/datum/material/iron=MINERAL_MATERIAL_AMOUNT*5,
	)
	build_path = /obj/item/wallframe/circuit

/datum/design/wiremod_shell/implant
	name = "Implant Shell Case"
	id = "implant_shell"
	desc = "Malutka obudowa, którą można wszczepić żywej istocie."
	materials = list(
		/datum/material/iron = (MINERAL_MATERIAL_AMOUNT / 10) * 5,
		/datum/material/glass = (MINERAL_MATERIAL_AMOUNT / 10) * 5,
	)
	build_path = /obj/item/implantcase/circuit

//This design has a different path but it's still a wiremod design.
/datum/design/board/bci_implanter
	name = "Brain-Computer Interface Manipulation Chamber"
	id = "bci_implanter"
	desc = "Maszyna, która po włożeniu interfejsu mózg-komputer wszczepia go osobie w środku. W przeciwnym razie usuwa jej wszystkie interfejsy mózg-komputer."
	build_path = /obj/item/circuitboard/machine/bci_implanter
	build_type = IMPRINTER | COMPONENT_PRINTER
	category = list(WIREMOD_CIRCUITRY, WIREMOD_SHELLS)
