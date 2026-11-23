// AQUILA: ruiny kosmiczne dla planety „słaby sygnał” przeniesione z Shiptesta (shiptest-ss13/Shiptest, kod AGPLv3, mapy jak
// kod, grafiki CC BY-SA 3.0): _maps/RandomRuins/SpaceRuins/ i code/datums/ruins/space.dm, obszary z
// code/game/area/areas/ruins/space.dm. Tylko jako ruina główna (koszt 10); wszystkie są większe niż połowa zwykłej
// powierzchni, więc planeta rośnie do PLANET_SURFACE_SIZE_LARGE.
// Mapy przerobione tools/planets/convert_maps.py z mappings/moon.py i space.py. Pusta przestrzeń i skała asteroidy wokół
// ruin -> powierzchnia planety; obszary bez grawitacji (wraki, promy) zostają bez grawitacji jak w Shiptest.

/datum/map_template/ruin/planet_space
	prefix = "aquila/_maps/RandomRuins/PlanetSpace/"
	cost = 10

/datum/map_template/ruin/planet_space/singularity_lab
	name = "Laboratorium Osobliwości"
	id = "planet_space_singularity_lab"
	description = "Zarośnięty ośrodek badawczy z uśpioną osobliwością i mnóstwem roślin."
	suffix = "planet_space_singularity_lab.dmm"

/datum/map_template/ruin/planet_space/scrapstation
	name = "Stacja Złomiarska Kliki Ramziego"
	id = "planet_space_scrapstation"
	description = "Wysunięta baza Syndykatu z czasów wojny, teraz dom Kliki Ramziego i jej najnowszego łupu."
	suffix = "planet_space_scrapstation.dmm"

/datum/map_template/ruin/planet_space/deepstorage
	name = "Głęboki Magazyn Vigilitas"
	id = "planet_space_deepstorage"
	description = "Tajny magazyn Vigilitas na ważny i podejrzany ładunek."
	suffix = "planet_space_deepstorage.dmm"

/datum/map_template/ruin/planet_space/refueling
	name = "Stacja Paliw Makosso-Warra"
	id = "planet_space_refueling"
	description = "Porzucona stacja paliw Makosso-Warra, ewakuowana po próbie zalania jej plazmą. Teraz próbują ją zająć hiveboty i ekipa złomiarzy Ramziego."
	suffix = "planet_space_refueling.dmm"

// Obszary ruin (pomieszczenia z APC)

/area/ruin/space/planet_space/hivebotshuttle
	name = "Prom Hivebotów"
	icon_state = "red"

/area/ruin/space/planet_space/shuttle1
	name = "Prom Frontiersmenów"
	icon_state = "red"

/area/ruin/space/planet_space/shuttle2
	name = "Prom Frontiersmenów"
	icon_state = "red"

/area/ruin/space/planet_space/shuttle3
	name = "Prom Frontiersmenów"
	icon_state = "red"

/area/ruin/space/planet_space/pgf_wreck
	name = "Wrak – Korytarz"
	icon_state = "hallC"

/area/ruin/space/planet_space/pgf_wreck/bridge
	name = "Wrak – Mostek"
	icon_state = "bridge_hallway"

/area/ruin/space/planet_space/pgf_wreck/cargo
	name = "Wrak – Ładownia"
	icon_state = "cargo_bay"

/area/ruin/space/planet_space/pgf_wreck/dorms
	name = "Wrak – Sypialnia"
	icon_state = "yellow"

/area/ruin/space/planet_space/pgf_wreck/engineering
	name = "Wrak – Inżynieria"
	icon_state = "engine"

/area/ruin/space/has_grav/planet_space/deepstorage/bathroom
	name = "Magazyn Vigilitas – Łazienka"
	icon_state = "toilet"

/area/ruin/space/has_grav/planet_space/deepstorage/canteen
	name = "Magazyn Vigilitas – Stołówka"
	icon_state = "kitchen"

/area/ruin/space/has_grav/planet_space/deepstorage/cargo
	name = "Magazyn Vigilitas – Ładownia"
	icon_state = "storage"

/area/ruin/space/has_grav/planet_space/deepstorage/crewquarters
	name = "Magazyn Vigilitas – Kwatery Załogi"
	icon_state = "crew_quarters"

/area/ruin/space/has_grav/planet_space/deepstorage/engineering
	name = "Magazyn Vigilitas – Inżynieria"
	icon_state = "engine"

/area/ruin/space/has_grav/planet_space/deepstorage/hallway
	name = "Magazyn Vigilitas – Dolny Korytarz"
	icon_state = "hallS"

/area/ruin/space/has_grav/planet_space/deepstorage/hallway/east
	name = "Magazyn Vigilitas – Korytarz"
	icon_state = "hallF"

/area/ruin/space/has_grav/planet_space/deepstorage/hallway/upper
	name = "Magazyn Vigilitas – Górny Korytarz"
	icon_state = "hallC"

/area/ruin/space/has_grav/planet_space/deepstorage/lobby
	name = "Magazyn Vigilitas – Hol"
	icon_state = "entry"

/area/ruin/space/has_grav/planet_space/deepstorage/lobby/med
	name = "Magazyn Vigilitas – Poczekalnia Ambulatorium"
	icon_state = "medbay"

/area/ruin/space/has_grav/planet_space/deepstorage/med
	name = "Magazyn Vigilitas – Ambulatorium"
	icon_state = "surgery"

/area/ruin/space/has_grav/planet_space/deepstorage/overwatch
	name = "Magazyn Vigilitas – Stanowisko Obserwacyjne"
	icon_state = "red"

/area/ruin/space/has_grav/planet_space/deepstorage/security
	name = "Magazyn Vigilitas – Ochrona"
	icon_state = "security"

/area/ruin/space/has_grav/planet_space/deepstorage/security/bedroom
	name = "Magazyn Vigilitas – Sypialnia Dyrektora"
	icon_state = "blue"

/area/ruin/space/has_grav/planet_space/deepstorage/security/lobby
	name = "Magazyn Vigilitas – Poczekalnia Dyrektora"
	icon_state = "security"

/area/ruin/space/has_grav/planet_space/deepstorage/security/office
	name = "Magazyn Vigilitas – Gabinet Dyrektora"
	icon_state = "bridge"

/area/ruin/space/has_grav/planet_space/deepstorage/security/vault
	name = "Magazyn Vigilitas – Skarbiec"
	icon_state = "security"

/area/ruin/space/has_grav/planet_space/refuelingpost/armory
	name = "Stacja Paliw – Ochrona"
	icon_state = "security"

/area/ruin/space/has_grav/planet_space/refuelingpost/bridge
	name = "Stacja Paliw – Mostek"
	icon_state = "bridge"

/area/ruin/space/has_grav/planet_space/refuelingpost/cargo
	name = "Stacja Paliw – Magazyn"
	icon_state = "storage"

/area/ruin/space/has_grav/planet_space/refuelingpost/cargobay
	name = "Stacja Paliw – Ładownia"
	icon_state = "quartstorage"

/area/ruin/space/has_grav/planet_space/refuelingpost/dorms
	name = "Stacja Paliw – Sypialnia"
	icon_state = "crew_quarters"

/area/ruin/space/has_grav/planet_space/refuelingpost/engineering
	name = "Stacja Paliw – Inżynieria"
	icon_state = "engine"

/area/ruin/space/has_grav/planet_space/refuelingpost/infirmary
	name = "Stacja Paliw – Izba Chorych"
	icon_state = "surgery"

/area/ruin/space/has_grav/planet_space/refuelingpost/lower
	name = "Stacja Paliw – Dolny Korytarz"
	icon_state = "entry"

/area/ruin/space/has_grav/planet_space/refuelingpost/solarstorage
	name = "Stacja Paliw – Sterownia Paneli"
	icon_state = "engine"

/area/ruin/space/has_grav/planet_space/refuelingpost/starboard
	name = "Stacja Paliw – Korytarz Sterburtowy"
	icon_state = "hallS"

/area/ruin/space/has_grav/planet_space/refuelingpost/upper
	name = "Stacja Paliw – Górny Korytarz"
	icon_state = "hallF"

/area/ruin/space/has_grav/planet_space/singularitylab
	name = "Laboratorium Osobliwości – Korytarze"
	icon_state = "hallC"

/area/ruin/space/has_grav/planet_space/singularitylab/cargo
	name = "Laboratorium Osobliwości – Ładownia"
	icon_state = "storage"

/area/ruin/space/has_grav/planet_space/singularitylab/civvie
	name = "Laboratorium Osobliwości – Kwatery"
	icon_state = "Sleep"

/area/ruin/space/has_grav/planet_space/singularitylab/engineering
	name = "Laboratorium Osobliwości – Inżynieria"
	icon_state = "blue"

/area/ruin/space/has_grav/planet_space/singularitylab/hangar
	name = "Laboratorium Osobliwości – Hangar"
	icon_state = "yellow"

/area/ruin/space/has_grav/planet_space/singularitylab/lab
	name = "Ośrodek Badań nad Zastosowaniami Wysokich Energii"
	icon_state = "green"

/area/ruin/space/has_grav/planet_space/singularitylab/reactor
	name = "Laboratorium Osobliwości – Reaktor Osobliwości"
	icon_state = "engine"

/area/ruin/space/has_grav/powered/planet_space/ramzi_station
	name = "Stacja Złomiarska Ramziego – Dolny Korytarz"
	icon_state = "entry"

/area/ruin/space/has_grav/powered/planet_space/ramzi_station/armory
	name = "Stacja Złomiarska Ramziego – Zbrojownia"
	icon_state = "security"

/area/ruin/space/has_grav/powered/planet_space/ramzi_station/canteen
	name = "Stacja Złomiarska Ramziego – Stołówka"
	icon_state = "kitchen"

/area/ruin/space/has_grav/powered/planet_space/ramzi_station/cargo
	name = "Stacja Złomiarska Ramziego – Ładownia"
	icon_state = "cargo_bay"

/area/ruin/space/has_grav/powered/planet_space/ramzi_station/dorms
	name = "Stacja Złomiarska Ramziego – Sypialnia"
	icon_state = "crew_quarters"

/area/ruin/space/has_grav/powered/planet_space/ramzi_station/engi
	name = "Stacja Złomiarska Ramziego – Inżynieria"
	icon_state = "engine"

/area/ruin/space/has_grav/powered/planet_space/ramzi_station/foreman
	name = "Stacja Złomiarska Ramziego – Gabinet Brygadzisty"
	icon_state = "bridge"

/area/ruin/space/has_grav/powered/planet_space/ramzi_station/hangar
	name = "Stacja Złomiarska Ramziego – Hangar"
	icon_state = "hangar"

/area/ruin/space/has_grav/powered/planet_space/ramzi_station/med
	name = "Stacja Złomiarska Ramziego – Ambulatorium"
	icon_state = "surgery"

/area/ruin/space/has_grav/powered/planet_space/ramzi_station/solars
	name = "Stacja Złomiarska Ramziego – Panele Słoneczne"
	icon_state = "panelsAP"

/area/ruin/space/has_grav/powered/planet_space/ramzi_station/starboard
	name = "Stacja Złomiarska Ramziego – Korytarz Sterburtowy"
	icon_state = "hallS"

/area/ruin/space/has_grav/powered/planet_space/ramzi_station/toilet
	name = "Stacja Złomiarska Ramziego – Umywalnia"
	icon_state = "toilet"

/area/ruin/space/has_grav/powered/planet_space/ramzi_station/upper
	name = "Stacja Złomiarska Ramziego – Górny Korytarz"
	icon_state = "hallF"
