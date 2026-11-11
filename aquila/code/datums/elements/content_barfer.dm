// AQUILA: port of tgstation code/datums/elements/content_barfer.dm (tg 926bf40c5a). Only on death: we send no
// COMSIG_LIVING_ON_WABBAJACKED or COMSIG_MOB_CHANGED_TYPE and have no TRAIT_NOT_BARFABLE.
/**
 * Content Barfer; which expels the contents of a mob when it dies
 */
/datum/element/content_barfer

/datum/element/content_barfer/Attach(datum/target)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(barf_contents))

/datum/element/content_barfer/Detach(datum/target)
	UnregisterSignal(target, COMSIG_LIVING_DEATH)
	return ..()

/datum/element/content_barfer/proc/barf_contents(mob/living/target)
	SIGNAL_HANDLER
	for(var/atom/movable/barfed_out as anything in target)
		barfed_out.forceMove(target.loc)
		if(prob(90))
			step(barfed_out, pick(GLOB.alldirs))
