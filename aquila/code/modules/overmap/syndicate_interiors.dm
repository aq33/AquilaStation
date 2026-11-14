/// AQUILA - wnętrza abordażu dla okrętów Syndykatu, które ich nie miały (aquila/_maps/templates/boarding/syndicate/).
/// Układ pomieszczeń według sprite'a i uzbrojenia okrętu (szkice w raport/overmapa_sprite/szkic_*.png), dziób na wschód jak w pozostałych wnętrzach.
/// mappath jako plik, nie string: deploy.sh nie kopiuje aquila/_maps na serwer, więc mapa musi być w .rsc.

/datum/map_template/boarding/barracuda
	name = "krążownik taktyczny klasy Barracuda (wnętrze)"
	mappath = 'aquila/_maps/templates/boarding/syndicate/barracuda.dmm'

/datum/map_template/boarding/flak_frigate
	name = "fregata przeciwlotnicza Syndykatu (wnętrze)"
	mappath = 'aquila/_maps/templates/boarding/syndicate/flak_frigate.dmm'

/datum/map_template/boarding/kadesh
	name = "zaawansowany krążownik klasy Kadesh (wnętrze)"
	mappath = 'aquila/_maps/templates/boarding/syndicate/kadesh.dmm'

/datum/map_template/boarding/inquisitor
	name = "krążownik szturmowy klasy Inquisitor (wnętrze)"
	mappath = 'aquila/_maps/templates/boarding/syndicate/inquisitor.dmm'

/datum/map_template/boarding/aspala
	name = "okręt podprzestrzenny klasy Aspala (wnętrze)"
	mappath = 'aquila/_maps/templates/boarding/syndicate/aspala.dmm'

// Piraci: frachtowiec dla zwykłego i abordażowego pirata, kanonierka i drednot na kadłubach Kadesha i fregaty przeciwlotniczej (te same sprite'y w pirackich barwach)
/datum/map_template/boarding/pirate_hauler
	name = "piracki frachtowiec (wnętrze)"
	mappath = 'aquila/_maps/templates/boarding/pirate/pirate_hauler.dmm'

/datum/map_template/boarding/pirate_raider
	name = "piracki ścigacz rakietowy (wnętrze)"
	mappath = 'aquila/_maps/templates/boarding/pirate/pirate_raider.dmm'

/datum/map_template/boarding/pirate_gunboat
	name = "piracka kanonierka (wnętrze)"
	mappath = 'aquila/_maps/templates/boarding/pirate/pirate_gunboat.dmm'

/datum/map_template/boarding/pirate_dreadnought
	name = "piracki drednot (wnętrze)"
	mappath = 'aquila/_maps/templates/boarding/pirate/pirate_dreadnought.dmm'

/obj/structure/overmap/syndicate/ai/cruiser
	possible_interior_maps = list(/datum/map_template/boarding/barracuda)

/obj/structure/overmap/syndicate/ai/gunboat
	possible_interior_maps = list(/datum/map_template/boarding/flak_frigate)

/obj/structure/overmap/syndicate/ai/kadesh
	possible_interior_maps = list(/datum/map_template/boarding/kadesh)

// Fregata desantowa Astartes jest podtypem Inquisitora, ale ma własne wnętrze w core (marine_frigate) i go nie dziedziczy
/obj/structure/overmap/syndicate/ai/assault_cruiser
	possible_interior_maps = list(/datum/map_template/boarding/inquisitor)

// Stalker (elita) dziedziczy wnętrze Aspali
/obj/structure/overmap/syndicate/ai/submarine
	possible_interior_maps = list(/datum/map_template/boarding/aspala)

/obj/structure/overmap/spacepirate/ai
	possible_interior_maps = list(/datum/map_template/boarding/pirate_hauler)

/obj/structure/overmap/spacepirate/ai/nt_missile
	possible_interior_maps = list(/datum/map_template/boarding/pirate_raider)

/obj/structure/overmap/spacepirate/ai/syndie_gunboat
	possible_interior_maps = list(/datum/map_template/boarding/pirate_gunboat)

/obj/structure/overmap/spacepirate/ai/dreadnought
	possible_interior_maps = list(/datum/map_template/boarding/pirate_dreadnought)
