// AQUILA - flak dla gracza i dla okrętów AI (raport nsv_martwe_08, pkt 6).
// Błąd: flak/New() ustawia burst_size = flak_battery_count (weapon_datum_types.dm), a liczby baterii nie podaje
// ani add_weapon() dla stojaka z mapy (Atlantis, nsv13/code/modules/overmap/weapons/delta_overmap_ship_weapons/physical.dm),
// ani większość okrętów AI (`new /datum/overmap_ship_weapon/flak(src, FALSE)` w syndicate.dm, nanotrasen.dm,
// spacepirates.dm). Salwa „null” nie wystrzeliwała nic, więc taki flak nigdy nie strzelał.
// Poprawka: bez podanej liczby baterii flak ma jedną (dawne `flak_battery_amount` okrętów NSV też zwykle było 1).
// Okręty z podaną liczbą (2 albo 3) zostają bez zmian.
// Do tego osobna płytka flaku i amunicja w Zaawansowanej balistyce (wcześniej płytkę dawał tylko przełącznik
// śrubokrętem na płytce PDC, wyłączony w BeeStation/NSV13#2603) i paczka amunicji w zaopatrzeniu.
// Działo strzela samo jak dotąd, bez limitu stojaków.

/datum/overmap_ship_weapon/flak/New(obj/structure/overmap/link_to, update_role_weapon_lists = TRUE, flak_battery_count, ...)
	. = ..()
	if(!burst_size)
		burst_size = 1

/obj/item/circuitboard/machine/pdc_mount/flak
	desc = "Płytka stojaka ładowania flaku: działo samo ostrzeliwuje najbliższy wrogi okręt, a chmury wybuchów ranią myśliwce i pociski kierowane."

/obj/machinery/ship_weapon/pdc_mount/flak
	circuit = /obj/item/circuitboard/machine/pdc_mount/flak

/datum/design/board/flak_mount
	name = "Projekt maszyny (stojak ładowania flaku)"
	desc = "Automatyczne działo przeciwlotnicze na amunicję flak 40 mm. Stawia się je jak stojak PDC."
	id = "flak_mount_circuit"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 1000, /datum/material/titanium = 5000, /datum/material/silver = 1000)
	build_path = /obj/item/circuitboard/machine/pdc_mount/flak
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/flak_ammo
	name = "Pociski flak 40 mm"
	desc = "Magazynek 150 pocisków do stojaka ładowania flaku."
	id = "flak_ammo"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 6000, /datum/material/copper = 1500, /datum/material/titanium = 1000)
	build_path = /obj/item/ammo_box/magazine/nsv/flak
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/techweb_node/advanced_ballistics/New()
	. = ..()
	design_ids += list("flak_mount_circuit", "flak_ammo")

/// Amunicja flak w zaopatrzeniu (dotąd tylko u Minsky'ego, 500 za magazynek przed losowaniem ceny)
/datum/supply_pack/munitions/flak_ammo
	name = "Amunicja flak 40 mm (x3)"
	desc = "3 magazynki po 150 pocisków flak do stojaków ładowania flaku."
	cost = 1500
	contains = list(/obj/item/ammo_box/magazine/nsv/flak,
					/obj/item/ammo_box/magazine/nsv/flak,
					/obj/item/ammo_box/magazine/nsv/flak)
	crate_name = "skrzynia z amunicją flak"
