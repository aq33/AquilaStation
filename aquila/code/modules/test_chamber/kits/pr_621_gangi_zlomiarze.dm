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
		/obj/item/salvage_reclaimer = 1,
		/obj/item/salvage_beacon = 1,
		/obj/machinery/recharger = 1,
		/obj/machinery/piratepad = 1,
		/obj/machinery/computer/piratepad_control/salvage = 1,
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
	for(var/obj/machinery/computer/piratepad_control/salvage/console in spawned)
		for(var/obj/machinery/piratepad/pad in spawned)
			console.set_pad(pad)
