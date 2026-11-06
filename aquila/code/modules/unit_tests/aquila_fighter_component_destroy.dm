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
		var/speed_before = fighter.speed_limit
		var/weight = component.weight
		qdel(component)
		if(fighter.loadout.get_slot(slot))
			return Fail("A deleted [component.name] stayed in its hardpoint slot [slot]")
		if(fighter.speed_limit != speed_before + weight)
			return Fail("A deleted [component.name] did not give back its weight drag (speed [speed_before] -> [fighter.speed_limit], weight [weight])")
	// Before the fix this damaged the deleted armour and canopy
	fighter.take_damage(10, BRUTE, "bomb", FALSE)

/// Regression for fighter_docking after test_chamber: a fighter whose docking computer was destroyed
/// still leaves for the overmap and docks again ("Cannot modify null.docking_cooldown / docking_mode");
/// the destroyed docking computer stays in its slot so the pilot is not stranded
/datum/unit_test/aquila_fighter_without_docking_computer

/datum/unit_test/aquila_fighter_without_docking_computer/Run()
	var/obj/structure/overmap/main = SSstar_system.find_main_overmap()
	if(!main)
		return // No main ship on this map, nothing to dock to
	var/turf/center = SSmapping.get_station_center()
	var/obj/structure/overmap/small_craft/combat/light/fighter = allocate(/obj/structure/overmap/small_craft/combat/light, center)
	qdel(fighter.loadout.get_slot(HARDPOINT_SLOT_DOCKING))
	if(!fighter.loadout.get_slot(HARDPOINT_SLOT_DOCKING))
		return Fail("A destroyed docking computer was taken out of its slot, the fighter could not leave or dock any more")
	fighter.check_overmap_elegibility(ignore_position = TRUE, ignore_cooldown = TRUE)
	fighter.transfer_from_overmap(main)
	if(fighter.get_overmap() != main)
		return Fail("A fighter without a docking computer did not dock back into the main ship")
