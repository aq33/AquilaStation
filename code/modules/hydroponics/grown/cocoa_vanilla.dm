// Cocoa Pod
/obj/item/food/grown/cocoapod
	seed = /obj/item/plant_seeds/preset/cocoa
	name = "strąk kakaowca"
	desc = "Tuczące... Mmmm... Czekolada."
	icon_state = "cocoapod"
	bite_consumption_mod = 2
	foodtypes = FRUIT
	tastes = list("kakao" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/creme_de_cacao

// Vanilla Pod
/obj/item/food/grown/vanillapod
	name = "laska wanilii"
	desc = "Tuczące... Mmmm... Wanilia."
	icon_state = "vanillapod"
	bite_consumption_mod = 2
	foodtypes = FRUIT
	tastes = list("wanilia" = 1)
	distill_reagent = /datum/reagent/consumable/vanilla //Takes longer, but you can get even more vanilla from it.
	discovery_points = 300

//Bungo
/obj/item/food/grown/bungofruit
	name = "owoc bungo"
	desc = "Dziwny owoc. Twarda, skórzasta skórka chroni soczysty miąższ i dużą trującą pestkę."
	icon_state = "bungo"
	bite_consumption_mod = 2
	trash_type = /obj/item/food/grown/bungopit
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/consumable/bungojuice
	tastes = list("bungo" = 2, "tropikalna owocowość" = 1)
	distill_reagent = null
	discovery_points = 300

/obj/item/food/grown/bungopit
	name = "pestka bungo"
	icon_state = "bungopit"
	bite_consumption_mod = 5
	desc = "Duża pestka. Podobno jest na tyle silna, że może zatrzymać ludzkie serce."
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5
	throw_speed = 3
	throw_range = 7
	foodtypes = TOXIC
	tastes = list("gryząca gorycz" = 1)

