// AQUILA - tgstation#91573 "Use any item as a prosthetic arm".
// The bodypart is a pseudopart and the item sits in its hand. Removing either one removes the other.
// Our bodyparts have no removal signal, so drop_limb() sends COMSIG_BODYPART_DROPPED for us.

/**
 * This makes an arbitrary item into a "prosthetic limb"
 */
/datum/component/item_as_prosthetic_limb
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// The item that is the prosthetic limb
	var/obj/item/item_limb
	/// Prob of losing the arm on attack
	var/drop_prob = 100
	/// The item was abstract before it became an arm
	var/was_abstract = FALSE
	/// The item could be picked up by hand before it became an arm
	var/was_pickupable = FALSE

/datum/component/item_as_prosthetic_limb/Initialize(obj/item/prosthetic_item, drop_prob = 100)
	if(!isbodypart(parent))
		return COMPONENT_INCOMPATIBLE
	var/obj/item/bodypart/bodyparent = parent
	if(bodyparent.body_zone != BODY_ZONE_L_ARM && bodyparent.body_zone != BODY_ZONE_R_ARM)
		return COMPONENT_INCOMPATIBLE
	if(isnull(bodyparent.owner) || !istype(prosthetic_item))
		return COMPONENT_INCOMPATIBLE

	bodyparent.is_pseudopart = TRUE
	item_limb = prosthetic_item // registered in RegisterWithParent()
	src.drop_prob = drop_prob

/datum/component/item_as_prosthetic_limb/InheritComponent(datum/component/new_comp, i_am_original, obj/item/prosthetic_item, drop_prob = 100)
	if(prosthetic_item && prosthetic_item != item_limb)
		unregister_item()
		register_item(prosthetic_item)
	src.drop_prob = drop_prob

/datum/component/item_as_prosthetic_limb/RegisterWithParent()
	RegisterSignal(parent, COMSIG_BODYPART_DROPPED, PROC_REF(on_limb_dropped))
	register_item(item_limb)

/datum/component/item_as_prosthetic_limb/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_BODYPART_DROPPED)
	unregister_item()

/datum/component/item_as_prosthetic_limb/proc/register_item(obj/item/prosthetic_item)
	var/obj/item/bodypart/bodyparent = parent
	SEND_SIGNAL(prosthetic_item, COMSIG_ITEM_PRE_USED_AS_PROSTHETIC, parent)
	item_limb = prosthetic_item
	RegisterSignal(prosthetic_item, COMSIG_PARENT_QDELETING, PROC_REF(item_deleted))
	RegisterSignal(prosthetic_item, COMSIG_MOVABLE_MOVED, PROC_REF(item_moved))
	RegisterSignal(prosthetic_item, COMSIG_ITEM_ATTACK, PROC_REF(pop_limb))
	RegisterSignal(prosthetic_item, COMSIG_TWOHANDED_WIELD, PROC_REF(block_wield))
	// adds a bunch of flags to the item to make it act like a limb
	was_abstract = !!(prosthetic_item.item_flags & ABSTRACT)
	was_pickupable = !!(prosthetic_item.interaction_flags_item & INTERACT_ITEM_ATTACK_HAND_PICKUP)
	prosthetic_item.item_flags |= ABSTRACT
	prosthetic_item.interaction_flags_item &= ~INTERACT_ITEM_ATTACK_HAND_PICKUP
	ADD_TRAIT(prosthetic_item, TRAIT_NODROP, PROSTHETIC_ITEM_TRAIT)
	// the real limb is named after the item, so you see "their chainsaw arm is wounded"
	bodyparent.name = "[prosthetic_item.name] zamiast ręki"
	switch(bodyparent.body_zone)
		if(BODY_ZONE_R_ARM)
			bodyparent.owner.put_in_r_hand(prosthetic_item)
		if(BODY_ZONE_L_ARM)
			bodyparent.owner.put_in_l_hand(prosthetic_item)
	bodyparent.owner.update_body_parts()
	bodyparent.owner.update_inv_hands()
	SEND_SIGNAL(prosthetic_item, COMSIG_ITEM_POST_USED_AS_PROSTHETIC, parent)

/datum/component/item_as_prosthetic_limb/proc/unregister_item()
	var/obj/item/prosthetic_item = item_limb
	if(!prosthetic_item)
		return
	item_limb = null
	UnregisterSignal(prosthetic_item, list(COMSIG_PARENT_QDELETING, COMSIG_MOVABLE_MOVED, COMSIG_ITEM_ATTACK, COMSIG_TWOHANDED_WIELD))
	// nothing to be done if it's being thrown away
	if(QDELING(prosthetic_item))
		return
	// reset all the flags
	if(!was_abstract)
		prosthetic_item.item_flags &= ~ABSTRACT
	if(was_pickupable)
		prosthetic_item.interaction_flags_item |= INTERACT_ITEM_ATTACK_HAND_PICKUP
	REMOVE_TRAIT(prosthetic_item, TRAIT_NODROP, PROSTHETIC_ITEM_TRAIT)
	SEND_SIGNAL(prosthetic_item, COMSIG_ITEM_DROPPED_FROM_PROSTHETIC, parent)

/// The limb is coming off: give the item its flags back, drop_limb() then drops it to the floor
/datum/component/item_as_prosthetic_limb/proc/on_limb_dropped(obj/item/bodypart/source, mob/living/carbon/old_owner, special)
	SIGNAL_HANDLER
	unregister_item()

/// If the fake limb (the item) is deleted, the real limb goes with it
/datum/component/item_as_prosthetic_limb/proc/item_deleted(obj/item/source)
	SIGNAL_HANDLER
	remove_limb()

/// If the item is removed from our hands somehow, the real limb has to go
/datum/component/item_as_prosthetic_limb/proc/item_moved(obj/item/source)
	SIGNAL_HANDLER
	var/obj/item/bodypart/bodyparent = parent
	if(source.loc == bodyparent.owner)
		return
	remove_limb()

/datum/component/item_as_prosthetic_limb/proc/remove_limb()
	var/obj/item/bodypart/bodyparent = parent
	if(QDELING(bodyparent))
		return
	if(bodyparent.owner)
		bodyparent.drop_limb() // a pseudopart deletes itself, which deletes us
	else
		qdel(bodyparent)

/// Attacking with the fake limb (the item) can cause it to fall off, which in turn will result in the real limb being deleted
/datum/component/item_as_prosthetic_limb/proc/pop_limb(obj/item/source, mob/living/target, mob/living/user)
	SIGNAL_HANDLER
	var/obj/item/bodypart/bodyparent = parent
	if(user != bodyparent.owner || !prob(drop_prob))
		return NONE
	user.visible_message("<span class='warning'>[user] próbuje się zamachnąć [source], ale [source] odpada od ramienia!</span>",
		"<span class='userdanger'>Próbujesz się zamachnąć [source], ale odpada ci od ramienia!</span>")
	playsound(user, 'sound/misc/splort.ogg', 50, TRUE, -1)
	INVOKE_ASYNC(src, PROC_REF(remove_limb))
	return COMPONENT_ITEM_NO_ATTACK

/// One hand is the item itself, it can't hold itself with the other one
/datum/component/item_as_prosthetic_limb/proc/block_wield(obj/item/source, mob/user)
	SIGNAL_HANDLER
	to_chat(user, "<span class='warning'>Nie dasz rady porządnie chwycić [source], skoro to twoja ręka!</span>")
	return COMPONENT_TWOHANDED_BLOCK_WIELD

/// Secures a loose item arm, it won't fall off on attacks anymore
/datum/component/item_as_prosthetic_limb/proc/secure()
	drop_prob = 0

/**
 * Makes the passed item into a "prosthetic limb" of this mob, replacing any existing arm
 *
 * Returns the created pseudopart
 */
/mob/living/carbon/proc/make_item_prosthetic(obj/item/some_thing, target_zone = BODY_ZONE_R_ARM, fall_prob = 0)
	var/obj/item/bodypart/existing = get_bodypart(target_zone)
	existing?.drop_limb(TRUE)

	var/obj/item/bodypart/bodypart_to_attach = newBodyPart(target_zone, FALSE, FALSE)
	bodypart_to_attach.is_pseudopart = TRUE
	bodypart_to_attach.attach_limb(src)
	bodypart_to_attach.AddComponent(/datum/component/item_as_prosthetic_limb, some_thing, fall_prob)

	if(bodypart_to_attach.owner != src)
		stack_trace("make_item_prosthetic failed to attach to owner!")
		qdel(bodypart_to_attach)
		return null

	return bodypart_to_attach

/// Examine lines for arms replaced with items
/mob/living/carbon/proc/prosthetic_item_examine_lines(mob/user)
	. = list()
	for(var/obj/item/bodypart/part as anything in bodyparts)
		var/datum/component/item_as_prosthetic_limb/prosthetic = part.GetComponent(/datum/component/item_as_prosthetic_limb)
		if(!prosthetic?.item_limb)
			continue
		. += "Zamiast ręki ([strefa_pl(part.body_zone)]) ma [prosthetic.item_limb.get_examine_string(user)][prosthetic.drop_prob ? " - <span class='warning'>trzyma się luźno</span>" : ""]."

// Looks: the human arm is not drawn, the item is the arm. Items with an inhand sprite use it as usual,
// items without one (food, small trinkets) get their own icon drawn shrunk where the hand would be.

/// Size the item icon is shrunk to when it has no inhand sprite
#define PROSTHETIC_FALLBACK_SIZE 18

/obj/item/bodypart/get_limb_icon(dropped)
	if(!dropped && GetComponent(/datum/component/item_as_prosthetic_limb))
		icon_state = ""
		return list()
	return ..()

/mob/living/carbon/generate_icon_key(obj/item/bodypart/BP)
	. = ..()
	if(BP.GetComponent(/datum/component/item_as_prosthetic_limb))
		. += "-item_arm"

/obj/item/build_worn_icon(default_layer = 0, default_icon_file = null, isinhands = FALSE, femaleuniform = NO_FEMALE_UNIFORM, override_state = null, special_override_flags = NONE)
	if(!isinhands || !HAS_TRAIT_FROM(src, TRAIT_NODROP, PROSTHETIC_ITEM_TRAIT))
		return ..()
	var/inhand_state = override_state || item_state || icon_state
	if(default_icon_file && icon_exists(default_icon_file, inhand_state))
		return ..()
	return mutable_appearance(prosthetic_fallback_icon(default_icon_file == righthand_file), "arm", -default_layer)

/// Directional icon of this item drawn small at the hand, for items without an inhand sprite
/obj/item/proc/prosthetic_fallback_icon(right_hand)
	var/static/list/cache = list()
	var/key = "[icon]|[icon_state]|[right_hand]"
	if(cache[key])
		return cache[key]
	// hand centers measured on the inhand sprites, in pixels from the top left
	var/static/list/right_centers = list("[SOUTH]" = list(11, 20), "[NORTH]" = list(21, 20), "[EAST]" = list(16, 20), "[WEST]" = list(14, 20))
	var/static/list/left_centers = list("[SOUTH]" = list(21, 20), "[NORTH]" = list(11, 20), "[EAST]" = list(18, 20), "[WEST]" = list(16, 20))
	var/list/centers = right_hand ? right_centers : left_centers
	var/icon/item_icon = icon(icon, icon_state, SOUTH, 1)
	item_icon.Scale(PROSTHETIC_FALLBACK_SIZE, PROSTHETIC_FALLBACK_SIZE)
	var/icon/result = new
	for(var/direction in GLOB.cardinals)
		var/list/center = centers["[direction]"]
		var/icon/frame = icon('icons/effects/effects.dmi', "nothing")
		var/icon/turned = icon(item_icon)
		if(direction == WEST)
			turned.Flip(WEST)
		// Blend takes the bottom left corner, counted from 1 at the bottom
		frame.Blend(turned, ICON_OVERLAY, center[1] - PROSTHETIC_FALLBACK_SIZE / 2 + 1, (32 - center[2]) - PROSTHETIC_FALLBACK_SIZE / 2 + 1)
		result.Insert(frame, "arm", direction)
	cache[key] = result
	return result

#undef PROSTHETIC_FALLBACK_SIZE
