/datum/test_chamber_kit/pr_611
	name = "PR 611: drzewko R&D, automat ekstraktów, gablota DNA, zlecenia, analizator"
	pr = "aq33/AquilaStation#611"
	description = "Karta naukowca z 2000 kr leży obok, w torbie bio są 3 szare i 1 złoty ekstrakt, w pudełku iniektory DNA. \
	1) Konsola R&D: widać drzewo z liniami; przeciągnij tło (przesuwa), kółko myszy (zoom), przycisk „Pokaż całe drzewo”. Kliknij węzeł → panel z prawej z „Zbadaj” i listami Wymaga/Odblokowuje; kliknięcie pozycji z listy centruje ją. Wpisz „laser” w wyszukiwarkę → reszta węzłów przygasa, Enter centruje pierwszy. Tablet z programem R&D: to samo drzewo w wąskim oknie. \
	2) Konsola zaopatrzenia: ikony paczek są duże (64 px), ceny i nazwy czytelne. \
	3) Automat ekstraktów: kliknij go torbą bio z kartą naukowca w ręce → „Wystawiasz na sprzedaż ekstrakty”. Okno: przy szarym ekstrakcie lista reakcji (aktywacja, wynik, opis). Ustaw cenę szarego na 100. Kup jeden → ekstrakt w ręce, saldo karty −100. Negatyw: zapasowa karta kapitana (bez konta) → „Nie wykryto karty z kontem”; zwykły asystent bez dostępu xenobiologii nie wystawi ekstraktu („tylko xenobiolodzy”). \
	4) Gablota DNA: włóż iniektory z pudełka → w oknie (widok listy) pod nazwą „Daje: …” z opisem i niestabilnością; w widoku kafelków to samo w podpowiedzi. Zlewki nie przyjmuje. \
	5) Konsola zgłoszeń: „Zlecenia na statku” → lista zleceń CentComu i wspólnych, filtr po dziale, przy każdym „oddaj: …”. Wróć. \
	6) Analizator zdrowia (zaawansowany) na człowieku z zestawu (ma złamaną lewą nogę i ciętą ranę prawej ręki): lewa noga zabarwiona z podpisem „Złamanie”, ręka „Cięcie”; w oknie Zmysły, temperatura z °F, zmęczenie, aktywność mózgu. Drugi człowiek ma Maskaradę i mało krwi → okno pokazuje 560 cl, bez „Niski poziom krwi”. Sprawdź w combat mode i na intencjach: alt-klik analizatora przełącza tryb tekstowy."
	items = list(
		/obj/machinery/computer/rdconsole/core = 1,
		/obj/machinery/computer/cargo = 1,
		/obj/machinery/slime_extract_requestor = 1,
		/obj/machinery/smartfridge/genetics = 1,
		/obj/machinery/requests_console = 1,
		/obj/item/healthanalyzer/advanced = 1,
		/obj/item/card/id/captains_spare = 1,
		/obj/item/reagent_containers/glass/beaker = 1,
		/obj/item/storage/box/injectors = 1,
	)

/datum/test_chamber_kit/pr_611/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/turf/drop = turfs[min(length(items) + 1, length(turfs))]
	var/obj/item/storage/bag/bio/bag = new(drop)
	for(var/extract_type in list(/obj/item/slime_extract/grey, /obj/item/slime_extract/grey, /obj/item/slime_extract/grey, /obj/item/slime_extract/gold))
		new extract_type(bag)
	var/obj/item/card/id/job/scientist/buyer_card = new(drop)
	buyer_card.registered_name = "Naukowiec Testowy"
	buyer_card.update_label()
	var/datum/bank_account/buyer_account = new("Naukowiec Testowy", SSjob.GetJobType(/datum/job/scientist))
	buyer_account.adjust_money(2000)
	buyer_card.registered_account = buyer_account
	buyer_account.bank_cards += buyer_card

	var/mob/living/carbon/human/wounded = new(drop)
	wounded.real_name = "Ranny testowy"
	wounded.name = wounded.real_name
	var/datum/wound/blunt/fracture = new /datum/wound/blunt/fracture()
	fracture.apply_wound(wounded.get_bodypart(BODY_ZONE_L_LEG), silent = TRUE)
	var/datum/wound/slash/deep/cut = new()
	cut.apply_wound(wounded.get_bodypart(BODY_ZONE_R_ARM), silent = TRUE)

	var/mob/living/carbon/human/vampire = new(drop)
	vampire.real_name = "Wampir testowy"
	vampire.name = vampire.real_name
	vampire.blood_volume = 250
	ADD_TRAIT(vampire, TRAIT_MASQUERADE, "test_chamber")
