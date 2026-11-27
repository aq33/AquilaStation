#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - zlecenie szpiega na zdjęcie (spy_bounty_photo.dm): liczy się zdjęcie żywej osoby, w wersji z miejscem
/// tylko wtedy, gdy stała w tym obszarze; aparat zapisuje obszar każdej osoby na zdjęciu
/datum/unit_test/aquila_spy_photo

/datum/unit_test/aquila_spy_photo/Run()
	var/datum/spy_bounty_handler/photo_test/handler = new
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/stranger = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)

	// Aparat zapisuje, gdzie stała osoba na zdjęciu
	var/obj/item/camera/camera = allocate(/obj/item/camera, run_loc_floor_bottom_left)
	var/datum/picture/snapshot = new("ujęcie", "", list(target), list())
	camera.after_picture(null, snapshot, FALSE)
	for(var/obj/item/photo/printed in run_loc_floor_bottom_left)
		qdel(printed)
	var/area/here = get_area(target)
	TEST_ASSERT(snapshot.aquila_seen_areas?[REF(target)] == here.type, "Aparat nie zapisał obszaru osoby na zdjęciu")

	var/datum/spy_bounty/targets_person/photo/bounty = new(handler)
	bounty.target_ref = WEAKREF(target)

	var/datum/picture/good_picture = new("ujęcie", "", list(target), list())
	good_picture.aquila_seen_areas = list()
	good_picture.aquila_seen_areas[REF(target)] = /area/security/brig
	var/obj/item/photo/good = allocate(/obj/item/photo, run_loc_floor_bottom_left, good_picture)
	TEST_ASSERT(bounty.is_stealable(good), "Zdjęcie żywego celu nie pasuje do zlecenia")

	var/datum/picture/wrong_picture = new("ujęcie", "", list(stranger), list())
	var/obj/item/photo/wrong = allocate(/obj/item/photo, run_loc_floor_bottom_left, wrong_picture)
	TEST_ASSERT(!bounty.is_stealable(wrong), "Zdjęcie innej osoby pasuje do zlecenia")

	var/datum/picture/dead_picture = new("ujęcie", "", list(target), list(target))
	var/obj/item/photo/corpse = allocate(/obj/item/photo, run_loc_floor_bottom_left, dead_picture)
	TEST_ASSERT(!bounty.is_stealable(corpse), "Zdjęcie zwłok celu pasuje do zlecenia na zdjęcie żywej osoby")
	TEST_ASSERT(!bounty.is_stealable(stranger), "Osoba zamiast zdjęcia pasuje do zlecenia")

	// Wersja z miejscem: cel musi stać w swoim dziale
	var/datum/spy_bounty/targets_person/photo/location/placed = new(handler)
	placed.target_ref = WEAKREF(target)
	placed.required_area = /area/security
	TEST_ASSERT(placed.is_stealable(good), "Zdjęcie celu w brygu nie liczy się jako zdjęcie w dziale ochrony")
	placed.required_area = /area/bridge
	TEST_ASSERT(!placed.is_stealable(good), "Zdjęcie celu w brygu liczy się jako zdjęcie na mostku")

	qdel(bounty)
	qdel(placed)
	qdel(handler)

/// Pusty zarządca zleceń: bez nagród i timera odświeżania, tylko lista zleceń
/datum/spy_bounty_handler/photo_test

/datum/spy_bounty_handler/photo_test/New()
	return

#undef TEST_ASSERT
