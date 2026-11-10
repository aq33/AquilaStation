// AQUILA - polskie jedzenie: gołąbki i żurek z tg (tgstation/tgstation#65848), ptasie mleczko z CM-SS13

/obj/item/food/golabki
	name = "gołąbki"
	desc = "Mielone mięso z ryżem zawinięte w liście kapusty i polane sosem pomidorowym. Palce lizać."
	icon = 'aquila/icons/obj/food/polskie.dmi'
	icon_state = "stuffed_cabbage"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	tastes = list("soczyste mięso" = 1, "ryż" = 1, "kapusta" = 1)
	foodtypes = MEAT | VEGETABLES | GRAIN
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/ptasie_mleczko
	name = "ptasie mleczko"
	desc = "Mięciutka pianka w czekoladzie. Popularny słodycz z Polski, idealny do herbaty."
	icon = 'aquila/icons/obj/food/polskie.dmi'
	icon_state = "ptasie_mleczko"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 4,
		/datum/reagent/consumable/cream = 3,
		/datum/reagent/consumable/cocoa = 3,
	)
	tastes = list("czekolada" = 1, "słodka pianka" = 1)
	foodtypes = SUGAR | DAIRY | JUNKFOOD
	junkiness = 10
	w_class = WEIGHT_CLASS_SMALL

// Jedzenie z Polonium Station (polonium14/polonium-station). Sprite'y: Tofi_Dev, cybercoffeedev, pinkscreen, Saver310 (CC-BY-SA-3.0).

/obj/item/food/kabanosy
	name = "kabanosy neo-tarczyńskie"
	desc = "Słone, cienkie paluszki mięsa, które były wędzone przez jakiś czas."
	icon = 'aquila/icons/obj/food/polskie.dmi'
	icon_state = "kabanosy"
	trash_type = /obj/item/trash/kabanosy
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/sodiumchloride = 2,
	)
	junkiness = 15
	tastes = list("wędzone mięso" = 2, "sól" = 1)
	foodtypes = JUNKFOOD | MEAT
	w_class = WEIGHT_CLASS_SMALL

/obj/item/trash/kabanosy
	name = "opakowanie po kabanosach"
	desc = "Aż smutno, że się skończyły."
	icon = 'aquila/icons/obj/food/polskie.dmi'
	icon_state = "kabanosy_trash"

/obj/item/food/parowka
	name = "parówka"
	desc = "Parówka, taka jak z żabki."
	icon = 'aquila/icons/obj/food/polskie.dmi'
	icon_state = "parowka"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/nutriment/fat = 1,
	)
	tastes = list("parówka" = 1)
	foodtypes = MEAT
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/peto_parowek
	name = "pęto parówek"
	desc = "Pęto parówek, no bo kto nie lubi parówek. Pokrój nożem na stole."
	icon = 'aquila/icons/obj/food/polskie.dmi'
	icon_state = "peto_parowek"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 16,
		/datum/reagent/consumable/nutriment/fat = 4,
	)
	tastes = list("parówka" = 1)
	foodtypes = MEAT
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/food/peto_parowek/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/parowka, 4, 3 SECONDS, table_required = TRUE, screentip_verb = "Pokrój")
