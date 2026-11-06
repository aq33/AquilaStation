// Makra asercji z upstreamu są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc ten test ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - regresje z przeglądu antagów: zakrwawione podłogi kultu przy kilku plamach na kafelku
/datum/unit_test/aquila_review_bloody_floors

/datum/unit_test/aquila_review_bloody_floors/Run()
	var/datum/team/cult/cult = new
	TEST_ASSERT_EQUAL(GLOB.bloodcult_team, cult, "New cult team was not cached for blood decals")

	var/turf/floor = run_loc_floor_bottom_left
	var/obj/effect/decal/cleanable/blood/first = allocate(/obj/effect/decal/cleanable/blood, floor)
	var/obj/effect/decal/cleanable/blood/splatter/second = allocate(/obj/effect/decal/cleanable/blood/splatter, floor)
	// Poza poziomem stacji add_bloody_floor() nic nie dodaje, więc kafelek wpisujemy ręcznie
	cult.bloody_floors[floor] = floor

	qdel(first)
	TEST_ASSERT(floor in cult.bloody_floors, "Destroying one of two blood decals removed the turf from bloody_floors")
	qdel(second)
	TEST_ASSERT(!(floor in cult.bloody_floors), "Destroying the last blood decal left the turf in bloody_floors")

	qdel(cult)
	TEST_ASSERT(GLOB.bloodcult_team != cult, "Destroyed cult team stayed cached")

/// AQUILA - regresja: krew utracona przez ciało wampira (worek, krwawy robak) zabiera vitae
/datum/unit_test/aquila_review_vampire_blood_loss

/datum/unit_test/aquila_review_vampire_blood_loss/Run()
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	body.mind_initialize()
	var/datum/antagonist/vampire/vampire = new
	vampire.owner = body.mind
	vampire.current_vitae = BLOOD_VOLUME_NORMAL

	vampire.update_blood()
	TEST_ASSERT_EQUAL(body.blood_volume, BLOOD_VOLUME_NORMAL, "update_blood() did not mirror vitae into blood_volume")

	body.blood_volume -= 100
	vampire.update_blood()
	TEST_ASSERT_EQUAL(vampire.current_vitae, BLOOD_VOLUME_NORMAL - 100, "Blood lost by the body was not taken from vitae")
	TEST_ASSERT_EQUAL(body.blood_volume, BLOOD_VOLUME_NORMAL - 100, "blood_volume was refilled above vitae after blood loss")

	// Przyrost krwi w ciele nie dodaje vitae
	body.blood_volume += 50
	vampire.update_blood()
	TEST_ASSERT_EQUAL(vampire.current_vitae, BLOOD_VOLUME_NORMAL - 100, "Blood gained by the body changed vitae")

	qdel(vampire)

/// AQUILA - regresja: usunięty właściciel odczepia wampirzą strukturę (bez twardej referencji)
/datum/unit_test/aquila_review_vampire_structure_owner

/datum/unit_test/aquila_review_vampire_structure_owner/Run()
	var/mob/living/carbon/human/vampire_mob = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/structure/vampire/vassalrack/rack = allocate(/obj/structure/vampire/vassalrack, run_loc_floor_bottom_left)
	rack.bolt(vampire_mob)
	TEST_ASSERT_EQUAL(rack.owner, vampire_mob, "bolt() did not set the owner")

	qdel(vampire_mob)
	TEST_ASSERT(isnull(rack.owner), "Structure kept a reference to its deleted owner")
	TEST_ASSERT(!rack.anchored, "Structure stayed bolted after its owner was deleted")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
