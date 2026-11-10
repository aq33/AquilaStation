// AQUILA - pieces of BeeStation/BeeStation-Hornet core that basic mobs need and we did not have.
// Kept out of core: DM resolves procs globally, so core code that calls them works too.

///When a basic mob attacks something, either by AI or user (Bee code/_onclick/other_mobs.dm).
/atom/proc/attack_basic_mob(mob/user, list/modifiers)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_BASIC_MOB, user)
	return handle_basic_attack(user, modifiers) //return value of attack animal, this is how much damage was dealt to the attacked thing

///This exists so stuff can override the default call of attack_animal for attack_basic_mob
///Remove this when simple animals are removed and everything can be handled on attack basic mob.
/atom/proc/handle_basic_attack(user, modifiers)
	return attack_animal(user, modifiers)

/// Changes the density, Bee keeps it behind a setter (code/game/atom/_atom.dm)
/atom/proc/set_density(new_value)
	if(density == new_value)
		return
	. = density
	density = new_value

/**
 * Makes the passed mob a friend of this one (Bee code/modules/mob/living/living.dm).
 * Friends share a faction ("[REF(new_friend)]") and sit in the BB_FRIENDS_LIST of our AI.
 * Returns TRUE if they were not a friend before.
 */
/mob/living/proc/befriend(mob/living/new_friend)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(new_friend, COMSIG_LIVING_MADE_NEW_FRIEND, src)
	if(QDELETED(new_friend))
		return
	var/friend_ref = REF(new_friend)
	if (faction.Find(friend_ref))
		return FALSE
	faction |= friend_ref
	ai_controller?.insert_blackboard_key_lazylist(BB_FRIENDS_LIST, new_friend)

	SEND_SIGNAL(src, COMSIG_LIVING_BEFRIENDED, new_friend)
	return TRUE

/// Proc for removing a friend you added with the proc 'befriend'. Returns true if you removed a friend.
/mob/living/proc/unfriend(mob/living/old_friend)
	SHOULD_CALL_PARENT(TRUE)
	var/friend_ref = REF(old_friend)
	if (!faction.Find(friend_ref))
		return FALSE
	faction -= friend_ref
	ai_controller?.remove_from_blackboard_lazylist_key(BB_FRIENDS_LIST, old_friend)

	SEND_SIGNAL(src, COMSIG_LIVING_UNFRIENDED, old_friend)
	return TRUE

/// Called when this atom is tamed through the tameable component (Bee code/game/atom/_atom.dm)
/atom/proc/tamed(mob/living/tamer, obj/item/food)
	return

// Footsteps: Bee adds the footstep element per mob; our footstep component sits on every /mob/living, so basic mobs
// gate it with the simple animal var (mice and roaches stay silent, dogs, cats and cows patter)
/mob/living/basic
	/// Whether this mob makes footstep sounds
	var/do_footstep = FALSE

/mob/living/basic/initialize_footstep()
	if(do_footstep)
		return ..()
