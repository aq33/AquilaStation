/datum/test_chamber_kit/pr_664
	name = "Planeta na niebie za okrętem"
	pr = "aq33/AquilaStation#664"
	description = "Zestaw bez przedmiotów. Na serwerze (nie w CI) pyta, jaki typ planety dodać w układzie okrętu, i stawia ją 6 pól od okrętu na overmapie. \
	1) Po najwyżej 10 s za oknami i za kadłubem widać dużą planetę tego typu (najbliższą okrętowi). Powierzchnia powoli się obraca, chmury płyną szybciej, lewa górna strona jest oświetlona, prawa dolna ciemna, na brzegu świeci atmosfera w kolorze typu (księżyc bez atmosfery). \
	2) Typy: dżunglowa, oceaniczna, wodna, lodowa, wulkaniczna (świecące rzeki lawy, popielne chmury), pole bitwy, skalista, białe piaski, pustynna, mglista (gęste fioletowe opary), wysypisko, księżyc i karłowate (mniejsze), gazowy i plazmowy olbrzym (większe, w pasy). Pole asteroid i słaby sygnał nie dają planety na niebie (negatyw). \
	3) Skok FTL: w czasie skoku planeta znika, po wyjściu w układzie bez planety niebo jest puste (negatyw), w układzie z planetą pojawia się jej obraz. \
	4) Konsola pilota (widok overmapy): planeta z nieba się nie pokazuje (negatyw), na overmapie jest tylko jej zwykły sprite. \
	5) Preferencje, paralaksa na niskie: planeta stoi bez obrotu. Wyłączona paralaksa: brak planety."
	items = list()

/datum/test_chamber_kit/pr_664/setup(list/spawned, list/turfs, turf/center, mob/user)
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
