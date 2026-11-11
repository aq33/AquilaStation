/// AQUILA - ship signature: how far away a ship can be detected depends on what it is doing (thrust, weapons fire, damage).
/// Every visibility check (AI target selection and chase, lock-on and lock tracking, DRADIS blips, weapon autonomy)
/// goes through is_sensor_visible(), so a single override covers them all.
/// The state lives on the ship, not on a console, so it survives the planned split of DRADIS into separate stations.
/// Design: raport/sensory_01_analiza.md, raport/sensory_02_plan_mvp.md

/// Admin switch for the whole system (Debug > Toggle sensor signatures)
GLOBAL_VAR_INIT(sensor_signature_enabled, TRUE)

/// Per slowprocess (0.7 s) decay of the thrust heat average
#define SIGNATURE_THRUST_DECAY 0.85
/// Signature added by a ship that has been thrusting continuously
#define SIGNATURE_THRUST_MAX 0.5
/// Inertial dampeners keep firing thrusters, so they are not free
#define SIGNATURE_DAMPENERS 0.1
/// Signature added for a while after firing any weapon
#define SIGNATURE_WEAPON_FIRE 0.4
#define SIGNATURE_WEAPON_FIRE_TIME (10 SECONDS)
/// Signature added by a ship with no hull integrity left (scales linearly)
#define SIGNATURE_DAMAGE_MAX 0.3
/// Signature added while the hull is burning
#define SIGNATURE_HULLBURN 0.1
/// Player passive detection range = DRADIS sensor_range * this * target signature
#define SENSOR_PLAYER_RANGE_MULT 1.5
/// Passive detection never drops below this, so nothing can sit invisible right next to you
#define SENSOR_MIN_DETECTION 15
/// Passive detection cap; only an active radar pulse sees further
#define SENSOR_MAX_DETECTION 100

/obj/structure/overmap
	/// AQUILA - detection range multiplier, recalculated every slowprocess
	var/sensor_signature = 1
	/// AQUILA - decaying average of thruster use, 0 to 1
	var/thrust_heat = 0
	/// AQUILA - world.time of the last weapon fired
	var/last_weapon_fire = -SIGNATURE_WEAPON_FIRE_TIME
	/// AQUILA - lazy list, target => list(dx, dy, last step time): persistent position error of uncertain contacts
	var/list/sensor_offsets
	/// AQUILA - lazy list, shooter => list(x, y, world.time): undetected ships that recently hit us
	var/list/hit_ghosts
	/// AQUILA - anti-spam for the "fire from an undetected source" warning
	var/next_hit_ghost_warning = 0

/// Signature of a ship of this mass doing nothing at all
/obj/structure/overmap/proc/get_base_signature()
	if(mass <= MASS_TINY)
		return 0.4
	if(mass <= MASS_SMALL)
		return 0.5
	if(mass <= MASS_MEDIUM)
		return 0.6
	if(mass <= MASS_MEDIUM_LARGE)
		return 0.7
	if(mass <= MASS_LARGE)
		return 0.8
	if(mass < MASS_IMMOBILE)
		return 1
	return 1.3

/obj/structure/overmap/proc/update_sensor_signature()
	// last_thrust_* are set by the physics tick, braking included; there is no throttle, so we average how often the engines ran
	var/thrusting = (last_thrust_forward || last_thrust_right) ? 1 : 0
	thrust_heat = thrust_heat * SIGNATURE_THRUST_DECAY + thrusting * (1 - SIGNATURE_THRUST_DECAY)
	var/signature = get_base_signature() + thrust_heat * SIGNATURE_THRUST_MAX
	if(inertial_dampeners)
		signature += SIGNATURE_DAMPENERS
	if(world.time < last_weapon_fire + SIGNATURE_WEAPON_FIRE_TIME)
		signature += SIGNATURE_WEAPON_FIRE
	if(max_integrity)
		signature += SIGNATURE_DAMAGE_MAX * clamp(1 - obj_integrity / max_integrity, 0, 1)
	if(hullburn > 0)
		signature += SIGNATURE_HULLBURN
	sensor_signature = signature
	prune_sensor_memory()

/// Drops deleted ships from the contact memory lists
/obj/structure/overmap/proc/prune_sensor_memory()
	for(var/datum/target as anything in sensor_offsets?.Copy())
		if(QDELETED(target))
			LAZYREMOVE(sensor_offsets, target)
	for(var/datum/shooter as anything in hit_ghosts?.Copy())
		if(QDELETED(shooter))
			LAZYREMOVE(hit_ghosts, shooter)
	for(var/datum/emitter as anything in radar_emissions?.Copy())
		if(QDELETED(emitter))
			LAZYREMOVE(radar_emissions, emitter)

/obj/structure/overmap/slowprocess()
	// Before ..(), which runs ai_process() and should see the fresh value
	update_sensor_signature()
	. = ..()
	// After ai_process(), so the sensor tactics see this tick's contacts (ai_sensor_use.dm)
	update_ai_sensor_use()

/// How far away observer can passively detect this ship
/obj/structure/overmap/proc/get_detection_range(obj/structure/overmap/observer)
	var/base_range
	if(observer.ai_controlled)
		base_range = observer.max_tracking_range // Doubled by the AI's own radar pulse
	else
		// The operator's console runs the sensors; a DRADIS only copies its range while its window is open (sensor_console.dm)
		var/obj/machinery/computer/ship/dradis/display = observer.sensor_console || observer.dradis
		base_range = (display ? display.sensor_range : SENSOR_RANGE_DEFAULT) * SENSOR_PLAYER_RANGE_MULT
	var/range = max(base_range * sensor_signature, SENSOR_MIN_DETECTION)
	// A player's active pulse sees the whole map; the AI pulses all the time, so its pulse stays capped
	if(!observer.ai_controlled && observer.last_radar_pulse + RADAR_VISIBILITY_PENALTY > world.time)
		return range
	return min(range, SENSOR_MAX_DETECTION)

/obj/structure/overmap/is_sensor_visible(obj/structure/overmap/observer)
	. = ..()
	if(!GLOB.sensor_signature_enabled || . <= SENSOR_VISIBILITY_GHOST || !istype(observer) || observer == src)
		return
	// Allies broadcast IFF; a ship painting the observer is loud no matter what.
	// A radar pulse no longer reveals the emitter outright: listeners get a bearing-only emission contact instead (radar_emission.dm)
	if(observer.faction == faction || (observer in target_painted))
		return
	var/dist = overmap_dist(src, observer)
	if(dist <= sensor_profile) // EMP and other profile penalties
		return
	if(dist > get_detection_range(observer))
		return SENSOR_VISIBILITY_GHOST

/datum/overmap_ship_weapon/fire_proc_chain(atom/target, mob/living/firer, ai_aim = FALSE, list/inplace_report)
	. = ..()
	if(. && linked_overmap)
		linked_overmap.last_weapon_fire = world.time

/world/AVerbsDebug()
	. = ..()
	. += /client/proc/toggle_sensor_signatures

/client/proc/toggle_sensor_signatures()
	set category = "Debug"
	set name = "Toggle sensor signatures"
	set desc = "Włącza lub wyłącza sygnatury okrętów i niepewne kontakty DRADIS."
	if(!check_rights(R_DEBUG))
		return
	GLOB.sensor_signature_enabled = !GLOB.sensor_signature_enabled
	var/state = GLOB.sensor_signature_enabled ? "włączył" : "wyłączył"
	message_admins("[key_name_admin(usr)] [state] sygnatury okrętów (sensory).")
	log_admin("[key_name(usr)] toggled sensor signatures to [GLOB.sensor_signature_enabled].")

#undef SIGNATURE_THRUST_DECAY
#undef SIGNATURE_THRUST_MAX
#undef SIGNATURE_DAMPENERS
#undef SIGNATURE_WEAPON_FIRE
#undef SIGNATURE_WEAPON_FIRE_TIME
#undef SIGNATURE_DAMAGE_MAX
#undef SIGNATURE_HULLBURN
#undef SENSOR_PLAYER_RANGE_MULT
