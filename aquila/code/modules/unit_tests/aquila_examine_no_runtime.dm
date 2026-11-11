// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - shift-klik bez opisu: examine() z runtime'em nie wysyła graczowi nic (zgłoszenie gracza)
/datum/unit_test/aquila_examine_no_runtime

/datum/unit_test/aquila_examine_no_runtime/Run()
	var/mob/living/carbon/human/viewer = allocate(/mob/living/carbon/human)
	// konsola przeciwlotnicza bez wieżyczki nad sobą
	for(var/path in list(/obj/machinery/computer/anti_air))
		var/atom/thing = allocate(path)
		var/list/result
		try
			result = thing.examine(viewer)
		catch(var/exception/error)
			TEST_ASSERT(FALSE, "[path] examine() runtimed: [error.name] ([error.file]:[error.line])")
		TEST_ASSERT(length(result), "[path] examine() returned nothing")

#undef TEST_ASSERT
