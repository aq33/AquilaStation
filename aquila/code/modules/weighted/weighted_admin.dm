// AQUILA - admin controls of the weighted rotation (Server -> "Weighted: wagi pul").
// An admin can set the survey tilt, replace the pool weights by hand until cleared, or force one pool for the next round.

/// Short description of what admins changed in the weighted rotation, for the admin messages
/datum/weighted_rotation/proc/admin_summary()
	var/list/parts = list()
	if(forced_pool)
		parts += "wymuszona pula [pool_name(forced_pool)] na najbliższą rundę"
	if(admin_weights)
		parts += "ręczne wagi [pool_name(WEIGHTED_POOL_LOW)] [admin_weights[WEIGHTED_POOL_LOW]] / [pool_name(WEIGHTED_POOL_MEDIUM)] [admin_weights[WEIGHTED_POOL_MEDIUM]] / [pool_name(WEIGHTED_POOL_HIGH)] [admin_weights[WEIGHTED_POOL_HIGH]]"
	return length(parts) ? parts.Join(", ") : "brak (automatyczne z ankiet)"

/// The lobby odds have to be counted again after an admin change, and a mode drawn already is drawn again
/datum/weighted_rotation/proc/admin_changed(client/admin, text)
	cached_lobby_odds = null
	save()
	log_admin("[key_name(admin)] changed the weighted rotation: [text]")
	message_admins("<span class='adminnotice'>Weighted - zmiana od [key_name_admin(admin)]: [text].</span>")
	if(GLOB.master_mode == "weighted" && SSticker.current_state == GAME_STATE_PREGAME && SSticker.pre_setup_completed)
		if(SSticker.gamemode_hotswap_disabled)
			message_admins("Weighted: tryb [SSticker.mode?.config_tag] załadował już mapy, nowe wagi zadziałają od następnej rundy.")
			return
		SSticker.pre_setup_completed = FALSE
		message_admins("Weighted: tryb [SSticker.mode?.config_tag] zostanie wylosowany ponownie z nowymi wagami.")

/client/proc/weighted_settings()
	set category = "Server"
	set name = "Weighted: wagi pul"
	set desc = "Ustaw wagi pul zagrożeń trybu weighted"

	if(!check_rights(R_ADMIN|R_SERVER))
		return
	var/datum/weighted_rotation/rotation = GLOB.weighted_rotation
	var/list/weights = rotation.pool_weights()
	var/total = weights[WEIGHTED_POOL_LOW] + weights[WEIGHTED_POOL_MEDIUM] + weights[WEIGHTED_POOL_HIGH]
	var/list/now = list()
	for(var/pool in weights)
		now += "[rotation.pool_name(pool)] [total ? round(weights[pool] / total * 100, 1) : 0]%"
	var/info = "Tryb serwera: [GLOB.master_mode]. Nastawienie z ankiet: [round(rotation.bias, 0.01)]. Zmiany admina: [rotation.admin_summary()].\nTeraz (bez pustych pul): [now.Join(", ")]."

	var/static/list/options = list(
		"Ustaw ręczne wagi pul",
		"Wymuś pulę na najbliższą rundę",
		"Ustaw nastawienie z ankiet",
		"Przywróć automatyczne wagi",
	)
	var/choice = tgui_input_list(usr, info, "Weighted", options)
	if(!choice)
		return
	switch(choice)
		if("Ustaw ręczne wagi pul")
			var/list/new_weights = list()
			for(var/pool in list(WEIGHTED_POOL_LOW, WEIGHTED_POOL_MEDIUM, WEIGHTED_POOL_HIGH))
				var/value = tgui_input_number(usr, "Waga puli [rotation.pool_name(pool)] (0 = nigdy). Szansa puli = jej waga / suma wag.", "Weighted", weights[pool], 100, 0, round_value = FALSE)
				if(isnull(value))
					return
				new_weights[pool] = max(0, value)
			if(!(new_weights[WEIGHTED_POOL_LOW] + new_weights[WEIGHTED_POOL_MEDIUM] + new_weights[WEIGHTED_POOL_HIGH]))
				to_chat(usr, "<span class='warning'>Przynajmniej jedna pula musi mieć wagę większą od 0.</span>")
				return
			rotation.admin_weights = new_weights
			rotation.admin_changed(src, rotation.admin_summary())
		if("Wymuś pulę na najbliższą rundę")
			var/list/pools = list()
			for(var/pool in list(WEIGHTED_POOL_LOW, WEIGHTED_POOL_MEDIUM, WEIGHTED_POOL_HIGH))
				pools[rotation.pool_name(pool)] = pool
			pools["Bez wymuszania"] = null
			var/picked = tgui_input_list(usr, "Pula na najbliższą rundę (potem znowu zwykłe losowanie).", "Weighted", pools)
			if(!picked)
				return
			rotation.forced_pool = pools[picked]
			rotation.admin_changed(src, rotation.forced_pool ? "wymuszona pula [picked] na najbliższą rundę" : "bez wymuszonej puli")
		if("Ustaw nastawienie z ankiet")
			var/value = tgui_input_number(usr, "Nastawienie od -100 (spokojniej) do 100 (więcej zagrożeń). Działa, gdy nie ma ręcznych wag. Kolejne ankiety dalej je zmieniają.", "Weighted", round(rotation.bias * 100), 100, -100)
			if(isnull(value))
				return
			rotation.bias = clamp(value / 100, -1, 1)
			rotation.admin_changed(src, "nastawienie z ankiet [round(rotation.bias, 0.01)]")
		if("Przywróć automatyczne wagi")
			rotation.admin_weights = null
			rotation.forced_pool = null
			rotation.admin_changed(src, "automatyczne wagi z ankiet")
