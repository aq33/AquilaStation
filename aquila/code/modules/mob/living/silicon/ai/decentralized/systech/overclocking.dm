#define OVERCLOCKING_DURATION (5 SECONDS)
#define OVERCLOCKING_HISTORY_LENGTH 5

/obj/machinery/computer/ai_overclocking
	name = "stanowisko podkręcania"
	desc = "Służy do podkręcania neuronowych jednostek obliczeniowych. Wyższe taktowanie przy większym poborze mocy, o ile procesor to wytrzyma."
	icon_keyboard = "tech_key"
	icon_screen = "ai-fixer"
	light_color = LIGHT_COLOR_PINK
	circuit = /obj/item/circuitboard/computer/ai_overclocking

	var/obj/item/ai_cpu/inserted_cpu = null
	var/overclocking = FALSE

	COOLDOWN_DECLARE(overclocking_timer)

/obj/machinery/computer/ai_overclocking/proc/record_result(valid)
	if(length(inserted_cpu.last_overclocking_values) >= OVERCLOCKING_HISTORY_LENGTH)
		inserted_cpu.last_overclocking_values.Cut(1, 2)
	inserted_cpu.last_overclocking_values += list(list("speed" = inserted_cpu.speed, "power" = inserted_cpu.power_multiplier, "valid" = valid))

/obj/machinery/computer/ai_overclocking/proc/reset_cpu()
	inserted_cpu.speed = initial(inserted_cpu.speed)
	inserted_cpu.power_multiplier = initial(inserted_cpu.power_multiplier)

/obj/machinery/computer/ai_overclocking/process()
	. = ..()
	if(!.)
		if(inserted_cpu)
			if(overclocking)
				overclocking = FALSE
				reset_cpu()
				record_result(FALSE)
			inserted_cpu.forceMove(drop_location())
			inserted_cpu = null
		return

	if(overclocking && COOLDOWN_FINISHED(src, overclocking_timer))
		overclocking = FALSE
		if(!inserted_cpu)
			return
		var/overclock_result = inserted_cpu.valid_overclock()
		if(overclock_result == SUCCESSFUL_OVERCLOCK)
			say("Podkręcenie stabilne.")
			record_result(TRUE)
			inserted_cpu.forceMove(drop_location())
			inserted_cpu = null
		else
			say("Podkręcenie niestabilne.")
			say("Możliwa przyczyna: [overclock_result]")
			record_result(FALSE)
			reset_cpu()
		SStgui.update_uis(src)

/obj/machinery/computer/ai_overclocking/Destroy()
	if(inserted_cpu)
		reset_cpu()
		inserted_cpu.forceMove(drop_location())
		inserted_cpu = null
	return ..()

/obj/machinery/computer/ai_overclocking/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/ai_cpu))
		return ..()
	if(inserted_cpu)
		balloon_alert(user, "procesor już włożony!")
		return TRUE
	if(!user.transferItemToLoc(I, src))
		return TRUE
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
	inserted_cpu = I
	SStgui.update_uis(src)
	return TRUE

/obj/machinery/computer/ai_overclocking/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiOverclocking", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/computer/ai_overclocking/ui_data(mob/user)
	var/list/data = list()

	data["has_cpu"] = !!inserted_cpu
	data["overclocking"] = overclocking

	if(inserted_cpu)
		data["speed"] = inserted_cpu.speed
		data["max_speed"] = inserted_cpu.max_speed
		data["power_multiplier"] = inserted_cpu.power_multiplier
		data["max_power_multiplier"] = inserted_cpu.max_power_multiplier
		data["power_usage"] = inserted_cpu.get_power_usage()
		var/time_left_percent = COOLDOWN_TIMELEFT(src, overclocking_timer) / OVERCLOCKING_DURATION
		data["overclock_progress"] = overclocking ? time_left_percent : FALSE
		data["last_values"] = inserted_cpu.last_overclocking_values

	return data

/obj/machinery/computer/ai_overclocking/ui_static_data(mob/user)
	var/list/data = list()
	data["MINIMUM_CPU_SPEED"] = MINIMUM_CPU_SPEED
	data["MINIMUM_CPU_POWER"] = MINIMUM_CPU_POWER
	return data

/obj/machinery/computer/ai_overclocking/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("eject_cpu")
			if(!inserted_cpu || overclocking)
				return
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
			reset_cpu()
			if(!usr.put_in_hands(inserted_cpu))
				inserted_cpu.forceMove(drop_location())
			inserted_cpu = null
			. = TRUE
		if("set_speed")
			if(!inserted_cpu || overclocking)
				return
			var/new_speed = text2num(params["new_speed"])
			if(!isnum(new_speed))
				return
			inserted_cpu.speed = clamp(round(new_speed, 0.01), MINIMUM_CPU_SPEED, inserted_cpu.max_speed)
			. = TRUE
		if("set_power")
			if(!inserted_cpu || overclocking)
				return
			var/new_power = text2num(params["new_power"])
			if(!isnum(new_power))
				return
			inserted_cpu.power_multiplier = clamp(round(new_power, 0.01), MINIMUM_CPU_POWER, inserted_cpu.max_power_multiplier)
			. = TRUE

		if("test_overclock")
			if(!inserted_cpu || overclocking)
				return
			overclocking = TRUE
			COOLDOWN_START(src, overclocking_timer, OVERCLOCKING_DURATION)
			. = TRUE

		if("stop_overclock")
			if(!inserted_cpu || !overclocking)
				return
			overclocking = FALSE
			reset_cpu()
			. = TRUE

#undef OVERCLOCKING_DURATION
#undef OVERCLOCKING_HISTORY_LENGTH
