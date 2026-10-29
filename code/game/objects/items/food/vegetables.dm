/obj/item/food/eggplantparm
	name = "bakłażan po parmeńsku"
	desc = "Jedyny dobry przepis na bakłażana."
	icon_state = "eggplantparm"

	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("bakłażan" = 3, "ser" = 1)
	foodtypes = VEGETABLES | DAIRY
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/yakiimo
	name = "yaki imo"
	desc = "Z pieczonych batatów!"
	icon_state = "yakiimo"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("batat" = 1)
	foodtypes = VEGETABLES | SUGAR
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/roastparsnip
	name = "pieczony pasternak"
	desc = "Słodki i chrupiący."
	icon_state = "roastparsnip"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("pasternak" = 1)
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

// Potatoes
/obj/item/food/tatortot
	name = "krokiecik ziemniaczany"
	desc = "Duży smażony ziemniaczany nugget, który może próbować cię zvalidować. Albo nie."
	icon_state = "tatortot"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4)
	tastes = list("ziemniak" = 3, "validy" = 1)
	foodtypes = FRIED | VEGETABLES
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/tatortot/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/dunkable, 10)

/obj/item/food/loaded_baked_potato
	name = "faszerowany pieczony ziemniak"
	desc = "Gorący pieczony ziemniak z wydrążonym środkiem wymieszanym z kawałkami boczku, serem i kapustą."
	icon_state = "loadedbakedpotato"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/consumable/nutriment/protein = 4
	)
	tastes = list("pieczony ziemniak" = 1, "bekon" = 1, "ser" = 1, "kapusta" = 1)
	foodtypes = VEGETABLES | DAIRY | MEAT
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

// Fries
/obj/item/food/fries
	name = "kosmiczne frytki"
	desc = "Znane też jako: frytki belgijskie, frytki wolności itp."
	icon_state = "fries"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4)
	tastes = list("frytki" = 3, "sól" = 1)
	foodtypes = VEGETABLES | FRIED
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/fries/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/dunkable, 10)

/obj/item/food/cheesyfries
	name = "frytki z serem"
	desc = "Frytki. Z serem. No przecież."
	icon_state = "cheesyfries"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("frytki" = 3, "ser" = 1)
	foodtypes = VEGETABLES | DAIRY
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/cheesyfries/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/dunkable, 10)

/obj/item/food/carrotfries
	name = "frytki z marchewki"
	desc = "Smaczne frytki ze świeżej marchewki."
	icon_state = "carrotfries"

	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 2
		)
	tastes = list("marchewki" = 3, "sól" = 1)
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/carrotfries/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/dunkable, 10)
