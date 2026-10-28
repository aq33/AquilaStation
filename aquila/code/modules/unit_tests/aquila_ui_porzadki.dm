// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - porządki w UI: guziki "śpij" i czujników stroju są w HUD-zie człowieka
/datum/unit_test/aquila_ui_hud_buttons

/datum/unit_test/aquila_ui_hud_buttons/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human)
	dummy.hud_used = new dummy.hud_type(dummy)
	var/datum/hud/hud = dummy.hud_used
	TEST_ASSERT(locate(/atom/movable/screen/sleep_button) in hud.static_inventory, "The human HUD has no sleep button")
	TEST_ASSERT(locate(/atom/movable/screen/suit_sensors) in hud.static_inventory, "The human HUD has no suit sensors button")

#undef TEST_ASSERT
