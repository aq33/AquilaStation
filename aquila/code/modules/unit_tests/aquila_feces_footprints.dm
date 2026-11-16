// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Wdepnięcie w odchody brudzi buty i zostawia za postacią brązowe ślady (BLOOD_STATE_POOP, stany feces1/2 w footprints.dmi)
/datum/unit_test/aquila_feces_footprints

/datum/unit_test/aquila_feces_footprints/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/poop_turf = get_step(start, EAST)
	var/turf/after = get_step(poop_turf, EAST)
	var/mob/living/carbon/human/walker = allocate(/mob/living/carbon/human, start)
	walker.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(walker), ITEM_SLOT_FEET)
	walker.m_intent = MOVE_INTENT_WALK // odchody są śliskie, ale nie przy chodzeniu
	ADD_TRAIT(walker, TRAIT_NEGATES_GRAVITY, "aquila_feces_footprints") // sala testowa jest bez grawitacji, a ślady powstają tylko z grawitacją
	var/obj/effect/decal/cleanable/feces/poop = allocate(/obj/effect/decal/cleanable/feces, poop_turf)

	TEST_ASSERT(walker.Move(poop_turf, EAST), "Postać nie weszła na kratkę z odchodami")
	var/obj/item/clothing/shoes/shoes = walker.shoes
	TEST_ASSERT(shoes.bloody_shoes[BLOOD_STATE_POOP] > 0, "Buty nie ubrudziły się odchodami")
	TEST_ASSERT(shoes.blood_state == BLOOD_STATE_POOP, "Buty mają stan [shoes.blood_state] zamiast odchodów")
	TEST_ASSERT(!QDELETED(poop) && poop.bloodiness < initial(poop.bloodiness), "Odchody nie straciły nic po wdepnięciu")

	walker.Move(after, EAST)
	var/obj/effect/decal/cleanable/blood/footprints/prints = locate() in after
	var/obj/effect/decal/cleanable/blood/footprints/first_prints = locate() in poop_turf
	TEST_ASSERT(prints, "Za postacią nie ma śladów (postać na [walker.loc == after ? "dobrej" : "złej"] kratce, buty [shoes.bloody_shoes[BLOOD_STATE_POOP]], stan butów [shoes.blood_state], ślad na kupie [first_prints ? "jest" : "brak"], mobility [walker.mobility_flags])")
	TEST_ASSERT(prints.blood_state == BLOOD_STATE_POOP, "Ślady mają stan [prints?.blood_state] zamiast odchodów")
	TEST_ASSERT(prints.get_footprint_icon_state(TRUE) in icon_states(prints.icon), "Brak ikony [prints.get_footprint_icon_state(TRUE)] w [prints.icon]")

/// Ślady nie są alokowane przez test, więc zostałyby na sali dla kolejnych testów (np. aquila_review_paw_prints szuka śladów na tej samej kratce)
/datum/unit_test/aquila_feces_footprints/Destroy()
	for(var/turf/room_turf as anything in block(run_loc_floor_bottom_left, run_loc_floor_top_right))
		for(var/obj/effect/decal/cleanable/leftover in room_turf)
			qdel(leftover)
	return ..()

#undef TEST_ASSERT
