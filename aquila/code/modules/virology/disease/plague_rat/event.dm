// Event „szczury zarazy” — port z Monkestation2.0 (disease/plague_rat/event.dm).
// Monke stoi na nowym SSevents (track/category/tags) i SSpolling; u nas event i ankieta
// duchów wyglądają jak w pozostałych portach (wzór: aquila/code/modules/events/blood_worm.dm).

/datum/round_event_control/plague_rat
	name = "Plague Rats"
	typepath = /datum/round_event/ghost_role/plague_rat
	weight = 2
	max_occurrences = 1
	min_players = 35
	earliest_start = 55 MINUTES
	dynamic_should_hijack = TRUE
	cannot_spawn_after_shuttlecall = TRUE

/datum/round_event/ghost_role/plague_rat
	minimum_required = 1
	role_name = "szczur zarazy"

/datum/round_event/ghost_role/plague_rat/spawn_role()
	var/list/candidates = get_candidates(ROLE_PLAGUERAT, /datum/role_preference/midround_ghost/plague_rat, POLL_IGNORE_PLAGUERAT)
	if(!length(candidates))
		return NOT_ENOUGH_PLAYERS

	var/spawncount = min(4, length(candidates))
	while(spawncount > 0 && length(candidates))
		var/mob/dead/selected = pick_n_take(candidates)
		var/mob/living/simple_animal/mouse/plague/rat = new
		var/datum/mind/player_mind = new /datum/mind(selected.key)
		player_mind.active = TRUE
		player_mind.transfer_to(rat)
		player_mind.assigned_role = ROLE_PLAGUERAT
		player_mind.special_role = ROLE_PLAGUERAT
		player_mind.add_antag_datum(/datum/antagonist/plague_rat)
		playsound(rat, 'sound/magic/ethereal_exit.ogg', 50, TRUE, -1)
		message_admins("[ADMIN_LOOKUPFLW(rat)] został szczurem zarazy przez event.")
		log_game("[key_name(rat)] was spawned as a plague rat by an event.")
		spawned_mobs += rat
		spawncount--

	return SUCCESSFUL_SPAWN

/datum/role_preference/midround_ghost/plague_rat
	name = "Szczur zarazy"
	antag_datum = /datum/antagonist/plague_rat
