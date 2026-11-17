// AQUILA - flak dla gracza (raport nsv_martwe_08, pkt 6).
// Błąd: stojak flaku postawiony na mapie (Atlantis) tworzy datum broni w add_weapon()
// (nsv13/code/modules/overmap/weapons/delta_overmap_ship_weapons/physical.dm) przez new(overmapa), bez liczby baterii,
// a flak/New() ustawia burst_size = flak_battery_count, czyli null. Salwa „null” nie wystrzeliwała nic, więc stojaki
// flaku na Atlantis nigdy nie strzelały. Poprawka: datum z podpiętym stojakiem ma co najmniej jeden strzał na salwę.
// Okręty AI z podaną liczbą baterii zostają bez zmian.
// Do tego osobna płytka flaku w Zaawansowanej balistyce (wcześniej płytkę dawał tylko przełącznik śrubokrętem na
// płytce PDC, wyłączony w BeeStation/NSV13#2603). Działo strzela samo jak dotąd, bez limitu stojaków.

/datum/overmap_ship_weapon/flak/link_physical_weapon(weapon)
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

/datum/techweb_node/advanced_ballistics/New()
	. = ..()
	design_ids += "flak_mount_circuit"
