// AQUILA - Wiadomości z sektora: fabularny artykuł o sektorze (Nanotrasen, Syndykat, SolGov, Najeźdźcy z Tortugi, nasze firmy) w kanale Wiadomości z Galaktyki (port z CeladonSS13/Shiptest code/modules/events/news.dm)
// Shiptest posts one of two premade stories about its own factions and removes it from the list. Ours has a dozen
// stories written anew in Polish for the NSV sector; like Shiptest every story comes out at most once per round and
// the event stops spawning when none are left.

/datum/round_event_control/aquila_hex_news_report
	name = "Wiadomości z sektora"
	typepath = /datum/round_event/aquila_hex_news/report
	weight = 10
	max_occurrences = 3
	earliest_start = 5 MINUTES
	/// Indexes of stories already posted this round
	var/list/used_stories = list()

/datum/round_event_control/aquila_hex_news_report/canSpawnEvent(players_amt, gamemode)
	. = ..()
	if(. && length(used_stories) >= length(aquila_hex_sector_stories()))
		return FALSE

/// Stories of the sector news: list(title, body)
/proc/aquila_hex_sector_stories()
	var/static/list/stories = list(
		list("Syndykat zaprzecza", "Rzecznik Syndykatu zaprzeczył doniesieniom, jakoby jego flota stała za zniknięciem trzech frachtowców Nanotrasen. „Nasze okręty były wtedy na ćwiczeniach. Wszystkie. Jednocześnie. W tym samym miejscu” – oświadczył."),
		list("SolGov podnosi cła", "SolGov ogłosił nowe cła na towary z sektorów przygranicznych. Kupcy już zapowiadają podwyżki, a przemytnicy – rekordowy rok."),
		list("Promocja u piratów", "Najeźdźcy z Tortugi rozesłali ulotki z „promocją sezonową”: co trzeci abordaż gratis. Dowództwo floty przypomina, że abordaż nie jest usługą i nie przysługuje na niego reklamacja."),
		list("Kolejki do specjalistów", "Kosmiczny oddział NFZ poinformował, że średni czas oczekiwania na wizytę u ortopedy w sektorze wynosi już 47 lat świetlnych. Pacjentom zaleca się, by w międzyczasie nie łamać kości."),
		list("Fałszywi oficerowie", "Żandarmeria ostrzega przed oszustami podającymi się za oficerów floty, którzy sprzedają „awanse w promocji”. Prawdziwe awanse Nanotrasen wręcza wyłącznie po wypełnieniu formularza w trzech egzemplarzach."),
		list("Orlen na orbicie", "Orlen otworzył pierwszą stację paliw na orbicie gazowego olbrzyma. W ofercie plazma, hot-dogi i kawa, którą według pierwszych klientów da się pić nawet w próżni."),
		list("Punkty za przetrwanie", "Nanotrasen ogłosiło program lojalnościowy dla załóg okrętów NSV: punkty za każdą przeżytą zmianę. Za tysiąc punktów można odebrać kubek z logo korporacji. Kubki są już w drodze, ale kapsuła z nimi zaginęła."),
		list("Wspomnienia weterana", "Weteran floty NSV wspomina najcięższą bitwę swojej służby: „Rozkaz był prosty: nie dotykać czerwonego przycisku. Do dziś nie wiem, kto go dotknął, ale wiem, że już nie mamy tamtego hangaru”."),
		list("Rekrutacja Syndykatu", "Dowództwo Floty Syndykatu ruszyło z kampanią werbunkową pod hasłem „Czerwony ci do twarzy”. W pakiecie powitalnym: skafander, mapa pól minowych i ubezpieczenie, którego nikt jeszcze nie wykorzystał."),
		list("Kanapki sprzed wieków", "Badacze SolGov znaleźli w pasie asteroid wrak frachtowca wypełniony kanapkami sprzed dwustu lat. Wstępne badania wykazały, że kanapki są w lepszym stanie niż wrak."),
		list("Paczkomaty w próżni", "InPost uruchomił pierwsze paczkomaty w otwartej przestrzeni. Odbiór paczki wymaga skafandra, karty dostępu i dużo cierpliwości."),
		list("Akcja ratunkowa", "Załoga jednego z okrętów NSV uratowała czterdziestu kolonistów z uszkodzonej stacji górniczej. Koloniści podziękowali i od razu zapytali, czy na pokładzie jest automat z kawą."),
	)
	return stories

/datum/round_event/aquila_hex_news/report
	author = "Serwis Informacyjny Sektora"

/datum/round_event/aquila_hex_news/report/make_article()
	var/list/stories = aquila_hex_sector_stories()
	var/datum/round_event_control/aquila_hex_news_report/report_control = control
	var/list/free = list()
	for(var/i in 1 to length(stories))
		if(!istype(report_control) || !(i in report_control.used_stories))
			free += i
	if(!length(free))
		return null
	var/index = pick(free)
	if(istype(report_control))
		report_control.used_stories += index
	return stories[index]
