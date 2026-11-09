// aq33/AquilaStation#602 - rework drużyn

/datum/test_chamber_kit/pr_602
	name = "Rework drużyn (konsola XO, pager z mapą, skrzynie, rozkazy, znaczniki)"
	pr = "aq33/AquilaStation#602"
	description = "Zestaw robi cię dowódcą drużyny Alpha z pagerem w ręce i dokłada dwóch członków bez gracza (medyk i inżynier). Obok stoją automat drużyny i konsola drużyn XO. \
	1) Pager: użyj w ręce → okno z członkami, zadaniem i wiadomościami; zakładka Mapa pokazuje pokład z kropkami drużyny. Wybierz „Obrona” i kliknij mapę → znacznik na mapie, w świecie (nad oświetleniem) i komunikat na ekranie. \
	2) Rozkaz: „Wydaj rozkaz” w pagerze albo akcja z megafonem → tekst w lewym górnym rogu z twoim portretem; drugi rozkaz przed upływem 30 s → odmowa (negatyw). \
	3) Akcja „Znacznik taktyczny” → menu, klik w widoczne pole → znacznik; klik w pole poza ekranem → „Możesz oznaczyć tylko pole, które widzisz” (negatyw). \
	4) Automat: okno pokazuje tylko zestaw dowódcy; Wydaj → skrzynia w ręce (pancerz, skafander obcisły, hełmy, megafon). Drugie wydanie przed zwrotem → odmowa (negatyw). Wyjmij pancerz, oddaj skrzynię (klik skrzynią w automat) → brakuje 1 rzeczy; oddaj pancerz → wypożyczenie zamknięte. \
	5) Konsola: zakładka Drużyny → Alpha z trzema osobami, ich stan (członkowie bez gracza mają „Bez kontaktu”), zestaw i braki; zmień funkcję medyka na żołnierza → ikona nad postacią się zmienia; przenieś inżyniera do Bravo. Załóż pancerz drużyny i kliknij kamerę przy sobie → widok wokół ciebie. Zakładka Sprzęt → twoje wypożyczenie. \
	6) Konsola: guziki Dostęp / Broń / Przydział zmieniają napis po jednym kliknięciu, Smycz drukuje jedną smycz. \
	7) Postaw znacznik i odejdź tak, żeby zniknął z ekranu → przy krawędzi ekranu wskaźnik z ikoną znacznika, strzałką w jego stronę i odległością; podejdź → wskaźnik znika. \
	8) Kliknij pagerem w PDA → pager w PDA, przycisk „Pager drużyny” otwiera jego okno, rozkaz dalej pokazuje się na ekranie; Alt-klik na PDA wyjmuje pager (długopis wyjmuje Ctrl-klik). \
	9) Zabij się (np. ghostuj z ciała po śmierci od pistoletu): po 10 s dowodzenie przejmuje inny członek drużyny, a drużyna dostaje komunikat na ekranie."
	items = list(
		/obj/machinery/squad_vendor = 1,
		/obj/machinery/computer/squad_manager = 1,
		/obj/item/clothing/suit/ship/squad = 1,
		/obj/item/modular_computer/tablet/pda = 1,
	)

/datum/test_chamber_kit/pr_602/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/mob/living/carbon/human/H = user
	var/datum/squad/alpha = GLOB.squad_manager.get_squad("Alpha")
	if(!istype(H) || !alpha)
		to_chat(user, "<span class='warning'>Musisz być człowiekiem w komorze, żeby dołączyć do drużyny. Sprzęt i tak leży na arenie.</span>")
		return
	if(H.squad != alpha)
		if(H.squad)
			H.squad.remove_member(H)
		alpha.add_member(H)
	alpha.set_leader(H)
	H.put_in_hands(new /obj/item/squad_pager(get_turf(H), alpha))
	var/list/positions = list(SQUAD_POSITION_MEDIC, SQUAD_POSITION_ENGINEER)
	for(var/i in 1 to 2)
		var/mob/living/carbon/human/member = new(turfs[min(length(turfs), 4 + i)])
		member.equipOutfit(/datum/outfit/job/assistant)
		member.squad_position = positions[i]
		alpha.add_member(member)
		if(i == 1)
			member.adjustBruteLoss(40)
		spawned += member
