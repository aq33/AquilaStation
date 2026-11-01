/// Default script of a new console: lets every message through untouched
#define NTSL_DEFAULT_CODE "def process_signal(sig){\n\treturn sig;\n}"

/obj/item/circuitboard/computer/comm_traffic
	name = "konsola kontroli ruchu telekomunikacji (płytka komputera)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/telecomms/traffic

/datum/design/board/traffic
	name = "Projekt komputera (konsola kontroli ruchu telekomunikacji)"
	desc = "Pozwala zbudować konsolę kontroli ruchu, która programuje serwery telekomunikacji w NTSL."
	id = "s-traffic"
	build_path = /obj/item/circuitboard/computer/comm_traffic
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/techweb_node/telecomms/New()
	. = ..()
	design_ids += "s-traffic"

/obj/machinery/computer/telecomms/traffic
	name = "konsola kontroli ruchu telekomunikacji"
	desc = "Konsola do programowania serwerów telekomunikacji w języku NTSL."
	icon_screen = "generic"
	req_access = list(ACCESS_TCOMMS_ADMIN)
	circuit = /obj/item/circuitboard/computer/comm_traffic
	light_color = LIGHT_COLOR_GREEN

	/// The servers located by the computer
	var/list/obj/machinery/telecomms/server/servers = list()
	/// The network to probe
	var/network = "tcommsat"
	/// The current code being used
	var/storedcode = NTSL_DEFAULT_CODE
	/// The name and job on the ID used to log in
	var/user_name = ""
	/// ckey of whoever logged in, only they can work on the console
	var/session_ckey
	/// Logs for users logging in/out or compiling code
	var/list/access_log = list()
	/// Output from compiling to the servers
	var/list/compiler_output = list()
	/// Mapped consoles reach every server of their network, built ones only nearby servers
	var/unlimited_range = FALSE

/obj/machinery/computer/telecomms/traffic/Initialize(mapload)
	. = ..()
	if(!length(GLOB.pretty_filter_items))
		setup_pretty_filter()
	if(mapload)
		unlimited_range = TRUE
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/telecomms/traffic/LateInitialize()
	. = ..()
	refresh_servers()
	for(var/obj/machinery/telecomms/server/new_server as anything in servers)
		new_server.autoruncode = TRUE

/obj/machinery/computer/telecomms/traffic/Destroy()
	servers = null
	return ..()

/obj/machinery/computer/telecomms/traffic/proc/create_log(entry)
	if(!user_name)
		CRASH("[type] tried to create a log with no user_name!")
	access_log += "\[[station_time_timestamp()]\] [user_name] [entry]"

/obj/machinery/computer/telecomms/traffic/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NTSLCoding", name)
		ui.open()

/// Without the access the window closes, so nobody can use a console someone else logged into. Emagged consoles are open to everyone.
/obj/machinery/computer/telecomms/traffic/ui_status(mob/user, datum/ui_state/state)
	if(!(obj_flags & EMAGGED) && !issilicon(user) && !IsAdminGhost(user) && !allowed(user))
		return UI_CLOSE
	return ..()

/// Logged in as this user, or the console is emagged and open to everyone
/obj/machinery/computer/telecomms/traffic/proc/is_session_owner(mob/user)
	if(obj_flags & EMAGGED)
		return TRUE
	return user_name && user?.ckey == session_ckey

/obj/machinery/computer/telecomms/traffic/ui_data(mob/user)
	var/list/data = list()
	var/list/server_data = list()
	for(var/obj/machinery/telecomms/server/server as anything in servers)
		server_data += list(list(
			"server" = REF(server),
			"server_id" = server.id,
			"server_name" = server.name,
			"run_code" = server.autoruncode,
		))
	data["server_data"] = server_data
	data["stored_code"] = storedcode
	data["network"] = network
	data["user_name"] = is_session_owner(user) ? user_name : "" // anyone else gets the login screen
	data["access_log"] = access_log.Copy()
	data["compiler_output"] = compiler_output.Copy()
	data["emagged"] = !!(obj_flags & EMAGGED)
	data["admin_view"] = !!user.client?.holder // enables an admin-only button in case of severe grief
	return data

/obj/machinery/computer/telecomms/traffic/ui_act(action, list/params)
	. = ..()
	var/mob/user = usr

	if(action == "admin_reset")
		if(!user.client?.holder)
			message_admins("[key_name_admin(user)] próbuje wywołać \"admin_reset\" na konsoli kontroli ruchu, nie będąc adminem.")
			return
		network = initial(network)
		refresh_servers()
		storedcode = NTSL_DEFAULT_CODE
		for(var/obj/machinery/telecomms/server/server as anything in servers)
			server.rawcode = NTSL_DEFAULT_CODE
			COOLDOWN_RESET(server, compile_cooldown)
		compiler_output = compile_all(user)
		message_admins("[key_name_admin(user)] wyczyścił kod NTSL na konsoli kontroli ruchu [ADMIN_VERBOSEJMP(src)].")
		log_telecomms("NTSL: [key_name(user)] cleared the NTSL code as an admin [loc_name(src)]")
		access_log += "\[[station_time_timestamp()]\] BŁĄD! NTSL ZDALNIE WYCZYSZCZONY PRZEZ PERSONEL NANOTRASEN!"
		return TRUE

	if(.)
		return

	playsound(src, "terminal_type", 15, FALSE)
	switch(action)
		if("refresh_servers")
			refresh_servers()
			return TRUE
		if("toggle_code_execution")
			if(!is_session_owner(user))
				return
			var/obj/machinery/telecomms/server/selected_server = locate(params["selected_server"]) in servers
			if(!selected_server)
				return
			selected_server.autoruncode = !selected_server.autoruncode
			create_log("[selected_server.autoruncode ? "włączył" : "wyłączył"] wykonywanie kodu na [selected_server.id].")
			return TRUE
		if("save_code")
			if(!is_session_owner(user) || !istext(params["saved_code"]))
				return
			storedcode = params["saved_code"]
			compiler_output = list("Zapisano kod.")
			return TRUE
		if("compile_code")
			if(!is_session_owner(user))
				message_admins("[key_name_admin(user)] próbuje skompilować NTSL bez zalogowania.")
				return
			if(istext(params["code"])) // save and compile in one action, so the compile can't run before the save arrives
				storedcode = params["code"]
			// A server still cooling down would keep the old program while the rest got the new one
			for(var/obj/machinery/telecomms/server/server as anything in servers)
				if(!QDELETED(server) && !COOLDOWN_FINISHED(server, compile_cooldown))
					compiler_output = list("Serwery się ładują, poczekaj chwilę.")
					return TRUE
			for(var/obj/machinery/telecomms/server/server as anything in servers)
				server.rawcode = storedcode
			compiler_output = compile_all(user)
			return TRUE
		if("set_network")
			if(!is_session_owner(user))
				return
			var/new_network = reject_bad_text(params["new_network"], 15)
			if(!new_network)
				return
			network = new_network
			refresh_servers()
			return TRUE
		if("log_in")
			if(obj_flags & EMAGGED) // stays logged in as System Administrator
				return TRUE
			var/new_name
			if(issilicon(user) || IsAdminGhost(user))
				new_name = "Administrator systemu"
			else if(allowed(user))
				var/obj/item/card/id/user_id = user.get_idcard(TRUE)
				if(user_id)
					new_name = "[user_id.registered_name] ([user_id.assignment])"
				else
					new_name = "[user.name] (NIEZNANY)"
			if(!new_name)
				to_chat(user, "<span class='warning'>Brak dostępu.</span>")
				return TRUE
			// Logging in takes the console over from whoever was logged in before
			user_name = new_name
			session_ckey = user.ckey
			create_log("zalogował się.")
			return TRUE
		if("log_out")
			if((obj_flags & EMAGGED) || !is_session_owner(user))
				return TRUE
			create_log("wylogował się.")
			user_name = null
			session_ckey = null
			return TRUE
		if("clear_logs")
			if(!is_session_owner(user))
				message_admins("[key_name_admin(user)] próbuje wyczyścić logi NTSL bez zalogowania.")
				return
			access_log.Cut()
			create_log("wyczyścił log dostępu.")
			return TRUE

/obj/machinery/computer/telecomms/traffic/proc/refresh_servers()
	servers.Cut()
	for(var/obj/machinery/telecomms/server/new_server in GLOB.telecomms_list)
		if(new_server.network != network)
			continue
		if(!unlimited_range && get_dist(src, new_server) > 15)
			continue
		servers += new_server

/obj/machinery/computer/telecomms/traffic/proc/compile_all(mob/user)
	for(var/obj/machinery/telecomms/server/server as anything in servers)
		if(QDELETED(server))
			servers -= server
	if(!length(servers))
		return list("Nie wykryto serwerów.")
	for(var/obj/machinery/telecomms/server/server as anything in servers)
		if(QDELETED(server))
			continue
		var/list/compile_errors = server.compile(user)
		if(!compile_errors)
			return list("Wystąpił błąd krytyczny. Skontaktuj się z administratorem sieci.")
		if(istext(compile_errors))
			return splittext(compile_errors, "\n")
		var/list/text_list = list()
		for(var/datum/scriptError/error in compile_errors)
			text_list += error.message
		if(length(text_list))
			return text_list
	if(user_name)
		create_log("skompilował kod na wszystkich serwerach sieci [network].")
	return list("Kompilacja zakończona.")

/obj/machinery/computer/telecomms/traffic/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	user_name = "Administrator systemu"
	create_log("zalogował się.")
	playsound(src, 'sound/effects/sparks4.ogg', 75, TRUE)
	to_chat(user, "<span class='notice'>Obchodzisz zabezpieczenia konsoli.</span>")

#undef NTSL_DEFAULT_CODE
