/// Just move something around in the simplest way possible (tg, tgstation/tgstation#95857)
/datum/element/moving_randomly
	element_flags = ELEMENT_DETACH

	/// Movables that we are moving around
	var/list/movers = list()

/datum/element/moving_randomly/Attach(datum/target)
	. = ..()

	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE

	movers |= target

/datum/element/moving_randomly/Detach(datum/source, ...)
	movers -= source
	return ..()

/datum/element/moving_randomly/New()
	. = ..()
	START_PROCESSING(SSdcs, src)

/datum/element/moving_randomly/Destroy(force)
	STOP_PROCESSING(SSdcs, src)
	movers = null
	return ..()

/datum/element/moving_randomly/process(delta_time)
	for(var/atom/movable/mover as anything in movers)
		if(QDELETED(mover) || mover.anchored)
			continue
		var/turf/destination = get_step(mover, pick(GLOB.alldirs))
		if(destination)
			mover.Move(destination)
