// aq33/AquilaStation#621 - gangi jak w Goonstation (punkty, teren, szafka, zrzuty, przywództwo) i złomiarze

/datum/test_chamber_kit/pr_621
	name = "PR 621: gangi i złomiarze"
	pr = "aq33/AquilaStation#621"
	description = "Zestaw robi z ciebie szefa nowego gangu i dodaje manekina jako gangstera. \
	1) Na starcie wybierz nazwę i mundur gangu (okienka). Akcja „Szafka gangu” → Postaw szafkę tutaj. Kliknij szafkę: sklep (broń biała, bez C4, Uzi, lasera i EMP), Odbierz mundur, Przelej punkty. \
	2) Wrzuć do szafki gotówkę (poza combat mode) → licznik prania rośnie, punkty przybywają co sekundę. Wrzuć pistolet → +300 pkt, butelkę pigułek → punkty za narkotyki. Uderz szafkę → sypią się kredyty, gang dostaje ostrzeżenie. \
	3) Pomaluj podłogę farbą gangu kilka kafli od szafki → +50 pkt; okno roli (przycisk Gang) pokazuje teren. Stań w pełnym mundurze na swoim terenie → alert „Duma gangu”, więcej zdrowia. \
	4) Skrzynię ze zrzutu dociągnij do szafki i otwórz → każdy członek +3000 pkt. Bez szafki obok skrzynia się nie otworzy. Podnieś torbę z łupem → +1000 pkt. \
	5) Zabij siebie (admin: aheal później) albo manekina-szefa: po 5 minutach (z szafką) inny członek przejmuje dowodzenie przy szafce. \
	6) Złomiarze: reklamatorem (poza combat mode) rozbierz ładowarkę → płytka i części. Połóż je na platformie i w terminalu skupu wyślij → punkty. Rozstaw nadajnik (użyj w ręce), a teleporter na statku złomiarzy przerzuci do niego (event Salvagers z panelu admina)."
	items = list(
		/obj/item/stack/spacecash/c1000 = 2,
		/obj/item/gun/ballistic/automatic/pistol = 1,
		/obj/item/storage/pill_bottle/zoom = 1,
		/obj/item/storage/backpack/duffelbag/gang_loot = 1,
		/mob/living/carbon/human = 1,
	)

/datum/test_chamber_kit/pr_621/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	if(!user?.mind)
		return
	var/datum/team/gang/G = new /datum/team/gang/clandestine
	if(!user.mind.has_antag_datum(/datum/antagonist/gang))
		user.mind.add_antag_datum(/datum/antagonist/gang/boss, G)
	var/datum/antagonist/gang/boss/boss = user.mind.has_antag_datum(/datum/antagonist/gang/boss)
	boss?.equip_gang()
	for(var/mob/living/carbon/human/dummy in spawned)
		dummy.mind_initialize()
		dummy.mind.add_antag_datum(/datum/antagonist/gang, boss?.gang || G)
	var/obj/structure/closet/crate/secure/weapon/gang_drop/crate = new(center)
	crate.unlock_time = world.time

// aq33/AquilaStation#621 - złomiarze jak w Goonstation
/datum/test_chamber_kit/pr_621_zlomiarze
	name = "PR 621: złomiarze"
	pr = "aq33/AquilaStation#621"
	description = "Zestaw robi z ciebie złomiarza z 3000 pkt i stawia terminal S.R.O.K.A. oraz punkt powrotu teleportera. 	1) Reklamatorem (poza combat mode) rozbierz ładowarkę → złom i złom elektroniczny; czas krótszy o 25%, bo jesteś złomiarzem. Użyj reklamatora w ręce → korba ładuje ogniwo. 	2) Urządzeniem dwukonstrukcyjnym rozłóż drugą ładowarkę → paczka maszyny. Przełącz urządzenie (użyj w ręce) i uderz paczkę na podłodze → maszyna wraca. 	3) Uderz terminal S.R.O.K.A. paczką, złomem albo telekryształem → terminal podaje cenę i otwiera okno z przedmiotem z ręki; „Sprzedaj” dodaje punkty. W tym samym oknie jest cel załogi i sklep w działach (Narzędzia, Broń, Ochrona, Zaopatrzenie). 	4) Załóż gogle S.A.V. → nad przedmiotami w pobliżu wiszą ceny. 	5) Odejdź kilka kroków i użyj teleportera ręcznego → po 6 s wracasz na punkt powrotu, ładunek ubywa; telekryształ go dokłada (najwyżej 5). 	6) Kliknij konsolę kapsuł desantowych → wybierz obszar okrętu, „Uzbrój start”, potem „START” → po 10–15 s lądujesz w kapsule na okręcie. 	7) Przycisk roli (lewy górny róg) → okno złomiarza z punktami i wynikami załogi."
	items = list(
		/obj/machinery/recharger = 2,
		/obj/item/salvage_reclaimer = 1,
		/obj/item/salvage_dualconstructor = 1,
		/obj/item/salvager_hand_tele = 1,
		/obj/item/clothing/glasses/salvager = 1,
		/obj/item/stack/telecrystal = 1,
		/obj/item/stack/scrap/plating = 1,
		/obj/machinery/salvager_trader = 1,
		/obj/machinery/computer/salvager_pod_launcher = 1,
	)

/datum/test_chamber_kit/pr_621_zlomiarze/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	new /obj/effect/landmark/salvager_teleport(center)
	if(!user?.mind)
		return
	var/datum/antagonist/pirate/salvager/S = get_salvager_datum(user)
	if(!S)
		S = user.mind.add_antag_datum(/datum/antagonist/pirate/salvager)
	S?.add_salvage_points(3000)
