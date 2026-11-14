// AQUILA - testy eventów zagrożeń statku z mapy hex (burze, rozbłyski, APC, komputery, czujniki)
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// EMP storm: the pulse drains a power cell lying at the epicenter
/datum/unit_test/aquila_hex_emp_storm

/datum/unit_test/aquila_hex_emp_storm/Run()
	var/obj/item/stock_parts/cell/high/cell = allocate(/obj/item/stock_parts/cell/high, run_loc_floor_bottom_left)
	var/charge_before = cell.charge
	var/datum/round_event/aquila_hex_emp_storm/event = new(FALSE)
	event.strength = 1 // smallest pulse, so the test room stays intact
	event.pulse(run_loc_floor_bottom_left)
	event.kill()
	TEST_ASSERT(cell.charge < charge_before, "The EMP storm pulse did not drain the cell at its epicenter ([cell.charge]/[charge_before])")

/// Solar flare: the turfs around the epicenter catch fire
/datum/unit_test/aquila_hex_solar_flare

/datum/unit_test/aquila_hex_solar_flare/Run()
	var/turf/open/epicenter = run_loc_floor_bottom_left
	var/datum/round_event/aquila_hex_solar_flare/event = new(FALSE)
	event.strength = 1 // radius 1
	event.flare(epicenter)
	event.kill()
	var/had_fire = !isnull(epicenter.turf_fire)
	for(var/turf/open/T in circlerangeturfs(epicenter, 2))
		if(T.turf_fire)
			qdel(T.turf_fire)
	TEST_ASSERT(had_fire, "The solar flare did not set its epicenter on fire")

/// Solar storm: burns mobs standing in space, people indoors are left alone
/datum/unit_test/aquila_hex_solar_storm

/datum/unit_test/aquila_hex_solar_storm/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/space_turf = locate(start.x + 1, start.y, start.z)
	var/old_type = space_turf.type
	var/list/old_baseturfs = space_turf.baseturfs
	space_turf = space_turf.ChangeTurf(/turf/open/space/basic)

	var/mob/living/carbon/human/spacewalker = allocate(/mob/living/carbon/human, space_turf)
	var/mob/living/carbon/monkey/monkey = allocate(/mob/living/carbon/monkey, space_turf)
	var/mob/living/carbon/human/indoors = allocate(/mob/living/carbon/human, start)
	var/walker_temp = spacewalker.bodytemperature
	var/indoors_temp = indoors.bodytemperature
	var/monkey_burn = monkey.getFireLoss()

	var/datum/round_event/aquila_hex_solar_storm/event = new(FALSE)
	var/walker_hit = event.expose(spacewalker)
	var/monkey_hit = event.expose(monkey)
	var/indoors_hit = event.expose(indoors)
	event.kill()
	var/walker_temp_after = spacewalker.bodytemperature
	var/monkey_burn_after = monkey.getFireLoss()
	var/indoors_temp_after = indoors.bodytemperature
	space_turf.ChangeTurf(old_type, old_baseturfs)

	TEST_ASSERT(walker_hit && walker_temp_after > walker_temp, "The solar storm did not heat up a human in space ([walker_temp] -> [walker_temp_after])")
	TEST_ASSERT(monkey_hit && monkey_burn_after > monkey_burn, "The solar storm did not burn a monkey in space")
	TEST_ASSERT(!indoors_hit && indoors_temp_after == indoors_temp, "The solar storm heated up a human indoors")
	TEST_ASSERT_EQUAL(GLOB.aquila_hex_solar_multiplier, 1, "A stopped solar storm left the solar panels boosted")

/// APC damage: the interface of the APC is broken like with an emag, an already broken one is skipped
/datum/unit_test/aquila_hex_apc_damage

/datum/unit_test/aquila_hex_apc_damage/Run()
	// APC built outside mapload: no area, terminal or cell of its own
	var/obj/machinery/power/apc/apc = allocate(/obj/machinery/power/apc, run_loc_floor_top_right)
	apc.end_processing()
	QDEL_NULL(apc.cell)
	if(apc.terminal)
		apc.terminal.master = null
		QDEL_NULL(apc.terminal)
	apc.locked = TRUE

	var/datum/round_event/aquila_hex_apc_damage/event = new(FALSE)
	var/first = event.damage_apcs(apc, 0)
	var/second = event.damage_apcs(apc, 0)
	event.kill()
	TEST_ASSERT_EQUAL(first, 1, "APC damage did not break the APC")
	TEST_ASSERT(apc.obj_flags & EMAGGED, "The damaged APC is not emagged")
	TEST_ASSERT(!apc.locked, "The damaged APC is still locked")
	TEST_ASSERT_EQUAL(second, 0, "APC damage broke the same APC twice")

/// Computer damage: a failed drive stops working, a malfunctioning one is only past the malfunction threshold
/datum/unit_test/aquila_hex_computer_damage

/datum/unit_test/aquila_hex_computer_damage/Run()
	var/obj/item/modular_computer/laptop/preset/civillian/failed = allocate(/obj/item/modular_computer/laptop/preset/civillian, run_loc_floor_bottom_left)
	var/obj/item/modular_computer/laptop/preset/civillian/glitchy = allocate(/obj/item/modular_computer/laptop/preset/civillian, run_loc_floor_bottom_left)
	var/obj/item/computer_hardware/hard_drive/failed_drive = failed.all_components[MC_HDD]
	var/obj/item/computer_hardware/hard_drive/glitchy_drive = glitchy.all_components[MC_HDD]
	TEST_ASSERT(failed_drive && glitchy_drive, "The preset laptop has no hard drive")

	var/datum/round_event/aquila_hex_computer_damage/event = new(FALSE)
	event.damage_drive(failed, TRUE)
	event.damage_drive(glitchy, FALSE)
	event.kill()
	TEST_ASSERT(!failed_drive.check_functionality(), "A failed hard drive still works")
	TEST_ASSERT(glitchy_drive.damage > glitchy_drive.damage_malfunction && glitchy_drive.damage <= glitchy_drive.damage_failure, "A malfunctioning hard drive has the wrong damage ([glitchy_drive.damage])")

/// Sensor jamming: the crew monitor shows nobody while jammed and shows the crew again afterwards
/datum/unit_test/aquila_hex_sensor_jamming

/datum/unit_test/aquila_hex_sensor_jamming/Run()
	var/mob/living/carbon/human/crewman = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/item/clothing/under/color/grey/uniform = allocate(/obj/item/clothing/under/color/grey)
	crewman.equip_to_slot_or_del(uniform, ITEM_SLOT_ICLOTHING)
	uniform.update_sensors(SENSOR_COORDS, TRUE)
	TEST_ASSERT(crewman in GLOB.suit_sensors_list, "The test crewman has no working suit sensors")
	var/turf/T = get_turf(crewman)
	var/z = crewman.get_virtual_z_level()
	var/crewman_ref = REF(crewman)

	GLOB.crewmonitor.last_update -= "[z]"
	var/seen_before = aquila_hex_monitor_shows(GLOB.crewmonitor.update_data(z, T.z), crewman_ref)

	var/datum/round_event/aquila_hex_sensor_jamming/event = new(FALSE)
	event.start_jamming()
	GLOB.crewmonitor.last_update -= "[z]"
	var/jammed_count = length(GLOB.crewmonitor.update_data(z, T.z))
	event.kill() // releases the jam
	var/jams_left = GLOB.aquila_hex_sensor_jams

	GLOB.crewmonitor.last_update -= "[z]"
	var/seen_after = aquila_hex_monitor_shows(GLOB.crewmonitor.update_data(z, T.z), crewman_ref)

	TEST_ASSERT(seen_before, "The crew monitor did not show the crewman before the jamming")
	TEST_ASSERT_EQUAL(jammed_count, 0, "The jammed crew monitor still reported people")
	TEST_ASSERT_EQUAL(jams_left, 0, "The jam was not released when the event ended")
	TEST_ASSERT(seen_after, "The crew monitor did not show the crewman again after the jamming")

/datum/unit_test/aquila_hex_sensor_jamming/proc/aquila_hex_monitor_shows(list/entries, crewman_ref)
	for(var/list/entry as anything in entries)
		if(entry["ref"] == crewman_ref)
			return TRUE
	return FALSE

/// Zatrzymany przez admina event sprząta tylko po sobie: burza nie gasi paneli innej burzy, niestabilność oddaje swoje zakłócenia raz
/datum/unit_test/hexmap_event_kill_cleanup

/datum/unit_test/hexmap_event_kill_cleanup/Run()
	var/datum/round_event/aquila_hex_solar_storm/first = new(FALSE)
	var/datum/round_event/aquila_hex_solar_storm/second = new(FALSE)
	first.set_solar_level(5)
	second.set_solar_level(1.5)
	first.kill()
	var/after_first = GLOB.aquila_hex_solar_multiplier
	second.kill()
	var/after_both = GLOB.aquila_hex_solar_multiplier
	TEST_ASSERT_EQUAL(after_first, 1.5, "Stopping one solar storm reset the panels boosted by another one")
	TEST_ASSERT_EQUAL(after_both, 1, "The panels stayed boosted after both solar storms stopped")

	var/saved_interference = GLOB.aquila_hex_teleport_interference
	var/datum/round_event/aquila_hex_drive_instability/instability = new(FALSE)
	GLOB.aquila_hex_teleport_interference++
	instability.interference_active = TRUE
	instability.kill()
	var/after_kill = GLOB.aquila_hex_teleport_interference
	instability.end()
	var/after_end = GLOB.aquila_hex_teleport_interference
	GLOB.aquila_hex_teleport_interference = saved_interference
	TEST_ASSERT_EQUAL(after_kill, saved_interference, "A stopped drive instability left the teleporters jammed")
	TEST_ASSERT_EQUAL(after_end, saved_interference, "A drive instability released its interference twice")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
