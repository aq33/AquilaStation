/datum/admins/proc/create_panel_helper(template)
	var/final_html = replacetext(template, "/* ref src */", "[REF(src)];[HrefToken()]")
	final_html = replacetext(final_html,"/* hreftokenfield */","[HrefTokenFormField()]")
	return final_html

// AQUILA EDIT - stare okna HTML "Create Object/Mob/Turf" zastępuje Panel tworzenia TGUI (SpawnPanel z tg)
/datum/admins/proc/create_object(mob/user)
	open_spawn_panel(user)

/datum/admins/proc/quick_create_object(mob/user)
	open_spawn_panel(user)

/// AQUILA - otwiera panel tworzenia; jeden na ckey, żeby ustawienia nie znikały po zamknięciu
/datum/admins/proc/open_spawn_panel(mob/user)
	if(!check_rights(R_SPAWN))
		return
	var/static/list/spawn_panels = list()
	var/datum/spawnpanel/panel = spawn_panels[user.ckey]
	if(QDELETED(panel))
		panel = new()
		spawn_panels[user.ckey] = panel
	panel.ui_interact(user)

/// AQUILA - wyszukiwarka typów dla werbu Spawn (SpawnSearch z tg); jedna na ckey
/datum/admins/proc/open_spawn_menu(mob/user, init_value)
	if(!check_rights(R_SPAWN))
		return
	var/static/list/spawn_menus = list()
	var/datum/spawn_menu/menu = spawn_menus[user.ckey]
	if(QDELETED(menu))
		menu = new()
		spawn_menus[user.ckey] = menu
	menu.init_value = init_value
	menu.ui_interact(user)
	SStgui.update_uis(menu)

#define WHERE_FLOOR_BELOW_MOB "Current location"
#define WHERE_SUPPLY_BELOW_MOB "Current location (droppod)"
#define WHERE_MOB_HAND "In own mob's hand"
#define WHERE_MARKED_OBJECT "At a marked object"
#define WHERE_IN_MARKED_OBJECT "In the marked object"
#define WHERE_TARGETED_LOCATION "Targeted location"
#define WHERE_TARGETED_LOCATION_POD "Targeted location (droppod)"
#define WHERE_TARGETED_MOB_HAND "In targeted mob's hand"

#define PRECISE_MODE_OFF "Off"
#define PRECISE_MODE_TARGET "Target"
#define PRECISE_MODE_MARK "Mark"
#define PRECISE_MODE_COPY "Copy"

#define OFFSET_ABSOLUTE "Absolute offset"
#define OFFSET_RELATIVE "Relative offset"

#define SPAWN_PANEL_CAP 100

/*
	An instance of a /tg/UI Spawn Panel. Stores preferences, spawns things, controls the UI. Unique for each user (their ckey).
	AQUILA - port z tg (code/modules/admin/spawn_panel) na naszych procedurach
*/
/datum/spawnpanel
	/// Where and how the atom should be spawned.
	var/where_target_type = WHERE_FLOOR_BELOW_MOB
	/// The atom typepath selected from the panel.
	var/selected_atom = null
	/// The icon selected for the atom from the panel.
	var/selected_atom_icon = null
	/// The icon state selected for the atom from the panel.
	var/selected_atom_icon_state = null
	/// Should selected icon/icon state override the initial ones?
	var/apply_icon_override = FALSE
	/// A list of icon states to display in preview panels.
	var/list/available_icon_states = null
	/// Override for the icon size of the spawned mob.
	var/atom_icon_size = 100
	/// How many atoms will be spawned at once.
	var/atom_amount = 1
	/// Custom atom name (leave `null` for initial).
	var/atom_name = null
	/// Custom atom dir
	var/atom_dir = 1
	/// An associative list of x-y-z offsets.
	var/list/offset = list()
	/// The pivot point for offsetting - relative or absolute.
	var/offset_type = OFFSET_RELATIVE
	/// Precise mode toggle. Used for build-mode-like spawning experience and targeting datums.
	var/precise_mode = PRECISE_MODE_OFF
	/// Klient, któremu podmieniliśmy kursor
	var/client/precise_client

/datum/spawnpanel/New()
	. = ..()
	offset = list("X" = 0, "Y" = 0, "Z" = 0)

/datum/spawnpanel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SpawnPanel")
		ui.open()

/datum/spawnpanel/ui_close(mob/user)
	. = ..()
	if(precise_mode != PRECISE_MODE_OFF)
		toggle_precise_mode(PRECISE_MODE_OFF)

/datum/spawnpanel/ui_state(mob/user)
	return GLOB.admin_state

/datum/spawnpanel/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/json/spawnpanel),
	)

/datum/spawnpanel/proc/set_selected_path(path)
	if(!ispath(path, /obj) && !ispath(path, /turf) && !ispath(path, /mob))
		return
	var/atom/temp_atom = path
	selected_atom = path
	selected_atom_icon = initial(temp_atom.icon)
	selected_atom_icon_state = initial(temp_atom.icon_state)
	available_icon_states = selected_atom_icon ? icon_states(selected_atom_icon) : list()

/datum/spawnpanel/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!check_rights(R_SPAWN))
		return

	switch(action)
		if("select-new-DMI")
			var/icon/new_icon = input(usr, "Wybierz plik ikony:", "Ikona") as null|icon
			if(new_icon)
				selected_atom_icon = new_icon
				available_icon_states = icon_states(selected_atom_icon)
				if(length(available_icon_states) && !(selected_atom_icon_state in available_icon_states))
					selected_atom_icon_state = available_icon_states[1]
			return TRUE

		if("set-apply-icon-override")
			apply_icon_override = !!params["value"]
			return TRUE

		if("reset-DMI-icon")
			selected_atom_icon = null
			selected_atom_icon_state = null
			if(selected_atom)
				set_selected_path(selected_atom)
			else
				available_icon_states = list()
			return TRUE

		if("select-new-icon-state")
			selected_atom_icon_state = params["new_state"]
			return TRUE

		if("reset-icon-state")
			selected_atom_icon_state = null
			if(selected_atom)
				var/atom/temp_atom = selected_atom
				selected_atom_icon_state = initial(temp_atom.icon_state)
			return TRUE

		if("set-icon-size")
			atom_icon_size = text2num("[params["size"]]") || 100
			return TRUE

		if("reset-icon-size")
			atom_icon_size = 100
			return TRUE

		if("get-icon-states")
			available_icon_states = selected_atom_icon ? icon_states(selected_atom_icon) : list()
			return TRUE

		if("selected-atom-changed")
			var/path = text2path(params["newObj"])
			if(path)
				set_selected_path(path)
			return TRUE

		if("create-atom-action")
			var/list/spawn_params = list(
				"selected_atom" = selected_atom,
				"atom_dir" = text2num("[params["atom_dir"]]") || atom_dir || 1,
				"atom_amount" = text2num("[params["atom_amount"]]") || atom_amount || 1,
				"atom_name" = params["atom_name"] || atom_name,
				"where_target_type" = params["where_target_type"] || where_target_type || WHERE_FLOOR_BELOW_MOB,
				"atom_icon_size" = text2num("[params["atom_icon_size"]]") || atom_icon_size,
				"offset_type" = params["offset_type"] || offset_type || OFFSET_RELATIVE,
				"apply_icon_override" = apply_icon_override,
			)
			if(apply_icon_override)
				spawn_params["selected_atom_icon"] = selected_atom_icon
				spawn_params["selected_atom_icon_state"] = selected_atom_icon_state
			spawn_atom(spawn_params, usr)
			return TRUE

		if("toggle-precise-mode")
			var/precise_type = params["newPreciseType"]
			if(!(precise_type in list(PRECISE_MODE_OFF, PRECISE_MODE_TARGET, PRECISE_MODE_MARK, PRECISE_MODE_COPY)))
				return
			if(precise_type == PRECISE_MODE_TARGET && params["where_target_type"])
				where_target_type = params["where_target_type"]
			toggle_precise_mode(precise_type)
			return TRUE

		if("update-settings")
			if(params["atom_amount"])
				atom_amount = text2num("[params["atom_amount"]]") || 1
			if(params["atom_dir"])
				atom_dir = text2num("[params["atom_dir"]]") || 1
			if(islist(params["offset"]))
				var/list/temp_offset = params["offset"]
				if(length(temp_offset) >= 3)
					offset["X"] = text2num("[temp_offset[1]]") || 0
					offset["Y"] = text2num("[temp_offset[2]]") || 0
					offset["Z"] = text2num("[temp_offset[3]]") || 0
			if(!isnull(params["atom_name"]))
				atom_name = params["atom_name"]
			if(params["where_target_type"])
				where_target_type = params["where_target_type"]
			if(params["offset_type"])
				offset_type = params["offset_type"]
			if(params["atom_icon_size"])
				atom_icon_size = text2num("[params["atom_icon_size"]]") || 100
			if(params["selected_atom_icon"])
				selected_atom_icon = params["selected_atom_icon"]
			if(params["selected_atom_icon_state"])
				selected_atom_icon_state = params["selected_atom_icon_state"]
			if(params["selected_atom"])
				var/path = text2path(params["selected_atom"])
				if(path && path != selected_atom)
					set_selected_path(path)
			return TRUE

/datum/spawnpanel/proc/toggle_precise_mode(precise_type)
	precise_mode = precise_type
	var/client/admin_client = usr?.client || precise_client
	if(!admin_client)
		return

	admin_client.mouse_up_icon = null
	admin_client.mouse_down_icon = null
	if(admin_client.click_intercept == src)
		admin_client.click_intercept = null

	if(precise_mode != PRECISE_MODE_OFF)
		precise_client = admin_client
		admin_client.mouse_up_icon = 'icons/effects/supplypod_pickturf.dmi'
		admin_client.mouse_down_icon = 'icons/effects/supplypod_pickturf_down.dmi'
		admin_client.mouse_pointer_icon = admin_client.mouse_up_icon
		admin_client.click_intercept = src
		winset(admin_client, "mapwindow.map", "right-click=true")
	else
		precise_client = null
		winset(admin_client, "mapwindow.map", "right-click=false")
		admin_client.mob?.update_mouse_pointer()

/datum/spawnpanel/proc/InterceptClickOn(mob/user, params, atom/target)
	var/list/modifiers = params2list(params)
	var/left_click = modifiers["left"]
	var/right_click = modifiers["right"]

	if(right_click)
		toggle_precise_mode(PRECISE_MODE_OFF)
		SStgui.update_uis(src)
		return TRUE

	if(left_click)
		if(istype(target, /atom/movable/screen))
			return FALSE

		var/turf/clicked_turf = get_turf(target)
		if(!clicked_turf)
			return FALSE

		switch(precise_mode)
			if(PRECISE_MODE_TARGET)
				var/list/spawn_params = list(
					"selected_atom" = selected_atom,
					"atom_amount" = atom_amount,
					"atom_dir" = atom_dir,
					"atom_name" = atom_name,
					"offset_type" = OFFSET_ABSOLUTE,
					"where_target_type" = where_target_type,
					"target" = target,
					"atom_icon_size" = atom_icon_size,
					"apply_icon_override" = apply_icon_override,
				)
				if(apply_icon_override)
					spawn_params["selected_atom_icon"] = selected_atom_icon
					spawn_params["selected_atom_icon_state"] = selected_atom_icon_state
				if(where_target_type == WHERE_TARGETED_LOCATION || where_target_type == WHERE_TARGETED_LOCATION_POD)
					spawn_params["target"] = clicked_turf
				spawn_atom(spawn_params, user)

			if(PRECISE_MODE_MARK)
				user.client?.mark_datum(target)
				to_chat(user, "<span class='notice'>Oznaczono obiekt: [icon2html(target, user)] <b>[target]</b></span>")
				toggle_precise_mode(PRECISE_MODE_OFF)
				SStgui.update_uis(src)

			if(PRECISE_MODE_COPY)
				to_chat(user, "<span class='notice'>Wybrano obiekt: [icon2html(target, user)] <b>[target]</b></span>")
				set_selected_path(target.type)
				toggle_precise_mode(PRECISE_MODE_OFF)
				SStgui.update_uis(src)

		return TRUE

/datum/spawnpanel/ui_data(mob/user)
	var/list/data = list()
	data["icon"] = selected_atom_icon ? "[selected_atom_icon]" : null
	data["iconState"] = selected_atom_icon_state
	data["iconSize"] = atom_icon_size
	data["apply_icon_override"] = apply_icon_override
	var/list/states = list()
	for(var/state in available_icon_states)
		states += state
	data["iconStates"] = states
	data["precise_mode"] = precise_mode
	data["selected_object"] = selected_atom ? "[selected_atom]" : ""
	return data

/*
	Handles spawning an atom. Same options as the old Create Object panel (topic "object_list").
*/
/datum/spawnpanel/proc/spawn_atom(list/spawn_params, mob/user)
	if(!check_rights(R_SPAWN) || !spawn_params || !user)
		return

	var/atom_to_spawn = spawn_params["selected_atom"]
	if(!atom_to_spawn || (!ispath(atom_to_spawn, /obj) && !ispath(atom_to_spawn, /turf) && !ispath(atom_to_spawn, /mob)))
		to_chat(user, "<span class='warning'>Najpierw wybierz, co chcesz stworzyć.</span>")
		return

	var/amount = clamp(text2num("[spawn_params["atom_amount"]]") || 1, 1, SPAWN_PANEL_CAP)

	var/X = offset["X"] || 0
	var/Y = offset["Y"] || 0
	var/Z = offset["Z"] || 0

	var/spawn_dir = text2num("[spawn_params["atom_dir"]]") || 1
	if(!(spawn_dir in GLOB.alldirs))
		spawn_dir = SOUTH
	var/spawn_name = spawn_params["atom_name"] ? sanitize(spawn_params["atom_name"]) : null

	var/where = spawn_params["where_target_type"]
	var/atom/target = null

	if(where == WHERE_MOB_HAND || where == WHERE_TARGETED_MOB_HAND)
		target = (where == WHERE_TARGETED_MOB_HAND ? spawn_params["target"] : user)
		if(!target)
			to_chat(user, "<span class='warning'>Nie wskazano celu.</span>")
			return
		if(!ismob(target))
			to_chat(user, "<span class='warning'>Wskazany obiekt nie jest mobem.</span>")
			return
		if(!iscarbon(target) && !iscyborg(target))
			to_chat(user, "<span class='warning'>Do ręki można tworzyć tylko mobom węglowym i cyborgom.</span>")
			where = WHERE_FLOOR_BELOW_MOB
			target = get_turf(target)

	else if(where == WHERE_MARKED_OBJECT || where == WHERE_IN_MARKED_OBJECT)
		var/datum/marked = user.client?.holder?.marked_datum
		if(!marked)
			to_chat(user, "<span class='warning'>Nie masz oznaczonego obiektu.</span>")
			return
		if(!isatom(marked))
			to_chat(user, "<span class='warning'>Oznaczony obiekt musi być typu /atom.</span>")
			return
		target = (where == WHERE_MARKED_OBJECT ? get_turf(marked) : marked)

	else if(where == WHERE_TARGETED_LOCATION || where == WHERE_TARGETED_LOCATION_POD)
		target = spawn_params["target"]
	else
		switch(spawn_params["offset_type"])
			if(OFFSET_ABSOLUTE)
				target = locate(X, Y, Z)
			else
				var/turf/relative_turf = get_turf(user)
				if(!relative_turf && user.client?.eye)
					relative_turf = get_turf(user.client.eye)
				if(!relative_turf)
					to_chat(user, "<span class='warning'>Nie da się ustalić położenia.</span>")
					return
				target = locate(relative_turf.x + X, relative_turf.y + Y, relative_turf.z + Z)

	if(!target)
		to_chat(user, "<span class='warning'>Nieprawidłowe miejsce.</span>")
		return

	var/use_droppod = (where == WHERE_SUPPLY_BELOW_MOB || where == WHERE_TARGETED_LOCATION_POD)
	var/obj/structure/closet/supplypod/centcompod/pod
	if(use_droppod)
		pod = new()

	for(var/i in 1 to amount)
		if(ispath(atom_to_spawn, /turf))
			var/turf/original_turf = get_turf(target)
			var/turf/created_turf = original_turf.ChangeTurf(atom_to_spawn)
			if(created_turf && spawn_name)
				created_turf.name = spawn_name
			continue

		var/atom/created_atom = new atom_to_spawn(use_droppod ? pod : target)
		if(QDELETED(created_atom))
			continue
		created_atom.flags_1 |= ADMIN_SPAWNED_1

		if(spawn_params["apply_icon_override"])
			if(spawn_params["selected_atom_icon"])
				var/new_icon = spawn_params["selected_atom_icon"]
				created_atom.icon = isicon(new_icon) ? new_icon : file("[new_icon]")
			if(spawn_params["selected_atom_icon_state"])
				created_atom.icon_state = spawn_params["selected_atom_icon_state"]

		var/icon_size = text2num("[spawn_params["atom_icon_size"]]")
		if(icon_size && icon_size != 100 && isliving(created_atom))
			var/mob/living/created_mob = created_atom
			created_mob.resize = icon_size / 100
			created_mob.update_transform()

		if(spawn_dir)
			created_atom.setDir(spawn_dir)

		if(spawn_name)
			created_atom.name = spawn_name
			if(ismob(created_atom))
				var/mob/created_mob = created_atom
				created_mob.real_name = spawn_name

		if((where == WHERE_MOB_HAND || where == WHERE_TARGETED_MOB_HAND) && isliving(target) && isitem(created_atom))
			var/mob/living/living_target = target
			var/obj/item/created_item = created_atom
			living_target.put_in_hands(created_item)
			if(iscyborg(living_target))
				var/mob/living/silicon/robot/target_robot = living_target
				if(target_robot.module)
					target_robot.module.add_module(created_item, TRUE, TRUE)
					target_robot.activate_module(created_item)

	if(pod)
		new /obj/effect/pod_landingzone(get_turf(target), pod)

	var/turf/T = get_turf(user)
	log_admin("[key_name(user)] created [amount]ea [atom_to_spawn] at [AREACOORD(T)]")
	if(ispath(atom_to_spawn, /mob))
		message_admins("[key_name_admin(user)] created [amount]ea [atom_to_spawn]")

#undef WHERE_FLOOR_BELOW_MOB
#undef WHERE_SUPPLY_BELOW_MOB
#undef WHERE_MOB_HAND
#undef WHERE_MARKED_OBJECT
#undef WHERE_IN_MARKED_OBJECT
#undef WHERE_TARGETED_LOCATION
#undef WHERE_TARGETED_LOCATION_POD
#undef WHERE_TARGETED_MOB_HAND
#undef PRECISE_MODE_OFF
#undef PRECISE_MODE_TARGET
#undef PRECISE_MODE_MARK
#undef PRECISE_MODE_COPY
#undef OFFSET_ABSOLUTE
#undef OFFSET_RELATIVE

/// AQUILA - dane wszystkich atomów dla Panelu tworzenia (port z tg)
/datum/asset/json/spawnpanel
	name = "spawnpanel_atom_data"

/datum/asset/json/spawnpanel/generate()
	var/list/data = list()

	var/static/list/mapping_objects = typecacheof(list(
		/obj/effect/mapping_helpers,
		/obj/effect/landmark,
		/obj/effect/spawner,
		/obj/effect/mob_spawn,
		/obj/effect/holodeck_effect,
		/obj/docking_port,
	))

	var/list/atoms = list()
	for(var/obj/each_object as anything in typesof(/obj))
		atoms["[each_object]"] = list(
			"icon" = initial(each_object.icon) ? "[initial(each_object.icon)]" : "none",
			"icon_state" = initial(each_object.icon_state) || "none",
			"name" = initial(each_object.name),
			"description" = initial(each_object.desc),
			"mapping" = is_type_in_typecache(each_object, mapping_objects),
			"type" = "Objects",
		)
	for(var/turf/each_turf as anything in typesof(/turf))
		atoms["[each_turf]"] = list(
			"icon" = initial(each_turf.icon) ? "[initial(each_turf.icon)]" : "none",
			"icon_state" = initial(each_turf.icon_state) || "none",
			"name" = initial(each_turf.name),
			"description" = initial(each_turf.desc),
			"mapping" = FALSE,
			"type" = "Turfs",
		)
	for(var/mob/each_mob as anything in typesof(/mob))
		atoms["[each_mob]"] = list(
			"icon" = initial(each_mob.icon) ? "[initial(each_mob.icon)]" : "none",
			"icon_state" = initial(each_mob.icon_state) || "none",
			"name" = initial(each_mob.name),
			"description" = initial(each_mob.desc),
			"mapping" = FALSE,
			"type" = "Mobs",
		)
	data["atoms"] = atoms
	return data

/// AQUILA - wyszukiwarka typów dla werbu Spawn (port SpawnSearch z tg, bez typów abstrakcyjnych)
/datum/spawn_menu
	/// Does the menu default to a regex prefix?
	var/regex_search = FALSE
	/// Does the search include atom names?
	var/name_search = TRUE
	/// Should we display full typepaths or the condensed versions?
	var/fancy_types = TRUE
	/// Initial search value from the latest command
	var/init_value = null

/datum/spawn_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SpawnSearch")
		ui.open()

/datum/spawn_menu/ui_state(mob/user)
	return GLOB.admin_state

/datum/spawn_menu/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!check_rights(R_SPAWN))
		return

	switch(action)
		if("setRegexSearch")
			regex_search = !!params["regexSearch"]
			return TRUE
		if("setNameSearch")
			name_search = !!params["searchNames"]
			return TRUE
		if("setFancyTypes")
			fancy_types = !!params["fancyTypes"]
			return TRUE
		if("spawn")
			var/path = text2path(params["type"])
			if(!path || (!ispath(path, /obj) && !ispath(path, /turf) && !ispath(path, /mob)))
				return TRUE
			var/amount = clamp(text2num("[params["amount"]]") || 1, 1, SPAWN_PANEL_CAP)
			var/turf/target_turf = get_turf(usr)
			if(!target_turf)
				return TRUE
			if(ispath(path, /turf))
				target_turf.ChangeTurf(path)
			else
				for(var/i in 1 to amount)
					var/atom/spawned = new path(target_turf)
					spawned.flags_1 |= ADMIN_SPAWNED_1
			log_admin("[key_name(usr)] spawned [amount] x [path] at [AREACOORD(usr)]")
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Spawn Atom")
			SStgui.close_uis(src)
			return TRUE
		if("cancel")
			SStgui.close_uis(src)
			return TRUE

/datum/spawn_menu/ui_data(mob/user)
	var/list/data = list()
	data["initValue"] = init_value
	data["searchNames"] = name_search
	data["regexSearch"] = regex_search
	data["fancyTypes"] = fancy_types
	return data

/datum/spawn_menu/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/json/spawn_menu),
	)

/datum/asset/json/spawn_menu
	name = "spawn_menu_atom_data"

/datum/asset/json/spawn_menu/generate()
	var/list/data = list()
	var/list/types_list = list()
	for(var/atom/atom_type as anything in subtypesof(/atom))
		types_list["[atom_type]"] = initial(atom_type.name) || ""
	data["types"] = types_list
	// Kolejność od ogólnych do szczegółowych - okno bierze ostatni pasujący prefiks
	var/static/list/fancy_types = list(
		"/mob" = "M",
		"/mob/living" = "LIVING",
		"/mob/living/simple_animal" = "SIMPLE",
		"/mob/living/carbon" = "CARBON",
		"/turf" = "T",
		"/turf/closed" = "CLOSED",
		"/turf/open" = "OPEN",
		"/obj" = "O",
		"/obj/effect" = "EFFECT",
		"/obj/machinery" = "MACHINERY",
		"/obj/item" = "ITEM",
		"/obj/item/organ" = "ORGAN",
		"/obj/item/mecha_parts/mecha_equipment" = "MECHA_EQUIP",
		"/obj/machinery/portable_atmospherics" = "PORT_ATMOS",
		"/obj/machinery/atmospherics" = "ATMOS_MECH",
		"/obj/item/reagent_containers" = "REAGENT_CONTAINERS",
		"/obj/item/reagent_containers/food" = "FOOD",
		"/obj/item/reagent_containers/food/drinks" = "DRINK",
		"/obj/item/book/manual" = "MANUAL",
		"/obj/item/bodypart" = "BODYPART",
		"/obj/item/clothing/head/helmet/space" = "SPESSHELMET",
		"/obj/item/radio/headset" = "HEADSET",
		"/obj/effect/decal/cleanable" = "CLEANABLE",
	)
	data["fancyTypes"] = fancy_types
	data["abstractTypes"] = list()
	return data

#undef SPAWN_PANEL_CAP
