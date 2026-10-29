// Tobacco
/obj/item/food/grown/tobacco
	seed = /obj/item/plant_seeds/preset/tobacco
	name = "liście tytoniu"
	desc = "Wysusz je, żeby zrobić coś do palenia."
	icon_state = "tobacco_leaves"
	filling_color = "#008000"
	distill_reagent = /datum/reagent/consumable/ethanol/creme_de_menthe //Menthol, I guess.

// Space Tobacco
/obj/item/food/grown/tobacco/space
	name = "liście kosmicznego tytoniu"
	desc = "Wysusz je, żeby zrobić coś kosmicznego do palenia."
	icon_state = "stobacco_leaves"
	bite_consumption_mod = 2
	distill_reagent = null
	wine_power = 50
	discovery_points = 300
