/obj/machinery/vending/cola
	name = "\improper Robust Softdrinks"
	desc = "Automat z napojami gazowanymi od Robust Industries, LLC."
	icon_state = "Cola_Machine"
	product_slogans = "Robustne napoje bezalkoholowe: Bardziej robustne niż skrzynka narzędziowa w ryj!"
	product_ads = "Odświeżające!;Mam nadzieję, że jesteś spragniony!;Ponad milion sprzedanych napojów!;Spragniony? A może coli?;Proszę, napij się!;Do dna!;Najlepsze napoje w kosmosie."
	light_color = LIGHT_COLOR_BLUE
	products = list(/obj/item/reagent_containers/food/drinks/soda_cans/cola = 10,
		            /obj/item/reagent_containers/food/drinks/soda_cans/space_mountain_wind = 10,
					/obj/item/reagent_containers/food/drinks/soda_cans/dr_gibb = 10,
					/obj/item/reagent_containers/food/drinks/soda_cans/starkist = 10,
					/obj/item/reagent_containers/food/drinks/soda_cans/space_up = 10,
					/obj/item/reagent_containers/food/drinks/soda_cans/pwr_game = 10,
					/obj/item/reagent_containers/food/drinks/soda_cans/lemon_lime = 10,
					/obj/item/reagent_containers/glass/waterbottle = 10)
	contraband = list(/obj/item/reagent_containers/food/drinks/soda_cans/thirteenloko = 6,
		              /obj/item/reagent_containers/food/drinks/soda_cans/shamblers = 6)
	premium = list(/obj/item/reagent_containers/food/drinks/drinkingglass/filled/nuka_cola = 1,
		           /obj/item/reagent_containers/food/drinks/soda_cans/air = 1,
		           /obj/item/reagent_containers/food/drinks/soda_cans/monkey_energy = 1,
		           /obj/item/reagent_containers/food/drinks/soda_cans/grey_bull = 1)
	refill_canister = /obj/item/vending_refill/cola
	default_price = 5
	extra_price = 60
	payment_department = ACCOUNT_SRV
/obj/item/vending_refill/cola
	machine_name = "Robust Softdrinks"
	icon_state = "refill_cola"

/obj/machinery/vending/cola/random
	name = "\improper Random Drinkies"
	icon_state = "random_cola"
	desc = "Ojej!"

/obj/machinery/vending/cola/random/Initialize(mapload)
	..()
	var/T = pick(subtypesof(/obj/machinery/vending/cola) - /obj/machinery/vending/cola/random)
	new T(loc)
	return INITIALIZE_HINT_QDEL

/obj/machinery/vending/cola/blue
	icon_state = "Cola_Machine"

/obj/machinery/vending/cola/black
	icon_state = "cola_black"
	light_color = LIGHT_COLOR_WHITE

/obj/machinery/vending/cola/red
	icon_state = "red_cola"
	name = "\improper automat Space Cola"
	desc = "Sprzedaje colę. W kosmosie."
	product_slogans = "Cola w kosmosie!"
	light_color = LIGHT_COLOR_RED

/obj/machinery/vending/cola/space_up
	icon_state = "space_up"
	name = "\improper automat Space-up!"
	desc = "Daj się porwać eksplozji smaku."
	product_slogans = "Space-up! Jak rozszczelnienie kadłuba w twoich ustach."
	light_color = LIGHT_COLOR_GREEN

/obj/machinery/vending/cola/starkist
	icon_state = "starkist"
	name = "\improper automat Star-kist"
	desc = "Smak gwiazdy w płynnej postaci."
	product_slogans = "Pij gwiazdy! Star-kist!"
	light_color = LIGHT_COLOR_ORANGE

/obj/machinery/vending/cola/sodie
	icon_state = "soda"
	light_color = LIGHT_COLOR_LAVA

/obj/machinery/vending/cola/pwr_game
	icon_state = "pwr_game"
	name = "\improper automat Pwr Game"
	desc = "Ty chcesz, my mamy. Dostarczane we współpracy z Vlad's Salads."
	product_slogans = "MOC, której pragną gracze! PWR GAME!"
	light_color = LIGHT_COLOR_PURPLE

/obj/machinery/vending/cola/shamblers
	name = "\improper automat Shambler's"
	desc = "~Wstrząśnij mi trochę tego Shambler's Juice!~"
	icon_state = "shamblers_juice"
	light_color = LIGHT_COLOR_RED
	products = list(/obj/item/reagent_containers/food/drinks/soda_cans/cola = 10,
		            /obj/item/reagent_containers/food/drinks/soda_cans/space_mountain_wind = 10,
					/obj/item/reagent_containers/food/drinks/soda_cans/dr_gibb = 10,
					/obj/item/reagent_containers/food/drinks/soda_cans/starkist = 10,
					/obj/item/reagent_containers/food/drinks/soda_cans/space_up = 10,
					/obj/item/reagent_containers/food/drinks/soda_cans/pwr_game = 10,
					/obj/item/reagent_containers/food/drinks/soda_cans/lemon_lime = 10,
					/obj/item/reagent_containers/food/drinks/soda_cans/shamblers = 10)
	product_slogans = "~Wstrząśnij mi trochę tego Shambler's Juice!~"
	product_ads = "Orzeźwiające!;Jyrbv dv lg jfdv fw kyrk Jyrdscvi'j Alztv!;Wypiło go ponad bilion dusz!;Spragniony? Nyp efk uizeb kyv uribevjj?;Kyv Jyrdscvi uizebj kyv ezxyk!;Pij!;Krjkp."
