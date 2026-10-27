/datum/design/integrated_circuit
	name = "Integrated Circuit"
	id = "integrated_circuit"
	desc = "The foundation of all circuits. All Circuitry go onto this."
	build_path = /obj/item/integrated_circuit
	build_type = COMPONENT_PRINTER
	category = list(WIREMOD_CIRCUITRY, WIREMOD_CORE)
	materials = list(/datum/material/glass =(MINERAL_MATERIAL_AMOUNT / 2), /datum/material/iron =(MINERAL_MATERIAL_AMOUNT / 2))
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/circuit_multitool
	name = "Circuit Multitool"
	id = "circuit_multitool"
	desc = "A circuit multitool to mark entities and load them into."
	build_path = /obj/item/multitool/circuit
	build_type = COMPONENT_PRINTER
	category = list(WIREMOD_CIRCUITRY, WIREMOD_CORE)
	materials = list(/datum/material/glass =(MINERAL_MATERIAL_AMOUNT / 2), /datum/material/iron =(MINERAL_MATERIAL_AMOUNT / 2))
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/usb_cable
	name = "USB Cable"
	id = "usb_cable"
	desc = "A cable that allows certain shells to connect to nearby computers and machines."
	build_path = /obj/item/usb_cable
	build_type = COMPONENT_PRINTER
	category = list(WIREMOD_CIRCUITRY, WIREMOD_CORE)
	// Yes, it would make sense to make them take plastic, but then less people would make them, and I think they're cool
	materials = list(/datum/material/iron = (MINERAL_MATERIAL_AMOUNT / 2)*2.5)
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/component
	desc = "A component that goes into an integrated circuit."
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
	name = "Module Component"
	id = "comp_module"
	build_path = /obj/item/circuit_component/module
	category = list(WIREMOD_CIRCUITRY, WIREMOD_CORE)
