/obj/item/food/icecreamsandwich
	name = "kanapka lodowa"
	desc = "Przenośne lody we własnym opakowaniu."
	icon = 'icons/obj/food/frozen_treats.dmi'
	icon_state = "icecreamsandwich"
	w_class = WEIGHT_CLASS_TINY
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/ice = 4
	)
	tastes = list("lody" = 1)
	foodtypes = GRAIN | DAIRY | SUGAR
	food_flags = FOOD_FINGER_FOOD
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/strawberryicecreamsandwich
	name = "truskawkowa kanapka lodowa"
	desc = "Przenośne lody we własnym opakowaniu, w wersji truskawkowej."
	icon = 'icons/obj/food/frozen_treats.dmi'
	icon_state = "strawberryicecreamsandwich"
	w_class = WEIGHT_CLASS_TINY
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/ice = 4
	)
	tastes = list("lody" = 2, "jagoda" = 2)
	foodtypes = FRUIT | DAIRY | SUGAR
	food_flags = FOOD_FINGER_FOOD
	crafting_complexity = FOOD_COMPLEXITY_3


/obj/item/food/spacefreezy
	name = "kosmiczna mrożonka"
	desc = "Najlepsze lody w kosmosie."
	icon = 'icons/obj/food/frozen_treats.dmi'
	icon_state = "spacefreezy"
	w_class = WEIGHT_CLASS_TINY
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/bluecherryjelly = 5,
		/datum/reagent/consumable/nutriment/vitamin = 5
	)
	tastes = list("niebieskie wiśnie" = 2, "lody" = 2)
	foodtypes = FRUIT | DAIRY | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sundae
	name = "puchar lodowy"
	desc = "Klasyczny deser."
	icon = 'icons/obj/food/frozen_treats.dmi'
	icon_state = "sundae"
	w_class = WEIGHT_CLASS_SMALL
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/banana = 5,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	tastes = list("lody" = 1, "banan" = 1)
	foodtypes = FRUIT | DAIRY | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/honkdae
	name = "honkowy puchar lodowy"
	desc = "Ulubiony deser klauna."
	icon = 'icons/obj/food/frozen_treats.dmi'
	icon_state = "honkdae"
	w_class = WEIGHT_CLASS_SMALL
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/banana = 10,
		/datum/reagent/consumable/nutriment/vitamin = 4
	)
	tastes = list("lody" = 1, "banan" = 1, "kiepski żart" = 1)
	foodtypes = FRUIT | DAIRY | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_4

/////////////
//SNOWCONES//
/////////////

/obj/item/food/snowcones //We use this as a base for all other snowcones
	name = "kruszony lód bez smaku"
	desc = "To tylko kruszony lód. Wciąż fajnie się go gryzie."
	icon = 'icons/obj/food/frozen_treats.dmi'
	icon_state = "flavorless_sc"
	w_class = WEIGHT_CLASS_SMALL
	trash_type = /obj/item/reagent_containers/food/drinks/sillycup //We dont eat paper cups
	food_reagents = list(
		/datum/reagent/water = 11 // We dont get food for water/juices
	)
	tastes = list("lód" = 1, "woda" = 1)
	foodtypes = SUGAR //We use SUGAR as a base line to act in as junkfood, other wise we use fruit
	food_flags = FOOD_FINGER_FOOD
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/snowcones/lime
	name = "kruszony lód limonkowy"
	desc = "Syrop limonkowy polany na kulkę kruszonego lodu w papierowym kubku."
	icon_state = "lime_sc"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/limejuice = 5,
		/datum/reagent/water = 11
	)
	tastes = list("lód" = 1, "woda" = 1, "limonki" = 5)
	foodtypes = FRUIT

/obj/item/food/snowcones/lemon
	name = "kruszony lód cytrynowy"
	desc = "Syrop cytrynowy polany na kulkę kruszonego lodu w papierowym kubku."
	icon_state = "lemon_sc"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/lemonjuice = 5,
		/datum/reagent/water = 11
	)
	tastes = list("lód" = 1, "woda" = 1, "cytryny" = 5)
	foodtypes = FRUIT

/obj/item/food/snowcones/apple
	name = "kruszony lód jabłkowy"
	desc = "Syrop jabłkowy polany na kulkę kruszonego lodu w papierowym kubku."
	icon_state = "amber_sc"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/applejuice = 5,
		/datum/reagent/water = 11
	)
	tastes = list("lód" = 1, "woda" = 1, "jabłka" = 5)
	foodtypes = FRUIT

/obj/item/food/snowcones/grape
	name = "kruszony lód winogronowy"
	desc = "Syrop winogronowy polany na kulkę kruszonego lodu w papierowym kubku."
	icon_state = "grape_sc"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/grapejuice = 5,
		/datum/reagent/water = 11
	)
	tastes = list("lód" = 1, "woda" = 1, "winogrono" = 5)
	foodtypes = FRUIT

/obj/item/food/snowcones/orange
	name = "kruszony lód pomarańczowy"
	desc = "Syrop pomarańczowy polany na kulkę kruszonego lodu w papierowym kubku."
	icon_state = "orange_sc"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/orangejuice = 5,
		/datum/reagent/water = 11
	)
	tastes = list("lód" = 1, "woda" = 1, "pomarańcza" = 5)
	foodtypes = FRUIT

/obj/item/food/snowcones/blue
	name = "kruszony lód z niebieskich wiśni"
	desc = "Syrop z niebieskich wiśni polany na kulkę kruszonego lodu w papierowym kubku. Co za rzadkość!"
	icon_state = "blue_sc"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/bluecherryjelly = 5
	)
	tastes = list("lód" = 1, "woda" = 1, "kolor niebieski" = 5, "wiśnie" = 5)
	foodtypes = FRUIT

/obj/item/food/snowcones/red
	name = "kruszony lód wiśniowy"
	desc = "Syrop wiśniowy polany na kulkę kruszonego lodu w papierowym kubku."
	icon_state = "red_sc"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/cherryjelly = 5,
		/datum/reagent/water = 11
	)
	tastes = list("lód" = 1, "woda" = 1, "kolor czerwony" = 5, "wiśnie" = 5)
	foodtypes = FRUIT

/obj/item/food/snowcones/berry
	name = "kruszony lód jagodowy"
	desc = "Syrop jagodowy polany na kulkę kruszonego lodu w papierowym kubku."
	icon_state = "berry_sc"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/berryjuice = 5, \
		/datum/reagent/water = 11
	)
	tastes = list("lód" = 1, "woda" = 1, "jagody" = 5)
	foodtypes = FRUIT

/obj/item/food/snowcones/fruitsalad
	name = "kruszony lód owocowy"
	desc = "Rozkoszna mieszanka syropów cytrusowych polana na kulkę kruszonego lodu w papierowym kubku."
	icon_state = "fruitsalad_sc"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/lemonjuice = 5,
		/datum/reagent/consumable/limejuice = 5,
		/datum/reagent/consumable/orangejuice = 5,
		/datum/reagent/water = 11
	)
	tastes = list("lód" = 1, "woda" = 1, "pomarańcze" = 5, "limonki" = 5, "cytryny" = 5, "cytrusy" = 5, "sałatka" = 5)
	foodtypes = FRUIT

/obj/item/food/snowcones/pineapple
	name = "kruszony lód ananasowy"
	desc = "Syrop ananasowy polany na kulkę kruszonego lodu w papierowym kubku."
	icon_state = "pineapple_sc"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/pineapplejuice = 5,
		/datum/reagent/water = 11
	)
	tastes = list("lód" = 1, "woda" = 1, "ananasy" = 5)
	foodtypes = PINEAPPLE //Pineapple to allow all that like pineapple to enjoy

/obj/item/food/snowcones/mime
	name = "kruszony lód mima"
	desc = "..."
	icon_state = "mime_sc"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/nothing = 5,
		/datum/reagent/water = 11
	)
	tastes = list("lód" = 1, "woda" = 1, "nic" = 5)
	foodtypes = SUGAR

/obj/item/food/snowcones/clown
	name = "kruszony lód klauna"
	desc = "Śmiech polany na kulkę kruszonego lodu w papierowym kubku."
	icon_state = "clown_sc"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/laughter = 5,
		/datum/reagent/water = 11
	)
	tastes = list("lód" = 1, "woda" = 1, "żarty" = 5, "lodowy ból głowy" = 5, "radość" = 5)
	foodtypes = SUGAR | FRUIT

/obj/item/food/snowcones/soda
	name = "kruszony lód z Kosmiczną Colą"
	desc = "Kosmiczna Cola polana na kulkę kruszonego lodu w papierowym kubku."
	icon_state = "soda_sc"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/space_cola = 5,
		/datum/reagent/water = 11
	)
	tastes = list("lód" = 1, "woda" = 1, "cola" = 5)
	foodtypes = SUGAR

/obj/item/food/snowcones/spacemountainwind
	name = "kruszony lód z Kosmicznym Górskim Wiatrem"
	desc = "Kosmiczny Górski Wiatr polany na kulkę kruszonego lodu w papierowym kubku."
	icon_state = "mountainwind_sc"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/spacemountainwind = 5,
		/datum/reagent/water = 11
	)
	tastes = list("lód" = 1, "woda" = 1, "górski wiatr" = 5)
	foodtypes = SUGAR


/obj/item/food/snowcones/pwrgame
	name = "kruszony lód z Pwr Game"
	desc = "Napój Pwr Game polany na kulkę kruszonego lodu w papierowym kubku."
	icon_state = "pwrgame_sc"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/pwr_game = 5,
		/datum/reagent/water = 11
	)
	tastes = list("lód" = 1, "woda" = 1, "valid" = 5, "sól" = 5, "waty" = 5)
	foodtypes = SUGAR

/obj/item/food/snowcones/honey
	name = "kruszony lód miodowy"
	desc = "Miód polany na kulkę kruszonego lodu w papierowym kubku."
	icon_state = "amber_sc"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/honey = 5,
		/datum/reagent/water = 11
	)
	tastes = list("lód" = 1, "woda" = 1, "kwiaty" = 5, "słodycz" = 5, "wosk" = 1)
	foodtypes = SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/snowcones/rainbow
	name = "tęczowy kruszony lód"
	desc = "Bardzo kolorowa kulka kruszonego lodu w papierowym kubku."
	icon_state = "rainbow_sc"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/laughter = 25,
		/datum/reagent/water = 11
	)
	tastes = list("lód" = 1, "woda" = 1, "światło słoneczne" = 5, "światło" = 5, "szlam" = 5, "farba" = 3, "chmury" = 3)
	foodtypes = SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3
