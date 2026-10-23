/obj/machinery/computer/ai_server_console
	name = "konsola przeglądu serwerów SI"
	desc = "Pokazuje stan szaf serwerowych i rdzeni danych w sieci SI: moc, temperaturę i zasoby."
	icon_keyboard = "tech_key"
	icon_screen = "ai-fixer"
	light_color = LIGHT_COLOR_PINK

	circuit = /obj/item/circuitboard/computer/ai_server_overview

/obj/machinery/computer/ai_server_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiServerConsole", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/computer/ai_server_console/ui_data(mob/user)
	var/list/data = list()

	var/turf/computer_turf = get_turf(src)
	var/datum/ai_os/os_used = GLOB.ai_os["[computer_turf.z]"]

	data["servers"] = list()
	for(var/obj/machinery/ai/server_cabinet/holder as anything in GLOB.ai_server_cabinets)
		if(!os_used || holder.linked_os != os_used)
			continue
		data["servers"] += list(list(
			"area" = get_area_name(holder, TRUE),
			"working" = holder.valid_holder(),
			"total_cpu" = holder.total_cpu,
			"ram" = holder.total_ram,
			"card_capacity" = "[length(holder.installed_racks)]/[holder.max_racks]",
			"temp" = round(holder.core_temp, 0.1),
		))

	data["cores"] = list()
	for(var/obj/machinery/ai/data_core/core as anything in GLOB.data_cores["[computer_turf.z]"])
		var/list/hosted = list()
		for(var/mob/living/silicon/ai/AI in core.contents)
			hosted += AI.name
		data["cores"] += list(list(
			"area" = get_area_name(core, TRUE),
			"working" = core.valid_holder() && core.valid_ticks > 0,
			"temp" = round(core.core_temp, 0.1),
			"battery" = core.integrated_battery ? round(core.integrated_battery.percent()) : null,
			"ais" = length(hosted) ? jointext(hosted, ", ") : null,
		))

	data["temp_limit"] = os_used ? os_used.get_temp_limit() : AI_TEMP_LIMIT

	return data
