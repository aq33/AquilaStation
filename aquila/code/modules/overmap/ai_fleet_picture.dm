/// AQUILA - what a fleet of AI ships actually knows, as opposed to what the game knows.
///
/// Upstream a fleet shares targets as bare references (`shared_targets`, `ai-skynet.dm`): one ship spots you and
/// every other ship flies to your real coordinates for as long as the spotter keeps reporting, whether or not it
/// can see anything itself. With sensor suites (ai_sensor_suites.dm) that made the whole system pointless - going
/// dark only hid you from the one ship that had you.
///
/// Here a report carries a position, a course and a timestamp instead. Ships that cannot see the target steer at
/// that picture, the picture ages, and when it goes stale the target drops out of the fleet's reports by itself.
/// On top of that the fleet runs one radar at a time, puts two heard bearings together, and can wait in the cold.

/// Admin and sandbox switches, one per behaviour, so each can be shown on its own
GLOBAL_VAR_INIT(ai_fleet_picture_enabled, TRUE)
GLOBAL_VAR_INIT(ai_picket_enabled, TRUE)
GLOBAL_VAR_INIT(ai_triangulation_enabled, TRUE)
GLOBAL_VAR_INIT(ai_ambush_enabled, TRUE)

/// How long the fleet keeps believing a report nobody has refreshed
#define AI_FLEET_CONTACT_TIME (30 SECONDS)
/// How often the picture is cleaned up (per fleet, not per ship)
#define AI_PICTURE_PRUNE_GAP (2 SECONDS)
/// How long one ship stays the fleet's radar picket
#define AI_PICKET_TIME (60 SECONDS)
/// Two bearings closer than this to parallel give a useless intersection
#define AI_TRIANGULATION_MIN_ANGLE 12
/// A fleet lying in wait wakes up when a hostile is this much inside its own detection range
#define AI_AMBUSH_TRIGGER 0.9

/datum/fleet
	/// AQUILA - target => list(x, y, velocity x, velocity y, world.time, reporter): the fleet's picture of a contact
	var/list/ai_contact_picture
	/// AQUILA - the one ship allowed to run its radar for the fleet
	var/obj/structure/overmap/ai_picket
	/// AQUILA - world.time when the picket job passes to someone else
	var/ai_picket_until = 0
	/// AQUILA - world.time of the next picture cleanup
	var/ai_picture_pruned = 0
	/// AQUILA - the fleet is lying in wait: cold engines, no radar, until something walks into sensor range
	var/ai_lying_in_wait = FALSE

// ---------------------------------------------------------------- the fleet picture

/// A ship that can see target tells the fleet where it is and where it is going
/datum/fleet/proc/report_ai_contact(obj/structure/overmap/target, obj/structure/overmap/reporter)
	if(!GLOB.ai_fleet_picture_enabled || QDELETED(target) || QDELETED(reporter))
		return
	LAZYSET(ai_contact_picture, target, list(target.x, target.y, target.velocity?.a || 0, target.velocity?.e || 0, world.time, reporter))

/// The fleet's picture of target, or null when nobody has seen it recently enough
/datum/fleet/proc/get_ai_contact(obj/structure/overmap/target)
	if(!GLOB.ai_fleet_picture_enabled)
		return null
	var/list/picture = LAZYACCESS(ai_contact_picture, target)
	if(!picture)
		return null
	if(QDELETED(target) || world.time > picture[5] + AI_FLEET_CONTACT_TIME)
		return null
	return picture

/// Zapomina okręt, który znika z gry: jako cel meldunków, jako zgłaszającego i jako szpicę.
/// Woła to Destroy() (overmap.dm), bo flota w nieaktywnym systemie sama nie sprząta (prune_ai_picture z slowprocess).
/datum/fleet/proc/forget_ai_contact(obj/structure/overmap/ship)
	LAZYREMOVE(ai_contact_picture, ship)
	for(var/obj/structure/overmap/target as anything in ai_contact_picture?.Copy())
		var/list/picture = ai_contact_picture[target]
		if(picture?[6] == ship)
			picture[6] = null
	if(ai_picket == ship)
		ai_picket = null

/// Throws out reports nobody refreshed, and with them the shared target, so every ship drops it the usual way
/datum/fleet/proc/prune_ai_picture()
	if(!GLOB.ai_fleet_picture_enabled || world.time < ai_picture_pruned)
		return
	ai_picture_pruned = world.time + AI_PICTURE_PRUNE_GAP
	for(var/obj/structure/overmap/target as anything in ai_contact_picture?.Copy())
		if(get_ai_contact(target))
			continue
		LAZYREMOVE(ai_contact_picture, target)
		// Nobody has seen it for a while: the fleet stops passing it around
		if(shared_targets?[target])
			shared_targets -= target
	if(QDELETED(ai_picket))
		ai_picket = null

// ---------------------------------------------------------------- one radar at a time

/// Whether ship is the fleet's radar picket right now, picking a new one when the job is free
/datum/fleet/proc/is_ai_picket(obj/structure/overmap/ship)
	if(!GLOB.ai_picket_enabled)
		return TRUE // Without the picket role everyone shares the plain fleet-wide pulse gap
	if(!QDELETED(ai_picket) && world.time < ai_picket_until)
		return ai_picket == ship
	// The job is open: whoever asks first and is a sensible choice takes it
	// Myśliwce nie mają radaru (ai_sensor_suites.dm), więc szpicą nie zostają
	if(QDELETED(ship) || CHECK_BITFIELD(ship.ai_flags, AI_FLAG_SUPPLY) || ship.ai_fleeing || ship.mass <= MASS_TINY)
		return FALSE
	ai_picket = ship
	ai_picket_until = world.time + AI_PICKET_TIME
	return TRUE

// ---------------------------------------------------------------- two bearings on one emitter

/// Where the fleet thinks emitter is, from the bearings of everyone who heard it; null without two usable bearings
/datum/fleet/proc/triangulate_ai_emission(obj/structure/overmap/emitter)
	if(!GLOB.ai_triangulation_enabled || QDELETED(emitter))
		return null
	var/list/listeners = list()
	for(var/obj/structure/overmap/mate as anything in all_ships)
		if(QDELETED(mate) || mate.z != emitter.z || !mate.get_radar_emission(emitter))
			continue
		var/list/estimate = mate.get_emission_estimate(emitter)
		if(estimate)
			listeners += list(list(mate, estimate[1]))
		if(length(listeners) >= 2)
			break
	if(length(listeners) < 2)
		return null
	var/obj/structure/overmap/a = listeners[1][1]
	var/obj/structure/overmap/b = listeners[2][1]
	var/angle_a = listeners[1][2]
	var/angle_b = listeners[2][2]
	var/spread = abs(closer_angle_difference(angle_a, angle_b))
	if(spread < AI_TRIANGULATION_MIN_ANGLE)
		return null // Both heard it from the same side, the lines barely cross
	// Bearings as lines from each listener; sin/cos match the bearing convention of overmap_angle()
	var/ax = sin(angle_a), ay = cos(angle_a)
	var/bx = sin(angle_b), by = cos(angle_b)
	var/denominator = ax * by - ay * bx
	if(!denominator)
		return null
	var/dx = b.x - a.x, dy = b.y - a.y
	var/along = (dx * by - dy * bx) / denominator
	if(along <= 0)
		return null // The crossing is behind one of the listeners
	return locate(clamp(round(a.x + ax * along), 1, world.maxx), clamp(round(a.y + ay * along), 1, world.maxy), a.z)

// ---------------------------------------------------------------- lying in wait

/// A defence fleet with nothing to chase sits cold instead of patrolling into the open
/datum/fleet/proc/update_ai_ambush()
	if(fleet_trait != FLEET_TRAIT_DEFENSE || !GLOB.ai_ambush_enabled || !GLOB.ai_sensor_tactics_enabled)
		ai_lying_in_wait = FALSE
		return
	if(length(shared_targets))
		ai_lying_in_wait = FALSE
		return
	ai_lying_in_wait = TRUE

/// This ship is holding still in the ambush: cold, quiet, and not moving
/obj/structure/overmap/proc/is_ai_lying_in_wait()
	if(!uses_ai_sensor_tactics() || !fleet?.ai_lying_in_wait || last_target || ai_search_target)
		return FALSE
	// Something close enough to see wakes the whole thing up
	for(var/obj/structure/overmap/other as anything in current_system?.system_contents)
		if(!is_ai_hostile(other) || other.z != z)
			continue
		// other.get_detection_range(src) is how far WE see THEM, not the other way round
		if(overmap_dist(src, other) <= other.get_detection_range(src) * AI_AMBUSH_TRIGGER)
			fleet.ai_lying_in_wait = FALSE
			return FALSE
	return TRUE

#undef AI_FLEET_CONTACT_TIME
#undef AI_PICTURE_PRUNE_GAP
#undef AI_PICKET_TIME
#undef AI_TRIANGULATION_MIN_ANGLE
#undef AI_AMBUSH_TRIGGER
