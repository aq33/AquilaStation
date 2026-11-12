// AQUILA: port of tgstation code/datums/elements/content_barfer.dm (tg 926bf40c5a) for the legion, the geese and the space
// dragon. We have no wabbajack/shapeshift/change type signals, so it barfs on death only; the space dragon drops its
// meals in wabbajack_act() itself.
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
		// AQUILA: the mob's own HUD and ability objects are not "contents" (screen objects, actions live elsewhere)
		if(!ismob(barfed_out) && !isobj(barfed_out))
			continue
		if(isitem(barfed_out))
			var/obj/item/barfed_item = barfed_out
			if(barfed_item.item_flags & ABSTRACT)
				continue
		barfed_out.forceMove(target.drop_location())
		if(prob(90))
			step(barfed_out, pick(GLOB.alldirs))
