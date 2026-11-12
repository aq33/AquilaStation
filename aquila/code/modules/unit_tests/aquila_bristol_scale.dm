// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b]. [message]") }

/// AQUILA - skala bristolska: dieta, ruch, nawodnienie i środki przeczyszczające zmieniają typ, a typ zmienia tempo i próg
/datum/unit_test/aquila_bristol_scale

/datum/unit_test/aquila_bristol_scale/Run()
	var/mob/living/carbon/human/pooper = allocate(/mob/living/carbon/human)
	pooper.set_hydration(HYDRATION_LEVEL_HYDRATED)

	// Bez danych o diecie i ruchu: norma
	TEST_ASSERT_EQUAL(pooper.stool_type(), 4, "A fresh human is not type 4")
	TEST_ASSERT_EQUAL(pooper.stool_rate_mod(), 1, "Type 4 changes the defecation rate")

	// Same burgery i siedzenie przy konsoli: zaparcie, wolniejsza potrzeba, dłuższe wypróżnienie
	pooper.bowel_junk = 30
	pooper.bowel_since = world.time - 10 MINUTES
	pooper.bowel_steps = 0
	var/list/reasons = list()
	var/hard = pooper.stool_type(reasons)
	TEST_ASSERT(hard <= 2, "Junk food and no movement gave type [hard]")
	TEST_ASSERT("za mało ruchu" in reasons, "No movement is not listed as a reason")
	TEST_ASSERT(pooper.stool_rate_mod() < 1, "Constipation does not slow the need down")
	TEST_ASSERT(pooper.bowel_movement_time() > 3 SECONDS, "Constipation does not make defecation longer")

	// Wypróżnienie: kupa dostaje typ, licznik zaczyna od nowa
	pooper.set_defecation(DEFECATION_SHIT_YOURSELF)
	pooper.finish_defecate_here(FALSE)
	var/obj/effect/decal/cleanable/feces/stool = locate() in get_turf(pooper)
	TEST_ASSERT(stool, "Defecating naked left nothing on the floor")
	TEST_ASSERT_EQUAL(stool.stool_type, hard, "The stool on the floor has a different type than computed")
	TEST_ASSERT_EQUAL(pooper.bowel_junk, 0, "Diet was not reset after defecating")
	TEST_ASSERT_EQUAL(pooper.stool_type(), 4, "Type did not return to normal after defecating")

	// Warzywa, ruch i picie: norma mimo mięsa
	pooper.bowel_fiber = 20
	pooper.bowel_junk = 20
	pooper.bowel_since = world.time - 10 MINUTES
	pooper.bowel_steps = 500
	TEST_ASSERT_EQUAL(pooper.stool_type(), 4, "A balanced diet with movement is not type 4")

	// Odwodnienie twardzi
	pooper.set_hydration(HYDRATION_LEVEL_PARCHED - 1)
	TEST_ASSERT(pooper.stool_type() <= 2, "Severe dehydration does not cause constipation")
	pooper.set_hydration(HYDRATION_LEVEL_HYDRATED)

	// Kawa przyspiesza, olej rycynowy to biegunka i wcześniejsze popuszczenie
	pooper.bowel_laxative = 40
	TEST_ASSERT(pooper.stool_type() >= 6, "A lot of coffee does not loosen the stool")
	pooper.reagents.add_reagent(/datum/reagent/consumable/castor_oil, 10)
	TEST_ASSERT_EQUAL(pooper.stool_type(), 7, "Castor oil is not type 7")
	TEST_ASSERT(pooper.accident_threshold() < DEFECATION_ACTUALLY_SHIT_YOURSELF, "Diarrhea does not lower the accident threshold")
	TEST_ASSERT(pooper.stool_rate_mod() > 1, "Diarrhea does not speed the need up")

	// Popuszczenie: własna odraza z popuszczenia nie może podbić zapisanego typu (4 → 5)
	var/mob/living/carbon/human/accident = allocate(/mob/living/carbon/human)
	accident.set_hydration(HYDRATION_LEVEL_HYDRATED)
	for(var/obj/effect/decal/cleanable/feces/old_stool in get_turf(accident))
		qdel(old_stool)
	var/old_shitting = CONFIG_GET(flag/shitting_enabled)
	CONFIG_SET(flag/shitting_enabled, TRUE)
	var/shat = accident.actually_shit_myself()
	CONFIG_SET(flag/shitting_enabled, old_shitting)
	TEST_ASSERT(shat, "The accident did not happen with shitting enabled")
	var/obj/effect/decal/cleanable/feces/accident_stool = locate() in get_turf(accident)
	TEST_ASSERT(accident_stool, "The accident left nothing on the floor")
	TEST_ASSERT_EQUAL(accident_stool.stool_type, 4, "The accident's own disgust changed the recorded type")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
