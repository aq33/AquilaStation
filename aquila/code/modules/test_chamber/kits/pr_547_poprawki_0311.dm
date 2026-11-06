// aq33/AquilaStation#547 - poprawki z listy 3.11: biblioteka układów, drukarka komponentów, toksyny ze szlamu, malakser

/datum/test_chamber_kit/pr_547
	name = "PR 547: biblioteka układów, drukarka, oozeling, malakser"
	pr = "aq33/AquilaStation#547"
	description = "1) Biblioteka układów: nadaj układowi nazwę i przyłóż go do duplikatora modułów → oczekiwane: komunikat, że wzór trafił do twojej biblioteki, i kategoria „Moje układy” w oknie. Druk z tej kategorii pobiera materiały jak druk ze skanu. Ikona kosza usuwa wzór. Po restarcie serwera wzór nadal jest w „Moich układach”. \
	2) Drukarka komponentów: zbadaj w B+R węzeł z komponentami, otwórz okno drukarki i kliknij „Synchronizuj z B+R” → oczekiwane: nowe komponenty pojawiają się bez konsoli B+R obok drukarki. \
	3) Oozeling: wstrzyknij plazmę ze strzykawki do zielonego ekstraktu, wylej toksynę do zlewki i wstrzyknij człowiekowi co najmniej 4u → oczekiwane: po chwili zmienia rasę na galaretowatą albo oozelinga. \
	4) Malakser i młynek: włóż jedzenie do malaksera i włącz go, włóż zlewkę i składnik do młynka i zmiel → oczekiwane: obie maszyny przy pracy się trzęsą, ale nie zmieniają sprite'a na stary. \
	5) Kabura: przypnij kaburę detektywa do munduru, załóż go i kliknij mundur → oczekiwane: otwiera się schowek kabury z rewolwerem."
	items = list(
		/obj/item/integrated_circuit/loaded = 1,
		/obj/machinery/module_duplicator = 1,
		/obj/machinery/modular_fabricator/component_printer = 1,
		/obj/item/slime_extract/green = 1,
		/obj/item/reagent_containers/syringe/plasma = 1,
		/obj/item/reagent_containers/glass/beaker/large = 1,
		/obj/item/reagent_containers/syringe = 1,
		/obj/machinery/processor = 1,
		/obj/machinery/reagentgrinder = 1,
		/obj/item/clothing/accessory/holster/detective = 1,
		/obj/item/clothing/under/rank/security/detective = 1,
	)
