////////////////////////////////
/proc/message_admins(msg)
	msg = "<span class=\"admin\"><span class=\"prefix\">LOG ADMINA:</span> <span class=\"message linkify\">[msg]</span></span>"
	to_chat(GLOB.admins,
		type = MESSAGE_TYPE_ADMINLOG,
		html = msg)

/proc/relay_msg_admins(msg)
	msg = "<span class=\"admin\"><span class=\"prefix\">PRZEKAZ:</span> <span class=\"message linkify\">[msg]</span></span>"
	to_chat(GLOB.admins,
		type = MESSAGE_TYPE_ADMINLOG,
		html = msg)


///////////////////////////////////////////////////////////////////////////////////////////////Panels

/datum/admins/proc/show_player_panel(mob/M in GLOB.mob_list)
	set category = "Admin"
	set name = "Show Player Panel"
	set desc="Edytuj gracza (odrodzenie, ban, leczenie itd.)"

	if(!check_rights())
		return

	log_admin("[key_name(usr)] checked the individual player panel for [key_name(M)][isobserver(usr)?"":" while in game"].")

	if(!M)
		to_chat(usr, "Wygląda na to, że wybierasz moba, który już nie istnieje.")
		return

	// AQUILA EDIT - panel gracza w TGUI (okno "AdminPlayerPanel") zamiast HTML
	// Wołane jako verb src jest klientem, nie /datum/admins, więc listę okien bierzemy z holdera
	var/datum/admins/holder = usr.client.holder
	var/panel_key = REF(M)
	var/datum/admin_player_panel/panel = LAZYACCESS(holder.player_option_panels, panel_key)
	if(!panel)
		panel = new(holder, M)
		LAZYSET(holder.player_option_panels, panel_key, panel)
	panel.refresh_db_values()
	panel.ui_interact(usr)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Player Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins
	/// AQUILA - otwarte okna panelu gracza: REF(mob) -> /datum/admin_player_panel
	var/list/player_option_panels

/// AQUILA - panel opcji admina dla jednego moba (dawne okno "adminplayeropts")
/datum/admin_player_panel
	var/datum/admins/holder
	var/datum/weakref/target_ref
	var/panel_key
	/// Wartości z bazy danych, odświeżane przy otwarciu panelu (nie przy każdej aktualizacji okna)
	var/antag_tokens = 0
	var/metabalance = 0

/datum/admin_player_panel/New(datum/admins/holder, mob/target)
	. = ..()
	src.holder = holder
	target_ref = WEAKREF(target)
	panel_key = REF(target)

/datum/admin_player_panel/Destroy(force)
	if(holder)
		LAZYREMOVE(holder.player_option_panels, panel_key)
	holder = null
	target_ref = null
	return ..()

/datum/admin_player_panel/ui_state(mob/user)
	return GLOB.admin_state

/datum/admin_player_panel/ui_close(mob/user)
	qdel(src)

/datum/admin_player_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AdminPlayerPanel")
		ui.open()

/datum/admin_player_panel/proc/refresh_db_values()
	var/mob/M = target_ref?.resolve()
	if(!M?.client)
		return
	antag_tokens = M.client.get_antag_token_count()
	metabalance = M.client.get_metabalance()

/datum/admin_player_panel/ui_static_data(mob/user)
	var/list/data = list()
	data["mute_types"] = list(
		list("name" = "IC", "flag" = MUTE_IC),
		list("name" = "OOC", "flag" = MUTE_OOC),
		list("name" = "LOOC", "flag" = MUTE_LOOC),
		list("name" = "PRAY", "flag" = MUTE_PRAY),
		list("name" = "ADMINHELP", "flag" = MUTE_ADMINHELP),
		list("name" = "MHELP", "flag" = MUTE_MHELP),
		list("name" = "DEADCHAT", "flag" = MUTE_DEADCHAT),
	)
	return data

/datum/admin_player_panel/ui_data(mob/user)
	var/list/data = list()
	var/mob/M = target_ref?.resolve()
	data["exists"] = !QDELETED(M)
	if(QDELETED(M))
		return data
	data["ref"] = REF(M)
	data["name"] = "[M]"
	data["key"] = M.key
	data["ckey"] = M.ckey
	data["mob_type"] = "[M.type]"
	data["new_player"] = isnewplayer(M)
	data["has_mind"] = !!M.mind
	data["cyborg"] = iscyborg(M)
	data["human_with_mind"] = ishuman(M) && !!M.mind
	data["is_human"] = ishuman(M)
	data["is_monkey"] = ismonkey(M)
	data["is_corgi"] = iscorgi(M)
	data["is_ai"] = isAI(M)
	data["is_cluwne"] = istype(M, /mob/living/simple_animal/cluwne)
	data["is_animal"] = isanimal(M)

	var/client/C = M.client
	data["has_client"] = !!C
	data["log_src"] = C ? LOGSRC_CLIENT : LOGSRC_MOB
	if(!C)
		return data
	data["client_name"] = "[C]"
	data["rank"] = C.holder ? (C.holder.rank?.name || "?") : "Gracz"
	data["is_admin"] = !!(GLOB.admin_datums[C.ckey] || GLOB.deadmins[C.ckey])
	data["playtime"] = CONFIG_GET(flag/use_exp_tracking) ? C.get_exp_living() : null
	data["join_date"] = C.player_join_date
	data["account_join_date"] = C.account_join_date
	data["telemetry"] = get_telemetry_data(C)
	data["centcom_db"] = !!CONFIG_GET(string/centcom_ban_db)
	data["antag_rep"] = SSpersistence.antag_rep[M.ckey] || 0
	data["antag_tokens"] = antag_tokens
	data["metacurrency_name"] = CONFIG_GET(string/metacurrency_name)
	data["metabalance"] = metabalance
	data["byond_version"] = C.byond_version ? "[C.byond_version].[C.byond_build ? C.byond_build : "xxx"]" : "Nieznana"
	data["muted"] = C.prefs?.muted || 0
	return data

/// Stan telemetrii klienta jako zwykły tekst (dawniej HTML z show_notices())
/datum/admin_player_panel/proc/get_telemetry_data(client/C)
	var/list/telemetry = list()
	var/datum/tgui_panel/panel = C.tgui_panel
	if(!panel)
		telemetry["status"] = "Czat gracza się nie załadował, zgłoś to koderom."
		telemetry["bad"] = TRUE
		return telemetry
	telemetry["bad"] = FALSE
	switch(panel.telemetry_status)
		if(TGUI_TELEMETRY_STAT_NOT_REQUESTED)
			telemetry["status"] = "Nie wysłano zapytania o telemetrię. Zgłoś to koderom."
			telemetry["bad"] = TRUE
		if(TGUI_TELEMETRY_STAT_AWAITING)
			telemetry["status"] = "Oczekiwanie na telemetrię."
		if(TGUI_TELEMETRY_STAT_ANALYZED, TGUI_TELEMETRY_STAT_OVERSEND)
			telemetry["status"] = "Przeanalizowano."
		if(TGUI_TELEMETRY_STAT_MISSING)
			telemetry["status"] = "Brak danych telemetrii!"
			telemetry["bad"] = TRUE
		else
			telemetry["status"] = "Nieprawidłowy stan telemetrii ([panel.telemetry_status]). Zgłoś to koderom."
			telemetry["bad"] = TRUE
	var/static/regex/html_tags = regex(@"<[^>]*>", "g")
	var/list/notices = list()
	for(var/notice in panel.telemetry_notices)
		var/notice_text = panel.telemetry_notices[notice]
		notices += list(list(
			"text" = replacetext(notice_text, html_tags, ""),
			"bad" = !!findtext(notice_text, "'bad'"),
		))
	telemetry["notices"] = notices
	return telemetry

/// Dawne linki panelu, które przyjmują tylko REF(moba)
GLOBAL_LIST_INIT(admin_player_panel_mob_commands, list(
	"revive", "getplaytimewindow", "initmind", "traitor", "borgpanel", "subtlemessage", "HeadsetMessage",
	"adminplayerobservefollow", "boot2", "sendtoprison", "sendbacktolobby", "jumpto", "getmob", "sendmob",
	"narrateto", "languagemenu", "humanone", "monkeyone", "corgione", "makeai", "makepai", "makerobot",
	"makealien", "makeslime", "makeblob", "makecluwne", "makeanimal", "forcespeech", "tdome1", "tdome2",
	"tdomeadmin", "tdomeobserve",
))

/// Dozwolone typy dla "simplemake"
GLOBAL_LIST_INIT(admin_player_panel_simplemake, list(
	"observer", "human", "monkey", "robot", "cat", "runtime", "corgi", "ian", "crab", "coffee", "shade",
	"slime", "adultslime", "drone", "hunter", "sentinel", "praetorian", "queen", "larva",
	"constructarmored", "constructbuilder", "constructwraith",
))

/datum/admin_player_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!check_rights(R_ADMIN))
		return
	var/mob/M = target_ref?.resolve()
	if(QDELETED(M))
		return
	var/mob_ref = REF(M)
	var/client/C = M.client

	if(action in GLOB.admin_player_panel_mob_commands)
		holder.ui_topic(list("[action]" = mob_ref))
		return TRUE

	switch(action)
		if("vv")
			usr.client.debug_variables(M)
			return
		if("pm")
			usr.client.cmd_admin_pm(M.ckey, null)
			return
		if("logs")
			holder.ui_topic(list("individuallog" = mob_ref, "log_src" = C ? LOGSRC_CLIENT : LOGSRC_MOB))
			return
		if("notes")
			holder.ui_topic(list("showmessageckey" = M.ckey))
			return
		if("editrights")
			if(!C)
				return
			holder.ui_topic(list("editrights" = (GLOB.admin_datums[C.ckey] || GLOB.deadmins[C.ckey]) ? "rank" : "add", "key" = M.key))
			return TRUE
		if("centcomlookup")
			if(!C)
				return
			holder.ui_topic(list("centcomlookup" = C.ckey))
			return
		if("relatedacc")
			if(!C || !(params["type"] in list("cid", "ip")))
				return
			holder.ui_topic(list("showrelatedacc" = params["type"], "client" = REF(C)))
			return
		if("modvalue")
			if(!C)
				return
			var/operation = params["operation"]
			if(!(operation in list("add", "subtract", "set", "zero")))
				return
			var/command
			switch(params["value"])
				if("antagrep")
					command = "modantagrep"
				if("antagtokens")
					command = "modantagtokens"
				if("metacoins")
					command = "modmetacoins"
			if(!command)
				return
			holder.ui_topic(list("[command]" = operation, "mob" = mob_ref))
			return TRUE
		if("ban")
			if(C)
				holder.ui_topic(list("newbankey" = M.key, "newbanip" = C.address, "newbancid" = C.computer_id))
			else
				holder.ui_topic(list("newbankey" = M.key))
			return
		if("mute")
			if(!C)
				return
			holder.ui_topic(list("mute" = M.ckey, "mute_type" = "[text2num("[params["flag"]]")]"))
			return TRUE
		if("simplemake")
			if(!(params["type"] in GLOB.admin_player_panel_simplemake))
				return
			holder.ui_topic(list("simplemake" = params["type"], "mob" = mob_ref))
			return TRUE


// AQ EDIT - port BeeStation #7779: access_news_network() is the TGUI admin newscaster in aquila/code/modules/admin/verbs/admin_newscaster.dm

// AQUILA EDIT - Game Panel w TGUI (okno "AdminGamePanel"); łączy dawne okna Game Panel, wyboru trybu (c_mode),
// wymuszenia trybu w secret (f_secret) i opcji trybu dynamic. Przyciski wywołują dotychczasowe gałęzie Topic().
/datum/admins/proc/Game()
	if(!check_rights(0))
		return
	if(!game_panel_ui)
		game_panel_ui = new(src)
	game_panel_ui.ui_interact(usr)

/datum/admins
	/// AQUILA - okno TGUI Game Panelu
	var/datum/admin_game_panel/game_panel_ui

/datum/admin_game_panel
	var/datum/admins/holder

/datum/admin_game_panel/New(datum/admins/holder)
	. = ..()
	src.holder = holder

/datum/admin_game_panel/Destroy(force)
	if(holder?.game_panel_ui == src)
		holder.game_panel_ui = null
	holder = null
	return ..()

/datum/admin_game_panel/ui_state(mob/user)
	return get_admin_state(0)

/datum/admin_game_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AdminGamePanel")
		ui.open()

/datum/admin_game_panel/ui_data(mob/user)
	var/list/data = list()
	data["master_mode"] = GLOB.master_mode
	data["secret_force_mode"] = GLOB.secret_force_mode
	data["round_started"] = SSticker.HasRoundStarted()
	data["round_in_progress"] = SSticker.IsRoundInProgress()
	data["pregame"] = SSticker.current_state <= GAME_STATE_PREGAME
	data["hotswap_disabled"] = !!SSticker.gamemode_hotswap_disabled

	var/list/modes = list()
	for(var/mode in config.modes)
		modes += list(list("id" = mode, "name" = config.mode_names[mode]))
	data["modes"] = modes

	var/is_dynamic = SSticker.is_mode("dynamic")
	data["is_dynamic"] = is_dynamic
	if(is_dynamic)
		var/list/forced_roundstart = list()
		for(var/datum/dynamic_ruleset/roundstart/rule in GLOB.dynamic_forced_roundstart_ruleset)
			forced_roundstart += list(list("name" = rule.name, "ref" = REF(rule)))
		data["forced_roundstart"] = forced_roundstart
		var/datum/game_mode/dynamic/mode = SSticker.mode
		data["forced_latejoin"] = istype(mode) ? mode.forced_latejoin_rule?.name : null
		data["forced_extended"] = GLOB.dynamic_forced_extended
		data["no_stacking"] = GLOB.dynamic_no_stacking
		data["stacking_limit"] = GLOB.dynamic_stacking_limit
		data["forced_threat"] = GLOB.dynamic_forced_threat_level

	data["marked_atom"] = isatom(holder.marked_datum)
	return data

/datum/admin_game_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/static/list/simple_commands = list(
		"f_dynamic_roundstart", "f_dynamic_roundstart_clear", "f_dynamic_latejoin", "f_dynamic_latejoin_clear",
		"f_dynamic_midround", "f_dynamic_force_extended", "f_dynamic_no_stacking", "f_dynamic_stacking_limit",
		"f_dynamic_forced_threat", "gamemode_panel", "create_object", "quick_create_object", "create_turf",
		"create_mob", "dupe_marked_datum",
	)
	if(action in simple_commands)
		holder.ui_topic(list("[action]" = "1"))
		return TRUE
	switch(action)
		if("set_mode")
			var/mode = params["mode"]
			if(!(mode in config.modes) && !(mode in list("secret", "random", "weighted")))
				return
			holder.ui_topic(list("c_mode2" = mode))
			return TRUE
		if("force_secret")
			var/mode = params["mode"]
			if(!(mode in config.modes) && mode != "secret")
				return
			holder.ui_topic(list("f_secret2" = mode))
			return TRUE
		if("remove_roundstart")
			holder.ui_topic(list("f_dynamic_roundstart_remove" = params["ref"]))
			return TRUE

/////////////////////////////////////////////////////////////////////////////////////////////////admins2.dm merge
//i.e. buttons/verbs


/datum/admins/proc/restart()
	set category = "Server"
	set name = "Reboot World"
	set desc="Natychmiast restartuje świat gry"
	if (!usr.client.holder)
		return

	var/list/options = list("Zwykły restart", "Zwykły restart (z opóźnieniem)", "Twardy restart (bez opóźnienia i powodu)", "Najtwardszy restart (bez akcji, sam reboot)")
	if(world.TgsAvailable())
		options += "Restart serwera (zabij i uruchom DD)";
	if(check_rights(R_SERVER, FALSE))
		options += "Twardy restart + nowa kampania" // AQUILA EDIT - resets the persistent starmap, see aquila/code/modules/admin/campaign_reset.dm

	var/rebootconfirm
	if(SSticker.admin_delay_notice)
		if(alert(usr, "Na pewno? Admin już opóźnił koniec rundy z następującego powodu: [SSticker.admin_delay_notice]", "Potwierdzenie", "Tak", "Nie") == "Tak")
			rebootconfirm = TRUE
	else
		rebootconfirm = TRUE
	if(rebootconfirm)
		var/result = input(usr, "Wybierz sposób restartu", "Restart świata", options[1]) as null|anything in options
		if(result)
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Reboot World") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
			var/init_by = "Restart zlecił: [usr.client.holder.fakekey ? "Admin" : usr.key]."
			switch(result)
				if("Zwykły restart")
					SSticker.Reboot(init_by, "admin reboot - by [usr.key] [usr.client.holder.fakekey ? "(stealth)" : ""]", 10)
				if("Zwykły restart (z opóźnieniem)")
					var/delay = input("Jakie opóźnienie ma mieć restart (w sekundach)?", "Opóźnienie restartu", 5) as num|null
					if(!delay)
						return FALSE
					SSticker.Reboot(init_by, "admin reboot - by [usr.key] [usr.client.holder.fakekey ? "(stealth)" : ""]", delay * 10)
				if("Twardy restart (bez opóźnienia i powodu)")
					to_chat(world, "Restart świata – [init_by]")
					world.Reboot()
				if("Najtwardszy restart (bez akcji, sam reboot)")
					to_chat(world, "Twardy restart świata – [init_by]")
					world.Reboot(fast_track = TRUE)
				if("Twardy restart + nowa kampania") // AQUILA EDIT
					usr.client.holder.hard_restart_new_campaign(init_by) // verbs run with the client as src, so go through the holder
				if("Restart serwera (zabij i uruchom DD)")
					to_chat(world, "Restart serwera – [init_by]")
					world.TgsEndProcess()

/datum/admins/proc/end_round()
	set category = "Round"
	set name = "End Round"
	set desc = "Próbuje wygenerować raport z końca rundy, a potem normalnie zrestartować serwer."

	if (!usr.client.holder)
		return
	var/confirm = alert("Zakończyć rundę i zrestartować świat gry?", "Koniec rundy", "Tak", "Anuluj")
	if(confirm != "Tak")
		return
	SSticker.force_ending = 1
	SSblackbox.record_feedback("tally", "admin_verb", 1, "End Round") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/dynamic_mode_options(mob/user)
	// AQUILA EDIT - opcje trybu dynamic są teraz sekcją Game Panelu (TGUI)
	Game()

/datum/admins/proc/announce()
	set category = "Admin"
	set name = "Announce"
	set desc="Ogłoś swoje życzenia całemu światu"
	if(!check_rights(0))
		return

	var/message = capped_multiline_input(usr, "Wiadomość globalna do wysłania:", "Ogłoszenie admina")
	if(message)
		if(!check_rights(R_SERVER,0))
			message = adminscrub(message,500)
		to_chat(world, "<span class='adminnotice'><b>[usr.client.holder.fakekey ? "Administrator" : usr.key] ogłasza:</b></span>\n \t [message]")
		log_admin("Announce: [key_name(usr)] : [message]")
		discordsendmsg("ooc", "***[usr.client.holder.fakekey ? "Administrator" : usr.key] ogłasza:***\n       [message]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Announce") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/set_admin_notice()
	set category = "Adminbus"
	set name = "Set Admin Notice"
	set desc ="Ustaw ogłoszenie, które zobaczy każdy, kto dołączy do serwera. Działa tylko w tej rundzie"
	if(!check_rights(0))
		return

	var/new_admin_notice = capped_multiline_input(usr, "Ustaw publiczne ogłoszenie na tę rundę. Zobaczy je każdy, kto dołączy do serwera.\n(Puste pole usunie obecne ogłoszenie):","Ogłoszenie",GLOB.admin_notice)
	if(new_admin_notice == null)
		return
	if(new_admin_notice == GLOB.admin_notice)
		return
	if(new_admin_notice == "")
		message_admins("[key_name(usr)] usuwa ogłoszenie admina.")
		log_admin("[key_name(usr)] removed the admin notice:\n[GLOB.admin_notice]")
	else
		message_admins("[key_name(usr)] ustawia ogłoszenie admina.")
		log_admin("[key_name(usr)] set the admin notice:\n[new_admin_notice]")
		to_chat(world, "<span class ='adminnotice'><b>Ogłoszenie admina:</b>\n \t [new_admin_notice]</span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Set Admin Notice") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	GLOB.admin_notice = new_admin_notice
	return

/datum/admins/proc/toggleooc()
	set category = "Server"
	set desc="Przełącz to cholerstwo"
	set name="Toggle OOC"
	toggle_ooc()
	log_admin("[key_name(usr)] toggled OOC.")
	message_admins("[key_name_admin(usr)] przełącza OOC.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle OOC", "[GLOB.ooc_allowed ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/togglelooc() //nsv13
	set category = "Server"
	set desc="Jeśli widzisz ten komunikat po próbie użycia LOOC, wiń BYOND-a; LOOC jest wyłączone."
	set name="Toggle LOOC"
	toggle_looc()
	log_admin("[key_name(usr)] toggled LOOC.")
	message_admins("[key_name_admin(usr)] [GLOB.looc_allowed ? "włącza" : "wyłącza"] LOOC.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle LOOC", "[GLOB.looc_allowed ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleoocdead()
	set category = "Server"
	set desc="Przełącz to cholerstwo"
	set name="Toggle Dead OOC"
	toggle_dooc()

	log_admin("[key_name(usr)] toggled OOC.")
	message_admins("[key_name_admin(usr)] przełącza OOC martwych.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Dead OOC", "[GLOB.dooc_allowed ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/startnow()
	set category = "Round"
	set desc="Wystartuj rundę NATYCHMIAST"
	set name="Start Now"
	if(SSticker.current_state == GAME_STATE_PREGAME || SSticker.current_state == GAME_STATE_STARTUP)
		SSticker.start_immediately = TRUE
		log_admin("[usr.key] has started the game.")
		var/msg = ""
		if(SSticker.current_state == GAME_STATE_STARTUP)
			msg = " (Serwer wciąż się przygotowuje, ale runda wystartuje najszybciej, jak to możliwe.)"
		message_admins("<font color='blue'>\
			[usr.key] startuje grę.[msg]</font>")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Start Now") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return 1
	else
		to_chat(usr, "<font color='red'>Błąd: Start teraz: gra już się zaczęła.</font>")

	return 0

/datum/admins/proc/toggleenter()
	set category = "Server"
	set desc="Gracze nie mogą dołączać"
	set name="Toggle Entering"
	GLOB.enter_allowed = !( GLOB.enter_allowed )
	if (!( GLOB.enter_allowed ))
		to_chat(world, "<B>Nowi gracze nie mogą już dołączać do gry.</B>")
	else
		to_chat(world, "<B>Nowi gracze mogą teraz dołączać do gry.</B>")
	log_admin("[key_name(usr)] toggled new player game entering.")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] przełącza dołączanie nowych graczy.</span>")
	world.update_status()
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Entering", "[GLOB.enter_allowed ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleAI()
	set category = "Server"
	set desc="Gracze nie mogą być SI"
	set name="Toggle AI"
	var/alai = CONFIG_GET(flag/allow_ai)
	CONFIG_SET(flag/allow_ai, !alai)
	if (alai)
		to_chat(world, "<B>Stanowiska SI nie można już wybrać.</B>")
	else
		to_chat(world, "<B>Stanowisko SI można teraz wybrać.</B>")
	log_admin("[key_name(usr)] toggled AI allowed.")
	world.update_status()
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle AI", "[!alai ? "Disabled" : "Enabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleaban()
	set category = "Server"
	set desc="Po prostu odradzanie"
	set name="Toggle Respawn"
	var/new_nores = !CONFIG_GET(flag/norespawn)
	CONFIG_SET(flag/norespawn, new_nores)
	if (!new_nores)
		to_chat(world, "<B>Możesz się teraz odrodzić.</B>")
	else
		to_chat(world, "<B>Nie możesz się już odrodzić :(</B>")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] [!new_nores ? "włącza" : "wyłącza"] odradzanie.</span>")
	log_admin("[key_name(usr)] toggled respawn to [!new_nores ? "On" : "Off"].")
	world.update_status()
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Respawn", "[!new_nores ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/delay()
	set category = "Round"
	set desc="Opóźnij start gry"
	set name="Delay pre-game"

	var/newtime = input("Ustaw nowy czas w sekundach. -1 oznacza opóźnienie bez końca.","Opóźnienie",round(SSticker.GetTimeLeft()/10)) as num|null
	if(SSticker.current_state > GAME_STATE_PREGAME)
		return alert("Za późno... Gra już się zaczęła!")
	if(newtime)
		newtime = newtime*10
		SSticker.SetTimeLeft(newtime)
		if(newtime < 0)
			to_chat(world, "<b>Start gry został opóźniony.</b>")
			log_admin("[key_name(usr)] delayed the round start.")
		else
			to_chat(world, "<b>Gra wystartuje za [DisplayTimeText(newtime)].</b>")
			SEND_SOUND(world, sound('sound/ai/default/attention.ogg'))
			log_admin("[key_name(usr)] set the pre-game delay to [DisplayTimeText(newtime)].")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Delay Game Start") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/delay_round_end()
	set category = "Round"
	set desc= "Wstrzymaj restart serwera po końcu rundy"
	set name= "Delay round end"
	if(!SSticker.delay_end)
		SSticker.admin_delay_notice = input(usr, "Podaj powód opóźnienia końca rundy", "Powód opóźnienia rundy") as null|text
		if(isnull(SSticker.admin_delay_notice))
			return
		for(var/client/admin in GLOB.admins)
			if(check_rights(R_FUN) && !GLOB.battle_royale && admin.tgui_panel && SSticker.current_state == GAME_STATE_FINISHED)
				admin.tgui_panel.give_br_popup()
	else
		if(alert(usr, "Na pewno anulować obecne opóźnienie końca rundy? Powód obecnego opóźnienia: \"[SSticker.admin_delay_notice]\"", "Anulowanie opóźnienia", "Tak", "Nie") != "Tak")
			return
		SSticker.admin_delay_notice = null
	SSticker.delay_end = !SSticker.delay_end
	var/reason = SSticker.delay_end ? "for reason: [SSticker.admin_delay_notice]" : "."//laziness
	var/msg = "[SSticker.delay_end ? "delayed" : "undelayed"] the round end [reason]"
	log_admin("[key_name(usr)] [msg]")
	message_admins("[key_name_admin(usr)] [SSticker.delay_end ? "opóźnia koniec rundy, powód: [SSticker.admin_delay_notice]" : "anuluje opóźnienie końca rundy."]")
	if(SSticker.ready_for_reboot && !SSticker.delay_end) //we undelayed after standard reboot would occur
		SSticker.standard_reboot()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Delay round end") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/unprison(mob/M in GLOB.mob_list)
	set category = "Admin"
	set name = "Unprison"
	if (is_centcom_level(M.z))
		SSjob.SendToLateJoin(M)
		message_admins("[key_name_admin(usr)] wypuszcza z więzienia: [key_name_admin(M)]")
		log_admin("[key_name(usr)] has unprisoned [key_name(M)]")
	else
		alert("[M.name] nie jest w więzieniu.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Unprison") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

////////////////////////////////////////////////////////////////////////////////////////////////ADMIN HELPER PROCS

/datum/admins/proc/spawn_atom(object as text)
	set category = "Debug"
	set desc = "(ścieżka atomu) Stwórz atom"
	set name = "Spawn"

	if(!check_rights(R_SPAWN))
		return

	// AQUILA EDIT - bez jednoznacznego dopasowania otwiera wyszukiwarkę TGUI (SpawnSearch z tg) zamiast długiej listy input()
	var/search = trim("[object]")
	var/list/matches = length(search) ? filter_fancy_list(get_fancy_list_of_atom_types(), search) : list()
	if(length(matches) != 1)
		// Wołane jako verb src jest klientem, nie /datum/admins
		usr.client.holder.open_spawn_menu(usr, search)
		return
	var/chosen = matches[matches[1]]
	if(!chosen)
		return
	var/turf/T = get_turf(usr)

	if(ispath(chosen, /turf))
		T.ChangeTurf(chosen)
	else
		var/atom/A = new chosen(T)
		A.flags_1 |= ADMIN_SPAWNED_1

	log_admin("[key_name(usr)] spawned [chosen] at [AREACOORD(usr)]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Spawn Atom") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/podspawn_atom(object as text)
	set category = "Debug"
	set desc = "(ścieżka atomu) Stwórz atom w kapsule zaopatrzeniowej"
	set name = "Podspawn"

	if(!check_rights(R_SPAWN))
		return

	var/chosen = pick_closest_path(object)
	if(!chosen)
		return
	var/turf/T = get_turf(usr)

	if(ispath(chosen, /turf))
		T.ChangeTurf(chosen)
	else
		var/obj/structure/closet/supplypod/centcompod/pod = new()
		var/atom/A = new chosen(pod)
		A.flags_1 |= ADMIN_SPAWNED_1
		new /obj/effect/pod_landingzone(T, pod)

	log_admin("[key_name(usr)] pod-spawned [chosen] at [AREACOORD(usr)]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Podspawn Atom") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/spawn_cargo(object as text)
	set category = "Debug"
	set desc = "(ścieżka atomu) Stwórz skrzynię zaopatrzenia"
	set name = "Spawn Cargo"

	if(!check_rights(R_SPAWN))
		return

	var/chosen = pick_closest_path(object, make_types_fancy(subtypesof(/datum/supply_pack)))
	if(!chosen)
		return
	var/datum/supply_pack/S = new chosen
	S.admin_spawned = TRUE
	S.generate(get_turf(usr))

	log_admin("[key_name(usr)] spawned cargo pack [chosen] at [AREACOORD(usr)]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Spawn Cargo") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/admins/proc/show_traitor_panel(mob/M in GLOB.mob_list)
	set category = "Admin"
	set desc = "Edytuj pamięć i rolę moba"
	set name = "Show Traitor Panel"

	if(!istype(M))
		to_chat(usr, "Można tego użyć tylko na instancjach typu /mob")
		return
	if(!M.mind)
		to_chat(usr, "Ten mob nie ma umysłu!")
		return

	M.mind.traitor_panel()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Traitor Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/datum/admins/proc/toggletintedweldhelmets()
	set category = "Debug"
	set desc="Zmniejsza pole widzenia w maskach spawalniczych"
	set name="Toggle tinted welding helmes"
	GLOB.tinted_weldhelh = !( GLOB.tinted_weldhelh )
	if (GLOB.tinted_weldhelh)
		to_chat(world, "<B>Przyciemnienie masek spawalniczych włączone!</B>")
	else
		to_chat(world, "<B>Przyciemnienie masek spawalniczych wyłączone!</B>")
	log_admin("[key_name(usr)] toggled tinted_weldhelh.")
	message_admins("[key_name_admin(usr)] przełącza tinted_weldhelh.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Tinted Welding Helmets", "[GLOB.tinted_weldhelh ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/toggleguests()
	set category = "Server"
	set desc="Goście nie mogą dołączać"
	set name="Toggle guests"
	var/new_guest_ban = !CONFIG_GET(flag/guest_ban)
	CONFIG_SET(flag/guest_ban, new_guest_ban)
	if (new_guest_ban)
		to_chat(world, "<B>Goście nie mogą już dołączać do gry.</B>")
	else
		to_chat(world, "<B>Goście mogą teraz dołączać do gry.</B>")
	log_admin("[key_name(usr)] toggled guests game entering [!new_guest_ban ? "" : "dis"]allowed.")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] [!new_guest_ban ? "zezwala" : "zabrania"] gościom dołączać do gry.</span>")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Guests", "[!new_guest_ban ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/admins/proc/output_ai_laws()
	var/ai_number = 0
	for(var/i in GLOB.silicon_mobs)
		var/mob/living/silicon/S = i
		ai_number++
		var/message = ""
		if(isAI(S))
			message += "<b>Prawa SI [key_name(S, usr)]:</b>"
		else if(iscyborg(S))
			var/mob/living/silicon/robot/R = S
			message += "<b>CYBORG [key_name(S, usr)] [R.connected_ai?"(podległy: [key_name(R.connected_ai)])":"(niezależny)"]: prawa:</b>"
		else if (ispAI(S))
			message += "<b>Prawa pAI [key_name(S, usr)]:</b>"
		else
			message += "<b>Prawa JAKIEGOŚ SILICONA [key_name(S, usr)]:</b>"

		message += "<br>"

		if (S.laws == null)
			message += "Prawa [key_name(S, usr)] są puste (null)?? Zgłoś to koderom."
		else
			message += jointext(S.laws.get_law_list(include_zeroth = TRUE), "<br>")

		to_chat(usr, message)

	if(!ai_number)
		to_chat(usr, "<b>Nie znaleziono SI</b>" )

/// AQUILA - panel praw SI dla adminów (port Lawpanel z tg), zastępuje wypisywanie praw na czat w "Check AI Laws"
/datum/law_panel

/datum/law_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Lawpanel")
		ui.open()

/datum/law_panel/ui_state(mob/user)
	return GLOB.admin_state

/datum/law_panel/ui_close(mob/user)
	qdel(src)

/datum/law_panel/proc/log_panel_change(mob/user, message)
	log_law("[key_name(user)] [message]")
	log_admin("[key_name(user)] [message]")
	message_admins("[key_name_admin(user)] [message]")

/datum/law_panel/proc/law_list_for_type(datum/ai_laws/lawset, lawtype)
	switch(lawtype)
		if(LAW_DEVIL)
			return lawset.devillaws
		if(LAW_HACKED)
			return lawset.hacked
		if(LAW_ION)
			return lawset.ion
		if(LAW_INHERENT)
			return lawset.inherent
		if(LAW_SUPPLIED)
			return lawset.supplied

/datum/law_panel/proc/add_law_helper(mob/user, mob/living/silicon/borgo)
	var/list/lawtypes = list(LAW_ZEROTH, LAW_HACKED, LAW_ION, LAW_INHERENT, LAW_SUPPLIED) // in order of priority
	var/lawtype = tgui_input_list(user, "Wybierz rodzaj prawa", "Rodzaj prawa", lawtypes)
	if(isnull(lawtype))
		return FALSE
	var/lawtext = tgui_input_text(user, "Wpisz treść prawa", "Treść prawa")
	if(!lawtext)
		return FALSE
	if(QDELETED(src) || QDELETED(borgo))
		return FALSE
	borgo.laws_sanity_check()
	switch(lawtype)
		if(LAW_ZEROTH)
			if(borgo.laws.zeroth)
				if(tgui_alert(user, "Ta jednostka ma już prawo zerowe, nowe je zastąpi. Na pewno?", "Zastąpienie prawa zerowego", list("Tak", "Nie")) != "Tak")
					return FALSE
				if(QDELETED(src) || QDELETED(borgo))
					return FALSE
			borgo.laws.set_zeroth_law(lawtext)
		if(LAW_HACKED)
			borgo.laws.add_hacked_law(lawtext)
		if(LAW_ION)
			borgo.laws.add_ion_law(lawtext)
		if(LAW_INHERENT)
			borgo.laws.add_inherent_law(lawtext)
		if(LAW_SUPPLIED)
			borgo.laws.supplied += lawtext // Just goes to the end of the list
	log_panel_change(user, "has UPLOADED a [lawtype] law to [key_name(borgo)] stating: [lawtext]")
	return TRUE

/datum/law_panel/proc/move_law_helper(mob/user, mob/living/silicon/borgo, direction, law)
	var/list/relevant_laws = borgo.laws.inherent
	var/lawindex = relevant_laws.Find(law)
	if(!lawindex)
		to_chat(user, "<span class='danger'>Coś poszło nie tak, nie udało się przesunąć prawa.</span>")
		return FALSE
	switch(direction)
		if("up")
			if(lawindex == 1)
				return FALSE
			relevant_laws.Swap(lawindex - 1, lawindex)
		if("down")
			if(lawindex == length(relevant_laws))
				return FALSE
			relevant_laws.Swap(lawindex + 1, lawindex)
		else
			return FALSE
	log_panel_change(user, "has MOVED a [LAW_INHERENT] law for [key_name(borgo)] [direction]. LAW: [law]")
	return TRUE

/datum/law_panel/proc/edit_law_text_helper(mob/user, mob/living/silicon/borgo, lawtype, oldlaw)
	var/newlaw = tgui_input_text(user, "Zmień treść prawa.", "Edycja prawa", oldlaw)
	if(!newlaw || QDELETED(src) || QDELETED(borgo))
		return FALSE
	if(lawtype == LAW_ZEROTH)
		borgo.laws.set_zeroth_law(newlaw)
	else
		var/list/relevant_laws = law_list_for_type(borgo.laws, lawtype)
		var/lawindex = relevant_laws ? relevant_laws.Find(oldlaw) : 0
		if(!lawindex)
			to_chat(user, "<span class='danger'>Coś poszło nie tak, nie udało się zmienić prawa.</span>")
			return FALSE
		relevant_laws[lawindex] = newlaw
	log_panel_change(user, "has EDITED [key_name(borgo)] [lawtype] law. OLD LAW: [oldlaw] NEW LAW: [newlaw]")
	return TRUE

/datum/law_panel/proc/remove_law_helper(mob/user, mob/living/silicon/borgo, lawtype, law)
	if(lawtype == LAW_ZEROTH)
		borgo.laws.clear_zeroth_law(TRUE)
	else
		var/list/relevant_laws = law_list_for_type(borgo.laws, lawtype)
		if(!relevant_laws || !(law in relevant_laws))
			return FALSE
		relevant_laws -= law
	log_panel_change(user, "has REMOVED a [lawtype] law from [key_name(borgo)]. LAW: [law]")
	return TRUE

/// Po zmianie praw SI synchronizuje podłączone cyborgi
/datum/law_panel/proc/sync_laws(mob/living/silicon/borgo)
	if(!isAI(borgo))
		return
	var/mob/living/silicon/ai/ai = borgo
	for(var/mob/living/silicon/robot/R as anything in ai.connected_robots)
		if(R.lawupdate)
			R.lawsync()

/datum/law_panel/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(!check_rights(R_ADMIN))
		qdel(src)
		return FALSE

	var/mob/living/silicon/borgo
	if(params["ref"])
		borgo = locate(params["ref"]) in GLOB.silicon_mobs
	if(QDELETED(borgo))
		to_chat(usr, "<span class='danger'>Ta jednostka już nie istnieje.</span>")
		return TRUE

	switch(action)
		if("force_state_laws")
			INVOKE_ASYNC(borgo, TYPE_PROC_REF(/mob/living/silicon, statelaws), TRUE)
			return FALSE
		if("announce_law_changes")
			borgo.show_laws()
			return FALSE
		if("laws_updated_alert")
			borgo.post_lawchange(TRUE)
			return FALSE
		if("give_law_datum")
			borgo.make_laws()
			return TRUE
		if("add_law")
			. = add_law_helper(usr, borgo)
		if("remove_law")
			. = remove_law_helper(usr, borgo, params["lawtype"], params["law"])
		if("move_law")
			. = move_law_helper(usr, borgo, params["direction"], params["law"])
		if("edit_law_text")
			. = edit_law_text_helper(usr, borgo, params["lawtype"], params["law"])

	if(. && !QDELETED(borgo))
		sync_laws(borgo)

/datum/law_panel/ui_data(mob/user)
	var/list/data = list()
	var/list/all_silicons = list()
	for(var/mob/living/silicon/borgo as anything in GLOB.silicon_mobs)
		var/list/borg_information = list()
		if(iscyborg(borgo))
			var/mob/living/silicon/robot/cyborg = borgo
			if(cyborg.shell)
				continue
			borg_information["master_ai"] = cyborg.connected_ai?.real_name
			borg_information["borg_synced"] = cyborg.lawupdate
			borg_information["borg_type"] = "Cyborg"
		else if(isAI(borgo))
			borg_information["borg_type"] = "SI"
		else if(ispAI(borgo))
			borg_information["borg_type"] = "pAI"
		else
			borg_information["borg_type"] = "Nieznany"

		borg_information["borg_name"] = borgo.real_name
		borg_information["ref"] = REF(borgo)

		var/datum/ai_laws/lawset = borgo.laws
		if(isnull(lawset))
			borg_information["laws"] = null
		else
			var/list/borg_laws = list()
			for(var/law in lawset.devillaws)
				borg_laws += list(list("lawtype" = LAW_DEVIL, "law" = law, "num" = 666))
			if(lawset.zeroth)
				borg_laws += list(list("lawtype" = LAW_ZEROTH, "law" = lawset.zeroth, "num" = 0))
			for(var/law in lawset.hacked)
				if(length(law))
					borg_laws += list(list("lawtype" = LAW_HACKED, "law" = law, "num" = -1))
			for(var/law in lawset.ion)
				if(length(law))
					borg_laws += list(list("lawtype" = LAW_ION, "law" = law, "num" = -1))
			var/lawnum = 1
			for(var/law in lawset.inherent)
				borg_laws += list(list("lawtype" = LAW_INHERENT, "law" = law, "num" = lawnum))
				lawnum += 1
			for(var/law in lawset.supplied)
				if(length(law)) // Supplied is full of a bunch of empties
					borg_laws += list(list("lawtype" = LAW_SUPPLIED, "law" = law, "num" = lawnum))
					lawnum += 1
			borg_information["laws"] = borg_laws

		all_silicons += list(borg_information)

	data["all_silicons"] = all_silicons
	return data

/datum/admins/proc/output_all_devil_info()
	var/devil_number = 0
	for(var/datum/mind/D in SSticker.mode.devils)
		devil_number++
		var/datum/antagonist/devil/devil = D.has_antag_datum(/datum/antagonist/devil)
		to_chat(usr, "Devil #[devil_number]:<br><br>" + devil.printdevilinfo())
	if(!devil_number)
		to_chat(usr, "<b>Nie znaleziono diabłów</b>" )

/datum/admins/proc/output_devil_info(mob/living/M)
	if(is_devil(M))
		var/datum/antagonist/devil/devil = M.mind.has_antag_datum(/datum/antagonist/devil)
		to_chat(usr, devil.printdevilinfo())
	else
		to_chat(usr, "<b>[M] nie jest diabłem.")

/datum/admins/proc/manage_free_slots()
	if(!check_rights())
		return

	if(!SSjob.initialized)
		alert(usr, "Nie możesz zarządzać stanowiskami przed inicjalizacją podsystemu stanowisk!")
		return

	// AQUILA EDIT - zarządzanie wolnymi stanowiskami w TGUI (okno "AdminJobSlots")
	if(!job_slots_ui)
		job_slots_ui = new(src)
	job_slots_ui.ui_interact(usr)

/datum/admins
	/// AQUILA - okno TGUI do zarządzania wolnymi stanowiskami
	var/datum/admin_job_slots/job_slots_ui

/datum/admin_job_slots
	var/datum/admins/holder

/datum/admin_job_slots/New(datum/admins/holder)
	. = ..()
	src.holder = holder

/datum/admin_job_slots/Destroy(force)
	if(holder?.job_slots_ui == src)
		holder.job_slots_ui = null
	holder = null
	return ..()

/datum/admin_job_slots/ui_state(mob/user)
	return GLOB.admin_state

/datum/admin_job_slots/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AdminJobSlots")
		ui.open()

/datum/admin_job_slots/ui_data(mob/user)
	var/list/data = list()
	var/list/jobs = list()
	for(var/datum/job/job as anything in SSjob.occupations)
		jobs += list(list(
			"title" = job.title,
			"current" = job.current_positions,
			"total" = job.total_positions,
		))
	data["jobs"] = jobs
	return data

/datum/admin_job_slots/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/static/list/commands = list(
		"add" = "addjobslot",
		"custom" = "customjobslot",
		"remove" = "removejobslot",
		"unlimit" = "unlimitjobslot",
		"limit" = "limitjobslot",
	)
	var/command = commands[action]
	if(!command || !istext(params["title"]))
		return
	holder.ui_topic(list("[command]" = params["title"]))
	return TRUE

/datum/admins/proc/create_or_modify_area()
	set category = "Debug"
	set name = "Create or modify area"
	create_area(usr)

//
//
//ALL DONE
//*********************************************************************************************************
//TO-DO:
//
//

//RIP ferry snowflakes

//Kicks all the clients currently in the lobby. The second parameter (kick_only_afk) determins if an is_afk() check is ran, or if all clients are kicked
//defaults to kicking everyone (afk + non afk clients in the lobby)
//returns a list of ckeys of the kicked clients
/proc/kick_clients_in_lobby(message, kick_only_afk = 0)
	var/list/kicked_client_names = list()
	for(var/client/C in GLOB.clients)
		if(isnewplayer(C.mob))
			if(kick_only_afk && !C.is_afk()) //Ignore clients who are not afk
				continue
			if(message)
				to_chat(C, message)
			kicked_client_names.Add("[C.key]")
			qdel(C)
	return kicked_client_names

//returns 1 to let the dragdrop code know we are trapping this event
//returns 0 if we don't plan to trap the event
/datum/admins/proc/cmd_ghost_drag(mob/dead/observer/frommob, mob/tomob)

	//this is the exact two check rights checks required to edit a ckey with vv.
	if (!check_rights(R_VAREDIT,0) || !check_rights(R_SPAWN|R_DEBUG,0))
		return 0

	if (!frommob.ckey)
		return 0

	var/question = ""
	if (tomob.ckey)
		question = "Ten mob ma już użytkownika ([tomob.key]), który nim steruje! "
	question += "Czy na pewno chcesz dać [frommob.name]([frommob.key]) kontrolę nad [tomob.name]?"

	var/ask = alert(question, "Dać duchowi kontrolę nad mobem?", "Tak", "Nie")
	if (ask != "Tak")
		return 1

	if (!frommob || !tomob) //make sure the mobs don't go away while we waited for a response
		return 1

	tomob.ghostize(FALSE)

	message_admins("<span class='adminnotice'>[key_name_admin(usr)] daje [frommob.key] kontrolę nad: [tomob.name].</span>")
	log_admin("[key_name(usr)] stuffed [frommob.key] into [tomob.name].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Ghost Drag Control")

	tomob.ckey = frommob.ckey
	qdel(frommob)

	return 1

/client/proc/adminGreet(logout)
	if(SSticker.HasRoundStarted())
		var/string
		if(logout && CONFIG_GET(flag/announce_admin_logout))
			string = pick(
				"Admin się wylogowuje: [key_name(src)]")
		else if(!logout && CONFIG_GET(flag/announce_admin_login) && (prefs.toggles & PREFTOGGLE_ANNOUNCE_LOGIN))
			string = pick(
				"Admin się loguje: [key_name(src)]")
		if(string)
			message_admins("[string]")
