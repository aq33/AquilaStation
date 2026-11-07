// Kopie makr z code/modules/unit_tests/_unit_tests.dm (tam s¹ #undef na koñcu)
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - strza³ z broni palnej zostawia dym (zanieczyszczenie) na kafelku strzelca, broñ na piankê nie
/datum/unit_test/aquila_gun_smoke_pollution

/datum/unit_test/aquila_gun_smoke_pollution/Run()
	var/turf/open/shooter_turf = run_loc_floor_bottom_left
	var/turf/open/toy_turf = locate(shooter_turf.x + 2, shooter_turf.y, shooter_turf.z)
	TEST_ASSERT(isopenturf(toy_turf), "No open turf 2 tiles east of the test room corner")
	QDEL_NULL(shooter_turf.pollution)
	QDEL_NULL(toy_turf.pollution)

	var/mob/living/carbon/human/shooter = allocate(/mob/living/carbon/human, shooter_turf)
	var/obj/item/gun/ballistic/automatic/pistol/gun = allocate(/obj/item/gun/ballistic/automatic/pistol)
	shooter.put_in_hands(gun)
	var/turf/target = locate(shooter_turf.x, shooter_turf.y + 2, shooter_turf.z)
	gun.process_fire(target, shooter, FALSE)
	TEST_ASSERT(shooter_turf.pollution?.pollutants[/datum/pollutant/smoke] >= gun.gun_smoke_pollution, "Pistol shot left no gun smoke on the shooter's tile")

	var/mob/living/carbon/human/toy_shooter = allocate(/mob/living/carbon/human, toy_turf)
	var/obj/item/gun/ballistic/automatic/toy/pistol/toy = allocate(/obj/item/gun/ballistic/automatic/toy/pistol)
	toy_shooter.put_in_hands(toy)
	toy.process_fire(target, toy_shooter, FALSE)
	TEST_ASSERT(!toy_turf.pollution?.pollutants[/datum/pollutant/smoke], "Foam pistol left gun smoke")

	QDEL_NULL(shooter_turf.pollution)

#undef TEST_ASSERT
