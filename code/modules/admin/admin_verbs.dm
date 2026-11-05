//admin verb groups - They can overlap if you so wish. Only one of each verb will exist in the verbs list regardless
//the procs are cause you can't put the comments in the GLOB var define
GLOBAL_LIST_INIT(admin_verbs_default, world.AVerbsDefault())
GLOBAL_PROTECT(admin_verbs_default)
/world/proc/AVerbsDefault()
	return list(
	/client/proc/deadmin,				/*destroys our own admin datum so we can play as a regular player*/
	/client/proc/cmd_admin_say,			/*admin-only ooc chat*/
	/client/proc/hide_verbs,			/*hides all our adminverbs*/
	/client/proc/hide_most_verbs,		/*hides all our hideable adminverbs*/
	/client/proc/debug_variables,		/*allows us to -see- the variables of any instance in the game. +VAREDIT needed to modify*/
	/client/proc/dsay,					/*talk in deadchat using our ckey/fakekey*/
	/client/proc/investigate_show,		/*various admintools for investigation. Such as a singulo grief-log*/
	/client/proc/secrets,				/*from useful quick commands, to memes*/
	/client/proc/toggle_hear_radio,		/*allows admins to hide all radio output*/
	/client/proc/reload_admins,
	/client/proc/reestablish_db_connection, /*reattempt a connection to the database*/
	/client/proc/cmd_admin_pm_context,	/*right-click adminPM interface*/
	/client/proc/cmd_admin_pm_panel,		/*admin-pm list*/
	/client/proc/stop_sounds,
	/client/proc/mark_datum_mapview,
	/client/proc/tag_datum_mapview,
	/client/proc/requests,
	/client/proc/fax_manager
	)
GLOBAL_LIST_INIT(admin_verbs_admin, world.AVerbsAdmin())
GLOBAL_PROTECT(admin_verbs_admin)
/world/proc/AVerbsAdmin()
	return list(
	/client/proc/invisimin,				/*allows our mob to go invisible/visible*/
//	/datum/admins/proc/show_traitor_panel,	/*interface which shows a mob's mind*/ -Removed due to rare practical use. Moved to debug verbs ~Errorage
	/datum/admins/proc/show_player_panel,	/*shows an interface for individual players, with various links (links require additional flags*/
	/client/proc/playerpanel,
	/client/proc/game_panel,			/*game panel, allows to change game-mode etc*/
	/client/proc/check_ai_laws,			/*shows AI and borg laws*/
	/client/proc/ghost_pool_protection,	/*opens a menu for toggling ghost roles*/
	/datum/admins/proc/toggleooc,		/*toggles ooc on/off for everyone*/
	/datum/admins/proc/togglelooc,		/*toggles looc on/off for everyone*/ //nsv13
	/datum/admins/proc/toggleoocdead,	/*toggles ooc on/off for everyone who is dead*/
	/datum/admins/proc/toggleenter,		/*toggles whether people can join the current game*/
	/datum/admins/proc/toggleguests,	/*toggles whether guests can join the current game*/
	/datum/admins/proc/announce,		/*priority announce something to all clients.*/
	/datum/admins/proc/set_admin_notice, /*announcement all clients see when joining the server.*/
	/client/proc/admin_ghost,			/*allows us to ghost/reenter body at will*/
	/client/proc/toggle_view_range,		/*changes how far we can see*/
	/client/proc/getcurrentlogs,		/*for accessing server logs for the current round*/
	/client/proc/cmd_admin_subtle_message,	/*send an message to somebody as a 'voice in their head'*/
	/client/proc/cmd_admin_headset_message,	/*send an message to somebody through their headset as CentCom*/
	/client/proc/cmd_admin_delete,		/*delete an instance/object/mob/etc*/
	/client/proc/cmd_admin_check_contents,	/*displays the contents of an instance*/
	/client/proc/check_antagonists,		/*shows all antags*/
	/client/proc/check_teams,			/*shows all antag teams*/
	/datum/admins/proc/access_news_network,	/*allows access of newscasters*/
	/client/proc/jumptocoord,			/*we ghost and jump to a coordinate*/
	/client/proc/Getmob,				/*teleports a mob to our location*/
	/client/proc/Getkey,				/*teleports a mob with a certain ckey to our location*/
//	/client/proc/sendmob,				/*sends a mob somewhere*/ -Removed due to it needing two sorting procs to work, which were executed every time an admin right-clicked. ~Errorage
	/client/proc/jumptoarea,
	/client/proc/jumptokey,				/*allows us to jump to the location of a mob with a certain ckey*/
	/client/proc/jumptomob,				/*allows us to jump to a specific mob*/
	/client/proc/jumptoturf,			/*allows us to jump to a specific turf*/
	/client/proc/admin_call_shuttle,	/*allows us to call the emergency shuttle*/
	/client/proc/admin_cancel_shuttle,	/*allows us to cancel the emergency shuttle, sending it back to centcom*/
	/client/proc/cmd_admin_direct_narrate,	/*send text directly to a player with no padding. Useful for narratives and fluff-text*/
	/client/proc/cmd_admin_world_narrate,	/*sends text to all players with no padding*/
	/client/proc/cmd_admin_local_narrate,	/*sends text to all mobs within view of atom*/
	/client/proc/cmd_admin_create_centcom_report,
	/client/proc/cmd_change_command_name,
	/client/proc/cmd_admin_check_player_exp, /* shows players by playtime */
	/client/proc/toggle_combo_hud, // toggle display of the combination pizza antag and taco sci/med/eng hud
	/client/proc/toggle_AI_interact, /*toggle admin ability to interact with machines as an AI*/
	/datum/admins/proc/open_shuttlepanel, /* Opens shuttle manipulator UI */
	/client/proc/deadchat,
	/client/proc/toggleprayers,
	/client/proc/toggle_prayer_sound,
	/client/proc/colorasay,
	/client/proc/resetasaycolor,
	/client/proc/toggleadminhelpsound,
	/client/proc/respawn_character,
	/datum/admins/proc/open_borgopanel,
	/client/proc/fix_say,
	/client/proc/stabilize_atmos,
	/client/proc/openTicketManager,
	/client/proc/battle_royale,
	/client/proc/library_control,
	/client/proc/cmd_admin_send_pda_msg,
	/datum/admins/proc/display_tags,
	/client/proc/changeranks, //NSV13 - verb to change rank structure
	/client/proc/system_manager, //Nsv13 - Fleet + starsystem management
	/client/proc/instance_overmap_menu, //Nsv13 - Midround ship creation.
	/client/proc/overmap_mode_controller //NSV13 - Admin overmap mode controller
	)
GLOBAL_LIST_INIT(admin_verbs_ban, list(/client/proc/unban_panel, /client/proc/ban_panel, /client/proc/stickybanpanel))
GLOBAL_PROTECT(admin_verbs_ban)
GLOBAL_LIST_INIT(admin_verbs_sounds, list(/client/proc/play_local_sound, /client/proc/play_sound, /client/proc/set_round_end_sound))
GLOBAL_PROTECT(admin_verbs_sounds)
GLOBAL_LIST_INIT(admin_verbs_fun, list(
	/client/proc/cmd_admin_dress,
	/client/proc/cmd_admin_gib_self,
	/client/proc/drop_bomb,
	/client/proc/set_dynex_scale,
	/client/proc/drop_dynex_bomb,
	/client/proc/cinematic,
	/client/proc/one_click_antag,
	/client/proc/cmd_admin_add_freeform_ai_law,
	/client/proc/object_say,
	/client/proc/toggle_random_events,
	/client/proc/set_ooc,
	/client/proc/reset_ooc,
	/client/proc/forceEvent,
	/client/proc/admin_change_sec_level,
	/client/proc/toggle_nuke,
	/client/proc/run_weather,
	/client/proc/mass_zombie_infection,
	/client/proc/mass_zombie_cure,
	/client/proc/polymorph_all,
	/client/proc/show_tip,
	/client/proc/smite,
	/client/proc/admin_away,
	/client/proc/healall,
	/client/proc/spawn_floor_cluwne,
	/client/proc/spawnhuman,
	/client/proc/battle_royale
	))
GLOBAL_PROTECT(admin_verbs_fun)
GLOBAL_LIST_INIT(admin_verbs_spawn, list(
	/datum/admins/proc/spawn_atom,
	/datum/admins/proc/podspawn_atom,
	/datum/admins/proc/spawn_cargo,
	/datum/admins/proc/spawn_objasmob,
	/datum/admins/proc/beaker_panel,
	/client/proc/respawn_character,
	/client/proc/centcom_podlauncher,/*Open a window to launch a Supplypod and configure it or it's contents*/
	))
GLOBAL_PROTECT(admin_verbs_spawn)
GLOBAL_LIST_INIT(admin_verbs_server, world.AVerbsServer())
GLOBAL_PROTECT(admin_verbs_server)
/world/proc/AVerbsServer()
	return list(
	/datum/admins/proc/startnow,
	/datum/admins/proc/restart,
	/datum/admins/proc/end_round,
	/datum/admins/proc/delay,
	/datum/admins/proc/delay_round_end,
	/datum/admins/proc/toggleaban,
	/datum/admins/proc/reloadwhitelist, // aquila edit
	/client/proc/weighted_settings, // aquila edit
	/client/proc/everyone_random,
	/datum/admins/proc/toggleAI,
	/client/proc/cmd_admin_delete,		/*delete an instance/object/mob/etc*/
	/client/proc/getserverlogs,		/*for accessing server logs*/
	/client/proc/cmd_debug_del_all,
	/client/proc/toggle_random_events,
	/client/proc/forcerandomrotate,
	/client/proc/adminchangemap,
	/client/proc/panicbunker,
	/client/proc/toggle_interviews,
	/client/proc/toggle_hub,
	/client/proc/toggle_cdn
	)
GLOBAL_LIST_INIT(admin_verbs_debug, world.AVerbsDebug())
GLOBAL_PROTECT(admin_verbs_debug)
/world/proc/AVerbsDebug()
	return list(
	/client/proc/restart_controller,
	/client/proc/cmd_admin_list_open_jobs,
	/client/proc/Debug2,
	/client/proc/cmd_debug_make_powernets,
	/client/proc/cmd_debug_mob_lists,
	/client/proc/cmd_admin_delete,
	/client/proc/cmd_debug_del_all,
	/client/proc/restart_controller,
	/client/proc/enable_debug_verbs,
	/client/proc/callproc,
	/client/proc/callproc_datum,
	/client/proc/forcemapconfig,
	/client/proc/SDQL2_query,
	/client/proc/test_movable_UI,
	/client/proc/test_snap_UI,
	/client/proc/debugNatureMapGenerator,
	/client/proc/check_bomb_impacts,
	/proc/machine_upgrade,
	/client/proc/populate_world,
	/client/proc/get_dynex_power,		//*debug verbs for dynex explosions.
	/client/proc/get_dynex_range,		//*debug verbs for dynex explosions.
	/client/proc/set_dynex_scale,
	/client/proc/cmd_display_del_log,
	/client/proc/outfit_manager,
	/client/proc/modify_goals,
	/client/proc/debug_huds,
	/client/proc/map_template_load,
	/client/proc/map_template_upload,
	/client/proc/test_chamber, // aquila edit
	/client/proc/adventure_manager, // AQ EDIT - drony eksploracyjne, przeglądarka przygód
	/client/proc/jump_to_ruin,
	/client/proc/generate_ruin,
	/client/proc/clear_dynamic_transit,
	/client/proc/fucky_wucky,
	/client/proc/toggle_medal_disable,
	/client/proc/view_runtimes,
	/client/proc/pump_random_event,
	/client/proc/cmd_display_init_log,
	/client/proc/cmd_display_overlay_log,
	/client/proc/reload_configuration,
	/client/proc/give_all_spells,
	/datum/admins/proc/create_or_modify_area,
	#ifdef TESTING
	/client/proc/run_dynamic_simulations,
	#endif
	#ifdef SENDMAPS_PROFILE
	/client/proc/display_sendmaps,
	#endif
	/client/proc/toggle_cdn,
	/client/proc/check_timer_sources,
	/client/proc/test_dview_to_lum_changes
	)

GLOBAL_LIST_INIT(admin_verbs_possess, list(/proc/possess, GLOBAL_PROC_REF(release)))
GLOBAL_PROTECT(admin_verbs_possess)
GLOBAL_LIST_INIT(admin_verbs_permissions, list(/client/proc/edit_admin_permissions, /client/proc/edit_mentors))
GLOBAL_PROTECT(admin_verbs_permissions)
GLOBAL_LIST_INIT(admin_verbs_poll, list(/client/proc/poll_panel))
GLOBAL_PROTECT(admin_verbs_poll)

//verbs which can be hidden - needs work
GLOBAL_LIST_INIT(admin_verbs_hideable, list(
	/client/proc/set_ooc,
	/client/proc/reset_ooc,
	/client/proc/deadmin,
	/datum/admins/proc/show_traitor_panel,
	/datum/admins/proc/toggleenter,
	/datum/admins/proc/toggleguests,
	/datum/admins/proc/announce,
	/datum/admins/proc/set_admin_notice,
	/client/proc/admin_ghost,
	/client/proc/toggle_view_range,
	/client/proc/cmd_admin_subtle_message,
	/client/proc/cmd_admin_headset_message,
	/client/proc/cmd_admin_check_contents,
	/datum/admins/proc/access_news_network,
	/client/proc/admin_call_shuttle,
	/client/proc/admin_cancel_shuttle,
	/client/proc/cmd_admin_direct_narrate,
	/client/proc/cmd_admin_world_narrate,
	/client/proc/cmd_admin_local_narrate,
	/client/proc/play_local_sound,
	/client/proc/play_sound,
	/client/proc/set_round_end_sound,
	/client/proc/cmd_admin_dress,
	/client/proc/cmd_admin_gib_self,
	/client/proc/drop_bomb,
	/client/proc/drop_dynex_bomb,
	/client/proc/get_dynex_range,
	/client/proc/get_dynex_power,
	/client/proc/set_dynex_scale,
	/client/proc/cinematic,
	/client/proc/cmd_admin_add_freeform_ai_law,
	/client/proc/cmd_admin_create_centcom_report,
	/client/proc/cmd_change_command_name,
	/client/proc/object_say,
	/client/proc/toggle_random_events,
	/datum/admins/proc/startnow,
	/datum/admins/proc/restart,
	/datum/admins/proc/delay,
	/datum/admins/proc/delay_round_end,
	/datum/admins/proc/toggleaban,
	/client/proc/everyone_random,
	/datum/admins/proc/toggleAI,
	/client/proc/restart_controller,
	/client/proc/cmd_admin_list_open_jobs,
	/client/proc/callproc,
	/client/proc/callproc_datum,
	/client/proc/Debug2,
	/client/proc/reload_admins,
	/client/proc/cmd_debug_make_powernets,
	/client/proc/startSinglo,
	/client/proc/cmd_debug_mob_lists,
	/client/proc/cmd_debug_del_all,
	/client/proc/enable_debug_verbs,
	/proc/possess,
	/proc/release,
	/client/proc/reload_admins,
	/client/proc/panicbunker,
	/client/proc/toggle_interviews,
	/client/proc/admin_change_sec_level,
	/client/proc/toggle_nuke,
	/client/proc/cmd_display_del_log,
	/client/proc/toggle_combo_hud,
	/client/proc/debug_huds,
	/client/proc/changeranks //NSV13
	))
GLOBAL_PROTECT(admin_verbs_hideable)

/client/proc/add_admin_verbs()
	if(holder)
		control_freak = CONTROL_FREAK_SKIN | CONTROL_FREAK_MACROS

		var/rights = holder.rank.rights
		add_verb(GLOB.admin_verbs_default)
		if(rights & R_BUILD)
			add_verb(/client/proc/togglebuildmodeself)
		if(rights & R_ADMIN)
			add_verb(GLOB.admin_verbs_admin)
		if(rights & R_BAN)
			add_verb(GLOB.admin_verbs_ban)
		if(rights & R_FUN)
			add_verb(GLOB.admin_verbs_fun)
		if(rights & R_SERVER)
			add_verb(GLOB.admin_verbs_server)
		if(rights & R_DEBUG)
			add_verb(GLOB.admin_verbs_debug)
		if(rights & R_POSSESS)
			add_verb(GLOB.admin_verbs_possess)
		if(rights & R_PERMISSIONS)
			add_verb(GLOB.admin_verbs_permissions)
		if(rights & R_STEALTH)
			add_verb(/client/proc/stealth)
		if(rights & R_ADMIN)
			add_verb(GLOB.admin_verbs_poll)
		if(rights & R_SOUND)
			add_verb(GLOB.admin_verbs_sounds)
			if(CONFIG_GET(string/invoke_youtubedl))
				add_verb(/client/proc/play_web_sound)
		if(rights & R_SPAWN)
			add_verb(GLOB.admin_verbs_spawn)
		reset_badges()

/client/proc/remove_admin_verbs()
	var/list/verb_list = list()
	verb_list.Add(
		GLOB.admin_verbs_default,
		/client/proc/togglebuildmodeself,
		GLOB.admin_verbs_admin,
		GLOB.admin_verbs_ban,
		GLOB.admin_verbs_fun,
		GLOB.admin_verbs_server,
		GLOB.admin_verbs_debug,
		GLOB.admin_verbs_possess,
		GLOB.admin_verbs_permissions,
		/client/proc/stealth,
		GLOB.admin_verbs_poll,
		GLOB.admin_verbs_sounds,
		/client/proc/play_web_sound,
		GLOB.admin_verbs_spawn,
		/*Debug verbs added by "show debug verbs"*/
		GLOB.admin_verbs_debug_mapping,
		/client/proc/disable_debug_verbs,
		/client/proc/readmin,
		/client/proc/fix_say
		)
	remove_verb(verb_list)
	reset_badges()

/client/proc/hide_most_verbs()//Allows you to keep some functionality while hiding some verbs
	set name = "Adminverbs - Hide Most"
	set category = "Admin"

	remove_verb(list(/client/proc/hide_most_verbs) + GLOB.admin_verbs_hideable)
	add_verb(/client/proc/show_verbs)

	to_chat(src, "<span class='interface'>Większość twoich czasowników admina została ukryta.</span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Hide Most Adminverbs") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/hide_verbs()
	set name = "Adminverbs - Hide All"
	set category = "Admin"

	remove_admin_verbs()
	add_verb(/client/proc/show_verbs)

	to_chat(src, "<span class='interface'>Prawie wszystkie twoje czasowniki admina zostały ukryte.</span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Hide All Adminverbs") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/show_verbs()
	set name = "Adminverbs - Show"
	set category = "Admin"

	remove_verb(/client/proc/show_verbs)
	add_admin_verbs()

	to_chat(src, "<span class='interface'>Wszystkie twoje czasowniki admina są teraz widoczne.</span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Adminverbs") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!




/client/proc/admin_ghost()
	set category = "Adminbus"
	set name = "Aghost"
	if(!holder)
		return
	. = TRUE
	if(isobserver(mob))
		//re-enter
		var/mob/dead/observer/ghost = mob
		if(!ghost.mind || !ghost.mind.current) //won't do anything if there is no body
			return FALSE
		if(!ghost.can_reenter_corpse)
			log_admin("[key_name(usr)] re-entered corpse")
			message_admins("[key_name_admin(usr)] wraca do ciała")
		ghost.can_reenter_corpse = 1 //force re-entering even when otherwise not possible
		ghost.reenter_corpse()
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Admin Reenter") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	else if(isnewplayer(mob))
		to_chat(src, "<font color='red'>Błąd: Aghost: nie możesz zostać admin-duchem w lobby. Najpierw dołącz lub obserwuj.</font>")
		return FALSE
	else
		//ghostize
		log_admin("[key_name(usr)] admin ghosted.")
		message_admins("[key_name_admin(usr)] zostaje admin-duchem.")
		var/mob/body = mob
		body.ghostize(TRUE)
		if(body && !body.key)
			body.key = "@[key]"	//Haaaaaaaack. But the people have spoken. If it breaks; blame adminbus
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Admin Ghost") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/invisimin()
	set name = "Invisimin"
	set category = "Admin"
	set desc = "Przełącza niewidzialność jak u ducha (nie nadużywaj)"
	if(holder && mob)
		if(mob.invisibility == INVISIBILITY_OBSERVER)
			mob.invisibility = initial(mob.invisibility)
			to_chat(mob, "<span class='boldannounce'>Invisimin wyłączony. Przywrócono widoczność.</span>")
		else
			mob.invisibility = INVISIBILITY_OBSERVER
			to_chat(mob, "<span class='adminnotice'><b>Invisimin włączony. Jesteś teraz niewidzialny jak duch.</b></span>")

/client/proc/fix_say()
	set name = "FIX SAY"
	set category = "Admin"
	set desc = "naprawia błąd, przez który ludzie nie mogą nic powiedzieć"
	for(var/x in GLOB.player_list)
		if(isnull(x))
			GLOB.player_list -= x

/client/proc/check_antagonists()
	set name = "Check Antagonists"
	set category = "Round"
	if(holder)
		holder.check_antagonists()
		log_admin("[key_name(usr)] checked antagonists.")	//for tsar~
		if(!isobserver(usr) && SSticker.HasRoundStarted())
			message_admins("[key_name_admin(usr)] sprawdza antagonistów.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check Antagonists") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/check_teams()
	set name = "Check Teams"
	set category = "Round"
	if(holder)
		holder.check_teams()
		log_admin("[key_name(usr)] checked antagonist teams.")
		if(!isobserver(usr) && SSticker.HasRoundStarted())
			message_admins("[key_name_admin(usr)] sprawdza drużyny antagonistów.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check Teams") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/ban_panel()
	set name = "Banning Panel"
	set category = "Admin"
	if(!check_rights(R_BAN))
		return
	holder.ban_panel()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Banning Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/unban_panel()
	set name = "Unbanning Panel"
	set category = "Admin"
	if(!check_rights(R_BAN))
		return
	holder.unban_panel()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Unbanning Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/game_panel()
	set name = "Game Panel"
	set category = "Adminbus"
	if(holder)
		holder.Game()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Game Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/secrets()
	set name = "Secrets"
	set category = "Adminbus"
	if (holder)
		GLOB.admin_secrets.ui_interact(usr)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Secrets Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/poll_panel()
	set name = "Server Poll Management"
	set category = "Admin"
	if(!check_rights(R_POLL))
		return
	holder.poll_list_panel()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Server Poll Management") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/findStealthKey(txt)
	if(txt)
		for(var/P in GLOB.stealthminID)
			if(GLOB.stealthminID[P] == txt)
				return P
	txt = GLOB.stealthminID[ckey]
	return txt

/client/proc/createStealthKey()
	var/num = (rand(0,1000))
	var/i = 0
	while(i == 0)
		i = 1
		for(var/P in GLOB.stealthminID)
			if(num == GLOB.stealthminID[P])
				num++
				i = 0
	GLOB.stealthminID["[ckey]"] = "@[num2text(num)]"

/client/proc/stealth()
	set category = "Admin"
	set name = "Stealth Mode"
	if(holder)
		if(holder.fakekey)
			holder.fakekey = null
			reset_badges()
			if(isobserver(mob))
				mob.invisibility = initial(mob.invisibility)
				mob.alpha = initial(mob.alpha)
				mob.name = initial(mob.name)
				mob.mouse_opacity = initial(mob.mouse_opacity)
		else
			var/new_key = ckeyEx(stripped_input(usr, "Podaj nazwę, która ma być wyświetlana.", "Fałszywy klucz", key, max_length=26))
			if(!new_key)
				return
			holder.fakekey = new_key
			reset_badges()
			createStealthKey()
			if(isobserver(mob))
				mob.invisibility = INVISIBILITY_MAXIMUM //JUST IN CASE
				mob.alpha = 0 //JUUUUST IN CASE
				mob.name = " "
				mob.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		log_admin("[key_name(usr)] has turned stealth mode [holder.fakekey ? "ON as [holder.fakekey]" : "OFF"]")
		message_admins("[key_name_admin(usr)] [holder.fakekey ? "włącza tryb ukryty jako [holder.fakekey]" : "wyłącza tryb ukryty"]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Stealth Mode") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/drop_bomb()
	set category = "Fun"
	set name = "Drop Bomb"
	set desc = "Wywołaj w swoim miejscu eksplozję o wybranej sile."

	var/list/choices = list("Mała bomba (1, 2, 3, 3)", "Średnia bomba (2, 3, 4, 4)", "Duża bomba (3, 5, 7, 5)", "Maxcap", "Własna bomba")
	var/choice = input("Jaki rozmiar eksplozji chcesz wywołać? UWAGA: możesz to wszystko robić szybko i w sposób IC (pociskami manewrującymi!) czasownikiem Config/Launch Supplypod. OSTRZEŻENIE: to pomija maxcap") as null|anything in choices
	var/turf/epicenter = mob.loc

	switch(choice)
		if(null)
			return 0
		if("Mała bomba (1, 2, 3, 3)")
			explosion(epicenter, 1, 2, 3, 3, TRUE, TRUE)
		if("Średnia bomba (2, 3, 4, 4)")
			explosion(epicenter, 2, 3, 4, 4, TRUE, TRUE)
		if("Duża bomba (3, 5, 7, 5)")
			explosion(epicenter, 3, 5, 7, 5, TRUE, TRUE)
		if("Maxcap")
			explosion(epicenter, GLOB.MAX_EX_DEVESTATION_RANGE, GLOB.MAX_EX_HEAVY_RANGE, GLOB.MAX_EX_LIGHT_RANGE, GLOB.MAX_EX_FLASH_RANGE)
		if("Własna bomba")
			var/devastation_range = input("Zasięg całkowitego zniszczenia (w polach):") as null|num
			if(devastation_range == null)
				return
			var/heavy_impact_range = input("Zasięg ciężkich uderzeń (w polach):") as null|num
			if(heavy_impact_range == null)
				return
			var/light_impact_range = input("Zasięg lekkich uderzeń (w polach):") as null|num
			if(light_impact_range == null)
				return
			var/flash_range = input("Zasięg błysku (w polach):") as null|num
			if(flash_range == null)
				return
			if(devastation_range > GLOB.MAX_EX_DEVESTATION_RANGE || heavy_impact_range > GLOB.MAX_EX_HEAVY_RANGE || light_impact_range > GLOB.MAX_EX_LIGHT_RANGE || flash_range > GLOB.MAX_EX_FLASH_RANGE)
				if(alert("Bomba jest większa niż maxcap. Kontynuować?",,"Tak","Nie") != "Tak")
					return
			epicenter = mob.loc //We need to reupdate as they may have moved again
			explosion(epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, TRUE, TRUE)
	message_admins("[ADMIN_LOOKUPFLW(usr)] wywołuje eksplozję admina w: [epicenter.loc].")
	log_admin("[key_name(usr)] created an admin explosion at [epicenter.loc].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Drop Bomb") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/drop_dynex_bomb()
	set category = "Fun"
	set name = "Drop DynEx Bomb"
	set desc = "Wywołaj w swoim miejscu eksplozję o wybranej sile."

	var/ex_power = input("Siła wybuchu:") as null|num
	var/turf/epicenter = mob.loc
	if(ex_power && epicenter)
		dyn_explosion(epicenter, ex_power)
		message_admins("[ADMIN_LOOKUPFLW(usr)] wywołuje eksplozję admina w: [epicenter.loc].")
		log_admin("[key_name(usr)] created an admin explosion at [epicenter.loc].")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Drop Dynamic Bomb") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/get_dynex_range()
	set category = "Debug"
	set name = "Get DynEx Range"
	set desc = "Oblicz szacowany zasięg bomby na podstawie siły wybuchu."

	var/ex_power = input("Siła wybuchu:") as null|num
	if (isnull(ex_power))
		return
	var/range = round((2 * ex_power)**GLOB.DYN_EX_SCALE)
	to_chat(usr, "Szacowany zasięg wybuchu: (zniszczenie: [round(range*0.25)], ciężki: [round(range*0.5)], lekki: [round(range)])")

/client/proc/get_dynex_power()
	set category = "Debug"
	set name = "Get DynEx Power"
	set desc = "Oblicz szacowaną siłę bomby potrzebną do osiągnięcia danego zasięgu."

	var/ex_range = input("Zasięg lekkiego wybuchu:") as null|num
	if (isnull(ex_range))
		return
	var/power = (0.5 * ex_range)**(1/GLOB.DYN_EX_SCALE)
	to_chat(usr, "Szacowana siła wybuchu: [power]")

/client/proc/set_dynex_scale()
	set category = "Debug"
	set name = "Set DynEx Scale"
	set desc = "Ustaw mnożnik skali eksplozji dynex. Domyślnie 0.5."

	var/ex_scale = input("Nowa skala DynEx:") as null|num
	if(!ex_scale)
		return
	GLOB.DYN_EX_SCALE = ex_scale
	log_admin("[key_name(usr)] has modified Dynamic Explosion Scale: [ex_scale]")
	message_admins("[key_name_admin(usr)] zmienia skalę dynamicznych eksplozji: [ex_scale]")

/client/proc/give_spell(mob/T in GLOB.mob_list)
	set category = "Fun"
	set name = "Give Spell"
	set desc = "Daje mobowi zaklęcie."

	var/list/spell_list = list()
	var/type_length = length_char("/obj/effect/proc_holder/spell") + 2
	for(var/A in GLOB.spells)
		spell_list[copytext_char("[A]", type_length)] = A
	var/obj/effect/proc_holder/spell/S = input("Wybierz zaklęcie, które chcesz mu dać", "ABRAKADABRA") as null|anything in sortList(spell_list)
	if(!S)
		return

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Give Spell") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] gave [key_name(T)] the spell [S].")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] daje [key_name_admin(T)] zaklęcie: [S].</span>")

	S = spell_list[S]
	if(T.mind)
		T.mind.AddSpell(new S)
	else
		T.AddSpell(new S)
		message_admins("<span class='danger'>Zaklęcia dane mobom bez umysłu nie zostaną przeniesione przy zamianie umysłów ani klonowaniu!</span>")

/client/proc/remove_spell(mob/T in GLOB.mob_list)
	set category = "Fun"
	set name = "Remove Spell"
	set desc = "Usuń zaklęcie wybranemu mobowi."

	if(T?.mind)
		var/obj/effect/proc_holder/spell/S = input("Wybierz zaklęcie do usunięcia", "NO ABRAKADABRA") as null|anything in sortList(T.mind.spell_list)
		if(S)
			T.mind.RemoveSpell(S)
			log_admin("[key_name(usr)] removed the spell [S] from [key_name(T)].")
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] zabiera [key_name_admin(T)] zaklęcie: [S].</span>")
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Remove Spell") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/give_disease(mob/living/T in GLOB.mob_living_list)
	set category = "Fun"
	set name = "Give Disease"
	set desc = "Daje mobowi chorobę."

	if(!istype(T))
		to_chat(src, "<span class='notice'>Chorobę możesz dać tylko mobowi typu /mob/living.</span>")
		return
	var/datum/disease/D = input("Wybierz chorobę, którą chcesz mu dać", "ACHOO") as null|anything in sortList(SSdisease.diseases, GLOBAL_PROC_REF(cmp_typepaths_asc))
	if(!D)
		return
	T.ForceContractDisease(new D, FALSE, TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Give Disease") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] gave [key_name(T)] the disease [D].")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] daje [key_name_admin(T)] chorobę: [D].</span>")

/client/proc/object_say(obj/O in world)
	set category = "Adminbus"
	set name = "OSay"
	set desc = "Sprawia, że obiekt coś mówi."
	var/message = capped_input(usr, "Jaka ma być wiadomość?", "Wydaj dźwięk")
	if(!message)
		return
	O.say(message)
	log_admin("[key_name(usr)] made [O] at [AREACOORD(O)] say \"[message]\"")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] każe obiektowi [O] w [AREACOORD(O)] powiedzieć: „[message]”</span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Object Say") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/togglebuildmodeself()
	set name = "Toggle Build Mode Self"
	set category = "Adminbus"
	if (!(holder.rank.rights & R_BUILD))
		return
	if(src.mob)
		togglebuildmode(src.mob)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Build Mode") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/check_ai_laws()
	set name = "Check AI Laws"
	set category = "Admin"
	if(holder)
		// AQUILA EDIT - panel praw TGUI (Lawpanel z tg) zamiast listy na czacie
		if(!isobserver(mob) && SSticker.HasRoundStarted())
			message_admins("[key_name_admin(src)] sprawdza prawa SI w panelu praw.")
		var/datum/law_panel/panel = new()
		panel.ui_interact(mob)

/client/proc/deadmin()
	set name = "Deadmin"
	set category = "Admin"
	set desc = "Zrzuć swoje uprawnienia admina."

	if(!holder)
		return

	if(has_antag_hud())
		toggle_combo_hud()

	holder.deactivate()

	to_chat(src, "<span class='interface'>Jesteś teraz zwykłym graczem.</span>")
	log_admin("[src] deadmined themself.")
	message_admins("[src] zrzeka się uprawnień admina.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Deadmin")

/client/proc/readmin()
	set name = "Readmin"
	set category = "Admin"
	set desc = "Odzyskaj swoje uprawnienia admina."

	var/datum/admins/A = GLOB.deadmins[ckey]

	if(!A)
		A = GLOB.admin_datums[ckey]
		if (!A)
			var/msg = " is trying to readmin but they have no deadmin entry"
			message_admins("[key_name_admin(src)][msg]")
			log_admin_private("[key_name(src)][msg]")
			return

	A.associate(src)

	if (!holder)
		return //This can happen if an admin attempts to vv themself into somebody elses's deadmin datum by getting ref via brute force

	to_chat(src, "<span class='interface'>Jesteś teraz adminem.</span>")
	message_admins("[src] odzyskuje uprawnienia admina.")
	log_admin("[src] re-adminned themselves.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Readmin")

/client/proc/populate_world(amount = 50 as num)
	set name = "Populate World"
	set category = "Debug"
	set desc = "(„liczba mobów do stworzenia”) Zaludnij świat testowymi mobami."

	if(amount > 0)
		var/area/area
		var/list/candidates
		var/turf/open/floor/tile
		var/j,k

		for(var/i = 1 to amount)
			j = 100

			do
				area = pick(GLOB.the_station_areas)

				if(area)

					candidates = get_area_turfs(area)

					if(candidates.len)
						k = 100

						do
							tile = pick(candidates)
						while ((!tile || !istype(tile)) && --k > 0)

						if(tile)
							var/mob/living/carbon/human/hooman = new(tile)
							hooman.equipOutfit(pick(subtypesof(/datum/outfit)))
							testing("Spawned test mob at [COORD(tile)]")
			while(!area && --j > 0)

/client/proc/toggle_AI_interact()
	set name = "Toggle Admin AI Interact"
	set category = "Adminbus"
	set desc = "Pozwala ci jako duchowi obsługiwać większość maszyn tak jak SI"

	AI_Interact = !AI_Interact
	if(mob && IsAdminGhost(mob))
		mob.has_unlimited_silicon_privilege = AI_Interact

	log_admin("[key_name(usr)] has [AI_Interact ? "activated" : "deactivated"] Admin AI Interact")
	message_admins("[key_name_admin(usr)] [AI_Interact ? "włącza" : "wyłącza"] sobie interakcję jak SI")



/client/proc/stabilize_atmos()
	set name = "Stabilize Atmos"
	set category = "Adminbus"
	set desc = "Przywraca normalne powietrze na każdym polu w zasięgu wzroku. Zamyka wszystkie kanistry w zasięgu wzroku."

	if(!check_rights(R_ADMIN))
		return

	var/turf/T = get_turf(usr.loc)
	message_admins("[key_name_admin(usr)] stabilizuje atmosferę w [AREACOORD(T)]")
	log_game("[key_name_admin(usr)] stabilized atmos at [AREACOORD(T)]")

	var/datum/gas_mixture/GM = new
	for(var/turf/open/F in view())
		if(F.blocks_air)
		//skip walls
			continue
		GM.parse_gas_string(F.initial_gas_mix)
		F.copy_air(GM)
		F.update_visuals()

	for(var/obj/machinery/portable_atmospherics/canister/can in view())
		can.valve_open = FALSE
		can.update_icon()

/client/proc/library_control()
	set category = "Admin"
	set name = "Library Management"
	set desc = "Przeglądaj bibliotekę i nią zarządzaj."

	if(!check_rights(R_ADMIN))
		return

	if(!holder.library_manager)
		holder.library_manager = new
	holder.library_manager.ui_interact(mob)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Library Management") // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

#ifdef SENDMAPS_PROFILE
/client/proc/display_sendmaps()
	set name = "Send Maps Profile"
	set category = "Debug"

	src << link("?debug=profile&type=sendmaps&window=test")
#endif
