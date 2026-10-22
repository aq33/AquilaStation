/obj/machinery/vending/hydroseeds
	name = "\improper MegaSeed Servitor"
	desc = "When you need seeds fast!"
	product_slogans = "TO TU ŻYJĄ NASIONKA! WEŹ TROSZKU!;Czapki z głów, nalepszy wybór nasion na stacji!;Więcej odmian grzybów dla ekspertów! Zdobądź dyplom już dziś!"
	product_ads = "Lubimy rośliny!;Zbierz trochę plonów !;Rośnij, skarbie, rośniiiij!;Oh tak, synu!"
	icon_state = "seeds"
	light_color = LIGHT_COLOR_GREEN
	products = list(/obj/item/plant_seeds/preset/ambrosia = 3,
					/obj/item/plant_seeds/preset/apple = 3,
					/obj/item/plant_seeds/preset/banana = 3,
					/obj/item/plant_seeds/preset/berry = 3,
					/obj/item/plant_seeds/preset/cabbage = 3,
					/obj/item/plant_seeds/preset/carrot = 3,
					/obj/item/plant_seeds/preset/cherry = 3,
					/obj/item/plant_seeds/preset/chanterelle = 3,
					/obj/item/plant_seeds/preset/chili = 3,
					/obj/item/plant_seeds/preset/cocoa = 3,
					/obj/item/plant_seeds/preset/coffee = 3,
					/obj/item/plant_seeds/preset/corn = 3,
					/obj/item/plant_seeds/preset/cotton = 3,
					/obj/item/plant_seeds/preset/diona_pod = 3,
					/obj/item/plant_seeds/preset/eggplant = 3,
					/obj/item/plant_seeds/preset/garlic = 3,
					/obj/item/plant_seeds/preset/grape = 3,
					/obj/item/plant_seeds/preset/grass = 3,
					/obj/item/plant_seeds/preset/lemon = 3,
					/obj/item/plant_seeds/preset/lime = 3,
					/obj/item/plant_seeds/preset/onion = 3,
					/obj/item/plant_seeds/preset/orange = 3,
					/obj/item/plant_seeds/preset/pineapple = 3,
					/obj/item/plant_seeds/preset/potato = 3,
					/obj/item/plant_seeds/preset/poppy = 3,
					/obj/item/plant_seeds/preset/pumpkin = 3,
					/obj/item/plant_seeds/preset/rice = 3,
					/obj/item/plant_seeds/preset/soybean = 3,
					/obj/item/plant_seeds/preset/sunflower = 3,
					/obj/item/plant_seeds/preset/sugarcane = 3,
					/obj/item/plant_seeds/preset/tea = 3,
					/obj/item/plant_seeds/preset/tobacco = 3,
					/obj/item/plant_seeds/preset/tomato = 3,
					/obj/item/plant_seeds/preset/tower = 3,
					/obj/item/plant_seeds/preset/watermelon = 3,
					/obj/item/plant_seeds/preset/wheat = 3,
					/obj/item/plant_seeds/preset/whitebeet = 3)
	contraband = list(/obj/item/plant_seeds/preset/amanita = 2,
						/obj/item/plant_seeds/preset/glowshroom = 2,
						/obj/item/plant_seeds/preset/liberty = 2,
						/obj/item/plant_seeds/preset/nettle = 2,
						/obj/item/plant_seeds/preset/plump = 2,
						/obj/item/plant_seeds/preset/reishi = 2,
						/obj/item/plant_seeds/preset/cannabis = 3,
						/obj/item/plant_seeds/preset/starthistle = 2)
	premium = list(/obj/item/reagent_containers/spray/waterflower = 1)
	refill_canister = /obj/item/vending_refill/hydroseeds
	default_price = 10
	extra_price = 50
	payment_department = ACCOUNT_SRV

/obj/item/vending_refill/hydroseeds
	machine_name = "MegaSeed Servitor"
	icon_state = "refill_plant"

/*
	Tutorial Variant
*/
/obj/machinery/vending/hydroseeds/tutorial
	color = "#f00" //Make it easier for mappers to identify

/obj/machinery/vending/hydroseeds/tutorial/Initialize(mapload)
	. = ..()
	color = "#fff"
	new /obj/item/sticker/sticky_note/tutorial/substrate(src)
