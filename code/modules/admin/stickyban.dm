/datum/admins/proc/stickyban(action,data)
	if(!check_rights(R_BAN))
		return
	switch (action)
		if ("show")
			stickyban_show()
		if ("add")
			var/list/ban = list()
			var/ckey
			ban["admin"] = usr.ckey
			ban["type"] = list("sticky")
			ban["reason"] = "(InGameBan)([usr.key])" //this will be displayed in dd only

			if (data["ckey"])
				ckey = ckey(data["ckey"])
			else
				ckey = capped_input(usr,"Ckey","Ckey")
				if (!ckey)
					return
				ckey = ckey(ckey)
			ban["ckey"] = ckey

			if (get_stickyban_from_ckey(ckey))
				to_chat(usr, "<span class='adminnotice'>Błąd: nie można dodać stickybana, użytkownik już ma aktywny sticky ban</span>")
				return

			if (data["reason"])
				ban["message"] = data["reason"]
			else
				var/reason = capped_input(usr,"Powód","Powód","Omijanie bana")
				if (!reason)
					return
				ban["message"] = "[reason]"

			if(SSdbcore.Connect())
				var/datum/DBQuery/query_create_stickyban = SSdbcore.NewQuery({"
					INSERT INTO [format_table_name("stickyban")] (ckey, reason, banning_admin)
					VALUES (:ckey, :message, :banning_admin)
				"}, list("ckey" = ckey, "message" = ban["message"], "banning_admin" = usr.ckey))
				if (query_create_stickyban.warn_execute())
					ban["fromdb"] = TRUE
				qdel(query_create_stickyban)

			world.SetConfig("ban",ckey,list2stickyban(ban))
			ban = stickyban2list(list2stickyban(ban))
			ban["matches_this_round"] = list()
			ban["existing_user_matches_this_round"] = list()
			ban["admin_matches_this_round"] = list()
			ban["pending_matches_this_round"] = list()
			SSstickyban.cache[ckey] = ban

			log_admin_private("[key_name(usr)] has stickybanned [ckey].\nReason: [ban["message"]]")
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] nakłada stickybana na [ckey].\nPowód: [ban["message"]]</span>")

		if ("remove")
			if (!data["ckey"])
				return
			var/ckey = data["ckey"]

			var/ban = get_stickyban_from_ckey(ckey)
			if (!ban)
				to_chat(usr, "<span class='adminnotice'>Błąd: nie znaleziono sticky bana dla [ckey]!</span>")
				return
			if (alert("Na pewno chcesz zdjąć sticky bana z [ckey]?","Na pewno","Tak","Nie") != "Tak")
				return
			if (!get_stickyban_from_ckey(ckey))
				to_chat(usr, "<span class='adminnotice'>Błąd: ban zniknął.</span>")
				return
			world.SetConfig("ban",ckey, null)
			SSstickyban.cache -= ckey

			if (SSdbcore.Connect())
				SSdbcore.QuerySelect(list(
					SSdbcore.NewQuery("DELETE FROM [format_table_name("stickyban")] WHERE ckey = :ckey", list("ckey" = ckey)),
					SSdbcore.NewQuery("DELETE FROM [format_table_name("stickyban_matched_ckey")] WHERE stickyban = :ckey", list("ckey" = ckey)),
					SSdbcore.NewQuery("DELETE FROM [format_table_name("stickyban_matched_cid")] WHERE stickyban = :ckey", list("ckey" = ckey)),
					SSdbcore.NewQuery("DELETE FROM [format_table_name("stickyban_matched_ip")] WHERE stickyban = :ckey", list("ckey" = ckey))
				), warn = TRUE, qdel = TRUE)


			log_admin_private("[key_name(usr)] removed [ckey]'s stickyban")
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] zdejmuje stickybana z [ckey]</span>")

		if ("remove_alt")
			if (!data["ckey"])
				return
			var/ckey = data["ckey"]
			if (!data["alt"])
				return
			var/alt = ckey(data["alt"])
			var/ban = get_stickyban_from_ckey(ckey)
			if (!ban)
				to_chat(usr, "<span class='adminnotice'>Błąd: nie znaleziono sticky bana dla [ckey]!</span>")
				return

			var/key = LAZYACCESS(ban["keys"], alt)
			if (!key)
				to_chat(usr, "<span class='adminnotice'>Błąd: [alt] nie jest powiązany ze sticky banem [ckey]!</span>")
				return

			if (alert("Na pewno chcesz odłączyć [alt] od sticky bana [ckey]? \nUwaga: nic nie powstrzyma BYOND-a przed ponownym powiązaniem. Użyj \[E], by zwolnić z bana","Na pewno","Tak","Nie") != "Tak")
				return

			//we have to do this again incase something changes
			ban = get_stickyban_from_ckey(ckey)
			if (!ban)
				to_chat(usr, "<span class='adminnotice'>Błąd: ban zniknął.</span>")
				return

			key = LAZYACCESS(ban["keys"], alt)

			if (!key)
				to_chat(usr, "<span class='adminnotice'>Błąd: powiązanie [alt] ze sticky banem [ckey] zniknęło.</span>")
				return

			LAZYREMOVE(ban["keys"], alt)
			world.SetConfig("ban",ckey,list2stickyban(ban))

			SSstickyban.cache[ckey] = ban

			if (SSdbcore.Connect())
				var/datum/DBQuery/query_remove_stickyban_alt = SSdbcore.NewQuery(
					"DELETE FROM [format_table_name("stickyban_matched_ckey")] WHERE stickyban = :ckey AND matched_ckey = :alt",
					list("ckey" = ckey, "alt" = alt)
				)
				query_remove_stickyban_alt.warn_execute()
				qdel(query_remove_stickyban_alt)

			log_admin_private("[key_name(usr)] has disassociated [alt] from [ckey]'s sticky ban")
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] odłącza [alt] od sticky bana [ckey]</span>")

		if ("edit")
			if (!data["ckey"])
				return
			var/ckey = data["ckey"]
			var/ban = get_stickyban_from_ckey(ckey)
			if (!ban)
				to_chat(usr, "<span class='adminnotice'>Błąd: nie znaleziono sticky bana dla [ckey]!</span>")
				return
			var/oldreason = ban["message"]
			var/reason = capped_input(usr,"Powód","Powód","[ban["message"]]")
			if (!reason || reason == oldreason)
				return
			//we have to do this again incase something changed while we waited for input
			ban = get_stickyban_from_ckey(ckey)
			if (!ban)
				to_chat(usr, "<span class='adminnotice'>Błąd: ban zniknął.</span>")
				return
			ban["message"] = "[reason]"

			world.SetConfig("ban",ckey,list2stickyban(ban))

			SSstickyban.cache[ckey] = ban

			if (SSdbcore.Connect())
				var/datum/DBQuery/query_edit_stickyban = SSdbcore.NewQuery(
					"UPDATE [format_table_name("stickyban")] SET reason = :reason WHERE ckey = :ckey",
					list("reason" = reason, "ckey" = ckey)
				)
				query_edit_stickyban.warn_execute()
				qdel(query_edit_stickyban)

			log_admin_private("[key_name(usr)] has edited [ckey]'s sticky ban reason from [oldreason] to [reason]")
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] zmienia powód sticky bana [ckey] z [oldreason] na [reason]</span>")

		if ("exempt")
			if (!data["ckey"])
				return
			var/ckey = data["ckey"]
			if (!data["alt"])
				return
			var/alt = ckey(data["alt"])
			var/ban = get_stickyban_from_ckey(ckey)
			if (!ban)
				to_chat(usr, "<span class='adminnotice'>Błąd: nie znaleziono sticky bana dla [ckey]!</span>")
				return

			var/key = LAZYACCESS(ban["keys"], alt)
			if (!key)
				to_chat(usr, "<span class='adminnotice'>Błąd: [alt] nie jest powiązany ze sticky banem [ckey]!</span>")
				return

			if (alert("Na pewno chcesz zwolnić [alt] ze sticky bana [ckey]?","Na pewno","Tak","Nie") != "Tak")
				return

			//we have to do this again incase something changes
			ban = get_stickyban_from_ckey(ckey)
			if (!ban)
				to_chat(usr, "<span class='adminnotice'>Błąd: ban zniknął.</span>")
				return

			key = LAZYACCESS(ban["keys"], alt)

			if (!key)
				to_chat(usr, "<span class='adminnotice'>Błąd: powiązanie [alt] ze sticky banem [ckey] zniknęło.</span>")
				return
			LAZYREMOVE(ban["keys"], alt)
			key["exempt"] = TRUE
			LAZYSET(ban["whitelist"], alt, key)

			world.SetConfig("ban",ckey,list2stickyban(ban))

			SSstickyban.cache[ckey] = ban

			if (SSdbcore.Connect())
				var/datum/DBQuery/query_exempt_stickyban_alt = SSdbcore.NewQuery(
					"UPDATE [format_table_name("stickyban_matched_ckey")] SET exempt = 1 WHERE stickyban = :ckey AND matched_ckey = :alt",
					list("ckey" = ckey, "alt" = alt)
				)
				query_exempt_stickyban_alt.warn_execute()
				qdel(query_exempt_stickyban_alt)

			log_admin_private("[key_name(usr)] has exempted [alt] from [ckey]'s sticky ban")
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] zwalnia [alt] ze sticky bana [ckey]</span>")

		if ("unexempt")
			if (!data["ckey"])
				return
			var/ckey = data["ckey"]
			if (!data["alt"])
				return
			var/alt = ckey(data["alt"])
			var/ban = get_stickyban_from_ckey(ckey)
			if (!ban)
				to_chat(usr, "<span class='adminnotice'>Błąd: nie znaleziono sticky bana dla [ckey]!</span>")
				return

			var/key = LAZYACCESS(ban["whitelist"], alt)
			if (!key)
				to_chat(usr, "<span class='adminnotice'>Błąd: [alt] nie jest zwolniony ze sticky bana [ckey]!</span>")
				return

			if (alert("Na pewno chcesz cofnąć zwolnienie [alt] ze sticky bana [ckey]?","Na pewno","Tak","Nie") != "Tak")
				return

			//we have to do this again incase something changes
			ban = get_stickyban_from_ckey(ckey)
			if (!ban)
				to_chat(usr, "<span class='adminnotice'>Błąd: ban zniknął.</span>")
				return

			key = LAZYACCESS(ban["whitelist"], alt)
			if (!key)
				to_chat(usr, "<span class='adminnotice'>Błąd: zwolnienie [alt] ze sticky bana [ckey] zniknęło.</span>")
				return

			LAZYREMOVE(ban["whitelist"], alt)
			key["exempt"] = FALSE
			LAZYSET(ban["keys"], alt, key)

			world.SetConfig("ban",ckey,list2stickyban(ban))

			SSstickyban.cache[ckey] = ban

			if (SSdbcore.Connect())
				var/datum/DBQuery/query_unexempt_stickyban_alt = SSdbcore.NewQuery(
					"UPDATE [format_table_name("stickyban_matched_ckey")] SET exempt = 0 WHERE stickyban = :ckey AND matched_ckey = :alt",
					list("ckey" = ckey, "alt" = alt)
				)
				query_unexempt_stickyban_alt.warn_execute()
				qdel(query_unexempt_stickyban_alt)

			log_admin_private("[key_name(usr)] has unexempted [alt] from [ckey]'s sticky ban")
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] cofa zwolnienie [alt] ze sticky bana [ckey]</span>")

		if ("timeout")
			if (!data["ckey"])
				return
			if (!SSdbcore.Connect())
				to_chat(usr, "<span class='adminnotice'>Brak połączenia z bazą danych!</span>")
				return

			var/ckey = data["ckey"]

			if (alert("Na pewno chcesz zawiesić stickybana [ckey] do następnej rundy (albo do usunięcia)?","Na pewno","Tak","Nie") != "Tak")
				return
			var/ban = get_stickyban_from_ckey(ckey)
			if (!ban)
				to_chat(usr, "<span class='adminnotice'>Błąd: nie znaleziono sticky bana dla [ckey]!</span>")
				return

			ban["timeout"] = TRUE

			world.SetConfig("ban", ckey, null)

			var/cachedban = SSstickyban.cache[ckey]
			if (cachedban)
				cachedban["timeout"] = TRUE

			log_admin_private("[key_name(usr)] has put [ckey]'s sticky ban on timeout.")
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] zawiesza sticky bana [ckey].</span>")

		if ("untimeout")
			if (!data["ckey"])
				return
			if (!SSdbcore.Connect())
				to_chat(usr, "<span class='adminnotice'>Brak połączenia z bazą danych!</span>")
				return
			var/ckey = data["ckey"]

			if (alert("Na pewno chcesz odwiesić stickybana [ckey]?","Na pewno","Tak","Nie") != "Tak")
				return

			var/ban = get_stickyban_from_ckey(ckey)
			var/cachedban = SSstickyban.cache[ckey]
			if (cachedban)
				cachedban["timeout"] = FALSE
			if (!ban)
				if (!cachedban)
					to_chat(usr, "<span class='adminnotice'>Błąd: nie znaleziono sticky bana dla [ckey]!</span>")
					return
				ban = cachedban

			ban["timeout"] = FALSE

			world.SetConfig("ban",ckey,list2stickyban(ban))

			log_admin_private("[key_name(usr)] has taken [ckey]'s sticky ban off of timeout.")
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] odwiesza sticky bana [ckey].</span>")


		if ("revert")
			if (!data["ckey"])
				return
			var/ckey = data["ckey"]
			if (alert("Na pewno chcesz przywrócić sticky bana [ckey] do stanu z początku rundy (albo z ostatniej edycji)?","Na pewno","Tak","Nie") != "Tak")
				return
			var/ban = get_stickyban_from_ckey(ckey)
			if (!ban)
				to_chat(usr, "<span class='adminnotice'>Błąd: nie znaleziono sticky bana dla [ckey]!</span>")
				return
			var/cached_ban = SSstickyban.cache[ckey]
			if (!cached_ban)
				to_chat(usr, "<span class='adminnotice'>Błąd: nie znaleziono zapamiętanego sticky bana dla [ckey]!</span>")
			world.SetConfig("ban",ckey,null)

			log_admin_private("[key_name(usr)] has reverted [ckey]'s sticky ban to its state at round start.")
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] przywraca sticky bana [ckey] do stanu z początku rundy.</span>")
			//revert is mostly used when shit goes rouge, so we have to set it to null
			//	and wait a byond tick before assigning it to ensure byond clears its shit.
			sleep(world.tick_lag)
			world.SetConfig("ban",ckey,list2stickyban(cached_ban))


// AQUILA EDIT - panel stickybanów w TGUI (okno "StickyBanPanel") zamiast HTML
/datum/admins/proc/stickyban_data(ckey)
	var/ban = get_stickyban_from_ckey(ckey)
	if (!ban)
		return
	var/list/alts = list()
	for (var/key in ban["keys"])
		if (ckey(key) == ckey)
			continue
		alts += list(list("key" = key, "ckey" = ckey(key), "exempt" = FALSE))
	for (var/key in ban["whitelist"])
		if (ckey(key) == ckey)
			continue
		alts += list(list("key" = key, "ckey" = ckey(key), "exempt" = TRUE))
	return list(
		"ckey" = ckey,
		"message" = ban["message"],
		"admin" = ban["admin"],
		"timeout" = !!ban["timeout"],
		"alts" = alts,
	)

/datum/admins/proc/stickyban_show()
	if(!check_rights(R_BAN))
		return
	if(!stickyban_panel_ui)
		stickyban_panel_ui = new(src)
	stickyban_panel_ui.ui_interact(usr)
	stickyban_panel_ui.update_static_data(usr)

/datum/admins
	/// AQUILA - okno TGUI stickybanów
	var/datum/stickyban_panel/stickyban_panel_ui

/datum/stickyban_panel
	var/datum/admins/holder

/datum/stickyban_panel/New(datum/admins/holder)
	. = ..()
	src.holder = holder

/datum/stickyban_panel/Destroy(force)
	if(holder?.stickyban_panel_ui == src)
		holder.stickyban_panel_ui = null
	holder = null
	return ..()

/datum/stickyban_panel/ui_state(mob/user)
	return get_admin_state(R_BAN)

/datum/stickyban_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "StickyBanPanel")
		ui.set_autoupdate(FALSE)
		ui.open()

// Lista banów może pytać bazę danych, więc jest w danych statycznych odświeżanych po każdej akcji
/datum/stickyban_panel/ui_static_data(mob/user)
	var/list/data = list()
	var/list/bans = list()
	for(var/key in sticky_banned_ckeys())
		var/list/ban_data = holder.stickyban_data(ckey(key))
		if(ban_data)
			bans += list(ban_data)
	data["bans"] = bans
	data["db_connected"] = SSdbcore.IsConnected()
	return data

/datum/stickyban_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!check_rights(R_BAN))
		return
	switch(action)
		if("refresh")
			update_static_data(usr, ui)
			return
		if("add", "remove", "remove_alt", "edit", "exempt", "unexempt", "timeout", "untimeout", "revert")
			var/list/data = list()
			if(istext(params["ckey"]))
				data["ckey"] = params["ckey"]
			if(istext(params["alt"]))
				data["alt"] = params["alt"]
			holder.stickyban(action, data)
			update_static_data(usr, ui)
			return

/proc/sticky_banned_ckeys()
	if (SSdbcore.Connect() || length(SSstickyban.dbcache))
		if (SSstickyban.dbcacheexpire < world.time)
			SSstickyban.Populatedbcache()
		if (SSstickyban.dbcacheexpire)
			return SSstickyban.dbcache.Copy()

	return sortList(world.GetConfig("ban"))


/proc/get_stickyban_from_ckey(var/ckey)
	. = list()
	if (!ckey)
		return null
	if (SSdbcore.Connect() || length(SSstickyban.dbcache))
		if (SSstickyban.dbcacheexpire < world.time)
			SSstickyban.Populatedbcache()
		if (SSstickyban.dbcacheexpire)
			. = SSstickyban.dbcache[ckey]
			//reset the cache incase its a newer ban (but only if we didn't update the cache recently)
			if (!. && SSstickyban.dbcacheexpire != world.time+STICKYBAN_DB_CACHE_TIME)
				SSstickyban.dbcacheexpire = 1
				SSstickyban.Populatedbcache()
				. = SSstickyban.dbcache[ckey]
			if (.)
				var/list/cachedban = SSstickyban.cache["[ckey]"]
				if (cachedban)
					.["timeout"] = cachedban["timeout"]

				.["fromdb"] = TRUE
			return

	. = stickyban2list(world.GetConfig("ban", ckey)) || stickyban2list(world.GetConfig("ban", ckey(ckey))) || list()

	if (!length(.))
		return null

/proc/stickyban2list(ban, strictdb = TRUE)
	if (!ban)
		return null
	. = params2list(ban)
	if (.["keys"])
		var/keys = splittext(.["keys"], ",")
		var/ckeys = list()
		for (var/key in keys)
			var/ckey = ckey(key)
			ckeys[ckey] = ckey //to make searching faster.
		.["keys"] = ckeys
	if (.["whitelist"])
		var/keys = splittext(.["whitelist"], ",")
		var/ckeys = list()
		for (var/key in keys)
			var/ckey = ckey(key)
			ckeys[ckey] = ckey //to make searching faster.
		.["whitelist"] = ckeys
	.["type"] = splittext(.["type"], ",")
	.["IP"] = splittext(.["IP"], ",")
	.["computer_id"] = splittext(.["computer_id"], ",")
	. -= "fromdb"


/proc/list2stickyban(list/ban)
	if (!ban || !islist(ban))
		return null
	. = ban.Copy()
	if (.["keys"])
		.["keys"] = jointext(.["keys"], ",")
	if (.["IP"])
		.["IP"] = jointext(.["IP"], ",")
	if (.["computer_id"])
		.["computer_id"] = jointext(.["computer_id"], ",")
	if (.["whitelist"])
		.["whitelist"] = jointext(.["whitelist"], ",")
	if (.["type"])
		.["type"] = jointext(.["type"], ",")

	. -= "reverting"
	. -= "matches_this_round"
	. -= "existing_user_matches_this_round"
	. -= "admin_matches_this_round"
	. -= "pending_matches_this_round"


	. = list2params(.)


/client/proc/stickybanpanel()
	set name = "Sticky Ban Panel"
	set category = "Admin"
	if (!holder)
		return
	holder.stickyban_show()
