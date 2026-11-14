/datum/test_chamber_kit/pr_637
	name = "Tłumacz na żywo, czip u obu stron"
	pr = "aq33/AquilaStation#637"
	description = "Potrzebne dwie osoby i DEEPL_API_KEY w configu: jedna z językiem English w preferencjach (obcokrajowiec), druga z polskim. \
		Bez drugiego gracza obcokrajowca da się zrobić przez VV procką aq_make_foreigner() na swojej postaci. \
		Postacie z komory nie dostają czipów z pracy: włóżcie czipy z zestawu do słuchawek z zestawu i załóżcie je (albo weźcie tłumacze kieszonkowe). Mówcie za każdym razem nowe zdanie, bo powtórka idzie z pamięci tłumaczeń od razu przetłumaczona. \
		1. Bez tłumacza po żadnej stronie: obaj słyszą tylko bełkot drugiej strony. \
		2. Tłumacz tylko u Polaka: Polak od razu widzi bełkot z „…” w czacie i w dymku, a po chwili bełkot przechodzi animacją w polskie tłumaczenie. Obcokrajowiec dalej słyszy bełkot Polaka. Nad obcokrajowcem nie ma „…”, jego mowa wychodzi od razu. \
		3. Tłumacz tylko u obcokrajowca: on dostaje polską mowę po angielsku tak samo (bełkot, potem tłumaczenie), a Polak słyszy jego bełkot. \
		4. To samo przez radio (;) i szeptem (#). Tłumaczenie ma zostać w historii czatu po przełączeniu karty i po odświeżeniu panelu. \
		5. OOC w obie strony bez czipów: odbiorca od razu widzi oryginał z „…”, potem tłumaczenie. Wysłanie OOC nie zatrzymuje gry autorowi. \
		6. Postać z pracy (dołączenie do rundy) ma czip w słuchawkach od startu, cyborg i SI rozumieją obie strony bez słuchawek. \
		7. Bez klucza: słuchacz z tłumaczem od razu dostaje oryginał, bez bełkotu i „…”. Z błędnym kluczem: bełkot przechodzi w oryginał, bez zawieszonych kropek."
	items = list(
		/obj/item/aquila_translator/chip = 2,
		/obj/item/aquila_translator = 2,
		/obj/item/radio/headset = 2,
		/obj/item/multitool = 1,
	)
