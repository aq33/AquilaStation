GLOBAL_VAR(vote_submit_cooldown)
#define VOTE_SUBMIT_COOLDOWN_TIME 1 SECONDS

/// Sound for everyone when someone votes, at most once a second
/datum/controller/subsystem/vote/proc/aquila_vote_submitted_sound()
	if(GLOB.vote_submit_cooldown < world.time)
		sound_to_playing_players('aquila/sound/misc/Vote.ogg')
		GLOB.vote_submit_cooldown = world.time + VOTE_SUBMIT_COOLDOWN_TIME

/datum/controller/subsystem/vote/submit_single_vote(mob/voter, their_vote)
	. = ..()
	if(.)
		aquila_vote_submitted_sound()

/datum/controller/subsystem/vote/submit_multi_vote(mob/voter, their_vote)
	. = ..()
	if(.)
		aquila_vote_submitted_sound()

// The start sound is the vote_sound of /datum/vote (aquila/code/datums/votes/_vote_datum.dm)
/datum/controller/subsystem/vote/process_vote_result()
	sound_to_playing_players('aquila/sound/misc/Vote_success.ogg')
	return ..()

/// Nazwa mapy z rozmiarem w nawiasie, np. „NSV Shrike (mała)”
/datum/map_config/proc/get_vote_label()
	return map_size ? "[map_name] ([map_size])" : map_name

/// Okno głosowania pokazuje rozmiar mapy obok nazwy. Klucz wyboru zostaje bez zmian, bo po nim wybierana jest mapa.
/datum/controller/subsystem/vote/ui_data(mob/user)
	. = ..()
	if(.["mode"] != "map")
		return
	for(var/list/choice as anything in .["choices"])
		var/datum/map_config/map_config = config.maplist[choice["name"]]
		choice["label"] = map_config ? map_config.get_vote_label() : choice["name"]

/// Okno głosowania (MapVote albo VotePanel) wybiera się tylko przy tworzeniu. Gdy zaczyna się głosowanie innego rodzaju,
/// otwarte okno dostałoby dane w obcym formacie i padło (VotePanel czyta user.isLowerAdmin), więc je zamykamy.
/datum/controller/subsystem/vote/proc/close_mismatched_uis()
	var/expected_interface = istype(current_vote, /datum/vote/map) ? "MapVote" : "VotePanel"
	var/list/open_uis = SStgui.get_all_open_uis(src)
	for(var/datum/tgui/ui as anything in open_uis.Copy())
		if(ui.interface != expected_interface)
			ui.close()

/// The map vote after the round ended is shown in the round-end report window, together with the report and the survey
/datum/controller/subsystem/vote/proc/map_vote_in_roundend_report()
	return istype(current_vote, /datum/vote/map) && SSticker.current_state == GAME_STATE_FINISHED

/datum/controller/subsystem/vote/ui_interact(mob/user, datum/tgui/ui)
	if(map_vote_in_roundend_report() && user?.client)
		GLOB.roundend_report_ui.show_with_vote(user)
		return
	close_mismatched_uis()
	if(ui?.closing)
		ui = null
	return ..(user, ui)

/datum/controller/subsystem/vote/initiate_vote(vote_type, vote_initiator_name, mob/vote_initiator, forced = FALSE, anonymous = FALSE, popup = FALSE)
	. = ..()
	if(.)
		close_mismatched_uis() // okna bez popupu; z popupem vote() otworzył już właściwe

#undef VOTE_SUBMIT_COOLDOWN_TIME
