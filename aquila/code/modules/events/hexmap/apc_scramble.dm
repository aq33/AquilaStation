// AQUILA - Rozregulowane APC: w kilku działających APC po cichu wyłącza się jeden kanał zasilania (port z BlueMoon-Station code/modules/events/apc_scramble.dm)
// As in BlueMoon, 3-6 working APCs on the ship flip one random channel (lighting, equipment or environment) off with no
// announcement and nothing breaks: an engineer opens the APC interface and switches it back. BlueMoon's scramble_channel()
// is not in the source we have, so the channel is switched off here with the same setsubsystem/update path the APC
// interface uses. APCs of areas with an AI core are skipped, so the event never turns the AI off.

/datum/round_event_control/aquila_hex_apc_scramble
	name = "Rozregulowane APC"
	typepath = /datum/round_event/aquila_hex_apc_scramble
	weight = 15
	max_occurrences = 4
	earliest_start = 10 MINUTES
	alert_observers = FALSE

/datum/round_event/aquila_hex_apc_scramble
	fakeable = FALSE
	startWhen = 1
	/// How many APCs lose a channel
	var/scramble_count = 0
	/// How many APCs did lose a channel
	var/scrambled = 0

/datum/round_event/aquila_hex_apc_scramble/setup()
	scramble_count = rand(3, 6)

/datum/round_event/aquila_hex_apc_scramble/start()
	var/list/candidates = list()
	for(var/obj/machinery/power/apc/apc as anything in GLOB.apcs_list)
		var/turf/apc_turf = get_turf(apc)
		if(!apc_turf || !is_station_level(apc_turf.z) || !can_scramble(apc))
			continue
		candidates += apc
	if(!length(candidates))
		log_game("APC Scramble: no working APC on the ship, cancelling the event.")
		return kill()
	for(var/i in 1 to min(scramble_count, length(candidates)))
		if(scramble_apc(pick_n_take(candidates)))
			scrambled++
	log_game("APC Scramble switched a power channel off in [scrambled] APC(s).")

/// A working APC with at least one channel on, outside the AI core
/datum/round_event/aquila_hex_apc_scramble/proc/can_scramble(obj/machinery/power/apc/apc)
	if(QDELETED(apc) || !apc.area || !apc.cell || apc.shorted || !apc.operating || apc.failure_timer || apc.malfhack)
		return FALSE
	if(apc.machine_stat & (NOPOWER|BROKEN|MAINT))
		return FALSE
	for(var/mob/living/silicon/ai/ai as anything in GLOB.ai_list)
		if(get_area(ai) == apc.area)
			return FALSE
	return length(channels_on(apc)) > 0

/// Names of the channels of the APC that are on (manual or auto)
/datum/round_event/aquila_hex_apc_scramble/proc/channels_on(obj/machinery/power/apc/apc)
	. = list()
	if(apc.lighting > 1)
		. += "lighting"
	if(apc.equipment > 1)
		. += "equipment"
	if(apc.environ > 1)
		. += "environ"

/// Switches one random channel of the APC off, as from its interface. Returns the channel or null
/datum/round_event/aquila_hex_apc_scramble/proc/scramble_apc(obj/machinery/power/apc/apc)
	if(!can_scramble(apc))
		return null
	var/channel = pick(channels_on(apc))
	switch(channel)
		if("lighting")
			apc.lighting = apc.setsubsystem(0)
		if("equipment")
			apc.equipment = apc.setsubsystem(0)
		if("environ")
			apc.environ = apc.setsubsystem(0)
	apc.update_appearance()
	apc.update()
	playsound(apc, 'sound/machines/click.ogg', 15, TRUE, -3)
	log_game("APC Scramble switched [channel] off in [AREACOORD(apc)].")
	return channel
