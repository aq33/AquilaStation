/datum/test_chamber_kit/pr_668
	name = "Planeta na niebie, zejście promu i okna Sabre"
	pr = "aq33/AquilaStation#668"
	description = "Zestaw bez przedmiotów. Na serwerze (nie w CI) pyta, jaki typ planety dodać w układzie okrętu, i stawia ją 6 pól od okrętu na overmapie. \
	1) Po najwyżej 10 s za oknami i za kadłubem widać dużą planetę tego typu (najbliższą okrętowi). Planeta stoi w miejscu (nie obraca się), lewa górna strona jest oświetlona, prawa dolna ciemna, na brzegu świeci atmosfera w kolorze typu (księżyc bez atmosfery). \
	2) Typy: dżunglowa, oceaniczna, wodna, lodowa, wulkaniczna (świecące rzeki lawy, popielne chmury), pole bitwy, skalista, białe piaski, pustynna, mglista (gęste fioletowe opary), wysypisko, księżyc i karłowate (mniejsze), gazowy i plazmowy olbrzym (większe, w pasy). Pole asteroid i słaby sygnał nie dają planety na niebie (negatyw). \
	3) Skok FTL: w czasie skoku planeta znika, po wyjściu w układzie bez planety niebo jest puste (negatyw), w układzie z planetą pojawia się jej obraz. Na powierzchni planety jej samej na niebie nie ma (negatyw). \
	4) Konsola pilota (widok overmapy): planeta z nieba się nie pokazuje (negatyw), na overmapie jest tylko jej zwykły sprite. Preferencje, wyłączona paralaksa: brak planety. \
	5) Sabre (z doku w hangarze): start, lot nad planetę w trybie dokowania, wybór lądowiska, „Wyląduj tutaj” w kamerze. Prom nie staje od razu na ziemi, tylko przez ok. 11 s schodzi. \
	6) Z kokpitu i ze skrzydeł: planeta rośnie, aż wypełni niebo; potem niebo w kolorze atmosfery ze smugami, pomarańczowy żar na kosmosie przy kadłubie, chmury planety przelatujące przez ekran, powiększony teren pod promem z kurczącym się cieniem kadłuba, na końcu przyziemienie z drżeniem i bryzgami na wodzie albo kurzem na lądzie. \
	7) W kabinie w czasie wejścia w atmosferę: pomarańczowa pulsująca poświata na całym ekranie i iskry z paneli. \
	8) Kadłub Sabre: z kokpitu widać całe otoczenie promu (hangar, kosmos, planetę), bez czarnych plam; szyby (przednia, w narożnikach i dwie nowe w burtach) nazywają się „szyba kokpitu”. W locie wokół promu jest tylko kosmos, bez skał ani innych obiektów z sąsiednich miejsc (negatyw). \
	9) Księżyc (bez atmosfery): od razu teren pod promem, bez nieba, żaru i chmur. \
	10) Start z planety (nikt na skrzydle): chmury lecą w dół, niebo blednie, planeta maleje do zwykłej wielkości za oknami; tam, gdzie stał prom, zostaje kurz. \
	11) W czasie zejścia promem nie da się sterować (negatyw). Wyłączenie trybu dokowania albo skok FTL okrętu w trakcie zejścia: prom nie ląduje, komunikat o przerwanym lądowaniu, komputer dokowania znów działa."
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
