/// AQUILA - regression for test_chamber "osłona kokpitu ze szkła / płyty pancerza taking damage after deletion":
/// deleting an installed fighter component frees its hardpoint slot, so damaging the fighter afterwards
/// does not reach the deleted component (aquila/code/modules/overmap/fighter_component_cleanup.dm)
/datum/unit_test/aquila_fighter_component_destroy

/datum/unit_test/aquila_fighter_component_destroy/Run()
	var/obj/structure/overmap/small_craft/combat/light/fighter = allocate(/obj/structure/overmap/small_craft/combat/light)
	for(var/slot in list(HARDPOINT_SLOT_ARMOUR, HARDPOINT_SLOT_CANOPY))
		var/obj/item/fighter_component/component = fighter.loadout.get_slot(slot)
		if(!component)
			return Fail("The test fighter has nothing in [slot]")
		qdel(component)
		if(fighter.loadout.get_slot(slot))
			return Fail("A deleted [component.name] stayed in its hardpoint slot [slot]")
	// Before the fix this damaged the deleted armour and canopy
	fighter.take_damage(10, BRUTE, "bomb", FALSE)
