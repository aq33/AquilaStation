/// AQUILA - sensor suites for AI ships: instead of one detection range from one signature number,
/// an AI ship looks through several sensors and each of them reads a different part of what the target is doing
/// (sensor_signature.dm computes the parts). The best suite wins and is remembered, so the sandbox recording
/// and the AI's own decisions (ai_sensor_use.dm) can say which sensor holds the contact.
///
/// Players are not touched: their DRADIS keeps the single range from sensor_signature.dm.
/// Design note: raport/sensory_05_sensory_ai.md

/// Admin switch (Debug > Toggle AI sensor suites)
GLOBAL_VAR_INIT(ai_sensor_suites_enabled, TRUE)
/// Admin switch (Debug > Toggle AI sensor cones): sensors with a field of view, as on a real warship.
/// Off: every suite sees all around, the way it did before the cones.
GLOBAL_VAR_INIT(ai_sensor_cones_enabled, TRUE)

/// Optical: sees the hull itself, so only its size counts. Short, but nothing can hide from it.
/// With the cones on this is the wide-angle panoramic camera: all around, but short.
#define SENSOR_OPTICAL "optyczny"
/// Telescope: the same hull image through a narrow, long lens on a gimbal. It has to be pointed:
/// at the target it holds, at where the target should be, or along the ship's course.
#define SENSOR_TELESCOPE "teleskop"
/// Infrared: sees engine burn, hull fire and battle damage. Long against a hot ship, blind against a cold one.
#define SENSOR_INFRARED "termiczny"
/// Lidar: the active radar pulse (radar_emission.dm). Sees everything in range and tells everyone where we are.
#define SENSOR_LIDAR "lidar"
/// Passive listening: hears other ships' pulses as a bearing, never a position (radar_emission.dm)
#define SENSOR_ESM "nasłuch"
/// Not a sensor: the contact is dead reckoning from where we last saw it (ai_sensor_use.dm)
#define SENSOR_MEMORY "pamięć"

/// Optical range against a ship of signature size 1
#define OPTICAL_BASE_RANGE 30
/// Optical never drops below this, so nothing sits invisible on top of us
#define OPTICAL_MIN_RANGE 15
/// Infrared range against a ship at full heat (with the cones: abeam, engine heat 1).
/// Was 70: in recordings hot ships were seen from 80-130 tiles, half the map and further than anything but the radar.
/// A passive sensor reaches less than the active radar (100 during a pulse): about 40 tiles abeam, outside gun range (25),
/// inside missile and tracking range (50).
#define INFRARED_BASE_RANGE 35

/// Wide-angle camera: a fraction of the old all-round optical range (a wide lens resolves less)
#define OPTICAL_WIDE_MULT 0.5
#define OPTICAL_WIDE_MIN_RANGE 10
/// Telescope: further than the old optical range, but only inside a narrow cone.
/// The half angles stay defined: the sandbox recording draws the cones (ai_sandbox.dm).
#define TELESCOPE_RANGE_MULT 1
#define TELESCOPE_HALF_ANGLE 10
/// Infrared: the ship's own drive blinds a wedge behind it while the engines burn (an IRST looking into its own exhaust)
#define INFRARED_BLIND_HALF_ANGLE 15
/// Own engine heat (thrust_heat, 0..1) above which that wedge is blind
#define INFRARED_BLIND_THRUST 0.2
/// Engine heat is directional: seen from behind (into the nozzles) it is brightest, from the bow faintest.
/// Multiplier on the engine part of the heat = ASPECT_MID - ASPECT_SWING * cos(angle between the target's heading
/// and the line from the target to us): in front of it 0.49, abeam 1.37, behind it 2.25. Range goes with the
/// square root of heat, so a ship running only on its engines is seen 0.7x as far from the bow and 1.5x from behind.
#define INFRARED_ASPECT_MID 1.37
#define INFRARED_ASPECT_SWING 0.88

/obj/structure/overmap
	/// AQUILA - lazy list, target => sensor id that currently holds it (SENSOR_OPTICAL and friends)
	var/list/sensor_contact_suites

/// How much of this ship a size-reading sensor sees: hull only, whatever it is doing
/obj/structure/overmap/proc/get_signature_size()
	return get_base_signature()

/// How much heat this ship radiates, 0 (cold and drifting) to about 1.4 (burning wreck at full burn)
/obj/structure/overmap/proc/get_signature_heat()
	var/heat = thrust_heat
	if(inertial_dampeners)
		heat += 0.15
	if(hullburn > 0)
		heat += 0.5
	if(max_integrity)
		heat += 0.5 * clamp(1 - obj_integrity / max_integrity, 0, 1)
	// Guns and drives run hot for a while after firing
	if(world.time < last_weapon_fire + 10 SECONDS)
		heat += 0.3
	return heat

/// Heat target shows toward observer: hull fire, damage and hot guns glow all around, the drive glows backwards
/obj/structure/overmap/proc/get_signature_heat_toward(obj/structure/overmap/observer)
	var/heat = get_signature_heat()
	if(!GLOB.ai_sensor_cones_enabled || !observer || observer == src)
		return heat
	var/to_observer = overmap_angle(src, observer)
	if(isnull(to_observer))
		return heat
	var/engine = clamp(thrust_heat, 0, heat)
	var/off_bow = abs(closer_angle_difference(angle, to_observer))
	return heat - engine + engine * (INFRARED_ASPECT_MID - INFRARED_ASPECT_SWING * cos(off_bow))

/// Where the telescope points: the target we hold, where the target or the hunted contact should be, else our course
/obj/structure/overmap/proc/get_telescope_bearing()
	var/obj/structure/overmap/aim = last_target
	if(!istype(aim) || QDELETED(aim) || aim.z != z)
		aim = ai_search_target
	if(istype(aim) && !QDELETED(aim) && aim.z == z)
		if(get_contact_suite(aim))
			. = overmap_angle(src, aim)
		else
			var/turf/guess = get_ai_contact_guess(aim)
			if(guess)
				. = overmap_angle(src, guess)
	if(isnull(.))
		. = angle

/// Najwyższe ciepło napędu (thrust_heat, 0..1), przy którym termika watchera sięga nas najwyżej na margin * dystans.
/// Podejście dziobem do watchera chowa dysze za kadłubem, więc wolno wtedy grzać więcej.
/obj/structure/overmap/proc/get_ai_engine_heat_budget(obj/structure/overmap/watcher, margin = 0.8)
	if(QDELETED(watcher))
		return 1
	var/heat = get_signature_heat()
	var/other = heat - clamp(thrust_heat, 0, heat) // pożar, uszkodzenia, gorące działa: tego nie wyłączymy
	var/reach = margin * overmap_dist(src, watcher) / INFRARED_BASE_RANGE
	if(!GLOB.ai_sensor_cones_enabled)
		return clamp(reach - other, 0, 1) // bez stożków zasięg termiki rośnie liniowo z ciepłem
	var/mult = INFRARED_ASPECT_MID
	var/to_watcher = overmap_angle(src, watcher)
	if(!isnull(to_watcher))
		mult = INFRARED_ASPECT_MID - INFRARED_ASPECT_SWING * cos(abs(closer_angle_difference(angle, to_watcher)))
	return clamp((reach * reach - other) / mult, 0, 1)

/// TRUE while our own drive blinds the infrared wedge behind us
/obj/structure/overmap/proc/is_infrared_rear_blind()
	return GLOB.ai_sensor_cones_enabled && thrust_heat >= INFRARED_BLIND_THRUST

/// How far the telescope would see target if target were inside its cone
/obj/structure/overmap/proc/get_telescope_reach(obj/structure/overmap/target)
	return OPTICAL_BASE_RANGE * TELESCOPE_RANGE_MULT * target.get_signature_size()

/// TRUE when our own drive blinds the infrared toward target
/obj/structure/overmap/proc/is_infrared_blinded_toward(obj/structure/overmap/target)
	if(!is_infrared_rear_blind())
		return FALSE
	var/bearing = overmap_angle(src, target)
	if(isnull(bearing))
		return FALSE
	return abs(closer_angle_difference(angle + 180, bearing)) <= INFRARED_BLIND_HALF_ANGLE

/// How far the infrared would see target if our own drive did not blind it.
/// Radiant intensity falls off with the square of distance, so detection range goes with its square root
/obj/structure/overmap/proc/get_infrared_reach(obj/structure/overmap/target)
	return INFRARED_BASE_RANGE * sqrt(max(target.get_signature_heat_toward(src), 0))

/// How far the wide-angle camera sees a hull of signature size, all around
/obj/structure/overmap/proc/get_optical_reach(size = 1)
	return max(OPTICAL_BASE_RANGE * OPTICAL_WIDE_MULT * size, OPTICAL_WIDE_MIN_RANGE)

/// TRUE when target sits inside the telescope's cone
/obj/structure/overmap/proc/is_in_telescope_cone(obj/structure/overmap/target)
	var/bearing = overmap_angle(src, target)
	if(isnull(bearing))
		return TRUE // right on top of us
	return abs(closer_angle_difference(get_telescope_bearing(), bearing)) <= TELESCOPE_HALF_ANGLE

/// Range at which suite would detect target from here, 0 if that suite cannot see it at all
/obj/structure/overmap/proc/get_suite_range(suite, obj/structure/overmap/target)
	switch(suite)
		if(SENSOR_OPTICAL)
			if(GLOB.ai_sensor_cones_enabled)
				return get_optical_reach(target.get_signature_size())
			return max(OPTICAL_BASE_RANGE * target.get_signature_size(), OPTICAL_MIN_RANGE)
		if(SENSOR_TELESCOPE)
			if(!GLOB.ai_sensor_cones_enabled || !is_in_telescope_cone(target))
				return 0
			return get_telescope_reach(target)
		if(SENSOR_INFRARED)
			if(!GLOB.ai_sensor_cones_enabled)
				return INFRARED_BASE_RANGE * target.get_signature_heat()
			if(is_infrared_blinded_toward(target))
				return 0
			return get_infrared_reach(target)
		if(SENSOR_LIDAR)
			// Only while our own pulse is up; radar_emission.dm doubles max_tracking_range for its duration
			if(world.time >= last_radar_pulse + RADAR_VISIBILITY_PENALTY)
				return 0
			return max_tracking_range
	return 0

/// Every suite an AI ship of this kind carries. Fighters make do with eyes and a heat seeker, no room for a telescope.
/obj/structure/overmap/proc/get_sensor_suites()
	if(mass <= MASS_TINY)
		return list(SENSOR_OPTICAL, SENSOR_INFRARED)
	return list(SENSOR_OPTICAL, SENSOR_TELESCOPE, SENSOR_INFRARED, SENSOR_LIDAR)

/// The suite that sees target furthest, as list(suite, range); never null
/obj/structure/overmap/proc/get_best_suite(obj/structure/overmap/target)
	var/best_suite = SENSOR_OPTICAL
	var/best_range = 0
	for(var/suite in get_sensor_suites())
		var/range = get_suite_range(suite, target)
		if(range > best_range)
			best_range = range
			best_suite = suite
	return list(best_suite, best_range)

/// Which sensor holds target right now, or null if we do not see it
/obj/structure/overmap/proc/get_contact_suite(obj/structure/overmap/target)
	return LAZYACCESS(sensor_contact_suites, target)

/// Detection through the suites: AI ships, and player ships with a sensor console (player_sensors.dm).
/// Other player ships keep the single range from sensor_signature.dm.
/obj/structure/overmap/get_detection_range(obj/structure/overmap/observer)
	if(!GLOB.ai_sensor_suites_enabled || !observer?.uses_sensor_suites())
		return ..()
	// DRADIS mostka (sensor_view_basic): tylko kamera i podczerwień dookoła; nie nadpisuje tego, czym operator trzyma kontakt
	if(observer.sensor_view_basic)
		return observer.get_best_suite(src)[2]
	// A player's pulse from the reconnaissance station: 100 tiles all around, or further inside a narrow beam (player_sensors.dm)
	if(!observer.ai_controlled)
		var/lidar = observer.get_player_lidar_range(src)
		if(lidar && overmap_dist(src, observer) <= lidar)
			LAZYSET(observer.sensor_contact_suites, src, SENSOR_LIDAR)
			return lidar
	var/list/best = observer.get_best_suite(src)
	var/range = best[2]
	if(overmap_dist(src, observer) <= range)
		LAZYSET(observer.sensor_contact_suites, src, best[1])
	else
		LAZYREMOVE(observer.sensor_contact_suites, src)
	return range

/// Drops deleted ships from the contact list. Called from prune_sensor_memory() in ai_sensor_use.dm,
/// which holds the single override of that proc.
/obj/structure/overmap/proc/prune_ai_suite_contacts()
	for(var/datum/target as anything in sensor_contact_suites?.Copy())
		if(QDELETED(target))
			LAZYREMOVE(sensor_contact_suites, target)

/world/AVerbsDebug()
	. = ..()
	. += /client/proc/toggle_ai_sensor_suites
	. += /client/proc/toggle_ai_sensor_cones

/client/proc/toggle_ai_sensor_cones()
	set category = "Debug"
	set name = "Toggle AI sensor cones"
	set desc = "Włącza lub wyłącza pola widzenia sensorów AI (teleskop, martwe pole za rufą, kąt patrzenia na dysze)."
	if(!check_rights(R_DEBUG))
		return
	GLOB.ai_sensor_cones_enabled = !GLOB.ai_sensor_cones_enabled
	var/state = GLOB.ai_sensor_cones_enabled ? "włączył" : "wyłączył"
	message_admins("[key_name_admin(usr)] [state] pola widzenia sensorów AI.")
	log_admin("[key_name(usr)] toggled AI sensor cones to [GLOB.ai_sensor_cones_enabled].")

/client/proc/toggle_ai_sensor_suites()
	set category = "Debug"
	set name = "Toggle AI sensor suites"
	set desc = "Włącza lub wyłącza zestawy sensorów okrętów AI (optyczny, termiczny, lidar)."
	if(!check_rights(R_DEBUG))
		return
	GLOB.ai_sensor_suites_enabled = !GLOB.ai_sensor_suites_enabled
	var/state = GLOB.ai_sensor_suites_enabled ? "włączył" : "wyłączył"
	message_admins("[key_name_admin(usr)] [state] zestawy sensorów AI.")
	log_admin("[key_name(usr)] toggled AI sensor suites to [GLOB.ai_sensor_suites_enabled].")

#undef OPTICAL_BASE_RANGE
#undef OPTICAL_MIN_RANGE
#undef INFRARED_BASE_RANGE
#undef OPTICAL_WIDE_MULT
#undef OPTICAL_WIDE_MIN_RANGE
#undef TELESCOPE_RANGE_MULT
#undef INFRARED_BLIND_THRUST
#undef INFRARED_ASPECT_MID
#undef INFRARED_ASPECT_SWING
