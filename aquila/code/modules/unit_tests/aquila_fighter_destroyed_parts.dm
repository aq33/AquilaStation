// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - wybuch niszczy osłonę i pancerz we wnętrzu myśliwca, a potem trafia sam myśliwiec (test_chamber w CI)
/datum/unit_test/aquila_fighter_destroyed_parts
	var/obj/structure/overmap/small_craft/combat/light/fighter

/datum/unit_test/aquila_fighter_destroyed_parts/Run()
	var/turf/center = SSmapping.get_station_center()
	TEST_ASSERT(center, "No station center")
	fighter = new(center)
	var/obj/item/fighter_component/canopy/canopy = fighter.loadout.get_slot(HARDPOINT_SLOT_CANOPY)
	var/obj/item/fighter_component/armour_plating/armour = fighter.loadout.get_slot(HARDPOINT_SLOT_ARMOUR)
	TEST_ASSERT(canopy && armour, "Light fighter should start with a canopy and armour plating")

	// tak jak SSexplosions: najpierw części z wnętrza, potem kadłub
	canopy.ex_act(EXPLODE_DEVASTATE)
	armour.ex_act(EXPLODE_DEVASTATE)
	TEST_ASSERT(QDELETED(canopy) && QDELETED(armour), "The explosion should destroy both parts")
	for(var/i in 1 to 10)
		fighter.take_damage(5, BRUTE, "bomb", 0)

	TEST_ASSERT(isnull(fighter.loadout.get_slot(HARDPOINT_SLOT_CANOPY)), "Destroyed canopy is still in its slot")
	TEST_ASSERT(isnull(fighter.loadout.get_slot(HARDPOINT_SLOT_ARMOUR)), "Destroyed armour plating is still in its slot")
	TEST_ASSERT(isnull(fighter.loadout.hardpoint_slots[HARDPOINT_SLOT_CANOPY]) && isnull(fighter.loadout.hardpoint_slots[HARDPOINT_SLOT_ARMOUR]), "get_slot returned null but left the deleted part in hardpoint_slots")
	TEST_ASSERT(!QDELETED(fighter), "Fighter should survive light damage")

/datum/unit_test/aquila_fighter_destroyed_parts/Destroy()
	QDEL_NULL(fighter)
	return ..()

#undef TEST_ASSERT
