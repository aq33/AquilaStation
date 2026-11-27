// AQUILA - Ciekawostki z galaktyki: błahy, zabawny artykuł w kanale Wiadomości z Galaktyki (port z Baystation12 code/modules/economy/Events_Mundane.dm, /datum/event/trivial_news)
// Bay picks one of its fixed English trivia lines about its own trade destinations. The articles here are written anew
// in Polish for the NSV setting (Nanotrasen, Syndicate, our brands) with a random star system of our map as the place
// and a random name where a person is needed. No economy effect, like Bay.

/datum/round_event_control/aquila_hex_trivial_news
	name = "Ciekawostki z galaktyki"
	typepath = /datum/round_event/aquila_hex_news/trivial
	weight = 10
	max_occurrences = 3
	earliest_start = 5 MINUTES

/datum/round_event/aquila_hex_news/trivial
	author = "Kurier Kosmiczny"

/datum/round_event/aquila_hex_news/trivial/make_article()
	var/place = aquila_hex_news_place()
	var/person = random_unique_name(pick(MALE, FEMALE))
	switch(rand(1, 14))
		if(1)
			return list("Kot, który otwiera śluzy", "Mieszkaniec układu [place] twierdzi, że jego kot nauczył się obsługiwać śluzę. „Wychodzi, kiedy chce, i wraca, kiedy chce. Zupełnie jak przed wynalezieniem śluz” – mówi właściciel.")
		if(2)
			return list("Pierogi z karpia podzieliły krytyków", "Na targach kulinarnych w układzie [place] zaprezentowano pierogi z kosmicznym karpiem. Połowa krytyków chwali smak, druga połowa wciąż leży w ambulatorium.")
		if(3)
			return list("Rekord w jedzeniu Donk-Pocketów", "[person] z układu [place] pobił rekord sektora: 47 Donk-Pocketów w dziesięć minut. Nanotrasen przypomina, że Donk-Pockety należy przed jedzeniem podgrzać.")
		if(4)
			return list("Asystent odnaleziony po trzech latach", "Zaginiony przed trzema laty asystent odnalazł się w szafce technicznej stacji w układzie [place]. Twierdzi, że „tylko czekał na dostęp”.")
		if(5)
			return list("Kolejka do paczkomatu", "Kolejka do paczkomatu InPost w układzie [place] ma już trzysta metrów. Jak ustalił nasz reporter, wszyscy czekają na tę samą paczkę: zapasowy klucz do paczkomatu.")
		if(6)
			return list("Karp rozpoznaje twarze", "Naukowcy z układu [place] dowiedli, że kosmiczny karp rozpoznaje ludzkie twarze. „Niestety robi to głównie po to, żeby w nie ugryźć” – dodają.")
		if(7)
			return list("Hełm na taśmę wygrał konkurs", "Konkurs na najładniejszy hełm skafandra w układzie [place] wygrał hełm sklejony taśmą. Jury doceniło „surowość formy i odwagę materiałową”.")
		if(8)
			return list("Klaun sołtysem", "Klaun z układu [place] został wybrany na sołtysa pobliskiej kolonii. Jego pierwsza decyzja: obowiązkowa skórka od banana przy każdym wejściu.")
		if(9)
			return list("Dwugłowy corgi", "W układzie [place] urodził się dwugłowy corgi. Obie głowy domagają się osobnej miski i nie chcą się nią dzielić.")
		if(10)
			return list("Pół roku w złą stronę", "Kapitan frachtowca z układu [place] przez pół roku leciał w złą stronę, bo ktoś powiesił mapę gwiezdną do góry nogami. „Trochę się dziwiłem, że tej stacji wciąż nie widać” – przyznał.")
		if(11)
			return list("Kawa ważniejsza od reaktora", "Według ankiety Kuriera 73% załogantów floty uważa, że automat z kawą zasługuje na wyższy priorytet niż reaktor. Pozostałe 27% to inżynierowie.")
		if(12)
			return list("Najszybszy hot-dog w galaktyce", "Na stacji Orlen w układzie [place] padł rekord: hot-dog wydany w dwie sekundy. Klient wciąż nie wie, co właściwie zamówił.")
		if(13)
			return list("Najdłuższy wniosek Centrali", "Centrala ogłosiła wyniki konkursu na najdłuższy wniosek. Zwycięski formularz ma 412 stron, w tym dziewięć stron na wymagane pieczątki.")
		if(14)
			return list("Dudy w próżni", "Mieszkańcy układu [place] skarżą się na sąsiada, który od miesiąca ćwiczy grę na dudach w próżni. „Nie słychać, ale widać, i to jest gorsze” – mówią.")
