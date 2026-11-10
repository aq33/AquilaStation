/// AQUILA - sensor suites for AI ships: instead of one detection range from one signature number,
/// an AI ship looks through several sensors and each of them reads a different part of what the target is doing
/// (sensor_signature.dm computes the parts). The best suite wins and is remembered, so the sandbox recording
/// and the AI's own decisions (ai_sensor_use.dm) can say which sensor holds the contact.
///
/// Players are not touched: their DRADIS keeps the single range from sensor_signature.dm.
/// Design note: raport/sensory_05_sensory_ai.md

/// Admin switch (Debug > Toggle AI sensor suites)
GLOBAL_VAR_INIT(ai_sensor_suites_enabled, TRUE)

/// Optical: sees the hull itself, so only its size counts. Short, but nothing can hide from it.
#define SENSOR_OPTICAL "optyczny"
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
/// Infrared range against a ship at full heat
#define INFRARED_BASE_RANGE 70

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

/// Range at which suite would detect target from here, 0 if that suite cannot see it at all
/obj/structure/overmap/proc/get_suite_range(suite, obj/structure/overmap/target)
	switch(suite)
		if(SENSOR_OPTICAL)
			return max(OPTICAL_BASE_RANGE * target.get_signature_size(), OPTICAL_MIN_RANGE)
		if(SENSOR_INFRARED)
			return INFRARED_BASE_RANGE * target.get_signature_heat()
		if(SENSOR_LIDAR)
			// Only while our own pulse is up; radar_emission.dm doubles max_tracking_range for its duration
			if(world.time >= last_radar_pulse + RADAR_VISIBILITY_PENALTY)
				return 0
			return max_tracking_range
	return 0

/// Every suite an AI ship of this kind carries. Fighters make do with eyes and a heat seeker.
/obj/structure/overmap/proc/get_sensor_suites()
	if(mass <= MASS_TINY)
		return list(SENSOR_OPTICAL, SENSOR_INFRARED)
	return list(SENSOR_OPTICAL, SENSOR_INFRARED, SENSOR_LIDAR)

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

/// AI detection goes through the suites; players keep the single range from sensor_signature.dm
/obj/structure/overmap/get_detection_range(obj/structure/overmap/observer)
	if(!GLOB.ai_sensor_suites_enabled || !observer?.ai_controlled)
		return ..()
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
