// AQUILA: ruiny planet wulkanicznych przeniesione z Shiptesta (shiptest-ss13/Shiptest, kod AGPLv3, mapy jak kod,
// grafiki CC BY-SA 3.0): _maps/RandomRuins/LavaRuins/ i code/datums/ruins/lavaland.dm.
// Shiptest nie daje tym ruinom kosztu ani wagi (wszystkie są tam ruinami głównymi), więc koszt 10 jest nasz:
// ruiny są za duże na małe ruiny z budżetu (ruin_budget planety wulkanicznej to 4), stają tylko jako ruina główna.
//
// Mapy przerobione skryptem (Shiptest -> nasze typy), najważniejsze decyzje:
// - Klika Ramziego (/mob/living/basic/human/ramzi/*) -> nasi żołnierze Syndykatu (/mob/living/basic/trooper/syndicate/*)
//   według broni; Vigilitas (warra/elite) -> żołnierz NT; psy Ramziego -> port /mob/living/basic/mining/ramzi_hound;
//   roboty automated/* -> hivebot z frakcją obrońców; goliaty i legiony -> nasze basic moby z portu fauny.
// - Zwłoki frakcji -> nasze zwłoki Syndykatu, NT, piratów, asystenta; wieżyczki statkowe -> wieżyczki Syndykatu.
// - Dekale Shiptesta (corner, trimline, spline, siding/black, industrial) -> nasze tile/trimline/siding/stripes
//   z kolorem i przezroczystością Shiptesta w edycji mapy; kierunki przeliczone tam, gdzie stany ikon są obrócone.
// - Światła, APC, gaśnice, tablice, telewizory i interkomy /directional/* -> nasze typy z dir lub przesunięciem.
// - Szafki ścienne -> zwykłe szafki na tym samym polu; magazyny skafandrów "inherit" -> nasz SSU ze skafandrem z pola.
// - Złom (salvage) -> ruda tego metalu; bronie i amunicja -> najbliższe nasze; dynamit -> IED; miny -> /obj/effect/mine.
// - Ściany betonowe -> nasze ściany (beton Shiptesta ma smoothing bitmaskowy); posadzki betonowe -> port niżej.
// - Podłogi */lava i */lavaland -> nasz typ z initial_gas_mix Lavalandu; bazalt i piasek */lit -> bez /lit
//   (oświetlenie daje obszar powierzchni planety).
// - Pominięte: platformy przemysłowe, zelektryzowana woda i jej wyłącznik, atmosferyczna ściana tarcz z przyciskiem,
//   faks, lądowisko podstatku, regały na skrzynie, wraki maszyn (-> puste ramy), drobne przedmioty bez odpowiednika
//   (uplink czarnego rynku, licznik amunicji, kastet, ręczniki, bilety, dłuto, worki betonu i podobne).
// - Obszary: zewnętrzne /area/overmap_encounter/planetoid/lava -> /area/lavaland/surface/outdoors (load_ruin przepina je
//   na powierzchnię planety), jaskinie -> /area/ruin/unpowered/planet_lava/cave, pomieszczenia -> obszary niżej.

/datum/map_template/ruin/planet_lava
	prefix = "aquila/_maps/RandomRuins/PlanetLava/"
	cost = 10

/datum/map_template/ruin/planet_lava/dynamite_hole
	name = "Dynamitowa Dziura"
	id = "planet_lava_dynamite_hole"
	description = "Placówka badawcza CLIP-LAND opanowana przez Klikę Ramziego, która dokopuje się do reszty jaskini, by założyć tam bazę."
	suffix = "planet_lava_dynamite_hole.dmm"

/datum/map_template/ruin/planet_lava/wrecked_factory
	name = "Zniszczona Fabryka"
	id = "planet_lava_wrecked_factory"
	description = "Zakład przetwórczy Makosso-Warra po napadzie piratów, w którym zginęła większość załogi. Biura na razie się trzymają."
	suffix = "planet_lava_wrecked_factory.dmm"

/datum/map_template/ruin/planet_lava/crashed_starwalker
	name = "Rozbity Starwalker"
	id = "planet_lava_crashed_starwalker"
	description = "Rozbity statek piracki. Wygląda na to, że jego załoga zginęła dawno temu."
	suffix = "planet_lava_crashed_starwalker.dmm"

/datum/map_template/ruin/planet_lava/listening_post
	name = "Opuszczony Posterunek Nasłuchowy"
	id = "planet_lava_listening_post"
	description = "Opuszczony posterunek nasłuchowy Cybersun. Wygląda na to, że Klika Ramziego interesuje się tym miejscem."
	suffix = "planet_lava_listening_post.dmm"

/datum/map_template/ruin/planet_lava/hardliner_holdout
	name = "Ostatni Bastion Twardogłowych"
	id = "planet_lava_hardliner_holdout"
	description = "Klika Ramziego oblega placówkę Twardogłowych z potężną automatyczną obroną."
	suffix = "planet_lava_hardliner_holdout.dmm"

/// Ruiny planet wulkanicznych (nazwa -> szablon). SSmapping wczytuje je razem z innymi ruinami do ruins_templates,
/// ale nie do lava_ruins_templates, więc nie trafiają na Lavaland.
GLOBAL_LIST_EMPTY(planet_lava_ruin_templates)

/// Lista ruin planet wulkanicznych; buduje się przy pierwszym użyciu z szablonów wczytanych przez SSmapping
/proc/get_planet_lava_ruin_templates()
	if(!length(GLOB.planet_lava_ruin_templates))
		for(var/name in SSmapping.ruins_templates)
			var/datum/map_template/ruin/ruin = SSmapping.ruins_templates[name]
			if(istype(ruin, /datum/map_template/ruin/planet_lava))
				GLOB.planet_lava_ruin_templates[name] = ruin
	return GLOB.planet_lava_ruin_templates

// Obszary ruin. Pomieszczenia z APC (Shiptest: unpowered = zasilanie z APC ruiny), fabryka bez zasilania jak w Shiptest.

/// Jaskinie wokół ruin: ciemne, bez pogody
/area/ruin/unpowered/planet_lava/cave
	name = "Jaskinia"
	icon_state = "unexplored"
	always_unpowered = TRUE
	sound_environment = SOUND_ENVIRONMENT_CAVE

/area/ruin/unpowered/planet_lava/listening_post
	name = "Posterunek Nasłuchowy – Hol"
	icon_state = "yellow"

/area/ruin/unpowered/planet_lava/listening_post/commons
	name = "Posterunek Nasłuchowy – Część Wspólna"
	icon_state = "green"

/area/ruin/unpowered/planet_lava/listening_post/canteen
	name = "Posterunek Nasłuchowy – Stołówka"
	icon_state = "purple"

/area/ruin/unpowered/planet_lava/listening_post/operations
	name = "Posterunek Nasłuchowy – Operacje"
	icon_state = "hallC"

/area/ruin/unpowered/planet_lava/listening_post/engineering
	name = "Posterunek Nasłuchowy – Maszynownia"
	icon_state = "dk_yellow"

/area/ruin/unpowered/planet_lava/crashed_starwalker
	name = "Rozbity Statek Piracki"
	icon_state = "away"

/area/ruin/unpowered/planet_lava/dynamite_hole
	name = "Dynamitowa Dziura – Teren"
	icon_state = "bluenew"

/area/ruin/unpowered/planet_lava/dynamite_hole/security
	name = "Dynamitowa Dziura – Ochrona"
	icon_state = "red"

/area/ruin/unpowered/planet_lava/dynamite_hole/living_quarters
	name = "Dynamitowa Dziura – Kwatery Mieszkalne"
	icon_state = "purple"

/area/ruin/unpowered/planet_lava/dynamite_hole/medbay
	name = "Dynamitowa Dziura – Laboratorium"

/area/ruin/unpowered/planet_lava/dynamite_hole/engineering
	name = "Dynamitowa Dziura – Inżynieria"
	icon_state = "cargo_warehouse"

/area/ruin/unpowered/planet_lava/dynamite_hole/dorms
	name = "Dynamitowa Dziura – Sypialnia"
	icon_state = "yellow"

/area/ruin/unpowered/planet_lava/dynamite_hole/dorms/two
	name = "Dynamitowa Dziura – Druga Sypialnia"

/area/ruin/unpowered/planet_lava/dynamite_hole/gear
	name = "Dynamitowa Dziura – Magazyn Sprzętu"
	icon_state = "green"

/area/ruin/unpowered/planet_lava/dynamite_hole/dogs
	name = "Dynamitowa Dziura – Dynamitowy Dół"
	icon_state = "red"

/area/ruin/powered/planet_lava/factory
	name = "Zniszczona Fabryka"
	icon_state = "away"

/area/ruin/powered/planet_lava/factory/warehouse
	name = "Zniszczona Fabryka – Magazyn"
	icon_state = "cargo_warehouse"

/area/ruin/powered/planet_lava/factory/administrative
	name = "Zniszczona Fabryka – Skrzydło Administracyjne"
	icon_state = "bridge_hallway"

/area/ruin/powered/planet_lava/factory/manager_office
	name = "Zniszczona Fabryka – Gabinet Kierownika"
	icon_state = "bridge"

/area/ruin/powered/planet_lava/factory/lobby
	name = "Zniszczona Fabryka – Hol"
	icon_state = "hallC"

/area/ruin/powered/planet_lava/factory/dorms
	name = "Zniszczona Fabryka – Sypialnia"
	icon_state = "crew_quarters"

/area/ruin/unpowered/planet_lava/holdout
	name = "Bastion Twardogłowych"
	icon_state = "away"

/area/ruin/unpowered/planet_lava/holdout/office
	name = "Bastion – Gabinet Sierżanta"
	icon_state = "bridge"

/area/ruin/unpowered/planet_lava/holdout/armory
	name = "Bastion – Zbrojownia"
	icon_state = "armory"

/area/ruin/unpowered/planet_lava/holdout/warehousea
	name = "Bastion – Magazyn Alfa"
	icon_state = "cargo_warehouse"

/area/ruin/unpowered/planet_lava/holdout/warehouseb
	name = "Bastion – Magazyn Bravo"
	icon_state = "auxstorage"

/area/ruin/unpowered/planet_lava/holdout/mainhall
	name = "Bastion – Korytarz"
	icon_state = "entry"

/area/ruin/unpowered/planet_lava/holdout/engineering
	name = "Bastion – Inżynieria"
	icon_state = "engine"

/area/ruin/unpowered/planet_lava/holdout/kitchen
	name = "Bastion – Kuchnia"
	icon_state = "kitchen"

/area/ruin/unpowered/planet_lava/holdout/mess
	name = "Bastion – Mesa"
	icon_state = "cafeteria"

/area/ruin/unpowered/planet_lava/holdout/barracks
	name = "Bastion – Koszary"
	icon_state = "crew_quarters"

/area/ruin/unpowered/planet_lava/holdout/tcomms
	name = "Bastion – Telekomunikacja"
	icon_state = "tcom_sat_cham"

/area/ruin/unpowered/planet_lava/holdout/ramziflea
	name = "Bastion – Statek Klasy Flea"
	icon_state = "syndie-ship"

/area/ruin/unpowered/planet_lava/holdout/ramzihq
	name = "Bastion – Kwatera Kliki Ramziego"
	icon_state = "syndie-control"
