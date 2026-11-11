/// AQUILA - sensor console (aquila/code/modules/overmap/sensor_console.dm): the radar operator designates targets,
/// the tactical console and every DRADIS get them, DRADIS loses its sensor controls and follows the operator's pulse,
/// and active radar pulses with nobody looking at a window.
/datum/unit_test/aquila_sensor_console
	var/obj/structure/overmap/small_craft/ship
	var/obj/structure/overmap/small_craft/enemy
	var/obj/structure/overmap/small_craft/second_enemy
	var/obj/machinery/computer/ship/dradis/sensors/station
	var/obj/machinery/computer/ship/dradis/display
	var/obj/machinery/computer/ship/tactical/tactical

/datum/unit_test/aquila_sensor_console/Run()
	var/was_enabled = GLOB.sensor_signature_enabled
	GLOB.sensor_signature_enabled = FALSE // Plain visibility rules, the signature system has its own test
	ship = allocate(/obj/structure/overmap/small_craft/combat/light)
	enemy = allocate(/obj/structure/overmap/small_craft/combat/light)
	second_enemy = allocate(/obj/structure/overmap/small_craft/combat/light)
	enemy.faction = "syndicate"
	second_enemy.faction = "syndicate"
	var/z = run_loc_floor_bottom_left.z
	ship.forceMove(locate(10, 10, z))
	enemy.forceMove(locate(15, 10, z))
	second_enemy.forceMove(locate(10, 16, z))
	station = allocate(/obj/machinery/computer/ship/dradis/sensors)
	display = allocate(/obj/machinery/computer/ship/dradis)
	tactical = allocate(/obj/machinery/computer/ship/tactical)
	for(var/obj/machinery/computer/ship/console as anything in list(station, display, tactical))
		console.forceMove(ship) // get_overmap() finds the ship through loc, the test z level has no linked overmap
		console.linked = ship
		console.set_position(ship)
	var/fail = check_designation() || check_bridge_view() || check_dradis_controls() || check_radar_process() || check_cleanup()
	GLOB.sensor_signature_enabled = was_enabled
	if(fail)
		return Fail(fail)

/datum/unit_test/aquila_sensor_console/proc/check_designation()
	if(ship.sensor_console != station)
		return "The sensor console did not register itself on the ship"
	if(ship.dradis == station)
		return "The sensor console took the DRADIS slot the pilot's popup uses"
	if(!station.designate(enemy, "primary"))
		return "Could not designate a visible enemy"
	station.designate(second_enemy, "primary")
	if(ship.designated_targets[second_enemy] != "primary" || ship.designated_targets[enemy] != "secondary")
		return "A new primary target did not demote the old one (got [ship.designated_targets[enemy]] / [ship.designated_targets[second_enemy]])"
	station.designate(second_enemy, null)
	if(LAZYACCESS(ship.designated_targets, second_enemy))
		return "Clearing a designation left the target designated"
	if(station.designate(ship, "primary"))
		return "The ship could designate itself"

/datum/unit_test/aquila_sensor_console/proc/check_bridge_view()
	var/list/designated = tactical.get_designated_data()
	if(length(designated) != 1 || designated[1]["id"] != "\ref[enemy]" || designated[1]["designation"] != "secondary")
		return "The tactical console did not list the designated target"
	// A designated target the gunner already painted becomes the fire target
	ship.target_painted[enemy] = FALSE
	tactical.lock_designated(enemy)
	if(ship.target_lock != enemy)
		return "Locking a painted designated target did not make it the fire target"
	ship.target_painted -= enemy
	ship.target_lock = null
	if(tactical.lock_designated(second_enemy))
		return "The tactical console locked a target the operator did not designate"
	var/list/dradis_data = display.ui_data()
	var/found = FALSE
	for(var/list/blip as anything in dradis_data["ships"])
		if(blip["id"] == "\ref[enemy]")
			found = blip["designation"] == "secondary"
	if(!found)
		return "DRADIS did not mark the designated target"
	if(ship.get_contact_label(second_enemy, FALSE) != ship.get_contact_label(second_enemy, FALSE) || ship.get_contact_label(enemy, FALSE) == ship.get_contact_label(second_enemy, FALSE))
		return "Contact numbers are not stable per target"

/datum/unit_test/aquila_sensor_console/proc/check_dradis_controls()
	display.sensor_mode = SENSOR_MODE_PASSIVE
	if(!display.ui_act("sensor_mode", list()))
		return "DRADIS handled a sensor action on a ship with a sensor console"
	if(display.sensor_mode != SENSOR_MODE_PASSIVE)
		return "DRADIS switched the sensor mode although the operator runs the sensors"
	station.sensor_range = world.maxx
	var/list/data = display.ui_data()
	// DRADIS mostka jest do latania: zostaje przy podstawowym zasięgu, impuls operatora go nie poszerza
	if(display.sensor_range != display.base_sensor_range || !data["sensor_station"])
		return "DRADIS took the reconnaissance station's pulse range ([display.sensor_range]) instead of its basic range"
	station.sensor_range = station.base_sensor_range

/datum/unit_test/aquila_sensor_console/proc/check_radar_process()
	station.machine_stat = NONE
	station.sensor_mode = SENSOR_MODE_RADAR
	ship.last_radar_pulse = -INFINITY
	station.process()
	station.sensor_mode = SENSOR_MODE_PASSIVE
	if(ship.last_radar_pulse != world.time)
		return "Active radar did not pulse from the console's process"

/// Regression: a destroyed or departed target must not linger in the ship's lists (hard delete)
/datum/unit_test/aquila_sensor_console/proc/check_cleanup()
	station.designate(second_enemy, "secondary")
	qdel(second_enemy)
	if(LAZYACCESS(ship.designated_targets, second_enemy) || LAZYACCESS(ship.sensor_contact_numbers, second_enemy))
		return "A destroyed target stayed in the designation lists"
	SEND_SIGNAL(ship, COMSIG_FTL_STATE_CHANGE)
	if(length(ship.designated_targets))
		return "Designations survived an FTL jump"
