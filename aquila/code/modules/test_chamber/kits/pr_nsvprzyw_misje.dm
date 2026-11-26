// Przywracanie treści NSV, punkt 10: misje od handlarzy i reputacja u frakcji stacji (trader_missions.dm, trader_reputation.dm)

/datum/test_chamber_kit/pr_nsvprzyw_misje
	name = "Misje od handlarzy i reputacja"
	pr = "aq33/AquilaStation#657"
	description = "Zestaw: zaplombowana skrzynia (bez misji), torpeda transportowa, łom, skrzynia amunicji z nagrody. Zrzucenie zestawu daje +50 reputacji u frakcji stacji w układzie okrętu (ta sama reputacja spada za ostrzał cywilów). 1) Okno handlarza (DRADIS, kliknij stację): sekcja „Misje dla okrętu” pokazuje reputację (poziom, zniżka, oferty specjalne) i 2 oferty; ceny towaru po zrzuceniu zestawu są niższe o 10%, a zakup zabiera z budżetu tę niższą cenę. Stacja Syndykatu misji nie zleca. 2) Przyjmij misje (karta z dostępem zaopatrzenia albo dowództwa): najwyżej 3 naraz, osobno od zleceń działów. Cel każdej misji (oprócz nagrody za okręty) świeci na mapie nawigacji jak cel misji trybu. 3) Nagroda za okręty: zniszcz wrogie okręty w układzie okrętu, licznik w oknie rośnie. Oczyszczenie układu: na zaznaczonym kaflu czeka flota, po jej rozbiciu misja jest wykonana. Obrona układu: zostań przy stacji, fale przychodzą po kolei, odlot w trakcie kończy misję porażką. Rozpoznanie trasy: wykonane po skoku na zaznaczony kafel. 4) Ładunek plombowany: kapsuła przywozi skrzynie i darmową torpedę; wyślij je torpedą z konsoli DRADIS zaopatrzenia do stacji docelowej. Skrzynia otwarta łomem (spróbuj na tej z zestawu: pyta o potwierdzenie) daje ćwierć stawki. 5) Po wykonaniu: kredyty w budżecie zaopatrzenia, kapsuła ze skrzynią amunicji (misje bojowe), reputacja rośnie; anulowanie albo porażka obniża reputację. Głowica (rzadka) jest w zwykłej grze najwyżej raz na rundę: otwarcie albo wyrzucenie skrzyni w kosmos kończy misję bez kary."
	items = list(
		/obj/structure/closet/crate/large/freight_objective/aq_sealed = 1,
		/obj/item/ship_weapon/ammunition/torpedo/freight = 1,
		/obj/item/crowbar = 1,
		/obj/structure/closet/crate/nsv_mission_rewards = 1,
	)

/datum/test_chamber_kit/pr_nsvprzyw_misje/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
	var/count = 0
	for(var/datum/trader/T as anything in SSstar_system.traders)
		var/obj/structure/overmap/trader/station = T.current_location
		if(!QDELETED(station) && ship && station.current_system == ship.current_system)
			T.aq_adjust_reputation(50)
			count++
	if(count)
		to_chat(user, "<span class='notice'>Reputacja +50 u frakcji stacji w układzie okrętu (stacji: [count]).</span>")
	else
		to_chat(user, "<span class='warning'>W układzie okrętu nie ma stacji handlowej: reputację sprawdzisz po skoku do stacji.</span>")
