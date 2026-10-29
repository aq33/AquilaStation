//Galaxy Thistle
/obj/item/food/grown/galaxythistle
	seed = /obj/item/plant_seeds/preset/galaxythistle
	name = "koszyczek galaktycznego ostu"
	desc = "Ten kolczasty koszyczek kwiatów przypomina ci wyżyny."
	icon_state = "galaxythistle"
	filling_color = "#1E7549"
	bite_consumption_mod = 2
	foodtypes = VEGETABLES
	wine_power = 35
	tastes = list("oset" = 2, "karczoch" = 1)

// Cabbage
/obj/item/food/grown/cabbage
	seed = /obj/item/plant_seeds/preset/cabbage
	name = "kapusta"
	desc = "Fuuuuuuj. Kapusta."
	icon_state = "cabbage"
	filling_color = "#90EE90"
	foodtypes = VEGETABLES
	wine_power = 20

// Sugarcane
/obj/item/food/grown/sugarcane
	seed = /obj/item/plant_seeds/preset/sugarcane
	name = "trzcina cukrowa"
	desc = "Mdląco słodka."
	icon_state = "sugarcane"
	filling_color = "#FFD700"
	bite_consumption_mod = 2
	foodtypes = VEGETABLES | SUGAR
	distill_reagent = /datum/reagent/consumable/ethanol/rum

// Gatfruit
/obj/item/food/grown/shell/gatfruit
	seed = /obj/item/plant_seeds/preset/gat
	name = "giwerowoc"
	desc = "Pachnie spalenizną."
	icon_state = "gatfruit"
	trash_type = /obj/item/gun/ballistic/revolver
	bite_consumption_mod = 2
	foodtypes = FRUIT
	tastes = list("proch strzelniczy" = 1)
	wine_power = 90 //It burns going down, too.

//Cherry Bombs
/obj/item/food/grown/cherry_bomb
	name = "wiśniowe bomby"
	desc = "Wydaje ci się, że słyszysz syk malutkiego lontu."
	icon_state = "cherry_bomb"
	filling_color = rgb(20, 20, 20)
	seed = /obj/item/plant_seeds/preset/cherry_bomb
	bite_consumption_mod = 3
	max_volume = 125 //Gives enough room for the black powder at max potency
	max_integrity = 40
	wine_power = 80
	discovery_points = 300

/obj/item/food/grown/cherry_bomb/attack_self(mob/living/user)
	//Preservation of a legacy feature
	icon_state = (icon_state == "cherry_bomb_lit") ? "cherry_bomb" : "cherry_bomb_lit"
	playsound(src, (icon_state == "cherry_bomb_lit") ? 'sound/items/cig_snuff.ogg' : 'sound/effects/fuse.ogg', 30, 0)
