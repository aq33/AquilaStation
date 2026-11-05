// Potato
/obj/item/food/grown/potato
	seed = /obj/item/plant_seeds/preset/potato
	name = "ziemniak"
	desc = "Ugotuj! Utłucz! Wrzuć do gulaszu!"
	icon_state = "potato"
	bite_consumption_mod = 100
	foodtypes = VEGETABLES
	juice_typepath = /datum/reagent/consumable/potato_juice
	distill_reagent = /datum/reagent/consumable/ethanol/vodka

/obj/item/food/grown/potato/wedges
	name = "ćwiartki ziemniaka"
	desc = "Starannie pokrojone kawałki ziemniaka."
	icon_state = "potato_wedges"
	bite_consumption_mod = 100

/obj/item/food/grown/potato/attackby(obj/item/W, mob/user, params)
	if(W.is_sharp())
		to_chat(user, "<span class='notice'>Kroisz ziemniaka w łódeczki za pomocą [W].</span>")
		var/obj/item/food/grown/potato/wedges/Wedges = new /obj/item/food/grown/potato/wedges
		remove_item_from_storage(user)
		qdel(src)
		user.put_in_hands(Wedges)
	else
		return ..()


// Sweet Potato
/obj/item/food/grown/potato/sweet
	name = "batat"
	desc = "Jest słodki."
	icon_state = "sweetpotato"
	distill_reagent = /datum/reagent/consumable/ethanol/sbiten
	discovery_points = 300
