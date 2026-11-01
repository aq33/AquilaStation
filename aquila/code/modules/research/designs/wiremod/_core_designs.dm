/datum/design/integrated_circuit
	name = "Układ scalony"
	id = "integrated_circuit"
	desc = "Podstawa wszystkich układów. Na niej montuje się całą elektronikę."
	build_path = /obj/item/integrated_circuit
	build_type = IMPRINTER | COMPONENT_PRINTER
	category = list(WIREMOD_CIRCUITRY, WIREMOD_CORE)
	materials = list(/datum/material/glass =(MINERAL_MATERIAL_AMOUNT / 2), /datum/material/iron =(MINERAL_MATERIAL_AMOUNT / 2))
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/circuit_multitool
	name = "Multitool do układów"
	id = "circuit_multitool"
	desc = "Multitool do układów, służący do oznaczania obiektów i wczytywania ich do układu."
	build_path = /obj/item/multitool/circuit
	build_type = PROTOLATHE | COMPONENT_PRINTER
	category = list(WIREMOD_CIRCUITRY, WIREMOD_CORE)
	materials = list(/datum/material/glass =(MINERAL_MATERIAL_AMOUNT / 2), /datum/material/iron =(MINERAL_MATERIAL_AMOUNT / 2))
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/usb_cable
	name = "Kabel USB"
	id = "usb_cable"
	desc = "Kabel, który pozwala niektórym obudowom łączyć się z pobliskimi komputerami i maszynami."
	build_path = /obj/item/usb_cable
	build_type = PROTOLATHE | COMPONENT_PRINTER
	category = list(WIREMOD_CIRCUITRY, WIREMOD_CORE)
	// Yes, it would make sense to make them take plastic, but then less people would make them, and I think they're cool
	materials = list(/datum/material/iron = (MINERAL_MATERIAL_AMOUNT / 2)*2.5)
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/component
	desc = "Komponent montowany w układzie scalonym."
	build_type = IMPRINTER | COMPONENT_PRINTER
	materials = list(/datum/material/glass = (MINERAL_MATERIAL_AMOUNT / 2))
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
	category = list(WIREMOD_CIRCUITRY, WIREMOD_COMPONENTS)

/datum/design/component/New()
	. = ..()
	if(build_path)
		var/obj/item/circuit_component/component_path = build_path
		desc = initial(component_path.desc)

/datum/design/component/module
	name = "Komponent: moduł"
	id = "comp_module"
	build_path = /obj/item/circuit_component/module
	category = list(WIREMOD_CIRCUITRY, WIREMOD_CORE)
