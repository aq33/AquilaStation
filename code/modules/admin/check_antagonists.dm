//I wish we had interfaces sigh, and i'm not sure giving team and antag common root is a better solution here
// AQUILA EDIT - Check Antagonists / Round Status w TGUI (okno "CheckAntagonists"). Wpisy listy to dane, a nie HTML.

//Name shown on antag list
/datum/antagonist/proc/antag_listing_name()
	if(!owner)
		return "Nieprzypisany"
	if(owner.current)
		return owner.current.real_name
	return owner.name

//Whatever interesting things happened to the antag admins should know about
//Include additional information about antag in this part
/datum/antagonist/proc/antag_listing_status()
	if(!owner)
		return "(Nieprzypisany)"
	if(!owner.current)
		return "(Ciało zniszczone)"
	if(owner.current.stat == DEAD)
		return "(MARTWY)"
	if(!owner.current.client)
		return "(Brak klienta)"
	return ""

/// Wpis antagonisty na liście: nazwa, stan i odnośniki do akcji admina
/datum/antagonist/proc/antag_listing_entry()
	var/list/entry = list()
	if(show_name_in_check_antagonists)
		entry["name"] = "[antag_listing_name()] ([name])"
	else
		entry["name"] = antag_listing_name()
	entry["status"] = antag_listing_status()
	entry["bad"] = !owner?.current || owner.current.stat == DEAD
	entry["mob_ref"] = owner?.current ? REF(owner.current) : null
	entry["mind_ref"] = owner ? REF(owner) : null
	entry["ckey"] = owner ? ckey(owner.key) : null
	return entry


/datum/team/proc/get_team_antags(antag_type,specific = FALSE)
	. = list()
	for(var/datum/antagonist/A in GLOB.antagonists)
		if(A.get_team() == src && (!antag_type || !specific && istype(A,antag_type) || specific && A.type == antag_type))
			. += A

/// Sekcja drużyny: nazwa, członkowie i dodatkowe tabelki (np. dyski nuklearne, głowy stacji)
/// Wiersz dodatkowej tabelki: list("text", "pp_ref", "follow_ref", "vv_ref", "ckey")
/datum/team/proc/antag_listing_entry()
	var/list/antags = list()
	for(var/datum/antagonist/A in get_team_antags())
		antags += list(A.antag_listing_entry())
	return list(
		"title" = antag_listing_name(),
		"antags" = antags,
		"extra" = list(),
	)

/datum/team/proc/antag_listing_name()
	return name

//Moves them to the top of the list if TRUE
/datum/antagonist/proc/is_gamemode_hero()
	return FALSE

/datum/team/proc/is_gamemode_hero()
	return FALSE

/datum/admins/proc/build_antag_listing()
	var/list/sections = list()
	var/list/priority_sections = list()

	var/list/all_teams = list()
	var/list/all_antagonists = list()

	for(var/datum/antagonist/A in GLOB.antagonists)
		if(!A.owner)
			continue
		all_teams |= A.get_team()
		all_antagonists += A

	for(var/datum/team/T in all_teams)
		for(var/datum/antagonist/X in all_antagonists)
			if(X.get_team() == T)
				all_antagonists -= X
		if(T.is_gamemode_hero())
			priority_sections += list(T.antag_listing_entry())
		else
			sections += list(T.antag_listing_entry())

	sortTim(all_antagonists, GLOBAL_PROC_REF(cmp_antag_category))

	var/list/current_section
	for(var/i in 1 to all_antagonists.len)
		var/datum/antagonist/current_antag = all_antagonists[i]
		var/datum/antagonist/next_antag
		if(i < all_antagonists.len)
			next_antag = all_antagonists[i+1]
		if(!current_section)
			current_section = list(
				"title" = capitalize(current_antag.roundend_category),
				"antags" = list(),
				"extra" = list(),
			)
		var/list/section_antags = current_section["antags"]
		section_antags += list(current_antag.antag_listing_entry()) // Name - (Traitor) - FLW | PM | TP

		if(!next_antag || next_antag.roundend_category != current_antag.roundend_category) //End of section
			if(current_antag.is_gamemode_hero())
				priority_sections += list(current_section)
			else
				sections += list(current_section)
			current_section = null
	return priority_sections + sections

/datum/admins/proc/check_antagonists()
	if(!SSticker.HasRoundStarted())
		alert("Gra jeszcze się nie zaczęła!")
		return
	if(!check_antagonists_ui)
		check_antagonists_ui = new(src)
	check_antagonists_ui.ui_interact(usr)

/datum/admins
	/// AQUILA - okno TGUI Check Antagonists
	var/datum/check_antagonists_ui/check_antagonists_ui

/datum/check_antagonists_ui
	var/datum/admins/holder

/datum/check_antagonists_ui/New(datum/admins/holder)
	. = ..()
	src.holder = holder

/datum/check_antagonists_ui/Destroy(force)
	if(holder?.check_antagonists_ui == src)
		holder.check_antagonists_ui = null
	holder = null
	return ..()

/datum/check_antagonists_ui/ui_state(mob/user)
	return GLOB.admin_state

/datum/check_antagonists_ui/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CheckAntagonists")
		ui.open()

/datum/check_antagonists_ui/ui_data(mob/user)
	var/list/data = list()
	if(!SSticker.HasRoundStarted() || !SSticker.mode)
		data["round_started"] = FALSE
		return data
	data["round_started"] = TRUE
	data["mode_name"] = SSticker.mode.name
	data["replacement_mode_name"] = SSticker.mode.replacementmode?.name
	data["round_duration"] = time2text(world.timeofday - SSticker.round_start_timeofday, "hh:mm:ss", 0)

	// Prom ewakuacyjny
	var/list/shuttle = list()
	shuttle["idle_or_recalled"] = !!EMERGENCY_IDLE_OR_RECALLED
	if(SSshuttle.emergency && !EMERGENCY_IDLE_OR_RECALLED)
		var/timeleft = SSshuttle.emergency.timeLeft()
		shuttle["eta"] = "[(timeleft / 60) % 60]:[add_leading(num2text(timeleft % 60), 2, "0")]"
		shuttle["called"] = SSshuttle.emergency.mode == SHUTTLE_CALL
	data["shuttle"] = shuttle

	// Ciągłość rundy
	var/config_tag = SSticker.mode.config_tag
	var/continuous = !!CONFIG_GET(keyed_list/continuous)[config_tag]
	var/midround_antag = !!CONFIG_GET(keyed_list/midround_antag)[config_tag]
	data["continuous"] = continuous
	data["midround_antag"] = midround_antag
	data["midround_time_limit"] = CONFIG_GET(number/midround_antag_time_check)
	data["midround_life_limit"] = CONFIG_GET(number/midround_antag_life_check) * 100
	data["round_ends_with_antag_death"] = !!SSticker.mode.round_ends_with_antag_death
	data["delay_end"] = !!SSticker.delay_end

	// Statystyki graczy
	var/connected_players = GLOB.clients.len
	var/lobby_players = 0
	var/observers = 0
	var/observers_connected = 0
	var/living_players = 0
	var/living_players_connected = 0
	var/living_players_antagonist = 0
	var/brains = 0
	var/other_players = 0
	var/living_skipped = 0
	var/drones = 0
	for(var/mob/M in GLOB.mob_list)
		if(M.ckey)
			if(isnewplayer(M))
				lobby_players++
				continue
			else if(M.stat != DEAD && M.mind && !isbrain(M))
				if(isdrone(M))
					drones++
					continue
				if(is_centcom_level(M.z))
					living_skipped++
					continue
				living_players++
				if(M.mind.special_role)
					living_players_antagonist++
				if(M.client)
					living_players_connected++
			else if(M.stat == DEAD || isobserver(M))
				observers++
				if(M.client)
					observers_connected++
			else if(isbrain(M))
				brains++
			else
				other_players++
	data["stats"] = list(
		"ingame" = connected_players - lobby_players,
		"connected" = connected_players,
		"lobby" = lobby_players,
		"living_active" = living_players_connected,
		"living_disconnected" = living_players - living_players_connected,
		"living_antags" = living_players_antagonist,
		"skipped_living" = living_skipped,
		"skipped_drones" = drones,
		"dead_active" = observers_connected,
		"dead_disconnected" = observers - observers_connected,
		"brains" = brains,
		"other" = other_players,
	)

	data["sections"] = holder.build_antag_listing()
	return data

/datum/check_antagonists_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!check_rights(R_ADMIN))
		return
	switch(action)
		if("call_shuttle")
			holder.ui_topic(list("call_shuttle" = params["send_back"] ? "2" : "1"))
			return TRUE
		if("end_round")
			holder.ui_topic(list("end_round" = REF(usr)))
			return TRUE
		if("check_teams")
			holder.ui_topic(list("check_teams" = "1"))
			return
		if("edit_shuttle_time", "toggle_continuous", "toggle_midround_antag", "alter_midround_time_limit", "alter_midround_life_limit", "toggle_noncontinuous_behavior", "delay_round_end")
			holder.ui_topic(list("[action]" = "1"))
			return TRUE
	return holder.ui_common_action(action, params)
