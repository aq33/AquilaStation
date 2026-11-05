/client/proc/forcerandomrotate()
	set category = "Server"
	set name = "Trigger Random Map Rotation"
	var/rotate = i18n_alert(usr, "Wymusić losową rotację mapy?", "Zmienić mapę?", "Tak", "Anuluj") // AQ EDIT - i18n okienka
	if (rotate != "Tak")
		return
	message_admins("[key_name_admin(usr)] wymusza losową rotację mapy.")
	log_admin("[key_name(usr)] is forcing a random map rotation.")
	SSticker.maprotatechecked = 1
	SSmapping.maprotate()

/client/proc/adminchangemap()
	set category = "Server"
	set name = "Change Map"

	var/list/maprotatechoices = list()
	for (var/map in config.maplist)
		var/datum/map_config/VM = config.maplist[map]
		var/mapname = VM.map_name
		if (VM == config.defaultmap)
			mapname += " (domyślna)"

		if (VM.config_min_users > 0 || VM.config_max_users > 0)
			mapname += " \["
			if (VM.config_min_users > 0)
				mapname += "[VM.config_min_users]"
			else
				mapname += "0"
			mapname += "-"
			if (VM.config_max_users > 0)
				mapname += "[VM.config_max_users]"
			else
				mapname += "inf"
			mapname += "\]"

		maprotatechoices[mapname] = VM
	var/chosenmap = i18n_input_choice(usr, input(i18n_dialog_text(usr, "Wybierz mapę, na którą zmienić"), i18n_dialog_text(usr, "Zmiana mapy"))  as null|anything in i18n_input_shown(usr, sortList(maprotatechoices))) // AQ EDIT - i18n okienka
	if (!chosenmap)
		return
	SSticker.maprotatechecked = 1
	var/datum/map_config/VM = maprotatechoices[chosenmap]
	message_admins("[key_name_admin(usr)] zmienia mapę na [VM.map_name]")
	log_admin("[key_name(usr)] is changing the map to [VM.map_name]")
	if (SSmapping.changemap(VM) == 0)
		message_admins("Mapa zmieniona na [VM.map_name] przez [key_name_admin(usr)]")

/client/proc/forcemapconfig()
	set category = "Debug"
	set name = "Debug Force Map"

	//Locked behind permissions since it needs serious protection.
	if(!check_rights(R_DEBUG) || !check_rights(R_SERVER) || !check_rights(R_PERMISSIONS))
		to_chat(src, "<span class='warning'>Niewystarczające uprawnienia (wymaga debug, server i permissions).</span>")
		return

	var/json_settings = input(usr, i18n_dialog_text(usr, "Podaj nazwę pliku json mapy:"), i18n_dialog_text(usr, "Nazwa json mapy"), "") as text|null // AQ EDIT - i18n okienka

	if(!json_settings)
		return

	var/datum/map_config/config = new
	if(!config.LoadConfig("_maps/[json_settings].json", TRUE))
		qdel(config)
		to_chat(usr, "<span class='warning'>Nie udało się wczytać json mapy!</span>")
		return
	SSticker.maprotatechecked = 1
	message_admins("[key_name_admin(usr)] zmienia mapę na [config.map_name]")
	log_admin("[key_name(usr)] is changing the map to [config.map_name]")
	if (SSmapping.changemap(config) == 0)
		message_admins("Mapa zmieniona na [config.map_name] przez [key_name_admin(usr)]")
