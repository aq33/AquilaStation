// AQUILA - uszkodzenie APC: przepięcie pali interfejs jednego APC na statku albo kilku w okolicy, APC w tunelach serwisowych obrywają najczęściej (port z Baystation12 code/modules/events/apc_damage.dm)

/datum/round_event_control/aquila_hex_apc_damage
	name = "APC Damage"
	typepath = /datum/round_event/aquila_hex_apc_damage
	weight = 10
	min_players = 3
	max_occurrences = 3
	earliest_start = 15 MINUTES

/datum/round_event/aquila_hex_apc_damage
	startWhen = 1
	/// Range around the first APC in which other APCs are broken too: 0 (one APC), 7 or 15, like the Bay severities
	var/severity_range = 0

/datum/round_event/aquila_hex_apc_damage/setup()
	severity_range = pick(0, 0, 0, 7, 7, 15) // mundane 50%, moderate 33%, major 17%

/datum/round_event/aquila_hex_apc_damage/start()
	var/obj/machinery/power/apc/epicentre = pick_random_apc()
	if(!epicentre)
		return
	var/broken = damage_apcs(epicentre, severity_range)
	log_game("APC Damage broke [broken] APC interface(s) around [AREACOORD(epicentre)] (range [severity_range]).")

/// Random valid APC on the ship, APCs in maintenance are three times more likely (as in Bay)
/datum/round_event/aquila_hex_apc_damage/proc/pick_random_apc()
	var/list/apcs = list()
	for(var/obj/machinery/power/apc/apc as anything in GLOB.apcs_list)
		if(!is_valid_apc(apc) || !is_station_level(apc.z))
			continue
		apcs += apc
		if(istype(apc.area, /area/maintenance))
			apcs += apc
			apcs += apc
	if(length(apcs))
		return pick(apcs)

/// Breaks the interface of every valid APC in range of the epicentre, returns how many were broken
/datum/round_event/aquila_hex_apc_damage/proc/damage_apcs(obj/machinery/power/apc/epicentre, range)
	. = 0
	for(var/obj/machinery/power/apc/apc in range(range, epicentre))
		if(!is_valid_apc(apc))
			continue
		// Same result as an emag: the lock is fried and the interface stays open until the board is replaced
		flick("apc-spark", apc)
		playsound(apc, "sparks", 75, TRUE)
		apc.obj_flags |= EMAGGED
		apc.locked = FALSE
		apc.wires?.ui_update()
		apc.update_appearance()
		apc.visible_message("<span class='warning'>Z [apc] sypią się iskry, a jego ekran wyświetla same błędy!</span>")
		.++

/// APCs that can still be broken: working, closed, not taken over by a malfunctioning AI
/datum/round_event/aquila_hex_apc_damage/proc/is_valid_apc(obj/machinery/power/apc/apc)
	if(QDELETED(apc) || (apc.obj_flags & EMAGGED) || apc.malfhack || apc.opened || apc.panel_open)
		return FALSE
	if(apc.machine_stat & (BROKEN|MAINT))
		return FALSE
	return TRUE
