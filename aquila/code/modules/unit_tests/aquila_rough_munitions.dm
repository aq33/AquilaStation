// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Amunicja klasy I z kuźni (automat młota): trzy razy szybciej zużywa broń, a zacięta broń nie strzela do odblokowania
/datum/unit_test/aquila_rough_munitions

/datum/unit_test/aquila_rough_munitions/Run()
	var/datum/munition_material/iron = get_munition_material(/datum/material/iron)
	var/obj/item/ammo_casing/c10mm/rough = allocate(/obj/item/ammo_casing/c10mm, run_loc_floor_bottom_left)
	rough.AddComponent(/datum/component/forged_munition, iron, get_munition_quality(/datum/munition_quality))
	var/obj/item/ammo_casing/c10mm/fine = allocate(/obj/item/ammo_casing/c10mm, run_loc_floor_bottom_left)
	fine.AddComponent(/datum/component/forged_munition, iron, get_munition_quality(/datum/munition_quality/improved))
	var/obj/item/ammo_casing/c10mm/factory = allocate(/obj/item/ammo_casing/c10mm, run_loc_floor_bottom_left)
	var/obj/item/ammo_casing/c10mm/plated = allocate(/obj/item/ammo_casing/c10mm, run_loc_floor_bottom_left)
	plated.AddComponent(/datum/component/forged_munition, iron, get_munition_quality(/datum/munition_quality), null, TRUE)
	TEST_ASSERT(aq_is_rough_munition(rough), "Nabój klasy I nie jest surowy")
	TEST_ASSERT(!aq_is_rough_munition(fine) && !aq_is_rough_munition(factory) && !aq_is_rough_munition(plated), "Nabój klasy II, fabryczny albo galwanizowany jest surowy")

	// zużycie: klasa I trzy razy szybciej niż fabryczny nabój
	var/obj/item/gun/ballistic/automatic/pistol/gun = allocate(/obj/item/gun/ballistic/automatic/pistol, run_loc_floor_bottom_left)
	gun.gun_wear = 0
	gun.add_wear(factory)
	var/factory_wear = gun.gun_wear
	gun.gun_wear = 0
	gun.add_wear(rough)
	TEST_ASSERT(factory_wear > 0 && abs(gun.gun_wear - factory_wear * 3) < 0.001, "Klasa I zużyła broń o [gun.gun_wear] zamiast [factory_wear * 3]")

	// zacięcie: broń nie strzela, użycie w ręce ją odblokowuje
	var/mob/living/carbon/human/shooter = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	shooter.put_in_hands(gun)
	gun.aq_jammed = TRUE
	TEST_ASSERT(!gun.process_fire(get_step(shooter, NORTH), shooter), "Zacięta broń strzeliła")
	gun.attack_self(shooter)
	TEST_ASSERT(!gun.aq_jammed, "Użycie w ręce nie usunęło zacięcia")

#undef TEST_ASSERT
