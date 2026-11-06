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
	return ..()
