/obj/machinery/rnd/production/circuit_imprinter/department
	name = "działowa drukarka obwodów"
	desc = "Specjalna drukarka obwodów z wbudowanym interfejsem do użytku w dziale. Wbudowane odbiorniki ExoSync pozwalają jej drukować zbadane projekty pasujące do działu zapisanego w jej pamięci ROM."
	icon_state = "circuit_imprinter"
	circuit = /obj/item/circuitboard/machine/circuit_imprinter/department

/obj/machinery/rnd/production/circuit_imprinter/department/science
	name = "działowa drukarka obwodów (Nauka)"
	circuit = /obj/item/circuitboard/machine/circuit_imprinter/department/science
	allowed_department_flags = DEPARTMENTAL_FLAG_ALL|DEPARTMENTAL_FLAG_SCIENCE
	department_tag = "Science"
