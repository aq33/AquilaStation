// AQUILA - przepisy na polskie jedzenie (tgstation/tgstation#65848)

/datum/crafting_recipe/food/golabki
	name = "Gołąbki"
	reqs = list(
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/boiledrice = 1,
		/obj/item/food/grown/cabbage = 1,
		/obj/item/food/grown/tomato = 1,
	)
	result = /obj/item/food/golabki
	subcategory = CAT_MISCFOOD

/datum/crafting_recipe/food/ptasie_mleczko
	name = "Ptasie mleczko"
	reqs = list(
		/obj/item/food/chocolatebar = 1,
		/datum/reagent/consumable/cream = 5,
		/datum/reagent/consumable/sugar = 5,
	)
	result = /obj/item/food/ptasie_mleczko
	subcategory = CAT_MISCFOOD

// Przepisy z Polonium Station (polonium14/polonium-station): parówki i hot dogi.

/datum/crafting_recipe/food/peto_parowek
	name = "Pęto parówek"
	reqs = list(
		/obj/item/food/meat/slab = 1,
		/obj/item/paper = 1,
	)
	result = /obj/item/food/peto_parowek
	subcategory = CAT_MEAT

/datum/crafting_recipe/food/hotdog_parowka
	name = "Hot dog z parówką"
	reqs = list(
		/datum/reagent/consumable/ketchup = 5,
		/obj/item/food/bun = 1,
		/obj/item/food/parowka = 1,
	)
	result = /obj/item/food/hotdog
	subcategory = CAT_SANDWICH
