// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - gruczoły porywaczy z tg: dostęp, krew, kwantowy i przemiana (pop) działają po aktywacji
/datum/unit_test/aquila_abductor_glands_tg

/datum/unit_test/aquila_abductor_glands_tg/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/other_turf = locate(start.x + 2, start.y, start.z)

	// dostęp: przed aktywacją zamek z dostępem kapitana nie wpuszcza, po aktywacji tak, po wyjęciu znowu nie
	var/mob/living/carbon/human/abductee = allocate(/mob/living/carbon/human, start)
	var/obj/structure/closet/secure_closet/locker = allocate(/obj/structure/closet/secure_closet, start)
	locker.req_access = list(ACCESS_CAPTAIN)
	var/obj/item/organ/heart/gland/access/access_gland = new
	access_gland.Insert(abductee)
	TEST_ASSERT(!locker.allowed(abductee), "Abductee opens a captain lock before the access gland activated")
	access_gland.activate()
	TEST_ASSERT(locker.allowed(abductee), "Access gland did not grant all access")
	access_gland.Remove(abductee)
	TEST_ASSERT(!locker.allowed(abductee), "Access stayed after the access gland was removed")
	qdel(access_gland)

	// krew: po aktywacji krew to losowy odczynnik, po wyjęciu wraca krew rasy
	var/obj/item/organ/heart/gland/blood/blood_gland = new
	blood_gland.Insert(abductee)
	blood_gland.activate()
	var/new_blood = abductee.dna.species.exotic_blood
	TEST_ASSERT(ispath(new_blood, /datum/reagent), "Blood gland did not set a reagent as blood")
	TEST_ASSERT(abductee.get_blood_id() == new_blood, "Blood id is [abductee.get_blood_id()] instead of [new_blood]")
	blood_gland.Remove(abductee)
	TEST_ASSERT(abductee.get_blood_id() == /datum/reagent/blood, "Human blood did not come back after removing the blood gland")
	qdel(blood_gland)

	// kwantowy: wiąże się z kimś w zasięgu wzroku i zamienia się z nim miejscami
	var/mob/living/carbon/human/bystander = allocate(/mob/living/carbon/human, other_turf)
	var/obj/item/organ/heart/gland/quantum/quantum_gland = new
	quantum_gland.Insert(abductee)
	quantum_gland.activate()
	TEST_ASSERT(quantum_gland.entangled_mob == bystander, "Quantum gland did not entangle with the bystander in view")
	quantum_gland.quantum_swap()
	TEST_ASSERT(get_turf(abductee) == other_turf, "Abductee did not move to the bystander's place")
	TEST_ASSERT(get_turf(bystander) == start, "Bystander did not move to the abductee's place")
	TEST_ASSERT(isnull(quantum_gland.entangled_mob), "Entanglement stayed after the swap")
	quantum_gland.Remove(abductee)
	qdel(quantum_gland)

	// przemiana: rasa po aktywacji jest jedną z grywalnych
	var/obj/item/organ/heart/gland/pop/transform_gland = new
	transform_gland.Insert(abductee)
	transform_gland.activate()
	TEST_ASSERT(abductee.dna.species.id in GLOB.roundstart_races, "Transform gland picked a non-playable species [abductee.dna.species.id]")
	TEST_ASSERT(!QDELETED(transform_gland) && abductee.getorganslot(ORGAN_SLOT_HEART) == transform_gland, "Transform gland was lost when the new species replaced the organs")
	transform_gland.Remove(abductee)
	qdel(transform_gland)

#undef TEST_ASSERT
