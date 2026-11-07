// AQUILA - "Statek w następnej rundzie" question in the end of round map vote window (tgui MapVote.tsx), next to "Dynamika rundy".
// Players who had a character answer whether the next round on this ship keeps it as the crew left it or starts on a new ship.
// The structure is saved at round end, before the vote; the result is applied at world shutdown to the map that was played,
// so a different map winning the map vote doesn't lose the result.

/datum/ship_structure
	/// ckey -> TRUE (keep the ship) / FALSE (start on a new ship), votes of this round
	var/list/keep_votes = list()

/// Whether a player can vote on the ship now: after the round ended, only with a character in it, and only when this round saved a ship
/datum/ship_structure/proc/can_vote_keep(ckey)
	return SSticker.current_state == GAME_STATE_FINISHED && (ckey in GLOB.joined_player_list) && saved_this_round && !skip_save

/datum/ship_structure/proc/set_keep_vote(ckey, keep)
	if(!can_vote_keep(ckey))
		return FALSE
	keep_votes[ckey] = keep ? TRUE : FALSE
	return TRUE

/datum/ship_structure/proc/count_keep_votes()
	. = list("keep" = 0, "reset" = 0)
	for(var/ckey in keep_votes)
		if(keep_votes[ckey])
			.["keep"]++
		else
			.["reset"]++

/datum/ship_structure/proc/vote_report()
	var/list/counts = count_keep_votes()
	return "obecny statek [counts["keep"]], nowy statek [counts["reset"]]"

/**
 * Applies the vote of this round to this map's save (called from SSship_structure.Shutdown()).
 * More "new ship" than "keep" votes deletes the save; a tie or no votes keeps the ship.
 */
/datum/ship_structure/proc/apply_vote()
	var/list/counts = count_keep_votes()
	if(!counts["keep"] && !counts["reset"])
		return
	log_game("Ship structure: vote [counts["keep"]] keep / [counts["reset"]] new ship for [save_path]")
	if(counts["reset"] > counts["keep"] && save_path && fexists(save_path))
		fdel(save_path)
		log_game("Ship structure: players voted for a new ship, [save_path] deleted")

/datum/controller/subsystem/vote/ui_data(mob/user)
	. = ..()
	var/datum/ship_structure/structure = SSship_structure.structure
	if(!structure || !istype(current_vote, /datum/vote/map) || SSticker.current_state != GAME_STATE_FINISHED || !structure.saved_this_round || structure.skip_save)
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
