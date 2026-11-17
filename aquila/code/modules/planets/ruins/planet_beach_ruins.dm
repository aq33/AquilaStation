// AQUILA - ruiny planet morskich przeniesione z Shiptesta (shiptest-ss13/Shiptest, kod AGPLv3, mapy jak kod, grafiki CC BY-SA 3.0):
// _maps/RandomRuins/BeachRuins/ i code/datums/ruins/beachplanet.dm. Mapy przerobione tools/planets/convert_maps.py
// z modułem mappings/beach.py (planeta oceaniczna) i mappings/water.py (te same ruiny na lodowatej planecie wodnej,
// która w Shiptest ruin nie ma). Jak przy planecie wulkanicznej: koszt 10, więc stają tylko jako ruina główna.
// Najważniejsze decyzje (pełna lista w mappings/beach.py):
// - Pogranicznicy (/mob/living/basic/human/frontier/*) -> nasi piraci (basic trooper/pirate) według broni,
//   Klika Ramziego -> żołnierze Syndykatu, roboty (rover, agrav) -> hivebot z frakcją obrońców;
// - statyczne pnącza -> krzewy dżungli, parasole plażowe i platformy pominięte, ogródki -> krzewy, grządki pominięte;
// - prom Kliki w kurorcie bez silników (ster i transponder -> puste ramy komputera), dekale logo Twardogłowych pominięte;
// - obszary zewnętrzne -> /area/lavaland/surface/outdoors (load_ruin przepina je na powierzchnię planety),
//   pomieszczenia -> obszary niżej (osobne dla kopii na planecie wodnej, żeby dwie wczytane kopie nie dzieliły APC).

/datum/map_template/ruin/planet_beach
	prefix = "aquila/_maps/RandomRuins/PlanetBeach/"
	cost = 10

/datum/map_template/ruin/planet_beach/bunkers
	name = "Składnica Pograniczników"
	id = "planet_beach_bunkers"
	description = "Bezładna plątanina bunkrów, w której flota Pograniczników urządziła składnicę zaopatrzenia."
	suffix = "planet_beach_bunkers.dmm"

/datum/map_template/ruin/planet_beach/corpo_resort
	name = "Kurort Korporacyjny"
	id = "planet_beach_corpo_resort"
	description = "Kurort korporacji sprzed wojny, zaatakowany w czasie wojny, a potem zajęty przez Klikę Ramziego. Wokół elektrowni geotermalnej jak nowotwór pleni się rój hivebotów."
	suffix = "planet_beach_corpo_resort.dmm"

/datum/map_template/ruin/planet_beach/csun_pad
	name = "Lądowisko Cybersun"
	id = "planet_beach_csun_pad"
	description = "Opuszczone centrum medyczne Cybersun. W okolicy rośnie aktywność anomalii."
	suffix = "planet_beach_csun_pad.dmm"

/datum/map_template/ruin/planet_beach/frontie_moat
	name = "Fosa Pograniczników"
	id = "planet_beach_frontie_moat"
	description = "Wioska Pograniczników otoczona fosą. Nie najgorsze miejsce do życia."
	suffix = "planet_beach_frontie_moat.dmm"

/datum/map_template/ruin/planet_beach/gunsmith
	name = "Jaskiniowy Rusznikarz"
	id = "planet_beach_gunsmith"
	description = "Rozpustna rusznikarnia w jaskini, wspólna własność oddziału Kliki Ramziego i skorumpowanego urzędnika. Ukryta głęboko w skale."
	suffix = "planet_beach_gunsmith.dmm"

/// Te same ruiny na planecie wodnej (lodowata atmosfera, osobne obszary)
/datum/map_template/ruin/planet_water
	prefix = "aquila/_maps/RandomRuins/PlanetWater/"
	cost = 10

/datum/map_template/ruin/planet_water/bunkers
	name = "Składnica Pograniczników (planeta wodna)"
	id = "planet_water_bunkers"
	description = "Bezładna plątanina bunkrów, w której flota Pograniczników urządziła składnicę zaopatrzenia."
	suffix = "planet_water_bunkers.dmm"

/datum/map_template/ruin/planet_water/frontie_moat
	name = "Fosa Pograniczników (planeta wodna)"
	id = "planet_water_frontie_moat"
	description = "Wioska Pograniczników otoczona fosą. Nie najgorsze miejsce do życia."
	suffix = "planet_water_frontie_moat.dmm"

/datum/map_template/ruin/planet_water/gunsmith
	name = "Jaskiniowy Rusznikarz (planeta wodna)"
	id = "planet_water_gunsmith"
	description = "Rozpustna rusznikarnia w jaskini, wspólna własność oddziału Kliki Ramziego i skorumpowanego urzędnika. Ukryta głęboko w skale."
	suffix = "planet_water_gunsmith.dmm"

/// Ruiny planet morskich danego typu szablonu (nazwa -> szablon), z szablonów wczytanych przez SSmapping
/proc/get_planet_sea_ruin_templates(ruin_type)
	var/static/list/cache = list()
	var/list/templates = cache[ruin_type]
	if(!length(templates))
		templates = list()
		for(var/name in SSmapping.ruins_templates)
			var/datum/map_template/ruin/ruin = SSmapping.ruins_templates[name]
			if(istype(ruin, ruin_type))
				templates[name] = ruin
		cache[ruin_type] = templates
	return templates

// Obszary ruin. Pomieszczenia z APC ruiny (Shiptest: zasilanie z APC ruiny).

/area/ruin/unpowered/planet_beach/cave
	name = "Jaskinia"
	icon_state = "unexplored"
	always_unpowered = TRUE
	sound_environment = SOUND_ENVIRONMENT_CAVE

/area/ruin/unpowered/planet_beach/bunker
	name = "Bunkier"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/bunker/living
	name = "Bunkier – Kwatery"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/bunker/office
	name = "Bunkier – Biuro"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/bunker/side_one
	name = "Bunkier – Skrzydło pierwsze"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/bunker/side_two
	name = "Bunkier – Skrzydło drugie"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/corpo_resort/bar
	name = "Kurort – Bar"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/corpo_resort/electrical
	name = "Kurort – Elektrownia"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/corpo_resort/hotel
	name = "Kurort – Hotel"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/corpo_resort/hotel/rooms/officer
	name = "Kurort – Apartament oficerski"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/corpo_resort/hotel/rooms/one
	name = "Kurort – Pokój 1"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/corpo_resort/hotel/rooms/three
	name = "Kurort – Pokój 3"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/corpo_resort/hotel/rooms/two
	name = "Kurort – Pokój 2"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/corpo_resort/office
	name = "Kurort – Biuro"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/corpo_resort/ramzi_emplacement
	name = "Kurort – Stanowisko Kliki"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/corpo_resort/ramzi_emplacement/north
	name = "Kurort – Stanowisko Kliki (północ)"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/corpo_resort/ramzi_emplacement/west
	name = "Kurort – Stanowisko Kliki (zachód)"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/corpo_resort/ramzi_shuttle
	name = "Kurort – Prom Kliki"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/corpo_resort/ramzi_tent
	name = "Kurort – Namiot Kliki"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/corpo_resort/security
	name = "Kurort – Ochrona"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/corpo_resort/staff_dorms
	name = "Kurort – Kwatery personelu"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/corpo_resort/supply
	name = "Kurort – Magazyn"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/csunpad
	name = "Lądowisko Cybersun"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/csunpad/canteen
	name = "Lądowisko Cybersun – Stołówka"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/csunpad/director
	name = "Lądowisko Cybersun – Gabinet dyrektora"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/csunpad/dorm
	name = "Lądowisko Cybersun – Sypialnia"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/csunpad/engineering
	name = "Lądowisko Cybersun – Inżynieria"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/csunpad/june
	name = "Lądowisko Cybersun – Desantowiec"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/csunpad/medical
	name = "Lądowisko Cybersun – Ambulatorium"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/csunpad/security
	name = "Lądowisko Cybersun – Ochrona"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/gunsmith
	name = "Rusznikarnia"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/gunsmith/bathroom
	name = "Rusznikarnia – Łazienka"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/gunsmith/crewquarters
	name = "Rusznikarnia – Kwatery załogi"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/gunsmith/dorms
	name = "Rusznikarnia – Sypialnie"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/gunsmith/dorms/officer
	name = "Rusznikarnia – Sypialnia oficera"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/gunsmith/electrical
	name = "Rusznikarnia – Rozdzielnia"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/gunsmith/kitchen
	name = "Rusznikarnia – Kuchnia"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/gunsmith/workshop
	name = "Rusznikarnia – Warsztat"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/village/armory
	name = "Wioska – Zbrojownia"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/village/dorm
	name = "Wioska – Sypialnia"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/village/infirmary
	name = "Wioska – Izba chorych"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/village/kitchen
	name = "Wioska – Kuchnia"
	icon_state = "away"

/area/ruin/unpowered/planet_beach/village/officers
	name = "Wioska – Kwatery oficerów"
	icon_state = "away"

/area/ruin/unpowered/planet_water/cave
	name = "Jaskinia (planeta wodna)"
	icon_state = "unexplored"
	always_unpowered = TRUE
	sound_environment = SOUND_ENVIRONMENT_CAVE

/area/ruin/unpowered/planet_water/bunker
	name = "Bunkier (planeta wodna)"
	icon_state = "away"

/area/ruin/unpowered/planet_water/bunker/living
	name = "Bunkier – Kwatery (planeta wodna)"
	icon_state = "away"

/area/ruin/unpowered/planet_water/bunker/office
	name = "Bunkier – Biuro (planeta wodna)"
	icon_state = "away"

/area/ruin/unpowered/planet_water/bunker/side_one
	name = "Bunkier – Skrzydło pierwsze (planeta wodna)"
	icon_state = "away"

/area/ruin/unpowered/planet_water/bunker/side_two
	name = "Bunkier – Skrzydło drugie (planeta wodna)"
	icon_state = "away"

/area/ruin/unpowered/planet_water/village/armory
	name = "Wioska – Zbrojownia (planeta wodna)"
	icon_state = "away"

/area/ruin/unpowered/planet_water/village/dorm
	name = "Wioska – Sypialnia (planeta wodna)"
	icon_state = "away"

/area/ruin/unpowered/planet_water/village/infirmary
	name = "Wioska – Izba chorych (planeta wodna)"
	icon_state = "away"

/area/ruin/unpowered/planet_water/village/kitchen
	name = "Wioska – Kuchnia (planeta wodna)"
	icon_state = "away"

/area/ruin/unpowered/planet_water/village/officers
	name = "Wioska – Kwatery oficerów (planeta wodna)"
	icon_state = "away"

/area/ruin/unpowered/planet_water/gunsmith
	name = "Rusznikarnia (planeta wodna)"
	icon_state = "away"

/area/ruin/unpowered/planet_water/gunsmith/bathroom
	name = "Rusznikarnia – Łazienka (planeta wodna)"
	icon_state = "away"

/area/ruin/unpowered/planet_water/gunsmith/crewquarters
	name = "Rusznikarnia – Kwatery załogi (planeta wodna)"
	icon_state = "away"

/area/ruin/unpowered/planet_water/gunsmith/dorms
	name = "Rusznikarnia – Sypialnie (planeta wodna)"
	icon_state = "away"

/area/ruin/unpowered/planet_water/gunsmith/dorms/officer
	name = "Rusznikarnia – Sypialnia oficera (planeta wodna)"
	icon_state = "away"

/area/ruin/unpowered/planet_water/gunsmith/electrical
	name = "Rusznikarnia – Rozdzielnia (planeta wodna)"
	icon_state = "away"

/area/ruin/unpowered/planet_water/gunsmith/kitchen
	name = "Rusznikarnia – Kuchnia (planeta wodna)"
	icon_state = "away"

/area/ruin/unpowered/planet_water/gunsmith/workshop
	name = "Rusznikarnia – Warsztat (planeta wodna)"
	icon_state = "away"
