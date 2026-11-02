////////////////////////////////////////////SNACKS FROM VENDING MACHINES////////////////////////////////////////////
//in other words: junk food
//don't even bother looking for recipes for these

/obj/item/food/candy
	name = "cukierek"
	desc = "Nugat: kochasz albo nienawidzisz."
	icon_state = "candy"
	trash_type = /obj/item/trash/candy
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/sugar = 3
	)
	junkiness = 25
	tastes = list("cukierki" = 1)
	foodtypes = JUNKFOOD | SUGAR
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_TINY
	crafting_complexity = FOOD_COMPLEXITY_2

/obj/item/food/sosjerky
	name = "\improper suszona wołowina Scaredy's Private Reserve"
	icon_state = "sosjerky"
	desc = "Suszona wołowina z najlepszych kosmicznych krów."
	trash_type = /obj/item/trash/sosjerky
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 3,
		/datum/reagent/consumable/sugar = 2,
		/datum/reagent/consumable/sodiumchloride = 2
	)
	junkiness = 25
	tastes = list("suszone mięso" = 1)
	w_class = WEIGHT_CLASS_SMALL
	foodtypes = JUNKFOOD | MEAT | SUGAR
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/sosjerky/healthy
	name = "domowa suszona wołowina"
	desc = "Domowa suszona wołowina z najlepszych kosmicznych krów."
	icon_state = "sosjerky_homemade"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 1
	)
	crafting_complexity = FOOD_COMPLEXITY_2
	junkiness = 0

/obj/item/food/sosjerky/healthy/lean
	name = "chuda suszona wołowina"
	desc = "Domowa suszona wołowina z najlepszych kosmicznych krów. Specjalna edycja z chudych kawałków!"
	icon_state = "sosjerky_lowfat"
	tastes = list("suszone mięso" = 3, "kurczak" = 1)	//is it really chicken, or something else?....

/obj/item/food/sosjerky/healthy/lizard
	name = "suszone mięso dinozaura"
	desc = "Domowe suszone mięso z najlepszych dinozaurów Saurii. Naturalny smak dinozaura!"
	icon_state = "sosjerky_dinosaur"
	tastes = list("suszone mięso" = 1, "łuski" = 1)

/obj/item/food/sosjerky/healthy/pig
	name = "suszona wieprzowina"
	desc = "Domowe suszone mięso z najczystszych świń w sektorze."
	icon_state = "sosjerky_pig"
	tastes = list("suszone mięso" = 1, "żołędzie" = 1)
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 3,
		/datum/reagent/consumable/nutriment/fat = 2,
		/datum/reagent/consumable/nutriment/vitamin = 1
	)

/obj/item/food/sosjerky/healthy/mouse
	name = "przysmaki dla jaszczurów"
	desc = "Domowe suszone mięso z lokalnych kosmicznych myszy. \n20% dochodu idzie na walkę ze szkodnikami na niedofinansowanych stacjach kosmicznych. \n100% mięsa idzie na szczęście twojego jaszczura!"
	icon_state = "sosjerky_lizard_treats"
	tastes = list("suszone mięso" = 1, "szkodniki" = 1)
	foodtypes = JUNKFOOD | MEAT | GORE

/obj/item/food/sosjerky/pemmican
	name = "\improper racja żywnościowa Space Pemmican(tm)"
	desc = "Produkt mięsny przetworzony chemicznie, odwodniony, zakonserwowany.\nMoże zawierać azodikarbonamid, propyloparaben, erytrozynę.\nW ponad 35% składa się z tkanki łącznej. \nSpace Pemmican(tm) uznano za niezdatny do spożycia przez ludzi w Strefie Ekonomicznej Zewnętrznego Układu Słonecznego Jowisz II Europa."
	icon_state = "sosjerky_synth_pemmican"
	tastes = list("aromat mięsny" = 2, "mączka z krwi" = 2, "naturalne i sztuczne barwniki" = 1, "gastronomiczny niepokój" = 1)
	foodtypes = JUNKFOOD | MEAT | GROSS
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/fat = 2
	)
	junkiness = 45	//At least Scaredy's Private Reserve is made from real meat! What the hell is this?! Is this even food at this point?!

/obj/item/food/sosjerky/healthy/bugs
	name = "przekąski z robaków"
	desc = "Domowe wysokobiałkowe przekąski z mieszanki owadów. Dziękujemy za wspieranie drogi ku zrównoważonej żywności!"
	icon_state = "sosjerky_bugs"
	tastes = list("chrupiąca tkanka" = 4, "postępowość" = 1)

/obj/item/food/sosjerky/healthy/bees
	name = "przekąski z pszczół"
	desc = "Domowe wysokobiałkowe przekąski w 100% z pszczół."
	icon_state = "sosjerky_bees"
	tastes = list("chrupiąca delikatność" = 4, "pyłek" = 1)

/obj/item/food/sosjerky/healthy/synthmeat
	name = "suszone mięso bez okrucieństwa"
	desc = "Domowe suszone mięso z syntetycznego mięsa. Przy produkcji nie ucierpiało ani jedno zwierzę."
	icon_state = "sosjerky_synth"
	tastes = list("suszone mięso" = 3, "kolor niebieski" = 1)

/obj/item/food/sosjerky/healthy/monkey
	name = "suszone mięso małpy"
	desc = "Domowe suszone mięso z małpy. \nNaturalnie zawiera smak bananowy. \nBez szczepionki na HIV."
	icon_state = "sosjerky_monkey"
	tastes = list("suszone mięso" = 1, "banany" = 1)

/obj/item/food/sosjerky/healthy/diona
	name = "suszone warzywa"
	desc = "Domowe suszone warzywa udające mięso. \nTen produkt NIE został zatwierdzony przez komisję etyki. \nMoże urazić niektórych roślinnych członków załogi."
	icon_state = "sosjerky_vegan"
	tastes = list("suszone buraki" = 3, "sfermentowane pomidory" = 2, "sałata" = 2, "wegetariańskie wyrzuty sumienia" = 1)
	foodtypes = JUNKFOOD | VEGETABLES
	food_reagents = list(
		/datum/reagent/consumable/nutriment/vitamin = 6	//very healthy! go butcher your diona coworker!
	)

/obj/item/food/sosjerky/healthy/mushroom
	name = "suszone grzyby"
	desc = "Mieszanka suszonych plasterków grzybów. Nie powinny być trujące."
	icon_state = "sosjerky_mushroom"
	tastes = list("suszone grzyby" = 3, "ziemia" = 1)
	foodtypes = JUNKFOOD | VEGETABLES
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 3,	//fungi are heterotrophs
		/datum/reagent/consumable/nutriment/vitamin = 3,	//still healthy
		/datum/reagent/drug/mushroomhallucinogen = 3
	)

/obj/item/food/sosjerky/healthy/mushroom/Initialize(mapload)
	. = ..()
	if(rand(1, 100) == 1)
		for(var/datum/reagent/R in reagents.reagent_list)
			var/amount = R.volume
			reagents.remove_reagent(R.type, amount)
		reagents.add_reagent(/datum/reagent/toxin/amanitin, 10) //don't trust random mushrooms! (this is about 90 tox)
		reagents.add_reagent(/datum/reagent/drug/mushroomhallucinogen, 3)

/obj/item/food/sosjerky/healthy/jelly
	name = "suszone paski galaretki"
	desc = "Domowe suszone paski galaretki. \nMogą być toksyczne dla większości form życia."
	icon_state = "sosjerky_jelly"
	tastes = list("galaretka" = 2, "galaretka" = 2, "kwaśność" = 1)
	foodtypes = JUNKFOOD | TOXIC | SUGAR
	food_reagents = list(
		/datum/reagent/toxin/slimejelly = 3,
		/datum/reagent/consumable/sugar = 3,
		/datum/reagent/consumable/nutriment = 3
	)

/obj/item/food/sosjerky/healthy/ethereal
	name = "suszony ładunek elektrostatyczny"
	desc = "To, co zostaje po wysuszeniu samej elektryczności. \nMoże kopać prądem."
	icon_state = "sosjerky_electric"
	tastes = list("ładunek elektrostatyczny" = 2, "elektrodynamika" = 2, "narastający żal" = 1)
	foodtypes = JUNKFOOD
	food_reagents = list(
		/datum/reagent/consumable/liquidelectricity = 6
	)

/obj/item/food/chips
	name = "chipsy"
	desc = "Chipsy Co-Do-Licha komandora Rikera."
	icon_state = "chips"
	trash_type = /obj/item/trash/chips
	bite_consumption = 1
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/sugar = 3,
		/datum/reagent/consumable/sodiumchloride = 1
	)
	junkiness = 20
	tastes = list("sól" = 1, "chrupki" = 1)
	foodtypes = JUNKFOOD | FRIED
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/no_raisin
	name = "\improper rodzynki 4no"
	icon_state = "4no_raisins"
	desc = "Najlepsze rodzynki we wszechświecie. Nie wiadomo czemu."
	trash_type = /obj/item/trash/raisins
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/sugar = 4
	)
	junkiness = 25
	tastes = list("suszone rodzynki" = 1)
	foodtypes = JUNKFOOD | FRUIT | SUGAR
	food_flags = FOOD_FINGER_FOOD
	custom_price = PAYCHECK_MEDIUM * 0.7
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/no_raisin/healthy
	name = "domowe rodzynki"
	desc = "Domowe rodzynki, najlepsze w całym kosmosie."
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	junkiness = 0
	foodtypes = FRUIT
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/spacetwinkie
	name = "\improper Space Twinkie"
	icon_state = "space_twinkie"
	desc = "Gwarantujemy, że przetrwa dłużej niż ty."
	food_reagents = list(
		/datum/reagent/consumable/sugar = 4
	)
	junkiness = 25
	foodtypes = JUNKFOOD | GRAIN | SUGAR
	food_flags = FOOD_FINGER_FOOD
	custom_price = PAYCHECK_EASY
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/cheesiehonkers
	name = "\improper Cheesie Honkers"
	desc = "Serowe przekąski na jeden kęs, które zahonkają ci w całej buzi."
	icon_state = "cheesie_honkers"
	trash_type = /obj/item/trash/cheesie
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/sugar = 3
	)
	junkiness = 25
	tastes = list("ser" = 5, "chrupki" = 2)
	foodtypes = JUNKFOOD | DAIRY | SUGAR
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/syndicake
	name = "\improper Syndi-Cakes"
	icon_state = "syndi_cakes"
	desc = "Niezwykle wilgotne ciastko, które smakuje równie dobrze po wybuchu jądrowym."
	trash_type = /obj/item/trash/syndi_cakes
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/doctor_delight = 5
	)
	tastes = list("słodycz" = 3, "ciasto" = 1)
	foodtypes = GRAIN | FRUIT | VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1

/obj/item/food/energybar
	name = "\improper batony energetyczne dużej mocy"
	icon_state = "energybar"
	desc = "Baton energetyczny z niezłym kopem. Lepiej go nie jedz, jeśli nie jesteś Eterykiem."
	trash_type = /obj/item/trash/energybar
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/liquidelectricity = 10
	)
	tastes = list("czysty prąd" = 3, "fitness" = 2)
	foodtypes = TOXIC
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_1
