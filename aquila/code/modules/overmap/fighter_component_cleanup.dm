/// AQUILA - a fighter component that gets deleted while installed (destroyed by an explosion, qdel'd by its own damage)
/// stayed in its hardpoint slot, so the next hit on the fighter damaged a deleted object ("taking damage after deletion")
/// and the slot held a hard reference. The component now frees its slot when it is deleted.
/obj/item/fighter_component/Destroy()
	var/obj/structure/overmap/small_craft/craft = loc
	if(slot && istype(craft) && craft.loadout?.hardpoint_slots?[slot] == src)
		craft.loadout.hardpoint_slots[slot] = null
	return ..()
