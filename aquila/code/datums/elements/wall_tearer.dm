// AQUILA: port of tgstation code/datums/elements/wall_tearer.dm (tg 926bf40c5a), smallest version: we have no torn_wall component,
// so one do_after of the whole tear time dismantles the wall (as our old space dragon and the breacher spider did); no do_after
// interaction keys, the element remembers who is busy tearing. Indestructible walls are /turf/closed/indestructible here.
/// Returned if we can rip up this target
#define WALL_TEAR_ALLOWED TRUE
/// Returned if we can't rip up this target
#define WALL_TEAR_INVALID FALSE
/// Returned if we can't rip up the target but still don't want to attack it
#define WALL_TEAR_FAIL_CANCEL_CHAIN -1

/**
 * Allows attached mobs to destroy walls over time, a little less unreasonable than the instant wall deletion of wall_smasher
 */
/datum/element/wall_tearer
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	/// Whether we can break reinforced walls
	var/allow_reinforced
	/// How long it takes for us to destroy a wall completely
	var/tear_time
	/// How much longer it takes to break reinforced walls
	var/reinforced_multiplier
	/// Mobs tearing a wall right now
	var/list/busy_tearers = list()

/datum/element/wall_tearer/Attach(datum/target, allow_reinforced = TRUE, tear_time = 2 SECONDS, reinforced_multiplier = 2)
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE
	src.allow_reinforced = allow_reinforced
	src.tear_time = tear_time
	src.reinforced_multiplier = reinforced_multiplier
	RegisterSignals(target, list(COMSIG_HOSTILE_PRE_ATTACKINGTARGET, COMSIG_LIVING_UNARMED_ATTACK), PROC_REF(on_attacked_wall))

/datum/element/wall_tearer/Detach(datum/source)
	. = ..()
	busy_tearers -= source
	UnregisterSignal(source, list(COMSIG_HOSTILE_PRE_ATTACKINGTARGET, COMSIG_LIVING_UNARMED_ATTACK))

/// Try to tear up a wall
/datum/element/wall_tearer/proc/on_attacked_wall(mob/living/tearer, atom/target)
	SIGNAL_HANDLER
	var/is_valid = validate_target(target, tearer)
	if (is_valid != WALL_TEAR_ALLOWED)
		return is_valid == WALL_TEAR_FAIL_CANCEL_CHAIN ? COMPONENT_CANCEL_ATTACK_CHAIN : NONE
	if (tearer in busy_tearers)
		tearer.balloon_alert(tearer, "zajęty!")
		return COMPONENT_CANCEL_ATTACK_CHAIN
	INVOKE_ASYNC(src, PROC_REF(rip_and_tear), tearer, target)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/element/wall_tearer/proc/rip_and_tear(mob/living/tearer, turf/closed/wall/target)
	var/rip_time = istype(target, /turf/closed/wall/r_wall) ? tear_time * reinforced_multiplier : tear_time
	if (rip_time > 0)
		tearer.visible_message(span_warning("[tearer] zaczyna rozrywać [target]!"))
		playsound(tearer, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)
		busy_tearers |= tearer
		var/finished = do_after(tearer, rip_time, target = target)
		busy_tearers -= tearer
		if (!finished)
			tearer.balloon_alert(tearer, "przerwano!")
			return
	// Might have been replaced, removed, or reinforced during our do_after
	if (QDELETED(tearer) || validate_target(target, tearer) != WALL_TEAR_ALLOWED)
		return
	tearer.do_attack_animation(target)
	playsound(target, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	target.dismantle_wall(TRUE)

/// Check if the target atom is a wall we can actually rip up
/datum/element/wall_tearer/proc/validate_target(atom/target, mob/living/tearer)
	if (!iswallturf(target))
		return WALL_TEAR_INVALID

	if (!allow_reinforced && istype(target, /turf/closed/wall/r_wall))
		target.balloon_alert(tearer, "za mocna!")
		return WALL_TEAR_FAIL_CANCEL_CHAIN
	return WALL_TEAR_ALLOWED

#undef WALL_TEAR_ALLOWED
#undef WALL_TEAR_INVALID
#undef WALL_TEAR_FAIL_CANCEL_CHAIN
