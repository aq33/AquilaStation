// AQUILA - Błąd sterowników drzwi: śluzy okrętu zamykają się, ryglują i elektryzują na 90 s jak przy blokadzie z modułu SI, potem same puszczają (port z BlueMoon-Station code/modules/events/door_runtime.dm)
// As in BlueMoon, every powered airlock on the ship the AI can control gets hostile_lockdown() (the malf AI lockdown) in a
// spread-out wave and is released after 90 s by a global proc that does not depend on the event's lifetime. Differences,
// so that the lockdown does not kill or open what was shut:
// - airlocks already bolted or welded are left alone, so secure doors stay bolted after the release;
// - airlocks with a living mob in the doorway are skipped (the lockdown closes doors unsafely and would crush them);
// - airlocks in areas with an active fire or atmosphere alarm are skipped, so the crew can still run from a fire or a breach;
// - the release only reopens airlocks that were open before (BlueMoon and the malf module open every door), so external
//   airlocks, which are locked like in the original, are never left open into space;
// - the release turns off only the electrification the lockdown set; no secret "samosbor" mode.

/// How long the airlocks stay locked
#define DOOR_RUNTIME_DURATION (90 SECONDS)

/datum/round_event_control/aquila_hex_door_runtime
	name = "Błąd sterowników drzwi"
	typepath = /datum/round_event/aquila_hex_door_runtime
	weight = 10
	min_players = 10
	max_occurrences = 1
	earliest_start = 20 MINUTES

/datum/round_event/aquila_hex_door_runtime
	startWhen = 1
	announceWhen = 1
	/// Weakref of each locked airlock -> was it open before the lockdown
	var/list/locked_doors

/datum/round_event/aquila_hex_door_runtime/announce(fake)
	if(!fake && !length(locked_doors))
		return
	priority_announce("W systemie sterowania śluzami wykryto złośliwe oprogramowanie. Uruchomiono protokoły izolacji: śluzy są zaryglowane i pod napięciem. Prosimy zachować spokój i nie dotykać klamek.", "Uwaga: luka w sieci okrętu")

/datum/round_event/aquila_hex_door_runtime/start()
	var/list/doors = list()
	for(var/obj/machinery/door/airlock/door as anything in GLOB.airlocks)
		if(can_lock(door))
			doors += door
	if(!length(doors))
		log_game("Door Runtime: no airlock to lock, cancelling the event.")
		return kill()
	locked_doors = list()
	aquila_hex_door_runtime_lock(doors, locked_doors)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(aquila_hex_door_runtime_release), locked_doors, TRUE), DOOR_RUNTIME_DURATION)
	log_game("Door Runtime locked [length(locked_doors)] airlock(s) for [DisplayTimeText(DOOR_RUNTIME_DURATION)].")

/// A powered ship airlock the AI controls that is not bolted, welded, blocked by a mob or in an alarmed area
/datum/round_event/aquila_hex_door_runtime/proc/can_lock(obj/machinery/door/airlock/door)
	if(!istype(door) || QDELETED(door) || !is_station_level(door.z) || door.machine_stat)
		return FALSE
	if(door.locked || door.welded || door.operating || !door.canAIControl())
		return FALSE
	var/area/door_area = get_area(door)
	if(!door_area || door_area.fire || door_area.atmosalm)
		return FALSE
	return !(locate(/mob/living) in get_turf(door))

/**
 * Locks the airlocks like the malf AI lockdown and fills locked_doors with weakref -> was open before, for
 * aquila_hex_door_runtime_release(). The list is filled at once; closing sleeps, so each door gets its own async call,
 * spread over ticks.
 */
/proc/aquila_hex_door_runtime_lock(list/doors, list/locked_doors)
	set waitfor = FALSE
	var/list/to_lock = list()
	for(var/obj/machinery/door/airlock/door as anything in doors)
		if(QDELETED(door))
			continue
		locked_doors[WEAKREF(door)] = !door.density
		to_lock += door
	for(var/obj/machinery/door/airlock/door as anything in to_lock)
		if(!QDELETED(door))
			INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door, hostile_lockdown))
		CHECK_TICK

/// Unbolts the locked airlocks, turns off their electrification and reopens only those that were open before
/proc/aquila_hex_door_runtime_release(list/locked_doors, announce = FALSE)
	set waitfor = FALSE
	for(var/datum/weakref/door_ref as anything in locked_doors)
		var/obj/machinery/door/airlock/door = door_ref.resolve()
		if(QDELETED(door))
			continue
		door.safe = TRUE
		if(door.secondsElectrified == MACHINE_ELECTRIFIED_PERMANENT)
			door.set_electrified(MACHINE_NOT_ELECTRIFIED)
		door.unbolt()
		if(locked_doors[door_ref] && !door.machine_stat)
			INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door, open))
		CHECK_TICK
	if(announce)
		priority_announce("Automatyczny restart systemu sterowania śluzami zakończony. Życzymy miłego dnia i mniej wirusów.", "Restart sieci okrętu")

#undef DOOR_RUNTIME_DURATION
