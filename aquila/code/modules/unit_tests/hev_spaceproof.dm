// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - kombinezon HEV dyrektora badań chroni przed próżnią (hełm i kombinezon)
/datum/unit_test/hev_spaceproof

/datum/unit_test/hev_spaceproof/Run()
	var/obj/item/clothing/suit/space/hardsuit/aquila/hazard_suit/suit = allocate(/obj/item/clothing/suit/space/hardsuit/aquila/hazard_suit)
	var/obj/item/clothing/head/helmet/space/hardsuit/aquila/hazard_suit/helmet = allocate(/obj/item/clothing/head/helmet/space/hardsuit/aquila/hazard_suit)

	TEST_ASSERT(suit.clothing_flags & STOPSPRESSUREDAMAGE, "HEV suit does not stop pressure damage")
	TEST_ASSERT(helmet.clothing_flags & STOPSPRESSUREDAMAGE, "HEV helmet does not stop pressure damage")
	TEST_ASSERT(helmet.clothing_flags & SCAN_REAGENTS, "HEV helmet lost its reagent scanner")
	TEST_ASSERT(suit.min_cold_protection_temperature <= SPACE_SUIT_MIN_TEMP_PROTECT, "HEV suit does not protect from space cold")
	TEST_ASSERT(helmet.min_cold_protection_temperature <= SPACE_HELM_MIN_TEMP_PROTECT, "HEV helmet does not protect from space cold")

#undef TEST_ASSERT
