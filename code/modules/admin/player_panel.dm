// AQUILA EDIT - Player Panel przeniesiony z HTML/JS na TGUI (okno "PlayerPanel")

/datum/admins/proc/player_panel_new()//The new one
	if(!check_rights())
		return
	log_admin("[key_name(usr)] checked the player panel.")
	if(!player_panel_ui)
		player_panel_ui = new(src)
	player_panel_ui.ui_interact(usr)

/datum/admins
	/// AQUILA - okno TGUI z listą graczy
	var/datum/player_panel_ui/player_panel_ui

/// Lista wszystkich mobów z ckey, z szybkimi akcjami admina
/datum/player_panel_ui
	var/datum/admins/holder

/datum/player_panel_ui/New(datum/admins/holder)
	. = ..()
	src.holder = holder

/datum/player_panel_ui/Destroy(force)
	if(holder?.player_panel_ui == src)
		holder.player_panel_ui = null
	holder = null
	return ..()

/datum/player_panel_ui/ui_state(mob/user)
	return GLOB.admin_state

/datum/player_panel_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PlayerPanel")
		ui.open()

/// Opis stanowiska/rodzaju moba na liście graczy
/proc/player_panel_job(mob/M)
	if(isliving(M))
		if(iscarbon(M)) //Carbon stuff
			if(ishuman(M))
				return M.job
			if(ismonkey(M))
				return "Małpa"
			if(isalien(M)) //aliens
				if(islarva(M))
					return "Larwa obcego"
				return ROLE_ALIEN
			return "Węglowy"
		if(issilicon(M)) //silicon
			if(isAI(M))
				return JOB_NAME_AI
			if(ispAI(M))
				return ROLE_PAI
			if(iscyborg(M))
				return JOB_NAME_CYBORG
			return "Krzemowy"
		if(isanimal(M)) //simple animals
			if(iscorgi(M))
				return "Corgi"
			if(isslime(M))
				return "Szlam"
			return "Zwierzę"
		return "Żywy"
	if(isnewplayer(M))
		return "Nowy gracz"
	if(isobserver(M))
		var/mob/dead/observer/O = M
		if(O.started_as_observer)//Did they get BTFO or are they just not trying?
			return "Obserwator"
		return "Duch"
	return ""

/datum/player_panel_ui/ui_data(mob/user)
	var/list/data = list()
	var/list/mobs_with_ckey = list()
	for(var/mob/M as anything in GLOB.mob_list)
		if(M.ckey)
			mobs_with_ckey += M
	var/list/players = list()
	for(var/mob/M as anything in sortNames(mobs_with_ckey))
		var/previous_names = ""
		var/datum/player_details/P = GLOB.player_details[M.ckey]
		if(P)
			previous_names = P.played_names.Join(", ")
		players += list(list(
			"ref" = REF(M),
			"name" = M.name,
			"real_name" = M.real_name,
			"key" = M.key,
			"ckey" = M.ckey,
			"job" = player_panel_job(M),
			"ip" = M.lastKnownIP,
			"old_names" = previous_names,
			"antag" = !!is_special_character(M),
			"cyborg" = iscyborg(M),
			"connected" = !!M.client,
		))
	data["players"] = players
	return data

/datum/player_panel_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!check_rights(R_ADMIN))
		return
	switch(action)
		if("check_antagonists")
			usr.client.check_antagonists()
			return
		if("kick_lobby")
			holder.ui_topic(list("kick_all_from_lobby" = "1", "afkonly" = params["afk"] ? "1" : "0"))
			return TRUE
	return holder.ui_common_action(action, params)
