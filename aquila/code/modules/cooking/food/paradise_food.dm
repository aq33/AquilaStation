// AQUILA - dania z Paradise (ParadiseSS13/Paradise, code/modules/food_and_drinks/food), robione krok po kroku.
// Wygenerowane z definicji Paradise; nazwy i opisy po polsku. Sprite'y: Paradise, CC BY-SA 3.0 (aquila/icons/obj/food/paradise).

/obj/item/food/sweet
	name = "słodycz"
	foodtypes = JUNKFOOD | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/popsicle
	trash_type = /obj/item/popsicle_stick
	name = "lód na patyku"
	foodtypes = SUGAR | DAIRY
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/frozen_dessert
	name = "mrożony deser"
	foodtypes = SUGAR | DAIRY
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sushi_roll
	name = "rolka sushi"
	foodtypes = MEAT | GRAIN
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sushi_piece
	name = "sushi"
	foodtypes = MEAT | GRAIN
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/arepa
	name = "arepa"
	desc = "Smak Wenezueli."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "arepa"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	foodtypes = GRAIN
	bite_consumption = 4
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/arepa/cheese
	name = "arepa z serem"
	desc = "Smak Wenezueli, tylko z serem."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "arepa_cheese"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	foodtypes = DAIRY | GRAIN
	bite_consumption = 4
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/arepa/cheesier
	name = "arepa z dużą ilością sera"
	desc = "Mnóstwo sera w pysznej arepie."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "cheese_arepa"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	foodtypes = DAIRY | GRAIN
	bite_consumption = 10
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/arepa/fruit
	name = "arepa owocowa"
	desc = "Tropikalna arepa."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "fruit_arepa"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/vitamin = 8,
		/datum/reagent/consumable/banana = 10,
	)
	foodtypes = FRUIT | GRAIN
	bite_consumption = 5
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/arepa/ghost
	name = "arepa duchów"
	desc = "Przepysznie straszna. BUUUUUUU."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "arepa_ghost"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 7,
	)
	foodtypes = DAIRY | GRAIN
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/arepa/ham
	name = "arepa z szynką"
	desc = "Smak Wenezueli, tylko z szynką."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "ham_arepa"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	foodtypes = GRAIN | MEAT
	bite_consumption = 4
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/arepa/ham_cheese
	name = "arepa z szynką i serem"
	desc = "Smak Wenezueli, ale z szynką i serem."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "arepa_ham_cheese"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 6,
	)
	foodtypes = DAIRY | GRAIN | MEAT
	bite_consumption = 6
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/arepa/ice
	name = "arepa w lodzie"
	desc = "Bryła lodu z arepą w środku."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "arepa_ice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/consumable/frostoil = 25,
	)
	foodtypes = GRAIN
	bite_consumption = 5
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/arepa/industrial
	name = "arepa przemysłowa"
	desc = "Bip bup WENEZUELO, POWSTAŃ bip."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "arepa_industrial"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/nutriment/fat/oil = 10,
		/datum/reagent/iron = 10,
	)
	foodtypes = GRAIN
	bite_consumption = 7
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/arepa/infernal
	name = "piekielna arepa"
	desc = "Od samego zapachu pali cię w nosie."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "arepa_infernal"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/consumable/capsaicin = 10,
		/datum/reagent/consumable/condensedcapsaicin = 7,
	)
	foodtypes = GRAIN
	bite_consumption = 5
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/arepa/life
	name = "święta arepa"
	desc = "Stworzona przez maga w domu jego mamy."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "arepa_life"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 0,
		/datum/reagent/consumable/nutriment/vitamin = 0,
		/datum/reagent/medicine/strange_reagent = 5,
	)
	foodtypes = GRAIN
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/arepa/magma
	name = "arepa z magmą"
	desc = "Arepa prosto z Lawalandu."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "arepa_magma"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/consumable/capsaicin = 20,
		/datum/reagent/consumable/condensedcapsaicin = 20,
	)
	foodtypes = GRAIN
	bite_consumption = 6
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/arepa/plasma
	name = "arepa z plazmą"
	desc = "Smak Wenezueli na zupełnie innym poziomie."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "arepa_plasma"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/vitamin = 9,
	)
	foodtypes = GRAIN
	bite_consumption = 6
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/arepa/plumphelmet
	name = "arepa krasnoludzka"
	desc = "Sam Armok stworzył tę arepę."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "arepa_plumphelmet"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 9,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	foodtypes = GRAIN | VEGETABLES
	bite_consumption = 5
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/arepa/salmon
	name = "arepa z łososiem"
	desc = "W zamyśle miał być tuńczyk."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "arepa_salmon"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/vitamin = 8,
	)
	foodtypes = GRAIN | MEAT
	bite_consumption = 5
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/arepa/slime
	name = "arepa ze szlamem"
	desc = "Gładka arepa."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "arepa_slime"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/toxin/slimejelly = 5,
	)
	foodtypes = GRAIN
	bite_consumption = 4
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/arepa/spider
	name = "arepa z pająkiem"
	desc = "Chyba się jeszcze rusza... Dobra, przysięgam, że się ruszyła."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "spider_arepa"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 7,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/toxin = 2,
		/datum/reagent/medicine/charcoal = 2,
	)
	foodtypes = GRAIN | MEAT | TOXIC
	bite_consumption = 7
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/arepa/sweet
	name = "słodka arepa"
	desc = "Słodka i pyszna arepa."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "sweet_arepa"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/toxin/slimejelly = 10,
		/datum/reagent/consumable/sugar = 10,
	)
	foodtypes = GRAIN | SUGAR
	bite_consumption = 5
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/arepa/xeno
	name = "ksenoarepa"
	desc = "Lepka, grudkowata i okropnie śmierdzi, ale ma wszystko, czego potrzebuje zdrowe ciało, nawet jeśli zbiera ci się na wymioty."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "xeno_arepa"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	foodtypes = GRAIN | MEAT | SUGAR
	bite_consumption = 5
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/avocadosalmon
	name = "łosoś z awokado"
	desc = "Świeżo grillowany filet z łososia z awokado."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "salmonavocado"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/consumable/sodiumchloride = 1,
		/datum/reagent/consumable/nutriment/protein = 1,
	)
	tastes = list("mięso z warzywami" = 1)
	foodtypes = FRUIT | MEAT
	bite_consumption = 4
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/avocadosandwich
	name = "kanapka z awokado"
	desc = "Z awokado i dużą ilością majonezu."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "avocado_sandwich"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/consumable/mayonnaise = 5,
	)
	tastes = list("chleb" = 1, "awokado" = 2)
	foodtypes = FRUIT | GRAIN
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/baconrolled
	name = "roladki z boczku z awokado"
	desc = "Plastry boczku zwinięte z awokado w środku!"
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "bacon_roll"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 1,
		/datum/reagent/consumable/nutriment = 2,
	)
	tastes = list("mięso z warzywami" = 1)
	foodtypes = BREAKFAST | FRUIT | MEAT
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/blt
	name = "kanapka BLT"
	desc = "Klasyczna kanapka z boczkiem, sałatą i pomidorem."
	icon = 'aquila/icons/obj/food/paradise/burgerbread.dmi'
	icon_state = "blt"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	tastes = list("bekon" = 3, "sałata" = 2, "pomidor" = 2, "chleb" = 2)
	foodtypes = BREAKFAST | FRUIT | GRAIN | MEAT | VEGETABLES
	bite_consumption = 4
	crafting_complexity = FOOD_COMPLEXITY_3

/// Surowa krewetka: składnik gotowanych i smażonych krewetek oraz szaszłyka, kupowana w konsoli zamówień kuchni
/obj/item/food/shellfish_meat/shrimp
	name = "surowa krewetka"
	desc = "Smaczna krewetka, gotowa do użycia. Zjedzona w nadmiarze szkodzi."
	icon = 'aquila/icons/obj/food/paradise/seafood.dmi'
	icon_state = "shrimp_raw"
	w_class = WEIGHT_CLASS_TINY
	bite_consumption = 4
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 3)
	tastes = list("krewetka" = 1)
	foodtypes = MEAT | RAW

/obj/item/food/boiled_shrimp
	name = "gotowane krewetki"
	desc = "Tylko jedna z wielu rzeczy, które można zrobić z krewetek!"
	icon = 'aquila/icons/obj/food/paradise/seafood.dmi'
	icon_state = "shrimp_cooked"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
	)
	tastes = list("krewetki" = 1)
	foodtypes = MEAT
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/boiledslimecore
	name = "gotowany rdzeń szlamu"
	desc = "Ugotowana czerwona rzecz."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "boiledrorocore"
	food_reagents = list(
		/datum/reagent/toxin/slimejelly = 5,
	)
	tastes = list("galaretka" = 1)
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/bread/banarnar
	name = "bochenek banarnarowy"
	desc = "Bochenek przepysznego mah'weyh pleggh at e'ntrath!"
	icon = 'aquila/icons/obj/food/paradise/burgerbread.dmi'
	icon_state = "banarnarbread"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	tastes = list("herezja" = 10, "banan" = 10)
	foodtypes = DAIRY | FRUIT | GRAIN | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3
	slice_type = /obj/item/food/breadslice/banarnar
	yield = 5

/obj/item/food/breadslice/banarnar
	name = "kromka chleba banarnarowego"
	desc = "Kromka przepysznego mah'weyh pleggh at e'ntrath!"
	icon = 'aquila/icons/obj/food/paradise/burgerbread.dmi'
	icon_state = "banarnarbreadslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	tastes = list("herezja" = 10, "banan" = 10)
	foodtypes = DAIRY | FRUIT | GRAIN | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/burger/nothing
	name = "burger z niczym"
	desc = "Naprawdę spodziewałeś się czegoś więcej."
	icon = 'aquila/icons/obj/food/paradise/burgerbread.dmi'
	icon_state = "nothingburger1"
	food_reagents = list(
		/datum/reagent/consumable/nothing = 10,
	)
	tastes = list("nic" = 4, "absolutnie nic" = 1, "temperatura pokojowa" = 2)
	foodtypes = GRAIN
	bite_consumption = 5
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/burger/rainbow
	name = "tęczowy ładny burger"
	desc = "Poczuj smak tęczy, zjedz tęczę."
	icon = 'aquila/icons/obj/food/paradise/burgerbread.dmi'
	icon_state = "ppatty-rainbow"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 14,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/medicine/omnizine = 10,
	)
	tastes = list("bułka" = 2, "mięso" = 2, "tęcza" = 5)
	foodtypes = GRAIN | MEAT
	bite_consumption = 4
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/cake/banana
	name = "ciasto bananowe"
	desc = "Ciasto z bananami."
	icon = 'aquila/icons/obj/food/paradise/bakedgoods.dmi'
	icon_state = "bananacake"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	tastes = list("ciasto" = 5, "słodycz" = 2, "banan" = 2)
	foodtypes = DAIRY | FRUIT | GRAIN
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3
	slice_type = /obj/item/food/cakeslice/banana
	yield = 5

/obj/item/food/cake/plum
	name = "ciasto śliwkowe"
	desc = "Ciasto z dodatkiem śliwek."
	icon = 'aquila/icons/obj/food/paradise/bakedgoods.dmi'
	icon_state = "plum_cake"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/nutriment/vitamin = 10,
	)
	tastes = list("ciasto" = 5, "słodycz" = 1, "śliwka" = 2)
	foodtypes = DAIRY | FRUIT | GRAIN | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3
	slice_type = /obj/item/food/cakeslice/plum
	yield = 5

/obj/item/food/cakeslice/banana
	name = "kawałek ciasta bananowego"
	desc = "Zwykły kawałek ciasta. Wystarczy dla wszystkich."
	icon = 'aquila/icons/obj/food/paradise/bakedgoods.dmi'
	icon_state = "bananacake_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	tastes = list("ciasto" = 5, "słodycz" = 2, "banan" = 2)
	foodtypes = DAIRY | FRUIT | GRAIN
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/cakeslice/plum
	name = "kawałek ciasta śliwkowego"
	desc = "Kawałek ciasta śliwkowego."
	icon = 'aquila/icons/obj/food/paradise/bakedgoods.dmi'
	icon_state = "plum_cake_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("ciasto" = 5, "słodycz" = 1, "śliwka" = 2)
	foodtypes = DAIRY | FRUIT | GRAIN | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/cannoli
	name = "cannoli"
	desc = "Sycylijski przysmak, po którym zostajesz mafiosem."
	icon = 'aquila/icons/obj/food/paradise/bakedgoods.dmi'
	icon_state = "cannoli"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("ciasto" = 1)
	foodtypes = DAIRY | GRAIN | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/caribean_paradise
	name = "karaibski raj"
	desc = "Pół kokosa nadziane mango."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "caribean_paradise"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/sugar = 2,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("mango" = 1)
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/cheese_balls
	name = "ælorölen"
	desc = "Ælorölen (serowe kulki) to tradycyjny deser ciem: miękki ser, cukier puder i mąka zwinięte w kulki, w panierce, smażone w głębokim oleju. Podawane z sosem czekoladowym albo miodem, a czasem z obydwoma!"
	icon = 'aquila/icons/obj/food/paradise/bakedgoods.dmi'
	icon_state = "moth_cheese_cakes"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/sugar = 12,
	)
	tastes = list("sernik" = 1, "czekolada" = 1, "miód" = 1)
	foodtypes = DAIRY | GRAIN | JUNKFOOD | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/chimichanga
	name = "chimichanga"
	desc = "Czas na chimi-cholerną-changę."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "chimichanga"
	food_reagents = list(
		/datum/reagent/medicine/omnizine = 4,
		/datum/reagent/consumable/nutriment/soup/cheese = 2,
	)
	foodtypes = GRAIN
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/citrussalmon
	name = "grillowany łosoś z cytrusami"
	desc = "Świeżo grillowany filet z łososia z owocami cytrusowymi."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "citrussalmon"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/consumable/orangejuice = 2,
		/datum/reagent/consumable/lemonjuice = 2,
	)
	tastes = list("łosoś" = 1, "cytrusy" = 1)
	foodtypes = FRUIT | MEAT
	bite_consumption = 4
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/croissant
	name = "rogalik francuski"
	desc = "Kiedyś przysmak burżuazji, dziś ta krucha pyszność trafia na twój stół."
	icon = 'aquila/icons/obj/food/paradise/bakedgoods.dmi'
	icon_state = "croissant"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/sugar = 2,
	)
	tastes = list("rogalik" = 1)
	foodtypes = DAIRY | GRAIN | MEAT | SUGAR
	bite_consumption = 4
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/donut/jelly/cherryjelly
	name = "pączek z galaretką wiśniową"
	desc = "Zazdrościsz?"
	icon = 'aquila/icons/obj/food/paradise/bakedgoods.dmi'
	icon_state = "jdonut1"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/sugar = 2,
	)
	tastes = list("galaretka" = 1, "pączek" = 3)
	foodtypes = GRAIN | SUGAR
	bite_consumption = 5
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/ensaladacactus
	name = "sałatka z opuncji"
	desc = "Sałatka dziennie trzyma lekarza z daleka."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "cactus_salad"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 8,
	)
	tastes = list("opuncja" = 4, "kapusta z pomidorem" = 3)
	foodtypes = FRUIT | VEGETABLES
	bite_consumption = 1
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/flatbread
	name = "podpłomyk"
	desc = "Mdły, ale sycący."
	icon = 'aquila/icons/obj/food/paradise/food_ingredients.dmi'
	icon_state = "flatbread"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	tastes = list("chleb" = 1)
	foodtypes = GRAIN
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/fried_nian
	name = "skrzydełka Moffolo"
	desc = "Kubełek skrzydełek Moffolo. Litera B na kubełku jest przekreślona niebieskim długopisem, a nad nią ktoś nabazgrał M."
	icon = 'aquila/icons/obj/food/paradise/cannibalism.dmi'
	icon_state = "fried_nian"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 5,
	)
	tastes = list("puch" = 1, "długi" = 1)
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/fried_nian_bbq
	name = "dzikie skrzydełka Moffolo"
	desc = "Kubełek dzikich skrzydełek Moffolo. Litera B na kubełku jest przekreślona niebieskim długopisem, a nad nią ktoś nabazgrał M."
	icon = 'aquila/icons/obj/food/paradise/cannibalism.dmi'
	icon_state = "fried_nian_bbq"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 5,
	)
	tastes = list("puch" = 1, "długi" = 1, "sos barbecue" = 1)
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/fried_shrimp
	name = "smażone krewetki"
	desc = "Tylko jedna z wielu rzeczy, które można zrobić z krewetek!"
	icon = 'aquila/icons/obj/food/paradise/seafood.dmi'
	icon_state = "shrimp_fried"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
	)
	tastes = list("krewetki" = 1, "bułka tarta" = 1)
	foodtypes = MEAT
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/fried_tofu
	name = "smażone tofu"
	desc = "Dowód, że nawet wegetarianie mają ochotę na niezdrowe jedzenie."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "tofu"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
	)
	tastes = list("tofu" = 1)
	foodtypes = VEGETABLES
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/friedbanana
	name = "smażony banan"
	desc = "Goreng pisang, czyli banany smażone."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "friedbanana"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/fat/oil = 4,
	)
	foodtypes = FRUIT | GRAIN | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/friedrice
	name = "smażony ryż"
	desc = "Ryż, ale smażony!"
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "friedrice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
	)
	tastes = list("smażony ryż" = 1)
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/friedriceegg
	name = "smażony ryż z jajkiem"
	desc = "Smażony ryż z jajkiem sadzonym na wierzchu!"
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "friedriceegg"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 7,
	)
	tastes = list("smażony ryż" = 1, "jajko" = 1)
	foodtypes = BREAKFAST | FRIED | MEAT
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/frozen_dessert/cornuto
	name = "cornetto"
	desc = "Neapolitański rożek z lodami waniliowymi i czekoladowymi. Grozi posypką z karmelizowanych orzechów."
	icon = 'aquila/icons/obj/food/paradise/frozen_treats.dmi'
	icon_state = "cornuto"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/cocoa/hot_cocoa = 4,
		/datum/reagent/consumable/cream = 2,
		/datum/reagent/consumable/vanilla = 4,
		/datum/reagent/consumable/sugar = 2,
	)
	tastes = list("siekane orzechy laskowe" = 3, "gofr" = 5)
	foodtypes = DAIRY | GRAIN | JUNKFOOD | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/frozen_dessert/peanutbuttermochi
	name = "mochi z lodami z masła orzechowego"
	desc = "Klasyczny deser z nocnego targu przy ulicy Arabskiej w Prospect: mochi z lodami o smaku masła orzechowego."
	icon = 'aquila/icons/obj/food/paradise/frozen_treats.dmi'
	icon_state = "pb_ice_cream_mochi"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/sugar = 6,
		/datum/reagent/consumable/peanut_butter = 4,
		/datum/reagent/consumable/milk = 2,
	)
	tastes = list("masło orzechowe" = 1, "mochi" = 1)
	foodtypes = DAIRY | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/fufu
	name = "fufu"
	desc = "Najlepsze z zupą."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "fufu"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("banan" = 1)
	foodtypes = FRUIT
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/garlic_snack
	name = "dip czosnkowy"
	desc = "Świeża mieszanka czosnku z awokado."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "garlic_snack"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	foodtypes = GRAIN
	bite_consumption = 5
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/gigapuddi
	name = "giga puddi"
	desc = "Wielki krem karmelowy."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "gigapuddi"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("Japonia" = 4, "mleko" = 3)
	foodtypes = DAIRY | JUNKFOOD | MEAT | SUGAR
	bite_consumption = 50
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/glass_sandwich
	name = "kanapka ze szkłem"
	desc = "Pokruszone odłamki szkła między dwiema kromkami chleba. Chrupiąca!"
	icon = 'aquila/icons/obj/food/paradise/burgerbread.dmi'
	icon_state = "glass_sandwich"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
	)
	tastes = list("dziesiątki odłamków szkła wbijających się w usta" = 3, "ból" = 3, "chleb" = 2)
	foodtypes = GRAIN
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/glass_sandwich/plasma
	name = "kanapka ze szkłem plazmowym"
	desc = "Ostre jak brzytwa odłamki szkła plazmowego między dwiema kromkami chleba. Bardzo chrupiąca!"
	icon = 'aquila/icons/obj/food/paradise/burgerbread.dmi'
	icon_state = "plasma_glass_sandwich"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/toxin/plasma = 5,
	)
	tastes = list("dziesiątki odłamków szkła wbijających się w usta" = 3, "ból" = 3, "chleb" = 2)
	foodtypes = GRAIN
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/ham_leg
	name = "udziec"
	desc = "Udziec z szynki."
	icon = 'aquila/icons/obj/food/paradise/cannibalism.dmi'
	icon_state = "ham_leg"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 5,
	)
	tastes = list("ludzkie mięso" = 1, "spalone włosy" = 1)
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/kebab/ash
	name = "kebab z popiołów"
	desc = "Kebab z jadalnej fauny i flory z popielnego pustkowia."
	icon = 'aquila/icons/obj/food/paradise/meat.dmi'
	icon_state = "ash_kebab"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/vitfro = 2,
	)
	tastes = list("mięso" = 1, "owoc kaktusa" = 2, "grzybowa kapusta" = 1, "popiół" = 1)
	foodtypes = MEAT | TOXIC
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/kebab/fish
	name = "szaszłyk rybny"
	desc = "Cała ryba w cieście, grillowana na szpikulcu. Oby ci dopisywał apetyt!"
	icon = 'aquila/icons/obj/food/paradise/seafood.dmi'
	icon_state = "fishskewer"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("krewetki" = 1, "panierka" = 1)
	foodtypes = GRAIN | MEAT
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/kebab/hiss
	name = "kebab syczący"
	desc = "Kość z grillowanym mięsem. Czy to łuski?"
	icon = 'aquila/icons/obj/food/paradise/cannibalism.dmi'
	icon_state = "hiss_kebab"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 5,
	)
	tastes = list("mięso" = 1, "łuski" = 1)
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/kebab/picoss
	name = "picoss-kebab"
	desc = "Popularne danie uliczne z Moghes: marynowany w occie kosmiczny karp na szpikulcu z cebulą i papryczkami."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "picoss_skewer"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/consumable/vinegar = 1,
		/datum/reagent/consumable/capsaicin = 1,
	)
	tastes = list("ryba" = 4, "kwas" = 1, "cebula" = 1, "ostrość" = 1)
	foodtypes = FRUIT | MEAT
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/kebab/shrimp
	name = "szaszłyk z krewetek"
	desc = "Cztery krewetki lekko grillowane na szpikulcu. Pycha!"
	icon = 'aquila/icons/obj/food/paradise/seafood.dmi'
	icon_state = "shrimpskewer"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
	)
	tastes = list("krewetki" = 4)
	foodtypes = MEAT
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/kebab/synth
	name = "kebab z syntetycznego mięsa"
	desc = "Pyszne syntetyczne mięso na patyku."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "kebab"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
	)
	foodtypes = MEAT
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/macncheese
	name = "makaron z serem"
	desc = "Jedno z najbardziej pocieszających dań na świecie. Podobno."
	icon = 'aquila/icons/obj/food/paradise/pasta.dmi'
	icon_state = "macncheese"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/nutriment/soup/cheese = 4,
	)
	tastes = list("makaron" = 1, "ser" = 1, "pocieszenie" = 1)
	foodtypes = DAIRY | GRAIN
	trash_type = /obj/item/reagent_containers/glass/bowl
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/mashed_potatoes
	name = "puree ziemniaczane"
	desc = "Miękkie, kremowe, nie do odparcia puree ziemniaczane."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "mashedtaters"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 15,
		/datum/reagent/consumable/gravy = 5,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("puree ziemniaczane" = 3, "sos pieczeniowy" = 1)
	foodtypes = VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/meatsteak_cactus
	name = "stek z kaktusem"
	desc = "Kawałek gorącego, pikantnego mięsa z opuncją na wierzchu."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "meatstake_cactus"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	tastes = list("mięso" = 1, "kaktus" = 1)
	foodtypes = FRUIT
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/monkeysdelight
	name = "małpia rozkosz"
	desc = "Iiii iii!"
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "monkeysdelight"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/banana = 5,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	tastes = list("banan" = 1, "dżungla" = 1)
	foodtypes = FRUIT | GRAIN | MEAT | SUGAR
	bite_consumption = 6
	trash_type = /obj/item/trash/tray
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/mothmallow
	name = "ćmiankowa pianka"
	desc = "Puszyste chmurki radości w dziwnie ćmim kolorze."
	icon = 'aquila/icons/obj/food/paradise/bakedgoods.dmi'
	icon_state = "mothmallow_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/sugar = 4,
	)
	tastes = list("wanilia" = 1, "chmurki" = 1, "czekolada" = 1)
	foodtypes = SUGAR | VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/mothmallow_tray
	name = "blacha ćmiankowych pianek"
	desc = "Lekkie i puszyste wegańskie pianki o smaku wanilii i rumu, z miękką czekoladą na wierzchu. Ćmy nazywają je höllflöf."
	icon = 'aquila/icons/obj/food/paradise/bakedgoods.dmi'
	icon_state = "mothmallow_tray"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 20,
		/datum/reagent/consumable/sugar = 20,
	)
	tastes = list("wanilia" = 1, "chmurki" = 1, "czekolada" = 1)
	foodtypes = SUGAR | VEGETABLES
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/mothmallow_tray/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/mothmallow, 5, 3 SECONDS, table_required = TRUE, screentip_verb = "Pokrój")

/obj/item/food/mousse_avocado
	name = "mus czekoladowy z awokado"
	desc = "Mus z awokado i kakao."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "mousse_avocado"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/cocoa = 4,
		/datum/reagent/consumable/cream = 3,
	)
	tastes = list("dobra czekolada" = 1)
	foodtypes = DAIRY | FRUIT | JUNKFOOD | SUGAR
	bite_consumption = 1
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/mushrooms_curry
	name = "curry z grzybami"
	desc = "Lekko zmieniony tradycyjny przepis. Rzadkie, ale pyszne."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "mushrooms_curry"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	foodtypes = BREAKFAST | DAIRY | GRAIN | VEGETABLES
	bite_consumption = 5
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/peanut_butter_banana
	name = "kanapka z masłem orzechowym i bananem"
	desc = "Kanapka z masłem orzechowym i plasterkami banana. Dobry, białkowy przysmak."
	icon = 'aquila/icons/obj/food/paradise/burgerbread.dmi'
	icon_state = "peanut_butter_banana_sandwich"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	tastes = list("masło orzechowe" = 3, "banan" = 3, "chleb" = 2)
	foodtypes = FRUIT | GRAIN
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/peanut_butter_cookie
	name = "ciasteczko z masłem orzechowym"
	desc = "Smaczne, ciągnące się ciasteczko z masłem orzechowym."
	icon = 'aquila/icons/obj/food/paradise/bakedgoods.dmi'
	icon_state = "peanut_butter_cookie"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/peanut_butter = 5,
	)
	tastes = list("ciasteczko" = 1, "masło orzechowe" = 2)
	foodtypes = DAIRY | GRAIN | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/peanut_butter_jelly/cherry
	name = "kanapka z masłem orzechowym i dżemem"
	desc = "Klasyczna kanapka z masłem orzechowym i dżemem, jak od mamy."
	icon = 'aquila/icons/obj/food/paradise/burgerbread.dmi'
	icon_state = "peanut_butter_jelly_sandwich"
	food_reagents = list(
		/datum/reagent/consumable/peanut_butter = 2,
		/datum/reagent/consumable/cherryjelly = 5,
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	tastes = list("masło orzechowe" = 3, "galaretka" = 3, "chleb" = 2)
	foodtypes = GRAIN
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/peanut_butter_jelly/slime
	name = "kanapka z masłem orzechowym i szlamem"
	desc = "Klasyczna kanapka z masłem orzechowym i dżemem, jak od mamy?"
	icon = 'aquila/icons/obj/food/paradise/burgerbread.dmi'
	icon_state = "peanut_butter_jelly_sandwich"
	food_reagents = list(
		/datum/reagent/consumable/peanut_butter = 2,
		/datum/reagent/toxin/slimejelly = 5,
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	tastes = list("masło orzechowe" = 3, "galaretka" = 3, "chleb" = 2)
	foodtypes = GRAIN
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/philly_cheesesteak
	name = "philly cheesesteak"
	desc = "Popularna kanapka z plastrami mięsa, cebulą i roztopionym serem w długiej bułce. „Ślinka cieknie” to za mało powiedziane."
	icon = 'aquila/icons/obj/food/paradise/burgerbread.dmi'
	icon_state = "philly_cheesesteak"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/protein = 4,
	)
	tastes = list("stek" = 3, "roztopiony ser" = 3, "cebula" = 2, "chleb" = 2)
	foodtypes = DAIRY | GRAIN | MEAT
	bite_consumption = 4
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pie/french_silk
	name = "francuski placek jedwabny"
	desc = "Wystawny placek z kremowym musem czekoladowym, warstwą bitej śmietany i wiórkami czekolady. Do krojenia."
	icon = 'aquila/icons/obj/food/paradise/bakedgoods.dmi'
	icon_state = "french_silk_pie"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 15,
		/datum/reagent/consumable/nutriment/vitamin = 5,
	)
	tastes = list("placek" = 1, "gładka czekolada" = 1, "bita śmietana" = 1)
	foodtypes = GRAIN | JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3
	slice_type = /obj/item/food/pieslice/french_silk
	yield = 5

/obj/item/food/pieslice/french_silk
	name = "kawałek francuskiego placka jedwabnego"
	desc = "Kawałek placka z musem czekoladowym, warstwą bitej śmietany i wiórkami czekolady. Pyszny."
	icon = 'aquila/icons/obj/food/paradise/bakedgoods.dmi'
	icon_state = "french_silk_pie_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	tastes = list("placek" = 1, "gładka czekolada" = 1, "bita śmietana" = 1)
	foodtypes = GRAIN | JUNKFOOD | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pizza/cheese
	name = "pizza serowa"
	desc = "Ser, ciasto, ser, pomidor i ser."
	icon = 'aquila/icons/obj/food/paradise/pizza.dmi'
	icon_state = "cheesepizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 42,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 6,
	)
	tastes = list("skórka" = 1, "pomidor" = 1, "ser" = 1)
	foodtypes = DAIRY | FRUIT | GRAIN
	crafting_complexity = FOOD_COMPLEXITY_3
	slice_type = /obj/item/food/pizzaslice/cheese

/obj/item/food/pizza/firecracker
	name = "pizza petarda"
	desc = "Smakuje OSTRO OSTRO OSTRO!"
	icon = 'aquila/icons/obj/food/paradise/pizza.dmi'
	icon_state = "firecrackerpizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 30,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/consumable/capsaicin = 12,
	)
	tastes = list("skórka" = 1, "ser" = 1, "OSTROŚĆ" = 1)
	foodtypes = DAIRY | FRUIT | GRAIN
	crafting_complexity = FOOD_COMPLEXITY_3
	slice_type = /obj/item/food/pizzaslice/firecracker

/obj/item/food/pizza/garlic
	name = "pizza czosnkowa"
	desc = "Ach, czosnek. Wszyscy go kochają, może poza wampirami."
	icon = 'aquila/icons/obj/food/paradise/pizza.dmi'
	icon_state = "garlicpizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 30,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/consumable/garlic = 12,
	)
	tastes = list("skórka" = 1, "ser" = 1, "czosnek" = 1)
	foodtypes = DAIRY | GRAIN
	crafting_complexity = FOOD_COMPLEXITY_3
	slice_type = /obj/item/food/pizzaslice/garlic

/obj/item/food/pizza/macncheese
	name = "pizza z makaronem z serem"
	desc = "Gastronomowie nadal nie uznali tego za pizzę."
	icon = 'aquila/icons/obj/food/paradise/pizza.dmi'
	icon_state = "macpizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 42,
		/datum/reagent/consumable/nutriment/vitamin = 6,
	)
	tastes = list("skórka" = 1, "ser" = 2, "makaron" = 1)
	foodtypes = DAIRY | GRAIN
	crafting_complexity = FOOD_COMPLEXITY_3
	slice_type = /obj/item/food/pizzaslice/macncheese

/obj/item/food/pizza/pepperoni
	name = "pizza pepperoni"
	desc = "Co pepperoni powiedziało pizzy?"
	icon = 'aquila/icons/obj/food/paradise/pizza.dmi'
	icon_state = "pepperonipizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 30,
		/datum/reagent/consumable/tomatojuice = 6,
		/datum/reagent/consumable/nutriment/vitamin = 9,
	)
	tastes = list("ser" = 3, "pepperoni" = 3, "tłuszcz" = 1)
	foodtypes = BREAKFAST | DAIRY | FRUIT | GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_3
	slice_type = /obj/item/food/pizzaslice/pepperoni

/obj/item/food/pizza/pesto
	name = "pizza „pesto”"
	desc = "Chwila... to nie smakuje jak pesto!"
	icon = 'aquila/icons/obj/food/paradise/pizza.dmi'
	icon_state = "pestopizza"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 30,
		/datum/reagent/consumable/tomatojuice = 12,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/consumable/wasabi = 12,
	)
	tastes = list("pomidor" = 1, "ser" = 1, "wasabi" = 1)
	foodtypes = DAIRY | FRUIT | GRAIN
	crafting_complexity = FOOD_COMPLEXITY_3
	slice_type = /obj/item/food/pizzaslice/pesto

/obj/item/food/pizzaslice/cheese
	name = "kawałek pizzy serowej"
	desc = "Niebezpiecznie serowy?"
	icon = 'aquila/icons/obj/food/paradise/pizza.dmi'
	icon_state = "cheesepizzaslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 7,
		/datum/reagent/consumable/tomatojuice = 1,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	tastes = list("skórka" = 1, "pomidor" = 1, "ser" = 3)
	foodtypes = DAIRY | FRUIT | GRAIN
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/pizzaslice/firecracker
	name = "kawałek pizzy petardy"
	desc = "Ostry kawałek czegoś całkiem fajnego."
	icon = 'aquila/icons/obj/food/paradise/pizza.dmi'
	icon_state = "firecrackerpizzaslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/capsaicin = 2,
	)
	tastes = list("skórka" = 1, "ser" = 1, "OSTROŚĆ" = 1)
	foodtypes = DAIRY | FRUIT | GRAIN
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/pizzaslice/garlic
	name = "kawałek pizzy czosnkowej"
	desc = "Czego tu nie kochać?"
	icon = 'aquila/icons/obj/food/paradise/pizza.dmi'
	icon_state = "garlicpizzaslice"
	tastes = list("skórka" = 1, "ser" = 1, "czosnek" = 1)
	foodtypes = DAIRY | GRAIN
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/pizzaslice/macncheese
	name = "kawałek pizzy z makaronem z serem"
	desc = "Pyszny kawałek pizzy z makaronem z serem... chwila, co? Kto by coś takiego zrobił?!"
	icon = 'aquila/icons/obj/food/paradise/pizza.dmi'
	icon_state = "macpizzaslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 7,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	tastes = list("skórka" = 1, "pomidor" = 1, "ser" = 2, "makaron" = 1)
	foodtypes = DAIRY | GRAIN
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/pizzaslice/pepperoni
	name = "kawałek pizzy pepperoni"
	desc = "Miło cię pomięsić!"
	icon = 'aquila/icons/obj/food/paradise/pizza.dmi'
	icon_state = "pepperonipizzaslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/tomatojuice = 1,
		/datum/reagent/consumable/nutriment/vitamin = 1.5,
	)
	tastes = list("ser" = 3, "pepperoni" = 3, "tłuszcz" = 1)
	foodtypes = BREAKFAST | DAIRY | FRUIT | GRAIN | MEAT
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/pizzaslice/pesto
	name = "kawałek pizzy „pesto”"
	desc = "Pyszny i podejrzanie zielony."
	icon = 'aquila/icons/obj/food/paradise/pizza.dmi'
	icon_state = "pestopizzaslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/tomatojuice = 2,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/wasabi = 2,
	)
	tastes = list("pomidor" = 1, "ser" = 1, "wasabi" = 1)
	foodtypes = DAIRY | FRUIT | GRAIN
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/plasmabone_broth
	name = "bulion z plazmy i kości"
	desc = "Miska płynnej plazmy."
	icon = 'aquila/icons/obj/food/paradise/cannibalism.dmi'
	icon_state = "plasmabone_broth"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/toxin/plasma = 3,
	)
	tastes = list("gorycz" = 1, "marnowane mienie korporacji" = 1)
	trash_type = /obj/item/reagent_containers/glass/bowl
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/popsicle/bananatop
	name = "bananowy lód z tofu"
	desc = "Mrożony smakołyk z tofu i soku bananowego, zmiksowanych na gładko i zamrożonych. Popularny latem na japońskiej wsi."
	icon = 'aquila/icons/obj/food/paradise/frozen_treats.dmi'
	icon_state = "topsicle_banana"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/consumable/sugar = 6,
		/datum/reagent/consumable/banana = 4,
	)
	tastes = list("banany" = 1, "tofu" = 1)
	foodtypes = SUGAR | VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/popsicle/berrycream
	name = "jagodowy lód śmietankowy"
	desc = "Wyrazisty jagodowy lód śmietankowy. Jagodzinnie dobry mrożony przysmak."
	icon = 'aquila/icons/obj/food/paradise/frozen_treats.dmi'
	icon_state = "creamsicle_m"
	food_reagents = list(
		/datum/reagent/consumable/berryjuice = 4,
		/datum/reagent/consumable/cream = 2,
		/datum/reagent/consumable/vanilla = 2,
		/datum/reagent/consumable/sugar = 4,
	)
	tastes = list("lody" = 1, "jagody" = 1, "wanilia" = 1)
	foodtypes = DAIRY | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/popsicle/berrytop
	name = "jagodowy lód z tofu"
	desc = "Mrożony smakołyk z tofu i soku jagodowego, zmiksowanych na gładko i zamrożonych. Podobno ulubiony przez niedźwiedzie, co nie ma sensu..."
	icon = 'aquila/icons/obj/food/paradise/frozen_treats.dmi'
	icon_state = "topsicle_berry"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/consumable/sugar = 6,
		/datum/reagent/consumable/berryjuice = 4,
	)
	tastes = list("jagody" = 1, "tofu" = 1)
	foodtypes = SUGAR | VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/popsicle/frozenpineapple
	name = "mrożony ananas na patyku"
	desc = "Mało która kultura kocha ananasy tak jak Marsjanie: mrożony ananas na patyku, lekko zanurzony w czekoladzie."
	icon = 'aquila/icons/obj/food/paradise/frozen_treats.dmi'
	icon_state = "pineapple_pop"
	food_reagents = list(
		/datum/reagent/consumable/pineapplejuice = 4,
		/datum/reagent/consumable/sugar = 4,
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("zimny ananas" = 1, "czekolada" = 1)
	foodtypes = FRUIT | JUNKFOOD | PINEAPPLE | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/popsicle/jumbo
	name = "wielki lód"
	desc = "Luksusowy lód w gęstej czekoladzie. Wydaje się mniejszy, niż pamiętasz."
	icon = 'aquila/icons/obj/food/paradise/frozen_treats.dmi'
	icon_state = "jumbo"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/sugar = 4,
		/datum/reagent/consumable/cocoa = 3,
	)
	tastes = list("lody" = 1, "czekolada" = 1, "wanilia" = 1)
	foodtypes = DAIRY | JUNKFOOD | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/popsicle/licoricecream
	name = "lukrecjowy lód śmietankowy"
	desc = "Słony lód lukrecjowy. Słony mrożony przysmak."
	icon = 'aquila/icons/obj/food/paradise/frozen_treats.dmi'
	icon_state = "licorice_creamsicle"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/cream = 2,
		/datum/reagent/consumable/vanilla = 1,
		/datum/reagent/consumable/sugar = 4,
		/datum/reagent/consumable/sodiumchloride = 1,
	)
	tastes = list("słona lukrecja" = 1)
	foodtypes = DAIRY | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/popsicle/orangecream
	name = "pomarańczowy lód śmietankowy"
	desc = "Klasyczny pomarańczowy lód śmietankowy. Słoneczny mrożony przysmak."
	icon = 'aquila/icons/obj/food/paradise/frozen_treats.dmi'
	icon_state = "creamsicle_o"
	food_reagents = list(
		/datum/reagent/consumable/orangejuice = 4,
		/datum/reagent/consumable/cream = 2,
		/datum/reagent/consumable/vanilla = 2,
		/datum/reagent/consumable/sugar = 4,
	)
	tastes = list("lody" = 1, "pomarańcze" = 1, "wanilia" = 1)
	foodtypes = DAIRY | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/popsicle/pineappletop
	name = "ananasowy lód z tofu"
	desc = "Mrożony smakołyk z tofu i soku ananasowego, zmiksowanych na gładko i zamrożonych. Znany z telewizji."
	icon = 'aquila/icons/obj/food/paradise/frozen_treats.dmi'
	icon_state = "topsicle_pineapple"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/consumable/sugar = 6,
		/datum/reagent/consumable/pineapplejuice = 4,
	)
	tastes = list("ananasy" = 1, "tofu" = 1)
	foodtypes = SUGAR | VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/popsicle/sea_salt
	name = "lód z solą morską"
	desc = "Błękitny lód na patyku o smaku najlepszej importowanej soli morskiej. Słony... nie, słodki!"
	icon = 'aquila/icons/obj/food/paradise/frozen_treats.dmi'
	icon_state = "sea_salt_pop"
	food_reagents = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/cream = 2,
		/datum/reagent/consumable/vanilla = 2,
		/datum/reagent/consumable/sugar = 4,
	)
	tastes = list("sól" = 1, "słodycz" = 1)
	foodtypes = DAIRY | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/pork_rind
	name = "skwarka"
	desc = "Kawałek wieprzowej skórki."
	icon = 'aquila/icons/obj/food/paradise/cannibalism.dmi'
	icon_state = "pork_rind_1"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/nutriment/protein = 1,
	)
	tastes = list("ludzkie mięso" = 1, "słoność" = 1)
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/roast_turkey
	name = "indyk"
	desc = "Tradycyjny indyk z farszem."
	icon = 'aquila/icons/obj/food/paradise/meat.dmi'
	icon_state = "turkey"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 24,
		/datum/reagent/consumable/nutriment = 18,
		/datum/reagent/consumable/nutriment/vitamin = 6,
	)
	tastes = list("indyk" = 2, "farsz" = 2)
	foodtypes = GRAIN
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/roast_turkey/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/roast_turkey_slice, 6, 3 SECONDS, table_required = TRUE, screentip_verb = "Pokrój")

/obj/item/food/roast_turkey_slice
	name = "porcja indyka"
	desc = "Porcja delikatnego, pysznego indyka."
	icon = 'aquila/icons/obj/food/paradise/meat.dmi'
	icon_state = "turkeyslice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	tastes = list("indyk" = 1)
	foodtypes = GRAIN
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/salad/antipasto
	name = "sałatka antipasto"
	desc = "Tradycyjna włoska sałatka z salami, mozzarelli, oliwek i pomidorów. Zwykle podawana jako przystawka."
	icon = 'aquila/icons/obj/food/paradise/soupsalad.dmi'
	icon_state = "antipasto_salad"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 6,
	)
	tastes = list("sałata" = 2, "salami" = 2, "mozzarella" = 2, "pomidory" = 2, "sos sałatkowy" = 1)
	foodtypes = DAIRY | FRUIT | MEAT | VEGETABLES
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/salad/ash_salad
	name = "sałatka z popiołów"
	desc = "Sałatka z jadalnej fauny i flory z popielnego pustkowia."
	icon = 'aquila/icons/obj/food/paradise/soupsalad.dmi'
	icon_state = "ash_salad"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/vitfro = 1,
		/datum/reagent/drug/nicotine = 2,
	)
	tastes = list("mięso" = 1, "owoc kaktusa" = 2, "grzybowa kapusta" = 1, "popiół" = 1)
	foodtypes = MEAT
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/salad/caesar
	name = "sałatka cezar"
	desc = "Prosta, ale aromatyczna sałatka z cebuli, sałaty, grzanek i sera polana oliwą. Z kawałkiem pity!"
	icon = 'aquila/icons/obj/food/paradise/soupsalad.dmi'
	icon_state = "caesar_salad"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/consumable/nutriment/vitamin = 6,
	)
	tastes = list("zdrowa zielenina" = 2, "sos oliwkowy" = 2, "feta" = 2, "pita" = 1)
	foodtypes = DAIRY | GRAIN | VEGETABLES
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/salad/greek
	name = "sałatka grecka"
	desc = "Popularna sałatka z pomidorów, cebuli, fety i oliwek polana oliwą. Jakby czegoś brakowało..."
	icon = 'aquila/icons/obj/food/paradise/soupsalad.dmi'
	icon_state = "greek_salad"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 13,
		/datum/reagent/consumable/nutriment/vitamin = 14,
	)
	tastes = list("zdrowa zielenina" = 2, "sos oliwkowy" = 1, "feta" = 1)
	foodtypes = DAIRY | FRUIT
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/salad/kale
	name = "sałatka z jarmużu"
	desc = "Zdrowa sałatka z jarmużu polana oliwą, idealna na ciepłe lato."
	icon = 'aquila/icons/obj/food/paradise/soupsalad.dmi'
	icon_state = "kale_salad"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/consumable/nutriment/vitamin = 12,
	)
	tastes = list("zdrowa zielenina" = 2, "sos oliwkowy" = 1)
	foodtypes = VEGETABLES
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/salad/potato
	name = "sałatka ziemniaczana"
	desc = "Gotowane ziemniaki z jajkami, cebulą i majonezem. Obowiązkowa na każdym grillu."
	icon = 'aquila/icons/obj/food/paradise/soupsalad.dmi'
	icon_state = "potato_salad"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/protein = 4,
	)
	tastes = list("ziemniak" = 2, "jajko" = 2, "majonez" = 2)
	foodtypes = BREAKFAST | MEAT | VEGETABLES
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/salmoncreamtoast
	name = "tost z łososiem i serkiem"
	desc = "Malutki tost z łososiem i gęstym serkiem śmietankowym."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "scc_toast"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/consumable/cream_cheese = 5,
	)
	tastes = list("chleb" = 1, "awokado" = 2)
	foodtypes = DAIRY | GRAIN | MEAT
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/salmoncurry
	name = "curry z łososiem"
	desc = "Mieszanka przypraw i ziół daje smaczne danie."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "carpcurry"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/blackpepper = 1,
		/datum/reagent/consumable/capsaicin = 1,
	)
	tastes = list("ostrość" = 1, "łosoś" = 1, "mleko" = 1)
	foodtypes = BREAKFAST | DAIRY | GRAIN | MEAT
	bite_consumption = 4
	trash_type = /obj/item/reagent_containers/glass/bowl
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/salmonsteak
	name = "stek z łososia"
	desc = "Świeżo grillowany filet z łososia."
	icon = 'aquila/icons/obj/food/paradise/seafood.dmi'
	icon_state = "salmonsteak"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("gotowany łosoś" = 1)
	foodtypes = MEAT
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/smokedsalmon
	name = "stek z wędzonego łososia"
	desc = "Świeżo grillowany i wędzony filet z łososia."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "smokedsalmon"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/sodiumchloride = 1,
	)
	tastes = list("wędzony łosoś" = 1)
	foodtypes = MEAT
	bite_consumption = 4
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/stuffing
	name = "farsz"
	desc = "Wilgotna, pieprzna bułka tarta do faszerowania martwych ptaków. Smacznego!"
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "stuffing"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
	)
	tastes = list("bułka tarta" = 1, "zioła" = 1)
	foodtypes = GRAIN
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/supermatter_sandwich
	name = "kanapka z supermaterią"
	desc = "Odłamek supermaterii, jakimś cudem bezpiecznie zamknięty między dwiema kromkami chleba. Mówiono ci wiele razy, żeby nie lizać zakazanego nachosa..."
	icon = 'aquila/icons/obj/food/paradise/burgerbread.dmi'
	icon_state = "supermatter_sandwich"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/vitamin = 50,
	)
	tastes = list("nieopisana moc" = 3, "chleb" = 2)
	foodtypes = GRAIN
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sushi_piece/ebi
	name = "sushi ebi"
	desc = "Proste sushi z gotowanej krewetki i ryżu."
	icon = 'aquila/icons/obj/food/paradise/seafood.dmi'
	icon_state = "sushi_Ebi"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
	)
	tastes = list("krewetki" = 1, "ryż" = 1, "wodorosty" = 1)
	foodtypes = BREAKFAST | GRAIN | MEAT | VEGETABLES
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/sushi_piece/inari
	name = "sushi inari"
	desc = "Kawałek smażonego tofu nadziany ryżem."
	icon = 'aquila/icons/obj/food/paradise/seafood.dmi'
	icon_state = "sushi_Inari"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
	)
	tastes = list("smażone tofu" = 1, "ryż" = 1, "wodorosty" = 1)
	foodtypes = BREAKFAST | GRAIN | VEGETABLES
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/sushi_piece/sake
	name = "sushi sake"
	desc = "Proste sushi z surowego łososia i ryżu."
	icon = 'aquila/icons/obj/food/paradise/seafood.dmi'
	icon_state = "sushi_Sake"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
	)
	tastes = list("surowy łosoś" = 1, "ryż" = 1, "wodorosty" = 1)
	foodtypes = BREAKFAST | GRAIN | MEAT | VEGETABLES
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/sushi_piece/smoked_salmon
	name = "sushi z wędzonym łososiem"
	desc = "Proste sushi z gotowanego łososia i ryżu."
	icon = 'aquila/icons/obj/food/paradise/seafood.dmi'
	icon_state = "sushi_SmokedSalmon"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
	)
	tastes = list("wędzony łosoś" = 1, "ryż" = 1, "wodorosty" = 1)
	foodtypes = BREAKFAST | GRAIN | MEAT | VEGETABLES
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/sushi_piece/tamago
	name = "sushi tamago"
	desc = "Proste sushi z jajka i ryżu."
	icon = 'aquila/icons/obj/food/paradise/seafood.dmi'
	icon_state = "sushi_Tamago"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
	)
	tastes = list("jajko" = 1, "ryż" = 1, "wodorosty" = 1)
	foodtypes = BREAKFAST | GRAIN | MEAT | VEGETABLES
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/sushi_piece/unagi
	name = "sushi unagi"
	desc = "Proste sushi z węgorza i ryżu."
	icon = 'aquila/icons/obj/food/paradise/seafood.dmi'
	icon_state = "sushi_Hokki"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
	)
	tastes = list("grillowany węgorz" = 1, "wodorosty" = 1)
	foodtypes = BREAKFAST | GRAIN | MEAT | VEGETABLES
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sushi_roll/ebi
	name = "rolka maki ebi"
	desc = "Duża, niepokrojona rolka sushi ebi."
	icon = 'aquila/icons/obj/food/paradise/seafood.dmi'
	icon_state = "Ebi_maki"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
	)
	tastes = list("krewetki" = 1, "ryż" = 1, "wodorosty" = 1)
	foodtypes = BREAKFAST | GRAIN | MEAT | VEGETABLES
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sushi_roll/ebi/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/sushi_piece/ebi, 4, 3 SECONDS, table_required = TRUE, screentip_verb = "Pokrój")

/obj/item/food/sushi_roll/inari
	name = "rolka maki inari"
	desc = "Duża, niepokrojona rolka sushi inari."
	icon = 'aquila/icons/obj/food/paradise/seafood.dmi'
	icon_state = "Inari_maki"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
	)
	tastes = list("smażone tofu" = 1, "ryż" = 1, "wodorosty" = 1)
	foodtypes = BREAKFAST | GRAIN | VEGETABLES
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sushi_roll/inari/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/sushi_piece/inari, 4, 3 SECONDS, table_required = TRUE, screentip_verb = "Pokrój")

/obj/item/food/sushi_roll/sake
	name = "rolka maki sake"
	desc = "Duża, niepokrojona rolka sushi sake."
	icon = 'aquila/icons/obj/food/paradise/seafood.dmi'
	icon_state = "Sake_maki"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
	)
	tastes = list("surowy łosoś" = 1, "ryż" = 1, "wodorosty" = 1)
	foodtypes = BREAKFAST | GRAIN | MEAT | VEGETABLES
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sushi_roll/sake/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/sushi_piece/sake, 4, 3 SECONDS, table_required = TRUE, screentip_verb = "Pokrój")

/obj/item/food/sushi_roll/smoked_salmon
	name = "rolka maki z wędzonym łososiem"
	desc = "Duża, niepokrojona rolka sushi z wędzonym łososiem."
	icon = 'aquila/icons/obj/food/paradise/seafood.dmi'
	icon_state = "SmokedSalmon_maki"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
	)
	tastes = list("wędzony łosoś" = 1, "ryż" = 1, "wodorosty" = 1)
	foodtypes = BREAKFAST | GRAIN | MEAT | VEGETABLES
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sushi_roll/smoked_salmon/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/sushi_piece/smoked_salmon, 4, 3 SECONDS, table_required = TRUE, screentip_verb = "Pokrój")

/obj/item/food/sweet/candied_pineapple
	name = "kandyzowany ananas"
	desc = "Kawałek ananasa w cukrze, wysuszony na ciągnący się smakołyk."
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "candied_pineapple"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 3,
	)
	tastes = list("cukier" = 2, "ciągnący się ananas" = 4)
	foodtypes = FRUIT | JUNKFOOD | PINEAPPLE | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/candycane
	name = "laska cukrowa"
	desc = "Świąteczna miętowa laska cukrowa."
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "candycane"
	food_reagents = list(
		/datum/reagent/toxin/minttoxin = 1,
		/datum/reagent/consumable/sugar = 5,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR | TOXIC
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/caramel
	name = "karmelek"
	desc = "Ciągnący się i gęsty, a mimo to rozpływa się w ustach!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "caramel"
	food_reagents = list(
		/datum/reagent/consumable/cream = 2,
		/datum/reagent/consumable/sugar = 2,
	)
	tastes = list("cukierek" = 1)
	foodtypes = DAIRY | JUNKFOOD | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/cash
	name = "cukierkowe pieniądze"
	desc = "Nie są prawnym środkiem płatniczym, ale smaczne."
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "candy_cash"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/cocoa = 4,
	)
	tastes = list("czekolada" = 1)
	foodtypes = JUNKFOOD | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/confectionery/caramel
	name = "baton Małpiszon"
	desc = "Czekoladowa strzykawka z zastrzykiem karmelu. Dokładnie to, co zalecił lekarz!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "malper"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/cocoa = 1,
	)
	tastes = list("cukierek" = 1)
	foodtypes = DAIRY | JUNKFOOD | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/confectionery/caramel_nougat
	name = "baton Test Toksyn"
	desc = "Wybuchowe połączenie czekolady, karmelu i nugatu. Badania jeszcze nigdy nie były tak smaczne!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "toxinstest"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/cocoa = 1,
	)
	tastes = list("cukierek" = 1)
	foodtypes = DAIRY | JUNKFOOD | MEAT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/confectionery/nougat
	name = "baton Klucz-eron"
	desc = "Nugat w czekoladzie w kształcie klucza. Idealny dla inżyniera w biegu!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "toolerone"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/cocoa = 1,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | MEAT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/confectionery/rice
	name = "baton Asteroidowy Chrup"
	desc = "Chrupiące złoża ryżu w pysznej czekoladzie! Ulubieniec górników całej galaktyki."
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "asteroidcrunch"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/cocoa = 1,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	trash_type = /obj/item/trash/candy
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/confectionery/toffee
	name = "baton Pałka"
	desc = "Czekolada z toffi w kształcie pałki. Ochrona naprawdę umie je pałować!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "yumbaton"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/cocoa = 1,
	)
	tastes = list("cukierek" = 1)
	foodtypes = GRAIN | JUNKFOOD | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/cotton
	name = "wata cukrowa"
	desc = "Lekka i puszysta, jak jedzenie chmury z cukru!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "cottoncandy_plain"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 15,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 4
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/cotton/bad_rainbow
	name = "tęczowa wata cukrowa"
	desc = "Lekka i puszysta, jak jedzenie chmury z cukru!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "cottoncandy_rainbow"
	food_reagents = list(
		/datum/reagent/toxin/sulfonal = 20,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 4
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/cotton/blue
	name = "niebieska wata cukrowa"
	desc = "Lekka i puszysta, jak jedzenie chmury z cukru!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "cottoncandy_blue"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 15,
		/datum/reagent/consumable/berryjuice = 5,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 4
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/cotton/green
	name = "zielona wata cukrowa"
	desc = "Lekka i puszysta, jak jedzenie chmury z cukru!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "cottoncandy_green"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 15,
		/datum/reagent/consumable/limejuice = 5,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 4
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/cotton/orange
	name = "pomarańczowa wata cukrowa"
	desc = "Lekka i puszysta, jak jedzenie chmury z cukru!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "cottoncandy_orange"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 15,
		/datum/reagent/consumable/orangejuice = 5,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 4
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/cotton/pink
	name = "różowa wata cukrowa"
	desc = "Lekka i puszysta, jak jedzenie chmury z cukru!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "cottoncandy_pink"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 15,
		/datum/reagent/consumable/watermelonjuice = 5,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 4
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/cotton/poison
	name = "niebieska wata cukrowa"
	desc = "Lekka i puszysta, jak jedzenie chmury z cukru!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "cottoncandy_blue"
	food_reagents = list(
		/datum/reagent/consumable/poisonberryjuice = 20,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 4
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/cotton/purple
	name = "fioletowa wata cukrowa"
	desc = "Lekka i puszysta, jak jedzenie chmury z cukru!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "cottoncandy_purple"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 15,
		/datum/reagent/consumable/grapejuice = 5,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 4
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/cotton/rainbow
	name = "tęczowa wata cukrowa"
	desc = "Lekka i puszysta, jak jedzenie chmury z cukru!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "cottoncandy_rainbow"
	food_reagents = list(
		/datum/reagent/medicine/omnizine = 20,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 4
	crafting_complexity = FOOD_COMPLEXITY_4

/obj/item/food/sweet/cotton/red
	name = "czerwona wata cukrowa"
	desc = "Lekka i puszysta, jak jedzenie chmury z cukru!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "cottoncandy_red"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 15,
		/datum/reagent/consumable/cherryjelly = 5,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 4
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/cotton/yellow
	name = "żółta wata cukrowa"
	desc = "Lekka i puszysta, jak jedzenie chmury z cukru!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "cottoncandy_yellow"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 15,
		/datum/reagent/consumable/lemonjuice = 5,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 4
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/fudge
	name = "krówka czekoladowa"
	desc = "Czekoladowa krówka, ponadczasowy przysmak."
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "fudge"
	food_reagents = list(
		/datum/reagent/consumable/cream = 3,
		/datum/reagent/consumable/cocoa = 6,
	)
	tastes = list("cukierek" = 1)
	foodtypes = DAIRY | JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/fudge/cherry
	name = "krówka czekoladowa z wiśniami"
	desc = "Czekoladowa krówka ze słodkimi wiśniami. Dobry sposób, żeby dzieci zjadły trochę owoców."
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "fudge_cherry"
	food_reagents = list(
		/datum/reagent/consumable/cream = 3,
		/datum/reagent/consumable/cocoa = 6,
	)
	tastes = list("cukierek" = 1)
	foodtypes = DAIRY | FRUIT | JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/fudge/cookies_n_cream
	name = "krówka ciasteczkowo-śmietankowa"
	desc = "Bardzo kremowa krówka z kawałkami prawdziwych ciasteczek czekoladowych. Chrupiąca!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "fudge_cookies_n_cream"
	food_reagents = list(
		/datum/reagent/consumable/cream = 6,
		/datum/reagent/consumable/cocoa = 6,
	)
	tastes = list("cukierek" = 1)
	foodtypes = DAIRY | GRAIN | JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/fudge/peanut
	name = "krówka czekoladowa z orzeszkami"
	desc = "Czekoladowa krówka z kawałkami orzeszków ziemnych. Alergicy, uważajcie."
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "fudge_peanut"
	food_reagents = list(
		/datum/reagent/consumable/cream = 3,
		/datum/reagent/consumable/cocoa = 6,
	)
	tastes = list("cukierek" = 1)
	foodtypes = DAIRY | JUNKFOOD | SUGAR | VEGETABLES
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/fudge/turtle
	name = "krówka żółwik"
	desc = "Czekoladowa krówka z karmelem i orzechami. Na szczęście bez prawdziwych żółwi."
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "fudge_turtle"
	food_reagents = list(
		/datum/reagent/consumable/cream = 3,
		/datum/reagent/consumable/cocoa = 6,
	)
	tastes = list("cukierek" = 1)
	foodtypes = DAIRY | JUNKFOOD | SUGAR | VEGETABLES
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/gum
	name = "guma balonowa"
	desc = "Ciągnąca się!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "bubblegum"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 5,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 0.2
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/gummybear
	name = "żelkowy miś"
	desc = "Mały jadalny miś. Miękki i ciągnący się!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "gbear"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 10,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/gummybear/blue
	name = "niebieski żelkowy miś"
	desc = "Mały jadalny miś. Niebieski!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "gbear_blue"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 10,
		/datum/reagent/consumable/berryjuice = 2,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/gummybear/green
	name = "zielony żelkowy miś"
	desc = "Mały jadalny miś. Zielony!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "gbear_green"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 10,
		/datum/reagent/consumable/limejuice = 2,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/gummybear/orange
	name = "pomarańczowy żelkowy miś"
	desc = "Mały jadalny miś. Pomarańczowy!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "gbear_orange"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 10,
		/datum/reagent/consumable/orangejuice = 2,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/gummybear/poison
	name = "niebieski żelkowy miś"
	desc = "Mały jadalny miś. Niebieski!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "gbear_blue"
	food_reagents = list(
		/datum/reagent/consumable/poisonberryjuice = 12,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/gummybear/purple
	name = "fioletowy żelkowy miś"
	desc = "Mały jadalny miś. Fioletowy!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "gbear_purple"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 10,
		/datum/reagent/consumable/grapejuice = 2,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/gummybear/red
	name = "czerwony żelkowy miś"
	desc = "Mały jadalny miś. Czerwony!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "gbear_red"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 10,
		/datum/reagent/consumable/cherryjelly = 2,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/gummybear/wtf
	name = "tęczowy żelkowy miś"
	desc = "Mały miś. Chwila... co?"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "gbear_rainbow"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 10,
		/datum/reagent/drug/space_drugs = 2,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR | VEGETABLES
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/gummybear/yellow
	name = "żółty żelkowy miś"
	desc = "Mały jadalny miś. Żółty!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "gbear_yellow"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 10,
		/datum/reagent/consumable/lemonjuice = 2,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/gummyworm
	name = "żelkowy robak"
	desc = "Jadalny robak z żelatyny."
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "gworm"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 10,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/gummyworm/blue
	name = "niebieski żelkowy robak"
	desc = "Jadalny robak z żelatyny. Niebieski!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "gworm_blue"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 10,
		/datum/reagent/consumable/berryjuice = 2,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/gummyworm/green
	name = "zielony żelkowy robak"
	desc = "Jadalny robak z żelatyny. Zielony!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "gworm_green"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 10,
		/datum/reagent/consumable/limejuice = 2,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/gummyworm/orange
	name = "pomarańczowy żelkowy robak"
	desc = "Jadalny robak z żelatyny. Pomarańczowy!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "gworm_orange"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 10,
		/datum/reagent/consumable/orangejuice = 2,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/gummyworm/poison
	name = "niebieski żelkowy robak"
	desc = "Jadalny robak z żelatyny. Niebieski!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "gworm_blue"
	food_reagents = list(
		/datum/reagent/consumable/poisonberryjuice = 12,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/gummyworm/purple
	name = "fioletowy żelkowy robak"
	desc = "Jadalny robak z żelatyny. Fioletowy!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "gworm_purple"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 10,
		/datum/reagent/consumable/grapejuice = 2,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/gummyworm/red
	name = "czerwony żelkowy robak"
	desc = "Jadalny robak z żelatyny. Czerwony!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "gworm_red"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 10,
		/datum/reagent/consumable/cherryjelly = 2,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/gummyworm/wtf
	name = "tęczowy żelkowy robak"
	desc = "Jadalny robak. Czy on się właśnie ruszył?"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "gworm_rainbow"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 10,
		/datum/reagent/drug/space_drugs = 2,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR | VEGETABLES
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/gummyworm/yellow
	name = "żółty żelkowy robak"
	desc = "Jadalny robak z żelatyny. Żółty!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "gworm_yellow"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 10,
		/datum/reagent/consumable/lemonjuice = 2,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/jawbreaker
	name = "łamacz szczęk"
	desc = "Niewiarygodnie twardy cukierek. Nazwa pasuje."
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "jawbreaker"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 10,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 0.1
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/jellybean
	name = "żelkowa fasolka"
	desc = "Cukierkowa fasolka. Gwarantujemy, że nie wzdyma."
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "jbean"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 10,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/jellybean/blue
	name = "niebieska żelkowa fasolka"
	desc = "Cukierkowa fasolka. Gwarantujemy, że nie wzdyma. Niebieska!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "jbean_blue"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 10,
		/datum/reagent/consumable/berryjuice = 2,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/jellybean/chocolate
	name = "czekoladowa żelkowa fasolka"
	desc = "Cukierkowa fasolka. Gwarantujemy, że nie wzdyma. Czekoladowa!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "jbean_choc"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 10,
		/datum/reagent/consumable/cocoa = 2,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/jellybean/coffee
	name = "kawowa żelkowa fasolka"
	desc = "Cukierkowa fasolka. Gwarantujemy, że nie wzdyma. O smaku kawy!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "jbean_choc"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 10,
		/datum/reagent/consumable/coffee = 2,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/jellybean/cola
	name = "żelkowa fasolka o smaku coli"
	desc = "Cukierkowa fasolka. Gwarantujemy, że nie wzdyma. O smaku coli!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "jbean_cola"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 10,
		/datum/reagent/consumable/space_cola = 2,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/jellybean/drgibb
	name = "żelkowa fasolka Dr. Gibb"
	desc = "Cukierkowa fasolka. Gwarantujemy, że nie wzdyma. O smaku Dr. Gibba!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "jbean_cola"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 10,
		/datum/reagent/consumable/dr_gibb = 2,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/jellybean/green
	name = "zielona żelkowa fasolka"
	desc = "Cukierkowa fasolka. Gwarantujemy, że nie wzdyma. Zielona!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "jbean_green"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 10,
		/datum/reagent/consumable/limejuice = 2,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/jellybean/orange
	name = "pomarańczowa żelkowa fasolka"
	desc = "Cukierkowa fasolka. Gwarantujemy, że nie wzdyma. Pomarańczowa!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "jbean_orange"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 10,
		/datum/reagent/consumable/orangejuice = 2,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/jellybean/poison
	name = "niebieska żelkowa fasolka"
	desc = "Cukierkowa fasolka. Gwarantujemy, że nie wzdyma. Niebieska!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "jbean_blue"
	food_reagents = list(
		/datum/reagent/consumable/poisonberryjuice = 12,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/jellybean/popcorn
	name = "żelkowa fasolka o smaku popcornu"
	desc = "Cukierkowa fasolka. Gwarantujemy, że nie wzdyma. O smaku popcornu!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "jbean_popcorn"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 10,
		/datum/reagent/consumable/nutriment = 2,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/jellybean/purple
	name = "fioletowa żelkowa fasolka"
	desc = "Cukierkowa fasolka. Gwarantujemy, że nie wzdyma. Fioletowa!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "jbean_purple"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 10,
		/datum/reagent/consumable/grapejuice = 2,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/jellybean/red
	name = "czerwona żelkowa fasolka"
	desc = "Cukierkowa fasolka. Gwarantujemy, że nie wzdyma. Czerwona!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "jbean_red"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 10,
		/datum/reagent/consumable/cherryjelly = 2,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/jellybean/wtf
	name = "tęczowa żelkowa fasolka"
	desc = "Cukierkowa fasolka. Gwarantujemy, że nie wzdyma. Nie wiesz, jakiego jest koloru."
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "jbean_rainbow"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 10,
		/datum/reagent/drug/space_drugs = 2,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR | VEGETABLES
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/jellybean/yellow
	name = "żółta żelkowa fasolka"
	desc = "Cukierkowa fasolka. Gwarantujemy, że nie wzdyma. Żółta!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "jbean_yellow"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 10,
		/datum/reagent/consumable/lemonjuice = 2,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/nougat
	name = "nugat"
	desc = "Miękki, ciągnący się cukierek, częsty w batonach."
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "nougat"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/sugar = 3,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | MEAT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/taffy
	name = "ciągutki morskie"
	desc = "Staroświeckie ciągutki na słonej wodzie. Ciągną się!"
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "candy1"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/sugar = 3,
	)
	tastes = list("cukierek" = 1)
	foodtypes = JUNKFOOD | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/sweet/toffee
	name = "toffi"
	desc = "Twardy, kruchy cukierek o charakterystycznym smaku."
	icon = 'aquila/icons/obj/food/paradise/candy.dmi'
	icon_state = "toffee"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/sugar = 3,
	)
	tastes = list("cukierek" = 1)
	foodtypes = GRAIN | JUNKFOOD | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/syntisteak_cactus
	name = "syntetyczny stek z kaktusem"
	desc = "Syntetyczny płat mięsa z opuncją na wierzchu."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "meatstake_cactus"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/vitamin = 1,
	)
	tastes = list("mięso" = 1, "kaktus" = 1)
	foodtypes = FRUIT | MEAT
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/telebacon
	name = "teleboczek"
	desc = "Smakuje trochę dziwnie, ale nadal jest pyszny."
	icon = 'aquila/icons/obj/food/paradise/meat.dmi'
	icon_state = "bacon"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
	)
	tastes = list("bekon" = 1)
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/toast
	name = "tost"
	desc = "Tak! Tost!"
	icon = 'aquila/icons/obj/food/paradise/burgerbread.dmi'
	icon_state = "toast"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
	)
	tastes = list("tost" = 1)
	foodtypes = GRAIN
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/toastedsandwich
	name = "zapiekana kanapka"
	desc = "Teraz tylko brakuje batonika z pieprzem."
	icon = 'aquila/icons/obj/food/paradise/burgerbread.dmi'
	icon_state = "toastedsandwich"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/carbon = 2,
	)
	tastes = list("tost" = 1)
	foodtypes = GRAIN | VEGETABLES
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/tofurkey
	name = "tofurek"
	desc = "Udawany indyk z tofu."
	icon = 'aquila/icons/obj/food/paradise/food.dmi'
	icon_state = "tofurkey"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 12,
	)
	tastes = list("tofu" = 1)
	foodtypes = GRAIN | VEGETABLES
	bite_consumption = 3
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/tree_salad
	name = "sałatka z drzewa"
	desc = "Sałatka z kory i liści. Czy to oko nimfy?"
	icon = 'aquila/icons/obj/food/paradise/cannibalism.dmi'
	icon_state = "tree_salad"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
	)
	tastes = list("kora" = 1, "liście" = 1)
	trash_type = /obj/item/reagent_containers/glass/bowl
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/turkish_delight
	name = "rachatłukum"
	desc = "Kostki smakowej galaretki obtoczone w cukrze."
	icon = 'aquila/icons/obj/food/paradise/cannibalism.dmi'
	icon_state = "turkish_delight"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 5,
	)
	tastes = list("galaretka" = 1, "cukier" = 1)
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/wafers
	name = "wafle"
	desc = "Kawałek metalu z odsłoniętymi waflami krzemowymi."
	icon = 'aquila/icons/obj/food/paradise/cannibalism.dmi'
	icon_state = "wafers"
	food_reagents = list(
		/datum/reagent/iron = 5,
		/datum/reagent/gold = 1,
	)
	tastes = list("słodycz" = 1, "metal" = 1)
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/wingfangchu
	name = "wing fang chu"
	desc = "Pikantne danie z obcych skrzydełek w sosie sojowym. Chwila, co?"
	icon = 'aquila/icons/obj/food/paradise/soupsalad.dmi'
	icon_state = "wingfangchu"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/soysauce = 5,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("soja" = 1)
	foodtypes = MEAT
	trash_type = /obj/item/reagent_containers/glass/bowl
	crafting_complexity = FOOD_COMPLEXITY_3
