// Przeglądarka graczy: gracze z bazy (tabela player) z wyszukiwarką ckey, ich bany u nas i w bazie CentCom, historia ticketów.

/// Wyników na stronę listy graczy
#define PLAYER_BROWSER_PAGE_SIZE 50

/datum/admins
	/// Przeglądarka graczy tego admina (stan wyszukiwania i wybranego gracza)
	var/datum/player_browser/player_browser

/world/AVerbsAdmin()
	. = ..()
	. += /client/proc/player_browser

/client/proc/player_browser()
	set name = "Player Browser"
	set desc = "Gracze, którzy kiedykolwiek grali na serwerze: wyszukiwarka ckey, bany u nas i w CentCom, historia ticketów."
	set category = "Admin"
	if(!check_rights(R_ADMIN))
		return
	if(!holder.player_browser)
		holder.player_browser = new
	holder.player_browser.ui_interact(mob)

/datum/player_browser
	/// Fragment ckey z wyszukiwarki (tylko [a-z0-9], po ckey())
	var/search = ""
	/// Strona listy, od 0
	var/page = 0
	/// Czy jest następna strona
	var/has_next_page = FALSE
	/// Wyniki bieżącej strony
	var/list/players = list()
	/// Wybrany gracz (ckey)
	var/selected_ckey
	/// Dane wybranego gracza z tabeli player
	var/list/selected_info
	/// Nasze bany wybranego gracza
	var/list/bans
	/// Bany wybranego gracza w bazie CentCom (null = jeszcze nie sprawdzono)
	var/list/centcom_bans
	/// Komunikat po sprawdzeniu CentCom (błąd albo brak banów)
	var/centcom_status

/datum/player_browser/New()
	. = ..()
	load_players()

/datum/player_browser/ui_state(mob/user)
	return GLOB.admin_state

/datum/player_browser/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PlayerBrowser")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/player_browser/ui_data(mob/user)
	var/list/data = list()
	data["db_connected"] = SSdbcore.IsConnected()
	data["centcom_enabled"] = !!CONFIG_GET(string/centcom_ban_db)
	data["search"] = search
	data["page"] = page
	data["has_next_page"] = has_next_page
	data["players"] = players
	data["selected_ckey"] = selected_ckey
	data["selected_info"] = selected_info
	data["bans"] = bans
	data["centcom_bans"] = centcom_bans
	data["centcom_status"] = centcom_status
	return data

/datum/player_browser/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!check_rights(R_ADMIN))
		return

	switch(action)
		if("search")
			search = ckey(params["search"])
			page = 0
			load_players()
			return TRUE
		if("page")
			var/new_page = text2num(params["page"])
			if(!isnum(new_page) || new_page < 0 || (new_page > page && !has_next_page))
				return
			page = new_page
			load_players()
			return TRUE
		if("select")
			select_player(params["ckey"])
			return TRUE
		if("centcom")
			if(!selected_ckey)
				return
			load_centcom_bans()
			return TRUE
		if("tickets")
			if(!selected_ckey)
				return
			GLOB.player_ticket_history.open_for(usr, selected_ckey)
			return
		if("unban_panel")
			if(!selected_ckey || !check_rights(R_BAN))
				return
			usr.client.holder.unban_panel(player_key = selected_ckey)
			return

/// Lista graczy z bazy: pasujący do wyszukiwania, od ostatnio widzianych
/datum/player_browser/proc/load_players()
	players = list()
	has_next_page = FALSE
	if(!SSdbcore.Connect())
		return
	// o jeden wynik więcej, żeby wiedzieć, czy jest następna strona
	var/datum/DBQuery/query = SSdbcore.NewQuery({"
		SELECT ckey, byond_key, firstseen, firstseen_round_id, lastseen, lastseen_round_id, lastadminrank
		FROM [format_table_name("player")]
		WHERE ckey LIKE CONCAT('%', :search, '%')
		ORDER BY lastseen DESC
		LIMIT :skip, :take
	"}, list("search" = search, "skip" = page * PLAYER_BROWSER_PAGE_SIZE, "take" = PLAYER_BROWSER_PAGE_SIZE + 1))
	if(!query.warn_execute())
		qdel(query)
		return
	while(query.NextRow())
		if(length(players) >= PLAYER_BROWSER_PAGE_SIZE)
			has_next_page = TRUE
			break
		players += list(list(
			"ckey" = query.item[1],
			"key" = query.item[2],
			"firstseen" = query.item[3],
			"firstseen_round" = query.item[4],
			"lastseen" = query.item[5],
			"lastseen_round" = query.item[6],
			"rank" = query.item[7],
		))
	qdel(query)

/// Wybór gracza: dane z tabeli player i nasze bany (bez ukrytych, jak w panelu odbanowania)
/datum/player_browser/proc/select_player(target_ckey)
	target_ckey = ckey(target_ckey)
	selected_ckey = null
	selected_info = null
	bans = null
	centcom_bans = null
	centcom_status = null
	if(!target_ckey || !SSdbcore.Connect())
		return

	var/datum/DBQuery/query_player = SSdbcore.NewQuery({"
		SELECT ckey, byond_key, firstseen, firstseen_round_id, lastseen, lastseen_round_id, lastadminrank, accountjoindate
		FROM [format_table_name("player")]
		WHERE ckey = :ckey
	"}, list("ckey" = target_ckey))
	if(!query_player.warn_execute())
		qdel(query_player)
		return
	if(query_player.NextRow())
		selected_ckey = target_ckey
		selected_info = list(
			"ckey" = query_player.item[1],
			"key" = query_player.item[2],
			"firstseen" = query_player.item[3],
			"firstseen_round" = query_player.item[4],
			"lastseen" = query_player.item[5],
			"lastseen_round" = query_player.item[6],
			"rank" = query_player.item[7],
			"account_join_date" = query_player.item[8],
			"online" = !!GLOB.directory[target_ckey],
		)
	qdel(query_player)
	if(!selected_ckey)
		return

	// Jeden ban na kilka ról to kilka wierszy z tym samym bantime: łączymy je w jeden wpis
	var/datum/DBQuery/query_bans = SSdbcore.NewQuery({"
		SELECT bantime, round_id, role, expiration_time, reason, a_ckey, unbanned_datetime, unbanned_ckey,
			IF(unbanned_datetime IS NULL AND (expiration_time IS NULL OR expiration_time > NOW()), 1, 0)
		FROM [format_table_name("ban")]
		WHERE ckey = :ckey AND hidden = 0
		ORDER BY bantime DESC, id DESC
		LIMIT 200
	"}, list("ckey" = selected_ckey))
	if(!query_bans.warn_execute())
		qdel(query_bans)
		return
	var/list/bans_by_time = list()
	bans = list()
	while(query_bans.NextRow())
		var/bantime = query_bans.item[1]
		var/list/ban = bans_by_time[bantime]
		if(!ban)
			ban = list(
				"bantime" = bantime,
				"round_id" = query_bans.item[2],
				"roles" = list(),
				"expiration" = query_bans.item[4],
				"reason" = query_bans.item[5],
				"admin" = query_bans.item[6],
				"unbanned" = query_bans.item[7],
				"unbanned_by" = query_bans.item[8],
				"active" = text2num(query_bans.item[9]) == 1,
			)
			bans_by_time[bantime] = ban
			bans += list(ban)
		ban["roles"] += query_bans.item[3]
	qdel(query_bans)

/// Bany wybranego gracza w bazie CentCom (zapytanie HTTP)
/datum/player_browser/proc/load_centcom_bans()
	centcom_bans = null
	centcom_status = null
	var/url = CONFIG_GET(string/centcom_ban_db)
	if(!url)
		centcom_status = "Baza CentCom jest wyłączona w configu."
		return
	var/target_ckey = selected_ckey
	var/datum/http_request/request = new()
	request.prepare(RUSTG_HTTP_METHOD_GET, "[url]/[target_ckey]", "", "")
	request.begin_async()
	UNTIL(request.is_complete())
	if(target_ckey != selected_ckey) // admin wybrał w międzyczasie innego gracza
		return
	var/datum/http_response/response = request.into_response()
	if(response.errored || response.status_code != 200)
		centcom_status = "Nie udało się połączyć z CentCom[response.errored ? "" : " (kod [response.status_code])"]."
		return
	var/list/decoded = json_decode(response.body)
	centcom_bans = list()
	for(var/list/ban in decoded)
		centcom_bans += list(list(
			"server" = ban["sourceName"],
			"rp_level" = ban["sourceRoleplayLevel"],
			"type" = ban["type"],
			"banned_by" = ban["bannedBy"],
			"reason" = ban["reason"],
			"banned_on" = ban["bannedOn"],
			"expires" = ban["expires"],
			"jobs" = islist(ban["jobs"]) ? jointext(ban["jobs"], ", ") : null,
		))
	if(!length(centcom_bans))
		centcom_status = "Brak banów w CentCom."

#undef PLAYER_BROWSER_PAGE_SIZE
