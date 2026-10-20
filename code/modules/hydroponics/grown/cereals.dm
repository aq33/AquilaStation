// Wheat
/obj/item/food/grown/wheat
	seed = /obj/item/plant_seeds/preset/wheat
	name = "wheat"
	desc = "Sigh... wheat... a-grain?"
	gender = PLURAL
	icon_state = "wheat"
	bite_consumption_mod = 0.5 // Chewing on wheat grains?
	foodtypes = GRAIN
	grind_results = list(/datum/reagent/consumable/flour = 0)
	tastes = list("pszenica" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/beer

// Oat
/obj/item/food/grown/oat
	name = "oat"
	desc = "Eat oats, do squats."
	seed = /obj/item/plant_seeds/preset/oats
	gender = PLURAL
	icon_state = "oat"
	bite_consumption_mod = 0.5
	foodtypes = GRAIN
	grind_results = list(/datum/reagent/consumable/flour = 0)
	tastes = list("owies" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/ale
	discovery_points = 300

// Rice
/obj/item/food/grown/rice
	seed = /obj/item/plant_seeds/preset/rice
	name = "rice"
	desc = "Rice to meet you."
	gender = PLURAL
	icon_state = "rice"
	bite_consumption_mod = 0.5
	foodtypes = GRAIN
	grind_results = list(/datum/reagent/consumable/rice = 0)
	tastes = list("ryż" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/sake

//Meatwheat - grows into synthetic meat
/obj/item/food/grown/meatwheat
	name = "meatwheat"
	desc = "Some blood-drenched wheat stalks. You can crush them into what passes for meat if you squint hard enough."
	icon_state = "meatwheat"
	gender = PLURAL
	bite_consumption_mod = 0.5
	seed = /obj/item/plant_seeds/preset/meat
	foodtypes = MEAT | GRAIN
	grind_results = list(/datum/reagent/consumable/flour = 0, /datum/reagent/blood = 0)
	tastes = list("mięsopszenica" = 1)
	can_distill = FALSE
	discovery_points = 300

/obj/item/food/grown/meatwheat/attack_self(mob/living/user)
	user.visible_message("<span class='notice'>[user] rozgniata [src] w mięso.</span>", "<span class='notice'>Rozgniatasz [src] w coś, co przypomina mięso.</span>")
	playsound(user, 'sound/effects/blobattack.ogg', 50, 1)
	var/obj/item/food/meat/slab/meatwheat/M = new
	qdel(src)
	user.put_in_hands(M)
	return 1
