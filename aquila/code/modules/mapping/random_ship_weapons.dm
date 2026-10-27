/*
 * Losowe uzbrojenie statku - ta sama zasada co losowy silnik Atlasa (/obj/effect/spawner/room/atlasengine).
 *
 * Spawner stoi na mapie w lewym dolnym rogu stanowiska. Przy ładowaniu stacji losuje jeden szablon
 * z tą samą grupą (room_group) i tym samym rozmiarem, wkleja go i znika. Działa w szablonie same
 * podpinają się do statku przy inicjalizacji (/obj/machinery/ship_weapon/proc/PostInitialize()).
 *
 * Jak dodać stanowisko (dla mappera):
 * 1. Postaw na mapie spawner danego slotu (np. /obj/effect/spawner/room/ship_weapon/atlas_1) w lewym dolnym rogu stanowiska.
 * 2. Ustaw room_width / room_height spawnera na rozmiar stanowiska (tu i w szablonach musi być tak samo).
 * 3. Narysuj warianty w aquila/_maps/random_weapons/ - kafelki /turf/template_noop + /area/template_noop
 *    zostawiają to, co jest na mapie pod spodem, więc wystarczy narysować samą broń i jej otoczenie.
 * 4. Każdy wariant to osobny /datum/map_template/random_room/... z tym samym room_group co spawner.
 *    weight = szansa wylosowania względem innych wariantów tego slotu.
 *    mappath w apostrofach ('...'), nie w cudzysłowie - wtedy plik trafia do .rsc. Serwer (i CI) nie ma folderu aquila/_maps obok .dmb.
 * Kolejny slot na tym samym statku: nowy spawner z nowym room_group (np. "atlas_weapon_2") i jego warianty.
 */

/// Grupa szablonów. Spawner bierze tylko szablony z tą samą grupą; null = zwykłe losowe pokoje w maintenance
/obj/effect/spawner/room/var/room_group
/// Grupa szablonu, patrz /obj/effect/spawner/room/var/room_group
/datum/map_template/random_room/var/room_group

/// Czy ten spawner może wkleić dany szablon (poza zgodnością rozmiaru, którą sprawdza core)
/obj/effect/spawner/room/proc/accepts_template(datum/map_template/random_room/candidate)
	return candidate.room_group == room_group

/obj/effect/spawner/room/ship_weapon
	name = "random ship weapon spawner"
	icon_state = "random_room_alternative"

// Sloty uzbrojenia. Rozmiar 5x5 to wartość przykładowa - mapper ustawia go pod stanowisko.

/obj/effect/spawner/room/ship_weapon/atlas_1
	name = "Atlas weapon slot 1"
	room_group = "atlas_weapon_1"
	room_width = 5
	room_height = 5

/obj/effect/spawner/room/ship_weapon/snake_1
	name = "Snake weapon slot 1"
	room_group = "snake_weapon_1"
	room_width = 5
	room_height = 5

/obj/effect/spawner/room/ship_weapon/trawnik_1
	name = "Trawnik weapon slot 1"
	room_group = "trawnik_weapon_1"
	room_width = 5
	room_height = 5

// Warianty. Przykładowe: działko AA na środku albo puste stanowisko.

/datum/map_template/random_room/aq_weapon_atlas_1a
	name = "Atlas Weapon Slot 1 - AA Turret"
	room_id = "aq_weapon_atlas_1a"
	mappath = 'aquila/_maps/random_weapons/atlas_1_aa.dmm'
	room_group = "atlas_weapon_1"
	centerspawner = FALSE
	template_width = 5
	template_height = 5

/datum/map_template/random_room/aq_weapon_atlas_1b
	name = "Atlas Weapon Slot 1 - Empty"
	room_id = "aq_weapon_atlas_1b"
	mappath = 'aquila/_maps/random_weapons/atlas_1_empty.dmm'
	room_group = "atlas_weapon_1"
	centerspawner = FALSE
	template_width = 5
	template_height = 5

/datum/map_template/random_room/aq_weapon_snake_1a
	name = "Snake Weapon Slot 1 - AA Turret"
	room_id = "aq_weapon_snake_1a"
	mappath = 'aquila/_maps/random_weapons/snake_1_aa.dmm'
	room_group = "snake_weapon_1"
	centerspawner = FALSE
	template_width = 5
	template_height = 5

/datum/map_template/random_room/aq_weapon_snake_1b
	name = "Snake Weapon Slot 1 - Empty"
	room_id = "aq_weapon_snake_1b"
	mappath = 'aquila/_maps/random_weapons/snake_1_empty.dmm'
	room_group = "snake_weapon_1"
	centerspawner = FALSE
	template_width = 5
	template_height = 5

/datum/map_template/random_room/aq_weapon_trawnik_1a
	name = "Trawnik Weapon Slot 1 - AA Turret"
	room_id = "aq_weapon_trawnik_1a"
	mappath = 'aquila/_maps/random_weapons/trawnik_1_aa.dmm'
	room_group = "trawnik_weapon_1"
	centerspawner = FALSE
	template_width = 5
	template_height = 5

/datum/map_template/random_room/aq_weapon_trawnik_1b
	name = "Trawnik Weapon Slot 1 - Empty"
	room_id = "aq_weapon_trawnik_1b"
	mappath = 'aquila/_maps/random_weapons/trawnik_1_empty.dmm'
	room_group = "trawnik_weapon_1"
	centerspawner = FALSE
	template_width = 5
	template_height = 5
