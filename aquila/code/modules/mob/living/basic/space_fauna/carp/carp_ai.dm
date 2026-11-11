// AQUILA: tg 926bf40c5a carp_ai_actions.dm, carp_ai_rift_actions.dm and carp_ai_migration.dm, with the magicarp spell target
// finders of tg's find_and_set.dm (animatable, nearest_wall, friendly_corpses). No fisherman checks (no fishing here), the global
// is_blocked_turf(), migration points are turfs (tg: weakrefs to turfs). Our animate spell has no blacklist list, so the
// animatable search takes any loose item or unanchored structure.

#define MAGICARP_SPELL_TARGET_SEEK_RANGE 4
/// How close you need to get to the destination in order to consider yourself there
#define CARP_DESTINATION_SEARCH_RANGE 3
/// If there's a portal this close to us we'll enter it just on the basis that the carp who made it probably knew where they were going
#define CARP_PORTAL_SEARCH_RANGE 2

/datum/pet_command/use_ability/magicarp
	pet_ability_key = BB_MAGICARP_SPELL

/datum/ai_planning_subtree/attack_obstacle_in_path/carp
	attack_behaviour = /datum/ai_behavior/attack_obstructions/carp

/datum/ai_behavior/attack_obstructions/carp
	action_cooldown = 1.5 SECONDS

/// As basic attack tree but interrupt if your health gets low or if your spell is off cooldown
/datum/ai_planning_subtree/basic_melee_attack_subtree/magicarp
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/magicarp

/// Interrupt your attack chain if: you have a spell, it's not on cooldown, and it has a target
/datum/ai_behavior/basic_melee_attack/magicarp

/datum/ai_behavior/basic_melee_attack/magicarp/perform(delta_time, datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	var/datum/action/cooldown/using_action = controller.blackboard[BB_MAGICARP_SPELL]
	if(QDELETED(using_action))
		return ..()
	if(!controller.blackboard[BB_MAGICARP_SPELL_SPECIAL_TARGETING] && using_action.IsAvailable())
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	return ..()

/**
 * Find a target for the magicarp's spell
 * This gets weird because different spells want different targeting
 * but I didn't want a new ai controller for every different spell
 */
/datum/ai_planning_subtree/find_nearest_magicarp_spell_target

/datum/ai_planning_subtree/find_nearest_magicarp_spell_target/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/datum/action/cooldown/using_action = controller.blackboard[BB_MAGICARP_SPELL]
	if(!using_action?.IsAvailable())
		return

	var/spell_targeting = controller.blackboard[BB_MAGICARP_SPELL_SPECIAL_TARGETING]
	if(!spell_targeting)
		controller.queue_behavior(/datum/ai_behavior/find_potential_targets/nearest/magicarp, BB_MAGICARP_SPELL_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
		return

	switch(spell_targeting)
		if(MAGICARP_SPELL_CORPSES)
			controller.queue_behavior(/datum/ai_behavior/find_and_set/friendly_corpses, BB_MAGICARP_SPELL_TARGET, null, MAGICARP_SPELL_TARGET_SEEK_RANGE)
			return
		if(MAGICARP_SPELL_OBJECTS)
			controller.queue_behavior(/datum/ai_behavior/find_and_set/animatable, BB_MAGICARP_SPELL_TARGET, null, MAGICARP_SPELL_TARGET_SEEK_RANGE)
			return
		if(MAGICARP_SPELL_WALLS)
			controller.queue_behavior(/datum/ai_behavior/find_and_set/nearest_wall, BB_MAGICARP_SPELL_TARGET, null, MAGICARP_SPELL_TARGET_SEEK_RANGE)
			return

/// This subtype only exists because if you queue multiple of the same action with different arguments it deletes their stored arguments
/datum/ai_behavior/find_potential_targets/nearest/magicarp

/// Then use it on that target
/datum/ai_planning_subtree/targeted_mob_ability/magicarp
	ability_key = BB_MAGICARP_SPELL
	target_key = BB_MAGICARP_SPELL_TARGET
	use_ability_behaviour = /datum/ai_behavior/targeted_mob_ability/and_clear_target

/// Variant of find and set which returns an object which can be animated with a staff of change
/datum/ai_behavior/find_and_set/animatable

/datum/ai_behavior/find_and_set/animatable/search_tactic(datum/ai_controller/controller, locate_path, search_range = SEARCH_TACTIC_DEFAULT_RANGE)
	var/mob/living/living_pawn = controller.pawn
	var/list/nearby_items = list()
	for(var/obj/new_friend in oview(search_range, controller.pawn))
		if(!isitem(new_friend) && !isstructure(new_friend))
			continue
		if(new_friend.anchored)
			continue
		if(living_pawn.see_invisible < new_friend.invisibility)
			continue
		nearby_items += new_friend
	if(length(nearby_items))
		return pick(nearby_items)

/// Variant of find and set which returns the nearest wall which isn't invulnerable
/datum/ai_behavior/find_and_set/nearest_wall

/datum/ai_behavior/find_and_set/nearest_wall/search_tactic(datum/ai_controller/controller, locate_path, search_range = SEARCH_TACTIC_DEFAULT_RANGE)
	var/mob/living/living_pawn = controller.pawn
	var/list/nearby_walls = list()
	for(var/turf/closed/new_wall in oview(search_range, controller.pawn))
		if(isindestructiblewall(new_wall))
			continue
		nearby_walls += new_wall
	if(length(nearby_walls))
		return get_closest_atom(/turf/closed, nearby_walls, living_pawn)

/// Variant of find and set which returns corpses who share your faction
/datum/ai_behavior/find_and_set/friendly_corpses

/datum/ai_behavior/find_and_set/friendly_corpses/search_tactic(datum/ai_controller/controller, locate_path, search_range = SEARCH_TACTIC_DEFAULT_RANGE)
	var/mob/living/living_pawn = controller.pawn
	var/list/nearby_bodies = list()
	for(var/mob/living/dead_pal in oview(search_range, controller.pawn))
		if(!isturf(dead_pal.loc))
			continue
		if(!dead_pal.stat || dead_pal.health > 0)
			continue
		if(living_pawn.see_invisible < dead_pal.invisibility)
			continue
		if(!living_pawn.faction_check_mob(dead_pal))
			continue
		nearby_bodies += dead_pal
	if(length(nearby_bodies))
		return pick(nearby_bodies)

/**
 * # Make carp rift
 * Plan a carp rift action, so basically teleport somewhere if the action is available
 */
/datum/ai_planning_subtree/make_carp_rift
	/// Chiefly describes where we are placing this teleport
	var/datum/ai_behavior/rift_behaviour
	/// If true we finish planning after this
	var/finish_planning = FALSE
	/// Key to read for flee target
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET

/datum/ai_planning_subtree/make_carp_rift/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(!rift_behaviour)
		CRASH("Forgot to specify rift behaviour for [src]")
	if(!controller.blackboard_key_exists(target_key))
		return
	var/datum/action/cooldown/using_action = controller.blackboard[BB_CARP_RIFT]
	if(!using_action?.IsAvailable())
		return
	controller.queue_behavior(rift_behaviour, BB_CARP_RIFT, target_key)
	if(finish_planning)
		return SUBTREE_RETURN_FINISH_PLANNING

/**
 * # Make carp rift (panic)
 * Plan to teleport away from our target so they can't hurt us
 */
/datum/ai_planning_subtree/make_carp_rift/panic_teleport
	rift_behaviour = /datum/ai_behavior/make_carp_rift/away
	finish_planning = TRUE

/datum/ai_planning_subtree/make_carp_rift/panic_teleport/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(controller.blackboard[BB_BASIC_MOB_STOP_FLEEING])
		return
	return ..()

/datum/ai_planning_subtree/make_carp_rift/panic_teleport/flee_key
	target_key = BB_BASIC_MOB_FLEE_TARGET

/**
 * # Make carp rift (aggressive)
 * Plan to teleport towards our target so we can bite them
 */
/datum/ai_planning_subtree/make_carp_rift/aggressive_teleport
	rift_behaviour = /datum/ai_behavior/make_carp_rift/towards/aggressive

/**
 * # Make carp rift
 * Make a carp rift somewhere
 */
/datum/ai_behavior/make_carp_rift

/datum/ai_behavior/make_carp_rift/setup(datum/ai_controller/controller, ability_key, target_key)
	return controller.blackboard[ability_key] && controller.blackboard[target_key]

/datum/ai_behavior/make_carp_rift/perform(delta_time, datum/ai_controller/controller, ability_key, target_key)
	var/datum/action/cooldown/mob_cooldown/lesser_carp_rift/ability = controller.blackboard[ability_key]
	var/atom/target = controller.blackboard[target_key]

	if(!validate_target(controller, target, ability))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/turf/target_destination = find_target_turf(controller, target, ability)
	if(!target_destination)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	if(ability.InterceptClickOn(controller.pawn, null, target_destination))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/// Return true if your target is valid for the action
/datum/ai_behavior/make_carp_rift/proc/validate_target(datum/ai_controller/controller, atom/target, datum/action/cooldown/mob_cooldown/lesser_carp_rift/ability)
	if(!ability)
		return FALSE
	if(!target)
		return FALSE
	return TRUE

/// Return the turf to teleport to, implement this or the behaviour won't do anything
/datum/ai_behavior/make_carp_rift/proc/find_target_turf(datum/ai_controller/controller, atom/target, datum/action/cooldown/mob_cooldown/lesser_carp_rift/ability)
	CRASH("Called unimplemented target finding proc on carp rift behaviour")

/**
 * # Make carp rift away
 * Make a rift bringing you further away from your target
 */
/datum/ai_behavior/make_carp_rift/away

/datum/ai_behavior/make_carp_rift/away/find_target_turf(datum/ai_controller/controller, atom/target, datum/action/cooldown/mob_cooldown/lesser_carp_rift/ability)
	return get_ranged_target_turf_direct(controller.pawn, target, ability.max_range, 180)

/**
 * # Make carp rift forwards
 * Make a rift bringing you closer to your target
 */
/datum/ai_behavior/make_carp_rift/towards
	/// Drop rift at least this many tiles away from target
	var/teleport_buffer_distance = 0
	/// Teleport simply if you are far away
	var/teleport_if_far = TRUE
	/// Teleport if the turf in front of you is blocked
	var/teleport_if_blocked = TRUE

/datum/ai_behavior/make_carp_rift/towards/validate_target(datum/ai_controller/controller, atom/target, datum/action/cooldown/mob_cooldown/lesser_carp_rift/ability)
	. = ..()
	if(!.)
		return FALSE

	if(teleport_if_far)
		var/distance = get_dist(get_turf(controller.pawn), get_turf(target))
		if(distance >= ability.max_range + teleport_buffer_distance) // Perform if we are far away
			return TRUE

	if(teleport_if_blocked)
		var/turf/next_move = get_step_towards(controller.pawn, target)
		if(is_blocked_turf(next_move, TRUE)) // Perform if target is behind cover
			return TRUE

	return FALSE

/datum/ai_behavior/make_carp_rift/towards/find_target_turf(datum/ai_controller/controller, atom/target, datum/action/cooldown/mob_cooldown/lesser_carp_rift/ability)
	var/turf/target_turf = get_turf(target)
	var/distance = get_dist(get_turf(controller.pawn), target_turf)

	var/turf/chosen_turf

	if(distance <= ability.max_range)
		chosen_turf = target_turf
	else
		var/run_direction = get_dir(controller.pawn, get_step_towards(controller.pawn, target_turf))
		chosen_turf = get_ranged_target_turf(controller.pawn, run_direction, ability.max_range)

	if(!chosen_turf)
		return

	// Subtract some distance so we don't drop carp directly on top of someone
	var/rift_to_target_distance = get_dist(target_turf, chosen_turf)
	if(rift_to_target_distance < teleport_buffer_distance)
		var/away_direction = get_dir(controller.pawn, get_step_away(controller.pawn, target_turf))
		var/turf/backed_away_turf = get_ranged_target_turf(controller.pawn, away_direction, teleport_buffer_distance - rift_to_target_distance)
		if(distance > get_dist(backed_away_turf, target_turf))
			chosen_turf = backed_away_turf // Avoid edge case pointless teleports from being up against a wall

	return chosen_turf

/**
 * # Make carp rift forwards (aggressive)
 * Make a rift towards your target if you are blocked from moving or if it is far away
 */
/datum/ai_behavior/make_carp_rift/towards/aggressive
	teleport_buffer_distance = 1 // Don't aggressively drop carps directly on top of a target mob

/**
 * # Make carp rift forwards (unvalidated)
 * Skip validation checks because we already did them in the controller
 */
/datum/ai_behavior/make_carp_rift/towards/unvalidated

/datum/ai_behavior/make_carp_rift/towards/unvalidated/validate_target(datum/ai_controller/controller, atom/target, datum/action/cooldown/mob_cooldown/lesser_carp_rift/ability)
	return TRUE

/datum/ai_behavior/make_carp_rift/towards/unvalidated/finish_action(datum/ai_controller/controller, succeeded, ...)
	. = ..()
	if(succeeded)
		controller.CancelActions()

/**
 * # Shortcut to target through carp rift
 * If there's a carp rift heading your way, plan to ride it to your target
 */
/datum/ai_planning_subtree/shortcut_to_target_through_carp_rift
	/// How far away do we look for rifts?
	var/search_distance = 3
	/// Minimum distance we should be from the target before we bother performing this action
	var/minimum_distance = 2

/datum/ai_planning_subtree/shortcut_to_target_through_carp_rift/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/mob/living/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(QDELETED(target))
		return

	var/distance_to_target = get_dist(controller.pawn, target)
	if(distance_to_target <= minimum_distance)
		return

	for(var/obj/effect/temp_visual/lesser_carp_rift/entrance/rift in orange(controller.pawn, search_distance))
		var/exit_count = length(rift.exit_locs)
		if(!exit_count)
			continue
		var/turf/rift_exit = rift.exit_locs[exit_count]
		if((get_dist(rift_exit, target) + get_dist(rift, target)) >= distance_to_target)
			continue
		controller.queue_behavior(/datum/ai_behavior/travel_towards_atom, rift)
		return SUBTREE_RETURN_FINISH_PLANNING

/**
 * # Carp Migration
 * Will try to plan a path between a list of locations for carp to travel through
 */
/datum/ai_planning_subtree/carp_migration

/datum/ai_planning_subtree/carp_migration/SelectBehaviors(datum/ai_controller/controller, delta_time)
	// If there's a rift nearby take a ride, then cancel everything else because it's not valid any more
	for(var/obj/effect/temp_visual/lesser_carp_rift/entrance/rift in orange(controller.pawn, CARP_PORTAL_SEARCH_RANGE))
		controller.queue_behavior(/datum/ai_behavior/travel_towards_atom, get_turf(rift))
		return SUBTREE_RETURN_FINISH_PLANNING

	// We have a destination, try to approach it
	var/turf/moving_to = controller.blackboard[BB_CARP_MIGRATION_TARGET]
	if(!isnull(moving_to))
		var/turf/next_step = get_step_towards(controller.pawn, moving_to)
		// Attempt to teleport around if we're blocked
		if(is_blocked_turf(next_step, TRUE))
			controller.queue_behavior(/datum/ai_behavior/make_carp_rift/towards/unvalidated, BB_CARP_RIFT, BB_CARP_MIGRATION_TARGET)
			controller.queue_behavior(/datum/ai_behavior/attack_obstructions/carp, BB_CARP_MIGRATION_TARGET)
		controller.queue_behavior(/datum/ai_behavior/step_towards_turf, BB_CARP_MIGRATION_TARGET)
		// We've gotten close enough to it, clear it so we can select a new point (or do nothing)
		if(get_dist(controller.pawn, moving_to) <= CARP_DESTINATION_SEARCH_RANGE)
			controller.clear_blackboard_key(BB_CARP_MIGRATION_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

	// We have a path to follow but no destination, select one
	if(length(controller.blackboard[BB_CARP_MIGRATION_PATH]))
		controller.queue_behavior(/datum/ai_behavior/find_next_carp_migration_step, BB_CARP_MIGRATION_PATH, BB_CARP_MIGRATION_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

/**
 * # Find next carp migration step
 * Records the next turf we want to travel to into the blackboard for other actions
 */
/datum/ai_behavior/find_next_carp_migration_step

/datum/ai_behavior/find_next_carp_migration_step/perform(delta_time, datum/ai_controller/controller, path_key, target_key)
	var/list/blackboard_points = controller.blackboard[path_key]
	for(var/turf/migration_point as anything in blackboard_points.Copy())
		// By the end of this loop we will either have a valid migration point set, or an empty list in our blackboard
		blackboard_points -= migration_point
		if(QDELETED(migration_point))
			continue
		if(get_dist(controller.pawn, migration_point) > CARP_DESTINATION_SEARCH_RANGE)
			controller.set_blackboard_key(target_key, migration_point)
			return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

#undef MAGICARP_SPELL_TARGET_SEEK_RANGE
#undef CARP_DESTINATION_SEARCH_RANGE
#undef CARP_PORTAL_SEARCH_RANGE
