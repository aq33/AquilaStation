/obj/machinery/computer/ai_resource_distribution
	name = "konsola dystrybucji zasobów SI"
	desc = "Rozdziela moc obliczeniową (CPU) i pamięć (RAM) serwerowni między działające sztuczne inteligencje."
	req_one_access = list(ACCESS_RD, ACCESS_TCOMSAT)
	circuit = /obj/item/circuitboard/computer/ai_resource_distribution
	icon_keyboard = "tech_key"
	icon_screen = "ai-fixer"
	light_color = LIGHT_COLOR_PINK

	var/human_only = FALSE

/obj/machinery/computer/ai_resource_distribution/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	authenticated = TRUE
	if(user)
		balloon_alert(user, "zabezpieczenia obejście")
	return TRUE

/obj/machinery/computer/ai_resource_distribution/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiResources", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/computer/ai_resource_distribution/ui_data(mob/user)
	var/list/data = list()
	data["authenticated"] = authenticated

	if(obj_flags & EMAGGED)
		data["username"] = "BŁĄD"
		data["has_access"] = TRUE
	else if(issilicon(user))
		data["username"] = user.name
		data["has_access"] = TRUE
	else if(IsAdminGhost(user))
		data["username"] = user.client.holder.admin_signature || "Centrala"
		data["has_access"] = TRUE
	else if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		data["has_access"] = allowed(user)
		data["username"] = human_user.get_authentification_name("Nieznany")
	else
		data["has_access"] = allowed(user)
		data["username"] = user.name

	if(!authenticated)
		return data

	var/turf/computer_turf = get_turf(src)
	var/datum/ai_os/os_using = GLOB.ai_os["[computer_turf.z]"]
	data["total_cpu"] = os_using?.total_cpu || 0
	data["total_ram"] = os_using?.total_ram || 0

	data["total_assigned_cpu"] = os_using?.total_cpu_assigned() || 0
	data["total_assigned_ram"] = os_using?.total_ram_assigned() || 0

	data["human_only"] = human_only

	data["ais"] = list()

	for(var/obj/machinery/ai/data_core/data_core as anything in GLOB.data_cores["[computer_turf.z]"])
		for(var/mob/living/silicon/ai/A in data_core.contents)
			data["ais"] += list(list(
				"name" = A.name,
				"ref" = REF(A),
				"assigned_cpu" = os_using?.cpu_assigned[A] || 0,
				"assigned_ram" = os_using?.ram_assigned[A] || 0,
			))

	return data

/obj/machinery/computer/ai_resource_distribution/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	playsound(src, "terminal_type", 50, FALSE)

	var/mob/user = usr
	if(!authenticated)
		if(action == "log_in")
			if(allowed(user) || (obj_flags & EMAGGED))
				authenticated = TRUE
				return TRUE
		return

	var/is_human = ishuman(user)
	var/turf/computer_turf = get_turf(src)
	var/datum/ai_os/os_using = GLOB.ai_os["[computer_turf.z]"]
	if(!os_using && action != "log_out")
		return

	switch(action)
		if("log_out")
			authenticated = FALSE
			. = TRUE

		if("clear_ai_resources")
			var/mob/living/silicon/ai/target_ai = locate(params["targetAI"]) in os_using.ai_list
			if(!istype(target_ai))
				return
			if(human_only && !is_human)
				to_chat(user, span_warning("CAPTCHA nieudana. Tę konsolę może obsługiwać tylko człowiek."))
				return
			os_using.clear_ai_resources(target_ai)
			. = TRUE

		if("set_cpu")
			var/mob/living/silicon/ai/target_ai = locate(params["targetAI"]) in os_using.ai_list
			if(!istype(target_ai))
				return
			if(human_only && !is_human)
				to_chat(user, span_warning("CAPTCHA nieudana. Tę konsolę może obsługiwać tylko człowiek."))
				return
			var/amount = text2num(params["amount_cpu"])
			if(!isnum(amount) || amount < 0)
				return
			os_using.set_cpu(target_ai, amount, TRUE)
			. = TRUE

		if("set_ram")
			var/mob/living/silicon/ai/target_ai = locate(params["targetAI"]) in os_using.ai_list
			if(!istype(target_ai))
				return
			if(human_only && !is_human)
				to_chat(user, span_warning("CAPTCHA nieudana. Tę konsolę może obsługiwać tylko człowiek."))
				return
			var/amount = text2num(params["amount_ram"])
			if(!isnum(amount) || amount < 0)
				return
			os_using.set_ram(target_ai, round(amount), TRUE)
			. = TRUE

		if("toggle_human_status")
			if(!is_human)
				to_chat(user, span_warning("CAPTCHA nieudana. Tę konsolę może obsługiwać tylko człowiek."))
				return
			human_only = !human_only
			balloon_alert(user, human_only ? "tylko ludzie" : "dopuszczone krzemowce")
			. = TRUE
