/// AQUILA - AI sensor suites (aquila/code/modules/overmap/ai_sensor_suites.dm) and what the AI does with them
/// (aquila/code/modules/overmap/ai_sensor_use.dm): a cold ship hides from infrared but not from the optical sensor,
/// a lost contact is chased to where it should be, and radar discipline keeps a fleet from lighting itself up.
/datum/unit_test/aquila_ai_sensors
	var/obj/structure/overmap/small_craft/observer
	var/obj/structure/overmap/small_craft/target

/datum/unit_test/aquila_ai_sensors/Run()
	var/was_signature = GLOB.sensor_signature_enabled
	var/was_suites = GLOB.ai_sensor_suites_enabled
	var/was_tactics = GLOB.ai_sensor_tactics_enabled
	GLOB.sensor_signature_enabled = TRUE
	GLOB.ai_sensor_suites_enabled = TRUE
	GLOB.ai_sensor_tactics_enabled = TRUE
	observer = allocate(/obj/structure/overmap/small_craft/combat/light)
	target = allocate(/obj/structure/overmap/small_craft/combat/light)
	target.faction = "syndicate"
	observer.ai_controlled = TRUE
	var/fail = check_suites() || check_contact_suite() || check_search() || check_radar_discipline() || check_disabled()
	observer.ai_controlled = FALSE
	GLOB.sensor_signature_enabled = was_signature
	GLOB.ai_sensor_suites_enabled = was_suites
	GLOB.ai_sensor_tactics_enabled = was_tactics
	if(fail)
		return Fail(fail)

/// Puts target dist tiles east of observer, on the test z level
/datum/unit_test/aquila_ai_sensors/proc/place(dist)
	var/z = run_loc_floor_bottom_left.z
	observer.forceMove(locate(10, 10, z))
	target.forceMove(locate(10 + round(dist), 10, z))

/datum/unit_test/aquila_ai_sensors/proc/make_cold()
	target.thrust_heat = 0
	target.last_thrust_forward = 0
	target.last_thrust_right = 0
	target.brakes = FALSE
	target.inertial_dampeners = FALSE
	target.last_weapon_fire = -INFINITY
	target.hullburn = 0
	target.obj_integrity = target.max_integrity
	target.sensor_profile = 0
	target.target_painted = list()
	target.update_sensor_signature()

/// A cold ship is invisible to infrared and still visible to the optical sensor; a burning one is seen much further
/datum/unit_test/aquila_ai_sensors/proc/check_suites()
	make_cold()
	var/cold_ir = observer.get_suite_range(SENSOR_INFRARED, target)
	var/cold_optical = observer.get_suite_range(SENSOR_OPTICAL, target)
	if(cold_optical <= 0)
		return "The optical sensor saw nothing at all (range [cold_optical])"
	if(cold_ir >= cold_optical)
		return "A cold ship was not hidden from infrared (IR [cold_ir], optical [cold_optical])"
	target.last_thrust_forward = target.forward_maxthrust || 1
	for(var/i in 1 to 20)
		target.update_sensor_signature()
	var/hot_ir = observer.get_suite_range(SENSOR_INFRARED, target)
	if(hot_ir <= cold_ir)
		return "Burning the engines did not make the ship hotter ([cold_ir] -> [hot_ir])"
	if(hot_ir <= cold_optical)
		return "Infrared on a burning ship did not beat the optical sensor (IR [hot_ir], optical [cold_optical])"
	// The lidar is silent until the ship actually pulses
	observer.last_radar_pulse = -INFINITY
	if(observer.get_suite_range(SENSOR_LIDAR, target))
		return "The lidar had a range without a radar pulse"
	observer.last_radar_pulse = world.time
	if(observer.get_suite_range(SENSOR_LIDAR, target) <= 0)
		return "The lidar saw nothing during a pulse"
	observer.last_radar_pulse = -INFINITY

/// The contact remembers which sensor is holding it, and a cold ship drops off infrared at a distance optical cannot reach
/datum/unit_test/aquila_ai_sensors/proc/check_contact_suite()
	target.last_thrust_forward = target.forward_maxthrust || 1
	for(var/i in 1 to 20)
		target.update_sensor_signature()
	place(observer.get_suite_range(SENSOR_OPTICAL, target) + 5)
	if(target.is_sensor_visible(observer) <= SENSOR_VISIBILITY_GHOST)
		return "A burning ship just outside optical range was invisible"
	if(observer.get_contact_suite(target) != SENSOR_INFRARED)
		return "A burning ship outside optical range was not held by infrared (got [observer.get_contact_suite(target) || "nothing"])"
	// Engines off at the same distance: infrared loses it and nothing else reaches that far
	make_cold()
	if(target.is_sensor_visible(observer) > SENSOR_VISIBILITY_GHOST)
		return "A ship that cut its engines stayed visible at [overmap_dist(observer, target)] tiles"
	if(observer.get_contact_suite(target))
		return "A lost contact kept its sensor ([observer.get_contact_suite(target)])"
	place(5)
	if(target.is_sensor_visible(observer) <= SENSOR_VISIBILITY_GHOST || observer.get_contact_suite(target) != SENSOR_OPTICAL)
		return "A cold ship next to us was not picked up by the optical sensor"

/// Losing a contact starts a search at the point the target was heading for, not at the point it was last seen
/datum/unit_test/aquila_ai_sensors/proc/check_search()
	place(5)
	observer.ai_last_contact = null
	observer.stop_ai_search()
	target.velocity.a = 2
	target.velocity.e = 0
	observer.remember_ai_contact(target)
	var/list/seen = LAZYACCESS(observer.ai_last_contact, target)
	if(!seen || seen[1] != target.x)
		return "The contact was not remembered"
	// Pretend the sighting is 10 seconds old: the guess should be ahead of the target's last position
	seen[5] = world.time - 10 SECONDS
	var/turf/guess = observer.get_ai_contact_guess(target)
	if(!guess)
		return "No guess at all for a remembered contact"
	if(guess.x <= target.x)
		return "The search point did not lead the target ([guess.x] vs [target.x])"
	if(!observer.start_ai_search(target))
		return "The search did not start"
	if(observer.ai_search_target != target || observer.patrol_target != guess)
		return "The search did not aim at the guessed point"
	if(observer.get_ai_tactic() != "szukanie")
		return "A searching ship did not report it (got [observer.get_ai_tactic()])"
	// A contact we can see again ends the search
	observer.last_target = target
	place(5)
	target.last_thrust_forward = target.forward_maxthrust || 1
	for(var/i in 1 to 20)
		target.update_sensor_signature()
	target.is_sensor_visible(observer)
	observer.update_ai_sensor_use()
	if(observer.ai_search_target)
		return "The search went on after the contact came back"
	observer.last_target = null
	observer.stop_ai_search()

/// Radar discipline: no pulse while a passive sensor holds the target, and none while running away
/datum/unit_test/aquila_ai_sensors/proc/check_radar_discipline()
	place(5)
	observer.ai_fleeing = FALSE
	observer.ai_running_silent = FALSE
	observer.last_target = null
	observer.fleet = null
	if(!observer.try_ai_radar_pulse())
		return "A ship with nothing to go on refused to pulse"
	observer.last_target = target
	target.is_sensor_visible(observer)
	if(!observer.get_contact_suite(target))
		return "The target next to us was not on any sensor, cannot test discipline"
	if(observer.try_ai_radar_pulse())
		return "A ship pulsed although a passive sensor was holding the target"
	observer.last_target = null
	observer.ai_fleeing = TRUE
	if(observer.try_ai_radar_pulse())
		return "A fleeing ship lit up its radar"
	observer.ai_fleeing = FALSE

/// With the switch off nothing of this applies and detection goes back to the single signature range
/datum/unit_test/aquila_ai_sensors/proc/check_disabled()
	GLOB.ai_sensor_suites_enabled = FALSE
	make_cold()
	place(5)
	if(target.is_sensor_visible(observer) <= SENSOR_VISIBILITY_GHOST)
		return "With the suites off a close ship stopped being visible"
	observer.ai_fleeing = TRUE
	if(!observer.try_ai_radar_pulse())
		return "Radar discipline still applied with the suites switched off"
	observer.ai_fleeing = FALSE
	GLOB.ai_sensor_suites_enabled = TRUE
