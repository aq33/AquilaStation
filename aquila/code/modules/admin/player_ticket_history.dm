// Historia ticketów gracza (port tgstation#75830): ostatnie tickety z bazy (tabela ticket), bez bieżącej rundy.

/// Jeden ticket z bazy
/datum/ticket_history
	var/player_ckey
	/// Numer ticketu *w swojej rundzie*
	var/ticket_number
	var/round_id
	var/list/ticket_log

/// Jedna akcja na tickecie
/datum/ticket_log_entry
	var/timestamp
	var/origin_ckey
	var/target_ckey
	var/action
	var/message

GENERAL_PROTECT_DATUM(/datum/ticket_history)
GENERAL_PROTECT_DATUM(/datum/ticket_log_entry)

GLOBAL_DATUM_INIT(player_ticket_history, /datum/ticket_history_holder, new)
GLOBAL_PROTECT(player_ticket_history)

/world/AVerbsAdmin()
	. = ..()
	. += /client/proc/player_ticket_history

/client/proc/player_ticket_history()
	set name = "Player Ticket History"
	set desc = "Pokazuje historię ticketów gracza z bazy danych."
	set category = "Admin"
	if(!check_rights(R_ADMIN))
		return
	GLOB.player_ticket_history.ui_interact(mob)

/datum/ticket_history_holder
	/// ckey -> list/datum/ticket_history
	var/list/ticket_histories = list()
	/// ckey admina -> ckey wybranego gracza
	var/list/user_selections = list()

/datum/ticket_history_holder/proc/cache_history_for_ckey(ckey, entries = 5)
	ckey = ckey(ckey)
	if(!ckey || !isnum(entries) || entries <= 0)
		return
	entries = min(entries, 20)

	if(!ticket_db_ready())
		to_chat(usr, span_adminnotice("Brak tabeli ticketów w bazie i nie udało się jej utworzyć (sprawdź uprawnienie CREATE użytkownika bazy)."))
		return

	var/list/datum/ticket_history/history_cache = list()
	ticket_histories[ckey] = history_cache

	var/datum/DBQuery/ticket_lookup = SSdbcore.NewQuery({"
		WITH DISTINCT_TICKETS AS (
			SELECT id, round_id, ticket, sender, recipient FROM [format_table_name("ticket")]
			WHERE id IN (
				SELECT MAX(id) FROM [format_table_name("ticket")] GROUP BY round_id, ticket
			)
			AND round_id != :current_round
		)
		SELECT round_id, ticket FROM DISTINCT_TICKETS
		WHERE sender = :ckey OR recipient = :ckey
		ORDER BY id DESC
		LIMIT :max_entries
	"}, list("ckey" = ckey, "current_round" = GLOB.round_id, "max_entries" = entries))
	if(!ticket_lookup.warn_execute())
		qdel(ticket_lookup)
		ticket_histories -= ckey
		to_chat(usr, span_adminnotice("Nie udało się pobrać historii ticketów [ckey]."))
		return

	var/list/lookup_targets = list()
	while(ticket_lookup.NextRow())
		lookup_targets += list(list(ticket_lookup.item[1], ticket_lookup.item[2]))
	qdel(ticket_lookup)

	for(var/list/target as anything in lookup_targets)
		var/datum/DBQuery/ticket_lookup_instance = SSdbcore.NewQuery({"
			SELECT action, message, timestamp, recipient, sender
			FROM [format_table_name("ticket")]
			WHERE round_id = :round AND ticket = :ticket
			ORDER BY id DESC
		"}, list("round" = target[1], "ticket" = target[2]))
		if(!ticket_lookup_instance.warn_execute())
			qdel(ticket_lookup_instance)
			continue

		var/datum/ticket_history/ticket_history = new
		ticket_history.player_ckey = ckey
		ticket_history.round_id = text2num(target[1])
		ticket_history.ticket_number = text2num(target[2])
		var/list/ticket_log = list()
		while(ticket_lookup_instance.NextRow())
			var/datum/ticket_log_entry/log_entry = new
			log_entry.action = ticket_lookup_instance.item[1]
			log_entry.message = ticket_lookup_instance.item[2]
			log_entry.timestamp = ticket_lookup_instance.item[3]
			log_entry.target_ckey = ticket_lookup_instance.item[4]
			log_entry.origin_ckey = ticket_lookup_instance.item[5]
			ticket_log += log_entry
		qdel(ticket_lookup_instance)
		ticket_history.ticket_log = ticket_log
		history_cache += ticket_history

	if(!length(history_cache))
		to_chat(usr, span_adminnotice("Brak historii ticketów dla [ckey]."))
		ticket_histories -= ckey
		return

	to_chat(usr, span_adminnotice("Pobrano historię ticketów dla [ckey]."))

/datum/ticket_history_holder/ui_state(mob/user)
	return GLOB.admin_state

/datum/ticket_history_holder/ui_static_data(mob/user)
	if(!check_rights_for(CLIENT_FROM_VAR(user), R_ADMIN))
		return list()

	if(!SSdbcore.IsConnected())
		return list("db_connected" = FALSE)

	var/list/data = list("db_connected" = TRUE)
	var/list/cached_ckeys = list()
	for(var/ckey in ticket_histories)
		cached_ckeys += ckey
	data["cached_ckeys"] = cached_ckeys

	var/target_ckey = user_selections[user.ckey]
	if(target_ckey && (target_ckey in ticket_histories))
		var/list/ticket_cache = list()
		for(var/datum/ticket_history/ticket_history as anything in ticket_histories[target_ckey])
			var/list/ticket_log = list()
			for(var/datum/ticket_log_entry/entry as anything in ticket_history.ticket_log)
				ticket_log += list(list(
					"timestamp" = entry.timestamp,
					"origin_ckey" = entry.origin_ckey,
					"target_ckey" = entry.target_ckey,
					"action" = entry.action,
					"message" = entry.message,
				))
			ticket_cache += list(list(
				"ticket_number" = ticket_history.ticket_number,
				"round_id" = ticket_history.round_id,
				"ticket_log" = ticket_log,
			))
		data["ticket_cache"] = ticket_cache
		data["target_ckey"] = target_ckey

	return data

/datum/ticket_history_holder/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!check_rights(R_ADMIN))
		return

	switch(action)
		if("select-user")
			var/target = params["target"]
			if(!(target in ticket_histories))
				return TRUE
			user_selections[usr.ckey] = target
			update_static_data(usr, ui)
			return TRUE
		if("cache-user")
			var/amount = text2num(params["amount"]) || 5
			cache_history_for_ckey(params["target"], amount)
			update_static_data(usr, ui)
			return TRUE

/datum/ticket_history_holder/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		ui.send_full_update()
		return
	ui = new(user, src, "PlayerTicketHistory")
	ui.set_autoupdate(FALSE)
	ui.open()

/// Otwiera historię ticketów konkretnego gracza
/datum/ticket_history_holder/proc/open_for(mob/user, target_ckey)
	target_ckey = ckey(target_ckey)
	if(!target_ckey)
		return
	if(!(target_ckey in ticket_histories))
		cache_history_for_ckey(target_ckey)
	user_selections[user.ckey] = target_ckey
	ui_interact(user)

// Przycisk HIST w oknie ticketu
/datum/admin_help/ui_act(action, params)
	if(action != "tickethistory")
		return ..()
	if(!check_rights(R_ADMIN))
		return
	GLOB.player_ticket_history.open_for(usr, initiator_ckey)
