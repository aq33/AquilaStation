// aq33/AquilaStation#392 - polskie smaczki: gołąbki, żurek, ptasie mleczko, niedźwiedź Wojtek

/datum/test_chamber_kit/pr_392
	name = "PR 392: gołąbki, żurek, ptasie mleczko"
	pr = "aq33/AquilaStation#392"
	description = "Gotowe dania do obejrzenia i zjedzenia (sprite'y, smak). Na stole zrób z menu craftingu: gołąbki (2 kotlety, gotowany ryż, kapusta, pomidor), \
	żurek (woda 10 i mąka 5 w zlewce, jajko na twardo, kotlet, marchewka, cebula, miska) i ptasie mleczko (czekolada, śmietanka 5, cukier 5). \
	Ptasie mleczko ma też być w automacie z przekąskami (Getmore)."
	items = list(
		/obj/item/food/golabki = 1,
		/obj/item/food/soup/zurek = 1,
		/obj/item/food/ptasie_mleczko = 1,
		/obj/structure/table = 2,
		/obj/item/food/meat/cutlet/plain = 3,
		/obj/item/food/boiledrice = 1,
		/obj/item/food/grown/cabbage = 1,
		/obj/item/food/grown/tomato = 1,
		/obj/item/food/boiledegg = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/onion = 1,
		/obj/item/reagent_containers/glass/bowl = 1,
		/obj/item/reagent_containers/glass/beaker/large = 2,
		/obj/item/food/chocolatebar = 1,
		/obj/machinery/vending/snack = 1,
	)

/datum/test_chamber_kit/pr_392/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/list/beakers = list()
	for(var/obj/item/reagent_containers/glass/beaker/large/beaker in spawned)
		beakers += beaker
	if(length(beakers) < 2)
		return
	var/obj/item/reagent_containers/glass/beaker/large/soup_base = beakers[1]
	soup_base.name = "baza żurku"
	soup_base.reagents.add_reagent(/datum/reagent/water, 10)
	soup_base.reagents.add_reagent(/datum/reagent/consumable/flour, 5)
	var/obj/item/reagent_containers/glass/beaker/large/sweet = beakers[2]
	sweet.name = "śmietanka z cukrem"
	sweet.reagents.add_reagent(/datum/reagent/consumable/cream, 5)
	sweet.reagents.add_reagent(/datum/reagent/consumable/sugar, 5)

/datum/test_chamber_kit/pr_392_wojtek
	name = "PR 392: niedźwiedź Wojtek"
	pr = "aq33/AquilaStation#392"
	description = "Wojtek jest spokojny - atakuje tylko tego, kto go uderzy. Uderz go, żeby zabrać mu trochę HP, potem podaj papierosa (zjada, +10 HP) \
	i piwo (wypija duszkiem, +20 HP)."
	items = list(
		/mob/living/simple_animal/hostile/retaliate/wojtek = 1,
		/obj/item/clothing/mask/cigarette = 2,
		/obj/item/reagent_containers/food/drinks/beer = 2,
	)
