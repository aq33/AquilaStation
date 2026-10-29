/obj/item/food/tortilla
	name = "tortilla"
	desc = "Podstawa wszystkich twoich burrito."
	icon = 'icons/obj/food/food_ingredients.dmi'
	icon_state = "tortilla"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	tastes = list("tortilla" = 1)
	foodtypes = GRAIN
	w_class = WEIGHT_CLASS_TINY
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/burrito
	name = "burrito"
	desc = "Pyszności zawinięte w tortillę."
	icon = 'icons/obj/food/mexican.dmi'
	icon_state = "burrito"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	tastes = list("tortilla" = 2, "fasola" = 3)
	foodtypes = GRAIN
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/cheesyburrito
	name = "serowe burrito"
	desc = "To burrito wypełnione serem."
	icon = 'icons/obj/food/mexican.dmi'
	icon_state = "cheesyburrito"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("tortilla" = 2, "fasola" = 3, "ser" = 1)
	foodtypes = GRAIN | DAIRY
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/carneburrito
	name = "burrito carne asada"
	desc = "Najlepsze burrito dla miłośników mięsa."
	icon = 'icons/obj/food/mexican.dmi'
	icon_state = "carneburrito"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	tastes = list("tortilla" = 2, "mięso" = 4)
	foodtypes = GRAIN | MEAT
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/fuegoburrito
	name = "plazmowe burrito fuego"
	desc = "Superostre burrito."
	icon = 'icons/obj/food/mexican.dmi'
	icon_state = "fuegoburrito"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/capsaicin = 5,
		/datum/reagent/consumable/nutriment/vitamin = 3,
	)
	tastes = list("tortilla" = 2, "fasola" = 3, "ostre papryki" = 1)
	foodtypes = GRAIN
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/nachos
	name = "nachos"
	desc = "Chipsy z Kosmicznego Meksyku."
	icon = 'icons/obj/food/mexican.dmi'
	icon_state = "nachos"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("nachos" = 1)
	foodtypes = GRAIN | FRIED
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/cheesynachos
	name = "serowe nachos"
	desc = "Pyszne połączenie nachos i topionego sera."
	icon = 'icons/obj/food/mexican.dmi'
	icon_state = "cheesynachos"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/protein = 1,
		/datum/reagent/consumable/nutriment/vitamin = 3,
	)
	tastes = list("nachos" = 2, "ser" = 1)
	foodtypes = GRAIN | FRIED | DAIRY
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/cubannachos
	name = "kubańskie nachos"
	desc = "Niebezpiecznie ostre nachos."
	icon = 'icons/obj/food/mexican.dmi'
	icon_state = "cubannachos"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 7,
		/datum/reagent/consumable/capsaicin = 8,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("nachos" = 2, "ostra papryka" = 1)
	foodtypes = VEGETABLES | FRIED | DAIRY
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/taco
	name = "klasyczne taco"
	desc = "Tradycyjne taco z mięsem, serem i sałatą."
	icon = 'icons/obj/food/mexican.dmi'
	icon_state = "taco"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 3,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("taco" = 4, "mięso" = 2, "ser" = 2, "sałata" = 1)
	foodtypes = MEAT | DAIRY | GRAIN | VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/taco/plain
	name = "zwykłe taco"
	desc = "Tradycyjne taco z mięsem i serem, bez tego królikowego jedzenia."
	icon_state = "taco_plain"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	tastes = list("taco" = 4, "mięso" = 2, "ser" = 2)
	foodtypes = MEAT | DAIRY | GRAIN
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/enchiladas
	name = "enchiladas"
	desc = "Viva México!"
	icon = 'icons/obj/food/mexican.dmi'
	icon_state = "enchiladas"
	bite_consumption = 4
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 7,
		/datum/reagent/consumable/capsaicin = 6,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	tastes = list("ostre papryki" = 1, "mięso" = 3, "ser" = 1, "kwaśna śmietana" = 1)
	foodtypes = MEAT | GRAIN
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/stuffedlegion
	name = "faszerowany legion"
	desc = "Dawna czaszka potępionego człowieka, wypełniona mięsem goliata. Ma ozdobne jeziorko lawy z ketchupu i ostrego sosu."
	icon_state = "stuffed_legion"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/consumable/capsaicin = 2,
	)
	tastes = list("śmierć" = 2, "skała" = 1, "mięso" = 1, "ostre papryki" = 1)
	foodtypes = MEAT
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_5
