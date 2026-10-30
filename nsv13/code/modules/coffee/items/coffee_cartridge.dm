//Coffee Cartridges: like toner, but for your coffee!
/obj/item/coffee_cartridge
	name = "wkład z kawą – Kawa marynarki"
	desc = "Wkład z kawą produkcji Piccionaia Coffee do systemu Modello 3."
	icon = 'nsv13/icons/obj/coffee.dmi'
	icon_state = "cartridge_basic"
	w_class = WEIGHT_CLASS_TINY
	var/charges = 4
	var/list/drink_type = list(/datum/reagent/consumable/navy_coffee = 120)
//To-Do Later, make a new reagent called Navy Coffee which gives a moodboost to people who drink it,
//and make it so that the Navy Coffee cartridge gives you Navy Coffee instead of regular coffee.

/obj/item/coffee_cartridge/examine(mob/user)
	. = ..()
	if(charges)
		. += "<span class='warning'>Wkładowi zostało [charges] porcji zmielonej kawy.</span>"
	else
		. += "<span class='warning'>We wkładzie nie została żadna zmielona kawa.</span>"

/obj/item/coffee_cartridge/fancy
	name = "wkład z kawą – Caffè Fantasioso"
	desc = "Wykwintny wkład z kawą produkcji Piccionaia Coffee do systemu Modello 3."
	icon_state = "cartridge_blend"
	drink_type = list(/datum/reagent/consumable/cafe_latte = 120)

//Here's the joke before I get 50 issue reports: they're all the same, and that's intentional
//Not today, Navy Coffee is not the same as the fancy coffee
/obj/item/coffee_cartridge/fancy/Initialize(mapload)
	. = ..()
	var/coffee_type = pick("blend", "blue_mountain", "kilimanjaro", "mocha")
	switch(coffee_type)
		if("blend")
			name = "wkład z kawą – Miscela di Piccione"
			icon_state = "cartridge_blend"
		if("blue_mountain")
			name = "wkład z kawą – Montagna Blu"
			icon_state = "cartridge_blue_mtn"
		if("kilimanjaro")
			name = "wkład z kawą – Kilimangiaro"
			icon_state = "cartridge_kilimanjaro"
		if("mocha")
			name = "wkład z kawą – Moka Arabica"
			icon_state = "cartridge_mocha"

/obj/item/coffee_cartridge/decaf
	name = "wkład z kawą – Caffè Decaffeinato"
	desc = "Wkład z kawą bezkofeinową produkcji Piccionaia Coffee do systemu Modello 3."
	icon_state = "cartridge_decaf"
	drink_type = list(/datum/reagent/consumable/soy_latte = 120)

// no you can't just squeeze the juice bag into a glass!
/obj/item/coffee_cartridge/bootleg
	name = "wkład z kawą – Mieszanka Botaniczna"
	desc = "Prowizoryczny wkład z kawą. Powinien działać w systemie Modello 3, choć może unieważnić gwarancję."
	icon_state = "cartridge_bootleg"
	drink_type = list(/datum/reagent/consumable/coffee = 120)

// blank cartridge for crafting's sake, can be made at the service lathe
/obj/item/blank_coffee_cartridge
	name = "pusty wkład na kawę"
	desc = "Pusty wkład na kawę, gotowy do napełnienia pastą kawową."
	icon = 'nsv13/icons/obj/coffee.dmi'
	icon_state = "cartridge_blank"
