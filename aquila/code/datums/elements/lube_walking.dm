// AQUILA: port of tgstation code/datums/elements/lube_walking.dm (tg 926bf40c5a), smallest version: only the always-on variant
// (the living lube); the resting variant needs a resting signal and snail crawling we do not have.
/**
 * # lube_walking
 *
 * Makes a mob cause a turf to get wet as they walk.
 */
/datum/element/lube_walking
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH
	id_arg_index = 2
	///The wet flags that we make each tile we are affecting slippery with.
	var/wet_flags
	///The minimum amount of time any tile we wet will be wet for.
	var/min_time_wet_for

/datum/element/lube_walking/Attach(atom/movable/target, wet_flags = TURF_WET_LUBE, min_time_wet_for = 2 SECONDS)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	src.wet_flags = wet_flags
	src.min_time_wet_for = min_time_wet_for
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(lubricate))

/datum/element/lube_walking/Detach(atom/movable/target)
	. = ..()
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)

/datum/element/lube_walking/proc/lubricate(atom/movable/snail)
	SIGNAL_HANDLER
	var/turf/open/turf_standing_on = get_turf(snail)
	if(!istype(turf_standing_on))
		return FALSE
	turf_standing_on.MakeSlippery(wet_flags, min_wet_time = min_time_wet_for)
	return TRUE
