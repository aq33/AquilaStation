// AQ EDIT - zupy z garnka (tgstation/tgstation#74205): zupy, które stały się odczynnikami, są w aquila/code/modules/food_and_drinks/soup/
/obj/item/food/soup
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'icons/obj/food/soupsalad.dmi'
	trash_type = /obj/item/reagent_containers/glass/bowl
	bite_consumption = 5
	max_volume = 80
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/water = 5,
		/datum/reagent/consumable/nutriment/vitamin = 4
	)
	tastes = list("bezsmakowa zupa" = 1)
	foodtypes = VEGETABLES
	eatverbs = list("siorbie", "popija", "wciąga", "pije")

/obj/item/food/soup/wish
	name = "zupa życzeń"
	desc = "Życzę sobie, żeby to była zupa."
	icon_state = "wishsoup"
	food_reagents = list(
		/datum/reagent/water = 10
	)
	tastes = list("życzenia" = 1)

/obj/item/food/soup/wish/Initialize(mapload)
	. = ..()
	var/wish_true = prob(25)
	if(wish_true)
		desc = "Życzenie się spełniło!"
		reagents.add_reagent(/datum/reagent/consumable/nutriment, 9)
		reagents.add_reagent(/datum/reagent/consumable/nutriment/vitamin, 1)

/obj/item/food/soup/spacylibertyduff
	name = "kosmiczny deser wolności"
	desc = "Galaretka z książki kucharskiej Alfreda Hubbarda."
	icon_state = "spacylibertyduff"
	bite_consumption = 3
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/drug/mushroomhallucinogen = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5
	)
	tastes = list("galaretka" = 1, "grzyb" = 1)
	foodtypes = VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/soup/amanitajelly
	name = "galaretka z muchomorów"
	desc = "Wygląda podejrzanie toksycznie."
	icon_state = "amanitajelly"
	bite_consumption = 3
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 7,
		/datum/reagent/drug/mushroomhallucinogen = 3,
		/datum/reagent/toxin/amatoxin = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5
	)
	tastes = list("galaretka" = 1, "grzyb" = 1)
	foodtypes = VEGETABLES | TOXIC
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/soup/mammi
	name = "mämmi"
	desc = "Miska rozmokłego chleba z mlekiem. Przypomina ci, niezbyt miło, wizytę w toalecie."
	icon_state = "mammi"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 11,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	crafting_complexity = FOOD_COMPLEXITY_2
