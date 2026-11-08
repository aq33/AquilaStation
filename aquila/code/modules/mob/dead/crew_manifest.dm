// Port BeeStation #9836: manifest załogi w TGUI (okno CrewManifest z Bee) zamiast tabelki HTML.
// Dane bierzemy z naszego GLOB.data_core.get_manifest(), więc działy NSV (Munitions, VIP) zostają.

GLOBAL_DATUM_INIT(crew_manifest_tgui, /datum/crew_manifest, new)

/datum/crew_manifest

/datum/crew_manifest/ui_state(mob/user)
	return GLOB.always_state

/datum/crew_manifest/ui_status(mob/user, datum/ui_state/state)
	var/static/list/allowed_mobs_typecache = typecacheof(list(
		/mob/dead,
		/mob/living/silicon,
	))
	return is_type_in_typecache(user, allowed_mobs_typecache) ? UI_INTERACTIVE : UI_CLOSE

/datum/crew_manifest/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CrewManifest")
		ui.open()

/datum/crew_manifest/ui_static_data(mob/user)
	// Jobs are listed in the order of the department HUD lists
	var/static/list/ordering
	if(!ordering)
		ordering = list()
		for(var/list/huds in list(GLOB.command_positions_hud, GLOB.important_positions_hud, GLOB.security_positions_hud,
			GLOB.engineering_positions_hud, GLOB.medical_positions_hud, GLOB.science_positions_hud,
			GLOB.supply_positions_hud, GLOB.munitions_positions_hud, GLOB.civilian_positions_hud))
			for(var/hud in huds)
				if(!(hud in ordering))
					ordering[hud] = length(ordering) + 1
	// Heads follow the chain of command in the Command section
	var/static/list/command_order
	if(!command_order)
		command_order = list()
		for(var/job_title in SSjob.chain_of_command)
			command_order[get_hud_by_jobname(job_title)] = SSjob.chain_of_command[job_title]
	return list(
		"command" = list(
			"dept" = "Command",
			"huds" = GLOB.command_positions_hud,
			"jobs" = GLOB.command_positions,
			"order" = command_order,
		),
		"order" = ordering,
	)

/datum/crew_manifest/ui_data(mob/user)
	var/list/manifest = GLOB.data_core.get_manifest()
	var/list/silicons = get_silicon_entries()
	if(length(silicons))
		manifest["Silicon"] = silicons
	return list(
		"manifest" = manifest,
		"user_theme" = isdead(user) ? "generic" : null,
	)

/datum/crew_manifest/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/spritesheet/job_icons))

/// The AI and cyborgs have no crew record (manifest_inject() is for humans only), so the manifest lists them straight from the mobs
/datum/crew_manifest/proc/get_silicon_entries()
	var/list/entries = list()
	for(var/mob/living/silicon/ai/ai as anything in GLOB.ai_list)
		if(!ai.mind)
			continue
		entries += list(list("name" = ai.name, "rank" = JOB_NAME_AI, "hud" = get_hud_by_jobname(JOB_NAME_AI)))
	for(var/mob/living/silicon/robot/borg in GLOB.silicon_mobs)
		// AI shells belong to the AI, unlinked cyborgs (syndicate, emagged codes) are not crew
		if(!borg.mind || borg.shell || borg.scrambledcodes)
			continue
		entries += list(list("name" = borg.name, "rank" = JOB_NAME_CYBORG, "hud" = get_hud_by_jobname(JOB_NAME_CYBORG)))
	return entries
