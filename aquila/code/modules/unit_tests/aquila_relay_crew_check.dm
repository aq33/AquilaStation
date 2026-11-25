// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - a body carried away in a body bag stayed in mobs_in_ship of the ship it died on, so the player kept hearing that ship's
/// combat (relay) and feeling its shakes on another ship until ghosting. relay() must drop crew that is no longer aboard.
/datum/unit_test/aquila_relay_crew_check

/datum/unit_test/aquila_relay_crew_check/Run()
	var/obj/structure/overmap/small_craft/combat/light/enemy = allocate(/obj/structure/overmap/small_craft/combat/light)
	var/obj/structure/overmap/small_craft/combat/light/home = allocate(/obj/structure/overmap/small_craft/combat/light)
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/pilot = allocate(/mob/living/carbon/human)

	// The player dies aboard the enemy ship (inside it, like a pilot), and a second crewman stays there
	enemy.enter(body)
	enemy.enter(pilot)
	TEST_ASSERT(body in enemy.mobs_in_ship, "The body did not join the enemy crew: [json_encode(enemy.mobs_in_ship)]")

	// The body is carried away in a body bag: the bag moves, the mob inside does not, so update_overmap() never runs
	var/obj/structure/closet/body_bag/bag = allocate(/obj/structure/closet/body_bag)
	body.loc = bag
	bag.loc = home
	TEST_ASSERT(body in enemy.mobs_in_ship, "The scene did not reproduce the stale crew list")

	enemy.relay('nsv13/sound/effects/ship/damage/shield_hit.ogg')
	TEST_ASSERT(!(body in enemy.mobs_in_ship), "The carried body still gets the enemy ship's sounds: [json_encode(enemy.mobs_in_ship)]")
	TEST_ASSERT(body.last_overmap == home, "The carried body was not moved to the ship it is on now: [body.last_overmap]")
	TEST_ASSERT(body in home.mobs_in_ship, "The carried body did not join its new ship's crew")
	TEST_ASSERT(pilot in enemy.mobs_in_ship, "A crewman still aboard was dropped from the crew list")

	// A mob listed on two ships (last_overmap already points elsewhere) is dropped from the stale one only
	enemy.mobs_in_ship |= body
	enemy.shake_everyone(1)
	TEST_ASSERT(!(body in enemy.mobs_in_ship), "shake_everyone() kept a mob that belongs to another ship")
	TEST_ASSERT(body in home.mobs_in_ship, "shake_everyone() removed the mob from the ship it is on")

	// A pilot seated in a fighter, still listed on the stale ship, stays in the fighter's crew
	var/obj/structure/overmap/small_craft/combat/light/fighter = allocate(/obj/structure/overmap/small_craft/combat/light)
	fighter.enter(pilot)
	enemy.mobs_in_ship |= pilot
	enemy.relay('nsv13/sound/effects/ship/damage/shield_hit.ogg')
	TEST_ASSERT(!(pilot in enemy.mobs_in_ship), "The stale ship kept the pilot")
	TEST_ASSERT(pilot in fighter.mobs_in_ship, "The pilot was dropped from the fighter they sit in")
	TEST_ASSERT(pilot.last_overmap == fighter, "The pilot's ship changed: [pilot.last_overmap]")

#undef TEST_ASSERT
