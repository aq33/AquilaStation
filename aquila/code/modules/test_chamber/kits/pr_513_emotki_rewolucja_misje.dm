/datum/test_chamber_kit/pr_513
	name = "Koło emotek, zlecenia amunicji, rewolucja, wybór misji"
	pr = "aq33/AquilaStation#513"
	description = "Zestaw: dwóch ludzi (pierwszy to przywódca rewolucji), konsola łączności, zapasowa karta kapitana, konsola zleceń cargo z dwoma zleceniami amunicji i części do nich. Na serwerze (nie w CI) zestaw otwiera też wybór misji, jak na starcie rundy. \
	1) Koło emotek: przycisk z uśmiechem w rzędzie akcji (lewy górny róg). Pusty otwiera Panel emotek z podpowiedzią → oznacz gwiazdką 13 emotek, kliknij przycisk jeszcze raz → oczekiwane: koło ma 12 emotek plus pole Panelu emotek (13. się nie mieści, negatyw), emotka z koła się wykonuje, po reconnecie wybór zostaje. \
	2) Rewolucja: przejmij przywódcę. Czerwony przycisk R po lewej stronie ekranu → oczekiwane: panel z miejscami (twoje z obwódką), znacznikiem limitu, zablokowanymi miejscami i licznikami towarzysze / limit, przywódcy, szefowie. Najedź na miejsca → tooltipy. \
	3) Limit: VV drużyny rewolucji (z panelu antagonistów) ustaw rev_cap = 1 → oczekiwane: licznik pokazuje 1 wolne miejsce mniej; przemowa przywódcy na celu z klientem (drugi gracz albo admin w ciele drugiego człowieka; wymaga drugiego gracza) działa raz, po zapełnieniu limitu przemowa odmawia (negatyw). Dodanie rewolucjonisty przez Antag Panel omija limit. \
	4) Zlecenia amunicji: konsola zleceń cargo → oczekiwane: zlecenia „Elektronika spustowa” (2 szt.) i „Tace załadowcze” (2 szt.) z opisem, nagrodą i postępem 0/2. Leżące obok elektronika spustowa ×2 i tace ×2 pasują do wanted_types; pełne zaliczenie wymaga wysłania ich promem cargo (wymaga lotu promu), a bez wysyłki zlecenie zostaje otwarte (negatyw: nie zalicza się samo od leżenia). \
	5) Wybór misji: zaloguj się kartą kapitana w konsoli łączności, zakładka Status misji → oczekiwane: trzy różne misje (pierwsza to obecna), po wyborze ogłoszenie „Kapitan … przyjął misję” i odprawa. Bez karty kapitana zakładka nie pokazuje wyboru (negatyw). Jeśli misja była już wybrana albo tryb wymuszony przez admina, zakładka pokazuje tylko status; wtedy zestaw nie otwiera wyboru drugi raz."
	items = list(
		/mob/living/carbon/human = 2,
		/obj/machinery/computer/communications = 1,
		/obj/machinery/computer/bounty = 1,
		/obj/item/card/id/captains_spare = 1,
		/obj/item/ship_weapon/parts/firing_electronics = 2,
		/obj/item/ship_weapon/parts/loading_tray = 2,
	)

/datum/test_chamber_kit/pr_513/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/mob/living/carbon/human/leader = locate() in spawned
	if(leader)
		leader.mind_initialize()
		leader.mind.add_antag_datum(/datum/antagonist/rev/head)
		leader.name = "przywódca testowy"
		leader.real_name = leader.name
	// Zlecenia amunicji w konsoli cargo; konsola losuje resztę listy dopiero przy pierwszym otwarciu, a niepusta lista jej to wyłącza
#ifndef UNIT_TESTS
	if(!length(GLOB.bounties_list))
		setup_bounties()
#endif
	try_add_bounty(new /datum/bounty/item/munitions/firing_electronics)
	try_add_bounty(new /datum/bounty/item/munitions/loading_trays)
#ifndef UNIT_TESTS
	// Wybór misji normalnie trwa tylko do pierwszego skoku FTL; otwieramy go ponownie, żeby dało się go sprawdzić
	var/datum/controller/subsystem/overmap_mode/omode = SSovermap_mode
	if(user && omode.mode && !omode.forced_mode && !omode.mission_choice_pending)
		// Wstrzymuje cele misji całego statku, więc tylko po potwierdzeniu
		if(tgui_alert(user, "Otworzyć ponownie wybór misji dla całego statku? Do wyboru kapitana cele misji będą wstrzymane.", "Komora testowa", list("Tak", "Nie")) != "Tak")
			return
		omode.roll_mission_choices()
		if(length(omode.mission_choices) >= 2)
			omode.mission_choice_pending = TRUE
			if(user)
				to_chat(user, span_notice("Wybór misji został otwarty. Kapitan wybiera w konsoli łączności (Status misji); do wyboru cele misji i przypomnienia są wstrzymane."))
#endif
