// AQUILA - Wrogie drony bojowe pojawiają się w przestrzeni wokół kadłuba i ostrzeliwują okręt (port z Baystation12 code/modules/events/mob_spawning/rogue_drones.dm)
// Bay spawns one malfunctioning drone per tick at the space edge and throws it at the ship (1-3 drones, 6-12 with heavy
// drones for a major event), and deletes the drones when the event ends. We have no malf drone mob, so the drones are
// ranged hivebots that fly in space (spacewalk), spawned just outside the hull. When a drone has no one to shoot at it
// fires at a window or wall of the ship nearby, so the swarm keeps pecking at the hull. 2-4 drones, the swarm 6-9.
// This is not the antag event /datum/round_event_control/aquila_rogue_drone (one Syndicate drone from a dispenser).

/datum/round_event_control/aquila_hex_rogue_drone_swarm
	name = "Rój zbuntowanych dronów"
	typepath = /datum/round_event/aquila_hex_rogue_drone_swarm
	weight = 10
	min_players = 5
	max_occurrences = 2
	earliest_start = 20 MINUTES

/datum/round_event/aquila_hex_rogue_drone_swarm
	fakeable = FALSE
	startWhen = 1
	announceWhen = 3
	/// A big attack swarm instead of a patrol
	var/swarm = FALSE
	/// Drones still to come
	var/remaining_to_spawn = 0
	/// Drones this event spawned
	var/list/drones = list()
	/// Station areas the hull is searched from
	var/list/ship_areas

/datum/round_event/aquila_hex_rogue_drone_swarm/setup()
	swarm = prob(25)
	remaining_to_spawn = swarm ? rand(6, 9) : rand(2, 4)
	endWhen = rand(300, 450) // 10-15 minutes

/datum/round_event/aquila_hex_rogue_drone_swarm/announce(fake)
	if(swarm)
		priority_announce("Ostrzeżenie priorytetowe: w pobliżu okrętu [station_name()] wykryto rój niezidentyfikowanych dronów bojowych.", "Sensory okrętu")
	else
		priority_announce("Uwaga: w pobliżu okrętu [station_name()] wykryto niezidentyfikowane drony patrolowe.", "Sensory okrętu")

/datum/round_event/aquila_hex_rogue_drone_swarm/tick()
	if(remaining_to_spawn > 0 && !(activeFor % 3))
		var/turf/spot = find_hull_space()
		if(spot)
			var/mob/living/basic/hivebot/range/aquila_hex_rogue_drone/drone = spawn_drone(spot)
			if(length(drones) == 1)
				announce_to_ghosts(drone)
		remaining_to_spawn--
	if(!(activeFor % 5))
		for(var/mob/living/basic/hivebot/range/aquila_hex_rogue_drone/drone as anything in drones.Copy())
			shoot_hull(drone)

/datum/round_event/aquila_hex_rogue_drone_swarm/end()
	var/left = 0
	for(var/mob/living/drone as anything in drones.Copy())
		if(!QDELETED(drone))
			left++
			qdel(drone)
	drones.Cut()
	log_game("Rogue Drone Swarm: the swarm left, [left] drone(s) removed.")
	priority_announce("Sensory wskazują, że niezidentyfikowane drony opuściły bezpośrednie otoczenie okrętu [station_name()].", "Sensory okrętu")

/datum/round_event/aquila_hex_rogue_drone_swarm/kill()
	drones.Cut()
	return ..()

/datum/round_event/aquila_hex_rogue_drone_swarm/proc/spawn_drone(turf/spot)
	var/mob/living/basic/hivebot/range/aquila_hex_rogue_drone/drone = new(spot)
	drones += drone
	RegisterSignal(drone, COMSIG_PARENT_QDELETING, PROC_REF(drone_deleted))
	return drone

/datum/round_event/aquila_hex_rogue_drone_swarm/proc/drone_deleted(datum/source)
	SIGNAL_HANDLER
	drones -= source

/**
 * A space turf a few tiles outside the ship's hull: from a random floor of a ship area it walks in a random direction
 * until it leaves the ship, then goes 3 more tiles into space. Carp spawn points of the ship's z-levels are the fallback.
 */
/datum/round_event/aquila_hex_rogue_drone_swarm/proc/find_hull_space()
	if(isnull(ship_areas))
		ship_areas = list()
		for(var/area/A as anything in GLOB.sortedAreas)
			if(A.type in GLOB.the_station_areas)
				ship_areas += A
	for(var/attempt in 1 to 10)
		if(!length(ship_areas))
			break
		var/area/A = pick(ship_areas)
		var/list/floors = list()
		for(var/turf/open/floor/F in A)
			floors += F
			if(length(floors) >= 50)
				break
		if(!length(floors))
			continue
		var/turf/T = pick(floors)
		var/dir = pick(GLOB.cardinals)
		var/space_steps = 0
		for(var/step in 1 to 60)
			T = get_step(T, dir)
			if(!T)
				break
			if(isspaceturf(T) && istype(get_area(T), /area/space))
				space_steps++
				if(space_steps >= 3)
					return T
			else
				space_steps = 0
	var/list/carp_spots = list()
	for(var/obj/effect/landmark/carpspawn/C in GLOB.landmarks_list)
		if(is_station_level(C.z))
			carp_spots += get_turf(C)
	if(length(carp_spots))
		return pick(carp_spots)

/// With no one to shoot at, the drone fires at a window (or a wall) of the ship nearby
/datum/round_event/aquila_hex_rogue_drone_swarm/proc/shoot_hull(mob/living/basic/hivebot/range/aquila_hex_rogue_drone/drone)
	if(QDELETED(drone) || drone.stat == DEAD || !drone.loc)
		return
	if(drone.ai_controller?.blackboard[BB_BASIC_MOB_CURRENT_TARGET])
		return
	var/list/windows = list()
	var/list/walls = list()
	for(var/atom/A in view(6, drone))
		if(istype(A, /obj/structure/window))
			windows += A
		else if(iswallturf(A))
			walls += A
	var/atom/target = length(windows) ? pick(windows) : (length(walls) ? pick(walls) : null)
	if(target)
		drone.fire_projectile(/obj/item/projectile/hivebotbullet, target, 'sound/weapons/gunshot.ogg')

/// A ranged hivebot that flies through space; the event deletes it when the swarm leaves
/mob/living/basic/hivebot/range/aquila_hex_rogue_drone
	name = "zbuntowany dron bojowy"
	desc = "Uzbrojony dron bez żadnych oznaczeń. Jego oprogramowanie dawno przestało słuchać kogokolwiek."
	faction = list("rogue_drone")
	health = 30
	maxHealth = 30
	spacewalk = TRUE
	gold_core_spawnable = NO_SPAWN
	playable = FALSE
	do_footstep = FALSE
