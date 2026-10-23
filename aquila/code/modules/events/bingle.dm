// AQUILA - event Bingle Lorda (port z Monkestation, ghost_role.dm)
// Różnice: próg 15 graczy zamiast 35 (Monkestation/Monkestation2.0#11577) i pula ciężka trybu weighted.

/// Losowe bezpieczne pole w maintach, w razie czego gdziekolwiek na stacji
/proc/find_bingle_lord_spawn()
	var/list/maint_areas = list()
	for(var/area_type in GLOB.the_station_areas)
		if(ispath(area_type, /area/maintenance))
			maint_areas += area_type
	. = get_safe_random_station_turfs(maint_areas)
	if(!.)
		. = get_safe_random_station_turfs()

/datum/round_event_control/bingle
	name = "Spawn Bingle"
	typepath = /datum/round_event/ghost_role/bingle
	weight = 5
	min_players = 15
	max_occurrences = 1
	dynamic_should_hijack = TRUE
	cannot_spawn_after_shuttlecall = TRUE

/datum/round_event/ghost_role/bingle
	minimum_required = 1
	role_name = "Bingle Lord"
	fakeable = FALSE

/datum/round_event/ghost_role/bingle/spawn_role()
	var/list/candidates = get_candidates(ROLE_BINGLE, /datum/role_preference/midround_ghost/bingle, POLL_IGNORE_BINGLE)
	if(!length(candidates))
		return NOT_ENOUGH_PLAYERS
	var/turf/spawn_loc = find_bingle_lord_spawn()
	if(isnull(spawn_loc))
		return MAP_ERROR
	var/mob/dead/selected = pick(candidates)
	var/mob/living/simple_animal/hostile/bingle/lord/lord = new(spawn_loc)
	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = TRUE
	player_mind.transfer_to(lord)
	player_mind.assigned_role = ROLE_BINGLE
	player_mind.add_antag_datum(/datum/antagonist/bingle)
	message_admins("[ADMIN_LOOKUPFLW(lord)] has been made into a Bingle Lord by an event.")
	log_game("[key_name(lord)] was spawned as a Bingle Lord by an event.")
	spawned_mobs += lord
	return SUCCESSFUL_SPAWN

/datum/role_preference/midround_ghost/bingle
	name = "Bingiel"
	antag_datum = /datum/antagonist/bingle
