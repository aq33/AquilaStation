// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_NULL(a, message) do { \
	var/_val = ##a; \
	if (!isnull(_val)) { \
		return Fail("Expected [_val] to be null.[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - ByondUi map controls rendered in a tgui window are remembered and removed when the window closes or reinitializes
/datum/unit_test/byondui_cleanup

/// A window without a client, so the test does not touch the client's window pool
/datum/tgui_window/byondui_test

/datum/tgui_window/byondui_test/New()
	return

/datum/unit_test/byondui_cleanup/Run()
	var/datum/tgui_window/byondui_test/window = new

	window.on_message("renderByondUi", list("renderByondUi" = "preview_map"))
	TEST_ASSERT("preview_map" in window.byondui_elements, "A rendered ByondUi control was not remembered")

	window.on_message("unmountByondUi", list("renderByondUi" = "preview_map"))
	TEST_ASSERT_NULL(window.byondui_elements, "An unmounted ByondUi control is still remembered")

	window.on_message("renderByondUi", list("renderByondUi" = "preview_map"))
	window.close()
	TEST_ASSERT_NULL(window.byondui_elements, "Closing the window did not clear its ByondUi controls")

	qdel(window)

#undef TEST_ASSERT
#undef TEST_ASSERT_NULL
