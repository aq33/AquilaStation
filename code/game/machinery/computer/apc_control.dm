/obj/machinery/computer/apc_control
	name = "power flow control console"
	desc = "Used to remotely control the flow of power to different parts of the station."
	icon_screen = "solar"
	icon_keyboard = "power_key"
	req_access = list(ACCESS_ENGINE)
	circuit = /obj/item/circuitboard/computer/apc_control
	light_color = LIGHT_COLOR_YELLOW
	var/mob/living/operator //Who's operating the computer right now
	var/obj/machinery/power/apc/active_apc //The APC we're using right now
	var/list/logs
	var/auth_id = "\[NULL\]"

/obj/machinery/computer/apc_control/process()
	if(operator && (!operator.Adjacent(src) || machine_stat))
		operator = null
		disconnect_apc()

/obj/machinery/computer/apc_control/attack_ai(mob/user)
	if(!IsAdminGhost(user))
		to_chat(user,"<span class='warning'>[src] nie obsługuje sterowania przez SI.</span>") //You already have APC access, cheater!
		return
	..(user)

//nsv13 - adjusted for shipwide APC control
/obj/machinery/computer/apc_control/proc/check_apc(obj/machinery/power/apc/APC, linked_overmap)
	return ((linked_overmap && linked_overmap == APC.get_overmap()) || APC.get_virtual_z_level() == get_virtual_z_level()) && !APC.malfhack && !APC.aidisabled && !(APC.obj_flags & EMAGGED) && !APC.machine_stat && !istype(APC.area, /area/ai_monitored) && !APC.area.outdoors
//nsv13 end

// AQUILA: okno TGUI ApcControl (z tg) zamiast starego HTML; filtry zastąpione sortowaniem i wyszukiwarką w oknie
/obj/machinery/computer/apc_control/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ApcControl", name)
		ui.open()

/obj/machinery/computer/apc_control/ui_data(mob/user)
	var/list/data = list()
	data["auth_id"] = auth_id
	data["authenticated"] = authenticated
	data["emagged"] = !!(obj_flags & EMAGGED)
	data["logs"] = list()
	data["apcs"] = list()
	for(var/entry in logs)
		data["logs"] += list(list("entry" = entry))
	if(!authenticated)
		return data
	var/linked_overmap = get_overmap() //nsv13 - console works shipwide
	for(var/obj/machinery/power/apc/APC as anything in GLOB.apcs_list)
		if(!check_apc(APC, linked_overmap))
			continue
		data["apcs"] += list(list(
			"name" = "[APC.area.name]",
			"operating" = APC.operating,
			"charge" = APC.cell ? round(APC.cell.percent()) : 0,
			"has_cell" = !!APC.cell,
			"load" = display_power(APC.lastused_total),
			"charging" = APC.charging,
			"chargeMode" = APC.chargemode,
			"eqp" = APC.equipment,
			"lgt" = APC.lighting,
			"env" = APC.environ,
			"responds" = !(APC.aidisabled || APC.panel_open),
			"active" = (APC == active_apc),
			"ref" = REF(APC),
		))
	return data

/// AQUILA: zrywa zdalne połączenie z aktualnym APC
/obj/machinery/computer/apc_control/proc/disconnect_apc(mob/user)
	if(!active_apc)
		return
	if(user)
		to_chat(user, "<span class='robot danger'>[icon2html(src, user)] Rozłączono z [active_apc].</span>")
	if(!active_apc.locked)
		active_apc.say("Anulowano zdalny dostęp. Interfejs zablokowany.")
		playsound(active_apc, 'sound/machines/boltsdown.ogg', 25, 0)
		playsound(active_apc, 'sound/machines/terminal_alert.ogg', 50, 0)
	active_apc.locked = TRUE
	active_apc.update_icon()
	active_apc.remote_control = null
	active_apc = null

/obj/machinery/computer/apc_control/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(!usr || !usr.canUseTopic(src, !issilicon(usr)) || machine_stat || QDELETED(src))
		return
	var/mob/user = usr
	if(action == "log-in")
		var/obj/item/card/id/ID = user.get_idcard(TRUE)
		if(istype(ID) && check_access(ID))
			authenticated = TRUE
			auth_id = "[ID.registered_name] ([ID.assignment])"
			operator = user
			log_activity("zalogował(a) się")
			playsound(src, 'sound/machines/terminal_on.ogg', 50, 0)
		else
			playsound(src, 'sound/machines/terminal_error.ogg', 50, 0)
			say("Odmowa dostępu.")
		return TRUE
	if(!authenticated)
		return
	operator = user
	switch(action)
		if("log-out")
			log_activity("wylogował(a) się")
			playsound(src, 'sound/machines/terminal_off.ogg', 50, 0)
			disconnect_apc(user)
			authenticated = FALSE
			auth_id = "\[NULL\]"
			return TRUE
		if("restore-logging")
			if(!(obj_flags & EMAGGED))
				return
			to_chat(user, "<span class='robot notice'>[icon2html(src, user)] Przywrócono funkcję logowania z kopii zapasowej.</span>")
			obj_flags &= ~EMAGGED
			LAZYADD(logs, "-=- W tym miejscu przywrócono pełną funkcjonalność logowania -=-")
			return TRUE
		if("clear-logs")
			if(!(obj_flags & EMAGGED))
				return
			logs = list()
			return TRUE
		if("check-logs")
			log_activity("sprawdził(a) logi")
			return TRUE
		if("check-apcs")
			log_activity("sprawdził(a) APC")
			return TRUE
		if("access-apc")
			playsound(src, "terminal_type", 50, 0)
			var/obj/machinery/power/apc/APC = locate(params["ref"]) in GLOB.apcs_list
			if(!APC || QDELETED(APC) || !check_apc(APC, get_overmap()) || APC.panel_open)
				to_chat(user, "<span class='robot danger'>[icon2html(src, user)] APC nie odpowiada na żądanie interfejsu. Zdalny dostęp może być wyłączony.</span>")
				return
			if(active_apc && active_apc != APC)
				disconnect_apc(user)
			to_chat(user, "<span class='robot notice'>[icon2html(src, user)] Połączono z APC w [get_area_name(APC.area, TRUE)]. Wysłano żądanie interfejsu.</span>")
			log_activity("zdalnie połączył(a) się z APC w [get_area_name(APC.area, TRUE)]")
			APC.remote_control = src
			APC.ui_interact(user)
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
			message_admins("[ADMIN_LOOKUPFLW(user)] remotely accessed [APC] from [src] at [AREACOORD(src)].")
			log_game("[key_name(user)] remotely accessed [APC] from [src] at [AREACOORD(src)].")
			if(APC.locked)
				APC.say("Wykryto zdalny dostęp. Interfejs odblokowany.")
				playsound(APC, 'sound/machines/boltsup.ogg', 25, 0)
				playsound(APC, 'sound/machines/terminal_alert.ogg', 50, 0)
			APC.locked = FALSE
			APC.update_icon()
			active_apc = APC
			return TRUE
		if("breaker")
			var/obj/machinery/power/apc/APC = locate(params["ref"]) in GLOB.apcs_list
			if(!APC || !check_apc(APC, get_overmap()) || APC.panel_open)
				return
			APC.toggle_breaker(user)
			log_activity("[APC.operating ? "włączył(a)" : "wyłączył(a)"] główny wyłącznik APC w [APC.area.name]")
			return TRUE
		if("toggle-minor")
			var/obj/machinery/power/apc/APC = locate(params["ref"]) in GLOB.apcs_list
			if(!APC || !check_apc(APC, get_overmap()) || APC.panel_open)
				return
			var/value = APC.setsubsystem(text2num(params["value"]))
			var/channel_name
			switch(params["type"])
				if("equipment")
					APC.equipment = value
					channel_name = "sprzęt"
				if("lighting")
					APC.lighting = value
					channel_name = "oświetlenie"
				if("environ")
					APC.environ = value
					channel_name = "środowisko"
				else
					return
			APC.update_icon()
			APC.update()
			var/static/list/state_names = list("wył.", "auto (wył.)", "wł.", "auto (wł.)")
			log_activity("ustawił(a) [channel_name] APC w [APC.area.name] na: [state_names[value + 1]]")
			log_game("[key_name(user)] set [params["type"]] of [APC] to [value] remotely from [src] at [AREACOORD(src)].")
			return TRUE

/obj/machinery/computer/apc_control/emag_act(mob/user)
	if(!authenticated)
		to_chat(user, "<span class='warning'>Omijasz wymagania dostępu [src] za pomocą emaga.</span>")
		authenticated = TRUE
		log_activity("zalogował(a) się")
	else if(!(obj_flags & EMAGGED))
		user.visible_message("<span class='warning'>[user] emaguje [src], wyłączając dokładne logowanie!</span>", "<span class='warning'>Emagujesz [src], wyłączając dokładne logowanie i umożliwiając czyszczenie logów.</span>")
		log_game("[key_name(user)] emagged [src] at [AREACOORD(src)], disabling operator tracking.")
		obj_flags |= EMAGGED
	playsound(src, "sparks", 50, 1)

/obj/machinery/computer/apc_control/proc/log_activity(log_text)
	var/op_string = operator && !(obj_flags & EMAGGED) ? "[operator]" : "\[NULL OPERATOR\]"
	LAZYADD(logs, "([station_time_timestamp()]) [op_string]: [log_text]")

/mob/proc/using_power_flow_console()
	for(var/obj/machinery/computer/apc_control/A in range(1, src))
		if(A.operator && A.operator == src && !A.machine_stat)
			return TRUE
	return
