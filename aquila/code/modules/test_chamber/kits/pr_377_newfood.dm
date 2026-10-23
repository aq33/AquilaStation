// aq33/AquilaStation#377 - port Newfood z BeeStation: płyta, piec, krojenie, suszenie (+ #400 tacka do piekarnika)

/datum/test_chamber_kit/pr_377
	name = "PR 377: Newfood - płyta i piec"
	pr = "aq33/AquilaStation#377"
	description = "Płyta: połóż na niej surowy kotlet, bekon i stek (kawałek mięsa), włącz - po chwili mają się usmażyć, zostawione za długo przypalają się. \
	Piec postawiony w trakcie rundy jest pusty: otwórz go, włóż tackę z zestawu, połóż na niej ciasto/masę na ciasto, zamknij - ma upiec chleb/ciasto. Wyjmij tackę i włóż ją z powrotem, potem odstaw na stół (#400 - wcześniej nie działało). \
	Wałkiem rozwałkuj ciasto, nożem pokrój ciasto, ser i mięso (kotlety). Na suszarce wysusz ludzkie mięso (jerky). \
	Nazwij jedzenie długopisem. Zjedz widelcem/łyżką. Jedzenie zostawione na podłodze po kilku minutach ma zgnić."
	items = list(
		/obj/machinery/griddle = 1,
		/obj/machinery/oven = 1,
		/obj/item/plate/oven_tray = 1,
		/obj/machinery/smartfridge/drying_rack = 1,
		/obj/structure/table = 2,
		/obj/item/food/meat/rawcutlet/plain = 2,
		/obj/item/food/meat/rawbacon = 2,
		/obj/item/food/meat/slab = 2,
		/obj/item/food/meat/slab/human = 1,
		/obj/item/food/raw_meatball = 2,
		/obj/item/food/dough = 3,
		/obj/item/food/cakebatter = 1,
		/obj/item/food/cheese/wheel = 1,
		/obj/item/food/grown/tomato = 2,
		/obj/item/kitchen/rollingpin = 1,
		/obj/item/kitchen/knife = 1,
		/obj/item/kitchen/fork = 1,
		/obj/item/kitchen/spoon = 1,
		/obj/item/plate = 2,
		/obj/item/pen = 1,
	)

/datum/test_chamber_kit/pr_377_ingredients
	name = "PR 377: Newfood - składniki i gotowe dania"
	pr = "aq33/AquilaStation#377"
	description = "Składniki do mikrofali, frytkownicy i tablecraftu (mąka, ryż, mleko, enzym, jajka) oraz gotowe dania z portu: pizza, ciasto, tort, kiełbasa. \
	Sprawdź, czy dania kroją się nożem na kawałki, mają sprite'y i dają buffa od kucharza (ikona poziomu), gdy zrobi je kucharz."
	items = list(
		/obj/machinery/microwave = 1,
		/obj/machinery/deepfryer = 1,
		/obj/item/reagent_containers/food/condiment/flour = 2,
		/obj/item/reagent_containers/food/condiment/rice = 1,
		/obj/item/reagent_containers/food/condiment/milk = 1,
		/obj/item/reagent_containers/food/condiment/enzyme = 1,
		/obj/item/food/egg = 4,
		/obj/item/food/pizza/margherita = 1,
		/obj/item/food/pie/plain = 1,
		/obj/item/food/cake/plain = 1,
		/obj/item/food/sausage = 2,
		/obj/item/kitchen/knife = 1,
	)
