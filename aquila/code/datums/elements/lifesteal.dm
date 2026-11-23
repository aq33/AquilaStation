// AQUILA: port of tgstation code/datums/elements/lifesteal.dm (tg 926bf40c5a), smallest version for basic mobs: we have no
// on_hit_effect element, so the heal comes after a successful melee attack (COMSIG_HOSTILE_POST_ATTACKINGTARGET). Items do not use it.
/**
 * Heals the mob by a flat amount whenever a successful attack is performed against another living mob.
 */
/datum/element/lifesteal
	element_flags = ELEMENT_DETACH|ELEMENT_BESPOKE
	id_arg_index = 2
	/// heals a constant amount every time a hit occurs
	var/flat_heal
	/// static list shared that tells which order of damage types to prioritize
	var/static/list/damage_heal_order = list(BRUTE, BURN, OXY)

/datum/element/lifesteal/Attach(datum/target, flat_heal = 10)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	src.flat_heal = flat_heal
	RegisterSignal(target, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(do_lifesteal))

/datum/element/lifesteal/Detach(datum/source)
	UnregisterSignal(source, COMSIG_HOSTILE_POST_ATTACKINGTARGET)
	return ..()

/datum/element/lifesteal/proc/do_lifesteal(mob/living/source, atom/target, result)
	SIGNAL_HANDLER
	if(!result || !isliving(target))
		return
	var/mob/living/damaging = target
	if(damaging.stat != DEAD)
		source.heal_ordered_damage(flat_heal, damage_heal_order)
