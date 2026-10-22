// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - a living shooter firing without mouse params (no client, pulse demon) must aim at the target, not north
/datum/unit_test/aquila_gun_fire_without_params

/datum/unit_test/aquila_gun_fire_without_params/Run()
	var/turf/target_turf = run_loc_floor_bottom_left
	var/turf/shooter_turf = locate(target_turf.x, target_turf.y + 3, target_turf.z)
	TEST_ASSERT(isopenturf(shooter_turf), "No open turf 3 tiles north of the test room corner")

	var/mob/living/carbon/human/shooter = allocate(/mob/living/carbon/human, shooter_turf)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, target_turf)
	var/obj/item/gun/ballistic/automatic/pistol/gun = allocate(/obj/item/gun/ballistic/automatic/pistol)
	shooter.put_in_hands(gun)
	TEST_ASSERT(gun.chambered?.BB, "Pistol has no chambered bullet")

	var/obj/item/projectile/bullet = gun.chambered.BB
	gun.spread = 0
	gun.process_fire(victim, shooter, FALSE)
	TEST_ASSERT(round(bullet.Angle) == 180, "Bullet fired without params went at angle [bullet.Angle] instead of 180 (south, at the target)")

	for(var/i in 1 to 50)
		if(victim.getBruteLoss() > 0)
			break
		sleep(1)
	TEST_ASSERT(victim.getBruteLoss() > 0, "Bullet fired without params did not hit the target 3 tiles south")

#undef TEST_ASSERT
