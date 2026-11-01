/obj/item/gun/energy/taser
	name = "paralizator"
	desc = "Energetyczna broń ogłuszająca o małej pojemności, której ochrona używa do obezwładniania celów na odległość."
	icon_state = "taser"
	item_state = null	//so the human update icon uses the icon_state instead.
	ammo_type = list(/obj/item/ammo_casing/energy/electrode)
	ammo_x_offset = 3

/obj/item/gun/energy/tesla_revolver
	name = "pistolet Tesli"
	desc = "Eksperymentalna broń oparta na eksperymentalnym silniku. Zabije strzelca mniej więcej z takim samym prawdopodobieństwem jak cel."
	icon_state = "tesla"
	item_state = "tesla"
	ammo_type = list(/obj/item/ammo_casing/energy/tesla_revolver)
	can_flashlight = FALSE
	pin = null
	shaded_charge = 1
	fire_rate = 1.5

/obj/item/gun/energy/e_gun/advtaser
	name = "paralizator hybrydowy"
	desc = "Dwutrybowy paralizator strzelający zarówno silnymi elektrodami krótkiego zasięgu, jak i dalekozasięgowymi wiązkami disablera."
	icon_state = "advtaser"
	ammo_type = list(/obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/disabler)
	ammo_x_offset = 2

/obj/item/gun/energy/e_gun/advtaser/cyborg
	name = "paralizator cyborga"
	desc = "Wbudowany paralizator hybrydowy zasilany wprost z ogniwa cyborga. Ma ogranicznik, który chroni ogniwo cyborga przed przegrzaniem."
	can_flashlight = FALSE
	can_charge = FALSE
	use_cyborg_cell = TRUE
	requires_wielding = FALSE

/obj/item/gun/energy/disabler
	name = "disabler"
	desc = "Broń do samoobrony, która wyczerpuje organiczne cele, osłabiając je, aż padną."
	icon_state = "disabler"
	item_state = null
	ammo_type = list(/obj/item/ammo_casing/energy/disabler)
	ammo_x_offset = 2
	can_flashlight = TRUE
	flight_x_offset = 15
	flight_y_offset = 10

/obj/item/gun/energy/disabler/cyborg
	name = "disabler cyborga"
	desc = "Wbudowany disabler zasilany z ogniwa cyborga. Ma ogranicznik, który chroni ogniwo cyborga przed przegrzaniem."
	can_charge = FALSE
	use_cyborg_cell = TRUE
	requires_wielding = FALSE

/obj/item/gun/energy/pulse/carbine/cyborg
	name = "karabinek pulsacyjny cyborga"
	desc = "Wbudowany karabin pulsacyjny"
	can_charge = FALSE
	use_cyborg_cell = TRUE
	requires_wielding = FALSE
