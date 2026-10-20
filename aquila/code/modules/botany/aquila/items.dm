// AQUILA - przedmioty, których nowa botanika z Bee potrzebuje, a których u nas nie było

// Balonowiec - mutacja arbuza (u Bee w hydroponics/grown/melon.dm)
/obj/item/food/grown/ballolon
	name = "ballolon"
	desc = "Organiczny balon, lżejszy od powietrza."
	icon = 'aquila/icons/obj/hydroponics/botany_extra.dmi'
	icon_state = "ballolon"
	item_state = "ballolon"
	lefthand_file = 'aquila/icons/mob/inhands/ballolon_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/ballolon_righthand.dmi'
	filling_color = "#e35b6f"
	throw_range = 1
	throw_speed = 1
	discovery_points = 300

// Konstruktor hydrauliki dla botaników (u Bee w RCD.dm). Celowo gorszy od zwykłego, żeby działy współpracowały.
/obj/item/construction/plumbing/botany
	name = "hydroponic plumbing constructor"
	desc = "An expertly modified RCD outfitted to construct hydroponic machinery."
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "tray_maker"
	design_types = list(
		"Hydroponika" = list(
			/obj/item/plant_tray = 15,
		),
		"Distributors" = list(
			/obj/machinery/duct = 1,
			/obj/machinery/plumbing/input = 5,
			/obj/machinery/plumbing/output = 5,
			/obj/machinery/plumbing/filter = 5,
		),
		"Storage" = list(
			/obj/machinery/plumbing/tank = 20,
		),
	)
