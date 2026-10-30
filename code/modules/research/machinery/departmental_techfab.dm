/obj/machinery/rnd/production/techfab/department
	name = "działowy techfab"
	desc = "Zaawansowany fabrykator, który drukuje najnowsze prototypy i obwody zbadane przez Naukę. Ma sprzęt do synchronizacji z siecią badań. Ten egzemplarz jest przypisany do działu i ma tylko ograniczony zestaw kluczy deszyfrujących."
	icon_state = "protolathe"
	circuit = /obj/item/circuitboard/machine/techfab/department

/obj/machinery/rnd/production/techfab/department/engineering
	name = "działowy techfab – inżynieria"
	allowed_department_flags = DEPARTMENTAL_FLAG_ALL|DEPARTMENTAL_FLAG_ENGINEERING
	department_tag = "Engineering"
	circuit = /obj/item/circuitboard/machine/techfab/department/engineering

/obj/machinery/rnd/production/techfab/department/service
	name = "działowy techfab – służba"
	allowed_department_flags = DEPARTMENTAL_FLAG_ALL|DEPARTMENTAL_FLAG_SERVICE
	department_tag = "Service"
	circuit = /obj/item/circuitboard/machine/techfab/department/service

/obj/machinery/rnd/production/techfab/department/medical
	name = "działowy techfab – medyczny"
	allowed_department_flags = DEPARTMENTAL_FLAG_ALL|DEPARTMENTAL_FLAG_MEDICAL
	department_tag = "Medical"
	circuit = /obj/item/circuitboard/machine/techfab/department/medical

/obj/machinery/rnd/production/techfab/department/cargo
	name = "działowy techfab – zaopatrzenie"
	allowed_department_flags = DEPARTMENTAL_FLAG_ALL|DEPARTMENTAL_FLAG_CARGO
	department_tag = "Cargo"
	circuit = /obj/item/circuitboard/machine/techfab/department/cargo

/obj/machinery/rnd/production/techfab/department/science
	name = "działowy techfab – nauka"
	allowed_department_flags = DEPARTMENTAL_FLAG_ALL|DEPARTMENTAL_FLAG_SCIENCE
	department_tag = "Science"
	circuit = /obj/item/circuitboard/machine/techfab/department/science

/obj/machinery/rnd/production/techfab/department/security
	name = "działowy techfab – ochrona"
	allowed_department_flags = DEPARTMENTAL_FLAG_ALL|DEPARTMENTAL_FLAG_SECURITY
	department_tag = "Security"
	circuit = /obj/item/circuitboard/machine/techfab/department/security
