// AQUILA EDIT - panel pojemników z odczynnikami przeniesiony z HTML/jQuery na TGUI (port BeakerPanel z tg)

/datum/admins/proc/beaker_panel()
	set category = "Debug"
	set name = "Spawn reagent container"
	if(!check_rights())
		return
	var/datum/beaker_panel/panel = new
	panel.ui_interact(usr)

/datum/beaker_panel

/datum/beaker_panel/ui_state(mob/user)
	return GLOB.admin_state

/datum/beaker_panel/ui_close(mob/user)
	qdel(src)

/datum/beaker_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BeakerPanel")
		ui.open()

/datum/beaker_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!check_rights(R_ADMIN))
		return

	var/mob/user = usr
	switch(action)
		if("spawn")
			var/obj/item/reagent_containers/created = spawn_container_from_data(user, params["spawn_info"], user.drop_location())
			if(!created)
				return
			log_game("[key_name(user)] spawned a [created] containing [pretty_string_from_reagent_list(created.reagents.reagent_list)]")
			return TRUE
		if("spawngrenade")
			var/obj/item/grenade/chem_grenade/grenade = spawn_grenade_from_data(user, params["spawn_info"], params["grenade_info"])
			if(!grenade)
				return
			var/list/log_string = list()
			for(var/obj/item/beaker as anything in grenade.beakers)
				log_string += "([beaker.name]: [pretty_string_from_reagent_list(beaker.reagents.reagent_list)])"
			log_game("[key_name(user)] spawned a [grenade] containing: [log_string.Join("; ")]")
			return TRUE

/datum/beaker_panel/ui_static_data(mob/user)
	var/list/data = list()
	var/list/reagents = list()
	var/list/containers = list()

	for(var/datum/reagent/reagent_type as anything in subtypesof(/datum/reagent))
		var/reagent_name = initial(reagent_type.name)
		if(!reagent_name)
			continue
		reagents += list(list("id" = "[reagent_type]", "text" = reagent_name))

	for(var/obj/item/reagent_containers/container_type as anything in subtypesof(/obj/item/reagent_containers))
		var/container_name = initial(container_type.name)
		if(!container_name)
			continue
		containers += list(list("id" = "[container_type]", "text" = container_name, "volume" = initial(container_type.volume)))

	data["reagents"] = reagents
	data["containers"] = containers
	return data

/datum/beaker_panel/proc/spawn_container_from_data(mob/user, list/spawn_info, atom/location)
	if(!islist(spawn_info))
		return
	var/container_type = text2path(spawn_info["container"])
	if(!ispath(container_type, /obj/item/reagent_containers))
		return
	var/list/container_reagents = list()
	var/list/reagent_info = spawn_info["reagents"]
	if(islist(reagent_info))
		for(var/reagent_string in reagent_info)
			var/reagent_type = text2path(reagent_string)
			if(!ispath(reagent_type, /datum/reagent))
				continue
			var/amount = text2num("[reagent_info[reagent_string]]")
			if(!amount || amount <= 0)
				continue
			container_reagents[reagent_type] = amount
	return spawn_container(container_type, container_reagents, location)

/datum/beaker_panel/proc/spawn_container(container_type, list/container_reagents, atom/location)
	var/obj/item/reagent_containers/container = new container_type(location)
	var/datum/reagents/reagents = container.reagents
	if(!reagents)
		return container
	reagents.clear_reagents()
	reagents.maximum_volume = INFINITY
	for(var/reagent_type in container_reagents)
		reagents.add_reagent(reagent_type, container_reagents[reagent_type])
	reagents.maximum_volume = max(reagents.total_volume, initial(container.volume))
	return container

/datum/beaker_panel/proc/spawn_grenade_from_data(mob/user, list/all_spawn_info, list/grenade_info)
	if(!islist(all_spawn_info))
		return
	var/obj/item/grenade/chem_grenade/grenade = new(user.drop_location())
	for(var/list/container_info in all_spawn_info)
		var/obj/item/reagent_containers/container = spawn_container_from_data(user, container_info, grenade)
		if(container)
			grenade.beakers += container
	grenade.stage_change(GRENADE_READY)

	if(islist(grenade_info))
		switch(grenade_info["detonation_type"])
			if("normal")
				var/det_time = text2num("[grenade_info["detonation_timer"]]")
				if(det_time)
					grenade.det_time = det_time * 1 SECONDS

	return grenade
