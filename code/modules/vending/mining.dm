/obj/machinery/vending/mining
	name = "\improper automat z żywnością dla górników"
	desc = "Automat z gotowymi, paczkowanymi posiłkami. Nic wykwintnego, ale nie smakuje okropnie."
	product_slogans = "Walcz dalej!;Wracaj tam, mistrzuniu!;Pamiętaj, pozostań przy życiu!;Twoje usługi są bardzo doceniane!"
	product_ads = "Wstawaj, nie zatrzymuj się!; Pozostań przy życiu dzięki Menu-35!;Posiłki na miarę pogromcy demonów!; Weź gryza i spraw byśmy byli dumni!"
	icon_state = "sustenance"
	light_color = LIGHT_COLOR_BLUEGREEN
	products = list(/obj/item/food/donkpocket/warm = 8,
					/obj/item/food/salad/herbsalad = 6,
					/obj/item/food/canned/beans = 4,
					/obj/item/reagent_containers/glass/waterbottle/large = 10)
	contraband = list(/obj/item/reagent_containers/food/drinks/coffee = 10,
					  /obj/item/food/chips = 6,
					  /obj/item/food/icecreamsandwich = 6)
	refill_canister = /obj/item/vending_refill/mining
	default_price = 0
	extra_price = 0
	payment_department = NO_FREEBIES

/obj/item/vending_refill/mining
	machine_name = "automat z żywnością dla górników"
	icon_state = "refill_snack"
