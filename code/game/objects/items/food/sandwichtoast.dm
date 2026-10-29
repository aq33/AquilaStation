/obj/item/food/sandwich
	name = "kanapka"
	desc = "Wspaniałe dzieło z mięsa, sera, chleba i kilku liści sałaty! Arthur Dent byłby dumny."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "sandwich"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/protein = 7,
		/datum/reagent/consumable/nutriment/vitamin = 1
	)
	tastes = list("mięso" = 2, "ser" = 1, "chleb" = 2, "sałata" = 1)
	foodtypes = GRAIN | VEGETABLES
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/grilled_cheese_sandwich
	name = "tost z serem"
	desc = "Ciepła kanapka z roztopionym serem, idealna do zupy pomidorowej."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "toastedsandwich"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/carbon = 4
	)
	tastes = list("tost" = 2, "ser" = 3, "masło" = 1)
	foodtypes = GRAIN
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cheese_sandwich
	name = "kanapka z serem"
	desc = "Lekka przekąska na ciepły dzień. ...ale co, gdyby ją zgrillować?"
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "sandwich"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 7,
		/datum/reagent/consumable/nutriment/protein = 3,
		/datum/reagent/consumable/nutriment/vitamin = 1
	)
	tastes = list("chleb" = 1, "ser" = 1)
	foodtypes = GRAIN | DAIRY
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/cheese_sandwich/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/grilled_cheese_sandwich, rand(30 SECONDS, 60 SECONDS), TRUE)

/obj/item/food/jellysandwich
	name = "kanapka z dżemem"
	desc = "Szkoda, że nie masz do tego masła orzechowego..."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "jellysandwich"
	bite_consumption = 3
	tastes = list("chleb" = 1, "galaretka" = 1)
	foodtypes = GRAIN
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/jellysandwich/slime
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/toxin/slimejelly = 10,
		/datum/reagent/consumable/nutriment/vitamin = 4
	)
	foodtypes = GRAIN | TOXIC

/obj/item/food/jellysandwich/cherry
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/cherryjelly = 8,
		/datum/reagent/consumable/nutriment/vitamin = 4
	)
	foodtypes = GRAIN | FRUIT | SUGAR

/obj/item/food/notasandwich
	name = "nie-kanapka"
	desc = "Coś tu jest nie tak, ale nie wiesz dokładnie co. Może to te wąsy."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "notasandwich"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 10
	)
	tastes = list("nic podejrzanego" = 1)
	foodtypes = GRAIN | GROSS
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/butteredtoast
	name = "tost z masłem"
	desc = "Kromka tostu lekko posmarowana masłem."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "butteredtoast"
	bite_consumption = 3
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/vitamin = 1
	)
	tastes = list("masło" = 1, "tost" = 1)
	foodtypes = GRAIN | BREAKFAST
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/jelliedtoast
	name = "tost z dżemem"
	desc = "Kromka tostu z pysznym dżemem."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "jellytoast"
	bite_consumption = 3
	tastes = list("tost" = 1, "galaretka" = 1)
	foodtypes = GRAIN | BREAKFAST
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/jelliedtoast/cherry
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/cherryjelly = 8,
		/datum/reagent/consumable/nutriment/vitamin = 4
	)
	foodtypes = GRAIN | FRUIT | SUGAR | BREAKFAST

/obj/item/food/jelliedtoast/slime
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/toxin/slimejelly = 8,
		/datum/reagent/consumable/nutriment/vitamin = 4
	)
	foodtypes = GRAIN | TOXIC | SUGAR | BREAKFAST

/obj/item/food/twobread
	name = "dwa chleby"
	desc = "Wydaje się strasznie gorzkie."
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "twobread"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 4
	)
	tastes = list("chleb" = 2)
	foodtypes = GRAIN
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/hotdog
	name = "hot dog"
	desc = "Gorąca, parująca parówka w bułce."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "hotdog"
	bite_consumption = 3
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 1,
		/datum/reagent/consumable/ketchup = 3,
		/datum/reagent/consumable/nutriment/vitamin = 6,
	)
	tastes = list("bułka" = 3, "mięso" = 2)
	foodtypes = GRAIN | MEAT //Ketchup is not a vegetable
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3
