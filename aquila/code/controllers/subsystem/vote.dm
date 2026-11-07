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

#undef VOTE_SUBMIT_COOLDOWN_TIME
