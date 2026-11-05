// Berries
/obj/item/food/grown/berries
	seed = /obj/item/plant_seeds/preset/berry
	name = "jagoda"
	desc = "Pożywne!"
	icon_state = "berrypile"
	gender = PLURAL
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/consumable/berryjuice
	tastes = list("jagoda" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/gin

// Poison Berries
/obj/item/food/grown/berries/poison
	name = "trująca jagoda"
	desc = "Tak pyszne, że można umrzeć!"
	icon_state = "poisonberrypile"
	bite_consumption_mod = 3
	foodtypes = FRUIT | TOXIC
	juice_typepath = /datum/reagent/consumable/poisonberryjuice
	tastes = list("trująca jagoda" = 1)
	distill_reagent = null
	wine_power = 35
	discovery_points = 300

// Death Berries
/obj/item/food/grown/berries/death
	name = "jagoda śmierci"
	desc = "Tak pyszne, że na pewno umrzesz!"
	icon_state = "deathberrypile"
	bite_consumption_mod = 3
	foodtypes = FRUIT | TOXIC
	juice_typepath = /datum/reagent/consumable/poisonberryjuice
	tastes = list("śmiertelna jagoda" = 1)
	distill_reagent = null
	wine_power = 50
	discovery_points = 300

// Glow Berries
/obj/item/food/grown/berries/glow
	name = "świecąca jagoda"
	desc = "Pożywne!"
	bite_consumption_mod = 3
	icon_state = "glowberrypile"
	foodtypes = FRUIT
	tastes = list("świecąca jagoda" = 1)
	distill_reagent = null
	wine_power = 60
	discovery_points = 300

// Cherries
/obj/item/food/grown/cherries
	seed = /obj/item/plant_seeds/preset/cherry
	name = "wiśnie"
	desc = "Świetne na wierzch!"
	icon_state = "cherry"
	gender = PLURAL
	bite_consumption_mod = 2
	foodtypes = FRUIT
	grind_results = list(/datum/reagent/consumable/cherryjelly = 0)
	tastes = list("wiśnia" = 1)
	wine_power = 30

// Blue Cherries
/obj/item/food/grown/bluecherries
	name = "niebieskie wiśnie"
	desc = "To wiśnie, które są niebieskie."
	icon_state = "bluecherry"
	bite_consumption_mod = 2
	foodtypes = FRUIT
	grind_results = list(/datum/reagent/consumable/bluecherryjelly = 0)
	tastes = list("niebieska wiśnia" = 1)
	wine_power = 50
	discovery_points = 300

//Cherry Bulbs
/obj/item/food/grown/cherrybulbs
	name = "wiśnie żarówkowe"
	desc = "Są jak małe kosmiczne lampki choinkowe!"
	icon_state = "cherry_bulb"
	bite_consumption_mod = 2
	foodtypes = FRUIT
	grind_results = list(/datum/reagent/consumable/cherryjelly = 0)
	tastes = list("wiśnia" = 1)
	wine_power = 50
	discovery_points = 300

//Cherry Bulbs
/obj/item/food/grown/cherrybulbs
	name = "wiśnie żarówkowe"
	desc = "Są jak małe kosmiczne lampki choinkowe!"
	icon_state = "cherry_bulb"
	filling_color = "#FF0000"
	bite_consumption_mod = 2
	foodtypes = FRUIT
	grind_results = list(/datum/reagent/consumable/cherryjelly = 0)
	tastes = list("wiśnia" = 1)
	wine_power = 50

// Grapes
/obj/item/food/grown/grapes
	seed = /obj/item/plant_seeds/preset/grape
	name = "winogrona"
	desc = "Pożywne!"
	icon_state = "grapes"
	bite_consumption_mod = 2
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/consumable/grapejuice
	tastes = list("winogrono" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/wine

/obj/item/food/grown/grapes/make_dryable()
	AddElement(/datum/element/dryable, /obj/item/food/no_raisin/healthy)

// Green Grapes
/obj/item/food/grown/grapes/green
	name = "zielone winogrona"
	icon_state = "greengrapes"
	bite_consumption_mod = 3
	tastes = list("zielone winogrono" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/cognac
	discovery_points = 300
