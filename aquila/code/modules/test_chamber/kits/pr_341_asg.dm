// aq33/AquilaStation#341 - zabawki: kulki ASG zamiast strzałek Donksoft, chaingun na kulki dla mechów

/datum/test_chamber_kit/pr_341
	name = "PR 341: kulki ASG i chaingun Ratat"
	pr = "aq33/AquilaStation#341"
	description = "Pistolet Donksoft strzela plastikowymi kulkami (nowy sprite i polska nazwa, wersja riot to metalowa kulka). Wyjmuj kulki z granatu na kulki - \
	sprite ma się zmieniać w 4 stopniach aż do pustego. Automat Donksoft: wszystkie produkty mają ikonki, repliki hełmów ERT w ofercie, skafandry ERT i chaingun w premium, \
	stroje i balon Syndykatu w kontrabandzie, cena 100. Zamontuj chaingun LCG-4-BB \"Ratat\" w Gygaksie (klik sprzętem w mecha) i postrzelaj - ładuje się z baterii mecha. \
	Disabler mecha strzela szybciej (cooldown 3)."
	items = list(
		/obj/item/gun/ballistic/automatic/toy/pistol/unrestricted = 1,
		/obj/item/ammo_box/foambox = 1,
		/obj/item/ammo_box/foambox/riot = 1,
		/obj/machinery/vending/donksofttoyvendor = 1,
		/obj/mecha/combat/gygax = 1,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/BBchaingun = 1,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/disabler = 1,
		/obj/item/clothing/head/ertsecurityfake = 1,
		/obj/item/clothing/suit/ertsecurityfake = 1,
	)
