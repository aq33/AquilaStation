// AQUILA: port of tgstation code/modules/mob/living/basic/lavaland/goliath/goliath_actions.dm (tg 926bf40c5a) with our
// tentacle effect (/obj/effect/temp_visual/goliath_tentacle): the main attack puts our "original" tentacle cross under the
// target, the line spawns tentacles one tile at a time (tg: an invisible effect trail with a spawner).

/// Place some grappling tentacles underfoot
/datum/action/cooldown/mob_cooldown/goliath_tentacles
	name = "Wypuść macki"
	desc = "Wypuszcza zakopane macki w wybranym miejscu; po chwili chwytają każdego, kto tam stoi."
	icon_icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	button_icon_state = "Goliath_tentacle_wiggle"
	background_icon_state = "bg_demon"
	click_to_activate = TRUE
	cooldown_time = 12 SECONDS
	melee_cooldown_time = 0
	shared_cooldown = NONE
	/// Furthest range we can activate ability at
	var/max_range = 7

/datum/action/cooldown/mob_cooldown/goliath_tentacles/PreActivate(atom/target)
	var/turf/target_turf = get_turf(target)
	if (isnull(target_turf) || get_dist(owner, target_turf) > max_range)
		return FALSE
	return ..()

/datum/action/cooldown/mob_cooldown/goliath_tentacles/Activate(atom/target)
	var/turf/target_turf = get_turf(target)
	new /obj/effect/temp_visual/goliath_tentacle/original(target_turf, owner)
	if (isliving(target))
		owner.visible_message(span_warning("[owner] wbija macki pod [target]!"))
	StartCooldown()
	return TRUE

/// Place grappling tentacles around you to grab attackers
/datum/action/cooldown/mob_cooldown/tentacle_burst
	name = "Wybuch macek"
	desc = "Wypuszcza zakopane macki dookoła ciebie; po chwili chwytają każdego, kto stoi obok."
	icon_icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	button_icon_state = "Goliath_tentacle_wiggle"
	background_icon_state = "bg_demon"
	cooldown_time = 24 SECONDS
	melee_cooldown_time = 0
	shared_cooldown = NONE
	click_to_activate = FALSE

/datum/action/cooldown/mob_cooldown/tentacle_burst/Activate(atom/target)
	var/turf/center = get_turf(owner)
	for (var/dir in GLOB.alldirs)
		var/turf/adjacent_target = get_step(center, dir)
		if(adjacent_target)
			new /obj/effect/temp_visual/goliath_tentacle(adjacent_target, owner)
	owner.visible_message(span_warning("[owner] wypuszcza macki z ziemi dookoła siebie!"))
	StartCooldown()
	return TRUE

/// Summon a line of tentacles towards the target
/datum/action/cooldown/mob_cooldown/tentacle_grasp
	name = "Chwyt macek"
	desc = "Wypuszcza linię zakopanych macek w stronę celu; po chwili chwytają każdego na swojej drodze."
	icon_icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	button_icon_state = "Goliath_tentacle_wiggle"
	background_icon_state = "bg_demon"
	click_to_activate = TRUE
	cooldown_time = 12 SECONDS
	melee_cooldown_time = 0
	shared_cooldown = NONE
	/// Furthest a line reaches
	var/max_range = 9
	/// Time between the tentacles of the line
	var/spawn_interval = 0.1 SECONDS

/datum/action/cooldown/mob_cooldown/tentacle_grasp/Activate(atom/target)
	var/turf/target_turf = get_turf(target)
	if (isnull(target_turf))
		return FALSE
	var/list/line = getline(get_turf(owner), target_turf) - get_turf(owner)
	var/delay = 0
	for (var/turf/line_turf as anything in line)
		if (length(line) && line.Find(line_turf) > max_range)
			break
		delay += spawn_interval
		addtimer(CALLBACK(src, PROC_REF(spawn_tentacle), line_turf), delay)
	if (isliving(target))
		owner.visible_message(span_warning("[owner] sięga mackami po [target]!"))
	StartCooldown()
	return TRUE

/// One tentacle of the line
/datum/action/cooldown/mob_cooldown/tentacle_grasp/proc/spawn_tentacle(turf/line_turf)
	if (QDELETED(owner) || owner.stat == DEAD || isclosedturf(line_turf) && !ismineralturf(line_turf))
		return
	new /obj/effect/temp_visual/goliath_tentacle(line_turf, owner)
