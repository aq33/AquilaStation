/datum/test_chamber_kit/pr_613
	name = "Materiały (basemats)"
	pr = "aq33/AquilaStation#613"
	description = "Zestaw: po 50 arkuszy złota, srebra, plastiku, drewna, plazmy i szkła, 20 arkuszy mięsa, sukno, 3 płaty mięsa, Arkuszomistrz 2000, 2 ramy stołu, 2 dźwigary, łom, klucz, śrubokręt, monety (złota, diamentowa, bananiumowa, żeton automatu, żeton antagonisty, mythrilowa, heretyka), karta ID, automat do gry, autolathe, butelka metalgenu. \
	1) Arkusz złota w ręce → menu: „krzesło z materiału” i „płytka podłogowa z materiału” dają złote krzesło i złotą płytkę. Połóż płytkę na poszyciu → złota podłoga, podważ łomem → wraca złota płytka. Złoto na ramie stołu → złoty stół. Rozbiórka krzesła i stołu oddaje złoto. \
	2) Dźwigar + 2 arkusze plastiku, drewna albo mięsa → kolorowa, nieprzezroczysta ściana bez czarnego klina; szkło daje przezroczystą ścianę; sukno nie robi nic (negatyw). \
	3) Zjedz arkusz mięsa, mięsną podłogę i mięsną ścianę → zostaje poszycie. \
	4) Płat mięsa do Arkuszomistrza → 4 arkusze mięsa z animacją. \
	5) Monety: przesuń monetę po karcie ID → wartość zgodna z materiałem, żetony 0 kr; żeton automatu nie przewraca; rzut monetą pokazuje orła/reszkę. \
	6) Stos plazmy w ogniu wybucha, arkusz bananium piszczy i przewraca. \
	7) Metalgen na stos i monetę → bez zmian (negatyw). \
	8) Autolathe przyjmuje drewno, mięso i bluespace; okna fabrykatorów mają ikony drewna, mięsa i adamantytu. \
	9) Mapowane ściany i skrzynki z narzędziami wyglądają jak dotąd, podzespoły i sygnalizatory nie są przebarwione ani półprzezroczyste."
	items = list(
		/obj/item/stack/sheet/mineral/gold = 50,
		/obj/item/stack/sheet/mineral/silver = 50,
		/obj/item/stack/sheet/plastic = 50,
		/obj/item/stack/sheet/mineral/wood = 50,
		/obj/item/stack/sheet/mineral/plasma = 50,
		/obj/item/stack/sheet/glass = 50,
		/obj/item/stack/sheet/meat = 20,
		/obj/item/stack/sheet/cotton/cloth = 10,
		/obj/item/food/meat/slab = 3,
		/obj/machinery/sheetifier = 1,
		/obj/structure/table_frame = 2,
		/obj/structure/girder = 2,
		/obj/item/crowbar = 1,
		/obj/item/wrench = 1,
		/obj/item/screwdriver = 1,
		/obj/item/coin/gold = 1,
		/obj/item/coin/diamond = 1,
		/obj/item/coin/bananium = 1,
		/obj/item/coin/arcade_token = 1,
		/obj/item/coin/antagtoken = 1,
		/obj/item/coin/mythril = 1,
		/obj/item/coin/eldritch = 1,
		/obj/item/card/id = 1,
		/obj/machinery/computer/slot_machine = 1,
		/obj/machinery/modular_fabricator/autolathe = 1,
	)

/datum/test_chamber_kit/pr_613/setup(list/spawned, list/turfs, turf/center, mob/user)
	for(var/obj/item/card/id/card in spawned)
		card.registered_name = "Tester"
	var/obj/item/reagent_containers/glass/bottle/bottle = new(center)
	bottle.name = "butelka metalgenu"
	bottle.reagents.add_reagent(/datum/reagent/metalgen, 30, list("material" = /datum/material/gold))

/datum/test_chamber_kit/pr_613_pupile
	name = "Basic moby: pupile i hodowla"
	pr = "aq33/AquilaStation#613"
	description = "Zestaw: corgi, mops, kot, kociak, domek dla kota, krowa, koza, owca, 2 kury, pisklę, indyk, królik wielkanocny, łagodny lis, pisklę pingwina, leniwiec, chomik, jaszczurka, krab, motyl, wąż, żółw, 3 myszy, karaluch, ćmokaraluch, gondola, krowa mądrości, spawner Tysona z legowiskiem, lasso, zlewka, brzytwa, zwój kabla, czapka kucharza, sosna i zamknięta skrzynia z karmą (10 kości, 10 kłosów pszenicy, 3 martwe myszy, 2 marchewki, 2 sery), żeby zwierzęta nie zjadły jej same z podłogi. Sprawdzaj w obu trybach sterowania (combat mode i stare intencje). Nie zrzucaj razem z dzikimi zwierzętami. \
	1) Bez combat mode / na intencji pomocy kliknij zwierzę → głaskanie, serce i polska kwestia. W combat mode / na intencji harm → cios, zwierzę ucieka albo oddaje. Prawy przycisk / intencja rozbrajania → popchnięcie; krowę przewraca. \
	2) Oswój psa kością (30% za pierwszym razem, +15% z każdą próbą), krowę pszenicą (25%, +15%), węża martwą myszą (75%), dowolne zwierzę lassem (złap z daleka, poczekaj aż wyląduje przy tobie i kliknij je jeszcze raz, 2 s). Każde karmienie z ręki daje dymek „je ci z ręki”, udane oswojenie dymek „oswojony”, a oględziny oswojonego „Wydaje się cieszyć na twój widok!”. Koty, lis i reszta pupili nie oswajają się jedzeniem, tylko lassem. Potem polecenia głosem („za mną”, „zostań”, „aport”, „udawaj trupa”, „atakuj”) i z menu pod Alt+klikiem. Rzuć przedmiot → pies przynosi. \
	3) Wydój krowę, kozę i owcę zlewką (różne mleka), ostrzyż owcę brzytwą, wsiądź na oswojoną krowę. \
	4) Nakarm kurę pszenicą → jajko; zapłodnione wykluwa się w pisklę, pisklę dorasta w kurę (ok. 2 min). Pisklę pingwina też dorasta. Królik wielkanocny znosi jajka-niespodzianki z ikoną. \
	5) Kot poluje na mysz, kociak żebrze o jedzenie, kot wchodzi do domku i wychodzi po 10–20 s; kot gracza wchodzi kliknięciem. Czapka na corgim. \
	6) Mysz gryzie kabel na gołym poszyciu, ser działa i mija; rozgnieć karalucha. Duch przejmuje mysz, karalucha i węża (wskaźnik combat mode w HUD, atak w combat mode i na intencji harm). \
	7) Leniwiec wspina się na sosnę, żółw chowa się w skorupie po ciosie, krab chodzi bokiem, wąż gryzie jadem. \
	8) Krowa mądrości mówi polskie wróżby, po pogłaskaniu znika. Spawner Tysona zamienia się w psa ochrony z polskim opisem."
	items = list(
		/mob/living/basic/pet/cat = 1,
		/mob/living/basic/pet/cat/kitten = 1,
		/obj/structure/cat_house = 1,
		/mob/living/basic/cow = 1,
		/mob/living/basic/goat = 1,
		/mob/living/basic/sheep = 1,
		/mob/living/basic/chicken = 2,
		/mob/living/basic/chick = 1,
		/mob/living/basic/turkey = 1,
		/mob/living/basic/rabbit/easter = 1,
		/mob/living/basic/pet/fox/docile = 1,
		/mob/living/basic/pet/penguin/baby = 1,
		/mob/living/basic/sloth = 1,
		/mob/living/basic/pet/hamster = 1,
		/mob/living/basic/lizard = 1,
		/mob/living/basic/crab = 1,
		/mob/living/basic/butterfly = 1,
		/mob/living/basic/snake = 1,
		/mob/living/basic/turtle = 1,
		/mob/living/basic/mouse = 3,
		/mob/living/basic/cockroach = 1,
		/mob/living/basic/mothroach = 1,
		/mob/living/basic/pet/gondola = 1,
		/mob/living/basic/cow/wisdom = 1,
		/obj/item/mob_lasso/antag/debug = 1,
		/obj/item/reagent_containers/glass/beaker = 1,
		/obj/item/razor = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/clothing/head/chefhat = 1,
		/obj/structure/flora/tree/pine = 1,
	)

/datum/test_chamber_kit/pr_613_pupile/setup(list/spawned, list/turfs, turf/center, mob/user)
	// Spawner Tysona usuwa się zaraz po podstawieniu psa i losuje rasę (corgi, mops, bulterier), więc ani on, ani te rasy
	// nie mogą być w items (test komory liczy sztuki każdego typu)
	new /mob/living/basic/pet/dog/corgi(center)
	new /mob/living/basic/pet/dog/pug(center)
	new /obj/structure/bed/dogbed/tyson(center)
	new /mob/living/basic/pet/dog/bullterrier/tyson(center)
	// Karma w zamkniętej skrzyni: leżąca na podłodze znika w pyskach zwierząt, zanim tester ją podniesie (krowa zjada pszenicę, pies kość)
	var/obj/structure/closet/crate/food_crate = new(center)
	food_crate.name = "skrzynia z karmą"
	new /obj/item/stack/sheet/bone(food_crate, 10)
	for(var/i in 1 to 10)
		new /obj/item/food/grown/wheat(food_crate)
	for(var/i in 1 to 3)
		new /obj/item/food/deadmouse(food_crate)
	for(var/i in 1 to 2)
		new /obj/item/food/grown/carrot(food_crate)
		new /obj/item/food/cheese(food_crate)

/datum/test_chamber_kit/pr_613_dzikie
	name = "Basic moby: dzikie zwierzęta"
	pr = "aq33/AquilaStation#613"
	description = "Zestaw: niedźwiedź, pancerz dla niedźwiedzia, nietoperz, pomidor zabójca, żaba, zdziczały kot, księżycorożec, 2 krasnale ogrodowe. Uwaga: atakują ciebie od razu, ale nie siebie nawzajem (wspólna frakcja nadana w zestawie). Nie zrzucaj razem z pupilami. Sprawdzaj w obu trybach sterowania. \
	1) Niedźwiedź goni i bije; kliknij go pancerzem bez combat mode / na intencji pomocy → zakłada pancerz. \
	2) Nietoperz lata i oddaje tylko zaatakowany (combat mode / intencja harm). \
	3) Żaba gryzie kosmicznymi narkotykami, pomidor zabójca atakuje. \
	4) Zdziczały kot atakuje, inne koty nie. \
	5) Księżycorożec zostawia za sobą kwiaty i atakuje. \
	6) Uderz krasnala → przywołuje inne krasnale, zapada się w ziemię i leczy; wejdź na niego boso → rana stopy. \
	7) Opętaj niedźwiedzia przez ducha (lub VV + ckey) → wskaźnik combat mode w HUD, cios w combat mode i na intencji harm."
	items = list(
		/mob/living/basic/bear = 1,
		/obj/item/bear_armor = 1,
		/mob/living/basic/bat = 1,
		/mob/living/basic/killer_tomato = 1,
		/mob/living/basic/frog = 1,
		/mob/living/basic/pet/cat/feral = 1,
		/mob/living/basic/cow/moonicorn = 1,
		/mob/living/basic/garden_gnome = 2,
	)

/datum/test_chamber_kit/pr_613_dzikie/setup(list/spawned, list/turfs, turf/center, mob/user)
	// Wrogie moby różnych rodzajów rzucają się na siebie nawzajem (księżycorożec na krasnale, niedźwiedź na pomidora) i po
	// kilku sekundach nie ma czego testować. Wspólna frakcja zostawia im za cel tylko testera.
	for(var/mob/living/basic/wild in spawned)
		wild.faction = list("test_chamber_wild")
