// Przywracanie treści NSV, bronie i amunicja (raport nsv_martwe_08, pkt 1-6)

/datum/test_chamber_kit/pr_nsvprzyw_bronie
	name = "NSV: Yamato, działa, kalibracja, Magneton, Sparrowhawk, worek prochu, flak"
	pr = "aq33/AquilaStation#657"
	description = "1) Yamato: na okręcie rozbierz działo pokładowe do ramy, włóż płytkę trzylufową i dokończ budowę według opisu ramy (examine); dodatkowe zapalniki i lufy są w zestawie. Gotowe działo ładuje 3 pociski i strzela salwą trzech, potem 7 s przerwy; w wyborze broni to osobna grupa „Trzylufowa artyleria okrętowa”. Płytka jest w Makrobalistyce i u Minsky'ego. 2) Badanie „Uzbrojenie okrętowe” (po Makrobalistyce i Amunicji kierowanej I, 10000 pkt) daje płytki wieżyczki Gaussa, podajnika, działa pokładowego, VLS i elektronikę spustową. White Rapids sprzedaje płytki Gaussa i działa, Minsky elektronikę spustową i VLS. 3) Moduł kalibracji: postaw obok rdzenia działa pokładowego. Examine pokazuje, jak długo trzyma kalibracja; po 15 minutach szarzeje i piszczy, multitool kalibruje go w 4 s. Skalibrowany: pociski dłużej się naprowadzają, działo szybciej podaje pocisk do zamka, bramki ładują się szybciej. 4) Magneton (450 obrażeń, naprowadzanie 2,5 s) do działa pokładowego. Sparrowhawk: przewieź wózkiem do VLS z zestawu, nie wejdzie do wyrzutni myśliwca; leci dalej i mocniej bije niż zwykła rakieta. Głowicę Sparrowhawka składa się w obudowie rakiety jak zwykłą. 5) Głodny worek prochu: kucharz zna przepis (worek prochu, burger, 5 j. radu), zestaw uczy go też ciebie. Karm go jedzeniem; uważaj, przy wzroście może zjeść karmiącego. 6) Flak: zawieś ramę PDC na ścianie, włóż płytkę flaku i części, załaduj magazynek flak. Na okręcie z flakiem (np. Atlantis) stojak strzela sam do wrogów w zasięgu 30."
	items = list(
		/obj/item/circuitboard/multibarrel_upgrade/_3 = 1,
		/obj/item/ship_weapon/parts/mac_barrel = 2,
		/obj/item/assembly/igniter = 2,
		/obj/item/circuitboard/machine/gauss_turret = 1,
		/obj/item/circuitboard/machine/gauss_dispenser = 1,
		/obj/item/circuitboard/machine/deck_turret = 1,
		/obj/item/circuitboard/machine/vls = 1,
		/obj/item/ship_weapon/parts/firing_electronics = 1,
		/obj/machinery/deck_turret/core = 1,
		/obj/machinery/deck_turret/calibrator = 1,
		/obj/item/circuitboard/machine/deck_gun/calibrator = 1,
		/obj/item/multitool = 1,
		/obj/item/ship_weapon/ammunition/naval_artillery/homing = 2,
		/obj/structure/munitions_trolley = 1,
		/obj/machinery/ship_weapon/vls = 1,
		/obj/item/ship_weapon/ammunition/missile/cruise = 2,
		/obj/item/ship_weapon/parts/missile/warhead/cruise = 1,
		/obj/item/ship_weapon/ammunition/missile/missile_casing = 1,
		/obj/item/powder_bag = 1,
		/obj/item/food/burger/plain = 3,
		/obj/item/reagent_containers/glass/bottle/radium = 1,
		/obj/item/wallframe/pdc_frame = 1,
		/obj/item/circuitboard/machine/pdc_mount/flak = 1,
		/obj/item/stock_parts/manipulator = 4,
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stock_parts/matter_bin = 3,
		/obj/item/ammo_box/magazine/nsv/flak = 2,
	)

/datum/test_chamber_kit/pr_nsvprzyw_bronie/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	user?.mind?.teach_crafting_recipe(/datum/crafting_recipe/hungrypowder)
