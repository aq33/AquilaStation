/datum/test_chamber_kit/pr_592
	name = "Sabre jako wnętrze i promy z Wyznacznika na overmapie"
	pr = "aq33/AquilaStation#592"
	description = "Zestaw: Wyznacznik Stref Promu, RCD, sterownik lotu promu, silnik próżniowy, silnik plazmowy z podgrzewaczem, kanister plazmy, zbiornik kriopaliwa i zapasowa karta kapitana. \
	1) Sabre na mapie: w hangarze (na Atlasie zatoka górnicza na południu, dziobem na wschód do wrót, i poszerzony hangar obok Trafalgara, dziobem na północ) stoi wnętrze Sabre, bez spritu. Kadłub na porcie skierowanym na wschód ma obrazek obrócony w całości, bez poprzestawianych kawałków. Przycisk „Wrota hangaru Sabre” przy wrotach otwiera je i zamyka. Pustą ręką na lewej gondoli (właz) → wchodzisz do środka; bez dostępu pilota/górnika → „Odmowa dostępu” (negatyw). Wrota w kokpicie → wychodzisz na pole przed włazem. \
	2) Obsługa: wąż ze zbiornika kriopaliwa przy włazie, kliknięty na właz → tankowanie Sabre (badanie włazu pokazuje paliwo); karta na włazie → okno trybu serwisowego/wyrzucenia; przeciągnięcie skrzyni na właz → ładownia. \
	3) Start: ster w kokpicie → pytanie „Startujemy?”, Start → wnętrze znika z hangaru, Sabre jest na overmapie obok statku, ster steruje nim jak promem desantowym. Z pustym zbiornikiem start odmawia (negatyw). W locie wrota są zablokowane. \
	4) Lądowanie: włącz tryb dokowania i wleć w statek → komunikat o szukaniu miejsca, wnętrze wraca na swój port w hangarze. Przy celu bez portu (opuszczona stacja, asteroida) → wnętrze siada w kosmosie przy kadłubie celu tak, że z wrót wychodzi się na podłogę celu (jeśli wolne miejsce przy podłodze jest). \
	5) Prom z Wyznacznika: zbuduj RCD małe pomieszczenie z podłogą, ścianą zewnętrzną i śluzą, postaw w środku sterownik lotu i silnik (próżniowy działa bez paliwa; plazmowy potrzebuje podgrzewacza w tym samym kierunku i plazmy z kanistra), wyznacz prom Wyznacznikiem i użyj go na śluzie. Sterownik → „Startujemy?” → prom leci po overmapie z własnym sprite'em, powrót trybem dokowania na plac budowy. Bez silników albo bez paliwa start odmawia z komunikatem (negatyw)."
	items = list(
		/obj/item/shuttle_creator = 1,
		/obj/item/construction/rcd/loaded = 1,
		/obj/machinery/computer/shuttle_flight/custom_shuttle = 1,
		/obj/machinery/shuttle/engine/void = 1,
		/obj/machinery/shuttle/engine/plasma = 1,
		/obj/machinery/atmospherics/components/unary/shuttle/heater = 1,
		/obj/machinery/portable_atmospherics/canister/toxins = 1,
		/obj/structure/reagent_dispensers/fueltank/cryogenic_fuel = 1,
		/obj/item/card/id/captains_spare = 1,
	)

