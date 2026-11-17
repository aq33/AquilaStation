// AQUILA: ruiny i greeble planet lodowych przeniesione z Shiptesta (shiptest-ss13/Shiptest, kod AGPLv3, mapy jak kod,
// grafiki CC BY-SA 3.0): _maps/RandomRuins/IceRuins/, _maps/templates/greebles/ice/, code/datums/ruins/icemoon.dm,
// code/datums/mapgen/greebles/iceplanet.dm.
// Wszystkie ruiny są ruinami głównymi (jak w Shiptest, gdzie planeta ma jedną ruinę). Za duże na zwykłą powierzchnię
// (transportowiec, laboratorium, ośrodek szkoleniowy) powiększają planetę do 191 x 191. Małych ruin z budżetu nie ma:
// te planety dostają tylko greeble.
// Mapy przerobione skryptem tools/planets/convert_maps.py (mappings/ice.py, ice_areas.py, ice_tr.py, auto.py), potem
// kable na smartwires i tools/planets/fix_connections.py (urwane rury po usuniętych urządzeniach statków przycięte).
// Najważniejsze zamiany: ludzie frakcji (frontiersmen, pustelnicy) -> nasi piraci, Klika Ramziego -> żołnierze Syndykatu,
// fauna Shiptesta -> nasze basic moby, wieżyczki frakcji -> wieżyczki Syndykatu, broń i amunicja -> najbliższe nasze,
// zagrożenia (iskry, alarmy, beczki z odpadami), platformy i faksy pominięte; nazwy i notatki na mapach przetłumaczone.

/datum/map_template/ruin/planet_ice
	prefix = "aquila/_maps/RandomRuins/PlanetIce/"
	cost = 10

/datum/map_template/ruin/planet_ice/ice_lodge
	name = "Lodowa Chata"
	id = "planet_ice_ice_lodge"
	description = "Według zapisów osada należy do SRM, ale od dawna nikt się stamtąd nie odezwał. Ciekawe, co się stało?"
	suffix = "planet_ice_ice_lodge.dmm"

/datum/map_template/ruin/planet_ice/tesla_lab
	name = "Laboratorium Badawcze CLIP"
	id = "planet_ice_tesla_lab"
	description = "CLIP stracił kontakt z jednym ze swoich laboratoriów badań anomalii. Raporty sugerują, że stoją za tym piraci."
	suffix = "planet_ice_tesla_lab.dmm"

/datum/map_template/ruin/planet_ice/training_center
	name = "Ośrodek Szkoleniowy Kliki Ramziego"
	id = "planet_ice_training_center"
	description = "Opuszczony ośrodek szkoleniowy z pierwszych dni Wojny Międzykorporacyjnej. O dziwo wciąż ktoś w nim mieszka."
	suffix = "planet_ice_training_center.dmm"

/datum/map_template/ruin/planet_ice/downed_transport
	name = "Rozbity Transportowiec"
	id = "planet_ice_downed_transport"
	description = "Na pobliskim lodowym świecie widziano nieoznakowane budowle, a na orbicie właśnie zaginął transportowiec z Gezeny."
	suffix = "planet_ice_downed_transport.dmm"

/datum/map_template/ruin/planet_ice/command_post
	name = "Posterunek Dowodzenia Kliki Ramziego"
	id = "planet_ice_command_post"
	description = "Posterunek Kliki Ramziego, z którego kieruje się napadami i łącznością w sektorze."
	suffix = "planet_ice_command_post.dmm"

/// Ruiny tego typu planety (nazwa -> szablon) z szablonów wczytanych przez SSmapping
GLOBAL_LIST_EMPTY(planet_ice_ruin_templates)

/proc/get_planet_ice_ruin_templates()
	if(!length(GLOB.planet_ice_ruin_templates))
		for(var/name in SSmapping.ruins_templates)
			var/datum/map_template/ruin/ruin = SSmapping.ruins_templates[name]
			if(istype(ruin, /datum/map_template/ruin/planet_ice))
				GLOB.planet_ice_ruin_templates[name] = ruin
	return GLOB.planet_ice_ruin_templates

// Greeble (spawnery stawiane przez biomy, wagi map jak w Shiptest)

/obj/effect/greeble_spawner/ice
	greeble_maps = list(
		"aquila/_maps/greebles/ice/greeble_ice_1.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_2.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_3.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_4.dmm" = 3,
		"aquila/_maps/greebles/ice/greeble_ice_5.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_6.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_7.dmm" = 3,
		"aquila/_maps/greebles/ice/greeble_ice_8.dmm" = 3,
		"aquila/_maps/greebles/ice/greeble_ice_9.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_10.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_11.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_12.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_13.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_14.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_15.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_16.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_17.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_18.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_19.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_20.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_21.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_22.dmm" = 1,
		"aquila/_maps/greebles/ice/greeble_ice_23.dmm" = 1,
		"aquila/_maps/greebles/ice/greeble_ice_24.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_25.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_26.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_27.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_28.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_29.dmm" = 1,
		"aquila/_maps/greebles/ice/greeble_ice_30.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_31.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_32.dmm" = 3,
		"aquila/_maps/greebles/ice/greeble_ice_33.dmm" = 3,
		"aquila/_maps/greebles/ice/greeble_ice_34.dmm" = 3,
		"aquila/_maps/greebles/ice/greeble_ice_35.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_36.dmm" = 2,
		"aquila/_maps/greebles/ice/greeble_ice_37.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_38.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_39.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_40.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_41.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_42.dmm" = 3,
		"aquila/_maps/greebles/ice/greeble_ice_43.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_44.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_46.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_47.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_48.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_49.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_50.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_51.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_52.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_53.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_54.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_55.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_56.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_57.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_58.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_59.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_60.dmm" = 5,
		"aquila/_maps/greebles/ice/lossberg.dmm" = 5,
	)

/// Greeble z anomaliami
/obj/effect/greeble_spawner/ice/anomaly
	greeble_maps = list(
		"aquila/_maps/greebles/ice/greeble_ice_anomaly_1.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_anomaly_2.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_anomaly_3.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_anomaly_4.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_anomaly_5.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_anomaly_6.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_anomaly_7.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_anomaly_8.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_anomaly_9.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_anomaly_10.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_anomaly_11.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_anomaly_12.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_anomaly_13.dmm" = 5,
		"aquila/_maps/greebles/ice/greeble_ice_anomaly_14.dmm" = 1,
	)

// Obszary ruin. Pomieszczenia z APC (unpowered = zasilanie z APC ruiny), powered = zawsze zasilone, jak w Shiptest.

/area/ruin/unpowered/planet_ice/command_post
	name = "Posterunek Dowodzenia"
	icon_state = "away"

/area/ruin/unpowered/planet_ice/command_post/armory
	name = "Posterunek Dowodzenia – Zbrojownia"
	icon_state = "armory"

/area/ruin/unpowered/planet_ice/command_post/crew_quarters
	name = "Posterunek Dowodzenia – Kwatery Załogi"
	icon_state = "crew_quarters"

/area/ruin/unpowered/planet_ice/command_post/dorms
	name = "Posterunek Dowodzenia – Sypialnia"
	icon_state = "crew_quarters"

/area/ruin/unpowered/planet_ice/command_post/dorms/second
	name = "Posterunek Dowodzenia – Druga Sypialnia"
	icon_state = "crew_quarters"

/area/ruin/unpowered/planet_ice/command_post/dorms/third
	name = "Posterunek Dowodzenia – Trzecia Sypialnia"
	icon_state = "crew_quarters"

/area/ruin/unpowered/planet_ice/command_post/engi
	name = "Posterunek Dowodzenia – Garaż"
	icon_state = "away"

/area/ruin/unpowered/planet_ice/command_post/eva
	name = "Posterunek Dowodzenia – Magazyn EVA"
	icon_state = "cargo_warehouse"

/area/ruin/unpowered/planet_ice/command_post/kitchen
	name = "Posterunek Dowodzenia – Kuchnia"
	icon_state = "kitchen"

/area/ruin/unpowered/planet_ice/command_post/kitchen/second
	name = "Posterunek Dowodzenia – Druga Kuchnia"
	icon_state = "kitchen"

/area/ruin/unpowered/planet_ice/command_post/mission_control
	name = "Posterunek Dowodzenia – Centrum Kontroli Misji"
	icon_state = "away"

/area/ruin/unpowered/planet_ice/command_post/officer
	name = "Posterunek Dowodzenia – Kwatera Oficera"
	icon_state = "crew_quarters"

/area/ruin/unpowered/planet_ice/command_post/storage
	name = "Posterunek Dowodzenia – Szopa"
	icon_state = "away"

/area/ruin/unpowered/planet_ice/tesla_lab/armory
	name = "Laboratorium CLIP – Zbrojownia"
	icon_state = "armory"

/area/ruin/unpowered/planet_ice/tesla_lab/cargo
	name = "Laboratorium CLIP – Magazyn"
	icon_state = "cargo_warehouse"

/area/ruin/unpowered/planet_ice/tesla_lab/cargo_hall
	name = "Laboratorium CLIP – Korytarz Magazynowy"
	icon_state = "cargo_warehouse"

/area/ruin/unpowered/planet_ice/tesla_lab/central_hall
	name = "Laboratorium CLIP – Korytarz Główny"
	icon_state = "hallC"

/area/ruin/unpowered/planet_ice/tesla_lab/containment
	name = "Laboratorium CLIP – Izolatka Okazów"
	icon_state = "away"

/area/ruin/unpowered/planet_ice/tesla_lab/dorms
	name = "Laboratorium CLIP – Sypialnie"
	icon_state = "crew_quarters"

/area/ruin/unpowered/planet_ice/tesla_lab/engineering
	name = "Laboratorium CLIP – Inżynieria"
	icon_state = "engine"

/area/ruin/unpowered/planet_ice/tesla_lab/haymaker
	name = "Laboratorium CLIP – Kapsuła Haymaker"
	icon_state = "away"

/area/ruin/unpowered/planet_ice/tesla_lab/lab_a
	name = "Laboratorium CLIP – Strefa Badawcza 1"
	icon_state = "away"

/area/ruin/unpowered/planet_ice/tesla_lab/lab_halls
	name = "Laboratorium CLIP – Korytarz Laboratoriów"
	icon_state = "hallC"

/area/ruin/unpowered/planet_ice/tesla_lab/lobby
	name = "Laboratorium CLIP – Hol"
	icon_state = "hallC"

/area/ruin/unpowered/planet_ice/tesla_lab/medbay
	name = "Laboratorium CLIP – Ambulatorium"
	icon_state = "medbay"

/area/ruin/unpowered/planet_ice/tesla_lab/office
	name = "Laboratorium CLIP – Biuro"
	icon_state = "bridge"

/area/ruin/unpowered/planet_ice/tesla_lab/office_two
	name = "Laboratorium CLIP – Gabinet Dyrektora"
	icon_state = "bridge"

/area/ruin/unpowered/planet_ice/tesla_lab/turrets
	name = "Laboratorium CLIP – Wiata z Wieżyczkami"
	icon_state = "away"

/area/ruin/unpowered/planet_ice/training_facility
	name = "Ośrodek Szkoleniowy"
	icon_state = "away"

/area/ruin/unpowered/planet_ice/training_facility/armory
	name = "Ośrodek Szkoleniowy – Zbrojownia"
	icon_state = "armory"

/area/ruin/unpowered/planet_ice/training_facility/cafeteria
	name = "Ośrodek Szkoleniowy – Stołówka"
	icon_state = "kitchen"

/area/ruin/unpowered/planet_ice/training_facility/central_hall
	name = "Ośrodek Szkoleniowy – Korytarz Główny"
	icon_state = "hallC"

/area/ruin/unpowered/planet_ice/training_facility/classroom
	name = "Ośrodek Szkoleniowy – Sala Wykładowa"
	icon_state = "away"

/area/ruin/unpowered/planet_ice/training_facility/course
	name = "Ośrodek Szkoleniowy – Tor Mechów"
	icon_state = "away"

/area/ruin/unpowered/planet_ice/training_facility/demo_course
	name = "Ośrodek Szkoleniowy – Tor Saperski"
	icon_state = "away"

/area/ruin/unpowered/planet_ice/training_facility/dorms
	name = "Ośrodek Szkoleniowy – Koszary"
	icon_state = "crew_quarters"

/area/ruin/unpowered/planet_ice/training_facility/engineering
	name = "Ośrodek Szkoleniowy – Inżynieria"
	icon_state = "engine"

/area/ruin/unpowered/planet_ice/training_facility/garage
	name = "Ośrodek Szkoleniowy – Rampa Załadunkowa"
	icon_state = "away"

/area/ruin/unpowered/planet_ice/training_facility/killship
	name = "Ośrodek Szkoleniowy – Statek Ćwiczebny"
	icon_state = "away"

/area/ruin/unpowered/planet_ice/training_facility/killship/bridge
	name = "Statek Ćwiczebny – Mostek"
	icon_state = "bridge"

/area/ruin/unpowered/planet_ice/training_facility/killship/cargo
	name = "Statek Ćwiczebny – Ładownia"
	icon_state = "away"

/area/ruin/unpowered/planet_ice/training_facility/killship/crew
	name = "Statek Ćwiczebny – Kwatery Załogi"
	icon_state = "crew_quarters"

/area/ruin/unpowered/planet_ice/training_facility/killship/medical
	name = "Statek Ćwiczebny – Ambulatorium"
	icon_state = "medbay"

/area/ruin/unpowered/planet_ice/training_facility/lobby
	name = "Ośrodek Szkoleniowy – Hol"
	icon_state = "hallC"

/area/ruin/unpowered/planet_ice/training_facility/locker_room
	name = "Ośrodek Szkoleniowy – Szatnia"
	icon_state = "away"

/area/ruin/unpowered/planet_ice/training_facility/mech_garage
	name = "Ośrodek Szkoleniowy – Garaż Mechów"
	icon_state = "away"

/area/ruin/unpowered/planet_ice/training_facility/medbay
	name = "Ośrodek Szkoleniowy – Ambulatorium"
	icon_state = "medbay"

/area/ruin/unpowered/planet_ice/training_facility/office_1
	name = "Ośrodek Szkoleniowy – Gabinet Instruktora Mechów"
	icon_state = "bridge"

/area/ruin/unpowered/planet_ice/training_facility/office_2
	name = "Ośrodek Szkoleniowy – Gabinet Sierżanta"
	icon_state = "bridge"

/area/ruin/unpowered/planet_ice/training_facility/range
	name = "Ośrodek Szkoleniowy – Strzelnica"
	icon_state = "away"

/area/ruin/powered/planet_ice/downed_transport/delapidated_cabin
	name = "Rozbity Transportowiec – Zrujnowana Chata"
	icon_state = "away"

/area/ruin/powered/planet_ice/downed_transport/leaning_shack
	name = "Rozbity Transportowiec – Krzywa Buda"
	icon_state = "away"

/area/ruin/powered/planet_ice/downed_transport/outhouse
	name = "Rozbity Transportowiec – Wychodek"
	icon_state = "away"

/area/ruin/powered/planet_ice/downed_transport/ramshackle_workroom
	name = "Rozbity Transportowiec – Rozklekotany Warsztat"
	icon_state = "away"

/area/ruin/powered/planet_ice/lodge/cellar
	name = "Lodowa Chata – Piwnica"
	icon_state = "away"

/area/ruin/powered/planet_ice/lodge/gear_room
	name = "Lodowa Chata – Magazyn Sprzętu"
	icon_state = "cargo_warehouse"

/area/ruin/powered/planet_ice/lodge/mainhall
	name = "Lodowa Chata – Główna Sala"
	icon_state = "away"

/area/ruin/powered/planet_ice/lodge/montagne_office
	name = "Lodowa Chata – Gabinet Montagne"
	icon_state = "bridge"

/area/ruin/powered/planet_ice/lodge/residential
	name = "Lodowa Chata – Część Mieszkalna"
	icon_state = "away"

/area/ruin/unpowered/planet_ice/downed_transport/abandoned_mineshaft
	name = "Rozbity Transportowiec – Opuszczony Szyb"
	icon_state = "away"

/area/ruin/unpowered/planet_ice/downed_transport/atmospherics_shed
	name = "Rozbity Transportowiec – Szopa Atmosferyki"
	icon_state = "away"

/area/ruin/unpowered/planet_ice/downed_transport/barracks
	name = "Rozbity Transportowiec – Koszary"
	icon_state = "crew_quarters"

/area/ruin/unpowered/planet_ice/downed_transport/bathhouse
	name = "Rozbity Transportowiec – Łaźnia"
	icon_state = "away"

/area/ruin/unpowered/planet_ice/downed_transport/crashed_shuttle
	name = "Rozbity Transportowiec – Wrak Promu"
	icon_state = "away"

/area/ruin/unpowered/planet_ice/downed_transport/crew_accomodations
	name = "Rozbity Transportowiec – Kwatery Załogi"
	icon_state = "crew_quarters"

/area/ruin/unpowered/planet_ice/downed_transport/mining_power_station
	name = "Rozbity Transportowiec – Elektrownia Kopalni"
	icon_state = "engine"

/area/ruin/unpowered/planet_ice/downed_transport/security_office
	name = "Rozbity Transportowiec – Biuro Ochrony"
	icon_state = "bridge"

/area/ruin/unpowered/planet_ice/downed_transport/the_descent
	name = "Rozbity Transportowiec – Zejście"
	icon_state = "away"
