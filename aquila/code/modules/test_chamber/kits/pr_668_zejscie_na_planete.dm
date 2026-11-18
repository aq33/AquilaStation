/datum/test_chamber_kit/pr_668
	name = "Zejście promu na planetę i okna Sabre"
	pr = "aq33/AquilaStation#668"
	description = "Zestaw bez przedmiotów. Na serwerze (nie w CI) pyta, jaki typ planety dodać w układzie okrętu, i stawia ją 6 pól od okrętu na overmapie. \
	1) Sabre (z doku w hangarze): start, lot nad planetę w trybie dokowania, wybór lądowiska, „Wyląduj tutaj” w kamerze. Prom nie staje od razu na ziemi, tylko przez ok. 11 s schodzi. \
	2) Z kokpitu (przez boczne okna) i ze skrzydeł: planeta rośnie, aż wypełni niebo; potem niebo w kolorze atmosfery ze smugami, pomarańczowy żar na kosmosie przy kadłubie, chmury planety przelatujące przez ekran, powiększony teren pod promem z kurczącym się cieniem kadłuba, na końcu przyziemienie z drżeniem i bryzgami na wodzie albo kurzem na lądzie. \
	3) W kabinie w czasie wejścia w atmosferę: pomarańczowa pulsująca poświata na całym ekranie i iskry z paneli. \
	4) Okna Sabre: przednia szyba i pionowe szyby w górnych narożnikach są przezroczyste, w burtach pod nimi są nowe okna. Przez lewe i prawe okno widać skrzydła i kosmos (negatyw: ściany kokpitu dalej zasłaniają widok). \
	5) Księżyc (bez atmosfery): od razu teren pod promem, bez nieba, żaru i chmur. \
	6) Start z planety (nikt na skrzydle): chmury lecą w dół, niebo blednie, planeta maleje do zwykłej wielkości za oknami; tam, gdzie stał prom, zostaje kurz. \
	7) W czasie zejścia promem nie da się sterować (negatyw). Wyłączenie trybu dokowania albo skok FTL okrętu w trakcie zejścia: prom nie ląduje, komunikat o przerwanym lądowaniu, komputer dokowania znów działa."
	items = list()

/datum/test_chamber_kit/pr_668/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
#ifndef UNIT_TESTS
	var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
	if(!user || !ship?.current_system)
		return
	var/list/planet_choices = list()
	for(var/planet_type in GLOB.planet_type_prototypes)
		var/datum/planet_type/prototype = GLOB.planet_type_prototypes[planet_type]
		planet_choices["[prototype.name || planet_type] ([planet_type])"] = planet_type
	var/planet_choice = tgui_input_list(user, "Dodać planetę w układzie okrętu ([ship.current_system]), 6 pól od okrętu? (Anuluj = bez planety)", "Komora testowa", planet_choices)
	if(!planet_choice)
		return
	var/obj/structure/overmap/planet/planet = ship.current_system.add_planet(planet_choices[planet_choice], clamp(ship.x + 6, 30, world.maxx - 40), clamp(ship.y - 4, 30, world.maxy - 40))
	to_chat(user, span_notice("Dodano [planet] w układzie [ship.current_system]. Obraz na niebie zmieni się w ciągu 10 s."))
#endif
