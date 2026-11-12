// AQUILA: port of tgstation/tgstation code/datums/elements/mob_grabber.dm (tg 926bf40c5a)
// Our COMSIG_HOSTILE_PRE_ATTACKINGTARGET carries only the target (tg also passes the proximity and modifiers),
// so the AI attack path checks adjacency itself.
/// Grab onto mobs we attack
/datum/element/mob_grabber
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	/// What state must the mob be in to be grabbed?
	var/minimum_stat
	/// If someone else is already grabbing this, will we take it?
	var/steal_from_others

/datum/element/mob_grabber/Attach(datum/target, minimum_stat = SOFT_CRIT, steal_from_others = TRUE)
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE
	src.minimum_stat = minimum_stat
	src.steal_from_others = steal_from_others
	RegisterSignal(target, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(grab_mob))
	RegisterSignal(target, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(grab_mob_ai))

/datum/element/mob_grabber/Detach(datum/source)
	UnregisterSignal(source, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_HOSTILE_PRE_ATTACKINGTARGET))
	. = ..()

/// The AI attack path (melee_attack() of a basic mob)
/datum/element/mob_grabber/proc/grab_mob_ai(mob/living/source, mob/living/target)
	SIGNAL_HANDLER
	return grab_mob(source, target, source.Adjacent(target))

/// Try and grab something we attacked
/datum/element/mob_grabber/proc/grab_mob(mob/living/source, mob/living/target, proximity, modifiers)
	SIGNAL_HANDLER
	if (!isliving(target) || !proximity || target.stat < minimum_stat)
		return NONE
	var/atom/currently_pulled = target.pulledby
	if (!isnull(currently_pulled) && (!steal_from_others || currently_pulled == source))
		return NONE
	INVOKE_ASYNC(target, TYPE_PROC_REF(/mob/living, grabbedby), source)
	return COMPONENT_CANCEL_ATTACK_CHAIN
