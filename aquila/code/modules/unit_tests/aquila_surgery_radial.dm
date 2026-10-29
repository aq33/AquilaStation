// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - every operation of the new surgery skeleton gets a picture in the radial menu
/datum/unit_test/aquila_surgery_radial

/datum/unit_test/aquila_surgery_radial/Run()
	for(var/operation_type in GLOB.operations.operations_by_typepath)
		var/datum/surgery_operation/operation = GLOB.operations.operations_by_typepath[operation_type]
		var/image/picture = operation.get_default_radial_image()
		TEST_ASSERT(istype(picture) && picture.icon, "[operation_type] has no radial picture")
		TEST_ASSERT(picture.icon_state in icon_states(picture.icon), "[operation_type] has a radial picture with a missing icon state [picture.icon_state]")

#undef TEST_ASSERT
