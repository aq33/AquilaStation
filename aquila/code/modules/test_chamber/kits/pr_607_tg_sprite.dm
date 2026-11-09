// aq33/AquilaStation#607 - sprite'y z tg, hardsuity Orlenu i zespołu urazowego, tablica Żandarmerii, SI Claude, urządzenia na ścianach

/datum/test_chamber_kit/pr_607
	name = "Sprite'y z tg, hardsuity, SI Claude, ściany"
	pr = "aq33/AquilaStation#607"
	description = "1) Maszyny: włącz mikrofalówkę z jedzeniem (animowana ramka, świecenie w ciemności), wrzuć coś do gibbera i uruchom (lampki, krew), zagraj w jukeboxie, pociągnij jednorękiego bandytę, otwórz condimaster i limbgrower śrubokrętem. \
	2) Boty: medibot na podłodze (koła, lampka) i w trakcie leczenia rannej małpy, floorbot, cleanbot, secbot. Zbuduj medibota z apteczki brute (wygląd skrzynki). \
	3) Przedmioty: plecaki i torby na plecach i w rękach, skrzynki narzędziowe, wytłaczanka (wyjmij jajka), pudełko pączków, pojemnik na pigułki, pudełka amunicji, RPD i spryskiwacz na pasku, wiadro z wodą (nakładka) i na głowie, książki, księga kapelana (wybór wyglądu: Kojiki), rośliny doniczkowe, napoje w szklankach (nalej mleko i sok pomarańczowy). \
	4) Hardsuity: załóż inżynieryjny, atmosferyki i CE (barwy Orlenu), Ordynatora (czerwony hełm) i zespołu urazowego; włącz lampę hełmu (stan on). Spróbuj na postaci z nogami digitigrade (jaszczur): nogi zwykłe, bez starego sprite'a. Szafa zespołu urazowego wydaje skafander. \
	5) Tablica Żandarmerii na ścianie. \
	6) SI: w preferencjach wybierz wygląd rdzenia Claude, zostań SI (animacja), zabij rdzeń (ekran NO TOKENS). \
	7) Ściany: zawieś z ramki newscaster (ma trafić na ścianę przy tobie, w każdym kierunku), sprawdź w komorze rząd urządzeń na ścianie (zestaw aq33/AquilaStation#469) i na mapie włączniki, interkomy, gaśnice i szafkę na topór na ścianach bocznych."
	items = list(
		/obj/machinery/microwave = 1,
		/obj/machinery/gibber = 1,
		/obj/machinery/jukebox = 1,
		/obj/machinery/computer/slot_machine = 1,
		/obj/machinery/chem_master/condimaster = 1,
		/obj/machinery/limbgrower = 1,
		/obj/machinery/food_cart = 1,
		/obj/item/food/meat/slab = 2,
		/mob/living/simple_animal/bot/medbot = 1,
		/mob/living/simple_animal/bot/floorbot = 1,
		/mob/living/simple_animal/bot/cleanbot = 1,
		/mob/living/simple_animal/bot/secbot = 1,
		/mob/living/carbon/monkey = 1,
		/obj/item/storage/firstaid/brute = 1,
		/obj/item/healthanalyzer = 1,
		/obj/item/bodypart/r_arm/robot = 1,
		/obj/item/storage/backpack = 1,
		/obj/item/storage/backpack/satchel = 1,
		/obj/item/storage/backpack/duffelbag = 1,
		/obj/item/storage/toolbox/mechanical = 1,
		/obj/item/storage/toolbox/electrical = 1,
		/obj/item/storage/fancy/egg_box = 1,
		/obj/item/storage/fancy/donut_box = 1,
		/obj/item/storage/pill_bottle = 1,
		/obj/item/ammo_box/c9mm = 1,
		/obj/item/ammo_box/c45 = 1,
		/obj/item/pipe_dispenser = 1,
		/obj/item/reagent_containers/spray/cleaner = 1,
		/obj/item/reagent_containers/glass/bucket = 1,
		/obj/item/storage/belt/utility = 1,
		/obj/item/book/manual/wiki/engineering_guide = 1,
		/obj/item/storage/book/bible = 1,
		/obj/item/kirbyplants/random = 2,
		/obj/item/reagent_containers/food/drinks/drinkingglass = 3,
		/obj/item/reagent_containers/food/condiment/milk = 1,
		/obj/item/reagent_containers/food/drinks/bottle/orangejuice = 1,
		/obj/item/clothing/suit/space/hardsuit/engine = 1,
		/obj/item/clothing/suit/space/hardsuit/engine/atmos = 1,
		/obj/item/clothing/suit/space/hardsuit/engine/elite = 1,
		/obj/item/clothing/suit/space/hardsuit/medical/cmo = 1,
		/obj/machinery/suit_storage_unit/medical/trauma = 1,
		/obj/item/wallframe/newscaster = 1,
		/obj/item/screwdriver = 1,
	)
