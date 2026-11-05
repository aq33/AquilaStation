// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - Syndicate boarding mobs with ranged = 1 need ammo, otherwise Shoot() spawns nothing (space/ranged had none)
/datum/unit_test/aquila_nsv_syndicate_ammo

/datum/unit_test/aquila_nsv_syndicate_ammo/Run()
	for(var/mob/living/simple_animal/hostile/nsv/syndicate/path as anything in typesof(/mob/living/simple_animal/hostile/nsv/syndicate))
		if(!initial(path.ranged))
			continue
		TEST_ASSERT(initial(path.casingtype) || initial(path.projectiletype), "[path] has ranged = 1 but neither casingtype nor projectiletype, so it cannot shoot")

	// Shoot() of the shooter seen in the review must actually make a projectile
	var/turf/start = run_loc_floor_bottom_left
	var/turf/target = locate(start.x + 2, start.y, start.z)
	var/mob/living/simple_animal/hostile/nsv/syndicate/space/ranged/shooter = allocate(/mob/living/simple_animal/hostile/nsv/syndicate/space/ranged, start)
	TEST_ASSERT(!(locate(/obj/item/ammo_casing) in start), "Test turf already has a casing")
	shooter.Shoot(target)
	var/obj/item/ammo_casing/casing = locate() in start
	TEST_ASSERT(casing, "Space Syndicate shooter Shoot() did not fire anything (no spent casing under it)")
	qdel(casing)

#undef TEST_ASSERT
