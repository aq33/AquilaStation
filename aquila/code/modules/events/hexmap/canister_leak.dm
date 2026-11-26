// AQUILA - Pęknięty kanister: losowy pełny kanister na okręcie pęka i wypuszcza całą zawartość (port z VOREStation code/modules/events/canister_leak.dm)
// As in VORE: up to 10 tries to pick an intact canister on the ship holding at least one standard tile of gas, then it
// breaks like a destroyed canister. VORE checks that the area is empty only at mundane severity; we have no severities,
// so an empty area is always preferred and an occupied one is taken only if no other canister qualifies and the canister
// holds only harmless gas (nitrogen, oxygen or a mix of both, like air); a dangerous gas only breaks in an empty area. VORE says
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
	var/obj/machinery/portable_atmospherics/canister/target = pick_canister(empty_area_canisters, other_canisters)
	if(!target)
		log_game("Canister Leak: no full canister on the ship, cancelling the event.")
		return kill()
	break_canister(target)

/// A canister from an empty area if there is one; otherwise one with harmless gas from an occupied area, or null
/datum/round_event/aquila_hex_canister_leak/proc/pick_canister(list/empty_area_canisters, list/occupied_area_canisters)
	if(length(empty_area_canisters))
		return pick(empty_area_canisters)
	var/list/harmless = list()
	for(var/obj/machinery/portable_atmospherics/canister/canister as anything in occupied_area_canisters)
		if(holds_harmless_gas(canister))
			harmless += canister
	return length(harmless) ? pick(harmless) : null

/// The canister holds only nitrogen and oxygen (air, N2 or O2)
/datum/round_event/aquila_hex_canister_leak/proc/holds_harmless_gas(obj/machinery/portable_atmospherics/canister/canister)
	var/datum/gas_mixture/air = canister.air_contents
	if(!air)
		return FALSE
	for(var/gas_id in air.get_gases())
		if(gas_id != GAS_N2 && gas_id != GAS_O2 && air.get_moles(gas_id) > 0)
			return FALSE
	return TRUE

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
