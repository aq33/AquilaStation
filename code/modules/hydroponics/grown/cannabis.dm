// Cannabis
/obj/item/food/grown/cannabis
	seed = /obj/item/plant_seeds/preset/cannabis
	icon = 'goon/icons/obj/hydroponics.dmi'
	name = "liść konopi"
	desc = "Niedawno zalegalizowany w większości galaktyk."
	icon_state = "cannabis"
	bite_consumption_mod = 4
	foodtypes = VEGETABLES //i dont really know what else weed could be to be honest
	tastes = list("konopie" = 1)
	wine_power = 20

/obj/item/food/grown/cannabis/rainbow
	name = "tęczowy liść konopi"
	desc = "Czy on powinien tak świecić...?"
	icon_state = "megacannabis"
	wine_power = 60
	discovery_points = 300

/obj/item/food/grown/cannabis/death
	name = "liść konopi śmierci"
	desc = "Wygląda trochę mrocznie. Trudno."
	icon_state = "blackcannabis"
	wine_power = 40
	discovery_points = 300

/obj/item/food/grown/cannabis/white
	name = "biały liść konopi"
	desc = "Jest gładki i przyjemny w dotyku."
	icon_state = "whitecannabis"
	wine_power = 10
	discovery_points = 300

/obj/item/food/grown/cannabis/ultimate
	name = "liść konopi omega"
	desc = "Kręci ci się w głowie od samego patrzenia. Co jest, kurwa?"
	icon_state = "ocannabis"
	bite_consumption_mod = 2 // Ingesting like 40 units of drugs in 1 bite at 100 potency
	max_volume = 420
	wine_power = 90
	discovery_points = 300
