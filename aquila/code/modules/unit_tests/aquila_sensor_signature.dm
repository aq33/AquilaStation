/// AQUILA - ship signatures (aquila/code/modules/overmap/sensor_signature.dm): a quiet ship is detected later,
/// thrust and weapons fire give you away, a radar pulse is heard as an emission, and the paint / EMP exceptions still reveal you
/datum/unit_test/aquila_sensor_signature
	var/obj/structure/overmap/small_craft/observer
	var/obj/structure/overmap/small_craft/target

/datum/unit_test/aquila_sensor_signature/Run()
	var/was_enabled = GLOB.sensor_signature_enabled
	GLOB.sensor_signature_enabled = TRUE
	observer = allocate(/obj/structure/overmap/small_craft/combat/light)
	target = allocate(/obj/structure/overmap/small_craft/combat/light)
	target.faction = "syndicate"
	var/fail = check_signature() || check_detection() || check_offsets() || check_pulse_range()
	observer.ai_controlled = FALSE
	GLOB.sensor_signature_enabled = was_enabled
	if(fail)
		return Fail(fail)

/// Puts target dist tiles east of observer, on the test z level
/datum/unit_test/aquila_sensor_signature/proc/place(dist)
	var/z = run_loc_floor_bottom_left.z
	observer.forceMove(locate(10, 10, z))
	target.forceMove(locate(10 + round(dist), 10, z))

/datum/unit_test/aquila_sensor_signature/proc/make_quiet()
	target.thrust_heat = 0
	target.last_thrust_forward = 0
	target.last_thrust_right = 0
	target.brakes = FALSE
	target.inertial_dampeners = FALSE
	target.last_weapon_fire = -INFINITY
	target.last_radar_pulse = -INFINITY
	target.sensor_profile = 0
	target.target_painted = list()
	target.update_sensor_signature()

/datum/unit_test/aquila_sensor_signature/proc/check_signature()
	make_quiet()
	var/quiet = target.sensor_signature
	target.last_thrust_forward = target.forward_maxthrust || 1
	for(var/i in 1 to 20)
		target.update_sensor_signature()
	var/burning = target.sensor_signature
	if(burning <= quiet)
		return "Thrusting did not raise the signature ([quiet] -> [burning])"
	target.last_weapon_fire = world.time
	target.update_sensor_signature()
	if(target.sensor_signature <= burning)
		return "Firing did not raise the signature ([burning] -> [target.sensor_signature])"

/datum/unit_test/aquila_sensor_signature/proc/check_detection()
	for(var/ai in list(FALSE, TRUE))
		observer.ai_controlled = ai
		var/who = ai ? "AI" : "player"
		make_quiet()
		var/range = target.get_detection_range(observer)
		// Gracz widzi tuż za zasięgiem słaby, nienamierzalny sygnał (do 1,6 zasięgu); AI nic
		place(round(range * 1.3))
		var/faint = target.is_sensor_visible(observer)
		if(ai ? faint != SENSOR_VISIBILITY_GHOST : faint != SENSOR_VISIBILITY_FAINT)
			return "A quiet ship [round(range * 1.3)] tiles away had visibility [faint] for a [who] observer with a detection range of [range]"
		place(round(range * 1.6) + 3)
		if(target.is_sensor_visible(observer) != SENSOR_VISIBILITY_GHOST)
			return "A quiet ship [round(range * 1.6) + 3] tiles away was visible to a [who] observer with a detection range of [range]"
		place(max(1, range - 3))
		if(target.is_sensor_visible(observer) == SENSOR_VISIBILITY_GHOST)
			return "A quiet ship inside the detection range ([range]) was hidden from a [who] observer"

		// A pulse no longer reveals the emitter outright: the listener only hears an emission
		place(round(range * 1.6) + 3)
		target.last_radar_pulse = world.time
		if(target.is_sensor_visible(observer) != SENSOR_VISIBILITY_GHOST)
			return "A ship that pulsed its radar was fully revealed to a [who] observer outside its detection range"
		target.last_radar_pulse = -INFINITY
		LAZYREMOVE(observer.radar_emissions, target)
		target.broadcast_radar_emission(round(range * 1.6) + 13)
		var/list/estimate = observer.get_emission_estimate(target)
		if(!estimate)
			return "A [who] observer in range did not hear a radar pulse"
		if(abs(estimate[2] - (round(range * 1.6) + 3)) > estimate[4] + 1)
			return "The emission distance estimate ([estimate[2]] ± [estimate[4]]) missed the real distance ([round(range * 1.6) + 3])"
		LAZYREMOVE(observer.radar_emissions, target)

		// Regression: the exceptions must still reveal a ship far outside its passive range
		target.target_painted[observer] = FALSE
		if(target.is_sensor_visible(observer) != SENSOR_VISIBILITY_FULL)
			return "A ship painting the [who] observer was not fully visible to it"
		target.target_painted = list()
		target.sensor_profile = round(range * 1.6) + 8
		if(target.is_sensor_visible(observer) == SENSOR_VISIBILITY_GHOST)
			return "A ship with a sensor profile penalty (EMP) was hidden from a [who] observer"
		target.sensor_profile = 0
		GLOB.sensor_signature_enabled = FALSE
		var/disabled_visibility = target.is_sensor_visible(observer)
		GLOB.sensor_signature_enabled = TRUE
		if(disabled_visibility == SENSOR_VISIBILITY_GHOST)
			return "With the system switched off a ship was still hidden by its signature"

/datum/unit_test/aquila_sensor_signature/proc/check_offsets()
	var/radius = 4
	var/list/first = observer.get_sensor_offset(target, radius).Copy()
	var/list/second = observer.get_sensor_offset(target, radius)
	if(first[1] != second[1] || first[2] != second[2])
		return "The contact position error was re-rolled between two reads in the same step"
	for(var/i in 1 to 50)
		var/list/offset = observer.sensor_offsets[target]
		offset[3] = world.time - 1 MINUTES // Force a random walk step
		offset = observer.get_sensor_offset(target, radius)
		if(sqrt(offset[1] ** 2 + offset[2] ** 2) > radius + 1)
			return "The contact position error left its radius ([offset[1]], [offset[2]] for radius [radius])"


/// Regression: upstream send_radar_pulse() restored max_tracking_range to its value at call time,
/// so a pulse landing on the tick the previous one ended doubled the range for good (50 -> 100 -> 200)
/datum/unit_test/aquila_sensor_signature/proc/check_pulse_range()
	observer.ai_controlled = FALSE
	observer.base_tracking_range = null
	observer.max_tracking_range = 50
	observer.last_radar_pulse = -INFINITY
	observer.send_radar_pulse()
	if(observer.max_tracking_range != 100)
		return "A radar pulse did not double the tracking range (got [observer.max_tracking_range])"
	observer.last_radar_pulse -= 5 SECONDS // The cooldown ends before the restore timer fires
	observer.send_radar_pulse()
	if(observer.max_tracking_range != 100)
		return "A second pulse before the restore ratcheted the tracking range to [observer.max_tracking_range]"
	observer.end_radar_pulse()
	if(observer.max_tracking_range != 50)
		return "Ending the pulse did not restore the base tracking range (got [observer.max_tracking_range])"
