/datum/test_chamber_kit/pr_668
	name = "Planeta na niebie, zejście promu i okna Sabre"
	pr = "aq33/AquilaStation#668"
	description = "Zestaw bez przedmiotów. Na serwerze (nie w CI) pyta, jaki typ planety dodać w układzie okrętu, i stawia ją 6 pól od okrętu na overmapie. \
	1) Po najwyżej 10 s za oknami i za kadłubem widać dużą planetę tego typu (najbliższą okrętowi). Planeta stoi w miejscu (nie obraca się), lewa górna strona jest oświetlona, prawa dolna ciemna, na brzegu świeci atmosfera w kolorze typu (księżyc bez atmosfery). \
	2) Typy: dżunglowa, oceaniczna, wodna, lodowa, wulkaniczna (świecące rzeki lawy, popielne chmury), pole bitwy, skalista, białe piaski, pustynna, mglista (gęste fioletowe opary), wysypisko, księżyc i karłowate (mniejsze), gazowy i plazmowy olbrzym (większe, w pasy). Pole asteroid i słaby sygnał nie dają planety na niebie (negatyw). \
	3) Skok FTL: w czasie skoku planeta znika, po wyjściu w układzie bez planety niebo jest puste (negatyw), w układzie z planetą pojawia się jej obraz. Na powierzchni planety jej samej na niebie nie ma (negatyw). \
	4) Konsola pilota (widok overmapy): planeta z nieba się nie pokazuje (negatyw), na overmapie jest tylko jej zwykły sprite. Preferencje, wyłączona paralaksa: brak planety. \
	5) Sabre (z doku w hangarze): start, lot nad planetę w trybie dokowania, wybór lądowiska, „Wyląduj tutaj” w kamerze. Prom nie staje od razu na ziemi, tylko przez ok. 9,5 s schodzi. \
	6) Z kokpitu i ze skrzydeł: planeta rośnie, aż wypełni niebo; potem niebo w kolorze atmosfery ze smugami, pomarańczowy żar na kosmosie przy kadłubie, potem z nieba wyłania się prawdziwy teren lądowiska (drzewa, skały, to, co na nim stoi), mały, i rośnie pod promem z kurczącym się cieniem kadłuba i kurzem od dysz, aż w chwili przyziemienia ma prawdziwą wielkość i nic się nie przeskakuje; teren widać tylko za kadłubem, nie na nim, na końcu przyziemienie z drżeniem i bryzgami na wodzie albo kurzem na lądzie. Dźwięki: rozruch silników, wejście w atmosferę, chmury, dysze, przyziemienie. \
	7) W kabinie w czasie wejścia w atmosferę: pomarańczowa pulsująca poświata na całym ekranie i iskry z paneli. \
	8) Kadłub Sabre: z kokpitu widać całe otoczenie promu (hangar, kosmos, planetę), bez czarnych plam; szyby (przednia, w narożnikach i dwie nowe w burtach) nazywają się „szyba kokpitu”. W locie wokół promu jest tylko kosmos, bez skał ani innych obiektów z sąsiednich miejsc (negatyw). \
	9) Księżyc (bez atmosfery): od razu teren pod promem, bez nieba i żaru. \
	10) Start z planety (nikt na skrzydle): niebo blednie, lądowisko pod promem maleje i blednie (tylko gdy prom wcześniej schodził na to miejsce w ciągu 10 min, inaczej od razu niebo), planeta maleje do zwykłej wielkości za oknami, słychać start. \
	11) W czasie zejścia promem nie da się sterować (negatyw). Wyłączenie trybu dokowania albo skok FTL okrętu w trakcie zejścia: prom nie ląduje, planeta i niebo bledną w kosmos (nie znikają nagle), komunikat o przerwanym lądowaniu, komputer dokowania znów działa. \
	12) Z ziemi (drugi gracz albo duch przy lądowisku): ok. 6 s przed przyziemieniem słychać nadlatujący prom, a na lądowisku pojawia się blady, szeroki cień, który ciemnieje i zwęża się do obrysu promu; 3 s przed przyziemieniem z góry spada obraz promu (z ludźmi w środku), zawisa tuż nad ziemią, spod krawędzi leci kurz od dysz, potem stoi prawdziwy prom. Start: prom unosi się i odlatuje w stronę kokpitu, kurz leci spod rufy, cień sunie za nim i blednie. Przerwane zejście: cień i obraz bledną."
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
	// Okno wyboru nie ma limitu czasu: okręt mógł w tym czasie zniknąć albo skoczyć
	if(!planet_choice || QDELETED(ship) || !ship.current_system)
		return
	var/obj/structure/overmap/planet/planet = ship.current_system.add_planet(planet_choices[planet_choice], clamp(ship.x + 6, 30, world.maxx - 40), clamp(ship.y - 4, 30, world.maxy - 40))
	to_chat(user, span_notice("Dodano [planet] w układzie [ship.current_system]. Obraz na niebie zmieni się w ciągu 10 s."))
#endif
