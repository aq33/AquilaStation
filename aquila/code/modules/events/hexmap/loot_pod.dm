// AQUILA - Duża kapsuła desantowa rozbija się o okręt: łup i 2-4 wrogich strażników (port z CEV-Eris code/game/gamemodes/events/supply_pod.dm)
// Eris drops a random-map drop pod with two supply loot packs, 10 rare and 20 random items and 0-n groups of random mobs.
// Ours is a supply pod from our cargo system (landing area and floor checks of the stray cargo pod through parent_type):
// a heavier landing explosion, loot from the exploration drone loot generators (3 rare picks and 6-10 maintenance items)
// and 2-4 guards, either hivebots or Syndicate troopers. The pod always opens (Eris: 50%). Like Eris it tries to land
// at least 5 tiles away from space, so the impact does not breach the hull. Unlike Eris the crew is warned, like by our stray pods.

/datum/round_event_control/aquila_hex_loot_pod
	name = "Loot Drop Pod"
	typepath = /datum/round_event/aquila_hex_loot_pod
	weight = 10
	min_players = 10
	max_occurrences = 1
	earliest_start = 30 MINUTES

/datum/round_event/aquila_hex_loot_pod
	parent_type = /datum/round_event/aquila_stray_cargo
	fakeable = FALSE
	/// Syndicate troopers guard the loot instead of hivebots
	var/syndicate_guards = FALSE

/datum/round_event/aquila_hex_loot_pod/setup()
	syndicate_guards = prob(50)
	return ..()

/datum/round_event/aquila_hex_loot_pod/announce(fake)
	if(!landing_zone)
		return
	priority_announce("Sensory okrętu wykryły dużą, nieoznakowaną kapsułę desantową na kursie kolizyjnym. Przewidywane miejsce uderzenia: [impact_area?.name || "nieznane"]. Należy opuścić okolicę. Kapsuła może przewozić wrogie jednostki.", "Ostrzeżenie przed kolizją")

/datum/round_event/aquila_hex_loot_pod/start()
	if(!landing_zone)
		return kill()
	if(is_blocked_turf(landing_zone, TRUE))
		landing_zone = get_landing_zone()
		if(!landing_zone)
			return kill()
	var/obj/structure/closet/supplypod/pod = new(null, syndicate_guards ? STYLE_SYNDICATE : STYLE_PIRATE)
	pod.explosionSize = list(0, 1, 2, 3) // Eris: "major devastation where it hits"
	fill_pod(pod)
	var/obj/effect/pod_landingzone/landing_marker = new(landing_zone, pod)
	announce_to_ghosts(landing_marker)
	message_admins("Kapsuła desantowa z łupem ląduje w: [ADMIN_VERBOSEJMP(landing_zone)].")
	log_game("Loot Drop Pod: a loot drop pod is landing at [AREACOORD(landing_zone)].")

/// Puts the loot and the guards in the pod
/datum/round_event/aquila_hex_loot_pod/proc/fill_pod(obj/structure/closet/supplypod/pod)
	var/static/list/rare_loot_generators = list(
		/datum/adventure_loot_generator/simple/unique,
		/datum/adventure_loot_generator/simple/cash,
		/datum/adventure_loot_generator/simple/research,
		/datum/adventure_loot_generator/simple/materials,
		/datum/adventure_loot_generator/simple/weapons,
		/datum/adventure_loot_generator/simple/drugs,
	)
	for(var/i in 1 to 3)
		var/generator_type = pick(rare_loot_generators)
		add_loot(pod, new generator_type)
	var/datum/adventure_loot_generator/maintenance/maintenance_loot = new
	maintenance_loot.amount = rand(6, 10)
	add_loot(pod, maintenance_loot)

	var/static/list/hivebot_guards = list(/mob/living/basic/hivebot, /mob/living/basic/hivebot/range, /mob/living/basic/hivebot/rapid)
	var/static/list/syndicate_guards_list = list(/mob/living/basic/trooper/syndicate, /mob/living/basic/trooper/syndicate/ranged, /mob/living/basic/trooper/syndicate/melee/sword)
	for(var/i in 1 to rand(2, 4))
		var/guard_type = pick(syndicate_guards ? syndicate_guards_list : hivebot_guards)
		new guard_type(pod)

/datum/round_event/aquila_hex_loot_pod/proc/add_loot(obj/structure/closet/supplypod/pod, datum/adventure_loot_generator/generator)
	for(var/atom/movable/loot in generator.generate())
		if(QDELETED(loot))
			continue
		if(iseffect(loot)) // loot spawners of the maintenance table, they spawn into nullspace without a loc
			qdel(loot)
			continue
		loot.forceMove(pod)
	qdel(generator)

/// A free floor at least 5 tiles away from space, trying a few areas; any free floor of the last one if none is found
/datum/round_event/aquila_hex_loot_pod/get_landing_zone()
	for(var/area_attempt in 1 to 5)
		if(!impact_area)
			break
		var/list/valid_turfs = list()
		for(var/turf/open/T in impact_area)
			if(!isspaceturf(T) && !is_blocked_turf(T, TRUE))
				valid_turfs += T
		for(var/turf_attempt in 1 to 15)
			if(!length(valid_turfs))
				break
			var/turf/candidate = pick_n_take(valid_turfs)
			if(!near_space(candidate))
				return candidate
		impact_area = find_event_area()
	return ..()

/datum/round_event/aquila_hex_loot_pod/proc/near_space(turf/center)
	for(var/turf/T as anything in RANGE_TURFS(5, center))
		if(isspaceturf(T))
			return TRUE
	return FALSE
