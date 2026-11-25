// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Probe ship: the hearers are set by the test and the stopped listeners are recorded instead of sending sounds
/obj/structure/overmap/small_craft/combat/light/aq_relay_probe
	var/list/probe_hearers = list()
	var/list/probe_stopped = list()

/obj/structure/overmap/small_craft/combat/light/aq_relay_probe/aq_relay_hearers(list/hearers = list())
	hearers |= probe_hearers
	return hearers

/obj/structure/overmap/small_craft/combat/light/aq_relay_probe/aq_relay_stop_loop(listener, channel)
	probe_stopped += "[listener]@[channel]"

/// AQUILA - a looping relay() alarm (stormdrive overheating) kept playing for a player who left the ship (died, ghosted, flew off)
/// before stop_relay(): stop_relay() must silence it for everyone who got the loop, not only the current crew
/datum/unit_test/aquila_relay_loop_stop

/datum/unit_test/aquila_relay_loop_stop/Run()
	var/obj/structure/overmap/small_craft/combat/light/aq_relay_probe/ship = allocate(/obj/structure/overmap/small_craft/combat/light/aq_relay_probe)

	ship.probe_hearers = list("gracz_a", "gracz_b")
	ship.relay('nsv13/sound/effects/ship/reactor/core_overheating.ogg', null, loop = TRUE, channel = CHANNEL_REACTOR_ALERT)
	// gracz_a ginie i zostaje duchem poza statkiem, a na pokład wchodzi gracz_c, zanim reaktor się ochłodzi
	ship.probe_hearers = list("gracz_b", "gracz_c")
	ship.stop_relay(CHANNEL_REACTOR_ALERT)

	TEST_ASSERT("gracz_a@[CHANNEL_REACTOR_ALERT]" in ship.probe_stopped, "The loop was not stopped for a player who left the ship: [json_encode(ship.probe_stopped)]")
	TEST_ASSERT("gracz_b@[CHANNEL_REACTOR_ALERT]" in ship.probe_stopped, "The loop was not stopped for a player still aboard: [json_encode(ship.probe_stopped)]")
	TEST_ASSERT(!LAZYACCESS(ship.aq_relay_loop_listeners, "[CHANNEL_REACTOR_ALERT]"), "The listener list survived stop_relay()")

	// A one-off sound (no loop) is not remembered, there is nothing to stop later
	ship.probe_stopped.Cut()
	ship.relay('nsv13/sound/effects/ship/reactor/core_overheating.ogg', null, loop = FALSE, channel = CHANNEL_REACTOR_ALERT)
	ship.stop_relay(CHANNEL_REACTOR_ALERT)
	TEST_ASSERT(!length(ship.probe_stopped), "A non-looping relay() was stopped for remembered listeners: [json_encode(ship.probe_stopped)]")

#undef TEST_ASSERT
