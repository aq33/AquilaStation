// Soybeans
/obj/item/food/grown/soybeans
	seed = /obj/item/plant_seeds/preset/soybean
	name = "soja"
	desc = "Dość mdła, ale ile możliwości..."
	gender = PLURAL
	icon_state = "soybeans"
	foodtypes = VEGETABLES
	grind_results = list(/datum/reagent/consumable/soymilk = 0)
	tastes = list("soja" = 1)
	wine_power = 20

// Koibean
/obj/item/food/grown/koibeans
	name = "fasola koi"
	desc = "Coś tu śmierdzi rybą."
	icon_state = "koibeans"
	foodtypes = VEGETABLES
	tastes = list("koi" = 1)
	wine_power = 40
	discovery_points = 300
