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
	description = "Mikrofala, frytkownica (25 j. oleju), worki mąki, zlewka z wodą, jajka, ser i gotowe dania z portu. Kuchnię obsługujesz sam (rola kucharza niepotrzebna: jedzenie zrobione przez ciebie dostaje \"to twoje dzieło\"). \
	1) Wlej mąkę z worka do zlewki z wodą → oczekiwane: powstaje kulka ciasta (15 mąki + 10 wody = 1 ciasto). \
	2) Włóż jajko do mikrofali i włącz → oczekiwane: jajko na twardo (boiled egg); obejrzyj je - powinno być oznaczone jako twoje dzieło. \
	3) Pokrój kółko sera nożem → oczekiwane: kawałki sera; w menu craftingu (tablecraft) zrób omlet z 2 jajek i 2 kawałków sera → oczekiwane: omlet. \
	4) Wrzuć kiełbasę, pizzę lub placek (pie) do frytkownicy, poczekaj → oczekiwane: smażone wersje, olej ubywa. Wrzuć to samo drugi raz → oczekiwane: odmowa (nie da się smażyć dwa razy). \
	5) Pokrój pizzę, tort i ciasto nożem → oczekiwane: kawałki ze sprite'ami. \
	6) Negatyw: włóż do mikrofali nóż (metal) → oczekiwane: iskry i awaria mikrofali (UWAGA: lekki wybuch, stań z boku). Frytkownica bez oleju (wylej go) → oczekiwane: komunikat o braku oleju, nic się nie smaży."
	items = list(
		/obj/machinery/microwave = 1,
		/obj/machinery/deepfryer = 1,
		/obj/item/reagent_containers/glass/beaker/large = 1,
		/obj/item/reagent_containers/food/condiment/flour = 2,
		/obj/item/reagent_containers/food/condiment/rice = 1,
		/obj/item/reagent_containers/food/condiment/milk = 1,
		/obj/item/reagent_containers/food/condiment/enzyme = 1,
		/obj/item/food/egg = 4,
		/obj/item/food/cheese/wheel = 1,
		/obj/item/food/pizza/margherita = 1,
		/obj/item/food/pie/plain = 1,
		/obj/item/food/cake/plain = 1,
		/obj/item/food/sausage = 2,
		/obj/item/kitchen/knife = 1,
	)

/datum/test_chamber_kit/pr_377_ingredients/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	// Woda do robienia ciasta z mąki
	for(var/obj/item/reagent_containers/glass/beaker/large/beaker in spawned)
		beaker.reagents.add_reagent(/datum/reagent/water, 50)
