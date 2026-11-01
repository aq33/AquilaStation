//Not only meat, actually, but also snacks that are almost meat, such as fish meat or tofu


////////////////////////////////////////////FISH////////////////////////////////////////////

/obj/item/food/cubancarp
	name = "\improper kubański karp"
	desc = "Grifftastyczna kanapka, która pali język, a potem zostawia go odrętwiałym!"
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "cubancarp"
	bite_consumption = 3
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/capsaicin = 1,
		/datum/reagent/consumable/nutriment/vitamin = 4
	)
	tastes = list("ryba" = 4, "ciasto naleśnikowe" = 1, "ostre papryki" = 1)
	foodtypes = MEAT | FRIED
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/fishmeat
	name = "filet rybny"
	desc = "Filet z jakiejś ryby."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "fishfillet"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	bite_consumption = 6
	tastes = list("ryba" = 1)
	foodtypes = MEAT
	eatverbs = list("gryzie", "przeżuwa", "obgryza", "połyka", "chrupie")
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/fishmeat/carp
	name = "filet z karpia"
	desc = "Filet z mięsa kosmicznego karpia."
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/toxin/carpotoxin = 2,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)

/obj/item/food/fishmeat/carp/imitation
	name = "imitacja filetu z karpia"
	desc = "Prawie jak prawdziwy. Tak jakby."


/obj/item/food/fishfingers
	name = "paluszki rybne"
	desc = "Rybny paluszek."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "fishfingers"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	bite_consumption = 1
	tastes = list("ryba" = 1, "bułka tarta" = 1)
	foodtypes = MEAT | FRIED
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/fishandchips
	name = "ryba z frytkami"
	desc = "Sam to mówię, mój drogi."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "fishandchips"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	tastes = list("ryba" = 1, "chipsy" = 1)
	foodtypes = MEAT | VEGETABLES | FRIED
	crafting_complexity = FOOD_COMPLEXITY_2

/*
/obj/item/food/fishfry
	name = "smażona ryba"
	desc = "Tyle zachodu, a frytek brak..."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "fishfry"
	food_reagents = list (/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("ryba" = 1, "warzywa z patelni" = 1)
	foodtypes = SEAFOOD | VEGETABLES | FRIED
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/fishtaco
	name = "taco z rybą"
	desc = "Taco z rybą, serem i kapustą."
	icon_state = "fishtaco"
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 3, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("taco" = 4, "ryba" = 2, "ser" = 2, "kapusta" = 1)
	foodtypes = SEAFOOD | DAIRY | GRAIN | VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2
*/

////////////////////////////////////////////MEATS AND ALIKE////////////////////////////////////////////

/obj/item/food/tofu
	name = "tofu"
	desc = "Wszyscy kochamy tofu."
	icon_state = "tofu"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	tastes = list("tofu" = 1)
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/tofu/prison
	name = "rozmokłe tofu"
	desc = "Odmawiasz jedzenia tego dziwnego twarożku sojowego."
	tastes = list("kwaśna, zgniła woda" = 1)
	foodtypes = GROSS
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/spiderleg
	name = "pajęcza noga"
	desc = "Wciąż drgająca noga gigantycznego pająka... chyba nie chcesz tego jeść, co?"
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "spiderleg"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 3,
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/toxin = 2
	)
	tastes = list("pajęczyny" = 1)
	foodtypes = MEAT | TOXIC
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/spiderleg/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/boiledspiderleg, rand(50 SECONDS, 60 SECONDS), TRUE, TRUE)

/obj/item/food/cornedbeef
	name = "peklowana wołowina z kapustą"
	desc = "Teraz możesz poczuć się jak prawdziwy turysta na wakacjach w Irlandii."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "cornedbeef"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 4
	)
	tastes = list("mięso" = 1, "kapusta" = 1)
	foodtypes = MEAT | VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/bearsteak
	name = "filet migrrrnon"
	desc = "Bo jedzenie niedźwiedzia nie było dość męskie."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "bearsteak"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 9,
		/datum/reagent/consumable/ethanol/manly_dorf = 5
	)
	tastes = list("mięso" = 1, "łosoś" = 1)
	foodtypes = MEAT | ALCOHOL
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

//Raw

/obj/item/food/raw_meatball
	name = "surowy klopsik"
	desc = "Świetny posiłek pod każdym względem. Żadna tam kłoda drewna. Trochę surowy."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "raw_meatball"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 2)
	tastes = list("mięso" = 1)
	foodtypes = MEAT | RAW
	w_class = WEIGHT_CLASS_SMALL
	var/meatball_type = /obj/item/food/meatball
	var/patty_type = /obj/item/food/raw_patty
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/raw_meatball/make_grillable()
	AddComponent(/datum/component/grillable, meatball_type, rand(30 SECONDS, 40 SECONDS), TRUE)

/obj/item/food/raw_meatball/make_processable()
	AddElement(/datum/element/processable, TOOL_ROLLINGPIN, patty_type, 1, 20)

/obj/item/food/raw_meatball/human
	name = "dziwny surowy klopsik"
	meatball_type = /obj/item/food/meatball/human
	patty_type = /obj/item/food/raw_patty/human

/obj/item/food/raw_meatball/corgi
	name = "surowy klopsik z corgiego"
	meatball_type = /obj/item/food/meatball/corgi
	patty_type = /obj/item/food/raw_patty/corgi

/obj/item/food/raw_meatball/xeno
	name = "surowy klopsik z ksenomorfa"
	meatball_type = /obj/item/food/meatball/xeno
	patty_type = /obj/item/food/raw_patty/xeno

/obj/item/food/raw_meatball/bear
	name = "surowy klopsik z niedźwiedzia"
	meatball_type = /obj/item/food/meatball/bear
	patty_type = /obj/item/food/raw_patty/bear

/obj/item/food/raw_meatball/chicken
	name = "surowy klopsik z kurczaka"
	meatball_type = /obj/item/food/meatball/chicken
	patty_type = /obj/item/food/raw_patty/chicken

//Cooked

/obj/item/food/meatball
	name = "klopsik"
	desc = "Świetny posiłek pod każdym względem. Żadna tam kłoda drewna."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "meatball"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 2
	)
	tastes = list("mięso" = 1)
	foodtypes = MEAT
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/meatball/human
	name = "dziwny klopsik"

/obj/item/food/meatball/corgi
	name = "klopsik z corgiego"

/obj/item/food/meatball/bear
	name = "klopsik z niedźwiedzia"
	tastes = list("mięso" = 1, "łosoś" = 1)

/obj/item/food/meatball/xeno
	name = "klopsik z ksenomorfa"
	tastes = list("mięso" = 1, "kwas" = 1)

/obj/item/food/meatball/chicken
	name = "klopsik z kurczaka"
	tastes = list("kurczak" = 1)
	icon_state = "chicken_meatball"

/obj/item/food/raw_patty
	name = "surowy kotlet mielony"
	desc = "Jeszcze.....NIE JESTEM GOTOOOWYYY."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "raw_patty"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 2)
	tastes = list("mięso" = 1)
	foodtypes = MEAT | RAW
	w_class = WEIGHT_CLASS_SMALL
	var/patty_type = /obj/item/food/patty/plain
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/raw_patty/make_grillable()
	AddComponent(/datum/component/grillable, patty_type, rand(30 SECONDS, 40 SECONDS), TRUE)

/obj/item/food/raw_patty/human
	name = "dziwny surowy kotlet mielony"
	patty_type = /obj/item/food/patty/human

/obj/item/food/raw_patty/corgi
	name = "surowy kotlet mielony z corgiego"
	patty_type = /obj/item/food/patty/corgi

/obj/item/food/raw_patty/bear
	name = "surowy kotlet mielony z niedźwiedzia"
	tastes = list("mięso" = 1, "łosoś" = 1)
	patty_type = /obj/item/food/patty/bear

/obj/item/food/raw_patty/xeno
	name = "surowy kotlet mielony z ksenomorfa"
	tastes = list("mięso" = 1, "kwas" = 1)
	patty_type = /obj/item/food/patty/xeno

/obj/item/food/raw_patty/chicken
	name = "surowy kotlet mielony z kurczaka"
	tastes = list("kurczak" = 1)
	patty_type = /obj/item/food/patty/chicken

/obj/item/food/patty
	name = "kotlet mielony"
	desc = "Kotlet Nanotrasen to kotlet dla ciebie i dla mnie!"
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "patty"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 2)
	tastes = list("mięso" = 1)
	foodtypes = MEAT
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

///Exists purely for the crafting recipe (because itll take subtypes)
/obj/item/food/patty/plain

/obj/item/food/patty/human
	name = "dziwny kotlet mielony"

/obj/item/food/patty/corgi
	name = "kotlet mielony z corgiego"

/obj/item/food/patty/bear
	name = "kotlet mielony z niedźwiedzia"
	tastes = list("mięso" = 1, "łosoś" = 1)

/obj/item/food/patty/xeno
	name = "kotlet mielony z ksenomorfa"
	tastes = list("mięso" = 1, "kwas" = 1)

/obj/item/food/patty/chicken
	name = "kotlet mielony z kurczaka"
	tastes = list("kurczak" = 1)
	icon_state = "chicken_patty"

/obj/item/food/raw_sausage
	name = "surowa kiełbasa"
	desc = "Kawałek mieszanego, długiego mięsa, tyle że surowy."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "raw_sausage"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("mięso" = 1)
	foodtypes = MEAT | RAW
	eatverbs = list("gryzie","przeżuwa","skubie","połyka w całości","pochłania","chrupie")
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/raw_sausage/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/sausage, rand(60 SECONDS, 75 SECONDS), TRUE)

/obj/item/food/sausage
	name = "kiełbasa"
	desc = "Kawałek mieszanego, długiego mięsa."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "sausage"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	tastes = list("mięso" = 1)
	foodtypes = MEAT | BREAKFAST
	food_flags = FOOD_FINGER_FOOD
	eatverbs = list("gryzie", "przeżuwa", "skubie", "pochłania", "chrupie")
	w_class = WEIGHT_CLASS_SMALL
	var/roasted = FALSE
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/sausage/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/salami, 6, 3 SECONDS, table_required = TRUE, screentip_verb = "Pokrój")
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/sausage/american, 1, 3 SECONDS, table_required = TRUE)

/obj/item/food/sausage/american
	name = "amerykańska kiełbasa"
	desc = "Ciach."
	icon_state = "american_sausage"

/obj/item/food/sausage/american/make_processable() //or else it would make itself? Lmao
	return

/obj/item/food/salami
	name = "salami"
	desc = "Plasterek dojrzewającego salami. Na pewno można dać im trochę..."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "salami"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 1
	)
	tastes = list("mięso" = 1, "dym" = 1)
	foodtypes = MEAT
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/rawkhinkali
	name = "surowe chinkali"
	desc = "Sto chinkali? Czy ja wyglądam na świnię?"
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "khinkali"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/nutriment/protein = 1,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/garlic = 1
	)
	tastes = list("mięso" = 1, "cebula" = 1, "czosnek" = 1)
	foodtypes = MEAT | RAW
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/rawkhinkali/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/khinkali, rand(50 SECONDS, 60 SECONDS), TRUE)

/obj/item/food/khinkali
	name = "chinkali"
	desc = "Sto chinkali? Czy ja wyglądam na świnię?"
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "khinkali"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/nutriment/protein = 1,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/garlic = 1
	)
	bite_consumption = 3
	tastes = list("mięso" = 1, "cebula" = 1, "czosnek" = 1)
	foodtypes = MEAT
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/meatbun
	name = "bułka z mięsem"
	desc = "Istnieje szansa, że to nie pies."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "meatbun"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 7,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("bułka" = 3, "mięso" = 2)
	foodtypes = GRAIN | MEAT | VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/stewedsoymeat
	name = "duszone mięso sojowe"
	desc = "Nawet niewegetarianie to POKOCHAJĄ!"
	icon_state = "stewedsoymeat"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	tastes = list("soja" = 1, "warzywa" = 1)
	eatverbs = list("siorbie", "popija", "wciąga", "pije")
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/boiledspiderleg
	name = "gotowana pajęcza noga"
	desc = "Noga gigantycznego pająka, która drga nawet po ugotowaniu. Ohyda!"
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "spiderlegcooked"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/capsaicin = 4,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	tastes = list("ostre papryki" = 1, "pajęczyny" = 1)
	foodtypes = MEAT
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/spidereggsham
	name = "zielone jajka i szynka"
	desc = "Zjadłbyś je w pociągu? Zjadłbyś je w samolocie? Zjadłbyś je w najnowocześniejszej korporacyjnej pułapce śmierci dryfującej przez kosmos?"
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "spidereggsham"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/nutriment/vitamin = 3
	)
	bite_consumption = 4
	tastes = list("mięso" = 1, "kolor zielony" = 1)
	foodtypes = MEAT | BREAKFAST
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/sashimi
	name = "sashimi z karpia"
	desc = "Uczcij przetrwanie ataku wrogich obcych form życia, lądując w szpitalu. Oby ten, kto to zrobił, znał się na rzeczy."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "sashimi"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 10,
		/datum/reagent/consumable/capsaicin = 9,
		/datum/reagent/consumable/nutriment/vitamin = 4
	)
	tastes = list("ryba" = 1, "ostre papryki" = 1)
	foodtypes = MEAT
	w_class = WEIGHT_CLASS_TINY
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/nugget
	name = "nugget z kurczaka"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/nutriment/vitamin = 1
	)
	icon = 'icons/obj/food/meat.dmi'
	tastes = list("„kurczak”" = 1)
	foodtypes = MEAT
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_TINY
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/nugget/Initialize(mapload)
	. = ..()
	var/shape = pick("lump", "star", "lizard", "corgi")
	var/static/list/shape_pl = list("lump" = "grudki", "star" = "gwiazdki", "lizard" = "jaszczurki", "corgi" = "corgiego")
	desc = "Nugget z „kurczaka”, mniej więcej w kształcie [shape_pl[shape]]."
	icon_state = "nugget_[shape]"

/obj/item/food/pigblanket
	name = "parówka w cieście"
	desc = "Malutka kiełbaska zawinięta w kruche, maślane ciasto. Uwolnij tę świnkę z jej więzienia, zjadając ją."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "pigblanket"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	tastes = list("mięso" = 1, "masło" = 1)
	foodtypes = MEAT | DAIRY | GRAIN
	w_class = WEIGHT_CLASS_TINY
	crafting_complexity = FOOD_COMPLEXITY_3

/obj/item/food/bbqribs
	name = "żeberka BBQ"
	desc = "Żeberka BBQ obficie pokryte zdrową warstwą sosu barbecue. Najmniej wegańska rzecz, jaka kiedykolwiek istniała."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "ribs"
	w_class = WEIGHT_CLASS_NORMAL
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 10,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/consumable/bbqsauce = 10
	)
	tastes = list("mięso" = 3, "wędzony sos" = 1)
	foodtypes = MEAT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/meatclown
	name = "mięsny klaun"
	desc = "Pyszny, okrągły kawałek mięsnego klauna. Jakie to straszne."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "meatclown"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/banana = 2
	)
	tastes = list("mięso" = 5, "klauni" = 3, "szesnaście tesli" = 1)
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/meatclown/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery, 3 SECONDS)

//////////////////////////////////////////// KEBABS AND OTHER SKEWERS ////////////////////////////////////////////

/obj/item/food/kebab
	trash_type = /obj/item/stack/rods
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "kebab"
	w_class = WEIGHT_CLASS_NORMAL
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 14
	)
	tastes = list("mięso" = 3, "metal" = 1)
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/kebab/human
	name = "ludzki kebab"
	desc = "Ludzkie mięso na patyku."
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 16,
		/datum/reagent/consumable/nutriment/vitamin = 6
	)
	tastes = list("delikatne mięso" = 3, "metal" = 1)
	foodtypes = MEAT | GORE

/obj/item/food/kebab/monkey
	name = "kebab mięsny"
	desc = "Pyszne mięso na patyku."
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 16,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	tastes = list("mięso" = 3, "metal" = 1)
	foodtypes = MEAT

/obj/item/food/kebab/tofu
	name = "kebab z tofu"
	desc = "Wegańskie mięso na patyku."
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 15)
	tastes = list("tofu" = 3, "metal" = 1)
	foodtypes = VEGETABLES

/obj/item/food/kebab/tail
	name = "kebab z ogona jaszczura"
	desc = "Odcięty ogon jaszczura na patyku."
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 30,
		/datum/reagent/consumable/nutriment/vitamin = 4
	)
	tastes = list("mięso" = 8, "metal" = 4, "łuski" = 1)
	foodtypes = MEAT

/obj/item/food/kebab/rat
	name = "szczurzy kebab"
	desc = "Niezbyt pyszne szczurze mięso na patyku."
	icon_state = "ratkebab"
	w_class = WEIGHT_CLASS_NORMAL
	trash_type = null
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 10,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	tastes = list("szczurze mięso" = 1, "metal" = 1)
	foodtypes = MEAT | GORE

/obj/item/food/kebab/rat/double
	name = "podwójny szczurzy kebab"
	icon_state = "doubleratkebab"
	tastes = list("szczurze mięso" = 2, "metal" = 1)
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 20,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/iron = 2
	)

/obj/item/food/kebab/fiesta
	name = "szaszłyk fiesta"
	icon_state = "fiestaskewer"
	tastes = list("tex-mex" = 3, "kmin" = 2)
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 12,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/consumable/capsaicin = 3
	)
	crafting_complexity = FOOD_COMPLEXITY_3
