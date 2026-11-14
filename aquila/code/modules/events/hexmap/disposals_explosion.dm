// AQUILA - Osłabiona rura zsypowa syczy, a po kilku minutach pęka i rozrzuca śmieci (port z Baystation12 code/modules/events/disposals_explosion.dm)
// Like Bay: a pipe segment in a non-maintenance ship area is weakened, hisses as a clue and bursts at the end of the event
// unless it was replaced (cut out with a welder) in the meantime. Bay pipes have 10 health and can be repaired; ours have
// 200 integrity and no repair, so the pipe drops to 20-35% integrity and bursts if it is still at most half way repaired.

/datum/round_event_control/aquila_hex_disposals_explosion
	name = "Wybuch w zsypie"
	typepath = /datum/round_event/aquila_hex_disposals_explosion
	weight = 10
	min_players = 2
	max_occurrences = 2
	earliest_start = 15 MINUTES

/datum/round_event/aquila_hex_disposals_explosion
	fakeable = FALSE
	startWhen = 0
	announceWhen = 20
	endWhen = 150 // 5 minutes, should be plenty of time to find it
	/// The pipe segment that bursts
	var/obj/structure/disposalpipe/segment/bursting_pipe


/// Random disposal pipe segment in a ship area that is not maintenance
/datum/round_event/aquila_hex_disposals_explosion/proc/find_pipe()
	var/list/possible_areas = list()
	for(var/area/A as anything in GLOB.sortedAreas)
		if(!(A.type in GLOB.the_station_areas) || istype(A, /area/maintenance))
			continue
		possible_areas += A
	while(length(possible_areas))
		var/area/candidate = pick_n_take(possible_areas)
		var/list/pipes = list()
		for(var/obj/structure/disposalpipe/segment/pipe in candidate)
			pipes += pipe
		if(length(pipes))
			return pick(pipes)

/// Marks the pipe to burst and damages it
/datum/round_event/aquila_hex_disposals_explosion/proc/weaken_pipe(obj/structure/disposalpipe/segment/pipe)
	bursting_pipe = pipe
	RegisterSignal(pipe, COMSIG_PARENT_QDELETING, PROC_REF(pipe_destroyed))
	pipe.obj_integrity = round(pipe.max_integrity * rand(20, 35) / 100)

/// Is the pipe still weak enough to burst
/datum/round_event/aquila_hex_disposals_explosion/proc/pipe_weakened()
	return !QDELETED(bursting_pipe) && bursting_pipe.obj_integrity <= bursting_pipe.max_integrity * 0.5

/// The pipe was replaced or destroyed before it could burst
/datum/round_event/aquila_hex_disposals_explosion/proc/pipe_destroyed(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(bursting_pipe, COMSIG_PARENT_QDELETING)
	bursting_pipe = null
	kill()

/datum/round_event/aquila_hex_disposals_explosion/announce(fake)
	if(!bursting_pipe)
		return
	priority_announce("Odczyty ciśnienia wskazują na grożący wybuch w systemie zsypów w obszarze [get_area_name(bursting_pipe, TRUE)]. Odcinki rur mogą być uszkodzone.", "Monitoring atmosfery")

/datum/round_event/aquila_hex_disposals_explosion/start()
	var/obj/structure/disposalpipe/segment/pipe = find_pipe()
	if(!pipe)
		log_game("Disposals Explosion: no disposal pipe in a non-maintenance ship area, cancelling the event.")
		return kill()
	weaken_pipe(pipe)

/datum/round_event/aquila_hex_disposals_explosion/tick()
	if(!bursting_pipe)
		kill()
		return
	// Some noise as a clue
	if(prob(40) && pipe_weakened())
		playsound(bursting_pipe, 'sound/machines/hiss.ogg', 40, FALSE)

/datum/round_event/aquila_hex_disposals_explosion/end()
	if(!bursting_pipe)
		return
	UnregisterSignal(bursting_pipe, COMSIG_PARENT_QDELETING)
	if(pipe_weakened())
		burst_pipe()
	bursting_pipe = null

/// Bursts the pipe, spewing trash all over
/datum/round_event/aquila_hex_disposals_explosion/proc/burst_pipe()
	var/static/list/trash_types = list(
		/obj/item/trash/chips,
		/obj/item/trash/candy,
		/obj/item/trash/cheesie,
		/obj/item/trash/popcorn,
		/obj/item/trash/raisins,
		/obj/item/trash/sosjerky,
		/obj/item/trash/syndi_cakes,
		/obj/item/trash/waffles,
		/obj/item/trash/semki,
		/obj/item/trash/pistachios,
		/obj/item/trash/energybar,
		/obj/item/trash/boritos,
		/obj/item/trash/can,
		/obj/item/trash/tray,
	)
	var/obj/structure/disposalpipe/segment/pipe = bursting_pipe
	var/obj/structure/disposalholder/trash_holder = new(pipe)
	trash_holder.gas = new /datum/gas_mixture()
	for(var/i in 1 to rand(5, 8))
		var/trash_type = pick(trash_types)
		new trash_type(trash_holder)
	var/turf/T = get_turf(pipe)
	log_game("Disposals Explosion: a disposal pipe burst at [AREACOORD(T)].")
	playsound(T, "explosion", 40, FALSE)
	// Breaking the pipe leaves broken pipe pieces, and its Destroy() expels the holder: the tile pops off and the trash flies
	pipe.deconstruct(FALSE)
