/datum/orbit_menu
	var/mob/dead/observer/owner

/datum/orbit_menu/New(mob/dead/observer/new_owner)
	if(!istype(new_owner))
		qdel(src)
	owner = new_owner


/datum/orbit_menu/ui_state(mob/user)
	return GLOB.observer_state

/datum/orbit_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui) // AQ EDIT - port BeeStation #9034
	if (!ui)
		ui = new(user, src, "Orbit", "Orbita")
		ui.open()
		ui.set_autoupdate(TRUE)

/datum/orbit_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if (..())
		return

	switch(action)
		if("orbit")
			var/ref = params["ref"]
			var/atom/movable/poi = (locate(ref) in GLOB.mob_list) || (locate(ref) in GLOB.poi_list)
			if (poi != null)
				owner.ManualFollow(poi)
				// AQUILA EDIT START - automatyczna obserwacja z orbity tg
				owner.reset_perspective(null)
				if(params["auto_observe"] && ismob(poi) && poi != owner)
					owner.observe_mob(poi)
				// AQUILA EDIT END
			// AQ EDIT START - port BeeStation #9034: refresh the list when the target is gone
			else
				return TRUE
			// AQ EDIT END
		// AQUILA EDIT - przycisk odświeżania z orbity tg
		if("refresh")
			return TRUE

/datum/orbit_menu/ui_data(mob/user)
	var/list/data = list()

	var/is_admin = !!user?.client?.holder

	var/list/alive = list()
	var/list/antagonists = list()
	var/list/deadchat_controlled = list()
	var/list/dead = list()
	var/list/ghosts = list()
	var/list/misc = list()
	var/list/npcs = list()

	var/list/pois = getpois(skip_mindless = 1)
	for (var/name in pois)
		var/list/serialized = list()
		// AQUILA EDIT - pola jak w orbicie tg (full_name, name, health, job, client...)
		serialized["full_name"] = name

		var/atom/movable/poi = pois[name]

		serialized["ref"] = REF(poi)

		var/number_of_orbiters = poi.orbiters?.orbiters?.len
		if (number_of_orbiters)
			serialized["orbiters"] = number_of_orbiters

		if(poi.GetComponent(/datum/component/deadchat_control))
			deadchat_controlled += list(serialized)

		var/mob/M = poi
		if (istype(M))
			if (is_admin && M.ckey)
				serialized["ckey"] = M.ckey
			if (isobserver(M))
				ghosts += list(serialized)
			else if (M.stat == DEAD)
				dead += list(serialized)
			else if (M.mind == null)
				if(isliving(M))
					var/mob/living/npc = M
					serialized["health"] = get_health_percent(npc)
				npcs += list(serialized)
			else
				serialized["client"] = !!M.client
				serialized["name"] = M.real_name
				if(isliving(M))
					serialized += get_living_data(M)

				var/datum/mind/mind = M.mind
				var/was_antagonist = FALSE

				//If we have an ID, use that
				var/obj/item/card/id/identification_card = M.get_idcard()
				if (identification_card)
					serialized["role_icon"] = "hud[ckey(identification_card.GetJobIcon())]"
				else if(SSjob.name_occupations[mind.assigned_role]) // AQ EDIT - port BeeStation #9034: no job icon for non-job roles
					//If we have no ID, use the mind job
					var/datum/job/located_job = SSjob.GetJob(mind.assigned_role)
					if (located_job)
						serialized["role_icon"] = "hud[ckey(located_job.title)]"

				for (var/_A in mind.antag_datums)
					var/datum/antagonist/A = _A
					if (A.show_to_ghosts || is_admin) // AQUILA EDIT - admini widzą wszystkich antagonistów, jak w tg
						was_antagonist = TRUE
						// AQ EDIT START - port BeeStation #9034: team name and HUD icon
						serialized["antag"] = A.name
						var/datum/team/antag_team = A.get_team()
						if(antag_team)
							serialized["antag_group"] = antag_team.name
						else
							serialized["antag_group"] = A.get_antag_name()
						if(mind.antag_hud_icon_state)
							serialized["antag_icon"] = mind.antag_hud_icon_state
						// AQ EDIT END
						antagonists += list(serialized)
						break

				if (!was_antagonist)
					alive += list(serialized)
		else
			misc += list(serialized)

	data["alive"] = alive
	data["antagonists"] = antagonists
	data["critical"] = list()
	data["deadchat_controlled"] = deadchat_controlled
	data["dead"] = dead
	data["ghosts"] = ghosts
	data["misc"] = misc
	data["npcs"] = npcs
	data["can_observe"] = TRUE
	if(isobserver(user))
		data["orbiting"] = get_currently_orbiting(user)

	return data

/// AQUILA EDIT - zdrowie w procentach jak w orbicie tg
/datum/orbit_menu/proc/get_health_percent(mob/living/target)
	if(!target.maxHealth)
		return 0
	return FLOOR(target.health / target.maxHealth * 100, 1)

/// AQUILA EDIT - zdrowie, praca i dział żywego moba dla orbity
/datum/orbit_menu/proc/get_living_data(mob/living/target)
	var/list/serialized = list()
	serialized["health"] = get_health_percent(target)

	var/obj/item/card/id/identification_card = target.get_idcard()
	var/job_title = identification_card?.assignment || target.mind?.assigned_role
	if(job_title)
		serialized["job"] = job_title
		serialized["department"] = get_department(job_title)

	var/mind_job = target.mind?.assigned_role
	if(mind_job)
		serialized["mind_job"] = mind_job
		if(SSjob.name_occupations[mind_job])
			serialized["mind_role_icon"] = "hud[ckey(mind_job)]"
	return serialized

/// AQUILA EDIT - dział po nazwie pracy, do kolorów i sortowania w orbicie
/datum/orbit_menu/proc/get_department(job_title)
	if(job_title in list(JOB_NAME_CAPTAIN, JOB_NAME_HEADOFPERSONNEL))
		return "command"
	if(job_title in GLOB.security_positions)
		return "security"
	if(job_title in GLOB.munitions_positions)
		return "munitions"
	if(job_title in GLOB.engineering_positions)
		return "engineering"
	if(job_title in GLOB.medical_positions)
		return "medical"
	if(job_title in GLOB.science_positions)
		return "science"
	if(job_title in GLOB.supply_positions)
		return "cargo"
	if(job_title in GLOB.civilian_positions)
		return "service"
	if(job_title in GLOB.nonhuman_positions)
		return "silicon"
	if(job_title in GLOB.command_positions)
		return "command"

/// AQUILA EDIT - to, co duch właśnie orbituje, dla panelu bocznego orbity
/datum/orbit_menu/proc/get_currently_orbiting(mob/dead/observer/user)
	var/atom/movable/poi = user.orbiting?.parent
	if(!istype(poi))
		return

	var/list/serialized = list()
	serialized["full_name"] = poi.name
	serialized["ref"] = REF(poi)

	var/mob/mob_poi = poi
	if(!istype(mob_poi))
		return serialized

	if(mob_poi.mind)
		serialized["client"] = !!mob_poi.client
		serialized["name"] = mob_poi.real_name

	if(isliving(mob_poi) && mob_poi.stat != DEAD)
		serialized += get_living_data(mob_poi)
	return serialized

/// AQUILA EDIT - to samo co werb Observe, ale bez pytania o cel (orbita z auto-obserwacją)
/mob/dead/observer/proc/observe_mob(mob/mob_eye)
	if(!client || !istype(mob_eye))
		return
	client.eye = mob_eye
	if(mob_eye.hud_used)
		client.screen = list()
		LAZYINITLIST(mob_eye.observers)
		mob_eye.observers |= src
		mob_eye.hud_used.show_hud(mob_eye.hud_used.hud_version, src)
		observetarget = mob_eye

/datum/orbit_menu/ui_assets()
	. = ..() || list()
	. += get_asset_datum(/datum/asset/simple/orbit)
	. += get_asset_datum(/datum/asset/spritesheet/job_icons)
	. += get_asset_datum(/datum/asset/spritesheet/antag_hud) // AQ EDIT - port BeeStation #9034

/datum/asset/spritesheet/job_icons
	name = "job-icon"

/datum/asset/spritesheet/job_icons/register()
	var/icon/I = icon('icons/mob/hud.dmi')
	// Get the job hud part
	I.Crop(1, 17, 8, 24)
	// Scale it up
	I.Scale(16, 16)
	InsertAll("job-icon", I)
	..()
