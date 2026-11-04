// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - przeszukiwanie bez rozbierania: które ubrania mają schowek do przeszukania i że wyjęcie
/// przedmiotu z cudzego schowka trwa, a z własnego nie
/datum/unit_test/aquila_strip_search

/datum/unit_test/aquila_strip_search/Run()
	var/mob/living/carbon/human/owner = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/thief = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))

	var/obj/item/storage/backpack/backpack = allocate(/obj/item/storage/backpack)
	TEST_ASSERT(owner.equip_to_slot_if_possible(backpack, ITEM_SLOT_BACK, disable_warning = TRUE), "Could not put on the backpack")
	TEST_ASSERT(get_strip_search_storage(backpack), "A backpack has nothing to search")

	var/obj/item/clothing/under/color/grey/uniform = allocate(/obj/item/clothing/under/color/grey)
	TEST_ASSERT(!get_strip_search_storage(uniform), "A plain uniform has something to search")
	var/obj/item/clothing/accessory/holster/holster = allocate(/obj/item/clothing/accessory/holster)
	uniform.attach_accessory(holster, null, FALSE)
	TEST_ASSERT(get_strip_search_storage(uniform) == holster.GetComponent(/datum/component/storage), "A uniform with a holster does not search the holster")

	// Z własnego plecaka wyjmuje się od razu
	var/obj/item/pen/own_pen = allocate(/obj/item/pen)
	TEST_ASSERT(SEND_SIGNAL(backpack, COMSIG_TRY_STORAGE_INSERT, own_pen, null, TRUE, TRUE), "Could not put the pen into the backpack")
	var/started = world.time
	own_pen.attack_hand(owner)
	TEST_ASSERT(own_pen in owner.held_items, "The owner could not take a pen out of their own backpack")
	TEST_ASSERT(world.time == started, "Taking from your own backpack took time")

	// Z cudzego plecaka wyjmuje się z opóźnieniem
	var/obj/item/pen/pen = allocate(/obj/item/pen)
	TEST_ASSERT(SEND_SIGNAL(backpack, COMSIG_TRY_STORAGE_INSERT, pen, null, TRUE, TRUE), "Could not put the second pen into the backpack")
	TEST_ASSERT(pen.strip_search_holder(thief) == owner, "The pen in the owner's backpack has no holder for the thief")
	started = world.time
	pen.attack_hand(thief)
	TEST_ASSERT(pen in thief.held_items, "The thief could not take the pen out of the owner's backpack")
	TEST_ASSERT(world.time - started >= strip_search_delay(pen), "Taking from someone's backpack was instant")

#undef TEST_ASSERT
