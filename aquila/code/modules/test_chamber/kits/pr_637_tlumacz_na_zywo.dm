/datum/test_chamber_kit/pr_637
	name = "Tłumacz na żywo"
	pr = "aq33/AquilaStation#637"
	description = "Potrzebne dwie osoby i DEEPL_API_KEY w configu: jedna z językiem English w preferencjach (obcokrajowiec), druga z polskim. \
		Bez drugiego gracza obcokrajowca da się zrobić przez VV procką aq_make_foreigner() na swojej postaci. \
		1. Obcokrajowiec bierze tłumacza kieszonkowego z zestawu. Polak mówi nowe zdanie (nie powtarzaj, powtórka idzie z pamięci od razu). \
		Obcokrajowiec od razu widzi polski oryginał z „…” w czacie i w dymku, a po chwili linijka zmienia się w angielską z animacją, dymek też. \
		2. To samo przez radio (;) i szeptem (#). Tłumaczenie ma zostać w historii czatu po przełączeniu karty i po odświeżeniu panelu. \
		3. Obcokrajowiec mówi nowe zdanie: nad jego głową wisi „…”, aż wyjdzie polska wypowiedź, a wtedy „…” znika. \
		4. OOC w obie strony: odbiorca od razu widzi oryginał z „…”, potem tłumaczenie. Wysłanie OOC nie zatrzymuje gry autorowi. \
		5. Bez klucza (albo z błędnym): oryginał bez „…” i bez zawieszonych kropek."
	items = list(
		/obj/item/aquila_translator = 2,
		/obj/item/radio/headset = 2,
	)
