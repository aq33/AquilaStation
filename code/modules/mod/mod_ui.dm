// AQUILA: okno modułów hardsuitu (dawny panel MODsuitu). Klucze danych jak w MODsuit.tsx; bez SI, przewodów i blokady ID.
/obj/item/clothing/suit/space/hardsuit/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MODsuit", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/item/clothing/suit/space/hardsuit/ui_data(mob/user)
	var/data = list()
	var/suit_status = list(
		"core_name" = core?.name,
		"cell_charge_current" = get_charge(),
		"cell_charge_max" = get_max_charge(),
		"active" = active,
		"ai_name" = null,
		"has_pai" = FALSE,
		"is_ai" = FALSE,
		"open" = TRUE,
		"seconds_electrified" = 0,
		"malfunctioning" = FALSE,
		"locked" = FALSE,
		"interface_break" = FALSE,
		"complexity" = complexity,
		"tank_pressure" = integrated_tank ? round(integrated_tank.air_contents.return_pressure()) : null,
		"tank_open" = wearer && integrated_tank && wearer.internal == integrated_tank,
	)
	data["suit_status"] = suit_status
	var/user_status = list(
		"user_name" = wearer ? (wearer.get_authentification_name("Nieznany") || "Nieznany") : "",
		"user_assignment" = wearer ? wearer.get_assignment("Nieznany", "Nieznany", FALSE) : "",
	)
	data["user_status"] = user_status
	var/module_custom_status = list()
	var/module_info = list()
	for(var/obj/item/mod/module/module as anything in modules)
		module_custom_status += module.add_ui_data()
		module_info += list(list(
			"module_name" = module.name,
			"description" = module.desc,
			"module_type" = module.module_type,
			"module_active" = module.active,
			"pinned" = module.pinned_to[REF(user)],
			"idle_power" = module.idle_power_cost,
			"active_power" = module.active_power_cost,
			"use_power" = module.use_power_cost,
			"module_complexity" = module.complexity,
			"cooldown_time" = module.cooldown_time,
			"cooldown" = round(COOLDOWN_TIMELEFT(module, cooldown_timer), 1 SECONDS),
			"id" = module.tgui_id,
			"ref" = REF(module),
			"configuration_data" = module.get_configuration(user),
		))
	data["module_custom_status"] = module_custom_status
	data["control"] = name
	data["module_info"] = module_info
	var/part_info = list()
	if(helmet)
		part_info += list(list(
			"slot" = "głowa",
			"name" = helmet.name,
			"deployed" = suittoggled,
			"ref" = REF(helmet),
		))
	data["parts"] = part_info
	return data

/obj/item/clothing/suit/space/hardsuit/ui_static_data(mob/user)
	var/data = list()
	data["ui_theme"] = "ntos"
	data["complexity_max"] = complexity_max
	return data

/obj/item/clothing/suit/space/hardsuit/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("select")
			var/obj/item/mod/module/module = locate(params["ref"]) in modules
			if(!module)
				return
			module.on_select()
		if("configure")
			var/obj/item/mod/module/module = locate(params["ref"]) in modules
			if(!module)
				return
			module.configure_edit(params["key"], params["value"])
		if("pin")
			var/obj/item/mod/module/module = locate(params["ref"]) in modules
			if(!module)
				return
			module.pin(ui.user)
		if("deploy", "activate")
			if(ui.user == wearer)
				ToggleHelmet()
		if("tank")
			if(ishuman(ui.user))
				toggle_integrated_tank(ui.user)
	return TRUE
