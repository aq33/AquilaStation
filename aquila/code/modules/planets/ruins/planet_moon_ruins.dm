// AQUILA: ruiny księżyców przeniesione z Shiptesta (shiptest-ss13/Shiptest, kod AGPLv3, mapy jak kod, grafiki CC BY-SA 3.0):
// _maps/RandomRuins/MoonRuins/ i code/datums/ruins/moon.dm, obszary z code/game/area/areas/ruins/moon.dm.
// W Shiptest to ruiny główne bez kosztu; u nas koszt 10 (jak przy lawie), więc stają tylko jako ruina główna. Większość
// jest wyższa niż połowa zwykłej powierzchni, więc planeta z taką ruiną rośnie do PLANET_SURFACE_SIZE_LARGE.
// Mapy przerobione tools/planets/convert_maps.py z mappings/moon.py (Klika Ramziego -> nasi żołnierze Syndykatu,
// Frontiersmen -> rosyjscy żołnierze, automaty -> hivebot z frakcją obrońców, elektrolizer -> puste ramy maszyn,
// ruda lodu poza zakresem tej partii). Obszary zewnętrzne -> powierzchnia planety.

/datum/map_template/ruin/planet_moon
	prefix = "aquila/_maps/RandomRuins/PlanetMoon/"
	cost = 10

/datum/map_template/ruin/planet_moon/bunker
	name = "Opuszczony Bunkier Maruderów"
	id = "planet_moon_bunker"
	description = "Stary, nieużywany bunkier z czasów wojny. Zawalenia stropów zaczynają niszczyć obiekt."
	suffix = "planet_moon_bunker.dmm"

/datum/map_template/ruin/planet_moon/moonbase
	name = "Baza Księżycowa CLIP-MELD"
	id = "planet_moon_moonbase"
	description = "Opuszczona rafineria CLIP-MELD, którą zajęły kryształy i Frontiersmeni. Kryje wielką żyłę lodu."
	suffix = "planet_moon_moonbase.dmm"

/datum/map_template/ruin/planet_moon/hideout
	name = "Jaskiniowa Kryjówka Ramziego"
	id = "planet_moon_hideout"
	description = "Prowizoryczna kryjówka Kliki Ramziego w jaskini z niewielkim garnizonem."
	suffix = "planet_moon_hideout.dmm"

/datum/map_template/ruin/planet_moon/cybergrind
	name = "Laboratorium Robotyki Virtual Solutions"
	id = "planet_moon_cybergrind"
	description = "Księżycowe laboratorium robotyki działu Virtual Solutions Cybersun, opanowane przez złośliwą SI."
	suffix = "planet_moon_cybergrind.dmm"

// Obszary ruin (pomieszczenia z APC)

/area/ruin/unpowered/planet_moon/bunker
	name = "Bunkier Maruderów – Korytarz"
	icon_state = "hallC"

/area/ruin/unpowered/planet_moon/bunker/armory
	name = "Bunkier Maruderów – Zbrojownia"
	icon_state = "security"

/area/ruin/unpowered/planet_moon/bunker/bathroom
	name = "Bunkier Maruderów – Umywalnia"
	icon_state = "toilet"

/area/ruin/unpowered/planet_moon/bunker/cargo
	name = "Bunkier Maruderów – Spiżarnia"
	icon_state = "cargo_warehouse"

/area/ruin/unpowered/planet_moon/bunker/dorms/lounge
	name = "Bunkier Maruderów – Świetlica"
	icon_state = "blue"

/area/ruin/unpowered/planet_moon/bunker/dorms/one
	name = "Bunkier Maruderów – Sypialnia 1"
	icon_state = "crew_quarters"

/area/ruin/unpowered/planet_moon/bunker/dorms/two
	name = "Bunkier Maruderów – Sypialnia 2"
	icon_state = "crew_quarters"

/area/ruin/unpowered/planet_moon/bunker/drone
	name = "Bunkier Maruderów – Pomieszczenie Dronów"
	icon_state = "security"

/area/ruin/unpowered/planet_moon/bunker/engineering
	name = "Bunkier Maruderów – Inżynieria"
	icon_state = "engine"

/area/ruin/unpowered/planet_moon/cybergrind/aicore
	name = "Laboratorium Robotyki – Rdzeń SI"
	icon_state = "ai_chamber"

/area/ruin/unpowered/planet_moon/cybergrind/atrium
	name = "Laboratorium Robotyki – Atrium"
	icon_state = "cafeteria"

/area/ruin/unpowered/planet_moon/cybergrind/bathroom
	name = "Laboratorium Robotyki – Łazienka"
	icon_state = "toilet"

/area/ruin/unpowered/planet_moon/cybergrind/cargo
	name = "Laboratorium Robotyki – Magazyn"
	icon_state = "cargo_warehouse"

/area/ruin/unpowered/planet_moon/cybergrind/centralhallway
	name = "Laboratorium Robotyki – Korytarz Główny"
	icon_state = "hallC"

/area/ruin/unpowered/planet_moon/cybergrind/decontam
	name = "Laboratorium Robotyki – Dekontaminacja"
	icon_state = "green"

/area/ruin/unpowered/planet_moon/cybergrind/directors
	name = "Laboratorium Robotyki – Gabinet Dyrektora"
	icon_state = "bridge"

/area/ruin/unpowered/planet_moon/cybergrind/dormitory
	name = "Laboratorium Robotyki – Skrzydło Sypialne"
	icon_state = "red"

/area/ruin/unpowered/planet_moon/cybergrind/engineering
	name = "Laboratorium Robotyki – Inżynieria"
	icon_state = "engine"

/area/ruin/unpowered/planet_moon/cybergrind/hangar
	name = "Laboratorium Robotyki – Hangar"
	icon_state = "shuttlered"

/area/ruin/unpowered/planet_moon/cybergrind/lab
	name = "Laboratorium Robotyki – Pracownia"
	icon_state = "green"

/area/ruin/unpowered/planet_moon/cybergrind/medbay
	name = "Laboratorium Robotyki – Ambulatorium"
	icon_state = "surgery"

/area/ruin/unpowered/planet_moon/cybergrind/northhallway
	name = "Laboratorium Robotyki – Korytarz Północny"
	icon_state = "hallC"

/area/ruin/unpowered/planet_moon/cybergrind/observatory
	name = "Laboratorium Robotyki – Obserwatorium"
	icon_state = "blue"

/area/ruin/unpowered/planet_moon/cybergrind/reception
	name = "Laboratorium Robotyki – Hol"
	icon_state = "hallC"

/area/ruin/unpowered/planet_moon/cybergrind/secdorm
	name = "Laboratorium Robotyki – Sypialnia Rozjemców"
	icon_state = "security"

/area/ruin/unpowered/planet_moon/cybergrind/simdomeengi
	name = "Laboratorium Robotyki – Dojście do Kopuły"
	icon_state = "engine"

/area/ruin/unpowered/planet_moon/cybergrind/terrarium
	name = "Laboratorium Robotyki – Terrarium"
	icon_state = "green"

/area/ruin/unpowered/planet_moon/cybergrind/terrarium/simdome
	name = "Laboratorium Robotyki – Kopuła Symulacyjna"
	icon_state = "green"

/area/ruin/unpowered/planet_moon/hideout
	name = "Kryjówka Ramziego – Korytarz"
	icon_state = "hallC"

/area/ruin/unpowered/planet_moon/hideout/bathroom
	name = "Kryjówka Ramziego – Łazienka"
	icon_state = "toilet"

/area/ruin/unpowered/planet_moon/hideout/bathroom/officer
	name = "Kryjówka Ramziego – Łazienka Twierdzy"
	icon_state = "toilet"

/area/ruin/unpowered/planet_moon/hideout/canteen
	name = "Kryjówka Ramziego – Stołówka"
	icon_state = "kitchen"

/area/ruin/unpowered/planet_moon/hideout/command
	name = "Kryjówka Ramziego – Stanowisko Obserwacyjne"
	icon_state = "bridge"

/area/ruin/unpowered/planet_moon/hideout/dorms
	name = "Kryjówka Ramziego – Kwatery"
	icon_state = "crew_quarters"

/area/ruin/unpowered/planet_moon/hideout/dorms/five
	name = "Kryjówka Ramziego – Sypialnia 5"
	icon_state = "red"

/area/ruin/unpowered/planet_moon/hideout/dorms/four
	name = "Kryjówka Ramziego – Sypialnia 4"
	icon_state = "red"

/area/ruin/unpowered/planet_moon/hideout/dorms/officer
	name = "Kryjówka Ramziego – Świetlica Oficerska"
	icon_state = "blue"

/area/ruin/unpowered/planet_moon/hideout/dorms/officer/bedroom
	name = "Kryjówka Ramziego – Kwatera Oficera"
	icon_state = "blue"

/area/ruin/unpowered/planet_moon/hideout/dorms/one
	name = "Kryjówka Ramziego – Sypialnia 1"
	icon_state = "crew_quarters"

/area/ruin/unpowered/planet_moon/hideout/dorms/three
	name = "Kryjówka Ramziego – Sypialnia 3"
	icon_state = "red"

/area/ruin/unpowered/planet_moon/hideout/dorms/two
	name = "Kryjówka Ramziego – Sypialnia 2"
	icon_state = "crew_quarters"

/area/ruin/unpowered/planet_moon/hideout/engineering
	name = "Kryjówka Ramziego – Inżynieria"
	icon_state = "engine"

/area/ruin/unpowered/planet_moon/hideout/fortress
	name = "Kryjówka Ramziego – Twierdza"
	icon_state = "security"

/area/ruin/unpowered/planet_moon/moonbase/armory
	name = "Baza Księżycowa CLIP-MELD – Zbrojownia"
	icon_state = "armory"

/area/ruin/unpowered/planet_moon/moonbase/cargo
	name = "Baza Księżycowa CLIP-MELD – Ładownia"
	icon_state = "cargo_warehouse"

/area/ruin/unpowered/planet_moon/moonbase/dorms
	name = "Baza Księżycowa CLIP-MELD – Sypialnia"
	icon_state = "crew_quarters"

/area/ruin/unpowered/planet_moon/moonbase/engineering
	name = "Baza Księżycowa CLIP-MELD – Inżynieria"
	icon_state = "engine"

/area/ruin/unpowered/planet_moon/moonbase/refinery
	name = "Baza Księżycowa CLIP-MELD – Rafineria"
	icon_state = "storage"
