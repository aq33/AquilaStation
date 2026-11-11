// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - General Quarters turns the ship lights red only for a while, not for the whole alert (they looked like a fire alarm everywhere)
/datum/unit_test/aquila_gq_lights

/datum/unit_test/aquila_gq_lights/Run()
	var/old_level = GLOB.security_level
	set_security_level(SEC_LEVEL_GREEN)

	set_security_level(SEC_LEVEL_RED)
	var/area/ship_area = GLOB.teleportlocs[GLOB.teleportlocs[1]]
	TEST_ASSERT(ship_area?.redalert, "General Quarters did not turn the red lights on")
	var/list/timers = gq_light_timers()
	TEST_ASSERT(length(timers) == 1, "General Quarters must leave exactly one timer that switches the red lights off")

	// A second alert (Zebra) restarts the timer instead of adding one, so an old timer can't switch off the lights of a new alert
	set_security_level(SEC_LEVEL_ZEBRA)
	timers = gq_light_timers()
	TEST_ASSERT(length(timers) == 1, "Condition Zebra after General Quarters left [length(timers)] red light timers")

	var/datum/timedevent/timer = timers[1]
	timer.callBack.InvokeAsync()
	for(var/key in GLOB.teleportlocs)
		var/area/checked_area = GLOB.teleportlocs[key]
		TEST_ASSERT(!checked_area.redalert, "[checked_area] kept the red General Quarters lights after the timer ran")

	set_security_level(SEC_LEVEL_GREEN)
	if(old_level != SEC_LEVEL_GREEN)
		set_security_level(old_level)

/datum/unit_test/aquila_gq_lights/proc/gq_light_timers()
	. = list()
	for(var/hash in SStimer.hashes)
		var/datum/timedevent/timer = SStimer.hashes[hash]
		if(timer && !timer.spent && timer.callBack?.delegate == GLOBAL_PROC_REF(toggle_gq_lights))
			. += timer

#undef TEST_ASSERT
