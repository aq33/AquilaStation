/datum/test_chamber_kit/pr_487
	name = "PR 487: rynek ekstraktów i kompresor szlamów"
	pr = "aq33/AquilaStation#487"
	description = "Zestaw dokłada 10000 punktów xenobio, 5000 kr na koncie karty naukowca (leży obok) i torbę z 3 szarymi, 1 pomarańczowym i 1 złotym ekstraktem. Pady są podpięte do jednej konsoli rynku. \
	1) Konsola rynku, zakładka Ceny: zapisz cenę szarego i pomarańczowego → oczekiwane: lista kolorów z cenami i współczynnikami. \
	2) Wysyp torbę z ekstraktami na pad rynku (klik torbą) → oczekiwane: komunikat o sprzedaży 5 rdzeni i punktach xenobio; w Cenach cena szarego (sprzedane 3 szt.) spadła, a ceny nieruszonych kolorów lekko wzrosły. Negatyw: współczynnik ceny szarego nigdy nie schodzi poniżej 0,1 ceny bazowej, nawet po kolejnych sprzedażach (zrób kilka szarych przez Spawn). \
	3) Sklep w konsoli: kup dowolny przedmiot → oczekiwane: punkty spadają o jego koszt (start 10000). \
	4) Pad zamówień, klik z kartą naukowca w ręce → oczekiwane: menu wyboru ekstraktu, ilość i nagroda; zamów 2 szare z nagrodą 100 → saldo karty spada o 100, konsola ogłasza nowe zamówienie. Negatyw: klik bez karty → „Nie wykryto karty ID”, klik zapasową kartą kapitana (bez konta) → „Ta karta nie ma przypisanego konta”. \
	5) Weź szary ekstrakt (Spawn /obj/item/slime_extract/grey) i dotknij nim pada rynku → oczekiwane: wybór „oddaj do zamówienia / sprzedaj”; oddaj dwa → zamówienie gotowe. Klik padem zamówień kartą naukowca → wypada pudełko z 2 szarymi, punkty rynku rosną o nagrodę ×3. \
	6) Kompresor: kliknij, wybierz burning i blue, przeciągnij na niego dorosłego niebieskiego i dwa dorosłe pomarańczowe szlamy (leżą na jednym polu z torbą) → oczekiwane: po 40 s wypada crossbreed burning blue. \
	7) Negatyw kompresora: przeciągnij młodego pomarańczowego → „jest za mały, potrzebne są dorosłe szlamy”; przeciągnij dorosłego czerwonego (zły kolor) → „Przepis nie potrzebuje już szlama red”; Alt-klik anuluje przepis i wyrzuca szlamy. \
	8) Strzykawka losowej mutacji wbita w szlama → kolor szlama się zmienia."
	items = list(
		/obj/machinery/slime_market_pad = 1,
		/obj/machinery/computer/slime_market = 1,
		/obj/machinery/slime_extract_requestor = 1,
		/obj/machinery/slime_compressor = 1,
		/obj/item/slime_mutation_syringe/random_color = 1,
		/obj/item/slime_scanner = 1,
		/obj/item/card/id/captains_spare = 1,
	)

/datum/test_chamber_kit/pr_487/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/turf/drop = turfs[min(length(items) + 1, length(turfs))]
	var/obj/item/storage/bag/bio/bag = new(drop) // tu, bo test komory liczy podtypy z items
	for(var/extract_type in list(/obj/item/slime_extract/grey, /obj/item/slime_extract/grey, /obj/item/slime_extract/grey, /obj/item/slime_extract/orange, /obj/item/slime_extract/gold))
		new extract_type(bag)
	new /mob/living/simple_animal/slime(drop, "blue", TRUE)
	new /mob/living/simple_animal/slime(drop, "orange", TRUE)
	new /mob/living/simple_animal/slime(drop, "orange", TRUE)
	new /mob/living/simple_animal/slime(drop, "orange", FALSE)
	new /mob/living/simple_animal/slime(drop, "red", TRUE) // zły kolor do odrzucenia przez kompresor
	for(var/mob/living/simple_animal/slime/slime in drop)
		slime.docile = TRUE
	GLOB.slime_market.points += 10000
	// Karta z kontem do pada zamówień (zapasowa karta kapitana celowo zostaje bez konta, jako negatyw)
	var/obj/item/card/id/job/scientist/buyer_card = new(drop)
	buyer_card.registered_name = "Naukowiec Testowy"
	buyer_card.update_label()
	var/datum/bank_account/buyer_account = SSeconomy.get_dep_account(ACCOUNT_CIV)
	if(buyer_account)
		buyer_card.registered_account = buyer_account
		buyer_account.bank_cards += buyer_card
		buyer_account.adjust_money(5000)
