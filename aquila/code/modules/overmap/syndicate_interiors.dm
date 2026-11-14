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

/obj/structure/overmap/syndicate/ai/cruiser
	possible_interior_maps = list(/datum/map_template/boarding/barracuda)

/obj/structure/overmap/syndicate/ai/gunboat
	possible_interior_maps = list(/datum/map_template/boarding/flak_frigate)

/obj/structure/overmap/syndicate/ai/kadesh
	possible_interior_maps = list(/datum/map_template/boarding/kadesh)
