// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - nakładka pudełka przetrwania znika po wyjęciu przedmiotu i wraca po włożeniu go z powrotem
/datum/unit_test/aquila_survivalbox_overlays

/datum/unit_test/aquila_survivalbox_overlays/Run()
	var/obj/item/storage/box/survival/box = allocate(/obj/item/storage/box/survival)
	for(var/overlay_state in GLOB.survivalbox_overlays)
		TEST_ASSERT(overlay_state in box.managed_overlays, "Full survival box is missing overlay [overlay_state]")

	var/obj/item/clothing/head/helmet/space/skinsuit/helmet = locate() in box
	TEST_ASSERT(helmet, "Survival box has no skinsuit helmet")
	SEND_SIGNAL(box, COMSIG_TRY_STORAGE_TAKE, helmet, run_loc_floor_bottom_left)
	TEST_ASSERT(helmet.loc == run_loc_floor_bottom_left, "Helmet was not taken out of the box")
	TEST_ASSERT(!("overlay-survivalbox-helmet" in box.managed_overlays), "Helmet overlay stayed after the helmet was taken out")
	TEST_ASSERT("overlay-survivalbox-oxygen" in box.managed_overlays, "Oxygen overlay disappeared although the tank is still inside")

	SEND_SIGNAL(box, COMSIG_TRY_STORAGE_INSERT, helmet, null, TRUE, TRUE)
	TEST_ASSERT(helmet.loc == box, "Helmet was not put back into the box")
	TEST_ASSERT("overlay-survivalbox-helmet" in box.managed_overlays, "Helmet overlay did not come back after putting the helmet back")

#undef TEST_ASSERT
