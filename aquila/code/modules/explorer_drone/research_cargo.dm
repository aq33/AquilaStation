// AQUILA - drony eksploracyjne: płytki, projekty R&D, węzeł techwebu, paczki cargo, zasoby UI i znak (port z tgstation)

/obj/item/circuitboard/computer/exoscanner_console
	name = "konsola sterowania skanerami (płytka komputera)"
	icon_state = "science"
	build_path = /obj/machinery/computer/exoscanner_control

/obj/item/circuitboard/computer/exodrone_console
	name = "konsola sterowania dronami eksploracyjnymi (płytka komputera)"
	icon_state = "science"
	build_path = /obj/machinery/computer/exodrone_control_console

/obj/item/circuitboard/machine/exoscanner
	name = "antena skanująca (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/exoscanner
	req_components = list(
		/obj/item/stock_parts/micro_laser = 4,
		/obj/item/stock_parts/scanning_module = 4)

/obj/item/circuitboard/machine/exodrone_launcher
	name = "wyrzutnia dronów eksploracyjnych (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/exodrone_launcher
	req_components = list(
		/obj/item/stock_parts/micro_laser = 4,
		/obj/item/stock_parts/scanning_module = 4)

/datum/design/board/exoscanner_console
	name = "Projekt komputera (konsola sterowania skanerami)"
	desc = "Płytka konsoli sterowania skanerami. Operatorzy dronów zarządzają z niej antenami i szukają nowych miejsc do zbadania."
	id = "exoscanner_console"
	build_path = /obj/item/circuitboard/computer/exoscanner_console
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_CARGO

/datum/design/board/exodrone_console
	name = "Projekt komputera (konsola sterowania dronami eksploracyjnymi)"
	desc = "Płytka konsoli sterowania dronami eksploracyjnymi."
	id = "exodrone_console"
	build_path = /obj/item/circuitboard/computer/exodrone_console
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_CARGO

/datum/design/board/exoscanner
	name = "Projekt maszyny (antena skanująca)"
	desc = "Płytka anteny skanującej. Operatorzy dronów zwiększają nimi zasięg skanów."
	id = "exoscanner"
	build_path = /obj/item/circuitboard/machine/exoscanner
	category = list("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_CARGO

/datum/design/board/exodrone_launcher
	name = "Projekt maszyny (wyrzutnia dronów eksploracyjnych)"
	desc = "Płytka wyrzutni, z której startują drony eksploracyjne."
	id = "exodrone_launcher"
	build_path = /obj/item/circuitboard/machine/exodrone_launcher
	category = list("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_CARGO

/datum/techweb_node/exodrone
	id = "exodrone"
	display_name = "Drony eksploracyjne"
	description = "Przerobione automaty do gier, które po cichu wykorzystują zdolności graczy do sterowania prawdziwymi dronami."
	prereq_ids = list("robotics")
	design_ids = list("exodrone_console", "exodrone_launcher", "exoscanner", "exoscanner_console")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 5000

/datum/supply_pack/misc/exploration_drone
	name = "Dron eksploracyjny"
	desc = "Zapasowy dron eksploracyjny dalekiego zasięgu."
	cost = 1000
	contains = list(/obj/item/exodrone)
	crate_name = "skrzynia z dronem eksploracyjnym"

/datum/supply_pack/misc/exploration_fuel
	name = "Pellet paliwowy dla dronów"
	desc = "Świeży pellet paliwa dla dronów eksploracyjnych."
	cost = 600
	contains = list(/obj/item/fuel_pellet)
	crate_name = "skrzynia z paliwem dla dronów"

/// Exploration drone unlockables ///

/datum/supply_pack/exploration
	group = "Outsourced"
	special = TRUE

/datum/supply_pack/exploration/scrapyard
	name = "Skrzynia ze złomowiska"
	desc = "Skrzynia od zewnętrznego dostawcy z przeróżnym złomem."
	cost = 1000
	contains = list(/obj/item/relic,
					/obj/item/broken_bottle,
					/obj/item/pickaxe)
	crate_name = "skrzynia ze złomowiska"

/datum/supply_pack/exploration/catering
	name = "Skrzynia z cateringiem"
	desc = "Nie ma kucharza? Nie ma problemu! Jakość jedzenia zależy od dostawcy."
	cost = 1000
	contains = list(/obj/item/food/sandwich,
					/obj/item/food/sandwich,
					/obj/item/food/sandwich,
					/obj/item/food/sandwich,
					/obj/item/food/sandwich)
	crate_name = "skrzynia z cateringiem"

/datum/supply_pack/exploration/catering/fill(obj/structure/closet/crate/crate)
	. = ..()
	if(!prob(30))
		return

	for(var/obj/item/food/food_item in crate)
		// makes all of our items GROSS
		food_item.name = "zepsuty [food_item.name]"
		var/datum/component/edible/edible = food_item.GetComponent(/datum/component/edible)
		if(edible)
			edible.foodtypes |= GROSS

/datum/supply_pack/exploration/shrubbery
	name = "Skrzynia z krzewami"
	desc = "Skrzynia pełna roślin ozdobnych."
	cost = 1000
	contains = list(/obj/item/plant_tray/pot/random,
					/obj/item/plant_tray/pot/random,
					/obj/item/plant_tray/pot/random,
					/obj/item/plant_tray/pot/random,
					/obj/item/plant_tray/pot/random,
					/obj/item/plant_tray/pot/random,
					/obj/item/plant_tray/pot/random,
					/obj/item/plant_tray/pot/random)
	crate_name = "skrzynia z krzewami"

/datum/asset/simple/adventure
	assets = list(
		"default" = 'aquila/icons/ui/adventure/default.png',
		"grue" = 'aquila/icons/ui/adventure/grue.png',
		"signal_lost" = 'aquila/icons/ui/adventure/signal_lost.png',
		"trade" = 'aquila/icons/ui/adventure/trade.png',
	)

/obj/structure/sign/departments/exodrone
	name = "znak dronów eksploracyjnych"
	desc = "Znak oznaczający miejsce, gdzie używa się dronów eksploracyjnych."
	icon = 'aquila/icons/obj/exploration_sign.dmi'
	icon_state = "exodrone"
