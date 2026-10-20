/mob/living/silicon
	gender = NEUTER
	has_unlimited_silicon_privilege = 1
	verb_say = "stwierdza"
	verb_ask = "pyta"
	verb_exclaim = "oznajmia"
	verb_yell = "alarmuje"
	initial_language_holder = /datum/language_holder/synthetic
	see_in_dark = 8
	bubble_icon = "machine"
	weather_immunities = list("ash")
	possible_a_intents = list(INTENT_HELP, INTENT_HARM)
	mob_biotypes = list(MOB_ROBOTIC)
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	rad_flags = RAD_PROTECT_CONTENTS | RAD_NO_CONTAMINATE
	deathsound = 'aquila/sound/voice/borg_deathsound.ogg' //AQUILA EDIT original was sound/voice/borg_deathsound.ogg
	speech_span = SPAN_ROBOT
	var/datum/ai_laws/laws = null//Now... THEY ALL CAN ALL HAVE LAWS
	var/last_lawchange_announce = 0
	var/list/alarms_to_show = list()
	var/list/alarms_to_clear = list()
	var/designation = ""
	var/radiomod = "" //Radio character used before state laws/arrivals announce to allow department transmissions, default, or none at all.
	var/obj/item/camera/siliconcam/aicamera = null //photography
	hud_possible = list(ANTAG_HUD, DIAG_STAT_HUD, DIAG_HUD, DIAG_TRACK_HUD)

	var/obj/item/radio/borg/radio = null //All silicons make use of this, with (p)AI's creating headsets

	var/list/alarm_types_show = list("Motion" = 0, "Fire" = 0, "Atmosphere" = 0, "Power" = 0, "Camera" = 0)
	var/list/alarm_types_clear = list("Motion" = 0, "Fire" = 0, "Atmosphere" = 0, "Power" = 0, "Camera" = 0)

	var/lawcheck[1]
	var/ioncheck[1]
	var/hackedcheck[1]
	var/devillawcheck[5]

	/// Are our siliconHUDs on? TRUE for yes, FALSE for no.
	var/sensors_on = TRUE
	var/med_hud = DATA_HUD_MEDICAL_ADVANCED //Determines the med hud to use
	var/sec_hud = DATA_HUD_SECURITY_ADVANCED //Determines the sec hud to use
	var/d_hud = DATA_HUD_DIAGNOSTIC_BASIC //Determines the diag hud to use

	var/law_change_counter = 0
	var/obj/machinery/camera/builtInCamera = null
	var/updating = FALSE //portable camera camerachunk update

	var/hack_software = FALSE //Will be able to use hacking actions
	var/interaction_range = 7			//wireless control range
	///The reference to the built-in tablet that borgs carry.
	var/obj/item/modular_computer/tablet/integrated/modularInterface

	//The internal ID card inside the AI.
	var/list/default_access_list = list()
	var/obj/item/card/id/internal_id_card
	var/currently_stating_laws = FALSE
	/// AQUILA - okno TGUI wyboru ogłaszanych praw
	var/datum/state_laws_ui/state_laws_ui

	mobchatspan = "centcom"

	//NSV13 - Roleplay Stuff
	var/datum/examine_panel/tgui = new() //create the datum

/mob/living/silicon/Initialize(mapload)
	. = ..()
	GLOB.silicon_mobs += src
	faction += "silicon"
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_to_hud(src)
	diag_hud_set_status()
	diag_hud_set_health()
	add_sensors()
	create_access_card(default_access_list)
	default_access_list = null

/mob/living/silicon/proc/create_access_card(list/access_list)
	if(!internal_id_card)
		internal_id_card = new()
		internal_id_card.name = "[src] internal access"
	internal_id_card.access |= access_list

/mob/living/silicon/proc/create_modularInterface()
	if(!modularInterface)
		modularInterface = new /obj/item/modular_computer/tablet/integrated(src)
	modularInterface.layer = ABOVE_HUD_PLANE
	modularInterface.plane = ABOVE_HUD_PLANE
	modularInterface.saved_identification = real_name || name
	if(iscyborg(src))
		modularInterface.saved_job = JOB_NAME_CYBORG
		modularInterface.install_component(new /obj/item/computer_hardware/hard_drive/small/pda/robot)
	if(isAI(src))
		modularInterface.saved_job = JOB_NAME_AI
		modularInterface.install_component(new /obj/item/computer_hardware/hard_drive/small/pda/ai)
	if(ispAI(src))
		modularInterface.saved_job = JOB_NAME_PAI
		modularInterface.install_component(new /obj/item/computer_hardware/hard_drive/small/pda/ai)

/mob/living/silicon/robot/model/syndicate/create_modularInterface()
	if(!modularInterface)
		modularInterface = new /obj/item/modular_computer/tablet/integrated/syndicate(src)
		modularInterface.saved_identification = real_name
		modularInterface.saved_job = JOB_NAME_CYBORG
	return ..()


/mob/living/silicon/med_hud_set_health()
	return //we use a different hud

/mob/living/silicon/med_hud_set_status()
	return //we use a different hud

/mob/living/silicon/Destroy()
	radio = null
	aicamera = null
	QDEL_NULL(builtInCamera)
	QDEL_NULL(internal_id_card)
	QDEL_NULL(state_laws_ui) // AQUILA EDIT
	GLOB.silicon_mobs -= src
	return ..()

/mob/living/silicon/contents_explosion(severity, target)
	return

/mob/living/silicon/proc/cancelAlarm()
	return

/mob/living/silicon/proc/freeCamera()
	return

/mob/living/silicon/proc/triggerAlarm()
	return

/mob/living/silicon/proc/queueAlarm(message, type, incoming = 1)
	var/in_cooldown = (alarms_to_show.len > 0 || alarms_to_clear.len > 0)
	if(incoming)
		alarms_to_show += message
		alarm_types_show[type] += 1
	else
		alarms_to_clear += message
		alarm_types_clear[type] += 1

	if(!in_cooldown)
		addtimer(CALLBACK(src, PROC_REF(handle_alarms)), 30) //3 second cooldown

/mob/living/silicon/proc/handle_alarms()
	if(alarms_to_show.len < 5)
		for(var/msg in alarms_to_show)
			to_chat(src, msg)
	else if(alarms_to_show.len)

		var/msg = "--- "

		if(alarm_types_show["Burglar"])
			msg += "WŁAMANIE: wykryte alarmy: [alarm_types_show["Burglar"]]. - "

		if(alarm_types_show["Motion"])
			msg += "RUCH: wykryte alarmy: [alarm_types_show["Motion"]]. - "

		if(alarm_types_show["Fire"])
			msg += "POŻAR: wykryte alarmy: [alarm_types_show["Fire"]]. - "

		if(alarm_types_show["Atmosphere"])
			msg += "ATMOSFERA: wykryte alarmy: [alarm_types_show["Atmosphere"]]. - "

		if(alarm_types_show["Power"])
			msg += "ZASILANIE: wykryte alarmy: [alarm_types_show["Power"]]. - "

		if(alarm_types_show["Camera"])
			msg += "KAMERY: wykryte alarmy: [alarm_types_show["Camera"]]. - "

		msg += "<A href=byond://?src=[REF(src)];showalerts=1'>\[Show Alerts\]</a>"
		to_chat(src, msg)

	if(alarms_to_clear.len < 3)
		for(var/msg in alarms_to_clear)
			to_chat(src, msg)

	else if(alarms_to_clear.len)
		var/msg = "--- "

		if(alarm_types_clear["Motion"])
			msg += "RUCH: odwołane alarmy: [alarm_types_clear["Motion"]]. - "

		if(alarm_types_clear["Fire"])
			msg += "POŻAR: odwołane alarmy: [alarm_types_clear["Fire"]]. - "

		if(alarm_types_clear["Atmosphere"])
			msg += "ATMOSFERA: odwołane alarmy: [alarm_types_clear["Atmosphere"]]. - "

		if(alarm_types_clear["Power"])
			msg += "ZASILANIE: odwołane alarmy: [alarm_types_clear["Power"]]. - "

		if(alarm_types_show["Camera"])
			msg += "KAMERY: odwołane alarmy: [alarm_types_clear["Camera"]]. - "

		msg += "<A href=byond://?src=[REF(src)];showalerts=1'>\[Show Alerts\]</a>"
		to_chat(src, msg)

	alarms_to_show = list()
	alarms_to_clear = list()
	for(var/key in alarm_types_show)
		alarm_types_show[key] = 0
	for(var/key in alarm_types_clear)
		alarm_types_clear[key] = 0

/mob/living/silicon/can_inject(mob/user, error_msg)
	if(error_msg)
		to_chat(user, "<span class='alert'>Zewnętrzna powłoka jest zbyt wytrzymała.</span>")
	return FALSE

/mob/living/silicon/IsAdvancedToolUser()
	return TRUE

/proc/islinked(mob/living/silicon/robot/bot, mob/living/silicon/ai/ai)
	if(!istype(bot) || !istype(ai))
		return FALSE
	if(bot.connected_ai == ai)
		return TRUE
	return FALSE

/mob/living/silicon/Topic(href, href_list)
	// AQUILA EDIT - przełączniki praw do ogłoszenia są teraz w oknie TGUI (/datum/state_laws_ui)

	if (href_list["printlawtext"]) // this is kinda backwards
		to_chat(usr, href_list["printlawtext"])

	//NSV13 - Silicon Flavor Text - Start
	if(href_list["lookup_info"])
		tgui.holder = src
		tgui.ui_interact(usr) //datum has a tgui component, here we open the window
	//NSV13 - Silicon Flavor Text - End
	return


/mob/living/silicon/proc/statelaws(force = 0)
	var/mob/living/silicon/S = usr
	var/total_laws_count = 0
	currently_stating_laws = TRUE

	//"radiomod" is inserted before a hardcoded message to change if and how it is handled by an internal radio.
	say("[radiomod] Obecnie obowiązujące prawa:")
	S.client.silicon_spam_grace()
	//laws_sanity_check()
	//laws.show_laws(world)
	var/number = 1
	sleep(10)

	if (laws.devillaws?.len)
		for(var/index = 1, index <= laws.devillaws.len, index++)
			if (force || devillawcheck[index] == "Yes")
				say("[radiomod] 666. [laws.devillaws[index]]")
				S.client.silicon_spam_grace()
				total_laws_count++
				sleep(10)


	if (laws.zeroth)
		if (force || lawcheck[1] == "Yes")
			say("[radiomod] 0. [laws.zeroth]")
			S.client.silicon_spam_grace()
			total_laws_count++
			sleep(10)

	for (var/index = 1, index <= laws.hacked.len, index++)
		var/law = laws.hacked[index]
		var/num = ion_num()
		if (length(law) > 0)
			if (force || hackedcheck[index] == "Yes")
				say("[radiomod] [num]. [law]")
				S.client.silicon_spam_grace()
				total_laws_count++
				sleep(10)

	for (var/index = 1, index <= laws.ion.len, index++)
		var/law = laws.ion[index]
		var/num = ion_num()
		if (length(law) > 0)
			if (force || ioncheck[index] == "Yes")
				say("[radiomod] [num]. [law]")
				S.client.silicon_spam_grace()
				total_laws_count++
				sleep(10)

	for (var/index = 1, index <= laws.inherent.len, index++)
		var/law = laws.inherent[index]

		if (length(law) > 0)
			if (force || lawcheck[index+1] == "Yes")
				say("[radiomod] [number]. [law]")
				S.client.silicon_spam_grace()
				total_laws_count++
				number++
				sleep(10)

	for (var/index = 1, index <= laws.supplied.len, index++)
		var/law = laws.supplied[index]

		if (length(law) > 0)
			if(lawcheck.len >= number+1)
				if (force || lawcheck[number+1] == "Yes")
					say("[radiomod] [number]. [law]")
					S.client.silicon_spam_grace()
					total_laws_count++
					number++
					sleep(10)

	S.client.silicon_spam_grace_done(total_laws_count)
	currently_stating_laws = FALSE

/mob/living/silicon/proc/checklaws() //Gives you a link-driven interface for deciding what laws the statelaws() proc will share with the crew. --NeoFite
	// AQUILA EDIT - okno TGUI (StateLawUi z tg) zamiast starego okna HTML
	laws_sanity_check()
	if(!state_laws_ui)
		state_laws_ui = new(src)
	state_laws_ui.ui_interact(src)

/// AQUILA - okno wyboru ogłaszanych praw (port StateLawUi z tg), działa na lawcheck/ioncheck/hackedcheck/devillawcheck
/datum/state_laws_ui
	var/mob/living/silicon/owner
	/// Numery praw jonowych/zhakowanych, żeby nie losowały się przy każdym odświeżeniu okna
	var/list/cached_ion_nums = list()

/datum/state_laws_ui/New(mob/living/silicon/new_owner)
	owner = new_owner

/datum/state_laws_ui/Destroy()
	owner = null
	return ..()

/datum/state_laws_ui/ui_state(mob/user)
	return GLOB.not_incapacitated_state

/datum/state_laws_ui/ui_interact(mob/user, datum/tgui/ui)
	if(user != owner)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "StateLawUi")
		ui.open()

/datum/state_laws_ui/proc/get_ion_num(law)
	if(!cached_ion_nums[law])
		cached_ion_nums[law] = ion_num()
	return cached_ion_nums[law]

/datum/state_laws_ui/proc/law_entry(text, number, type, category, index, check)
	return list(list(
		"text" = text,
		"number" = number,
		"type" = type,
		"category" = category,
		"index" = index,
		"checked" = (check == "Yes"),
	))

/// Zbiera prawa w tej samej kolejności i z tymi samymi domyślnymi wartościami co dawne checklaws()
/datum/state_laws_ui/proc/get_laws_ui_data()
	var/list/law_data = list()
	var/datum/ai_laws/L = owner?.laws
	if(!L)
		return law_data

	if(length(L.devillaws))
		if(length(owner.devillawcheck) < length(L.devillaws))
			owner.devillawcheck.len = length(L.devillaws)
		for(var/index in 1 to length(L.devillaws))
			if(!owner.devillawcheck[index])
				owner.devillawcheck[index] = "No"
			law_data += law_entry(L.devillaws[index], "666", LAW_DEVIL, "devil", index, owner.devillawcheck[index])

	if(L.zeroth)
		if(!owner.lawcheck[1])
			owner.lawcheck[1] = "No" //Given Law 0's usual nature, it defaults to NOT getting reported. --NeoFite
		law_data += law_entry(L.zeroth, "0", LAW_ZEROTH, "law", 0, owner.lawcheck[1])

	for(var/index in 1 to length(L.hacked))
		var/law = L.hacked[index]
		if(!length(law))
			continue
		if(length(owner.hackedcheck) < index)
			owner.hackedcheck.len = index
		if(!owner.hackedcheck[index])
			owner.hackedcheck[index] = "No"
		law_data += law_entry(law, get_ion_num(law), LAW_HACKED, "hacked", index, owner.hackedcheck[index])

	for(var/index in 1 to length(L.ion))
		var/law = L.ion[index]
		if(!length(law))
			continue
		if(length(owner.ioncheck) < index)
			owner.ioncheck.len = index
		if(!owner.ioncheck[index])
			owner.ioncheck[index] = "Yes"
		law_data += law_entry(law, get_ion_num(law), LAW_ION, "ion", index, owner.ioncheck[index])

	var/number = 1
	for(var/law in L.inherent)
		if(!length(law))
			continue
		if(length(owner.lawcheck) < number + 1)
			owner.lawcheck.len = number + 1
		if(!owner.lawcheck[number + 1])
			owner.lawcheck[number + 1] = "Yes"
		law_data += law_entry(law, "[number]", LAW_INHERENT, "law", number, owner.lawcheck[number + 1])
		number++

	for(var/law in L.supplied)
		if(!length(law))
			continue
		if(length(owner.lawcheck) < number + 1)
			owner.lawcheck.len = number + 1
		if(!owner.lawcheck[number + 1])
			owner.lawcheck[number + 1] = "Yes"
		law_data += law_entry(law, "[number]", LAW_SUPPLIED, "law", number, owner.lawcheck[number + 1])
		number++

	return law_data

/datum/state_laws_ui/ui_data(mob/user)
	var/list/data = list()
	data["locked"] = owner.currently_stating_laws
	data["all_laws"] = get_laws_ui_data()
	return data

/datum/state_laws_ui/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(usr != owner)
		return
	switch(action)
		if("toggle_stated")
			var/index = text2num(params["index"])
			if(isnull(index))
				return
			var/list/checklist
			switch(params["category"])
				if("law")
					checklist = owner.lawcheck
					index += 1
				if("ion")
					checklist = owner.ioncheck
				if("hacked")
					checklist = owner.hackedcheck
				if("devil")
					checklist = owner.devillawcheck
			if(!checklist || index < 1 || index > length(checklist))
				return
			checklist[index] = (checklist[index] == "Yes") ? "No" : "Yes"
			return TRUE
		if("state_laws")
			if(owner.currently_stating_laws)
				return
			INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob/living/silicon, statelaws))
			SStgui.close_uis(src)
			return TRUE

/mob/living/silicon/proc/ai_roster()
	if(!client)
		return
	if(world.time < client.crew_manifest_delay)
		return
	client.crew_manifest_delay = world.time + (1 SECONDS)

	GLOB.crew_manifest_tgui.ui_interact(src) // AQ EDIT - port BeeStation #9836: TGUI manifest

/mob/living/silicon/proc/set_autosay() //For allowing the AI and borgs to set the radio behavior of auto announcements (state laws, arrivals).
	if(!radio)
		to_chat(src, "Nie wykryto radia.")
		return

	//Ask the user to pick a channel from what it has available.
	var/Autochan = input("Select a channel:") as null|anything in list("Default","None") + radio.channels

	if(!Autochan)
		return
	if(Autochan == "Default") //Autospeak on whatever frequency to which the radio is set, usually Common.
		radiomod = ";"
		Autochan += " ([radio.frequency])"
	else if(Autochan == "None") //Prevents use of the radio for automatic annoucements.
		radiomod = ""
	else	//For department channels, if any, given by the internal radio.
		for(var/key in GLOB.department_radio_keys)
			if(GLOB.department_radio_keys[key] == Autochan)
				radiomod = ":" + key
				break

	to_chat(src, "<span class='notice'>Automatyczne ogłoszenia [Autochan == "None" ? "nie będą używać radia." : "ustawione na kanał [Autochan]."]</span>")

/mob/living/silicon/put_in_hand_check() // This check is for borgs being able to receive items, not put them in others' hands.
	return 0

// The src mob is trying to place an item on someone
// But the src mob is a silicon!!  Disable.
/mob/living/silicon/stripPanelEquip(obj/item/what, mob/who, slot)
	return 0


/mob/living/silicon/assess_threat(judgment_criteria, lasercolor = "", datum/callback/weaponcheck=null) //Secbots won't hunt silicon units
	return -10

/mob/living/silicon/proc/remove_sensors()
	var/datum/atom_hud/secsensor = GLOB.huds[sec_hud]
	var/datum/atom_hud/medsensor = GLOB.huds[med_hud]
	var/datum/atom_hud/diagsensor = GLOB.huds[d_hud]
	secsensor.remove_hud_from(src)
	medsensor.remove_hud_from(src)
	diagsensor.remove_hud_from(src)

/mob/living/silicon/proc/add_sensors()
	var/datum/atom_hud/secsensor = GLOB.huds[sec_hud]
	var/datum/atom_hud/medsensor = GLOB.huds[med_hud]
	var/datum/atom_hud/diagsensor = GLOB.huds[d_hud]
	secsensor.add_hud_to(src)
	medsensor.add_hud_to(src)
	diagsensor.add_hud_to(src)

/mob/living/silicon/proc/toggle_sensors()
	if(incapacitated())
		return
	sensors_on = !sensors_on
	if (!sensors_on)
		to_chat(src, "Nakładka czujników wyłączona.")
		remove_sensors()
		return
	add_sensors()
	to_chat(src, "Nakładka czujników włączona.")

/mob/living/silicon/proc/crew_manifest(mob/living/silicon) //nsv add manifest to borg computer
	var/mob/living/silicon/borgo = usr
	borgo.ai_roster()

/mob/living/silicon/proc/GetPhoto(mob/user)
	if (aicamera)
		return aicamera.selectpicture(user)

/mob/living/silicon/update_transform()
	var/matrix/ntransform = matrix(transform) //aka transform.Copy()
	var/changed = 0
	if(resize != RESIZE_DEFAULT_SIZE)
		changed++
		ntransform.Scale(resize)
		resize = RESIZE_DEFAULT_SIZE

	if(changed)
		animate(src, transform = ntransform, time = 2,easing = EASE_IN|EASE_OUT)
	return ..()

/mob/living/silicon/is_literate()
	return TRUE

/mob/living/silicon/get_inactive_held_item()
	return FALSE

/mob/living/silicon/handle_high_gravity(gravity)
	//NSV13 - silicons are not fully grav immune, only very resistant.
	if(gravity <= GRAVITY_DAMAGE_TRESHOLD + 5) //5G additional tolerance. Magicnumber to avoid touching base defines.
		return
	gravity -= 5 //3 is base tolerance, this adds 5 onto it for the total of 8.
	return ..()
	//NSV13 end.

/mob/living/silicon/rust_heretic_act()
	adjustBruteLoss(500)
	return TRUE

/mob/living/silicon/hears_radio()
	return FALSE

/**
 * Records an IC event log entry in the cyborg's internal tablet.
 *
 * Creates an entry in the borglog list of the cyborg's internal tablet (if it's a borg), listing the current
 * in-game time followed by the message given. These logs can be seen by the cyborg in their
 * BorgUI tablet app. By design, logging fails if the cyborg is dead.
 *
 * (This used to be in robot.dm. It's in here now.)
 *
 * Arguments:
 * string: a string containing the message to log.
 */
/mob/living/silicon/proc/logevent(string = "")
	if(!string)
		return
	if(stat == DEAD) //Dead silicons log no longer
		return
	if(!modularInterface)
		stack_trace("Silicon [src] ( [type] ) was somehow missing their integrated tablet. Please make a bug report.")
		create_modularInterface()
	var/mob/living/silicon/robot/robo = modularInterface.borgo
	if(istype(robo))
		modularInterface.borglog += "[station_time_timestamp()] - [string]"
	var/datum/computer_file/program/borg_self_monitor/program = modularInterface.get_self_monitoring()
	if(program)
		program.force_full_update()

/// Same as the normal character name replacement, but updates the contents of the modular interface.
/mob/living/silicon/fully_replace_character_name(oldname, newname)
	. = ..()
	if(!modularInterface)
		stack_trace("Silicon [src] ( [type] ) was somehow missing their integrated tablet. Please make a bug report.")
		create_modularInterface()
	modularInterface.saved_identification = newname
