// AQUILA - "Statek w następnej rundzie" question in the end of round map vote window (tgui MapVote.tsx), next to "Dynamika rundy".
// Players who had a character answer whether the next round keeps the ship as the crew left it or starts on the ship straight from the map.
// The structure is saved at round end, before the vote, so the result is read when the next round loads the save.

#define SHIP_STRUCTURE_VOTE_FILE "data/ship_structure/vote.json"

/datum/ship_structure
	/// ckey -> TRUE (keep the ship) / FALSE (rebuild from the map), votes of this round
	var/list/keep_votes = list()

/// Whether a player can vote on the ship now: after the round ended, only with a character in it, and only when this round saves a ship
/datum/ship_structure/proc/can_vote_keep(ckey)
	return SSticker.current_state == GAME_STATE_FINISHED && (ckey in GLOB.joined_player_list) && !skip_save && save_path && fexists(save_path)

/datum/ship_structure/proc/set_keep_vote(ckey, keep)
	if(!can_vote_keep(ckey))
		return FALSE
	keep_votes[ckey] = keep ? TRUE : FALSE
	var/list/data = list("save" = save_path, "votes" = keep_votes)
	rustg_file_write(json_encode(data), SHIP_STRUCTURE_VOTE_FILE)
	return TRUE

/datum/ship_structure/proc/count_keep_votes()
	. = list("keep" = 0, "reset" = 0)
	for(var/ckey in keep_votes)
		if(keep_votes[ckey])
			.["keep"]++
		else
			.["reset"]++

/**
 * Reads the vote of the last round (and deletes it). Returns TRUE when the players chose to rebuild the ship from the map:
 * more "rebuild" than "keep" votes. No votes or a tie keep the ship. A vote cast for another map is dropped.
 */
/datum/ship_structure/proc/consume_last_vote()
	if(!fexists(SHIP_STRUCTURE_VOTE_FILE))
		return FALSE
	var/list/data
	try
		data = json_decode(rustg_file_read(SHIP_STRUCTURE_VOTE_FILE))
	catch
		data = null
	fdel(SHIP_STRUCTURE_VOTE_FILE)
	if(!islist(data) || data["save"] != save_path || !islist(data["votes"]))
		return FALSE
	var/keep = 0
	var/reset = 0
	var/list/votes = data["votes"]
	for(var/ckey in votes)
		if(votes[ckey])
			keep++
		else
			reset++
	log_game("Ship structure: last round vote [keep] keep / [reset] rebuild for [save_path]")
	last_vote_report = "głosowanie: obecny statek [keep], nowy statek [reset]"
	return reset > keep

/datum/ship_structure
	/// Result of the last round vote, shown to admins
	var/last_vote_report = "brak głosów"

/datum/controller/subsystem/vote/ui_data(mob/user)
	. = ..()
	var/datum/ship_structure/structure = SSship_structure.structure
	if(!structure || !istype(current_vote, /datum/vote/map) || SSticker.current_state != GAME_STATE_FINISHED || structure.skip_save)
		return
	var/ckey = user.client?.ckey
	.["ship_open"] = TRUE
	.["ship_can_vote"] = structure.can_vote_keep(ckey)
	.["ship_choice"] = (ckey in structure.keep_votes) ? (structure.keep_votes[ckey] ? 1 : 0) : null
	.["ship_counts"] = structure.count_keep_votes()
	.["ship_rounds"] = structure.rounds + 1

/datum/controller/subsystem/vote/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(action != "ship_vote")
		return ..()
	if(!ui || ui.status != UI_INTERACTIVE || !istype(current_vote, /datum/vote/map) || !usr?.client)
		return TRUE
	SSship_structure.structure?.set_keep_vote(usr.client.ckey, text2num(params["value"]) == 1)
	return TRUE

#undef SHIP_STRUCTURE_VOTE_FILE
