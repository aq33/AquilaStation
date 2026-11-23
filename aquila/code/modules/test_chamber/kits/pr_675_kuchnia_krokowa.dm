// Gotowanie krok po kroku, nagrzewanie sprzętu, konsola zamówień kuchni i baru

/datum/test_chamber_kit/pr_675
	name = "PR 675: kuchnia krok po kroku"
	pr = "aq33/AquilaStation#675"
	description = "1) Kuchenka elektryczna (4 palniki): postaw patelnię na wybranym palniku (kliknięcie w ten palnik). Do patelni po kolei: zlewka z olejem (dodatkowy krok), jajko, zlewka z solą (dodatkowy krok). Obejrzyj patelnię: widać, co może wyjść i jaki jest następny krok. Alt+klik na kuchence: wybierz palnik, włącz, ogień średni, minutnik 10 s. Examine kuchenki: rozgrzewa się (kilkanaście sekund). Po ~10–20 s jajko sadzone z dopiskiem „Dobrze przyrządzone”. Zostaw je na ogniu: po ~45 s dym i zakalec. 2) Omlet: patelnia, 2 jajka, ser, pieprz (dodatkowy), niski ogień 20 s. Na średnim ogniu czas nie leci i nic się nie przypala. 3) Rondel: woda (10 j.), surowe spaghetti, wysoki ogień 15 s; potem klopsiki ×2 do ugotowanego makaronu, średni ogień: spaghetti z klopsikami. 4) Piekarnik: otwórz, wstaw naczynie żaroodporne z ciastem i jajkiem, zamknij, Alt+klik: ogień średni. Po ~10 s chleb (samo ciasto daje bułkę). Blacha z ciastem na wysokim ogniu piecze się szybciej. 5) Grill: dorzuć węgiel, połóż ruszt z surowym mięsem (sól i pieprz dodatkowo), po 30 s stek. 6) Frytkownica: koszyk z ziemniakiem (z hydroponiki), smaży się 20 s; examine frytkownicy pokazuje rozgrzewanie oleju. 7) Kuchenka i kuchnia z zupami: Alt+klik ustawia ogień zupy (niski 348 K, średni 500 K, wysoki 620 K i przypalanie). Prawy przycisk dalej włącza palniki. Patelnia też staje na palniku zwykłej kuchenki. 8) PDA kucharza, Książka kucharska: zakładka „Krok po kroku” z ponumerowanymi krokami (wymaga przebudowanego TGUI). 9) Konsola zamówień kuchni i baru: włóż bon (10 darmowych produktów), zamów z kartą z dostępem kuchni albo baru i kontem bankowym. Płaci budżet usług, ekspres zrzuca kapsułę. 10) Mikser lodów: misa do lodów, do niej patyczek, tofu, 5 j. cukru i 5 j. soku bananowego (osobne zlewki), wstaw misę do miksera, Alt+klik: włącz. Po ~10 s bananowy lód z tofu; zostawiony w mikserze się nie przypala. 11) Foremka w misie: 5 j. cukru, 5 j. wody, 5 j. oleju, do miksera: żelkowy miś. Foremki robi się z arkusza plastiku (lista „foremki na cukierki”). 12) Mata do sushi: gotowany ryż, filet rybny, arkusz wodorostów: sushi sake. 13) Książka kucharska: około 500 przepisów krokowych (Paradise i nasze), w zakładce stołu zostają tylko poradniki. Menu craftingu (jedzenie) nie pokazuje już dań gotowanych krok po kroku. 14) Spiżarnia konsoli zamówień: ocet, wasabi, serek śmietankowy, sos pieczeniowy. Kliknięcia sprawdź w obu trybach sterowania."
	items = list(
		/obj/item/reagent_containers/cooking/pan = 2,
		/obj/item/reagent_containers/cooking/pot = 1,
		/obj/item/reagent_containers/cooking/oven = 1,
		/obj/item/reagent_containers/cooking/grill_grate = 1,
		/obj/item/reagent_containers/cooking/deep_basket = 1,
		/obj/item/reagent_containers/cooking/bowl = 1,
		/obj/item/reagent_containers/cooking/board = 1,
		/obj/item/food/egg = 6,
		/obj/item/food/cheese/wedge = 2,
		/obj/item/food/spaghetti/raw = 1,
		/obj/item/food/meatball = 2,
		/obj/item/food/meat/slab = 1,
		/obj/item/food/dough = 2,
		/obj/item/reagent_containers/food/condiment/peppermill = 1,
		/obj/item/kitchen/knife = 1,
		/obj/item/kitchen/rollingpin = 1,
		/obj/item/stack/sheet/mineral/coal/ten = 1,
		/obj/item/modular_computer/tablet/pda/cook = 1,
		/obj/item/card/id/job/cook = 1,
		/obj/item/cooking_voucher = 1,
		/obj/item/reagent_containers/cooking/icecream_bowl = 1,
		/obj/item/reagent_containers/cooking/mould/bear = 1,
		/obj/item/reagent_containers/cooking/sushimat = 1,
		/obj/item/popsicle_stick = 2,
		/obj/item/food/tofu = 1,
		/obj/item/food/boiledrice = 1,
		/obj/item/food/fishmeat = 1,
		/obj/item/food/seaweed_sheet = 1,
		/obj/item/stack/sheet/plastic/five = 1,
	)

/datum/test_chamber_kit/pr_675/setup(list/spawned, list/turfs, turf/center, mob/user)
	new /obj/machinery/cooking_stovetop(locate(center.x - 2, center.y + 2, center.z))
	new /obj/machinery/oven(locate(center.x - 1, center.y + 2, center.z))
	new /obj/machinery/grill(locate(center.x, center.y + 2, center.z))
	new /obj/machinery/deepfryer(locate(center.x + 1, center.y + 2, center.z))
	new /obj/machinery/stove(locate(center.x + 2, center.y + 2, center.z))
	new /obj/machinery/computer/order_console/cook(locate(center.x + 3, center.y + 2, center.z))
	new /obj/machinery/ice_cream_mixer(locate(center.x - 3, center.y + 2, center.z))
	var/turf/table_spot = locate(center.x - 2, center.y - 2, center.z)
	for(var/list/beaker_contents in list(list(/datum/reagent/consumable/nutriment/fat/oil, 50), list(/datum/reagent/consumable/sodiumchloride, 20), list(/datum/reagent/water, 50), list(/datum/reagent/consumable/sugar, 30), list(/datum/reagent/consumable/banana, 20)))
		var/obj/item/reagent_containers/glass/beaker/large/beaker = new(table_spot)
		beaker.reagents.add_reagent(beaker_contents[1], beaker_contents[2])
		beaker.amount_per_transfer_from_this = 5
