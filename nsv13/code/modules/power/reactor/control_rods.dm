/obj/item/control_rod
	name = "\improper nanowęglowy pręt sterujący reaktora"
	desc = "Standardowy nanowęglowy pręt sterujący reaktora."
	icon = 'nsv13/icons/obj/control_rod.dmi'
	icon_state = "normal"
	w_class = WEIGHT_CLASS_BULKY
	var/rod_integrity = 100
	var/rod_effectiveness = 1

/obj/item/control_rod/Initialize(mapload)
	.=..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE)

/obj/item/control_rod/inferior
	name = "\improper pręt sterujący reaktora z techfabu"
	desc = "Pręt sterujący reaktora wyprodukowany na pokładzie. Techfaby mają za małą rozdzielczość, by w pełni zestalić rdzeń."
	icon_state = "inferior"
	rod_integrity = 80
	rod_effectiveness = 0.8

/obj/item/control_rod/superior
	name = "\improper krystaliczny nanowęglowy pręt sterujący reaktora"
	desc = "Lepszy nanowęglowy pręt sterujący reaktora, o dłuższej żywotności."
	icon_state = "superior"
	rod_integrity = 200

/obj/item/control_rod/plasma
	name = "\improper plazmowy pręt sterujący reaktora w osłonie nanowęglowej"
	desc = "Plazmowy rdzeń tego pręta sterującego reaktora otacza warstwa nanowęgla."
	icon_state = "plasma"
	rod_effectiveness = -0.5

/obj/item/control_rod/irradiated
	name = "\improper zużyty pręt sterujący reaktora"
	desc = "Pręt sterujący reaktora nasycony cząstkami radioaktywnymi. Już nie działa."
	icon_state = "irradiated"
	rod_integrity = 0
	rod_effectiveness = 0

/obj/item/control_rod/irradiated/Initialize(mapload)
	.=..()
	AddComponent(/datum/component/radioactive, 500, src)

/datum/techweb_node/reactor_control_rods
	id = "reactor_control_rods"
	display_name = "Produkcja prętów sterujących reaktora napędu burzowego"
	description = "Pokładowa produkcja prętów sterujących reaktora napędu burzowego. W potrzebie się sprawdzą."
	prereq_ids = list("engineering")
	design_ids = list("reactor_control_rods")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 1000

/datum/design/reactor_control_rods
	name = "Pręt sterujący reaktora z techfabu"
	desc = "Pręt sterujący reaktora wyprodukowany na pokładzie. Techfaby mają za małą rozdzielczość, by w pełni zestalić rdzeń."
	id = "reactor_control_rods"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/titanium = 500)
	build_path = /obj/item/control_rod/inferior
	category = list("Power Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING
