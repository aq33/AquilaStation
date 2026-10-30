// Carrot
/obj/item/food/grown/carrot
	seed = /obj/item/plant_seeds/preset/carrot
	name = "marchew"
	desc = "Dobra na oczy!"
	icon_state = "carrot"
	filling_color = "#FFA500"
	bite_consumption_mod = 2
	foodtypes = VEGETABLES
	juice_typepath = /datum/reagent/consumable/carrotjuice
	wine_power = 30

/obj/item/food/grown/carrot/attackby(obj/item/I, mob/user, params)
	if(I.is_sharp())
		to_chat(user, "<span class='notice'>Za pomocą [I] ostrzysz marchewkę w prowizoryczny nóż.</span>")
		var/obj/item/kitchen/knife/carrotshiv/Shiv = new /obj/item/kitchen/knife/carrotshiv
		remove_item_from_storage(user)
		qdel(src)
		user.put_in_hands(Shiv)
	else
		return ..()

// Parsnip
/obj/item/food/grown/parsnip
	name = "pasternak"
	desc = "Bliski krewny marchwi."
	icon_state = "parsnip"
	foodtypes = VEGETABLES
	juice_typepath = /datum/reagent/consumable/parsnipjuice
	wine_power = 35
	discovery_points = 300


// White-Beet
/obj/item/food/grown/whitebeet
	seed = /obj/item/plant_seeds/preset/whitebeet
	name = "biały burak"
	desc = "Białego buraka nie pobijesz."
	icon_state = "whitebeet"
	filling_color = "#F4A460"
	bite_consumption_mod = 3
	foodtypes = VEGETABLES
	wine_power = 40

// Red Beet
/obj/item/food/grown/redbeet
	name = "czerwony burak"
	desc = "Czerwonego buraka nie pobijesz."
	icon_state = "redbeet"
	bite_consumption_mod = 2
	foodtypes = VEGETABLES
	wine_power = 60
	discovery_points = 300
