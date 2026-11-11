// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - General Quarters turns the ship lights red only for a while, not for the whole alert (they looked like a fire alarm everywhere)
/datum/unit_test/aquila_gq_lights
	/// Escape pod consoles and their admin lock before the test (set_security_level unlocks them)
	var/list/pod_locks = list()

/datum/unit_test/aquila_gq_lights/Run()
	for(var/obj/machinery/computer/shuttle_flight/pod/pod in GLOB.machines)
		pod_locks[pod] = pod.admin_controlled
	set_security_level(SEC_LEVEL_GREEN)

	set_security_level(SEC_LEVEL_RED)
	var/area/ship_area = GLOB.teleportlocs[GLOB.teleportlocs[1]]
	TEST_ASSERT(ship_area?.redalert, "General Quarters did not turn the red lights on")
	var/list/timers = gq_light_timers()
	TEST_ASSERT(length(timers) == 1, "General Quarters must leave exactly one timer that switches the red lights off, got [length(timers)]")
	var/datum/timedevent/timer = timers[1]
	TEST_ASSERT(abs(timer.timeToRun - world.time - 45 SECONDS) <= 1 SECONDS, "The red lights go off after [(timer.timeToRun - world.time) / 10] s instead of 45 s")

	// A new alert restarts the timer instead of adding one, so an old timer can't switch off the lights of a new alert
	set_security_level(SEC_LEVEL_GREEN)
	set_security_level(SEC_LEVEL_RED)
	timers = gq_light_timers()
	TEST_ASSERT(length(timers) == 1, "A second General Quarters left [length(timers)] red light timers")

	timer = timers[1]
	timer.callBack.Invoke()
	for(var/key in GLOB.teleportlocs)
		var/area/checked_area = GLOB.teleportlocs[key]
		TEST_ASSERT(!checked_area.redalert, "[checked_area] kept the red General Quarters lights after the timer ran")

/datum/unit_test/aquila_gq_lights/Destroy()
	// Nothing of the test may outlive it: the pending timer would switch off the lights of a later test, pods stay unlocked
	for(var/datum/timedevent/timer as anything in gq_light_timers())
		qdel(timer)
	if(GLOB.security_level != SEC_LEVEL_GREEN)
		set_security_level(SEC_LEVEL_GREEN)
	for(var/obj/machinery/computer/shuttle_flight/pod/pod as anything in pod_locks)
		if(!QDELETED(pod))
			pod.admin_controlled = pod_locks[pod]
	pod_locks = null
	return ..()

/datum/unit_test/aquila_gq_lights/proc/gq_light_timers()
	. = list()
	for(var/hash in SStimer.hashes)
		var/datum/timedevent/timer = SStimer.hashes[hash]
		if(timer && !timer.spent && timer.callBack?.delegate == GLOBAL_PROC_REF(toggle_gq_lights))
			. += timer

/// AQUILA - Condition Zebra closes the firelocks, any other alert opens them again (the handler used to read the sender as the level)
/datum/unit_test/aquila_zebra_firedoors

/datum/unit_test/aquila_zebra_firedoors/Run()
	// Handler działa tylko na poziomach stacji, a pokój testowy nim nie jest: bierzemy działające drzwi ze statku
	var/obj/machinery/door/firedoor/door
	for(var/obj/machinery/door/firedoor/candidate in GLOB.machines)
		if(is_station_level(candidate.z) && !candidate.welded && !(candidate.machine_stat & (NOPOWER|BROKEN)) && !candidate.operating)
			var/area/door_area = get_area(candidate)
			if(!door_area?.fire && !candidate.is_holding_pressure())
				door = candidate
				break
	TEST_ASSERT(door, "No working firelock on a station level to test with")
	var/was_closed = door.density
	if(was_closed)
		door.open()
		wait_for_firedoor(door, FALSE)
	TEST_ASSERT(!door.density, "The test firelock didn't open")

	// Jak sygnał (nadawca, poziom), ale tylko do tych drzwi: reszta statku zostaje w spokoju
	door.on_alert_level_change(SSdcs, SEC_LEVEL_ZEBRA)
	wait_for_firedoor(door, TRUE)
	TEST_ASSERT(door.density, "Condition Zebra didn't close the firelock")

	door.on_alert_level_change(SSdcs, SEC_LEVEL_GREEN)
	wait_for_firedoor(door, FALSE)
	TEST_ASSERT(!door.density, "Leaving Condition Zebra didn't open the firelock")

	if(was_closed)
		door.close()
		wait_for_firedoor(door, TRUE)

/datum/unit_test/aquila_zebra_firedoors/proc/wait_for_firedoor(obj/machinery/door/firedoor/door, closed)
	var/timeout = world.time + 5 SECONDS
	while(world.time < timeout && (door.operating || (!door.density) == closed))
		sleep(1)

#undef TEST_ASSERT
