/// AQUILA - passive radar: an active radar pulse is heard further than it sees, but only as a bearing with a rough distance.
/// Replaces the old "a ship that pulsed is fully visible to everyone for 5 s" while sensor signatures are on (sensor_signature.dm).
/// Also fixes the tracking range of a ship that pulses on the exact tick its previous pulse ends ratcheting up (50 -> 100 -> 200...).

/// The AI pulses whenever it hunts, patrols or defends; this keeps it from being permanently in pulse mode
#define AI_RADAR_MIN_INTERVAL (20 SECONDS)
/// How long a heard pulse stays on DRADIS
#define RADAR_EMISSION_TIME (10 SECONDS)
/// A pulse is heard this many times further than the AI pulse reaches
#define RADAR_EMISSION_HEARING_MULT 1.5
/// Repeated pulses narrow the estimate, up to this many steps
#define RADAR_EMISSION_MAX_STEPS 3

/obj/structure/overmap
	/// AQUILA - max_tracking_range outside a radar pulse
	var/base_tracking_range
	/// AQUILA - lazy list, emitter => list(last heard, steps, bearing error -1..1, distance error -1..1, turf at the last pulse)
	var/list/radar_emissions

// Full override (LEGACY_OVERRIDES.md): restores max_tracking_range from a stored base instead of the value at call time
/obj/structure/overmap/send_radar_pulse()
	if(world.time < last_radar_pulse + RADAR_VISIBILITY_PENALTY)
		return FALSE
	if(GLOB.sensor_signature_enabled && ai_controlled && world.time < last_radar_pulse + AI_RADAR_MIN_INTERVAL)
		return FALSE
	// Radar discipline: silent while the target is on a passive sensor, while running, and when a fleet mate just pulsed (ai_sensor_use.dm)
	if(ai_controlled && !try_ai_radar_pulse())
		return FALSE
	relay('nsv13/sound/effects/ship/sensor_pulse_send.ogg')
	relay_to_nearby('nsv13/sound/effects/ship/sensor_pulse_hit.ogg', ignore_self=TRUE, sound_range=255, faction_check=TRUE)
	last_radar_pulse = world.time
	if(isnull(base_tracking_range))
		base_tracking_range = max_tracking_range
	max_tracking_range = base_tracking_range * 2
	addtimer(CALLBACK(src, PROC_REF(end_radar_pulse)), RADAR_VISIBILITY_PENALTY, TIMER_UNIQUE | TIMER_OVERRIDE)
	if(!GLOB.sensor_signature_enabled)
		add_sensor_profile_penalty(max_tracking_range, RADAR_VISIBILITY_PENALTY)
	else if(ai_controlled) // Player pulses go through the DRADIS console, which knows its own range
		broadcast_radar_emission(max_tracking_range * RADAR_EMISSION_HEARING_MULT)
	return TRUE

/obj/structure/overmap/proc/end_radar_pulse()
	if(!isnull(base_tracking_range))
		max_tracking_range = base_tracking_range

// Full override (LEGACY_OVERRIDES.md): no sensor profile penalty, the pulse is broadcast as an emission instead
/obj/machinery/computer/ship/dradis/send_radar_pulse()
	var/obj/structure/overmap/OM = get_overmap()
	if(!OM || !can_radar_pulse())
		return FALSE
	OM.send_radar_pulse()
	addtimer(VARSET_CALLBACK(src, sensor_range, base_sensor_range), RADAR_VISIBILITY_PENALTY)
	sensor_range = world.maxx
	if(!GLOB.sensor_signature_enabled)
		OM.add_sensor_profile_penalty(sensor_range, RADAR_VISIBILITY_PENALTY)
	else
		OM.broadcast_radar_emission(sensor_range)

/// Every hostile ship within range on our z level hears the pulse
/obj/structure/overmap/proc/broadcast_radar_emission(range)
	for(var/obj/structure/overmap/listener as anything in GLOB.overmap_objects)
		if(QDELETED(listener) || listener == src || listener.z != z || listener.faction == faction || istype(listener, /obj/structure/overmap/asteroid))
			continue
		if(overmap_dist(src, listener) > range)
			continue
		listener.hear_radar_emission(src)

/obj/structure/overmap/proc/hear_radar_emission(obj/structure/overmap/emitter)
	var/list/emission = LAZYACCESS(radar_emissions, emitter)
	if(!emission || world.time > emission[1] + RADAR_EMISSION_TIME)
		emission = list(world.time, 1, rand(-100, 100) / 100, rand(-100, 100) / 100, get_turf(emitter))
		LAZYSET(radar_emissions, emitter, emission)
	else
		emission[1] = world.time
		emission[2] = min(emission[2] + 1, RADAR_EMISSION_MAX_STEPS)
		emission[5] = get_turf(emitter)
	// An AI with nothing to chase, or one hunting a contact it lost, goes to have a look;
	// it still needs a real contact to lock on. The fleet gets the bearing too (ai_sensor_use.dm).
	if(ai_controlled && (!last_target || ai_search_target))
		var/turf/lead = get_emission_turf(emitter)
		if(lead)
			patrol_target = lead
			if(ai_search_target)
				ai_search_pulsed = FALSE // A fresh lead is worth one more sweep
			share_ai_emission_lead(lead)

/// Fresh emission data from emitter, or null
/obj/structure/overmap/proc/get_radar_emission(obj/structure/overmap/emitter)
	var/list/emission = LAZYACCESS(radar_emissions, emitter)
	if(!emission)
		return null
	if(world.time > emission[1] + RADAR_EMISSION_TIME || QDELETED(emitter))
		LAZYREMOVE(radar_emissions, emitter)
		return null
	return emission

/// What we know about an emitter: list(bearing, distance, bearing width in degrees, distance spread in tiles), or null
/obj/structure/overmap/proc/get_emission_estimate(obj/structure/overmap/emitter)
	var/list/emission = get_radar_emission(emitter)
	if(!emission)
		return null
	var/turf/heard_at = emission[5]
	var/steps = emission[2]
	var/width = list(18, 10, 5)[steps]
	var/spread_fraction = list(0.4, 0.25, 0.12)[steps]
	var/dist = max(1, overmap_dist(src, heard_at))
	var/bearing = (overmap_angle(src, heard_at) + emission[3] * width / 2 + 360) % 360
	var/estimate = dist * (1 + emission[4] * spread_fraction / 2)
	return list(bearing, estimate, width, estimate * spread_fraction)

/// The turf where we think the emitter is
/obj/structure/overmap/proc/get_emission_turf(obj/structure/overmap/emitter)
	var/list/estimate = get_emission_estimate(emitter)
	if(!estimate)
		return null
	var/target_x = clamp(round(x + sin(estimate[1]) * estimate[2]), 1, world.maxx)
	var/target_y = clamp(round(y + cos(estimate[1]) * estimate[2]), 1, world.maxy)
	return locate(target_x, target_y, z)

#undef AI_RADAR_MIN_INTERVAL
#undef RADAR_EMISSION_HEARING_MULT
#undef RADAR_EMISSION_MAX_STEPS
#undef RADAR_EMISSION_TIME
