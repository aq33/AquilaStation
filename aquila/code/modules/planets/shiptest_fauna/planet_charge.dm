// AQUILA: charge of the planet fauna (wolf lunge, lobstrosity rush). We have no tg /datum/action/cooldown/mob_cooldown/charge
// (and no move manager), so this is a small version of tg's basic_charge: a short telegraph (the mob shakes), then a dash
// along the line to the target tile and a couple of tiles past it, one step per tick on a timer (the AI must not sleep in
// Activate()). The first living thing in the way is knocked down and hit by hit_target(); a wall or any other obstacle
// stops the dash, as tg's charge does. Like Shiptest's wolf, a mob that dashes into a wall is dazed for a moment.

/datum/action/cooldown/mob_cooldown/planet_charge
	name = "Szarża"
	desc = "Rzuca się na cel i przewraca go."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	cooldown_time = 8 SECONDS
	melee_cooldown_time = 0
	shared_cooldown = NONE
	/// How long the mob winds up before dashing
	var/charge_delay = 0.6 SECONDS
	/// How many tiles past the target tile the dash goes on
	var/charge_past = 2
	/// Maximum length of the dash
	var/charge_distance = 8
	/// How long a hit target stays knocked down
	var/knockdown_duration = 1.5 SECONDS
	/// How long the charger is dazed after dashing into a wall (0 = not at all)
	var/wall_stun_duration = 1 SECONDS
	/// Tile the dash aims at and the direction it keeps past it
	var/turf/charge_target
	var/charge_dir
	/// Steps left
	var/steps_left = 0
	/// Timer of the wind-up, then of the dash steps
	var/charge_timer
	/// Is the mob winding up or dashing
	var/charging = FALSE

/datum/action/cooldown/mob_cooldown/planet_charge/Destroy()
	stop_charge()
	return ..()

/datum/action/cooldown/mob_cooldown/planet_charge/Remove(mob/removed_from)
	stop_charge()
	return ..()

/datum/action/cooldown/mob_cooldown/planet_charge/Activate(atom/target)
	if(charging || !isliving(owner))
		return FALSE
	var/turf/target_turf = get_turf(target)
	var/turf/owner_turf = get_turf(owner)
	if(!target_turf || !owner_turf || target_turf == owner_turf)
		return FALSE
	charging = TRUE
	charge_dir = get_dir(owner_turf, target_turf)
	charge_target = get_ranged_target_turf(target_turf, charge_dir, charge_past)
	steps_left = min(charge_distance, get_dist(owner_turf, charge_target))
	owner.face_atom(target_turf)
	owner.Shake(1, 0, charge_delay)
	charge_timer = addtimer(CALLBACK(src, PROC_REF(start_dash)), charge_delay, TIMER_STOPPABLE)
	StartCooldown()
	return TRUE

/// Wind-up over: dash a tile per tick
/datum/action/cooldown/mob_cooldown/planet_charge/proc/start_dash()
	charge_timer = null
	if(!can_charge())
		stop_charge()
		return
	charge_timer = addtimer(CALLBACK(src, PROC_REF(dash_step)), 1, TIMER_LOOP | TIMER_STOPPABLE)
	dash_step()

/datum/action/cooldown/mob_cooldown/planet_charge/proc/can_charge()
	var/mob/living/living_owner = owner
	return istype(living_owner) && !QDELETED(living_owner) && living_owner.stat == CONSCIOUS && isturf(living_owner.loc) && !HAS_TRAIT(living_owner, TRAIT_IMMOBILIZED)

/// One tile of the dash
/datum/action/cooldown/mob_cooldown/planet_charge/proc/dash_step()
	if(!charging)
		return
	if(steps_left <= 0 || !can_charge())
		stop_charge()
		return
	steps_left--
	var/turf/owner_turf = get_turf(owner)
	var/step_dir = (owner_turf == charge_target || !charge_target) ? charge_dir : get_dir(owner_turf, charge_target)
	var/turf/next_turf = get_step(owner_turf, step_dir)
	if(!next_turf)
		stop_charge()
		return
	for(var/mob/living/victim in next_turf)
		if(victim == owner || !victim.density)
			continue
		hit_target(victim)
		stop_charge()
		return
	if(!owner.Move(next_turf, step_dir))
		hit_obstacle(next_turf)
		stop_charge()

/// Dashed into a living thing
/datum/action/cooldown/mob_cooldown/planet_charge/proc/hit_target(mob/living/victim)
	var/mob/living/living_owner = owner
	living_owner.visible_message(span_danger("[living_owner] rzuca się na [victim]!"), span_danger("Rzucasz się na [victim]!"))
	playsound(get_turf(victim), 'sound/effects/meteorimpact.ogg', 60, TRUE)
	victim.Knockdown(knockdown_duration)
	if(isbasicmob(living_owner))
		var/mob/living/basic/basic_owner = living_owner
		basic_owner.melee_attack(victim, ignore_cooldown = TRUE)

/// Dashed into a wall or something heavy
/datum/action/cooldown/mob_cooldown/planet_charge/proc/hit_obstacle(turf/obstacle_turf)
	if(!wall_stun_duration || !(isclosedturf(obstacle_turf) || obstacle_turf.density))
		return
	var/mob/living/living_owner = owner
	living_owner.visible_message(span_danger("[living_owner] wbiega z impetem w [obstacle_turf]!"))
	playsound(obstacle_turf, 'sound/effects/meteorimpact.ogg', 60, TRUE)
	living_owner.Stun(wall_stun_duration)

/datum/action/cooldown/mob_cooldown/planet_charge/proc/stop_charge()
	if(charge_timer)
		deltimer(charge_timer)
		charge_timer = null
	charging = FALSE
	charge_target = null
	steps_left = 0

/// Charge when the target is 3-8 tiles away, otherwise bite
/datum/ai_planning_subtree/targeted_mob_ability/planet_charge
	/// Closest and furthest distance we charge from
	var/min_range = 3
	var/max_range = 8

/datum/ai_planning_subtree/targeted_mob_ability/planet_charge/additional_ability_checks(datum/ai_controller/controller, datum/action/cooldown/using_action)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target) || !isturf(target.loc))
		return FALSE
	var/distance = get_dist(controller.pawn, target)
	return distance >= min_range && distance <= max_range && can_see(controller.pawn, target, max_range)
