// AQUILA - Aktualizacja komputerów: część konsol i włączonych komputerów modułowych (PDA, laptopy) na chwilę zajmuje instalacja aktualizacji (port z Baystation12 code/modules/events/computer_update.dm)
// Bay gives every NTOS device with a network connection a number of update bytes that it installs slowly while still
// usable. Ours blocks a random part of the devices for 30-90 seconds instead: opening one shows the update progress and
// nothing else. A third of the standard consoles and of the switched on modular computers are hit; ship control
// consoles (helm, weapons, overmap), communications consoles and the arcade are skipped, so the update never takes
// the ship out of a fight. Devices that are off or unpowered are skipped, like Bay's devices without a network.

/datum/round_event_control/aquila_hex_computer_update
	name = "Aktualizacja komputerów"
	typepath = /datum/round_event/aquila_hex_computer_update
	weight = 10
	min_players = 3
	max_occurrences = 2
	earliest_start = 15 MINUTES

/datum/round_event/aquila_hex_computer_update
	fakeable = FALSE
	startWhen = 1
	announceWhen = 2
	/// Chance for each device to get the update
	var/update_chance = 33
	/// Devices that got the update
	var/updated = 0

/datum/round_event/aquila_hex_computer_update/start()
	var/static/list/skipped_consoles = typecacheof(list(
		/obj/machinery/computer/ship,
		/obj/machinery/computer/communications,
		/obj/machinery/computer/arcade,
	))
	for(var/obj/machinery/computer/console in GLOB.machines)
		if(is_type_in_typecache(console, skipped_consoles) || (console.machine_stat & (NOPOWER|BROKEN)))
			continue
		var/turf/T = get_turf(console)
		if(T && is_station_level(T.z) && prob(update_chance))
			start_update(console, rand(30, 90) SECONDS)
	for(var/obj/item/modular_computer/computer in SSobj.processing) // every modular computer processes on SSobj
		if(!computer.enabled)
			continue
		var/turf/T = get_turf(computer)
		if(T && is_station_level(T.z) && prob(update_chance))
			start_update(computer, rand(30, 90) SECONDS)
	log_game("Computer Update: [updated] device(s) installing updates.")

/datum/round_event/aquila_hex_computer_update/announce(fake)
	if(!updated && !fake)
		return
	priority_announce("Burza jonowa zakłóciła synchronizację oprogramowania. Sieć NTNet wymusiła pilną aktualizację części konsol i komputerów pokładowych. Prosimy nie wyłączać urządzeń podczas instalacji.", "NTNet: aktualizacja systemu")

/// Starts an update of the device for the given time
/datum/round_event/aquila_hex_computer_update/proc/start_update(atom/device, duration)
	if(QDELETED(device))
		return FALSE
	var/until = world.time + duration
	if(istype(device, /obj/machinery/computer))
		var/obj/machinery/computer/console = device
		console.aquila_update_start = world.time
		console.aquila_update_until = until
	else if(istype(device, /obj/item/modular_computer))
		var/obj/item/modular_computer/computer = device
		computer.aquila_update_start = world.time
		computer.aquila_update_until = until
	else
		return FALSE
	var/atom/shown = device
	if(istype(device, /obj/item/modular_computer))
		var/obj/item/modular_computer/computer = device
		shown = computer.physical || computer
	shown.visible_message("<span class='notice'>Na ekranie [shown] pojawia się napis: „Instalowanie aktualizacji. Nie wyłączaj urządzenia”.</span>")
	updated++
	return TRUE

/// Text shown instead of the screen while an update installs, null when there is no update
/proc/aquila_update_screen(update_start, update_until)
	if(world.time >= update_until)
		return null
	var/percent = clamp(round((world.time - update_start) / max(1, update_until - update_start) * 100), 0, 99)
	return "Instalowanie aktualizacji: [percent]%. Nie wyłączaj urządzenia."

/obj/machinery/computer
	/// world.time an NTNet update started, see aquila_hex_computer_update
	var/aquila_update_start = 0
	/// world.time the NTNet update ends
	var/aquila_update_until = 0

/// Shows the update progress to the user instead of the console, returns TRUE while an update installs
/obj/machinery/computer/proc/aquila_update_blocks(mob/user)
	var/screen = aquila_update_screen(aquila_update_start, aquila_update_until)
	if(!screen)
		return FALSE
	to_chat(user, "<span class='warning'>[src]: [screen]</span>")
	return TRUE

/obj/machinery/computer/interact(mob/user, special_state)
	if(!isobserver(user) && aquila_update_blocks(user))
		return
	return ..()

/obj/item/modular_computer
	/// world.time an NTNet update started, see aquila_hex_computer_update
	var/aquila_update_start = 0
	/// world.time the NTNet update ends
	var/aquila_update_until = 0

/// Shows the update progress to the user instead of the screen, returns TRUE while an update installs
/obj/item/modular_computer/proc/aquila_update_blocks(mob/user)
	var/screen = aquila_update_screen(aquila_update_start, aquila_update_until)
	if(!screen)
		return FALSE
	to_chat(user, "<span class='warning'>[physical || src]: [screen]</span>")
	return TRUE

/obj/item/modular_computer/interact(mob/user)
	if(enabled && !isobserver(user) && aquila_update_blocks(user))
		return
	return ..()
