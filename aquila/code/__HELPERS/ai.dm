// AQUILA - helpers for the AI core synced with BeeStation/BeeStation-Hornet (code/__HELPERS/ai.dm and a few core procs Bee
// has and we do not). Kept here instead of in core: DM resolves procs globally, so the synced core AI files can call them.

/// Returns either the best weapon from the given choices or null if held weapons are better
/proc/GetBestWeapon(datum/ai_controller/controller, list/choices, list/held_weapons)
	var/gun_neurons_activated = controller.blackboard[BB_MONKEY_GUN_NEURONS_ACTIVATED]
	var/top_force = 0
	var/obj/item/top_force_item
	for(var/obj/item/item as anything in held_weapons)
		if(!item)
			continue
		if(HAS_TRAIT(item, TRAIT_NEEDS_TWO_HANDS) || controller.blackboard[BB_MONKEY_BLACKLISTITEMS][item])
			continue
		if(gun_neurons_activated && istype(item, /obj/item/gun))
			// We have a gun, why bother looking for something inferior
			// Also yes it is intentional that pawns dont know how to pick the best gun
			return item
		if(item.force > top_force)
			top_force = item.force
			top_force_item = item

	for(var/obj/item/item as anything in choices)
		if(!item)
			continue
		if(HAS_TRAIT(item, TRAIT_NEEDS_TWO_HANDS) || controller.blackboard[BB_MONKEY_BLACKLISTITEMS][item])
			continue
		if(gun_neurons_activated && istype(item, /obj/item/gun))
			return item
		if(item.force <= top_force)
			continue
		top_force_item = item
		top_force = item.force

	return top_force_item

///returns if something can be consumed, drink or food
/proc/IsEdible(obj/item/thing)
	if(!istype(thing))
		return FALSE
	if(IS_EDIBLE(thing))
		return TRUE
	if(istype(thing, /obj/item/reagent_containers/food/drinks/drinkingglass))
		var/obj/item/reagent_containers/food/drinks/drinkingglass/glass = thing
		if(glass.reagents.total_volume) // The glass has something in it, time to drink the mystery liquid!
			return TRUE
	return FALSE

/**
 * Returns TRUE if a movable can "Reach" this atom (Bee /atom/proc/IsReachableBy).
 * AQUILA: the AI asks this every tick while it moves to a target, and our CanReach() builds lists (for living mobs
 * GetAllContents()) on every call. Like Bee, atoms on a turf only need the adjacency check and atoms carried by the user
 * walk up their loc chain; only atoms inside something else (bags, lockers) fall back to CanReach()'s storage checks.
 */
/atom/proc/IsReachableBy(atom/movable/user, reacher_range = 1, depth = INFINITY)
	if(isnull(user))
		return FALSE
	if(src == user || loc == user || src == user.loc)
		return TRUE
	if(isturf(src) || isturf(loc))
		if(user.Adjacent(src))
			return TRUE
		return reacher_range > 1 && isturf(loc) && get_dist(user, src) <= reacher_range
	if(isnull(loc) || isarea(loc))
		return FALSE
	for(var/atom/holder = loc; holder && !isturf(holder); holder = holder.loc)
		if(holder == user) // in the user's own inventory or a bag on them
			return TRUE
	return user.CanReach(src)

/// Returns whether it is safe for an atom to move across this turf (lava, chasms, open space for walkers).
/// Flyers cross everything; space is also safe for mobs that move in it on their own (`spacewalk`: carp, dolphins,
/// troopers in suits). Bee treats space as always safe; we keep it dangerous for the rest so pets do not wander out.
/turf/proc/can_cross_safely(atom/movable/crossing)
	if(!is_type_in_typecache(src, GLOB.dangerous_turfs))
		return TRUE
	if(isnull(crossing))
		return FALSE
	if((crossing.movement_type & FLYING) || HAS_TRAIT(crossing, TRAIT_MOVE_FLYING))
		return TRUE
	if(!isspaceturf(src) || !ismob(crossing))
		return FALSE
	var/mob/swimmer = crossing
	return swimmer.spacewalk

///Find number of held items, multihand compatible
/mob/proc/get_num_held_items()
	. = 0
	for(var/i in 1 to held_items.len)
		if(held_items[i])
			.++

/// Bee splits the resist verb into a queued proc; ours is a plain verb, so AI pawns call it directly
/mob/living/proc/execute_resist()
	resist()

/// Last AI incapacitation state seen by update_mobility() (see update_incapacitated_signal()), null when not tracked
/mob/living/var/last_incapacitated_for_ai

/// Called from the end of /mob/living/proc/update_mobility() (AQ EDIT). Bee turned incapacitated into a var with a setter
/// that sends this signal (BeeStation/BeeStation-Hornet#14060); we keep the proc and compare here instead.
/// The state is a bitfield of every part controllers ask incapacitated() about with different ignore flags (restraints,
/// grabs, stasis) plus the stat, so the signal fires whenever any controller's answer can change. Only mobs with an AI
/// controller pay for it.
/mob/living/proc/update_incapacitated_signal()
	if(!ai_controller)
		last_incapacitated_for_ai = null
		return
	var/new_state = stat
	if(incapacitated(ignore_restraints = TRUE, ignore_stasis = TRUE))
		new_state |= AI_INCAP_STATE_BASE
	if(restrained(TRUE))
		new_state |= AI_INCAP_STATE_RESTRAINED
	if(restrained(FALSE))
		new_state |= AI_INCAP_STATE_RESTRAINED_OR_GRABBED
	if(IsInStasis())
		new_state |= AI_INCAP_STATE_STASIS
	if(new_state == last_incapacitated_for_ai)
		return
	var/old_state = last_incapacitated_for_ai
	last_incapacitated_for_ai = new_state
	SEND_SIGNAL(src, COMSIG_MOB_INCAPACITATE_CHANGED, old_state, new_state)
