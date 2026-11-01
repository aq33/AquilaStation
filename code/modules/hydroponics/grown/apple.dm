// Apple
/obj/item/food/grown/apple
	seed = /obj/item/plant_seeds/preset/apple
	name = "jabłko"
	desc = "To mały kawałek Edenu."
	icon_state = "apple"
	bite_consumption_mod = 100 // Always eat apples in one bite
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/consumable/applejuice
	tastes = list("jabłko" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/hcider

// Gold Apple
/obj/item/food/grown/apple/gold
	name = "złote jabłko"
	desc = "Na jabłku widnieje napis „Kallisti”."
	icon_state = "goldapple"
	distill_reagent = null
	wine_power = 50
	discovery_points = 300
