// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b].[message ? " [message]" : ""]") }

/// Records the ship sounds relayed to it (a mob without a client hears nothing otherwise)
/mob/living/carbon/human/aq_relay_listener
	var/relayed_sounds = 0

/mob/living/carbon/human/aq_relay_listener/play_mixed_sound(sound/S, volume_pref)
	relayed_sounds++

/// AQUILA: a dead player stayed in the ship's crew list until they ghosted and kept hearing the ship's battle
/datum/unit_test/aquila_relay_skips_dead

/datum/unit_test/aquila_relay_skips_dead/Run()
	var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
	TEST_ASSERT(ship, "No main ship to relay sounds from")
	var/mob/living/carbon/human/aq_relay_listener/alive = allocate(/mob/living/carbon/human/aq_relay_listener, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/aq_relay_listener/dead = allocate(/mob/living/carbon/human/aq_relay_listener, run_loc_floor_bottom_left)
	dead.death()
	ship.mobs_in_ship |= list(alive, dead)
	ship.relay('nsv13/sound/effects/ship/damage/shield_hit.ogg')
	ship.mobs_in_ship -= list(alive, dead)
	TEST_ASSERT_EQUAL(alive.relayed_sounds, 1, "A living crewman did not hear the ship")
	TEST_ASSERT_EQUAL(dead.relayed_sounds, 0, "A dead crewman still heard the ship's battle")

/// AQUILA: a wounded patient in pain got a heart attack from the medic's epinephrine; only an overdose of stimulants stops the heart
/datum/unit_test/aquila_heart_no_arrest_from_pain

/datum/unit_test/aquila_heart_no_arrest_from_pain/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/item/organ/heart/heart = patient.getorganslot(ORGAN_SLOT_HEART)
	patient.aq_pain = 130
	patient.blood_volume = BLOOD_VOLUME_BAD - 10
	patient.reagents.add_reagent(/datum/reagent/medicine/epinephrine, 20)
	for(var/i in 1 to 200)
		patient.aq_update_pulse(heart)
	TEST_ASSERT(!patient.undergoing_cardiac_arrest(), "The heart of a wounded patient on epinephrine stopped")

	patient.reagents.add_reagent(/datum/reagent/drug/methamphetamine, 30)
	patient.aq_update_pulse(heart)
	TEST_ASSERT(!patient.undergoing_cardiac_arrest(), "The heart stopped from stimulants before the overdose warning")
	TEST_ASSERT(heart.aq_overdose_warned, "The overdose gave no warning")
	for(var/i in 1 to 300)
		patient.aq_update_pulse(heart)
		if(patient.undergoing_cardiac_arrest())
			break
	TEST_ASSERT(patient.undergoing_cardiac_arrest(), "A stimulant overdose no longer stops a racing heart")

/// AQUILA: things seen through open space say which level they are on (screentip and examine)
/datum/unit_test/aquila_other_level_text

/datum/unit_test/aquila_other_level_text/Run()
	var/turf/upper
	var/turf/lower
	// The default test map (Atlas) has two decks; a floor with another floor right under it
	for(var/turf/open/openspace/airless/candidate in world)
		var/turf/below = candidate.below()
		if(!isopenturf(below) || isspaceturf(below) || istype(below, /turf/open/openspace))
			continue
		for(var/turf/open/floor/roof in range(2, candidate))
			if(roof.below())
				upper = roof
				lower = below
				break
		if(upper)
			break
	TEST_ASSERT(upper && lower, "No two decks on the test map, nothing to check")
	var/obj/item/wrench/up_thing = allocate(/obj/item/wrench, upper)
	var/obj/item/wrench/down_thing = allocate(/obj/item/wrench, lower)
	var/obj/item/wrench/same_level = allocate(/obj/item/wrench, upper)
	TEST_ASSERT_EQUAL(down_thing.aq_other_level_text(up_thing), "piętro niżej", "A thing one deck down")
	TEST_ASSERT_EQUAL(up_thing.aq_other_level_text(down_thing), "piętro wyżej", "A thing one deck up")
	TEST_ASSERT_EQUAL(same_level.aq_other_level_text(up_thing), "", "A thing on the same deck")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
