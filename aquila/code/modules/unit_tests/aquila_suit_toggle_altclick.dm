// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - Alt+klik na fartuchu laboratoryjnym w ręce rozpina go i zapina z powrotem (wcześniej nic się nie działo)
/datum/unit_test/aquila_suit_toggle_altclick

/datum/unit_test/aquila_suit_toggle_altclick/Run()
	var/mob/living/carbon/human/doctor = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/item/clothing/suit/toggle/labcoat/coat = allocate(/obj/item/clothing/suit/toggle/labcoat)
	doctor.put_in_hands(coat)

	coat.AltClick(doctor)
	TEST_ASSERT(coat.suittoggled, "Alt-click did not unbutton the labcoat")
	TEST_ASSERT(coat.icon_state == "labcoat_t", "Unbuttoned labcoat has icon_state [coat.icon_state] instead of labcoat_t")

	coat.AltClick(doctor)
	TEST_ASSERT(!coat.suittoggled, "Second alt-click did not button the labcoat back")
	TEST_ASSERT(coat.icon_state == "labcoat", "Buttoned labcoat has icon_state [coat.icon_state] instead of labcoat")

#undef TEST_ASSERT
