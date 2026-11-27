// AQUILA - Błąd sterowników drzwi: śluzy okrętu zamykają się i ryglują na 90 s, potem same puszczają (port z BlueMoon-Station code/modules/events/door_runtime.dm)
// As in BlueMoon, every powered airlock on the ship the AI can control is shut and bolted in a spread-out wave and released
// after 90 s by a datum that does not depend on the event's lifetime. Differences, so that the lockdown does not kill
// anyone or open what was shut:
// - no electrification and no hostile_lockdown() (BlueMoon and the malf module shock the doors, and a shock from the NSV
//   grid can kill on the first touch); airlocks close safely (safe stays TRUE, nobody is crushed) and are bolted only if
//   they really closed;
// - airlocks already bolted or welded are left alone, so secure doors stay bolted after the release;
// - airlocks with a living mob in the doorway are skipped, checked again right before each door closes;
// - airlocks in areas with an active fire or atmosphere alarm are skipped, so the crew can still run from a fire or a breach;
// - the release unbolts only the airlocks the lockdown bolted and nobody re-bolted since (bolts set by security or the AI
//   in the meantime stay), and reopens only those that were open before, so external airlocks, which are locked like in
//   the original, are never left open into space; no secret "samosbor" mode.

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
	/// The lockdown started by this event, released by its own timer
	var/datum/aquila_door_lockdown/lockdown

/datum/round_event/aquila_hex_door_runtime/announce(fake)
	if(!fake && !lockdown)
		return
	priority_announce("W systemie sterowania śluzami wykryto złośliwe oprogramowanie. Uruchomiono protokoły izolacji: śluzy zostały zamknięte i zaryglowane do czasu restartu systemu. Prosimy zachować spokój.", "Uwaga: luka w sieci okrętu")

/datum/round_event/aquila_hex_door_runtime/start()
	var/list/doors = list()
	for(var/obj/machinery/door/airlock/door as anything in GLOB.airlocks)
		if(can_lock(door))
			doors += door
	if(!length(doors))
		log_game("Door Runtime: no airlock to lock, cancelling the event.")
		return kill()
	lockdown = new
	lockdown.lock_all(doors)
	addtimer(CALLBACK(lockdown, TYPE_PROC_REF(/datum/aquila_door_lockdown, release), TRUE), DOOR_RUNTIME_DURATION)
	log_game("Door Runtime is locking [length(doors)] airlock(s) for [DisplayTimeText(DOOR_RUNTIME_DURATION)].")

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

/// The airlocks bolted by one door runtime lockdown, with whether each was open before
/datum/aquila_door_lockdown
	/// Airlock bolted by the lockdown -> was it open before
	var/list/bolted_doors = list()

/datum/aquila_door_lockdown/Destroy()
	for(var/obj/machinery/door/airlock/door as anything in bolted_doors.Copy())
		forget(door)
	return ..()

/// Locks the airlocks one by one, spread over ticks; closing sleeps, so each door gets its own async call
/datum/aquila_door_lockdown/proc/lock_all(list/doors)
	set waitfor = FALSE
	for(var/obj/machinery/door/airlock/door as anything in doors)
		if(QDELING(src))
			return
		if(!QDELETED(door))
			INVOKE_ASYNC(src, PROC_REF(lock_door), door)
		CHECK_TICK

/// Closes the airlock safely if nothing is in the doorway and bolts it if it closed. Sleeps while the door closes
/datum/aquila_door_lockdown/proc/lock_door(obj/machinery/door/airlock/door)
	if(!can_close(door))
		return FALSE
	var/was_open = !door.density
	if(was_open)
		door.close()
	if(QDELING(src) || !can_close(door) || !door.density)
		return FALSE
	return bolt_door(door, was_open)

/// Nothing stops the lockdown from closing the airlock: it is not moving, bolted or welded and no mob is in the doorway
/datum/aquila_door_lockdown/proc/can_close(obj/machinery/door/airlock/door)
	if(QDELETED(door) || door.operating || door.locked || door.welded || door.machine_stat)
		return FALSE
	return !(locate(/mob/living) in get_turf(door))

/// Bolts a closed airlock and remembers it; any later bolt change by someone else makes the lockdown forget it
/datum/aquila_door_lockdown/proc/bolt_door(obj/machinery/door/airlock/door, was_open)
	door.bolt()
	if(!door.locked)
		return FALSE
	bolted_doors[door] = was_open
	RegisterSignal(door, COMSIG_AIRLOCK_SET_BOLT, PROC_REF(on_bolt_changed))
	RegisterSignal(door, COMSIG_PARENT_QDELETING, PROC_REF(on_door_deleted))
	return TRUE

/// Stops tracking the airlock
/datum/aquila_door_lockdown/proc/forget(obj/machinery/door/airlock/door)
	UnregisterSignal(door, list(COMSIG_AIRLOCK_SET_BOLT, COMSIG_PARENT_QDELETING))
	bolted_doors -= door

/datum/aquila_door_lockdown/proc/on_bolt_changed(obj/machinery/door/airlock/source, should_bolt)
	SIGNAL_HANDLER
	forget(source)

/datum/aquila_door_lockdown/proc/on_door_deleted(obj/machinery/door/airlock/source)
	SIGNAL_HANDLER
	forget(source)

/// Releases every airlock the lockdown still holds, spread over ticks, then deletes itself
/datum/aquila_door_lockdown/proc/release(announce = FALSE)
	set waitfor = FALSE
	for(var/obj/machinery/door/airlock/door as anything in bolted_doors.Copy())
		release_door(door)
		CHECK_TICK
	if(announce)
		priority_announce("Automatyczny restart systemu sterowania śluzami zakończony. Życzymy miłego dnia i mniej wirusów.", "Restart sieci okrętu")
	qdel(src)

/// Unbolts the airlock if the lockdown still holds it and reopens it if it was open before
/datum/aquila_door_lockdown/proc/release_door(obj/machinery/door/airlock/door)
	if(!(door in bolted_doors))
		return
	var/was_open = bolted_doors[door]
	forget(door)
	if(QDELETED(door) || !door.locked)
		return
	door.unbolt()
	if(was_open && !door.locked && !door.machine_stat)
		INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door, open))

#undef DOOR_RUNTIME_DURATION
