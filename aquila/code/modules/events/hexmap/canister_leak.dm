// AQUILA - Pęknięty kanister: losowy pełny kanister na okręcie pęka i wypuszcza całą zawartość (port z VOREStation code/modules/events/canister_leak.dm)
// As in VORE: up to 10 tries to pick an intact canister on the ship holding at least one standard tile of gas, then it
// breaks like a destroyed canister. VORE checks that the area is empty only at mundane severity; we have no severities,
// so an empty area is always preferred and an occupied one is taken only if no other canister qualifies. VORE says
// nothing; atmospheric sensors here announce the area, so engineering knows where to go.

/datum/round_event_control/aquila_hex_canister_leak
	name = "Pęknięty kanister"
	typepath = /datum/round_event/aquila_hex_canister_leak
	weight = 10
	min_players = 2
	max_occurrences = 2
	earliest_start = 15 MINUTES

/datum/round_event/aquila_hex_canister_leak
	fakeable = FALSE
	startWhen = 1
	announceWhen = 3
	/// Area of the broken canister, for the announcement
	var/area/leak_area
	/// Name of the broken canister
	var/canister_name

/datum/round_event/aquila_hex_canister_leak/start()
	var/list/empty_area_canisters = list()
	var/list/other_canisters = list()
	for(var/obj/machinery/portable_atmospherics/canister/canister in GLOB.machines)
		if(!can_break(canister))
			continue
		if(aquila_hex_area_occupied(get_area(canister)))
			other_canisters += canister
		else
			empty_area_canisters += canister
	var/obj/machinery/portable_atmospherics/canister/target = length(empty_area_canisters) ? pick(empty_area_canisters) : (length(other_canisters) ? pick(other_canisters) : null)
	if(!target)
		log_game("Canister Leak: no full canister on the ship, cancelling the event.")
		return kill()
	break_canister(target)

/// An intact canister on the ship with at least one standard tile of gas
/datum/round_event/aquila_hex_canister_leak/proc/can_break(obj/machinery/portable_atmospherics/canister/canister)
	if(QDELETED(canister) || !isturf(canister.loc) || !is_station_level(canister.z) || (canister.machine_stat & BROKEN))
		return FALSE
	return canister.air_contents?.total_moles() >= MOLES_CELLSTANDARD

/// Breaks the canister like a destroyed one: all the gas goes out on its turf
/datum/round_event/aquila_hex_canister_leak/proc/break_canister(obj/machinery/portable_atmospherics/canister/canister)
	leak_area = get_area(canister)
	canister_name = canister.name
	log_game("Canister Leak: [canister] at [AREACOORD(canister)] broke.")
	canister.visible_message("<span class='danger'>Zawór [canister] pęka z hukiem i gaz z sykiem ucieka na zewnątrz!</span>")
	canister.canister_break()

/datum/round_event/aquila_hex_canister_leak/announce(fake)
	if(!leak_area)
		return
	priority_announce("Czujniki atmosferyczne wykryły rozszczelnienie kanistra ([canister_name]) w obszarze [leak_area.name]. Prosimy omijać to miejsce do czasu przewietrzenia.", "Monitoring atmosfery")
