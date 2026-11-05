/client/proc/air_status(turf/target)
	set category = "Debug"
	set name = "Display Air Status"

	if(!isturf(target))
		return
	atmosanalyzer_scan(usr, target, TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Air Status") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/fix_next_move()
	set category = "Debug"
	set name = "Unfreeze Everyone"
	var/largest_move_time = 0
	var/largest_click_time = 0
	var/mob/largest_move_mob = null
	var/mob/largest_click_mob = null
	for(var/mob/M in GLOB.player_list)
		if(M.next_move >= largest_move_time)
			largest_move_mob = M
			if(M.next_move > world.time)
				largest_move_time = M.next_move - world.time
			else
				largest_move_time = 1
		if(M.next_click >= largest_click_time)
			largest_click_mob = M
			if(M.next_click > world.time)
				largest_click_time = M.next_click - world.time
			else
				largest_click_time = 0
		log_admin("DEBUG: [key_name(M)]  next_move = [M.next_move]  lastDblClick = [M.next_click]  world.time = [world.time]")
		M.next_move = 1
		M.next_click = 0

	message_admins("[ADMIN_LOOKUPFLW(largest_move_mob)] ma największe opóźnienie ruchu: [largest_move_time] klatek / [DisplayTimeText(largest_move_time)]!")
	message_admins("[ADMIN_LOOKUPFLW(largest_click_mob)] ma największe opóźnienie kliknięcia: [largest_click_time] klatek / [DisplayTimeText(largest_click_time)]!")
	message_admins("world.time = [world.time]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Unfreeze Everyone") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/radio_report()
	set category = "Debug"
	set name = "Radio report"

	var/output = "<b>Raport radia</b><hr>"
	for (var/fq in SSradio.frequencies)
		output += "<b>Częst.: [fq]</b><br>"
		var/datum/radio_frequency/fqs = SSradio.frequencies[fq]
		if (!fqs)
			output += "&nbsp;&nbsp;<b>BŁĄD</b><br>"
			continue
		for (var/filter in fqs.devices)
			var/list/filtered = fqs.devices[filter]
			if (!filtered)
				output += "&nbsp;&nbsp;[filter]: BŁĄD<br>"
				continue
			output += "&nbsp;&nbsp;[filter]: [filtered.len]<br>"
			for(var/datum/weakref/device_ref as anything in filtered)
				var/atom/device = device_ref.resolve()
				if(!device)
					filtered -= device_ref
					continue
				if (istype(device, /atom))
					var/atom/A = device
					output += "&nbsp;&nbsp;&nbsp;&nbsp;[device] ([AREACOORD(A)])<br>"
				else
					output += "&nbsp;&nbsp;&nbsp;&nbsp;[device]<br>"

	usr << browse(HTML_SKELETON(output),"window=radioreport")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Radio Report") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/reload_admins()
	set name = "Reload Admins"
	set category = "Server"

	if(!src.holder)
		return

	var/confirm = alert(src, "Na pewno chcesz przeładować wszystkich adminów?", "Potwierdzenie", "Tak", "Nie")
	if(confirm !="Tak")
		return

	load_admins()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Reload All Admins") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	message_admins("[key_name_admin(usr)] ręcznie przeładowuje adminów")

/client/proc/toggle_cdn()
	set name = "Toggle CDN"
	set category = "Server"
	var/static/admin_disabled_cdn_transport = null
	if (alert(usr, "Na pewno chcesz przełączyć transport zasobów przez CDN?", "Potwierdzenie", "Tak", "Nie") != "Tak")
		return
	var/current_transport = CONFIG_GET(string/asset_transport)
	if (!current_transport || current_transport == "simple")
		if (admin_disabled_cdn_transport)
			CONFIG_SET(string/asset_transport, admin_disabled_cdn_transport)
			admin_disabled_cdn_transport = null
			SSassets.OnConfigLoad()
			message_admins("[key_name_admin(usr)] ponownie włącza transport zasobów przez CDN")
			log_admin("[key_name(usr)] re-enabled the CDN asset transport")
		else
			to_chat(usr, "<span class='adminnotice'>CDN nie jest włączony!</span>")
			if (alert(usr, "Transport zasobów przez CDN nie jest włączony! Jeśli masz problemy z zasobami, możesz też spróbować wyłączyć zmiany nazw plików.", "Transport zasobów przez CDN nie jest włączony!", "Wyłącz zmiany nazw plików", "Nieważne") == "Wyłącz zmiany nazw plików")
				SSassets.transport.dont_mutate_filenames = !SSassets.transport.dont_mutate_filenames
				message_admins("[key_name_admin(usr)] [(SSassets.transport.dont_mutate_filenames ? "wyłącza" : "ponownie włącza")] zmiany nazw plików zasobów")
				log_admin("[key_name(usr)] [(SSassets.transport.dont_mutate_filenames ? "disabled" : "re-enabled")] asset filename transforms")
	else
		admin_disabled_cdn_transport = current_transport
		CONFIG_SET(string/asset_transport, "simple")
		SSassets.OnConfigLoad()
		SSassets.transport.dont_mutate_filenames = TRUE
		message_admins("[key_name_admin(usr)] wyłącza transport zasobów przez CDN")
		log_admin("[key_name(usr)] disabled the CDN asset transport")
