// AQUILA - Wyciek gazu: w losowym pustym pomieszczeniu okrętu pojawia się chmura szkodliwego gazu, ogłoszenie podaje miejsce (port z VOREStation code/modules/events/atmos_leak.dm)
// As in VORE: up to 10 tries to find an unoccupied ship area (crew quarters, holodeck, engine rooms and shuttles excluded)
// with a free floor, a warning naming the area and the gas, then 10 standard tile volumes of the gas at room temperature
// let loose there. VORE rolls CO2 or N2O, plus phoron and methane above mundane severity; we have no severities and no
// methane, so the gas is rolled from carbon dioxide and nitrous oxide (40% each) and plasma (20%).

/datum/round_event_control/aquila_hex_atmos_leak
	name = "Wyciek gazu"
	typepath = /datum/round_event/aquila_hex_atmos_leak
	weight = 10
	min_players = 2
	max_occurrences = 3
	earliest_start = 15 MINUTES

/datum/round_event/aquila_hex_atmos_leak
	fakeable = FALSE
	announceWhen = 1
	startWhen = 5 // nobody is in the room, but give a bit of warning
	/// Area of the leak
	var/area/target_area
	/// Turf the gas comes out of
	var/turf/open/target_turf
	/// GAS_* id of the leaking gas
	var/gas_type

/datum/round_event/aquila_hex_atmos_leak/setup()
	gas_type = pick(40; GAS_CO2, 40; GAS_NITROUS, 20; GAS_PLASMA)
	var/static/list/excluded_areas = typecacheof(list(
		/area/shuttle,
		/area/crew_quarters,
		/area/holodeck,
		/area/engine,
		/area/solar,
	))
	var/list/area_types = GLOB.the_station_areas.Copy()
	for(var/i in 1 to 10)
		if(!length(area_types))
			break
		var/area_type = pick_n_take(area_types)
		if(excluded_areas[area_type])
			continue
		var/area/candidate = GLOB.areas_by_type[area_type]
		if(!candidate || aquila_hex_area_occupied(candidate))
			continue
		var/list/turfs = list()
		for(var/turf/open/floor/floor in get_area_turfs(area_type))
			if(is_station_level(floor.z) && !is_blocked_turf(floor))
				turfs += floor
		if(!length(turfs))
			continue
		target_area = candidate
		target_turf = pick(turfs)
		return

/datum/round_event/aquila_hex_atmos_leak/announce(fake)
	if(!target_area)
		return
	priority_announce("Uwaga: w obszarze [target_area.name] wykryto wyciek szkodliwego gazu ([aquila_hex_gas_name(gas_type)]). Opuśćcie ten obszar i opanujcie wyciek!", "Alarm atmosferyczny")

/datum/round_event/aquila_hex_atmos_leak/start()
	if(QDELETED(target_turf))
		log_game("Atmos Leak: no unoccupied ship area with a free floor, cancelling the event.")
		return kill()
	leak_gas(target_turf)
	log_game("Atmos Leak released [gas_type] in [AREACOORD(target_turf)].")

/// Lets 10 standard tile volumes of the gas loose on the turf
/datum/round_event/aquila_hex_atmos_leak/proc/leak_gas(turf/open/leak_turf)
	var/datum/gas_mixture/leak = new
	leak.set_moles(gas_type, 10 * MOLES_CELLSTANDARD)
	leak.set_temperature(T20C)
	leak_turf.assume_air(leak)
	leak_turf.air_update_turf()
	playsound(leak_turf, 'sound/effects/smoke.ogg', 50, TRUE)

/// Is a living player in the area
/proc/aquila_hex_area_occupied(area/checked)
	for(var/mob/living/crew in GLOB.player_list)
		if(crew.stat != DEAD && get_area(crew) == checked)
			return TRUE
	return FALSE

/// Polish name of a gas id for announcements
/proc/aquila_hex_gas_name(gas_id)
	switch(gas_id)
		if(GAS_CO2)
			return "dwutlenek węgla"
		if(GAS_NITROUS)
			return "podtlenek azotu"
		if(GAS_PLASMA)
			return "plazma"
	return "nieznany gaz"
