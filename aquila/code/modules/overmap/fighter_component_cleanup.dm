/// AQUILA - a fighter component that gets deleted while installed (destroyed by an explosion, qdel'd by its own damage)
/// stayed in its hardpoint slot, so the next hit on the fighter damaged a deleted object ("taking damage after deletion")
/// and the slot held a hard reference. The component now frees its slot when it is deleted and gives back its weight drag.
/// The docking computer is left in place: upstream treats a fighter without one as unable to leave or dock,
/// and it takes no damage, so a destroyed one keeps working as before instead of stranding the pilot.
/obj/item/fighter_component/Destroy()
	var/obj/structure/overmap/small_craft/craft = loc
	if(slot && istype(craft) && craft.loadout?.hardpoint_slots?[slot] == src && !istype(src, /obj/item/fighter_component/docking_computer))
		craft.loadout.hardpoint_slots[slot] = null
		if(weight) // The weight part of remove_from(), which the take_damage path calls and this one skips
			craft.speed_limit += weight
			craft.forward_maxthrust += weight
			craft.backward_maxthrust += weight
			craft.side_maxthrust += 0.25 * weight
			craft.max_angular_acceleration += weight * 10
	return ..()

/// The armour path (small_craft/take_damage) calls remove_hardpoint() on plating that its own take_damage() already deleted.
/// Destroy() above has given the weight drag back by then, so doing it again here made the fighter faster than its base.
/obj/item/fighter_component/remove_from(obj/structure/overmap/target, due_to_damage)
	if(QDELETED(src))
		return TRUE
	return ..()

/// AQUILA - myśliwiec trzymał komponent w `loadout`, a komponent myśliwiec w `holder`: po qdel żadne z nich się nie zwalniało,
/// a z komponentem wisiały części ze slotów (komputer dokujący). Twarde usunięcie i szukanie referencji w CI.
/datum/component/ship_loadout/Destroy(force, silent)
	STOP_PROCESSING(SSobj, src)
	holder = null
	return ..()

/// Myśliwiec stworzony w hangarze trafia do `overmaps_in_ship` okrętu w Initialize(), a Destroy() z upstreamu
/// zdejmował go tylko z `last_overmap`, które jest puste, dopóki myśliwiec nie wyleci. Usunięty myśliwiec zostawał na liście okrętu.
/// Statek z ludźmi w środku odmawia usunięcia (QDEL_HINT_LETMELIVE) i wtedy zostaje nietknięty.
/obj/structure/overmap/small_craft/Destroy()
	var/obj/structure/overmap/home = get_overmap()
	. = ..()
	if(. == QDEL_HINT_LETMELIVE)
		return
	if(home) // get_overmap() bez loc zwraca FALSE, nie null
		home.overmaps_in_ship -= src
	loadout = null
