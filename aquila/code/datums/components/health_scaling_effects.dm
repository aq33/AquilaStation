// AQUILA: port of tgstation code/datums/components/health_scaling_effects.dm (tg 926bf40c5a). Our mobs have one melee_damage
// value instead of tg's lower/upper bounds, so the two attack modifiers are averaged into it; the speed change goes through our
// ID-based movespeed modifiers.
/// Movespeed modifier ID of the health scaling effects
#define MOVESPEED_ID_HEALTH_SCALING "health_scaling_speed_buff"

/**
 * ### Enrage buffs component
 *
 * Scales some statistics of a living mob (speed or attack power or such) based on how hurt it is.
 */
/datum/component/health_scaling_effects
	/// Health percentage (between 0 and 1) at which you are considered to get the full "max" effect
	var/max_health_threshold
	/// Health percentage (between 0 and 1) at which you are considered to get the full "min" effect
	var/min_health_threshold
	/// Modification to apply to the lower bound of your attack while your health is at or above the max threshold
	var/max_health_attack_modifier_lower
	/// Modification to apply to the lower bound of your attack while your health is at or above the min threshold
	var/min_health_attack_modifier_lower
	/// Modification to apply to the upper bound of your attack while your health is at or above the max threshold
	var/max_health_attack_modifier_upper
	/// Modification to apply to the upper bound of your attack while your health is at or above the min threshold
	var/min_health_attack_modifier_upper
	/// Modification to movement speed to apply while your health is at or above the max threshold
	var/max_health_slowdown
	/// Modification to movement speed to apply while your health is at or above the min threshold
	var/min_health_slowdown
	/// A callback which is sent the mob's current ratio between the max and min values, for updating mob-specific effects
	var/datum/callback/additional_status_callback
	/// AQUILA: the melee damage modifier applied right now; melee_damage changes by the difference, so changes made by
	/// others (a fugu gland doubling the damage) stay
	var/applied_melee_modifier = 0

/datum/component/health_scaling_effects/Initialize(
	max_health_threshold = 1,
	min_health_threshold = 0.25,
	max_health_attack_modifier_lower = 0,
	min_health_attack_modifier_lower = 0,
	max_health_attack_modifier_upper = 0,
	min_health_attack_modifier_upper = 0,
	max_health_slowdown = 0,
	min_health_slowdown = 0,
	additional_status_callback = null,
)
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.max_health_threshold = max_health_threshold
	src.min_health_threshold = min_health_threshold
	src.max_health_attack_modifier_lower = max_health_attack_modifier_lower
	src.min_health_attack_modifier_lower = min_health_attack_modifier_lower
	src.max_health_attack_modifier_upper = max_health_attack_modifier_upper
	src.min_health_attack_modifier_upper = min_health_attack_modifier_upper
	src.max_health_slowdown = max_health_slowdown
	src.min_health_slowdown = min_health_slowdown
	src.additional_status_callback = additional_status_callback

	RegisterSignal(parent, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(on_health_changed))

/datum/component/health_scaling_effects/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_LIVING_HEALTH_UPDATE)
	return ..()

/datum/component/health_scaling_effects/Destroy(force)
	additional_status_callback = null
	return ..()

/// Called when mob health changes, recalculates the ratio between maximum and minimum
/datum/component/health_scaling_effects/proc/on_health_changed(mob/living/source)
	SIGNAL_HANDLER
	if (source.maxHealth <= 0 || max_health_threshold == min_health_threshold)
		return
	var/current_health_percentage = source.health / source.maxHealth
	// tg: INVERSE_LERP(min_health_threshold, max_health_threshold, current_health_percentage)
	var/max_min_ratio = clamp((current_health_percentage - min_health_threshold) / (max_health_threshold - min_health_threshold), 0, 1)

	INVOKE_ASYNC(src, PROC_REF(update_stats), source, max_min_ratio)

/// Update statistics based on provided interpolator between maximum and minimum values
/datum/component/health_scaling_effects/proc/update_stats(mob/living/source, max_min_ratio)
	if (max_health_attack_modifier_lower || min_health_attack_modifier_lower || max_health_attack_modifier_upper || min_health_attack_modifier_upper)
		var/lower_modifier = min_health_attack_modifier_lower + (max_health_attack_modifier_lower - min_health_attack_modifier_lower) * max_min_ratio
		var/upper_modifier = min_health_attack_modifier_upper + (max_health_attack_modifier_upper - min_health_attack_modifier_upper) * max_min_ratio
		var/new_modifier = round((lower_modifier + upper_modifier) / 2)
		source.melee_damage += new_modifier - applied_melee_modifier
		applied_melee_modifier = new_modifier

	if (max_health_slowdown || min_health_slowdown)
		source.add_movespeed_modifier(MOVESPEED_ID_HEALTH_SCALING, override = TRUE, multiplicative_slowdown = min_health_slowdown + (max_health_slowdown - min_health_slowdown) * max_min_ratio)

	if (additional_status_callback)
		additional_status_callback.Invoke(max_min_ratio)

#undef MOVESPEED_ID_HEALTH_SCALING
