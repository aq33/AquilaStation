// AQUILA - uszkodzenie komputerów: w części włączonych komputerów modułowych (PDA, laptopy, konsole) psuje się dysk twardy (port z Baystation12 code/modules/events/computer_damage.dm)

/datum/round_event_control/aquila_hex_computer_damage
	name = "Uszkodzenie komputerów"
	typepath = /datum/round_event/aquila_hex_computer_damage
	weight = 10
	min_players = 3
	max_occurrences = 2
	earliest_start = 20 MINUTES

/datum/round_event/aquila_hex_computer_damage
	startWhen = 1
	/// Computers that get a roll at a damaged drive: 4, 8 or 16, like the Bay severities
	var/number_of_victims = 4

/datum/round_event/aquila_hex_computer_damage/setup()
	number_of_victims = pick(4, 4, 4, 8, 8, 16) // mundane 50%, moderate 33%, major 17%

/datum/round_event/aquila_hex_computer_damage/start()
	var/list/victims = list()
	for(var/obj/item/modular_computer/computer in SSobj.processing) // every modular computer processes on SSobj
		if(!computer.enabled || !computer.all_components[MC_HDD])
			continue
		var/turf/T = get_turf(computer)
		if(T && is_station_level(T.z))
			victims += computer
	var/damaged = 0
	while(number_of_victims && length(victims))
		number_of_victims--
		var/obj/item/modular_computer/victim = pick_n_take(victims)
		if(prob(50))
			damage_drive(victim, prob(60))
			damaged++
	log_game("Computer Damage damaged [damaged] hard drive(s).")

/// Damages the hard drive of the computer: failure stops it completely, otherwise it only malfunctions now and then
/datum/round_event/aquila_hex_computer_damage/proc/damage_drive(obj/item/modular_computer/computer, failure)
	var/obj/item/computer_hardware/hard_drive/drive = computer.all_components[MC_HDD]
	if(!drive)
		return FALSE
	var/atom/shown = computer.physical || computer
	shown.visible_message("<span class='warning'>[shown] wydaje złowieszcze kliknięcia.</span>")
	if(failure)
		drive.damage = max(drive.damage, min(drive.damage_failure + 1, drive.max_damage))
	else
		drive.damage = max(drive.damage, min(drive.damage_malfunction + 1, drive.max_damage))
	return TRUE
