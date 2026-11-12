/// AQUILA - torpedo salvos for AI fleets (part of the AI morale toggle, ai_morale.dm):
/// torpedo ships on the same target fire together so point defence is swamped.

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
#define AI_SALVO_SHIPS 4
#define AI_SALVO_SHIPS_UNTIL 5
/// How long the list of ships taking part in a salvo is reused
#define AI_SALVO_SHIPS_CACHE (1 SECONDS)
/// Inside AI gun range (overmap_scale.dm) the AI picks guns first, so the salvo is only planned beyond it
#define AI_SALVO_GUN_RANGE 25

/datum/fleet
	/// AQUILA - lazy list, target => list(salvo open until, next salvo, waiting since)
	var/list/ai_salvos
	/// AQUILA - chance that the fleet coordinates its next torpedo salvo, otherwise every ship fires on its own until the next roll; null uses GLOB.ai_salvo_chance (ai_tuning.dm)
	var/ai_salvo_chance

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

/// A ship of this fleet is deleted: drop it from the cached ship lists of every salvo, or a salvo on a target nobody fires at any more keeps it (hard delete)
/datum/fleet/proc/forget_ai_salvo_ship(obj/structure/overmap/ship)
	for(var/salvo_target in ai_salvos)
		var/list/salvo = ai_salvos[salvo_target]
		var/list/ships = salvo[AI_SALVO_SHIPS]
		ships?.Remove(ship)

/// Whether ship may fire a torpedo at target now. One salvo state per fleet and target.
/datum/fleet/proc/ai_salvo_allows(obj/structure/overmap/ship, obj/structure/overmap/target)
	var/list/salvo = LAZYACCESS(ai_salvos, target)
	if(!salvo)
		salvo = list(0, 0, 0, null, 0)
		LAZYSET(ai_salvos, target, salvo)
	if(world.time < salvo[AI_SALVO_OPEN_UNTIL])
		return TRUE
	if(world.time < salvo[AI_SALVO_NEXT])
		return FALSE
	var/list/ships = salvo[AI_SALVO_SHIPS]
	if(!ships || world.time >= salvo[AI_SALVO_SHIPS_UNTIL])
		ships = get_ai_salvo_ships(target)
		salvo[AI_SALVO_SHIPS] = ships
		salvo[AI_SALVO_SHIPS_UNTIL] = world.time + AI_SALVO_SHIPS_CACHE
	if(length(ships) < 2 || !(ship in ships))
		return TRUE // Nobody to fire with
	if(!salvo[AI_SALVO_WAITING_SINCE])
		var/chance = ai_salvo_chance
		if(isnull(chance))
			chance = GLOB.ai_salvo_chance
		if(!prob(chance))
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
	if(!. || used_nonphysical_ammo != OSW_AMMO_TORPEDO || !GLOB.ai_morale_enabled || !isovermap(target))
		return
	var/obj/structure/overmap/ship = linked_overmap
	if(!ship?.ai_controlled || !ship.fleet || ship.ai_temperament == AI_TEMPERAMENT_RECKLESS)
		return
	// Strzał na namiar zwiadowcy albo tor radaru sam jest koordynacją (ai_scouting.dm)
	if(ship.ai_datalink_firing)
		return
	// can_fire() also runs while ai_fire() is only choosing a weapon; in gun range a gun usually wins and no torpedo goes out,
	// so the salvo roll and its timers are only spent where torpedoes are what the ship actually fires
	if(GLOB.overmap_scale_enabled && overmap_dist(ship, target) <= AI_SALVO_GUN_RANGE)
		return
	return ship.fleet.ai_salvo_allows(ship, target)

#undef AI_TEMPERAMENT_RECKLESS
#undef AI_SALVO_MAX_WAIT
#undef AI_SALVO_WINDOW
#undef AI_SALVO_INTERVAL
#undef AI_SALVO_OPEN_UNTIL
#undef AI_SALVO_NEXT
#undef AI_SALVO_WAITING_SINCE
#undef AI_SALVO_SHIPS
#undef AI_SALVO_SHIPS_UNTIL
#undef AI_SALVO_SHIPS_CACHE
#undef AI_SALVO_GUN_RANGE
