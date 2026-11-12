// AQUILA: port of tgstation code/datums/components/revenge_ability.dm (tg 926bf40c5a) for the basic mining mobs (goliath,
// watcher). Our relay_attackers sends COMSIG_ATOM_WAS_ATTACKED; the ability is used through InterceptClickOn() like tg.
/**
 * Automatically triggers a linked ability at a target who attacks us.
 * The ability might not necessarily be on our mob.
 * Make sure that /datum/element/relay_attackers is also present or you'll never receive the triggering signal.
 */
/datum/component/revenge_ability
	dupe_mode = COMPONENT_DUPE_ALLOWED
	/// The ability to use when we are attacked
	var/datum/action/cooldown/mob_cooldown/ability
	/// Optional datum for validating targets
	var/datum/targeting_strategy/targeting
	/// Trigger only if target is at least this far away
	var/min_range
	/// Trigger only if target is at least this close
	var/max_range
	/// Target the ability at ourself instead of at the offender
	var/target_self
	/// Should this behavoid continue if our mob is sapient?
	var/activate_with_mind

/datum/component/revenge_ability/Initialize(datum/action/cooldown/mob_cooldown/ability, datum/targeting_strategy/targeting, min_range = 0, max_range = INFINITY, target_self = FALSE, activate_with_mind = FALSE)
	. = ..()
	if (!isliving(parent) || !istype(ability))
		return COMPONENT_INCOMPATIBLE
	src.ability = ability
	src.targeting = targeting
	src.min_range = min_range
	src.max_range = max_range
	src.target_self = target_self
	src.activate_with_mind = activate_with_mind

	RegisterSignal(ability, COMSIG_PARENT_QDELETING, PROC_REF(ability_destroyed))

/datum/component/revenge_ability/RegisterWithParent()
	. = ..()
	parent.AddElement(/datum/element/relay_attackers)
	RegisterSignal(parent, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))

/datum/component/revenge_ability/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_WAS_ATTACKED)
	if (ability)
		UnregisterSignal(ability, COMSIG_PARENT_QDELETING)
	return ..()

/datum/component/revenge_ability/Destroy()
	ability = null
	targeting = null
	return ..()

/// If we were attacked, get revenge
/datum/component/revenge_ability/proc/on_attacked(mob/living/victim, atom/attacker)
	SIGNAL_HANDLER
	if (victim.mind && !activate_with_mind)
		return // This is mostly a component for the use of AI
	if (victim.stat != CONSCIOUS || QDELETED(ability?.owner))
		return
	var/atom/ability_user = ability.owner
	var/distance = get_dist(ability_user, attacker)
	if (distance < min_range || distance > max_range)
		return
	if (targeting && !targeting.can_attack(victim, attacker))
		return
	INVOKE_ASYNC(ability, TYPE_PROC_REF(/datum/action/cooldown/mob_cooldown, InterceptClickOn), ability_user, null, (target_self) ? ability_user : attacker)

/// For whatever reason we lost our linked ability so we can drop this behaviour
/datum/component/revenge_ability/proc/ability_destroyed(datum/source)
	SIGNAL_HANDLER
	qdel(src)
