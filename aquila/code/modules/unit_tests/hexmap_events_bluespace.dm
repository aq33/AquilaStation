// AQUILA - testy eventów z kafli mapy hex portowanych z innych kodów (niestabilność napędu, interfaza, szczeliny, ciemna materia, fale harmoniczne, tłumiki, grawitacja)
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Niestabilność napędu zabiera część ładunku, ale nie w czasie skoku; bez zakłóceń teleportacja nie zawodzi
/datum/unit_test/hexmap_event_drive_instability

/datum/unit_test/hexmap_event_drive_instability/Run()
	var/saved_interference = GLOB.aquila_hex_teleport_interference
	GLOB.aquila_hex_teleport_interference = 0
	for(var/i in 1 to 20)
		if(aquila_hex_teleport_misfire(run_loc_floor_bottom_left))
			GLOB.aquila_hex_teleport_interference = saved_interference
			return Fail("A teleport misfired with no drive instability running")
	GLOB.aquila_hex_teleport_interference = saved_interference

	var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
	var/obj/machinery/computer/ship/ftl_core/drive = ship?.ftl_drive
	if(!drive)
		return // No main ship with a drive on this map
	var/thirring = istype(drive, /obj/machinery/computer/ship/ftl_core)
	var/obj/machinery/computer/ship/ftl_computer/legacy = drive
	var/full = thirring ? drive.req_charge : legacy.spoolup_time
	var/saved_progress = drive.progress
	var/saved_state = drive.ftl_state
	var/saved_active = drive.active
	var/saved_icon = drive.icon_state
	var/was_processing = drive.datum_flags & DF_ISPROCESSING
	var/list/info = SSstar_system.ships[ship]
	var/saved_target = info?["target_system"]
	if(info)
		info["target_system"] = null
	var/fail = check_drain(ship, drive, full)
	if(info)
		info["target_system"] = saved_target
	drive.progress = saved_progress
	drive.ftl_state = saved_state
	drive.active = saved_active
	drive.icon_state = saved_icon
	if(!was_processing)
		STOP_PROCESSING(SSmachines, drive)
	if(fail)
		return Fail(fail)

/datum/unit_test/hexmap_event_drive_instability/proc/check_drain(obj/structure/overmap/ship, obj/machinery/computer/ship/ftl_core/drive, full)
	var/datum/round_event/aquila_hex_drive_instability/event = new(FALSE)
	event.kill()
	drive.progress = full
	drive.active = TRUE
	drive.ftl_state = FTL_STATE_READY
	var/drained = event.drain_drive(ship, 0.4)
	if(abs(drained - 40) > 0.5)
		return "Draining 40% of a full drive took [drained]%"
	if(abs(ship.hex_charge() - 60) > 0.5)
		return "A full drive drained by 40% has [ship.hex_charge()]% charge"
	if(drive.ftl_state == FTL_STATE_READY)
		return "A drive that lost charge still reports it is ready to jump"
	drive.progress = full
	drive.ftl_state = FTL_STATE_JUMPING
	if(event.drain_drive(ship, 0.4))
		return "The drive lost charge during a jump"
	if(abs(ship.hex_charge() - 100) > 0.01)
		return "A jumping drive was drained to [ship.hex_charge()]%"

/// Interfaza bluespace bierze stare wiadomości z logów serwera telekomunikacji, z nadawcą i kanałem serwera
/datum/unit_test/hexmap_event_bluespace_interphase

/datum/unit_test/hexmap_event_bluespace_interphase/Run()
	var/datum/round_event/aquila_hex_bluespace_interphase/event = new(FALSE)
	event.kill()
	var/obj/machinery/telecomms/server/server = allocate(/obj/machinery/telecomms/server)
	server.freq_listening = list(FREQ_SECURITY)
	TEST_ASSERT(isnull(event.pick_replay(list(server))), "A server with no logs gave a message to replay")

	var/datum/comm_log_entry/corrupted = new
	corrupted.input_type = "Uszkodzony plik"
	corrupted.parameters = list("message" = "xzq", "name" = "???", "job" = "???", "language" = /datum/language/common)
	server.log_entries += corrupted
	TEST_ASSERT(isnull(event.pick_replay(list(server))), "A corrupted log entry was replayed")

	var/datum/comm_log_entry/entry = new
	entry.parameters = list("message" = "Ochrona do mostka!", "name" = "Jan Kowalski", "job" = "Kapitan", "language" = /datum/language/common)
	server.log_entries += entry
	var/list/replay = event.pick_replay(list(server))
	TEST_ASSERT(replay, "A logged message was not picked for a replay")
	TEST_ASSERT_EQUAL(replay["message"], "Ochrona do mostka!", "Wrong message replayed")
	TEST_ASSERT_EQUAL(replay["name"], "Jan Kowalski", "The replay lost its original speaker")
	TEST_ASSERT_EQUAL(replay["frequency"], FREQ_SECURITY, "The replay is not on the server's channel")
	event.broadcast_replay(replay)

	server.freq_listening = list(FREQ_SECURITY, FREQ_COMMAND)
	replay = event.pick_replay(list(server))
	TEST_ASSERT_EQUAL(replay?["frequency"], FREQ_COMMON, "A server listening on many channels did not replay on the common channel")

/// Szczeliny bluespace powstają parami, prowadzą w obie strony i znikają razem po zużyciu przejść
/datum/unit_test/hexmap_event_bluespace_rifts

/datum/unit_test/hexmap_event_bluespace_rifts/Run()
	var/datum/round_event/aquila_hex_bluespace_rifts/event = new(FALSE)
	event.kill()
	var/turf/entrance = run_loc_floor_bottom_left
	var/turf/exit = run_loc_floor_top_right
	var/list/pair = event.open_rift_pair(entrance, exit, 2)
	TEST_ASSERT_EQUAL(length(pair), 2, "Rifts did not open as a pair")
	var/obj/effect/portal/aquila_hex_rift/first = pair[1]
	var/obj/effect/portal/aquila_hex_rift/second = pair[2]
	allocated += first
	allocated += second
	TEST_ASSERT(first.linked == second && second.linked == first, "The rifts are not linked to each other")
	TEST_ASSERT_EQUAL(get_turf(second), exit, "The second rift opened in the wrong place")

	var/mob/living/carbon/human/traveller = allocate(/mob/living/carbon/human, entrance)
	TEST_ASSERT(first.teleport(traveller), "The rift did not take anyone through")
	TEST_ASSERT_EQUAL(get_turf(traveller), exit, "The rift sent its traveller to the wrong place")
	TEST_ASSERT(!QDELETED(first) && !QDELETED(second), "The rift pair collapsed before running out of uses")
	TEST_ASSERT(first.uses_left == 1 && second.uses_left == 1, "A trip did not use up a crossing on both sides ([first.uses_left], [second.uses_left])")

	TEST_ASSERT(second.teleport(traveller), "The rift does not work the other way")
	TEST_ASSERT_EQUAL(get_turf(traveller), entrance, "The way back led to the wrong place")
	TEST_ASSERT(QDELETED(first) && QDELETED(second), "The rift pair did not collapse after its last crossing")

/// Napływ ciemnej materii dobija zawroty i dezorientację tylko do limitu
/datum/unit_test/hexmap_event_dark_matter_influx

/datum/unit_test/hexmap_event_dark_matter_influx/Run()
	var/datum/round_event/aquila_hex_dark_matter_influx/event = new(FALSE)
	event.kill()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	event.add_disorientation(victim, 10, 10)
	TEST_ASSERT(victim.dizziness >= 10 && victim.confused >= 10, "Dark matter did not make anyone dizzy or confused")
	for(var/i in 1 to 50)
		event.add_disorientation(victim, 20, 25)
	TEST_ASSERT(victim.dizziness <= 60, "Dizziness piled up past the cap: [victim.dizziness]")
	TEST_ASSERT(victim.confused <= 30, "Confusion piled up past the cap: [victim.confused]")
	victim.dizziness = 0
	victim.confused = 0

/// Fale harmoniczne zabierają tarczy energię i nie schodzą poniżej zera
/datum/unit_test/hexmap_event_harmonic_surge

/datum/unit_test/hexmap_event_harmonic_surge/Run()
	var/datum/round_event/aquila_hex_harmonic_surge/event = new(FALSE)
	event.kill()
	var/list/shield = list("integrity" = 1000, "max_integrity" = 1000)
	TEST_ASSERT_EQUAL(event.drain_shield(shield), 10, "Wrong drain from a full 1000 point shield")
	TEST_ASSERT_EQUAL(shield["integrity"], 990, "The shield did not lose energy")
	shield["integrity"] = 3
	event.drain_shield(shield)
	TEST_ASSERT_EQUAL(shield["integrity"], 0, "A weak shield did not drop to zero")
	TEST_ASSERT_EQUAL(event.drain_shield(shield), 0, "An empty shield was drained further")

	var/list/ship_shield = aquila_hex_shield_data(SSstar_system.find_main_overmap())
	if(!ship_shield)
		return // No main ship with shields on this map
	var/saved_integrity = ship_shield["integrity"]
	var/saved_max = ship_shield["max_integrity"]
	ship_shield["max_integrity"] = 1000
	ship_shield["integrity"] = 1000
	event.tick()
	var/after = ship_shield["integrity"]
	ship_shield["integrity"] = saved_integrity
	ship_shield["max_integrity"] = saved_max
	TEST_ASSERT(after < 1000, "The surge did not touch the main ship's shields")

/// Rekalibracja osłabia tłumik i blokuje IAS, a potem przywraca jedno i drugie
/datum/unit_test/hexmap_event_damper_recalibration

/datum/unit_test/hexmap_event_damper_recalibration/Run()
	var/datum/round_event/aquila_hex_damper_recalibration/event = new(FALSE)
	event.kill()
	var/obj/machinery/inertial_dampener/machine = allocate(/obj/machinery/inertial_dampener)
	var/base_strength = machine.strengthMultiplier
	TEST_ASSERT(base_strength < 1, "A test dampener does not dampen at all ([base_strength])")
	event.weaken_dampener(machine)
	TEST_ASSERT(machine.strengthMultiplier > base_strength && machine.strengthMultiplier < 1, "The dampener was not weakened ([base_strength] -> [machine.strengthMultiplier])")
	event.restore_dampener(machine)
	TEST_ASSERT_EQUAL(machine.strengthMultiplier, base_strength, "The dampener did not get its strength back")

	var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
	if(!ship)
		return
	var/saved_ias = ship.inertial_dampeners
	ship.inertial_dampeners = TRUE
	var/was_on = event.disable_ias(ship)
	var/blocked_off = !ship.inertial_dampeners
	var/blocked_trait = HAS_TRAIT_FROM(ship, TRAIT_NODAMPENERS, "aquila_hex_damper_recalibration")
	var/could_enable = ship.enable_dampeners()
	event.restore_ias(ship, was_on)
	var/restored = ship.inertial_dampeners
	var/trait_left = HAS_TRAIT_FROM(ship, TRAIT_NODAMPENERS, "aquila_hex_damper_recalibration")
	var/other_block = HAS_TRAIT(ship, TRAIT_NODAMPENERS)
	ship.inertial_dampeners = saved_ias
	TEST_ASSERT(was_on, "The event did not notice the IAS was on")
	TEST_ASSERT(blocked_off && blocked_trait, "The IAS was not turned off and locked")
	TEST_ASSERT(!could_enable, "The IAS could be turned back on during the recalibration")
	TEST_ASSERT(!trait_left, "The IAS lock stayed after the recalibration")
	if(!other_block)
		TEST_ASSERT(restored, "The IAS did not come back on after the recalibration")

/// Awaria grawitacji wyłącza działający generator, nie pozwala go włączyć w trakcie i przywraca go na koniec
/datum/unit_test/hexmap_event_gravity_failure

/datum/unit_test/hexmap_event_gravity_failure/Run()
	var/datum/round_event/aquila_hex_gravity_failure/event = new(FALSE)
	event.kill()
	var/obj/machinery/gravity_generator/main/generator = allocate(/obj/machinery/gravity_generator/main)
	TEST_ASSERT(generator.on && generator.breaker, "A new gravity generator is not running")
	TEST_ASSERT(event.disable_generator(generator), "A running generator was not shut down")
	TEST_ASSERT(!generator.on && !generator.breaker, "The generator kept running after the failure")
	TEST_ASSERT(generator in event.disabled_generators, "The event forgot which generator it shut down")
	TEST_ASSERT(!event.disable_generator(generator), "The same generator was shut down twice")

	generator.breaker = TRUE // ktoś włącza wyłącznik w trakcie awarii
	generator.set_power()
	event.tick()
	TEST_ASSERT(!generator.breaker, "The generator could be turned back on during the failure")

	event.end()
	TEST_ASSERT(generator.breaker, "The generator was not turned back on after the failure")
	TEST_ASSERT(generator.charging_state != POWER_IDLE, "The restored generator did not start its power sequence")
	TEST_ASSERT(!length(event.disabled_generators), "The event kept generators after it ended")

	// Admin zatrzymuje awarię przez kill(): generator wraca tak samo jak po end()
	var/datum/round_event/aquila_hex_gravity_failure/killed = new(FALSE)
	var/obj/machinery/gravity_generator/main/killed_generator = allocate(/obj/machinery/gravity_generator/main)
	TEST_ASSERT(killed.disable_generator(killed_generator), "A running generator was not shut down before kill()")
	killed.kill()
	TEST_ASSERT(killed_generator.breaker, "kill() left the generator switched off")
	TEST_ASSERT(!length(killed.disabled_generators), "kill() kept generators on the list")

	var/obj/machinery/gravity_generator/main/off_generator = allocate(/obj/machinery/gravity_generator/main)
	off_generator.breaker = FALSE
	off_generator.set_state(FALSE)
	TEST_ASSERT(!event.disable_generator(off_generator), "A generator that was already off was taken over by the event")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
