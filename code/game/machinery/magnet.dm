// Magnetic attractor, creates variable magnetic fields and attraction.
// Can also be used to emit electron/proton beams to create a center of magnetism on another tile

// tl;dr: it's magnets lol
// This was created for firing ranges, but I suppose this could have other applications - Doohl

/obj/machinery/magnetic_module
	icon = 'icons/obj/objects.dmi'
	icon_state = "floor_magnet-f"
	name = "electromagnetic generator"
	desc = "A device that uses station power to create points of magnetic energy."
	level = 1		// underfloor
	layer = LOW_OBJ_LAYER
	use_power = IDLE_POWER_USE
	idle_power_usage = 50

	var/freq = FREQ_MAGNETS		// radio frequency
	var/electricity_level = 1 // intensity of the magnetic pull
	var/magnetic_field = 1 // the range of magnetic attraction
	var/code = 0 // frequency code, they should be different unless you have a group of magnets working together or something
	var/turf/center // the center of magnetic attraction
	var/on = FALSE
	var/magneting = FALSE

	// x, y modifiers to the center turf; (0, 0) is centered on the magnet, whereas (1, -1) is one tile right, one tile down
	var/center_x = 0
	var/center_y = 0
	var/max_dist = 20 // absolute value of center_x,y cannot exceed this integer

/obj/machinery/magnetic_module/Initialize(mapload)
	..()
	var/turf/T = loc
	hide(T.intact)
	center = T
	SSradio.add_object(src, freq, RADIO_MAGNETS)
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/magnetic_module/LateInitialize()
	magnetic_process()

/obj/machinery/magnetic_module/Destroy()
	SSradio.remove_object(src, freq)
	center = null
	return ..()

// update the invisibility and icon
/obj/machinery/magnetic_module/hide(intact)
	invisibility = intact ? INVISIBILITY_MAXIMUM : 0
	update_icon()

// update the icon_state
/obj/machinery/magnetic_module/update_icon()
	var/state="floor_magnet"
	var/onstate=""
	if(!on)
		onstate="0"

	if(invisibility)
		icon_state = "[state][onstate]-f"	// if invisible, set icon to faded version
											// in case of being revealed by T-scanner
	else
		icon_state = "[state][onstate]"

/obj/machinery/magnetic_module/receive_signal(datum/signal/signal)

	var/command = signal.data["command"]
	var/modifier = signal.data["modifier"]
	var/signal_code = signal.data["code"]
	if(command && (signal_code == code))

		Cmd(command, modifier)



/obj/machinery/magnetic_module/proc/Cmd(command, modifier)

	if(command)
		switch(command)
			if("set-electriclevel")
				if(modifier)
					electricity_level = modifier
			if("set-magneticfield")
				if(modifier)
					magnetic_field = modifier

			if("add-elec")
				electricity_level++
				if(electricity_level > 12)
					electricity_level = 12
			if("sub-elec")
				electricity_level--
				if(electricity_level <= 0)
					electricity_level = 1
			if("add-mag")
				magnetic_field++
				if(magnetic_field > 4)
					magnetic_field = 4
			if("sub-mag")
				magnetic_field--
				if(magnetic_field <= 0)
					magnetic_field = 1

			if("set-x")
				if(modifier)
					center_x = modifier
			if("set-y")
				if(modifier)
					center_y = modifier

			if("N") // NORTH
				center_y++
			if("S")	// SOUTH
				center_y--
			if("E") // EAST
				center_x++
			if("W") // WEST
				center_x--
			if("C") // CENTER
				center_x = 0
				center_y = 0
			if("R") // RANDOM
				center_x = rand(-max_dist, max_dist)
				center_y = rand(-max_dist, max_dist)

			if("set-code")
				if(modifier)
					code = modifier
			if("toggle-power")
				on = !on

				if(on)
					INVOKE_ASYNC(src, PROC_REF(magnetic_process))



/obj/machinery/magnetic_module/process()
	if(machine_stat & NOPOWER)
		on = FALSE

	// Sanity checks:
	if(electricity_level <= 0)
		electricity_level = 1
	if(magnetic_field <= 0)
		magnetic_field = 1


	// Limitations:
	if(abs(center_x) > max_dist)
		center_x = max_dist
	if(abs(center_y) > max_dist)
		center_y = max_dist
	if(magnetic_field > 4)
		magnetic_field = 4
	if(electricity_level > 12)
		electricity_level = 12

	// Update power usage:
	if(on)
		use_power = ACTIVE_POWER_USE
		active_power_usage = electricity_level*15
	else
		use_power = NO_POWER_USE

	update_icon()


/obj/machinery/magnetic_module/proc/magnetic_process() // proc that actually does the magneting
	if(magneting)
		return
	while(on)

		magneting = TRUE
		center = locate(x+center_x, y+center_y, z)
		if(center)
			for(var/obj/M in orange(magnetic_field, center))
				if(!M.anchored && (M.flags_1 & CONDUCT_1))
					step_towards(M, center)

			for(var/mob/living/silicon/S in orange(magnetic_field, center))
				if(isAI(S))
					continue
				step_towards(S, center)

		use_power(electricity_level * 5)
		sleep(13 - electricity_level)

	magneting = FALSE




/obj/machinery/magnetic_controller
	name = "magnetic control console"
	icon = 'icons/obj/airlock_machines.dmi' // uses an airlock machine icon, THINK GREEN HELP THE ENVIRONMENT - RECYCLING!
	icon_state = "airlock_control_standby"
	density = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 45
	var/frequency = FREQ_MAGNETS
	var/code = 0
	var/list/magnets = list()
	var/title = "Konsola sterowania magnesami"
	var/autolink = 0 // if set to 1, can't probe for other magnets!

	var/pathpos = 1 // position in the path
	var/path = "w;e;e;w;s;n;n;s" // text path of the magnet
	var/speed = 1 // lowest = 1, highest = 10
	var/list/rpath = list() // real path of the magnet, used in iterator

	var/moving = 0 // 1 if scheduled to loop
	var/looping = 0 // 1 if looping

	var/datum/radio_frequency/radio_connection


/obj/machinery/magnetic_controller/Initialize(mapload)
	. = ..()
	if(autolink)
		for(var/obj/machinery/magnetic_module/M in GLOB.machines)
			if(M.freq == frequency && M.code == code)
				magnets.Add(M)

	if(path) // check for default path
		filter_path() // renders rpath
	radio_connection = SSradio.add_object(src, frequency, RADIO_MAGNETS)

/obj/machinery/magnetic_controller/Destroy()
	SSradio.remove_object(src, frequency)
	magnets = null
	rpath = null
	return ..()

/obj/machinery/magnetic_controller/process()
	if(magnets.len == 0 && autolink)
		for(var/obj/machinery/magnetic_module/M in GLOB.machines)
			if(M.freq == frequency && M.code == code)
				magnets.Add(M)

/obj/machinery/magnetic_controller/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MagnetController", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/magnetic_controller/ui_data(mob/user)
	var/list/data = list()
	data["title"] = title
	data["autolink"] = autolink
	data["frequency"] = frequency
	data["code"] = code
	data["speed"] = speed
	data["path"] = path
	data["moving"] = moving
	var/list/magnet_list = list()
	for(var/obj/machinery/magnetic_module/M in magnets)
		magnet_list += list(list(
			"on" = M.on,
			"electricity_level" = M.electricity_level,
			"magnetic_field" = M.magnetic_field,
		))
	data["magnets"] = magnet_list
	return data

/obj/machinery/magnetic_controller/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	// Polecenia radiowe idą do wszystkich magnesów z tym samym kodem
	var/static/list/radio_commands = list(
		"togglepower" = "toggle-power",
		"minuselec" = "sub-elec",
		"pluselec" = "add-elec",
		"minusmag" = "sub-mag",
		"plusmag" = "add-mag",
	)
	if(radio_commands[action])
		var/datum/signal/signal = new(list("code" = code))
		signal.data["command"] = radio_commands[action]
		radio_connection.post_signal(src, signal, filter = RADIO_MAGNETS)
		return TRUE

	switch(action)
		if("plusspeed")
			speed = min(speed + 1, 10)
			return TRUE
		if("minusspeed")
			speed = max(speed - 1, 1)
			return TRUE
		if("setpath")
			var/newpath = stripped_input(usr, "Wyznacz nową ścieżkę!", "Nowa ścieżka", path)
			if(newpath && newpath != "")
				moving = 0 // stop moving
				path = newpath
				pathpos = 1 // reset position
				filter_path() // renders rpath
			return TRUE
		if("togglemoving")
			moving = !moving
			if(moving)
				spawn() MagnetMove()
			return TRUE

/obj/machinery/magnetic_controller/proc/MagnetMove()
	if(looping)
		return

	while(moving && rpath.len >= 1)

		if(machine_stat & (BROKEN|NOPOWER))
			break

		looping = 1

		// Prepare the radio signal
		var/datum/signal/signal = new(list("code" = code))

		if(pathpos > rpath.len) // if the position is greater than the length, we just loop through the list!
			pathpos = 1

		var/nextmove = uppertext(rpath[pathpos]) // makes it un-case-sensitive

		if(!(nextmove in list("N","S","E","W","C","R")))
			// N, S, E, W are directional
			// C is center
			// R is random (in magnetic field's bounds)
			qdel(signal)
			break // break the loop if the character located is invalid

		signal.data["command"] = nextmove


		pathpos++ // increase iterator

		// Broadcast the signal
		spawn()
			radio_connection.post_signal(src, signal, filter = RADIO_MAGNETS)

		if(speed == 10)
			sleep(1)
		else
			sleep(12-speed)

	looping = 0


/obj/machinery/magnetic_controller/proc/filter_path()
	// Generates the rpath variable using the path string, think of this as "string2list"
	// Doesn't use params2list() because of the akward way it stacks entities
	rpath = list() //  clear rpath
	var/maximum_characters = 50
	var/lentext = length(path)
	var/nextchar = ""
	var/charcount = 0

	for(var/i = 1, i <= lentext, i += length(nextchar)) // iterates through all characters in path
		nextchar = path[i] // find next character

		if(nextchar in list(";", "&", "*", " ")) // if char is a separator, ignore
			continue

		rpath += nextchar // else, add to list
		// there doesn't HAVE to be separators but it makes paths syntatically visible
		charcount++
		if(charcount >= maximum_characters)
			break
