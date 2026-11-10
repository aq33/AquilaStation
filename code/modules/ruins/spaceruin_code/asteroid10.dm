///////////	asteroid4 items

/obj/item/paper/fluff/ruins/asteroid10/welcome
	name = "Witaj w Psim Niebie!"
	default_raw_text = "Ambasador Psiego Nieba wita cię w naszym skromnym zaciszu!"

/obj/item/food/nugget/dog
	name = "psi przysmak"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/corgium = 10
	)

/mob/living/basic/pet/dog/corgi/chef/Initialize(mapload) // AQ EDIT - basic moby
	..()
	var/obj/item/clothing/head/chefhat/hat = new (src)
	inventory_head = hat
	update_corgi_fluff()
	update_appearance() // AQ EDIT - basic moby

/mob/living/basic/pet/dog/corgi/seccie/Initialize(mapload) // AQ EDIT - basic moby
	..()
	var/obj/item/clothing/head/helmet/sec/hat = new (src) // AQUILA EDIT - zwykły hełm nie ma dog_fashion, regenerate_icons() sypało runtime
	inventory_head = hat
	update_corgi_fluff()
	update_appearance() // AQ EDIT - basic moby
