GLOBAL_LIST_EMPTY(preferences_datums)

/datum/preferences
	var/client/parent

	var/default_slot = 1				//Holder so it doesn't default to slot 1, rather the last one used
	// TREAT THIS VAR AS PRIVATE. USE set_max_character_slots() PLEASE
	var/max_usable_slots = 3

	//non-preference stuff
	var/muted = 0
	var/last_ip
	var/last_id

	/// List of all character saves, with list index being slot ID
	var/list/datum/character_save/character_saves = list()
	/// Active character, ref to an item in that list
	var/datum/character_save/active_character

	//game-preferences
	var/lastchangelog = ""				//Saved changlog filesize to detect if there was a change
	var/ooccolor = "#c43b23"
	var/asaycolor = "#ff4500"			//This won't change the color for current admins, only incoming ones.
	var/tip_delay = 500 //tip delay in milliseconds
	var/tesla_volume = 100 //Volume (0-100) of tesla/lightning sounds
	/// Which click (MIDDLE_CLICK or ALT_CLICK) uses the active MODsuit module
	var/mod_select = MIDDLE_CLICK

	//Antag preferences
	var/list/role_preferences = list()		//Special role selection

	var/UI_style = null
	var/outline_color = COLOR_BLUE_GRAY

	///Whether we want balloon alerts displayed alone, with chat or not displayed at all
	var/see_balloon_alerts = BALLOON_ALERT_ALWAYS

	var/toggles = TOGGLES_DEFAULT
	var/toggles2 = TOGGLES_2_DEFAULT
	var/db_flags
	var/chat_toggles = TOGGLES_DEFAULT_CHAT
	var/ghost_form = "ghost"
	var/ghost_orbit = GHOST_ORBIT_CIRCLE
	var/ghost_accs = GHOST_ACCS_DEFAULT_OPTION
	var/ghost_others = GHOST_OTHERS_DEFAULT_OPTION
	var/preferred_map = null
	var/pda_theme = THEME_NTOS
	var/pda_color = "#808000"

	// Custom Keybindings
	var/list/key_bindings = null

	// 0 = character settings, 1 = game preferences
	var/current_tab = 0

	var/unlock_content = 0

	var/list/ignoring = list()

	var/clientfps = 60
	var/updated_fps = 0

	var/parallax

	///What size should pixels be displayed as? 0 is strech to fit
	var/pixel_size = 0
	///What scaling method should we use?
	var/scaling_method = "normal"

	var/list/exp = list()
	var/job_exempt = 0

	//Loadout stuff
	var/list/purchased_gear = list()
	var/gear_tab = "General"

	var/action_buttons_screen_locs = list()
	//Nsv13 - Syndicate role select
	var/preferred_syndie_role = CONQUEST_ROLE_GRUNT
	//NSV13 - AI Custom Holographic Form - Start
	var/icon/custom_holoform_icon
	var/list/cached_holoform_icons
	var/last_custom_holoform = 0
	//NSV13 - AI Custom Holographic Form - End

/datum/preferences/proc/set_max_character_slots(newmax)
	max_usable_slots = min(TRUE_MAX_SAVE_SLOTS, newmax) // Make sure they dont go over
	check_usable_slots()

/datum/preferences/New(client/C)
	parent = C

	character_saves.len = TRUE_MAX_SAVE_SLOTS
	for(var/i in 1 to TRUE_MAX_SAVE_SLOTS)
		var/datum/character_save/CS = new()
		CS.slot_number = i
		character_saves[i] = CS

	UI_style = GLOB.available_ui_styles[1]
	if(istype(C))
		if(!IS_GUEST_KEY(C.key))
			unlock_content = C.IsByondMember()
			if(unlock_content)
				set_max_character_slots(8)
		else if(!length(key_bindings)) // Guests need default keybinds
			key_bindings = deepCopyList(GLOB.keybinding_list_by_key)
	var/loaded_preferences_successfully = load_from_database()
	if(loaded_preferences_successfully)
		if("6030fe461e610e2be3a2c3e75c06067e" in purchased_gear) //MD5 hash of, "extra character slot"
			set_max_character_slots(max_usable_slots + 1)
		if(load_characters()) // inside this proc is a disgusting SQL query
			var/datum/character_save/target_save = character_saves[default_slot]
			if(target_save && !target_save.slot_locked)
				active_character = target_save
			else
				active_character = character_saves[1] // Default to first if unavailable
				default_slot = 1
			// AQ EDIT - the default slot may never have been saved (empty slot), give it a body instead of leaving it broken
			active_character.ensure_valid(C)
			return

	//we couldn't load character data so just randomize the character appearance + name
	active_character = character_saves[1]
	active_character.randomise()		//let's create a random character then - rather than a fat, bald and naked man.
	active_character.real_name = active_character.pref_species.random_name(active_character.gender, TRUE)
	if(!loaded_preferences_successfully)
		save_preferences()
	active_character.save(C)		//let's save this new random character so it doesn't keep generating new ones.
	return

// AQ EDIT - stare okna HTML (ShowChoices, SetChoices, SetQuirks, ShowKeybindings, CaptureKeybinding) i ich Topic (process_link) usunięte:
// wszystko to robi okno TGUI PreferencesMenu (aquila/code/modules/client/preferences_menu/).

/datum/preferences/proc/SetJobPreferenceLevel(datum/job/job, level)
	if (!job)
		return FALSE

	if (level == JP_HIGH) // to high
		//Set all other high to medium
		for(var/j in active_character.job_preferences)
			if(active_character.job_preferences[j] == JP_HIGH)
				active_character.job_preferences[j] = JP_MEDIUM
				//technically break here

	active_character.job_preferences[job.title] = level
	return TRUE




/datum/preferences/proc/ResetJobs()
	active_character.job_preferences = list()

/datum/preferences/proc/GetQuirkBalance()
	var/bal = 0
	for(var/V in active_character.all_quirks)
		var/datum/quirk/T = SSquirks.quirks[V]
		bal -= initial(T.value)
	return bal

/datum/preferences/proc/GetPositiveQuirkCount()
	. = 0
	for(var/q in active_character.all_quirks)
		if(SSquirks.quirk_points[q] > 0)
			.++

/datum/preferences/proc/ask_for_custom_name(mob/user,name_id)
	var/namedata = GLOB.preferences_custom_names[name_id]
	if(!namedata)
		return

	var/raw_name = capped_input(user, "Wybierz [namedata["qdesc"]] postaci:","Preferencje postaci")
	if(!raw_name)
		if(namedata["allow_null"])
			active_character.custom_names[name_id] = get_default_name(name_id)
		else
			return
	else
		var/sanitized_name = reject_bad_name(raw_name,namedata["allow_numbers"])
		if(!sanitized_name)
			to_chat(user, "<font color='red'>Nieprawidłowe imię. Imię musi mieć od 2 do [MAX_NAME_LEN] znaków i może zawierać tylko litery A-Z, a-z,[namedata["allow_numbers"] ? ",0-9," : ""] -, ' i .</font>")
			return
		else
			active_character.custom_names[name_id] = sanitized_name

/// Handles adding and removing donator items from clients
/datum/preferences/proc/handle_donator_items()
	var/datum/loadout_category/DLC = GLOB.loadout_categories["Donator"] // stands for donator loadout category but the other def for DLC works too xD
	if(!LAZYLEN(GLOB.patrons) || !CONFIG_GET(flag/donator_items)) // donator items are only accesibile by servers with a patreon
		return
	if(IS_PATRON(parent.ckey) || (parent in GLOB.admins))
		for(var/gear_id in DLC.gear)
			var/datum/gear/AG = DLC.gear[gear_id]
			if(AG.id in purchased_gear)
				continue
			purchased_gear += AG.id
			AG.purchase(parent)
		save_preferences()
	else if(length(purchased_gear) || length(active_character.equipped_gear))
		for(var/gear_id in DLC.gear)
			var/datum/gear/RG = DLC.gear[gear_id]
			active_character.equipped_gear -= RG.id
			purchased_gear -= RG.id
		save_preferences()

//NSV13 - AI Custom Holographic Form
/datum/preferences/proc/get_filtered_holoform(filter_type)
	if(!custom_holoform_icon)
		return
	LAZYINITLIST(cached_holoform_icons)
	if(!cached_holoform_icons[filter_type])
		cached_holoform_icons[filter_type] = process_holoform_icon_filter(custom_holoform_icon, filter_type)
	return cached_holoform_icons[filter_type]

///Returns the 0-100 volume the client set for the given VOLUME_PREF_* category
/datum/preferences/proc/get_volume_pref(volume_pref)
	switch(volume_pref)
		if(VOLUME_PREF_TESLA)
			return tesla_volume
	return 100
