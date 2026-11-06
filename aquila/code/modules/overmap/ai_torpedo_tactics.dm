/// AQUILA - torpedo tactics for AI ships (part of the AI morale toggle, ai_morale.dm):
/// fleets fire torpedo salvos together so point defence is swamped, and AI ships turn away from incoming torpedoes.
/// Neither needs the sensor signature system.

#define AI_TEMPERAMENT_CAUTIOUS "ostrożny"
#define AI_TEMPERAMENT_RECKLESS "brawurowy"

/// The salvo opens once every launcher of the fleet on that target has reloaded, or after this long
#define AI_SALVO_MAX_WAIT (6 SECONDS)
/// Ships fire freely for this long (with a 2 s AI torpedo delay, one or two torpedoes each)
#define AI_SALVO_WINDOW (3 SECONDS)
/// Torpedoes are held between salvos; after a failed salvo roll the ships fire on their own for this long
#define AI_SALVO_INTERVAL (12 SECONDS)
#define AI_SALVO_OPEN_UNTIL 1
#define AI_SALVO_NEXT 2
#define AI_SALVO_WAITING_SINCE 3

/// Incoming torpedoes closer than this are dodged
#define AI_DODGE_RANGE 14
/// How far to the side the ship heads while dodging
#define AI_DODGE_DISTANCE 10
/// The ship keeps its dodge side this long, so it doesn't weave left and right
#define AI_DODGE_TIME (3 SECONDS)

/// Switched off only by the AI sandbox, to compare battles with and without these tactics (AI morale switches them off too)
GLOBAL_VAR_INIT(ai_torpedo_tactics_enabled, TRUE)

/datum/fleet
	/// AQUILA - lazy list, target => list(salvo open until, next salvo, waiting since)
	var/list/ai_salvos
	/// AQUILA - chance that the fleet coordinates its next torpedo salvo; otherwise every ship fires on its own until the next roll
	var/ai_salvo_chance = 50

/obj/structure/overmap
	/// AQUILA - 1 or -1: which side of the torpedo's path we are dodging to
	var/ai_dodge_side = 0
	/// AQUILA - world.time until which ai_dodge_side holds
	var/ai_dodge_until = 0

/obj/structure/overmap/proc/get_ai_torpedo_launchers()
	. = list()
	for(var/datum/overmap_ship_weapon/weapon as anything in overmap_weapon_datums)
		if(weapon.used_nonphysical_ammo == OSW_AMMO_TORPEDO && (weapon.weapon_control_flags & OSW_CONTROL_AI))
			. += weapon

/// Fleet ships that take part in a salvo on target: torpedo ships of the fleet on that target, in range, not running away.
/// Reckless commanders fire whenever they like and do not wait for anyone.
/datum/fleet/proc/get_ai_salvo_ships(obj/structure/overmap/target)
	. = list()
	for(var/obj/structure/overmap/ship as anything in all_ships)
		if(QDELETED(ship) || !ship.ai_controlled || ship.last_target != target || ship.ai_fleeing || ship.ai_temperament == AI_TEMPERAMENT_RECKLESS)
			continue
		if(ship.z != target.z || !ship.has_ai_torpedoes() || overmap_dist(ship, target) > ship.max_weapon_range)
			continue
		. += ship

/// Whether ship may fire a torpedo at target now. One salvo state per fleet and target.
/datum/fleet/proc/ai_salvo_allows(obj/structure/overmap/ship, obj/structure/overmap/target)
	var/list/salvo = LAZYACCESS(ai_salvos, target)
	if(!salvo)
		salvo = list(0, 0, 0)
		LAZYSET(ai_salvos, target, salvo)
	if(world.time < salvo[AI_SALVO_OPEN_UNTIL])
		return TRUE
	if(world.time < salvo[AI_SALVO_NEXT])
		return FALSE
	var/list/ships = get_ai_salvo_ships(target)
	if(length(ships) < 2 || !(ship in ships))
		return TRUE // Nobody to fire with
	if(!salvo[AI_SALVO_WAITING_SINCE])
		if(!prob(ai_salvo_chance))
			salvo[AI_SALVO_OPEN_UNTIL] = world.time + AI_SALVO_INTERVAL // No coordination this time
			salvo[AI_SALVO_NEXT] = salvo[AI_SALVO_OPEN_UNTIL]
			return TRUE
		salvo[AI_SALVO_WAITING_SINCE] = world.time
	var/all_loaded = TRUE
	for(var/obj/structure/overmap/other as anything in ships)
		var/loaded = FALSE
		for(var/datum/overmap_ship_weapon/launcher as anything in other.get_ai_torpedo_launchers())
			if(launcher.next_firetime <= world.time && launcher.get_ammo())
				loaded = TRUE
				break
		if(!loaded)
			all_loaded = FALSE
			break
	if(!all_loaded && world.time < salvo[AI_SALVO_WAITING_SINCE] + AI_SALVO_MAX_WAIT)
		return FALSE
	salvo[AI_SALVO_OPEN_UNTIL] = world.time + AI_SALVO_WINDOW
	salvo[AI_SALVO_NEXT] = salvo[AI_SALVO_OPEN_UNTIL] + AI_SALVO_INTERVAL
	salvo[AI_SALVO_WAITING_SINCE] = 0
	note_ai_fleet_event("salwa torped na [target]: [length(ships)] okrętów")
	return TRUE

/datum/overmap_ship_weapon/can_fire(atom/target, list/inplace_report)
	. = ..()
	if(!. || used_nonphysical_ammo != OSW_AMMO_TORPEDO || !GLOB.ai_morale_enabled || !GLOB.ai_torpedo_tactics_enabled || !isovermap(target))
		return
	var/obj/structure/overmap/ship = linked_overmap
	if(!ship?.ai_controlled || !ship.fleet || ship.ai_temperament == AI_TEMPERAMENT_RECKLESS)
		return
	return ship.fleet.ai_salvo_allows(ship, target)

/// An agile AI ship turns across the path of the closest torpedo homing on it; reckless ones don't bother
/obj/structure/overmap/proc/can_ai_dodge()
	return GLOB.ai_morale_enabled && GLOB.ai_torpedo_tactics_enabled && ai_controlled && mass < MASS_LARGE && speed_limit > 0 && ai_temperament != AI_TEMPERAMENT_RECKLESS

/// Where to fly to get out of the way of the closest incoming torpedo, or null
/obj/structure/overmap/proc/get_ai_dodge_point()
	if(!length(torpedoes_to_target) || !can_ai_dodge())
		return null
	var/range = AI_DODGE_RANGE * (ai_temperament == AI_TEMPERAMENT_CAUTIOUS ? 1.5 : 1)
	var/obj/item/projectile/guided_munition/closest
	var/closest_dist = range
	for(var/obj/item/projectile/guided_munition/munition in torpedoes_to_target)
		if(QDELETED(munition) || munition.homing_target != src || munition.z != z)
			continue
		var/dist = overmap_dist(src, munition)
		if(dist <= closest_dist)
			closest = munition
			closest_dist = dist
	if(!closest)
		return null
	// Keep to the side of its path we are already on, so we move away from the path instead of across it
	if(!ai_dodge_side || world.time > ai_dodge_until)
		ai_dodge_side = closer_angle_difference(closest.Angle, overmap_angle(closest, src)) >= 0 ? 1 : -1
	ai_dodge_until = world.time + AI_DODGE_TIME
	var/heading = closest.Angle + 90 * ai_dodge_side
	return locate(clamp(round(x + sin(heading) * AI_DODGE_DISTANCE), 1, world.maxx), clamp(round(y + cos(heading) * AI_DODGE_DISTANCE), 1, world.maxy), z)

/obj/structure/overmap/move_toward(atom/target, ram_target = FALSE, ignore_all_collisions = FALSE)
	if(ram_target)
		return ..()
	var/turf/dodge = get_ai_dodge_point()
	if(!dodge)
		return ..()
	return ..(dodge, FALSE, TRUE) // Full burn, no collision avoidance: the torpedo is the collision

#undef AI_TEMPERAMENT_CAUTIOUS
#undef AI_TEMPERAMENT_RECKLESS
#undef AI_SALVO_MAX_WAIT
#undef AI_SALVO_WINDOW
#undef AI_SALVO_INTERVAL
#undef AI_SALVO_OPEN_UNTIL
#undef AI_SALVO_NEXT
#undef AI_SALVO_WAITING_SINCE
#undef AI_DODGE_RANGE
#undef AI_DODGE_DISTANCE
#undef AI_DODGE_TIME
