// AQUILA - Wiadomości ze świata: zwykły artykuł (nauka, wybory, dymisja, nekrolog, wyprzedaż, premiera) w kanale Wiadomości z Galaktyki (port z Baystation12 code/modules/economy/Events_Mundane.dm, /datum/event/mundane_news)
// Bay builds the article from its event type and a weighted trade destination with English word picks. The kinds of news
// stay (research breakthrough, election, resignation, celebrity death, bargains, song debut) and a sports result is added;
// the texts are written anew in Polish for the NSV setting, each one a whole sentence so it can be translated as a unit.
// The place is a random star system of our map instead of a trade destination.

/datum/round_event_control/aquila_hex_mundane_news
	name = "Wiadomości ze świata"
	typepath = /datum/round_event/aquila_hex_news/mundane
	weight = 10
	max_occurrences = 3
	earliest_start = 5 MINUTES

/datum/round_event/aquila_hex_news/mundane

/datum/round_event/aquila_hex_news/mundane/make_article()
	var/place = aquila_hex_news_place()
	var/person = random_unique_name(pick(MALE, FEMALE))
	switch(pick("research", "election", "resignation", "death", "bargains", "song", "sport"))
		if("research")
			var/field = pick("badań nad plazmą", "materiałów supersprężonych", "nanoaugmentacji", "badań bluespace", "magazynowania energii")
			return list("Przełom w nauce", "Prywatna firma z układu [place] ogłosiła przełom w dziedzinie [field]. Nanotrasen odmówiło komentarza w sprawie wpływu odkrycia na zyski korporacji.")
		if("election")
			var/quote = pick("Moim jedynym celem jest pomoc najbiedniejszym.", "Utrzymam rekordowe zyski mojej firmy.", "Wierzę w naszą przyszłość.", "Musimy wrócić do naszych wartości.", "Wyluzujcie, ludzie, po prostu wyluzujcie.")
			return list("Nowy kandydat w wyborach", "Do wyborów na gubernatora układu [place] zgłosił się nowy kandydat, znany przedsiębiorca [person]. Zapytany o program, odpowiedział: „[quote]”")
		if("resignation")
			var/reason = pick("ze względu na zdrowie", "ze względów rodzinnych", "z powodów, których nie ujawniono", "po tym, jak pomylił przycisk ewakuacji z przyciskiem kawy")
			return list("Dymisja w dowództwie floty", "Nanotrasen z żalem informuje o odejściu admirała [person], który złożył dymisję [reason]. Uroczystość pożegnalna odbędzie się w układzie [place].")
		if("death")
			var/cause = pick("w wypadku przemysłowym", "z powodu niewydolności serca", "w niewyjaśnionych okolicznościach", "podczas zamachu, którego sprawców wciąż poszukuje Żandarmeria")
			return list("Nekrolog", "Z przykrością informujemy, że w układzie [place] zmarł(a) [person], ceniony(-a) artysta(-ka) i osobowość telewizyjna. Do śmierci doszło [cause].")
		if("bargains")
			return list("WYPRZEDAŻ!", "WYPRZEDAŻ! WYPRZEDAŻ! WYPRZEDAŻ! Izba handlowa układu [place] ogłasza, że wszystko musi zniknąć z półek. Wszystkie centra handlowe obniżają ceny, więc przylatujcie na zakupy życia!")
		if("song")
			var/title = pick("Gwiazdy nad Tortugą", "Mój mały corgi", "Ostatni prom z Centrali", "Plazma w sercu", "Tańcząc z karpiem")
			return list("Premiera płyty", "Piosenkarz(-rka) [person] zapowiada premierę nowej płyty „[title]”. Koncert premierowy odbędzie się w układzie [place].")
		if("sport")
			var/score = "[rand(1, 9)]:[rand(0, 8)]"
			return list("Wyniki ligi zero-g", "Drużyna z układu [place] wygrała mecz ligi piłki nożnej w stanie nieważkości wynikiem [score]. Sędzia przez całą drugą połowę dryfował poza boiskiem.")
