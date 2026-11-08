// AQUILA - efekt statusu halucynacji z BeeStation/BeeStation-Hornet#13095 i poziomy z tgstation/tgstation#89865
// (z poprawką tgstation/tgstation#92668). U nas duration efektu to chwila końca (world.time), stąd seconds_left.

/// Hallucination status effect. How most hallucinations end up happening.
/// Hallucinations are drawn from the global weighted list, random_hallucination_weighted_list
/datum/status_effect/hallucination
	id = "hallucination"
	alert_type = null
	tick_interval = 2 SECONDS
	/// The lower range of when the next hallucination will trigger after one occurs.
	var/lower_tick_interval = 20 SECONDS
	/// The upper range of when the next hallucination will trigger after one occurs.
	var/upper_tick_interval = 80 SECONDS
	/// The maximum hallucination tier that can be picked.
	var/max_hallucination_tier = HALLUCINATION_TIER_COMMON
	/// If TRUE, we only select hallucinations from the hallucination_tier.
	/// If FALSE, it will also include anything below the hallucination_tier.
	var/strict_tier = FALSE
	/// Tier can be variable, based on the duration of the hallucination.
	var/variable_tier = TRUE
	/// The cooldown for when the next hallucination can occur
	COOLDOWN_DECLARE(hallucination_cooldown)

/datum/status_effect/hallucination/on_creation(mob/living/new_owner, new_duration)
	if(isnum(new_duration))
		src.duration = new_duration
	return ..()

// U nas fałszywy szok przy śluzie, fałszywe rany przy oglądaniu siebie i wpis w skanerze robi core
// (hallucinating() w airlock.dm, human_defense.dm, scanners.dm), więc bez sygnałów z Bee.
/datum/status_effect/hallucination/on_apply()
	if(CANNOT_HALLUCINATE(owner))
		return FALSE
	return TRUE

/datum/status_effect/hallucination/tick(seconds_between_ticks)
	if(owner.stat == DEAD)
		return
	if(!COOLDOWN_FINISHED(src, hallucination_cooldown))
		return

	var/lower_cd = lower_tick_interval
	var/upper_cd = upper_tick_interval
	if(variable_tier)
		var/seconds_left = (duration - world.time) / 10
		switch(seconds_left)
			if(0 to 20)
				max_hallucination_tier = HALLUCINATION_TIER_COMMON
				lower_cd *= 1.2
				upper_cd *= 1.2
			if(20 to 60)
				max_hallucination_tier = prob(10) ? HALLUCINATION_TIER_RARE : HALLUCINATION_TIER_UNCOMMON
			if(60 to 120)
				max_hallucination_tier = HALLUCINATION_TIER_RARE
				lower_cd *= 0.75
				upper_cd *= 0.75
			if(120 to INFINITY)
				max_hallucination_tier = HALLUCINATION_TIER_VERYSPECIAL
				lower_cd *= 0.5
				upper_cd *= 0.5

	var/datum/hallucination/picked_hallucination = get_random_hallucination(max_hallucination_tier, strict_tier)
	if(!owner.cause_hallucination(picked_hallucination, "[id] status effect"))
		lower_cd *= 0.25
		upper_cd *= 0.25
	COOLDOWN_START(src, hallucination_cooldown, rand(lower_cd, upper_cd))
