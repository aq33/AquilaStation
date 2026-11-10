/// AQUILA - AI ships actually using their sensors (ai_sensor_suites.dm), instead of flying with perfect knowledge:
/// A: a lost contact is chased to where the target would be, not forgotten on the spot;
/// B: radar discipline - nobody pulses while the target is on a passive sensor, and a fleet pulses through one ship at a time;
/// C: a fleeing ship cuts its engines once it is outside the enemy's reach, so its heat drops and it really disappears;
/// D: a heard radar pulse (radar_emission.dm) is a lead for a searching ship and for its fleet, not only for an idle one;
/// E: a ship that is not detected yet closes in cold - no dampeners, no pulses - until it is in weapon range.
///
/// Everything here is AI-only and switched by one global, so a round can be compared with and without it.

/// Admin switch (Debug > Toggle AI sensor tactics)
GLOBAL_VAR_INIT(ai_sensor_tactics_enabled, TRUE)

/// How long a ship hunts a contact it lost before giving up
#define AI_SEARCH_TIME (45 SECONDS)
/// Distance at which the search point counts as reached
#define AI_SEARCH_ARRIVE 8
/// How far ahead of the last sighting we are willing to guess
#define AI_SEARCH_MAX_LEAD 60
/// How wide a sweep is after the search point turns up nothing
#define AI_SEARCH_SWEEP 25
/// Only one ship of a fleet pulses inside this window
#define AI_FLEET_PULSE_GAP (12 SECONDS)
/// A cautious commander leaves pulsing to someone else for this much longer
#define AI_CAUTIOUS_PULSE_GAP (24 SECONDS)
/// Coasting below this speed is just sitting still, so the engines stay on
#define AI_SILENT_MIN_SPEED 0.6

#define AI_TEMPERAMENT_CAUTIOUS "ostrożny"
#define AI_TEMPERAMENT_RECKLESS "brawurowy"

/obj/structure/overmap
	/// AQUILA - lazy list, target => list(x, y, velocity x, velocity y, world.time): where a contact was when we last saw it
	var/list/ai_last_contact
	/// AQUILA - the contact we are currently hunting without seeing it
	var/obj/structure/overmap/ai_search_target
	/// AQUILA - last_target as of the previous tick, so we notice the moment a chase ends
	var/obj/structure/overmap/ai_prev_target
	/// AQUILA - world.time when we give up the search
	var/ai_search_until = 0
	/// AQUILA - the search point has already been swept with a radar pulse
	var/ai_search_pulsed = FALSE
	/// AQUILA - engines off, coasting away from a threat that cannot see us
	var/ai_running_silent = FALSE
	/// AQUILA - what the ship is doing, for the sandbox recording (ai_sandbox.dm)
	var/ai_tactic = "patrol"

/datum/fleet
	/// AQUILA - world.time of the last radar pulse by any ship of this fleet
	var/last_ai_pulse = 0

/// Are the sensor tactics running on this ship at all
/obj/structure/overmap/proc/uses_ai_sensor_tactics()
	return GLOB.ai_sensor_tactics_enabled && GLOB.ai_sensor_suites_enabled && ai_controlled && !QDELETED(src)

// ---------------------------------------------------------------- A: last known position

/// Remembers where a contact was and where it was heading
/obj/structure/overmap/proc/remember_ai_contact(obj/structure/overmap/target)
	if(QDELETED(target))
		return
	LAZYSET(ai_last_contact, target, list(target.x, target.y, target.velocity?.a || 0, target.velocity?.e || 0, world.time))
	// The fleet gets the same picture, so mates that cannot see it steer at this instead of the real position
	fleet?.report_ai_contact(target, src)

/// Where target probably is now, guessing from its last course; null when we have nothing to go on
/obj/structure/overmap/proc/get_ai_contact_guess(obj/structure/overmap/target)
	var/list/seen = LAZYACCESS(ai_last_contact, target)
	if(!seen)
		seen = fleet?.get_ai_contact(target) // What a fleet mate reported, if we never saw it ourselves
	if(!seen)
		return null
	var/elapsed = (world.time - seen[5]) / (1 SECONDS)
	var/lead_x = clamp(seen[3] * elapsed, -AI_SEARCH_MAX_LEAD, AI_SEARCH_MAX_LEAD)
	var/lead_y = clamp(seen[4] * elapsed, -AI_SEARCH_MAX_LEAD, AI_SEARCH_MAX_LEAD)
	return locate(clamp(round(seen[1] + lead_x), 1, world.maxx), clamp(round(seen[2] + lead_y), 1, world.maxy), z)

/// Starts hunting a contact we just lost
/obj/structure/overmap/proc/start_ai_search(obj/structure/overmap/target)
	var/turf/guess = ai_far_enough_point(get_ai_contact_guess(target))
	if(!guess)
		return FALSE
	ai_search_target = target
	ai_search_until = world.time + AI_SEARCH_TIME
	ai_search_pulsed = FALSE
	patrol_target = guess
	return TRUE

/obj/structure/overmap/proc/stop_ai_search()
	if(ai_search_target && patrol_target && overmap_dist(src, patrol_target) > AI_SEARCH_ARRIVE)
		patrol_target = null
	ai_search_target = null
	ai_search_until = 0
	ai_search_pulsed = FALSE

/// Keeps the hunt going: sweep the area, pulse once, give up when the time runs out
/obj/structure/overmap/proc/continue_ai_search()
	if(QDELETED(ai_search_target) || world.time > ai_search_until || last_target)
		stop_ai_search()
		return
	if(patrol_target && overmap_dist(src, patrol_target) > AI_SEARCH_ARRIVE)
		return
	// At the spot and nothing here. One pulse, then widen the sweep around the guess.
	if(!ai_search_pulsed)
		ai_search_pulsed = TRUE
		send_radar_pulse()
	var/turf/centre = get_ai_contact_guess(ai_search_target) || get_turf(src)
	var/turf/sweep = locate(clamp(centre.x + rand(-AI_SEARCH_SWEEP, AI_SEARCH_SWEEP), 1, world.maxx),
		clamp(centre.y + rand(-AI_SEARCH_SWEEP, AI_SEARCH_SWEEP), 1, world.maxy), z)
	patrol_target = ai_far_enough_point(sweep)

// ---------------------------------------------------------------- B: radar discipline

/// Whether this AI ship may light up its radar now, and claims the fleet's pulse slot when it may.
/// Called once per pulse, from the override in radar_emission.dm, right before the pulse goes out.
/obj/structure/overmap/proc/try_ai_radar_pulse()
	if(!uses_ai_sensor_tactics())
		return TRUE
	// Running away or sneaking up: a pulse would tell everyone exactly where we are
	if(ai_fleeing || ai_running_silent)
		return FALSE
	// The target is already on a passive sensor, so there is nothing to gain
	if(last_target && get_contact_suite(last_target))
		return FALSE
	if(is_ai_lying_in_wait())
		return FALSE
	if(fleet)
		// One radar runs for the whole fleet, and it is the picket's (ai_fleet_picture.dm)
		if(!fleet.is_ai_picket(src))
			return FALSE
		var/gap = ai_temperament == AI_TEMPERAMENT_CAUTIOUS ? AI_CAUTIOUS_PULSE_GAP : AI_FLEET_PULSE_GAP
		if(world.time < fleet.last_ai_pulse + gap)
			return FALSE
		fleet.last_ai_pulse = world.time
	return TRUE

// ---------------------------------------------------------------- D: sharing a heard bearing

/// Passes a bearing we heard to fleet mates that have nothing better to do, spread out so they do not stack up
/obj/structure/overmap/proc/share_ai_emission_lead(turf/lead)
	if(!uses_ai_sensor_tactics() || !lead || !fleet)
		return
	for(var/obj/structure/overmap/mate as anything in fleet.all_ships)
		if(QDELETED(mate) || mate == src || !mate.ai_controlled || mate.z != lead.z)
			continue
		if(mate.last_target || mate.ai_fleeing || mate.patrol_target)
			continue
		mate.patrol_target = locate(clamp(lead.x + rand(-AI_SEARCH_SWEEP, AI_SEARCH_SWEEP), 1, world.maxx),
			clamp(lead.y + rand(-AI_SEARCH_SWEEP, AI_SEARCH_SWEEP), 1, world.maxy), lead.z)

// ---------------------------------------------------------------- C and E: running cold

/// The threat we are hiding from: what we are running from, or the nearest hostile
/obj/structure/overmap/proc/get_ai_hiding_from()
	return last_target && !QDELETED(last_target) ? last_target : get_ai_nearest_threat()

/// Can that ship see us at all right now
/obj/structure/overmap/proc/is_detected_by(obj/structure/overmap/watcher)
	if(QDELETED(watcher) || watcher.z != z)
		return FALSE
	return overmap_dist(src, watcher) <= get_detection_range(watcher)

/// Engines off and coasting: called from move_toward (overmap_scale.dm) to skip the burn.
/// Only for a ship running away (C). A ship sneaking up (E) steers as usual and burns within its heat budget
/// (ai_sneak_burn_allowed), otherwise a slow ship coasting with its engines off never arrived at all.
/obj/structure/overmap/proc/ai_coasting_silent(atom/target)
	if(!ai_running_silent || !ai_fleeing || QDELETED(src))
		return FALSE
	// Never coast into the ship we are running from
	if(istype(target, /obj/structure/overmap) && overmap_dist(src, target) < max_weapon_range)
		return FALSE
	return TRUE

/// Skradanie (E): wolno odpalić silnik, póki nasze ciepło nie zbliża termiki wroga na odległość, z której nas zobaczy
/obj/structure/overmap/proc/ai_sneak_burn_allowed()
	if(ai_fleeing)
		return FALSE
	var/obj/structure/overmap/threat = get_ai_hiding_from()
	if(QDELETED(threat))
		return TRUE
	return thrust_heat < get_ai_engine_heat_budget(threat)

/// Decides whether to keep the engines off this tick
/obj/structure/overmap/proc/update_ai_silent_running()
	var/obj/structure/overmap/threat = get_ai_hiding_from()
	var/was_silent = ai_running_silent
	ai_running_silent = FALSE
	if(QDELETED(threat))
		if(was_silent)
			enable_dampeners()
		return
	// C: we are running and they have lost us - coast, let the heat drop, do not burn a trail
	if(ai_fleeing && !is_detected_by(threat) && (velocity?.ln() || 0) >= AI_SILENT_MIN_SPEED)
		ai_running_silent = TRUE
	// E: we see them, they do not see us, we are still too far to shoot - close in cold
	else if(!ai_fleeing && last_target == threat && get_contact_suite(threat) \
		&& !is_detected_by(threat) && overmap_dist(src, threat) > max_weapon_range)
		ai_running_silent = TRUE
	if(ai_running_silent)
		disable_dampeners() // Dampener burns are heat too
	else if(was_silent)
		enable_dampeners()

/// Where to actually fly when the goal points at a ship we cannot see: our own guess or the fleet's,
/// never its real position. Returns null when we do see it, so movement runs as usual.
/obj/structure/overmap/proc/get_ai_blind_point(atom/goal)
	if(!uses_ai_sensor_tactics() || !istype(goal, /obj/structure/overmap))
		return null
	var/obj/structure/overmap/other = goal
	if(other.faction == faction || get_contact_suite(other))
		return null
	// Punkt bliżej niż martwa strefa silników znaczyłby, że okręt tam dryfuje bez ciągu (ai_formation.dm)
	return ai_far_enough_point(get_ai_contact_guess(other))

// ---------------------------------------------------------------- bookkeeping

/// One label for what the ship is doing, written into the sandbox recording
/obj/structure/overmap/proc/get_ai_tactic()
	if(ai_fleeing)
		return ai_running_silent ? "ucieczka cicho" : "odwrót"
	if(ai_running_silent)
		return "ciche podejście"
	if(ai_search_target)
		return ai_search_pulsed ? "przeczesywanie" : "szukanie"
	if(ai_waiting_for_support)
		return "czeka na flotę"
	if(last_target)
		if(overmap_dist(src, last_target) <= max_weapon_range)
			return "walka"
		if(get_contact_suite(last_target))
			return "pościg"
		return LAZYACCESS(ai_last_contact, last_target) ? "pościg w ciemno" : "pościg z meldunku"
	if(is_ai_lying_in_wait())
		return "zasadzka"
	return patrol_target ? "sprawdza namiar" : "patrol"

/// Run once per slowprocess from sensor_signature.dm, after ai_process() has refreshed the contacts
/obj/structure/overmap/proc/update_ai_sensor_use()
	if(!uses_ai_sensor_tactics())
		// The label is still worth keeping up to date with the tactics off, so a recording made
		// without them (ai_sandbox.dm) can be read side by side with one made with them
		if(ai_controlled)
			ai_tactic = get_ai_tactic()
		return
	if(last_target && !QDELETED(last_target))
		// A contact we can actually see is worth remembering for later
		if(get_contact_suite(last_target))
			remember_ai_contact(last_target)
			if(ai_search_target)
				stop_ai_search()
	else
		// The chase just ended and the target did not blow up: go and look where it should be
		if(!ai_search_target && ai_prev_target && !QDELETED(ai_prev_target))
			start_ai_search(ai_prev_target)
		if(ai_search_target)
			continue_ai_search()
	ai_prev_target = last_target
	update_ai_silent_running()
	update_ai_formation()
	fleet?.prune_ai_picture()
	fleet?.update_ai_ambush()
	ai_tactic = get_ai_tactic()

/obj/structure/overmap/prune_sensor_memory()
	. = ..()
	prune_ai_suite_contacts()
	for(var/datum/target as anything in ai_last_contact?.Copy())
		if(QDELETED(target))
			LAZYREMOVE(ai_last_contact, target)
	if(QDELETED(ai_search_target))
		ai_search_target = null
	if(QDELETED(ai_prev_target))
		ai_prev_target = null

/world/AVerbsDebug()
	. = ..()
	. += /client/proc/toggle_ai_sensor_tactics

/client/proc/toggle_ai_sensor_tactics()
	set category = "Debug"
	set name = "Toggle AI sensor tactics"
	set desc = "Włącza lub wyłącza korzystanie z sensorów przez AI (szukanie, cisza radiowa, ciche podejście)."
	if(!check_rights(R_DEBUG))
		return
	GLOB.ai_sensor_tactics_enabled = !GLOB.ai_sensor_tactics_enabled
	var/state = GLOB.ai_sensor_tactics_enabled ? "włączył" : "wyłączył"
	message_admins("[key_name_admin(usr)] [state] taktyki sensorowe AI.")
	log_admin("[key_name(usr)] toggled AI sensor tactics to [GLOB.ai_sensor_tactics_enabled].")

#undef AI_SEARCH_TIME
#undef AI_SEARCH_ARRIVE
#undef AI_SEARCH_MAX_LEAD
#undef AI_SEARCH_SWEEP
#undef AI_FLEET_PULSE_GAP
#undef AI_CAUTIOUS_PULSE_GAP
#undef AI_SILENT_MIN_SPEED
#undef AI_TEMPERAMENT_CAUTIOUS
#undef AI_TEMPERAMENT_RECKLESS
