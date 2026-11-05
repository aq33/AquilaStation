/*
 * Losowe uzbrojenie statku - ta sama zasada co losowy silnik Atlasa (/obj/effect/spawner/room/atlasengine).
 *
 * Spawner stoi na mapie w lewym dolnym rogu stanowiska. Przy ładowaniu stacji losuje jeden szablon
 * z tą samą grupą (room_group) i tym samym rozmiarem, wkleja go i znika. Działa w szablonie same
 * podpinają się do statku przy inicjalizacji (/obj/machinery/ship_weapon/proc/PostInitialize()).
 *
 * Stanowisko na kilku pokładach (np. NAC: wieża na górze, rdzeń i ładowanie pod spodem) to osobny spawner
 * na każdym pokładzie, każdy z własną grupą. Szablony obu pokładów mają wspólny room_link, a room_variant mówi,
 * do którego wariantu należą: pierwszy wklejony szablon wybiera wariant, reszta spawnerów bierze ten sam.
 *
 * Jak dodać stanowisko (dla mappera):
 * 1. Wytnij stanowisko z mapy do szablonu w aquila/_maps/random_weapons/, a na mapie zostaw w tym miejscu
 *    /turf/template_noop + /area/template_noop i postaw spawner slotu w lewym dolnym rogu (jak silnik Atlasa).
 *    Kafelki template_noop w szablonie zostawiają to, co jest na mapie pod spodem.
 * 2. room_width / room_height spawnera = rozmiar szablonu.
 * 3. Każdy wariant to osobny /datum/map_template/random_room/... z tym samym room_group co spawner.
 *    weight = szansa wylosowania względem innych wariantów tego slotu.
 *    mappath w apostrofach ('...'), nie w cudzysłowie - wtedy plik trafia do .rsc. Serwer (i CI) nie ma folderu aquila/_maps obok .dmb.
 * 4. Broń w wariancie musi mieć weapon_datum_type, inaczej nie podepnie się do statku (np. /obj/machinery/ship_weapon/anti_air go nie ma).
 */

/// Wariant wybrany dla każdego room_link w tej rundzie
GLOBAL_LIST_EMPTY(random_room_link_choices)

/// Grupa szablonów. Spawner bierze tylko szablony z tą samą grupą; null = zwykłe losowe pokoje w maintenance
/obj/effect/spawner/room/var/room_group
/// Grupa szablonu, patrz /obj/effect/spawner/room/var/room_group
/datum/map_template/random_room/var/room_group
/// Wspólny klucz szablonów jednego stanowiska na kilku pokładach
/datum/map_template/random_room/var/room_link
/// Wariant stanowiska; przy room_link wszystkie pokłady dostają ten sam
/datum/map_template/random_room/var/room_variant

/// Czy ten spawner może wkleić dany szablon (poza zgodnością rozmiaru, którą sprawdza core)
/obj/effect/spawner/room/proc/accepts_template(datum/map_template/random_room/candidate)
	if(candidate.room_group != room_group)
		return FALSE
	var/chosen = candidate.room_link && GLOB.random_room_link_choices[candidate.room_link]
	return !chosen || candidate.room_variant == chosen

/// Zapamiętuje wariant stanowiska, zanim szablon się wklei
/datum/map_template/random_room/proc/claim_link()
	if(room_link && !GLOB.random_room_link_choices[room_link])
		GLOB.random_room_link_choices[room_link] = room_variant

/datum/map_template/random_room/stationinitload(turf/T, centered = FALSE)
	claim_link()
	return ..()

/datum/map_template/random_room/load(turf/T, centered = FALSE, init_atmos = TRUE, finalize = TRUE)
	claim_link()
	return ..()

/obj/effect/spawner/room/ship_weapon
	name = "random ship weapon spawner"
	icon_state = "random_room_alternative"

// Świeży railgun hybrydowy przyjmował tylko pociski kute, a autolat drukuje zwykłe 400 mm (po przełączeniu typu amunicji działo i tak bierze wszystkie)
/obj/machinery/ship_weapon/hybrid_rail
	ammo_type = /obj/item/ship_weapon/ammunition/railgun_ammo

// Atlas, stanowisko NAC: dolny pokład (rdzenie, bramki, konsole) i górny pokład (wieże na kadłubie).
// Wariant railgun: dwa railguny hybrydowe w polach NAC, zamkiem do pola załadunku z taśmy, stojaki pocisków podpięte pod konsolę amunicji pokoju (id "atlas1").

/obj/effect/spawner/room/ship_weapon/atlas_nac_lower
	name = "Atlas NAC slot (lower deck)"
	room_group = "atlas_nac_lower"
	room_width = 5
	room_height = 7

/obj/effect/spawner/room/ship_weapon/atlas_nac_upper
	name = "Atlas NAC slot (upper deck)"
	room_group = "atlas_nac_upper"
	room_width = 1
	room_height = 5

/datum/map_template/random_room/aq_weapon_atlas_nac_lower
	name = "Atlas NAC Slot - NAC (lower deck)"
	room_id = "aq_weapon_atlas_nac_lower"
	mappath = 'aquila/_maps/random_weapons/atlas_nac_lower_nac.dmm'
	room_group = "atlas_nac_lower"
	room_link = "atlas_nac"
	room_variant = "nac"
	centerspawner = FALSE
	template_width = 5
	template_height = 7

/datum/map_template/random_room/aq_weapon_atlas_nac_upper
	name = "Atlas NAC Slot - NAC (upper deck)"
	room_id = "aq_weapon_atlas_nac_upper"
	mappath = 'aquila/_maps/random_weapons/atlas_nac_upper_nac.dmm'
	room_group = "atlas_nac_upper"
	room_link = "atlas_nac"
	room_variant = "nac"
	centerspawner = FALSE
	template_width = 1
	template_height = 5

/datum/map_template/random_room/aq_weapon_atlas_railgun_lower
	name = "Atlas NAC Slot - Hybrid Railgun (lower deck)"
	room_id = "aq_weapon_atlas_railgun_lower"
	mappath = 'aquila/_maps/random_weapons/atlas_nac_lower_railgun.dmm'
	room_group = "atlas_nac_lower"
	room_link = "atlas_nac"
	room_variant = "railgun"
	centerspawner = FALSE
	template_width = 5
	template_height = 7

/datum/map_template/random_room/aq_weapon_atlas_railgun_upper
	name = "Atlas NAC Slot - Hybrid Railgun (upper deck)"
	room_id = "aq_weapon_atlas_railgun_upper"
	mappath = 'aquila/_maps/random_weapons/atlas_nac_upper_railgun.dmm'
	room_group = "atlas_nac_upper"
	room_link = "atlas_nac"
	room_variant = "railgun"
	centerspawner = FALSE
	template_width = 1
	template_height = 5
