// AQ EDIT - ankiety graczy w oknie TGUI (PlayerPolls) zamiast okien HTML z formularzami.
// Zapisy do bazy (vote_on_poll_*) działają jak wcześniej, zmienił się tylko sposób przekazania głosu.

/mob/dead/new_player
	/// Okno ankiet tego gracza (TGUI)
	var/datum/player_polls_menu/polls_menu

/**
  * Shows a list of currently running polls a player can vote/has voted on
  *
  */
/mob/dead/new_player/proc/handle_player_polling()
	if(!client)
		return
	if(!polls_menu)
		polls_menu = new(src)
	polls_menu.ui_interact(src)

/**
  * Opens the poll window on the given poll.
  *
  */
/mob/dead/new_player/proc/poll_player(datum/poll_question/poll)
	if(!poll)
		return
	if(!polls_menu)
		polls_menu = new(src)
	if(polls_menu.select_poll(poll))
		polls_menu.ui_interact(src)

/// Okno ankiet jednego gracza w lobby: lista ankiet i głosowanie w wybranej
/datum/player_polls_menu
	/// Gracz w lobby, do którego należy okno
	var/mob/dead/new_player/owner
	/// Ankieta otwarta w oknie
	var/datum/poll_question/selected_poll
	/// Czy gracz już głosował w otwartej ankiecie (wczytane z bazy przy otwarciu)
	var/has_voted = FALSE
	/// Zapisany głos w otwartej ankiecie, w formie zależnej od typu ankiety (patrz load_vote)
	var/vote_data

/datum/player_polls_menu/New(mob/dead/new_player/new_owner)
	owner = new_owner

/datum/player_polls_menu/Destroy()
	SStgui.close_uis(src)
	owner = null
	selected_poll = null
	return ..()

/datum/player_polls_menu/ui_state(mob/user)
	return GLOB.always_state

/datum/player_polls_menu/ui_status(mob/user, datum/ui_state/state)
	return (user == owner && !QDELETED(owner)) ? UI_INTERACTIVE : UI_CLOSE

/datum/player_polls_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PlayerPolls", "Ankiety graczy")
		ui.open()

/// Czy gracz może zobaczyć tę ankietę
/datum/player_polls_menu/proc/can_see_poll(datum/poll_question/poll)
	if(!poll || !owner?.client)
		return FALSE
	if(poll.future_poll)
		return FALSE
	if(poll.admin_only && !owner.client.holder)
		return FALSE
	return TRUE

/// Otwiera ankietę w oknie i wczytuje z bazy głos gracza
/datum/player_polls_menu/proc/select_poll(datum/poll_question/poll)
	if(!can_see_poll(poll))
		return FALSE
	if(!SSdbcore.Connect())
		to_chat(owner, "<span class='danger'>Nie udało się połączyć z bazą danych.</span>")
		return FALSE
	if(!load_vote(poll))
		return FALSE
	selected_poll = poll
	return TRUE

/**
  * Loads the player's saved vote for a poll from the database.
  *
  * vote_data per poll type:
  * OPTION - REF of the voted option, TEXT - reply text, RATING - list(option REF = rating),
  * MULTI - list of voted option REFs, IRV - all option REFs in the voted order (unvoted ones shuffled at the end).
  */
/datum/player_polls_menu/proc/load_vote(datum/poll_question/poll)
	has_voted = FALSE
	vote_data = null
	var/ckey = owner.ckey
	if(poll.poll_type == POLLTYPE_TEXT)
		var/datum/DBQuery/query_text_get_replytext = SSdbcore.NewQuery({"
			SELECT replytext FROM [format_table_name("poll_textreply")]
			WHERE pollid = :pollid AND ckey = :ckey AND deleted = 0
		"}, list("pollid" = poll.poll_id, "ckey" = ckey))
		if(!query_text_get_replytext.warn_execute())
			qdel(query_text_get_replytext)
			return FALSE
		vote_data = ""
		if(query_text_get_replytext.NextRow())
			vote_data = query_text_get_replytext.item[1]
			has_voted = TRUE
		qdel(query_text_get_replytext)
		return TRUE

	var/datum/DBQuery/query_get_votes = SSdbcore.NewQuery({"
		SELECT optionid, rating FROM [format_table_name("poll_vote")]
		WHERE pollid = :pollid AND ckey = :ckey AND deleted = 0
		ORDER BY id
	"}, list("pollid" = poll.poll_id, "ckey" = ckey))
	if(!query_get_votes.warn_execute())
		qdel(query_get_votes)
		return FALSE
	var/list/voted_ids = list()
	var/list/voted_ratings = list()
	while(query_get_votes.NextRow())
		var/option_id = text2num(query_get_votes.item[1])
		voted_ids += option_id
		voted_ratings["[option_id]"] = text2num(query_get_votes.item[2])
	qdel(query_get_votes)
	has_voted = length(voted_ids) > 0

	switch(poll.poll_type)
		if(POLLTYPE_OPTION)
			for(var/datum/poll_option/option as anything in poll.options)
				if(option.option_id in voted_ids)
					vote_data = REF(option)
					break
		if(POLLTYPE_RATING)
			var/list/ratings = list()
			for(var/datum/poll_option/option as anything in poll.options)
				if(!isnull(voted_ratings["[option.option_id]"]))
					ratings[REF(option)] = voted_ratings["[option.option_id]"]
			vote_data = ratings
		if(POLLTYPE_MULTI)
			var/list/voted_refs = list()
			for(var/datum/poll_option/option as anything in poll.options)
				if(option.option_id in voted_ids)
					voted_refs += REF(option)
			vote_data = voted_refs
		if(POLLTYPE_IRV)
			//if they've already voted we use the order they voted in plus a shuffle of any options they haven't voted for, otherwise just shuffle the options
			var/list/prepared_options = list()
			for(var/vote_id in voted_ids)
				for(var/datum/poll_option/option as anything in poll.options)
					if(option.option_id == vote_id)
						prepared_options |= option
			prepared_options += shuffle(poll.options - prepared_options)
			var/list/order = list()
			for(var/datum/poll_option/option as anything in prepared_options)
				order += REF(option)
			vote_data = order
	return TRUE

/datum/player_polls_menu/ui_data(mob/user)
	var/list/data = list()
	var/list/polls = list()
	for(var/datum/poll_question/poll as anything in GLOB.polls)
		if(!can_see_poll(poll))
			continue
		polls += list(list(
			"ref" = REF(poll),
			"question" = poll.question,
			"type" = poll.poll_type,
		))
	data["polls"] = polls

	if(selected_poll && !QDELETED(selected_poll) && can_see_poll(selected_poll))
		var/list/options = list()
		for(var/datum/poll_option/option as anything in selected_poll.options)
			options += list(list(
				"ref" = REF(option),
				"text" = option.text,
				"min_val" = option.min_val,
				"max_val" = option.max_val,
				"desc_min" = option.desc_min,
				"desc_mid" = option.desc_mid,
				"desc_max" = option.desc_max,
			))
		data["selected"] = list(
			"ref" = REF(selected_poll),
			"question" = selected_poll.question,
			"subtitle" = selected_poll.subtitle,
			"type" = selected_poll.poll_type,
			"start" = selected_poll.start_datetime,
			"end" = selected_poll.end_datetime,
			"allow_revoting" = !!selected_poll.allow_revoting,
			"options_allowed" = selected_poll.options_allowed,
			"minimum_playtime" = selected_poll.minimumplaytime,
			"options" = options,
			"has_voted" = has_voted,
			"vote" = vote_data,
		)
	else
		data["selected"] = null
	return data

/datum/player_polls_menu/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(usr != owner)
		return
	switch(action)
		if("select")
			var/datum/poll_question/poll = locate(params["ref"]) in GLOB.polls
			select_poll(poll)
			return TRUE
		if("back")
			selected_poll = null
			vote_data = null
			has_voted = FALSE
			return TRUE
		if("vote")
			if(!selected_poll || params["ref"] != REF(selected_poll))
				return TRUE
			if(has_voted && !selected_poll.allow_revoting)
				return TRUE
			if(owner.vote_on_poll_handler(selected_poll, params))
				load_vote(selected_poll)
				owner.new_player_panel() // odświeża „NOWE!” przy ankietach w lobby
			return TRUE

/**
  * Runs some poll validation before a vote is processed.
  *
  * Checks a player is who they claim to be and that a poll is actually still running.
  * Also loads the vote_id to pass onto single-option and text polls.
  * Increments the vote count when successful.
  *
  * vote_params comes from the PlayerPolls window: "option" (OPTION), "text" (TEXT), "ratings" (RATING),
  * "options" (MULTI), "order" (IRV) - see the vote_on_poll_* procs.
  */
/mob/dead/new_player/proc/vote_on_poll_handler(datum/poll_question/poll, list/vote_params)
	if(!SSdbcore.Connect())
		to_chat(src, "<span class='danger'>Nie udało się połączyć z bazą danych.</span>")
		return
	if(!poll || !islist(vote_params))
		return
	if(IsAdminAdvancedProcCall())
		log_game("[key_name(usr)] attempted to rig the vote by voting as [key]")
		message_admins("[key_name_admin(usr)] próbuje sfałszować głosowanie, głosując jako [key]")
		to_chat(usr, "<span class='danger'>Wygląda na to, że nie jesteś [key].</span>")
		to_chat(src, "<span class='danger'>Coś poszło bardzo nie tak przy przetwarzaniu twojego głosu. Skontaktuj się z administratorem - powinien był dostać o tym wiadomość</span>")
		return
	var/admin_rank
	if(client.holder)
		admin_rank = client.holder.rank.name
	else
		if(poll.admin_only)
			return
		else
			admin_rank = "Player"
	var/player_playtime = round(client?.get_exp_living(TRUE) / 60)
	if(!isnull(player_playtime) && (player_playtime < poll.minimumplaytime))
		to_chat(usr, "<span class='warning'>Masz za mało przegranego czasu, by głosować w tej ankiecie. Minimum: [poll.minimumplaytime] godz. Twój czas: [player_playtime] godz.</span>")
		return
	var/table = "poll_vote"
	if(poll.poll_type == POLLTYPE_TEXT)
		table = "poll_textreply"
	var/sql_poll_id = poll.poll_id
	var/vote_id //only used for option and text polls to save needing another query
	var/datum/DBQuery/query_validate_poll_vote = SSdbcore.NewQuery({"
		SELECT
			(SELECT id FROM [format_table_name(table)] WHERE ckey = :ckey AND pollid = :pollid AND deleted = 0 LIMIT 1)
		FROM [format_table_name("poll_question")]
		WHERE NOW() BETWEEN starttime AND endtime AND deleted = 0 AND id = :pollid
	"}, list("ckey" = ckey, "pollid" = sql_poll_id))
	if(!query_validate_poll_vote.warn_execute())
		qdel(query_validate_poll_vote)
		return
	//triple state return: no row returned if poll isn't running, null if no vote found, otherwise returns the vote id
	if(query_validate_poll_vote.NextRow())
		vote_id = text2num(query_validate_poll_vote.item[1])
		if(vote_id && !poll.allow_revoting)
			to_chat(usr, "<span class='danger'>Zmiana głosu jest wyłączona, a ty już odpowiedziałeś na tę ankietę.</span>")
			qdel(query_validate_poll_vote)
			return
	else
		to_chat(usr, "<span class='danger'>Wybrana ankieta nie jest otwarta.</span>")
		qdel(query_validate_poll_vote)
		return
	qdel(query_validate_poll_vote)
	var/vote_success = FALSE
	switch(poll.poll_type)
		if(POLLTYPE_OPTION)
			vote_success = vote_on_poll_option(poll, vote_params, admin_rank, sql_poll_id, vote_id)
		if(POLLTYPE_TEXT)
			vote_success = vote_on_poll_text(vote_params, admin_rank, sql_poll_id, vote_id)
		if(POLLTYPE_RATING)
			vote_success = vote_on_poll_rating(poll, vote_params, admin_rank, sql_poll_id)
		if(POLLTYPE_MULTI)
			vote_success = vote_on_poll_multi(poll, vote_params, admin_rank, sql_poll_id)
		if(POLLTYPE_IRV)
			vote_success = vote_on_poll_irv(poll, vote_params, admin_rank, sql_poll_id)
	if(vote_success)
		if(!vote_id)
			poll.poll_votes++
		to_chat(usr, "<span class='notice'>Głos oddany.</span>")
	return vote_success

/**
  * Saves the vote of an option type poll. vote_params["option"] is the REF of the chosen option.
  *
  */
/mob/dead/new_player/proc/vote_on_poll_option(datum/poll_question/poll, list/vote_params, admin_rank, sql_poll_id, vote_id)
	if(!SSdbcore.Connect())
		to_chat(src, "<span class='danger'>Nie udało się połączyć z bazą danych.</span>")
		return
	if(IsAdminAdvancedProcCall())
		return
	var/datum/poll_option/option = locate(vote_params["option"]) in poll.options
	if(!option)
		to_chat(src, "<span class='danger'>Nie wybrano żadnej opcji.</span>")
		return
	var/datum/DBQuery/query_vote_option = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("poll_vote")] (id, datetime, pollid, optionid, ckey, ip, adminrank)
		VALUES (:vote_id, NOW(), :poll_id, :option_id, :ckey, INET_ATON(:ip), :admin_rank)
		ON DUPLICATE KEY UPDATE datetime = NOW(), optionid = :option_id, ip = INET_ATON(:ip), adminrank = :admin_rank
	"}, list(
		"vote_id" = vote_id,
		"poll_id" = sql_poll_id,
		"option_id" = option.option_id,
		"ckey" = ckey,
		"ip" = client.address,
		"admin_rank" = admin_rank,
	))
	if(!query_vote_option.warn_execute())
		qdel(query_vote_option)
		return
	qdel(query_vote_option)
	return TRUE

/**
  * Saves the response of a text response type poll. vote_params["text"] is the reply.
  *
  */
/mob/dead/new_player/proc/vote_on_poll_text(list/vote_params, admin_rank, sql_poll_id, vote_id)
	if(!SSdbcore.Connect())
		to_chat(src, "<span class='danger'>Nie udało się połączyć z bazą danych.</span>")
		return
	if(IsAdminAdvancedProcCall())
		return
	var/reply_text = vote_params["text"]
	if(!istext(reply_text))
		reply_text = null
	reply_text = trim(reply_text)
	if(!reply_text || (length(reply_text) > 2048))
		to_chat(src, "<span class='danger'>Wpisany tekst jest pusty lub za długi. Popraw go i wyślij ponownie.</span>")
		return
	var/datum/DBQuery/query_vote_text = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("poll_textreply")] (id, datetime, pollid, ckey, ip, replytext, adminrank)
		VALUES (:vote_id, NOW(), :poll_id, :ckey, INET_ATON(:ip), :reply_text, :admin_rank)
		ON DUPLICATE KEY UPDATE datetime = NOW(), ip = INET_ATON(:ip), replytext = :reply_text, adminrank = :admin_rank
	"}, list(
		"vote_id" = vote_id,
		"poll_id" = sql_poll_id,
		"ckey" = ckey,
		"ip" = client.address,
		"reply_text" = reply_text,
		"admin_rank" = admin_rank,
	))
	if(!query_vote_text.warn_execute())
		qdel(query_vote_text)
		return
	qdel(query_vote_text)
	return TRUE

/**
  * Saves the votes of a rating type poll. vote_params["ratings"] is a list of option REF = rating.
  *
  */
/mob/dead/new_player/proc/vote_on_poll_rating(datum/poll_question/poll, list/vote_params, admin_rank, sql_poll_id)
	if(!SSdbcore.Connect())
		to_chat(src, "<span class='danger'>Nie udało się połączyć z bazą danych.</span>")
		return
	if(IsAdminAdvancedProcCall())
		return
	var/list/ratings = vote_params["ratings"]
	if(!islist(ratings) || !length(ratings))
		to_chat(src, "<span class='danger'>Nie oceniono żadnej opcji.</span>")
		return
	var/list/votes = list()
	var/datum/DBQuery/query_get_rating_votes = SSdbcore.NewQuery({"
		SELECT id, optionid FROM [format_table_name("poll_vote")]
		WHERE pollid = :pollid AND ckey = :ckey AND deleted = 0
	"}, list("pollid" = sql_poll_id, "ckey" = ckey))
	if(!query_get_rating_votes.warn_execute())
		qdel(query_get_rating_votes)
		return
	while(query_get_rating_votes.NextRow())
		votes += list("[query_get_rating_votes.item[2]]" = text2num(query_get_rating_votes.item[1]))
	qdel(query_get_rating_votes)

	var/special_columns = list(
		"datetime" = "NOW()",
		"ip" = "INET_ATON(?)",
	)

	var/sql_votes = list()
	for(var/option_ref in ratings)
		var/datum/poll_option/option = locate(option_ref) in poll.options
		if(!option)
			continue
		var/rating = text2num("[ratings[option_ref]]")
		if(!isnum(rating))
			continue
		rating = clamp(round(rating), option.min_val, option.max_val)
		sql_votes += list(list(
			"id" = votes["[option.option_id]"],
			"pollid" = sql_poll_id,
			"optionid" = option.option_id,
			"ckey" = ckey,
			"ip" = client.address,
			"adminrank" = admin_rank,
			"rating" = rating
		))
	if(!length(sql_votes))
		to_chat(src, "<span class='danger'>Nie oceniono żadnej opcji.</span>")
		return
	SSdbcore.MassInsert(format_table_name("poll_vote"), sql_votes, duplicate_key = TRUE, special_columns = special_columns)
	return TRUE

/**
  * Saves the votes of a multiple choice type poll. vote_params["options"] is a list of chosen option REFs.
  *
  */
/mob/dead/new_player/proc/vote_on_poll_multi(datum/poll_question/poll, list/vote_params, admin_rank, sql_poll_id)
	if(!SSdbcore.Connect())
		to_chat(src, "<span class='danger'>Nie udało się połączyć z bazą danych.</span>")
		return
	if(IsAdminAdvancedProcCall())
		return
	var/list/chosen = vote_params["options"]
	if(!islist(chosen) || !length(chosen))
		to_chat(src, "<span class='danger'>Nie wybrano żadnych opcji.</span>")
		return

	var/special_columns = list(
		"datetime" = "NOW()",
		"ip" = "INET_ATON(?)",
	)

	var/sql_votes = list()
	var/list/voted_options = list()
	for(var/option_ref in chosen)
		if(length(voted_options) == poll.options_allowed)
			to_chat(src, "<span class='danger'>Przekroczono dozwoloną liczbę opcji, zapisano tylko pierwsze [poll.options_allowed].</span>")
			break
		var/datum/poll_option/option = locate(option_ref) in poll.options
		if(!option || (option in voted_options))
			continue
		voted_options += option
		sql_votes += list(list(
			"pollid" = sql_poll_id,
			"optionid" = option.option_id,
			"ckey" = ckey,
			"ip" = client.address,
			"adminrank" = admin_rank
		))
	if(!length(sql_votes))
		to_chat(src, "<span class='danger'>Nie wybrano żadnych opcji.</span>")
		return
	/*with revoting and poll editing possible there can be an edge case where a poll is changed to allow less multiple choice options than a user has already voted on
	rather than trying to calculate which options should be updated and which deleted, we just delete all of a user's votes and re-insert as needed*/
	var/datum/DBQuery/query_delete_multi_votes = SSdbcore.NewQuery({"
		UPDATE [format_table_name("poll_vote")] SET deleted = 1 WHERE pollid = :pollid AND ckey = :ckey
	"}, list("pollid" = sql_poll_id, "ckey" = ckey))
	if(!query_delete_multi_votes.warn_execute())
		qdel(query_delete_multi_votes)
		return
	qdel(query_delete_multi_votes)
	SSdbcore.MassInsert(format_table_name("poll_vote"), sql_votes, special_columns = special_columns)
	return TRUE

/**
  * Saves the ranking of an IRV type poll. vote_params["order"] is a list of option REFs, most preferred first.
  *
  */
/mob/dead/new_player/proc/vote_on_poll_irv(datum/poll_question/poll, list/vote_params, admin_rank, sql_poll_id)
	if(!SSdbcore.Connect())
		to_chat(src, "<span class='danger'>Nie udało się połączyć z bazą danych.</span>")
		return
	if(IsAdminAdvancedProcCall())
		return
	var/list/votelist = vote_params["order"]
	if(!islist(votelist) || !length(votelist))
		to_chat(src, "<span class='danger'>Nie znaleziono danych o kolejności. Spróbuj ponownie albo skontaktuj się z administratorem.</span>")
		return

	var/list/special_columns = list(
		"datetime" = "NOW()",
		"ip" = "INET_ATON(?)",
	)

	var/sql_votes = list()
	var/list/voted_options = list()
	for(var/option_ref in votelist)
		var/datum/poll_option/option = locate(option_ref) in poll.options
		if(!option || (option in voted_options))
			continue
		voted_options += option
		sql_votes += list(list(
			"pollid" = sql_poll_id,
			"optionid" = option.option_id,
			"ckey" = ckey,
			"ip" = client.address,
			"adminrank" = admin_rank
		))
	if(!length(sql_votes))
		to_chat(src, "<span class='danger'>Nie znaleziono danych o kolejności. Spróbuj ponownie albo skontaktuj się z administratorem.</span>")
		return
	//IRV results are calculated based on id order, we delete all of a user's votes to avoid potential errors caused by revoting and option editing
	var/datum/DBQuery/query_delete_irv_votes = SSdbcore.NewQuery({"
		UPDATE [format_table_name("poll_vote")] SET deleted = 1 WHERE pollid = :pollid AND ckey = :ckey
	"}, list("pollid" = sql_poll_id, "ckey" = ckey))
	if(!query_delete_irv_votes.warn_execute())
		qdel(query_delete_irv_votes)
		return
	qdel(query_delete_irv_votes)
	SSdbcore.MassInsert(format_table_name("poll_vote"), sql_votes, special_columns = special_columns)
	return TRUE
