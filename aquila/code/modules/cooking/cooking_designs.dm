// Naczynia z autolatu i kuchenka elektryczna w drzewie badań (tam, gdzie kuchenka i kuchnia z zupami)

/datum/design/cooking_pan
	name = "Patelnia"
	id = "cooking_pan"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 1000)
	build_path = /obj/item/reagent_containers/cooking/pan
	category = list("initial", "Dinnerware")

/datum/design/cooking_pot
	name = "Rondel"
	id = "cooking_pot"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 1250)
	build_path = /obj/item/reagent_containers/cooking/pot
	category = list("initial", "Dinnerware")

/datum/design/cooking_oven_dish
	name = "Naczynie żaroodporne"
	id = "cooking_oven_dish"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 1500)
	build_path = /obj/item/reagent_containers/cooking/oven
	category = list("initial", "Dinnerware")

/datum/design/cooking_deep_basket
	name = "Koszyk do frytkownicy"
	id = "cooking_deep_basket"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 1000)
	build_path = /obj/item/reagent_containers/cooking/deep_basket
	category = list("initial", "Dinnerware")

/datum/design/cooking_grill_grate
	name = "Ruszt"
	id = "cooking_grill_grate"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 750)
	build_path = /obj/item/reagent_containers/cooking/grill_grate
	category = list("initial", "Dinnerware")

/datum/design/cooking_bowl
	name = "Miska do mieszania"
	id = "cooking_bowl"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 400, /datum/material/glass = 100)
	build_path = /obj/item/reagent_containers/cooking/bowl
	category = list("initial", "Dinnerware")

/datum/design/cooking_icecream_bowl
	name = "Misa do lodów"
	id = "cooking_icecream_bowl"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 750)
	build_path = /obj/item/reagent_containers/cooking/icecream_bowl
	category = list("initial", "Dinnerware")

/datum/techweb_node/bio_process/New()
	. = ..()
	design_ids += list("cooking_stovetop", "ice_cream_mixer", "cooking_grill")

/// Deski do krojenia (drewniane, więc nie z autolatu) i miski do mieszania w automacie z zastawą
/obj/machinery/vending/dinnerware/Initialize(mapload)
	products[/obj/item/reagent_containers/cooking/board] = 3
	products[/obj/item/reagent_containers/cooking/bowl] = 2
	products[/obj/item/reagent_containers/cooking/sushimat] = 2
	return ..()
