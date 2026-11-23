// AQUILA: port of tgstation code/datums/components/healing_touch.dm (tg 926bf40c5a), smallest version the lightgeist needs.
// Changes against tg:
// - no do_after interaction keys here: the component remembers who is busy healing (`busy_healers`);
// - biotypes are a list here (our mob_biotypes are lists); the bodytype goes to heal_overall_damage() as required_status;
// - Polish balloon alerts; %SOURCE% and %TARGET% are replaced in the action texts as in tg.
#define MEND_REPLACE_KEY_SOURCE "%SOURCE%"
#define MEND_REPLACE_KEY_TARGET "%TARGET%"

/**
 * # Healing Touch component
 *
 * A mob with this component will be able to heal certain targets by attacking them.
 * This intercepts the attack and starts a do_after if the target is in its allowed type list.
 */
/datum/component/healing_touch
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// How much brute damage to heal
	var/heal_brute
	/// How much burn damage to heal
	var/heal_burn
	/// How much toxin damage to heal
	var/heal_tox
	/// How much oxygen damage to heal
	var/heal_oxy
	/// How much stamina damage to heal
	var/heal_stamina
	/// Any extra conditions which need to be true to permit healing. Returning TRUE permits the healing, FALSE or null cancels it.
	var/datum/callback/extra_checks
	/// Time it takes to perform the healing action
	var/heal_time
	/// Typecache of mobs we can heal
	var/list/valid_targets_typecache
	/// Bitfield for biotypes of mobs we can heal (our biotypes are lists, see has_healable_damage())
	var/list/valid_biotypes
	/// Which kinds of carbon limbs can we heal, has no effect on non-carbon mobs. Null if you don't care about prosthetics.
	var/required_bodytype
	/// How targeting yourself works, expects one of HEALING_TOUCH_ANYONE, HEALING_TOUCH_NOT_SELF, or HEALING_TOUCH_SELF_ONLY
	var/self_targeting
	/// Text to print when action starts, replaces %SOURCE% with healer and %TARGET% with healed mob
	var/action_text
	/// Text to print when action completes, replaces %SOURCE% with healer and %TARGET% with healed mob
	var/complete_text
	/// Color for the healing effect
	var/heal_color
	/// Callback to run after healing a mob
	var/datum/callback/after_healed
	/// AQUILA: is the healer in the middle of healing (no do_after interaction keys here)
	var/busy = FALSE

/datum/component/healing_touch/Initialize(
	heal_brute = 20,
	heal_burn = 20,
	heal_tox = 0,
	heal_oxy = 0,
	heal_stamina = 0,
	heal_time = 2 SECONDS,
	datum/callback/extra_checks = null,
	list/valid_targets_typecache = list(),
	list/valid_biotypes = list(MOB_ORGANIC, MOB_MINERAL),
	required_bodytype = BODYTYPE_ORGANIC,
	self_targeting = HEALING_TOUCH_NOT_SELF,
	action_text = "%SOURCE% zaczyna leczyć %TARGET%",
	complete_text = "%SOURCE% kończy leczyć %TARGET%",
	heal_color = "#80F5FF",
	datum/callback/after_healed = null,
)
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.heal_brute = heal_brute
	src.heal_burn = heal_burn
	src.heal_tox = heal_tox
	src.heal_oxy = heal_oxy
	src.heal_stamina = heal_stamina
	src.heal_time = heal_time
	src.extra_checks = extra_checks
	src.valid_targets_typecache = valid_targets_typecache.Copy()
	src.valid_biotypes = valid_biotypes
	src.required_bodytype = required_bodytype
	src.self_targeting = self_targeting
	src.action_text = action_text
	src.complete_text = complete_text
	src.heal_color = heal_color
	src.after_healed = after_healed

	RegisterSignal(parent, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(try_healing)) // Players and the AI (it clicks too)
	RegisterSignal(parent, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(try_healing)) // melee_attack() called directly

/datum/component/healing_touch/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_HOSTILE_PRE_ATTACKINGTARGET))
	return ..()

/datum/component/healing_touch/Destroy(force)
	extra_checks = null
	after_healed = null
	return ..()

/// Validate our target, and interrupt the attack chain to start healing it if it is allowed
/datum/component/healing_touch/proc/try_healing(mob/living/healer, atom/target)
	SIGNAL_HANDLER
	if (!isliving(target))
		return NONE

	if (length(valid_targets_typecache) && !is_type_in_typecache(target, valid_targets_typecache))
		return NONE // Fall back to attacking it

	if (extra_checks && !extra_checks.Invoke(healer, target))
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if (busy)
		healer.balloon_alert(healer, "zajęty!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	switch (self_targeting)
		if (HEALING_TOUCH_NOT_SELF)
			if (target == healer)
				healer.balloon_alert(healer, "nie możesz leczyć siebie!")
				return COMPONENT_CANCEL_ATTACK_CHAIN
		if (HEALING_TOUCH_SELF_ONLY)
			if (target != healer)
				healer.balloon_alert(healer, "możesz leczyć tylko siebie!")
				return COMPONENT_CANCEL_ATTACK_CHAIN

	var/mob/living/living_target = target
	if (living_target.stat == DEAD)
		target.balloon_alert(healer, "nie żyje!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if (living_target.health >= living_target.maxHealth)
		target.balloon_alert(healer, "nie jest ranny!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if (!has_healable_damage(living_target))
		target.balloon_alert(healer, "nie da się tego wyleczyć!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	INVOKE_ASYNC(src, PROC_REF(heal_target), healer, target)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// Returns true if the target has a kind of damage which we can heal
/datum/component/healing_touch/proc/has_healable_damage(mob/living/target)
	if (length(valid_biotypes))
		var/biotype_found = FALSE
		for (var/biotype in valid_biotypes)
			if (biotype in target.mob_biotypes)
				biotype_found = TRUE
				break
		if (!biotype_found)
			return FALSE
	if (target.getStaminaLoss() > 0 && heal_stamina)
		return TRUE
	if (target.getOxyLoss() > 0 && heal_oxy)
		return TRUE
	if (target.getToxLoss() > 0 && heal_tox)
		return TRUE
	if (!iscarbon(target))
		return (target.getBruteLoss() > 0 && heal_brute) || (target.getFireLoss() > 0 && heal_burn)
	var/mob/living/carbon/carbon_target = target
	for (var/obj/item/bodypart/part as anything in carbon_target.bodyparts)
		if (!(part.brute_dam && heal_brute) && !(part.burn_dam && heal_burn))
			continue
		if (!isnull(required_bodytype) && !(part.bodytype & required_bodytype))
			continue
		return TRUE
	return FALSE

/// Perform a do_after and then heal our target
/datum/component/healing_touch/proc/heal_target(mob/living/healer, mob/living/target)
	if (action_text)
		healer.visible_message(span_notice("[format_string(action_text, healer, target)]"))

	if (heal_time)
		busy = TRUE
		var/finished = do_after(healer, heal_time, target = target)
		busy = FALSE
		if (!finished)
			healer.balloon_alert(healer, "przerwano!")
			return

	if (QDELETED(target) || target.stat == DEAD)
		return

	if (complete_text)
		healer.visible_message(span_notice("[format_string(complete_text, healer, target)]"))

	var/health_before = target.health
	target.heal_overall_damage(heal_brute, heal_burn, heal_stamina, required_bodytype, FALSE)
	if (heal_oxy)
		target.adjustOxyLoss(-heal_oxy, updating_health = FALSE)
	if (heal_tox)
		target.adjustToxLoss(-heal_tox, updating_health = FALSE)
	target.updatehealth()
	if (target.health <= health_before)
		return

	new /obj/effect/temp_visual/heal(get_turf(target), heal_color)
	after_healed?.Invoke(target)

/// Reformats the passed string with the replacetext keys
/datum/component/healing_touch/proc/format_string(string, atom/source, atom/target)
	var/final_message = replacetext(string, MEND_REPLACE_KEY_SOURCE, "[source]")
	final_message = replacetext(final_message, MEND_REPLACE_KEY_TARGET, "[target]")
	return final_message

#undef MEND_REPLACE_KEY_SOURCE
#undef MEND_REPLACE_KEY_TARGET
