// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - zestaw przetrwania: hełm znika z grafiki po wyjęciu, a kieszonka medipena otwiera się dopiero, gdy medipena brakuje
/datum/unit_test/aquila_survivalbox_overlays

/datum/unit_test/aquila_survivalbox_overlays/Run()
	var/obj/item/storage/box/survival/box = allocate(/obj/item/storage/box/survival)
	var/list/overlays_now = survivalbox_test_overlays(box)
	for(var/overlay_state in GLOB.survivalbox_present_overlays)
		TEST_ASSERT(overlay_state in overlays_now, "Full survival kit is missing overlay [overlay_state]")
	for(var/overlay_state in GLOB.survivalbox_missing_overlays)
		TEST_ASSERT(!(overlay_state in overlays_now), "Full survival kit shows open pouch [overlay_state]")

	var/obj/item/clothing/head/helmet/space/skinsuit/helmet = locate() in box
	TEST_ASSERT(helmet, "Survival kit has no skinsuit helmet")
	SEND_SIGNAL(box, COMSIG_TRY_STORAGE_TAKE, helmet, run_loc_floor_bottom_left)
	TEST_ASSERT(helmet.loc == run_loc_floor_bottom_left, "Helmet was not taken out of the kit")
	overlays_now = survivalbox_test_overlays(box)
	TEST_ASSERT(!("overlay-survivalbox-helmet" in overlays_now), "Helmet overlay stayed after the helmet was taken out")

	// The pouch holds the medipen and the adrenaline autoinjector: it opens when both are out
	var/list/pens = list()
	for(var/obj/item/reagent_containers/hypospray/medipen/pen in box)
		pens += pen
	TEST_ASSERT(length(pens), "Survival kit has no medipen")
	for(var/obj/item/reagent_containers/hypospray/medipen/pen as anything in pens)
		SEND_SIGNAL(box, COMSIG_TRY_STORAGE_TAKE, pen, run_loc_floor_bottom_left)
	overlays_now = survivalbox_test_overlays(box)
	TEST_ASSERT("overlay-survivalbox-first-pouch" in overlays_now, "Medipen pouch did not open after the medipen was taken out")
	TEST_ASSERT(!("overlay-survivalbox-second-pouch" in overlays_now), "Mask pouch opened although the mask is still inside")

	for(var/obj/item/reagent_containers/hypospray/medipen/pen as anything in pens)
		SEND_SIGNAL(box, COMSIG_TRY_STORAGE_INSERT, pen, null, TRUE, TRUE)
	SEND_SIGNAL(box, COMSIG_TRY_STORAGE_INSERT, helmet, null, TRUE, TRUE)
	overlays_now = survivalbox_test_overlays(box)
	TEST_ASSERT("overlay-survivalbox-helmet" in overlays_now, "Helmet overlay did not come back after putting the helmet back")
	TEST_ASSERT(!("overlay-survivalbox-first-pouch" in overlays_now), "Medipen pouch stayed open after putting the medipen back")

/// managed_overlays to pojedyncza wartość, gdy nakładka jest jedna
/datum/unit_test/aquila_survivalbox_overlays/proc/survivalbox_test_overlays(obj/item/storage/box/box)
	if(islist(box.managed_overlays))
		return box.managed_overlays
	return box.managed_overlays ? list(box.managed_overlays) : list()

#undef TEST_ASSERT
