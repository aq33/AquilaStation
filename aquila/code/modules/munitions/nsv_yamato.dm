// AQUILA - trzylufowe działo pokładowe „Yamato” wraca do gry (raport nsv_martwe_08, pkt 1).
// Płytka ulepszenia `deck_gun_triple` była tylko w trybie trudnym (nsv13/code/modules/research/techweb/_techweb.dm),
// teraz jest w Makrobalistyce i u Minsky'ego. Bez limitu na okręt.
// Yamato strzela salwą trzech zwykłych pocisków (po 400) i przeładowuje się 7 s (Hood: jeden pocisk co 3,5 s).
// Własny datum broni, bo opóźnienie strzału jest wspólne dla całej grupy (`fire_delay` datumu), więc Yamato
// tworzy osobną grupę w wyborze broni.

/datum/overmap_ship_weapon/mac/yamato
	name = "Trzylufowa artyleria okrętowa"
	burst_size = 3
	burst_fire_delay = 0.4 SECONDS
	fire_delay = 7 SECONDS
	select_alert = "<span class='notice'>Trzylufowa artyleria okrętowa gotowa.</span>"
	sort_priority = 13

/obj/machinery/ship_weapon/deck_turret/_3
	weapon_datum_type = /datum/overmap_ship_weapon/mac/yamato

/**
 * Salwa grupy Yamato liczona z amunicji każdego działa osobno. Bazowe fire_physical() bierze get_ammo() całej grupy,
 * więc działo z jednym pociskiem dostawało rozkaz trzech strzałów, odrzucało go w can_fire(), a grupa i tak brała
 * 7 s przerwy. Tu działo strzela tyle, ile ma (najwyżej tyle, ile zostało z salwy), a odrzucony strzał się nie liczy.
 */
/datum/overmap_ship_weapon/mac/yamato/fire_physical(atom/target, mob/living/firer, ai_aim = FALSE)
	var/fire_count = burst_size
	for(var/obj/machinery/ship_weapon/firing_weapon in weapons["loaded"])
		if(ammo_filter && !check_valid_physical_ammo(firing_weapon))
			continue
		var/this_burst = min(fire_count, firing_weapon.get_ammo())
		if(this_burst <= 0 || !firing_weapon.can_fire(target, this_burst))
			continue
		if(fire_count == burst_size)
			firing_weapon.fire(target, this_burst)
		else // jak bazowe: reszta salwy z opóźnieniem, żeby brzmiała jak jedna seria
			addtimer(CALLBACK(firing_weapon, TYPE_PROC_REF(/obj/machinery/ship_weapon, fire), target, this_burst), (burst_fire_delay * (burst_size - fire_count)))
		fire_count -= this_burst
		if(fire_count <= 0)
			break
	return burst_size - fire_count

/datum/techweb_node/macro_ballistics/New()
	. = ..()
	design_ids += "deck_gun_triple"

/datum/trader_item/deck_gun_triple
	name = "Ulepszenie trzylufowe działa pokładowego „Yamato”"
	desc = "Płytka, która zamienia działo pokładowe w trzylufowe: salwa trzech pocisków, dwa razy dłuższe przeładowanie. Działo trzeba rozebrać do ramy, dołożyć dwie lufy i dwa zapalniki."
	price = 15000
	stock = 1
	unlock_path = /obj/item/circuitboard/multibarrel_upgrade/_3

/// Minsky sprzedaje płytkę Yamato (dopisane przy każdym uzupełnieniu towaru, inne pliki też dopisują)
/datum/trader/stock_items()
	if(istype(src, /datum/trader/minsky))
		sold_items |= list(/datum/trader_item/deck_gun_triple)
	return ..()
