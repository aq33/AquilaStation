/obj/machinery/computer/pod
	name = "mass driver launch control"
	desc = "A combined blastdoor and mass driver control unit."
	var/obj/machinery/mass_driver/connected = null
	var/title = "Sterowanie katapultą masową"
	var/id = 1
	var/timing = 0
	var/time = 30
	var/range = 4


/obj/machinery/computer/pod/Initialize(mapload)
	. = ..()
	for(var/obj/machinery/mass_driver/M in range(range, src))
		if(M.id == id)
			connected = M


/obj/machinery/computer/pod/proc/alarm()
	if(machine_stat & (NOPOWER|BROKEN))
		return

	if(!connected)
		say("Nie można zlokalizować złącza katapulty masowej. Anulowanie sekwencji odpalenia!")
		return

	for(var/obj/machinery/door/poddoor/M in range(range, src))
		if(M.id == id)
			M.open()

	sleep(20)
	for(var/obj/machinery/mass_driver/M in range(range, src))
		if(M.id == id)
			M.power = connected.power
			M.drive()

	sleep(50)
	for(var/obj/machinery/door/poddoor/M in range(range, src))
		if(M.id == id)
			M.close()

// AQUILA: okno TGUI MassDriverControl (z tg) zamiast starego HTML
/obj/machinery/computer/pod/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MassDriverControl", title)
		ui.open()

/obj/machinery/computer/pod/ui_data(mob/user)
	var/list/data = list()
	data["connected"] = !!connected
	data["seconds"] = round(time % 60)
	data["minutes"] = round((time - data["seconds"]) / 60)
	data["timing"] = !!timing
	data["power"] = connected ? connected.power : 0.25
	data["poddoor"] = FALSE
	for(var/obj/machinery/door/poddoor/door in range(range, src))
		if(door.id == id)
			data["poddoor"] = TRUE
			break
	return data

/obj/machinery/computer/pod/process()
	if(!..())
		return
	if(timing)
		if(time > 0)
			time = round(time) - 1
		else
			INVOKE_ASYNC(src, PROC_REF(alarm))
			time = 0
			timing = 0

/obj/machinery/computer/pod/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(!allowed(usr))
		to_chat(usr, "<span class='warning'>Odmowa dostępu.</span>")
		return
	add_fingerprint(usr)
	switch(action)
		if("set_power")
			if(!connected)
				return
			var/value = text2num(params["power"])
			if(!value)
				return
			connected.power = clamp(value, 0.25, 16)
			return TRUE
		if("launch")
			INVOKE_ASYNC(src, PROC_REF(alarm))
			return TRUE
		if("time")
			timing = !timing
			return TRUE
		if("input")
			var/adjust = text2num(params["adjust"])
			if(!adjust)
				return
			time = clamp(round(time + adjust), 0, 120)
			return TRUE
		if("door")
			for(var/obj/machinery/door/poddoor/M in range(range, src))
				if(M.id == id)
					if(M.density)
						INVOKE_ASYNC(M, TYPE_PROC_REF(/obj/machinery/door, open))
					else
						INVOKE_ASYNC(M, TYPE_PROC_REF(/obj/machinery/door, close))
			return TRUE
		if("driver_test")
			if(!connected)
				return
			for(var/obj/machinery/mass_driver/M in range(range, src))
				if(M.id == id)
					M.power = connected.power
					M.drive()
			return TRUE

/obj/machinery/computer/pod/old
	name = "\improper DoorMex control console"
	title = "Sterowanie drzwiami"
	icon_state = "oldcomp"
	icon_screen = "library"
	icon_keyboard = "no_keyboard"

/obj/machinery/computer/pod/old/syndicate
	name = "\improper ProComp Executive IIc"
	desc = "The Syndicate operate on a tight budget. Operates external airlocks."
	title = "Sterowanie zewnętrzną śluzą"
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/computer/pod/old/swf
	name = "\improper Magix System IV"
	desc = "An arcane artifact that holds much magic. Running E-Knock 2.2: Sorcerer's Edition."
