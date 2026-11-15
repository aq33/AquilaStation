// AQUILA: ruiny planet-śmietnisk i pól bitwy przeniesione z Shiptesta (shiptest-ss13/Shiptest, kod AGPLv3, mapy jak kod,
// grafiki CC BY-SA 3.0): _maps/RandomRuins/WasteRuins/ i code/datums/ruins/wasteplanet.dm.
// Shiptest nie daje tym ruinom kosztu (wszystkie są tam ruinami głównymi), więc koszt 10 jest nasz: stają tylko jako ruina
// główna. Pole bitwy nie ma w Shiptest własnych ruin, więc pożycza trzy wojskowe ruiny śmietniska, przerobione osobno na
// turfy, atmosferę i obszary pola bitwy (inaczej dwie kopie dzieliłyby obszary i APC).
//
// Mapy przerobione skryptem tools/planets/convert_maps.py (moduły tools/planets/mappings/waste.py i battlefield.py),
// najważniejsze decyzje (poza wspólnymi z portu lawy, opisanymi w planet_lava_ruins.dm):
// - pogranicznicy (frontiersmen) -> nasi żołnierze rosyjscy (/mob/living/basic/trooper/russian/*) według broni, z ich
//   zwłokami; pustelnik-wynalazca -> pirat ze strzelbą; Klika Ramziego -> żołnierze Syndykatu; InteQ i Vigilitas -> NT;
// - automaty (/mob/living/simple_animal/hostile/automated/*) -> port na basic moby (shiptest_fauna/automatons.dm),
//   frakcje Ramziego i koalicji -> Syndykat; „przeprogramowane” hivebota i viscerator -> ta sama maszyna z frakcją neutralną
//   (nie atakuje załogi); rdzeń roju -> /mob/living/basic/hivebot/strong/core;
// - beczki z odpadami i promieniowanie tła -> port w shiptest_flora/waste.dm, wraki maszyn (salvageable) -> puste ramy;
// - rury i urządzenia atmosferyczne na warstwach 1 i 5 (u nas tylko 2-4) -> warstwa 2 i 4, kwaśna fosa -> skażona woda;
// - kartki z mapy i fluff papers przetłumaczone, sztuczne zwierzęta i sofy według najbliższych naszych typów;
// - pominięte: platformy, alarmy przeciwwłamaniowe i inne zagrożenia /obj/structure/hazard, dźwig, regały na skrzynie,
//   faks Ramziego, holoznak ewakuacji, emblematy i numery na podłodze, ozdoby Miskilamo, sztuczne jaja pająków.

/datum/map_template/ruin/planet_waste
	prefix = "aquila/_maps/RandomRuins/PlanetWaste/"
	cost = 10

/datum/map_template/ruin/planet_waste/tradepost
	name = "Zrujnowana Faktoria"
	id = "planet_waste_tradepost"
	description = "Kiedyś działająca, choć nie kwitnąca faktoria. Teraz cmentarzysko najemników i hivebotów."
	suffix = "planet_waste_tradepost.dmm"

/datum/map_template/ruin/planet_waste/yard
	name = "Opuszczone Złomowisko Miskilamo"
	id = "planet_waste_yard"
	description = "Opuszczona stocznia rozbiórkowa statków."
	suffix = "planet_waste_yard.dmm"

/datum/map_template/ruin/planet_waste/icwbase
	name = "Baza Łączności i Medyczna z Wojny Międzykorporacyjnej"
	id = "planet_waste_icwbase"
	description = "Dawna baza koalicji Syndykatu z czasów Wojny Międzykorporacyjnej, porzucona na śmietnisku. Wygląda na to, że ma nowych lokatorów."
	suffix = "planet_waste_icwbase.dmm"

/datum/map_template/ruin/planet_waste/facility
	name = "Zakład Odzysku Złomu"
	id = "planet_waste_facility"
	description = "Zakład zbiórki i przerobu złomu, porzucony przez jedynego właściciela po rozwiązaniu korporacji."
	suffix = "planet_waste_facility.dmm"

/datum/map_template/ruin/planet_waste/recyclebay
	name = "Zakład Recyklingu"
	id = "planet_waste_recyclebay"
	description = "Zardzewiała baza odzysku i recyklingu, która zaopatruje dość podejrzanych ludzi."
	suffix = "planet_waste_recyclebay.dmm"

/datum/map_template/ruin/planet_waste/smugglerbunker
	name = "Bunkier Przemytników"
	id = "planet_waste_smugglerbunker"
	description = "W resztkach starego bunkra maruderów z Wojny Międzykorporacyjnej przemytnicy założyli placówkę. Mają dostęp do wszystkich urządzeń. Oznaki życia nieznane. To czynne wysypisko."
	suffix = "planet_waste_smugglerbunker.dmm"

/// Ruiny pola bitwy: wojskowe ruiny śmietniska przerobione na turfy pola bitwy
/datum/map_template/ruin/planet_battlefield
	prefix = "aquila/_maps/RandomRuins/PlanetBattlefield/"
	cost = 10

/datum/map_template/ruin/planet_battlefield/icwbase
	name = "Zrujnowana Baza z Wojny Międzykorporacyjnej"
	id = "planet_battlefield_icwbase"
	description = "Baza łączności i medyczna koalicji Syndykatu na dawnej linii frontu. Wygląda na to, że ma nowych lokatorów."
	suffix = "planet_battlefield_icwbase.dmm"

/datum/map_template/ruin/planet_battlefield/smugglerbunker
	name = "Bunkier Maruderów (pole bitwy)"
	id = "planet_battlefield_smugglerbunker"
	description = "Stary bunkier maruderów z Wojny Międzykorporacyjnej, w którym zagnieździli się przemytnicy."
	suffix = "planet_battlefield_smugglerbunker.dmm"

/datum/map_template/ruin/planet_battlefield/yard
	name = "Polowe Złomowisko"
	id = "planet_battlefield_yard"
	description = "Złomowisko wraków zebranych z pola bitwy."
	suffix = "planet_battlefield_yard.dmm"

/// Ruiny planet-śmietnisk i pól bitwy (nazwa -> szablon), jak get_planet_lava_ruin_templates()
GLOBAL_LIST_EMPTY(planet_waste_ruin_templates)
GLOBAL_LIST_EMPTY(planet_battlefield_ruin_templates)

/proc/get_planet_ruin_templates_of(list/cache, ruin_type)
	if(!length(cache))
		for(var/name in SSmapping.ruins_templates)
			var/datum/map_template/ruin/ruin = SSmapping.ruins_templates[name]
			if(istype(ruin, ruin_type))
				cache[name] = ruin
	return cache

/proc/get_planet_waste_ruin_templates()
	return get_planet_ruin_templates_of(GLOB.planet_waste_ruin_templates, /datum/map_template/ruin/planet_waste)

/proc/get_planet_battlefield_ruin_templates()
	return get_planet_ruin_templates_of(GLOB.planet_battlefield_ruin_templates, /datum/map_template/ruin/planet_battlefield)

// Kartki z ruin śmietniska (Shiptest code/modules/paperwork/paper_premade.dm)

/obj/item/paper/fluff/ruins/planet_waste/vault
	name = "Przycisk skarbca"
	default_raw_text = "Przycisk skarbca się zbugował. Jak chcecie wejść, idźcie do ochrony i krzyczcie na nich, żeby użyli zdalnego dostępu. Módlcie się tylko, żeby akurat nie byli w środku gry."

/obj/item/paper/fluff/ruins/planet_waste/reminder
	name = "OSTATNIE PRZYPOMNIENIE"
	default_raw_text = "Jeśli któryś z was, durnie, znowu zapomni pozbierać łuski, osobiście wyślę go do eskorty ekipy złomiarzy z samym nożem, a jak dacie komuś z nich zginąć, to wasza głowa pojedzie w następnej skrzyni stąd. Jasne?"

/obj/item/paper/crumpled/fluff/ruins/planet_waste/doors
	name = "Gówniane drzwi!"
	default_raw_text = "Grodzie przy wewnętrznej śluzie inżynierii znowu się zbugowały! Kto wybrał to miejsce na budowę, powinien zostać rozstrzelany, wszystko się tu sypie! Wiertło nie działa. Ktokolwiek to czyta, weź piłę do złomu ze skarbca i je przetnij albo wysadź, byle niczego nie zepsuć, bo Szef zrobi z ciebie tarczę strzelniczą dla hivebotów."

/// Rdzeń roju hivebotów: wieża z metalu i obwodów z przyspawanym działkiem (Shiptest /mob/living/basic/hivebot/core)
/mob/living/basic/hivebot/strong/core
	name = "rdzeń roju hivebotów"
	desc = "Ogromna, obca wieża z metalu i obwodów. Ze wszystkich stron patrzą oczy rzucające elektroniczne światło, a przyspawane działko gniewnie rozgląda się po świecie."
	health = 300
	maxHealth = 300
	melee_damage = 25
	speed = 3
	ranged_attack_cooldown = 1 SECONDS

/mob/living/basic/hivebot/strong/core/death(gibbed)
	var/turf/boom = get_turf(src)
	. = ..()
	radiation_pulse(boom, max_range = 4, threshold = RAD_LIGHT_INSULATION, intensity = 6)
	explosion(boom, 0, 1, 3, 3, adminlog = FALSE)

// Obszary ruin. Pomieszczenia z APC (unpowered = zasilanie z APC ruiny), jak w porcie lawy.

/area/ruin/unpowered/planet_waste
	name = "Ruiny Wysypiska"
	icon_state = "away"

/area/ruin/unpowered/planet_waste/cave
	name = "Jaskinia"
	icon_state = "unexplored"
	always_unpowered = TRUE
	sound_environment = SOUND_ENVIRONMENT_CAVE

/area/ruin/unpowered/planet_waste/tradepost
	name = "Zrujnowana Faktoria"
/area/ruin/unpowered/planet_waste/tradepost/barracks
	name = "Faktoria – Koszary"
	icon_state = "red"
/area/ruin/unpowered/planet_waste/tradepost/center
	name = "Faktoria – Kopuła"
	icon_state = "bridge"
/area/ruin/unpowered/planet_waste/tradepost/warehouse
	name = "Faktoria – Magazyn"
	icon_state = "dk_yellow"

/area/ruin/unpowered/planet_waste/shipbreaking
	name = "Złomowisko Statków"
	icon_state = "green"
/area/ruin/unpowered/planet_waste/shipbreaking/bay
	name = "Złomowisko Miskilamo – Dok"
	icon_state = "engine"
/area/ruin/unpowered/planet_waste/shipbreaking/canteen
	name = "Złomowisko Miskilamo – Stołówka"
	icon_state = "hallC"
/area/ruin/unpowered/planet_waste/shipbreaking/dorms
	name = "Złomowisko Miskilamo – Sypialnia"
	icon_state = "bridge"
/area/ruin/unpowered/planet_waste/shipbreaking/ship
	name = "Złomowisko – Wrak"
	icon_state = "red"

/area/ruin/unpowered/planet_waste/icwbase
	name = "Baza z Wojny Międzykorporacyjnej"
	icon_state = "bridge"
/area/ruin/unpowered/planet_waste/icwbase/tcom
	name = "Baza – Telekomunikacja"
/area/ruin/unpowered/planet_waste/icwbase/cic
	name = "Baza – Dowodzenie"
/area/ruin/unpowered/planet_waste/icwbase/vault
	name = "Baza – Skarbiec"
	icon_state = "security"
/area/ruin/unpowered/planet_waste/icwbase/eng
	name = "Baza – Inżynieria"
	icon_state = "engine"
/area/ruin/unpowered/planet_waste/icwbase/tcommoni
	name = "Baza – Nasłuch Telekomunikacji"
/area/ruin/unpowered/planet_waste/icwbase/warehouse
	name = "Baza – Magazyn"
	icon_state = "storage"
/area/ruin/unpowered/planet_waste/icwbase/hab
	name = "Baza – Część Mieszkalna"
	icon_state = "crew_quarters"
/area/ruin/unpowered/planet_waste/icwbase/cybersun
	name = "Baza – Skrzydło Cybersun"
	icon_state = "blue"

/area/ruin/unpowered/planet_waste/facility
	name = "Zakład Odzysku – Korytarz Główny"
	icon_state = "bluenew"
/area/ruin/unpowered/planet_waste/facility/westbay
	name = "Zakład Odzysku – Zachodnia Hala"
	icon_state = "green"
/area/ruin/unpowered/planet_waste/facility/eastbay
	name = "Zakład Odzysku – Wschodnia Hala"
	icon_state = "yellow"
/area/ruin/unpowered/planet_waste/facility/crew
	name = "Zakład Odzysku – Część Załogi"
	icon_state = "purple"
/area/ruin/unpowered/planet_waste/facility/northwing
	name = "Zakład Odzysku – Skrzydło Północne"
	icon_state = "fmaint"
/area/ruin/unpowered/planet_waste/facility/southwing
	name = "Zakład Odzysku – Skrzydło Południowe"
	icon_state = "amaint"

/area/ruin/unpowered/planet_waste/recycle_bay
	name = "Zakład Recyklingu"
	icon_state = "disposal"
/area/ruin/unpowered/planet_waste/recycle_bay/atmospherics
	name = "Zakład Recyklingu – Atmosferyka"
	icon_state = "atmos"
/area/ruin/unpowered/planet_waste/recycle_bay/dorms
	name = "Zakład Recyklingu – Sypialnia"
	icon_state = "crew_quarters"
/area/ruin/unpowered/planet_waste/recycle_bay/security
	name = "Zakład Recyklingu – Biuro Ochrony"
	icon_state = "security"
/area/ruin/unpowered/planet_waste/recycle_bay/armory
	name = "Zakład Recyklingu – Zbrojownia"
	icon_state = "armory"
/area/ruin/unpowered/planet_waste/recycle_bay/officers
	name = "Zakład Recyklingu – Pokój Oficerów"
	icon_state = "red"
/area/ruin/unpowered/planet_waste/recycle_bay/engineering
	name = "Zakład Recyklingu – Inżynieria"
	icon_state = "engine"
/area/ruin/unpowered/planet_waste/recycle_bay/security_dorms
	name = "Zakład Recyklingu – Kwatery Ochrony"
	icon_state = "blue"
/area/ruin/unpowered/planet_waste/recycle_bay/electrical
	name = "Zakład Recyklingu – Rozdzielnia"
	icon_state = "engine_smes"
/area/ruin/unpowered/planet_waste/recycle_bay/telecommunications
	name = "Zakład Recyklingu – Telekomunikacja"
	icon_state = "tcomsatcham"
/area/ruin/unpowered/planet_waste/recycle_bay/eva
	name = "Zakład Recyklingu – EVA"
	icon_state = "eva"
/area/ruin/unpowered/planet_waste/recycle_bay/salvage_bay
	name = "Zakład Recyklingu – Hala Złomu"
	icon_state = "disposal"
/area/ruin/unpowered/planet_waste/recycle_bay/vault
	name = "Zakład Recyklingu – Skarbiec"
	icon_state = "cargo_bay"
/area/ruin/unpowered/planet_waste/recycle_bay/officers_dorms
	name = "Zakład Recyklingu – Kwatery Oficerów"
	icon_state = "crew_quarters"
/area/ruin/unpowered/planet_waste/recycle_bay/officers_office
	name = "Zakład Recyklingu – Biuro Oficerów"
	icon_state = "bridge"

/area/ruin/unpowered/planet_waste/smugglerbunker
	name = "Bunkier"
	icon_state = "hallC"
/area/ruin/unpowered/planet_waste/smugglerbunker/exterior
	name = "Bunkier – Teren Zewnętrzny"
	icon_state = "green"
/area/ruin/unpowered/planet_waste/smugglerbunker/armory
	name = "Bunkier – Zbrojownia"
	icon_state = "security"
/area/ruin/unpowered/planet_waste/smugglerbunker/bathroom
	name = "Bunkier – Łazienka"
/area/ruin/unpowered/planet_waste/smugglerbunker/cargo
	name = "Bunkier – Ładownia"
	icon_state = "cargo_bay"
/area/ruin/unpowered/planet_waste/smugglerbunker/checkpoint
	name = "Bunkier – Punkt Kontroli Promieniowania"
	icon_state = "engine"
/area/ruin/unpowered/planet_waste/smugglerbunker/controlroom
	name = "Bunkier – Sterownia"
	icon_state = "security"
/area/ruin/unpowered/planet_waste/smugglerbunker/dorms
	name = "Bunkier – Sypialnie"
	icon_state = "crew_quarters"
/area/ruin/unpowered/planet_waste/smugglerbunker/dorms/lounge
	name = "Bunkier – Świetlica"
/area/ruin/unpowered/planet_waste/smugglerbunker/dorms/one
	name = "Bunkier – Sypialnia Pierwsza"
/area/ruin/unpowered/planet_waste/smugglerbunker/dorms/two
	name = "Bunkier – Sypialnia Druga"
/area/ruin/unpowered/planet_waste/smugglerbunker/engineering
	name = "Bunkier – Inżynieria"
	icon_state = "engine"
/area/ruin/unpowered/planet_waste/smugglerbunker/killroom
	name = "Bunkier – Komora Śmierci"
	icon_state = "red"
/area/ruin/unpowered/planet_waste/smugglerbunker/killroom/drones
	name = "Bunkier – Hangar Dronów"
/area/ruin/unpowered/planet_waste/smugglerbunker/lab
	name = "Bunkier – Laboratorium"
	icon_state = "purple"
/area/ruin/unpowered/planet_waste/smugglerbunker/medbay
	name = "Bunkier – Ambulatorium"
	icon_state = "blue"
/area/ruin/unpowered/planet_waste/smugglerbunker/mess
	name = "Bunkier – Mesa"
	icon_state = "hallC"
/area/ruin/unpowered/planet_waste/smugglerbunker/radiation
	name = "Bunkier – Komora Promieniowania"
	icon_state = "engine"

// Kopie obszarów dla ruin pola bitwy (te same pomieszczenia, osobne obszary)

/area/ruin/unpowered/planet_battlefield
	name = "Ruiny Pola Bitwy"
	icon_state = "away"

/area/ruin/unpowered/planet_battlefield/cave
	name = "Jaskinia"
	icon_state = "unexplored"
	always_unpowered = TRUE
	sound_environment = SOUND_ENVIRONMENT_CAVE

/area/ruin/unpowered/planet_battlefield/shipbreaking
	name = "Polowe Złomowisko"
	icon_state = "green"
/area/ruin/unpowered/planet_battlefield/shipbreaking/bay
	name = "Polowe Złomowisko – Dok"
	icon_state = "engine"
/area/ruin/unpowered/planet_battlefield/shipbreaking/canteen
	name = "Polowe Złomowisko – Stołówka"
	icon_state = "hallC"
/area/ruin/unpowered/planet_battlefield/shipbreaking/dorms
	name = "Polowe Złomowisko – Sypialnia"
	icon_state = "bridge"
/area/ruin/unpowered/planet_battlefield/shipbreaking/ship
	name = "Polowe Złomowisko – Wrak"
	icon_state = "red"

/area/ruin/unpowered/planet_battlefield/icwbase
	name = "Zrujnowana Baza Frontowa"
	icon_state = "bridge"
/area/ruin/unpowered/planet_battlefield/icwbase/tcom
	name = "Baza Frontowa – Telekomunikacja"
/area/ruin/unpowered/planet_battlefield/icwbase/cic
	name = "Baza Frontowa – Dowodzenie"
/area/ruin/unpowered/planet_battlefield/icwbase/vault
	name = "Baza Frontowa – Skarbiec"
	icon_state = "security"
/area/ruin/unpowered/planet_battlefield/icwbase/eng
	name = "Baza Frontowa – Inżynieria"
	icon_state = "engine"
/area/ruin/unpowered/planet_battlefield/icwbase/tcommoni
	name = "Baza Frontowa – Nasłuch Telekomunikacji"
/area/ruin/unpowered/planet_battlefield/icwbase/warehouse
	name = "Baza Frontowa – Magazyn"
	icon_state = "storage"
/area/ruin/unpowered/planet_battlefield/icwbase/hab
	name = "Baza Frontowa – Część Mieszkalna"
	icon_state = "crew_quarters"
/area/ruin/unpowered/planet_battlefield/icwbase/cybersun
	name = "Baza Frontowa – Skrzydło Cybersun"
	icon_state = "blue"

/area/ruin/unpowered/planet_battlefield/smugglerbunker
	name = "Bunkier Maruderów"
	icon_state = "hallC"
/area/ruin/unpowered/planet_battlefield/smugglerbunker/exterior
	name = "Bunkier Maruderów – Teren Zewnętrzny"
	icon_state = "green"
/area/ruin/unpowered/planet_battlefield/smugglerbunker/armory
	name = "Bunkier Maruderów – Zbrojownia"
	icon_state = "security"
/area/ruin/unpowered/planet_battlefield/smugglerbunker/bathroom
	name = "Bunkier Maruderów – Łazienka"
/area/ruin/unpowered/planet_battlefield/smugglerbunker/cargo
	name = "Bunkier Maruderów – Ładownia"
	icon_state = "cargo_bay"
/area/ruin/unpowered/planet_battlefield/smugglerbunker/checkpoint
	name = "Bunkier Maruderów – Punkt Kontroli Promieniowania"
	icon_state = "engine"
/area/ruin/unpowered/planet_battlefield/smugglerbunker/controlroom
	name = "Bunkier Maruderów – Sterownia"
	icon_state = "security"
/area/ruin/unpowered/planet_battlefield/smugglerbunker/dorms
	name = "Bunkier Maruderów – Sypialnie"
	icon_state = "crew_quarters"
/area/ruin/unpowered/planet_battlefield/smugglerbunker/dorms/lounge
	name = "Bunkier Maruderów – Świetlica"
/area/ruin/unpowered/planet_battlefield/smugglerbunker/dorms/one
	name = "Bunkier Maruderów – Sypialnia Pierwsza"
/area/ruin/unpowered/planet_battlefield/smugglerbunker/dorms/two
	name = "Bunkier Maruderów – Sypialnia Druga"
/area/ruin/unpowered/planet_battlefield/smugglerbunker/engineering
	name = "Bunkier Maruderów – Inżynieria"
	icon_state = "engine"
/area/ruin/unpowered/planet_battlefield/smugglerbunker/killroom
	name = "Bunkier Maruderów – Komora Śmierci"
	icon_state = "red"
/area/ruin/unpowered/planet_battlefield/smugglerbunker/killroom/drones
	name = "Bunkier Maruderów – Hangar Dronów"
/area/ruin/unpowered/planet_battlefield/smugglerbunker/lab
	name = "Bunkier Maruderów – Laboratorium"
	icon_state = "purple"
/area/ruin/unpowered/planet_battlefield/smugglerbunker/medbay
	name = "Bunkier Maruderów – Ambulatorium"
	icon_state = "blue"
/area/ruin/unpowered/planet_battlefield/smugglerbunker/mess
	name = "Bunkier Maruderów – Mesa"
	icon_state = "hallC"
/area/ruin/unpowered/planet_battlefield/smugglerbunker/radiation
	name = "Bunkier Maruderów – Komora Promieniowania"
	icon_state = "engine"

/obj/item/paper/fluff/ruins/planet_waste/derringer
	name = "NIE CZYTAĆ."
	default_raw_text = "Ciągle zapominam, gdzie zostawiam derringera, więc trzymam go w sejfie. PRZYPOMNIENIE: sejf stoi obok jedynej rośliny, która jakoś przeżywa w tym durnym habitacie."
