// AQUILA: base of tgstation code/datums/actions/mobs/projectileattack.dm (tg 926bf40c5a, lines 1-63). The megafauna patterns
// (rapid fire, spiral, shotgun, colossus and the rest) are not ported: no megafauna is a basic mob here.
// `speed` of our projectiles stays in deciseconds per tile (aquila/code/modules/gunplay/projectile_engine.dm), so
// projectile_speed_multiplier works as tg describes it (2 = twice as slow); tg projectile types ported for an ability
// need their own speed converted to our units.

/datum/action/cooldown/mob_cooldown/projectile_attack
	name = "Atak pociskiem"
	desc = "Wystrzeliwuje pocisk w wybrany cel."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	cooldown_time = 1.5 SECONDS
	/// The type of the projectile to be fired
	var/obj/item/projectile/projectile_type
	/// The sound played when a projectile is fired (played by the attack_sequence() of subtypes, as in tg)
	var/projectile_sound
	/// If the projectile should home in on its target
	var/has_homing = FALSE
	/// The turning speed if there is homing
	var/homing_turn_speed = 30
	/// The variance in the projectiles direction
	var/default_projectile_spread = 0
	/// The multiplier to the projectiles speed (a value of 2 makes it twice as slow, 0.5 makes it twice as fast)
	var/projectile_speed_multiplier = 1
	/// Whether the target can move or not while the attack is occurring
	var/can_move = TRUE

/datum/action/cooldown/mob_cooldown/projectile_attack/Activate(atom/target_atom)
	disable_cooldown_actions()
	RegisterSignal(owner, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_move), override = TRUE)
	attack_sequence(owner, target_atom)
	UnregisterSignal(owner, COMSIG_MOVABLE_PRE_MOVE)
	StartCooldown()
	enable_cooldown_actions()
	return TRUE

/datum/action/cooldown/mob_cooldown/projectile_attack/proc/on_move(atom/source, atom/new_loc)
	SIGNAL_HANDLER
	if(!can_move)
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/// The firing pattern; subtypes may fire more projectiles (do not sleep here when the AI uses the ability, see INVOKE_ASYNC)
/datum/action/cooldown/mob_cooldown/projectile_attack/proc/attack_sequence(mob/living/firer, atom/target)
	shoot_projectile(firer, target, null, firer, rand(-default_projectile_spread, default_projectile_spread), null)

/datum/action/cooldown/mob_cooldown/projectile_attack/proc/shoot_projectile(atom/origin, atom/target, set_angle, mob/firer, projectile_spread, speed_multiplier, override_projectile_type, override_homing)
	var/turf/startloc = get_turf(origin)
	var/turf/endloc = get_turf(target)
	if(!startloc || !endloc)
		return
	var/obj/item/projectile/our_projectile
	if(override_projectile_type)
		our_projectile = new override_projectile_type(startloc)
	else
		our_projectile = new projectile_type(startloc)
	if(!isnum(speed_multiplier))
		speed_multiplier = projectile_speed_multiplier
	our_projectile.speed *= speed_multiplier
	our_projectile.aim_projectile(endloc, startloc, null, projectile_spread)
	our_projectile.firer = firer
	our_projectile.fired_from = origin // AQUILA: like the simple animal Shoot()
	if(target)
		our_projectile.original = target
	if(override_homing == null && has_homing || override_homing)
		our_projectile.homing_turn_speed = homing_turn_speed
		our_projectile.set_homing_target(target)
	if(isnum(set_angle))
		our_projectile.fire(set_angle)
		return our_projectile
	our_projectile.fire()
	return our_projectile
