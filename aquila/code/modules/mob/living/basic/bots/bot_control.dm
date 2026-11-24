// Sterowanie basic botami z PDA (program „Zdalny kontroler botów”) i z konsoli SI („Sterowanie robotami”).
// MULEbot (stara baza) jest w GLOB.bots_list i obsługuje go kod z core; tu dokładamy GLOB.basic_bots_list nadpisaniami z ..().

/// Czy bot jest na tym samym okręcie albo pokładzie co punkt odniesienia
/mob/living/basic/bot/proc/remote_visible_from(atom/reference)
	if(stat == DEAD || !(bot_mode_flags & BOT_MODE_ON) || !(bot_mode_flags & BOT_MODE_REMOTE_ENABLED))
		return FALSE
	var/datum/our_overmap = get_overmap()
	if(our_overmap && our_overmap == reference.get_overmap())
		return TRUE
	return get_virtual_z_level() == reference.get_virtual_z_level()

/// Czy PDA może sterować botem: karta w PDA albo karta użytkownika; odblokowana obudowa (allowed()) nie wystarcza
/mob/living/basic/bot/proc/remote_access_allowed(mob/user, obj/item/card/id/id_card)
	if(!id_card && (issilicon(user) || IsAdminGhost(user)))
		return TRUE
	return check_access(id_card || user?.get_idcard(TRUE))

/// Wpis bota w oknach sterowania
/mob/living/basic/bot/proc/remote_control_entry()
	return list("name" = name, "mode" = get_mode_ui(), "model" = model, "locat" = get_area_name(src, TRUE), "bot_ref" = REF(src), "mule_check" = FALSE)

// --- PDA

/datum/computer_file/program/robocontrol/ui_data(mob/user)
	. = ..()
	var/list/data = .
	if(!computer)
		return
	var/obj/item/computer_hardware/card_slot/card_slot = computer.all_components[MC_CARD]
	var/obj/item/card/id/id_card = card_slot?.stored_card
	var/list/botlist = data["bots"] || list()
	for(var/mob/living/basic/bot/basic_bot as anything in GLOB.basic_bots_list)
		if(!basic_bot.remote_visible_from(computer))
			continue
		if(!basic_bot.remote_access_allowed(user, id_card))
			continue
		botlist += list(basic_bot.remote_control_entry())
	data["bots"] = botlist
	data["botcount"] = length(botlist)

/datum/computer_file/program/robocontrol/ui_act(action, list/params)
	var/mob/living/basic/bot/basic_bot = locate(params["robot"]) in GLOB.basic_bots_list
	if(!basic_bot)
		return ..()
	if(!computer)
		return TRUE
	var/obj/item/computer_hardware/card_slot/card_slot = computer.all_components[MC_CARD]
	var/obj/item/card/id/id_card = card_slot?.stored_card
	var/mob/user = usr
	if(!basic_bot.remote_access_allowed(user, id_card))
		return TRUE
	if(action in list("summon", "patroloff", "patrolon", "ejectpai"))
		basic_bot.bot_control(action, user, id_card ? id_card.GetAccess() : list())
	return TRUE

// --- Konsola SI

/mob/living/silicon/ai
	/// Basic bot czekający na punkt nawigacyjny od SI
	var/datum/weakref/aq_called_basic_bot

/datum/robot_control/ui_data(mob/user)
	. = ..()
	var/list/data = .
	if(!data || !owner)
		return
	for(var/mob/living/basic/bot/basic_bot as anything in GLOB.basic_bots_list)
		if(!basic_bot.remote_visible_from(owner))
			continue
		data["robots"] += list(list(
			"name" = basic_bot.name,
			"model" = basic_bot.model,
			"mode" = basic_bot.get_mode_ui(),
			"hacked" = !!(basic_bot.bot_access_flags & BOT_COVER_HACKED),
			"location" = get_area_name(basic_bot, TRUE),
			"ref" = REF(basic_bot),
		))

/datum/robot_control/ui_act(action, params)
	var/mob/living/basic/bot/basic_bot = locate(params["ref"]) in GLOB.basic_bots_list
	if(!basic_bot)
		return ..()
	if(!is_interactable(usr) || !(basic_bot.bot_mode_flags & BOT_MODE_REMOTE_ENABLED))
		return TRUE
	switch(action)
		if("callbot")
			if(owner.call_bot_cooldown > world.time)
				to_chat(usr, span_danger("Błąd: twoje ostatnie polecenie wezwania bota wciąż jest przetwarzane, zaczekaj, aż bot wyznaczy trasę."))
				return TRUE
			owner.Bot = null
			owner.aq_called_basic_bot = WEAKREF(basic_bot)
			owner.waypoint_mode = TRUE
			to_chat(usr, span_notice("Ustaw punkt nawigacyjny, klikając prawidłowe miejsce wolne od przeszkód."))
		if("interface")
			basic_bot.attack_ai(usr)
	return TRUE

/mob/living/silicon/ai/call_bot(turf/waypoint)
	var/mob/living/basic/bot/basic_bot = aq_called_basic_bot?.resolve()
	if(isnull(basic_bot) || Bot)
		return ..()
	aq_called_basic_bot = null
	var/atom/calling_ai = basic_bot.calling_ai_ref?.resolve()
	if(calling_ai && calling_ai != src)
		to_chat(src, span_danger("Błąd interfejsu. Jednostka jest już w użyciu."))
		return
	to_chat(src, span_notice("Wysyłanie polecenia do bota..."))
	basic_bot.summon_bot(src, waypoint, grant_all_access = TRUE)
