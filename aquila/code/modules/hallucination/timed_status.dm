// AQUILA - czasowe efekty statusu z BeeStation (code/modules/mob/living/status_procs.dm), przerobione na nasz system,
// w którym duration efektu to chwila końca (world.time), a nie pozostały czas. Używa ich halucynacja jako efekt statusu.

/**
 * Adjusts a timed status effect on the mob,taking into account any existing timed status effects.
 * This can be any status effect that takes into account "duration" with their initialize arguments.
 *
 * Positive durations will add deciseconds to the duration of existing status effects
 * or apply a new status effect of that duration to the mob.
 *
 * Negative durations will remove deciseconds from the duration of an existing version of the status effect,
 * removing the status effect entirely if the duration becomes less than zero.
 *
 * duration - the duration, in deciseconds, to add or remove from the effect
 * effect - the type of status effect being adjusted on the mob
 * max_duration - optional - if set, positive durations will only be added UP TO the passed max duration
 */
/mob/living/proc/adjust_timed_status_effect(duration, effect, max_duration)
	if(!isnum(duration))
		CRASH("adjust_timed_status_effect: called with an invalid duration. (Got: [duration])")
	if(!ispath(effect, /datum/status_effect))
		CRASH("adjust_timed_status_effect: called with an invalid effect type. (Got: [effect])")

	if(isnum(max_duration))
		if(max_duration <= 0)
			CRASH("adjust_timed_status_effect: Called with an invalid max_duration. (Got: [max_duration])")
		if(duration >= max_duration)
			duration = max_duration

	var/datum/status_effect/existing = has_status_effect(effect)
	if(existing)
		if(existing.duration == -1)
			return
		var/remaining = existing.duration - world.time
		if(isnum(max_duration) && duration > 0)
			if(remaining >= max_duration)
				return
			existing.duration += min(max_duration - remaining, duration)
		else
			existing.duration += duration

		if(existing.duration <= world.time)
			qdel(existing)

	else if(duration > 0)
		apply_status_effect(effect, duration)

/**
 * Sets a timed status effect of some kind on a mob to a specific value.
 * If only_if_higher is TRUE, it will only set the value up to the passed duration,
 * so any pre-existing status effects of the same type won't be reduced down
 */
/mob/living/proc/set_timed_status_effect(duration, effect, only_if_higher = FALSE)
	if(!isnum(duration))
		CRASH("set_timed_status_effect: called with an invalid duration. (Got: [duration])")
	if(!ispath(effect, /datum/status_effect))
		CRASH("set_timed_status_effect: called with an invalid effect type. (Got: [effect])")

	var/datum/status_effect/existing = has_status_effect(effect)
	if(existing)
		if(duration <= 0)
			qdel(existing)
			return
		if(existing.duration == -1)
			return
		if(only_if_higher && existing.duration - world.time >= duration)
			return
		existing.duration = world.time + duration

	else if(duration > 0)
		apply_status_effect(effect, duration)

/// Deciseconds left of the passed status effect on this mob, 0 if none, INFINITY for permanent ones
/mob/living/proc/get_timed_status_effect_duration(effect)
	if(!ispath(effect, /datum/status_effect))
		CRASH("get_timed_status_effect_duration: called with an invalid effect type. (Got: [effect])")
	var/datum/status_effect/existing = has_status_effect(effect)
	if(!existing)
		return 0
	if(existing.duration == -1)
		return INFINITY
	return max(existing.duration - world.time, 0)

// Halucynacje (w Bee makra, u nas procedury, bo core woła je przed dołączeniem aquila/)

/mob/living/proc/adjust_hallucinations(duration)
	adjust_timed_status_effect(duration, /datum/status_effect/hallucination)

/mob/living/proc/adjust_hallucinations_up_to(duration, up_to)
	adjust_timed_status_effect(duration, /datum/status_effect/hallucination, up_to)

/mob/living/proc/set_hallucinations(duration)
	set_timed_status_effect(duration, /datum/status_effect/hallucination)

/mob/living/proc/set_hallucinations_if_lower(duration)
	set_timed_status_effect(duration, /datum/status_effect/hallucination, TRUE)

/// Ile sekund halucynacji zostało (zamiast dawnej zmiennej hallucination)
/mob/living/proc/get_hallucination_duration()
	return get_timed_status_effect_duration(/datum/status_effect/hallucination)
