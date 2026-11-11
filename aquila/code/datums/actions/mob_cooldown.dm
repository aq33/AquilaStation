// AQUILA: mob abilities of tgstation (tg 926bf40c5a code/datums/actions/cooldown_action.dm and mobs/mobcooldown.dm) as their own
// branch on our old /datum/action/cooldown (code/datums/action.dm), like the spells (aquila/code/datums/actions/spell.dm).
// Our /datum/action has one button (UpdateButtonIcon), not tg's button per viewer, and the base is not reworked, so spells,
// spider abilities and the other old cooldown actions keep their own code.
//
// Porting a tg mob ability:
// - the ability icon file is `icon_icon`; `button_icon` is the BACKGROUND file here (the other way round in tg),
// - Trigger(trigger_flags, atom/target) like the spells; tg's Trigger(mob/clicker, trigger_flags, atom/target) called with
//   positional arguments has to drop the clicker (named `target = x` calls work as they are),
// - no sequences (sequence_actions, owner_has_control) and no active button states (active_*_icon_state): an active
//   click ability turns its button green, as the spells do,
// - melee_cooldown_time only works on basic mobs (COMSIG_HOSTILE_PRE_ATTACKINGTARGET is sent from their melee_attack()).
//
// Chain: Trigger() -> (click_to_activate: set_click_ability() and a click -> InterceptClickOn()) -> PreActivate() -> Activate()
// Activate() of a subtype does the work and calls StartCooldown() itself (the base only starts the cooldown).

/// Cooldowns this long or longer are not shown on the button (an ability blocked "forever" with StartCooldown(INFINITY))
#define MOB_COOLDOWN_NO_DISPLAY_TIME (180 SECONDS)

/datum/action/cooldown/mob_cooldown
	name = "Zdolność moba"
	desc = "Kliknij przycisk, a potem cel, żeby użyć zdolności."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	cooldown_time = 5 SECONDS

	/// The default melee cooldown applied after the ability ends. If set to null, copies cooldown_time.
	var/melee_cooldown_time = 0
	/// The actual next time the owner of this action can melee
	var/next_melee_use_time = 0
	/// Whether or not you want the cooldown for the ability to display in text form
	var/text_cooldown = TRUE
	/// Significant figures to round cooldown to
	var/cooldown_rounding = 0.1
	/// Shares cooldowns with other mob abilities of the owner, bitflag of MOB_SHARED_COOLDOWN_*
	var/shared_cooldown = MOB_SHARED_COOLDOWN_1
	/// Disabled for now (disable_cooldown_actions() during a projectile attack), tg's /datum/action/var/action_disabled
	var/action_disabled = FALSE

	// These are only used for click_to_activate actions
	/// Setting for intercepting clicks before activating the ability
	var/click_to_activate = TRUE
	/// The cooldown added onto the user's next click.
	var/click_cd_override = CLICK_CD_CLICK_ABILITY
	/// If TRUE, we will unset after using our click intercept.
	var/unset_after_click = TRUE
	/// What icon to replace our mouse cursor with when active. Optional
	var/ranged_mousepointer

/datum/action/cooldown/mob_cooldown/New(Target)
	. = ..()
	if(isnull(melee_cooldown_time))
		melee_cooldown_time = cooldown_time

/datum/action/cooldown/mob_cooldown/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/action/cooldown/mob_cooldown/Grant(mob/granted_to)
	. = ..()
	if(!owner)
		return
	RegisterSignal(owner, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(handle_melee_attack))

/datum/action/cooldown/mob_cooldown/Remove(mob/removed_from)
	if(removed_from)
		UnregisterSignal(removed_from, COMSIG_HOSTILE_PRE_ATTACKINGTARGET)
		if(click_to_activate && removed_from.click_intercept == src)
			unset_click_ability(removed_from, refund_cooldown = FALSE)
	return ..()

/datum/action/cooldown/mob_cooldown/IsAvailable(feedback = FALSE)
	if(!owner)
		return FALSE
	if(action_disabled)
		return FALSE
	if(!check_action_flags(feedback))
		return FALSE
	return next_use_time <= world.time

/datum/action/cooldown/mob_cooldown/Trigger(trigger_flags, atom/target)
	. = ..()
	if(!.)
		return FALSE
	if(!owner)
		return FALSE

	// A click_to_activate ability is used on whatever the user clicks next;
	// the code (AI, other abilities) passes the target straight away
	if(click_to_activate)
		if(target)
			return InterceptClickOn(owner, null, target)
		var/datum/already_set = owner.click_intercept
		if(already_set == src)
			// Clicking the button again puts the ability away
			return unset_click_ability(owner, refund_cooldown = TRUE)
		// One mob, one click_intercept: put away another mob ability or spell first
		if(istype(already_set, /datum/action/cooldown/mob_cooldown))
			var/datum/action/cooldown/mob_cooldown/other_ability = already_set
			other_ability.unset_click_ability(owner, refund_cooldown = TRUE)
		else if(istype(already_set, /datum/action/cooldown/spell))
			var/datum/action/cooldown/spell/other_spell = already_set
			other_spell.unset_click_ability(owner, refund_cooldown = TRUE)
		return set_click_ability(owner)

	// Not a click ability: used on the user (often the owner)
	return PreActivate(owner)

/// Intercepts client owner clicks to activate the ability. TRUE = the click was used up.
/datum/action/cooldown/mob_cooldown/proc/InterceptClickOn(mob/living/clicker, params, atom/click_target)
	if(!IsAvailable(feedback = TRUE))
		return FALSE
	if(!click_target)
		return FALSE
	// The actual action begins here
	if(!PreActivate(click_target))
		return FALSE

	// And if we reach here, the action was complete successfully
	if(unset_after_click)
		unset_click_ability(clicker, refund_cooldown = FALSE)
	clicker.next_click = world.time + click_cd_override
	return TRUE

/// For signal calling
/datum/action/cooldown/mob_cooldown/proc/PreActivate(atom/activate_target)
	if(SEND_SIGNAL(owner, COMSIG_MOB_ABILITY_STARTED, src, activate_target) & COMPONENT_BLOCK_ABILITY_START)
		return FALSE
	// PreActivate handles no cooldowns at all; Activate() calls StartCooldown() where necessary
	. = Activate(activate_target)
	// Our action (or owner) may be qdeleted in Activate()
	if(!QDELETED(src) && !QDELETED(owner))
		SEND_SIGNAL(owner, COMSIG_MOB_ABILITY_FINISHED, src)

/// To be implemented by subtypes, which call StartCooldown() themselves. Returns TRUE if the ability was used.
/datum/action/cooldown/mob_cooldown/proc/Activate(atom/activate_target)
	StartCooldown()
	return TRUE

/// Starts the cooldown, shared with the owner's mob abilities of the same group. Default cooldown times if not overridden.
/datum/action/cooldown/mob_cooldown/StartCooldown(override_cooldown_time, override_melee_cooldown_time)
	if(shared_cooldown != NONE)
		StartCooldownOthers(override_cooldown_time)

	StartCooldownSelf(override_cooldown_time)

	if(isnum(override_melee_cooldown_time))
		next_melee_use_time = world.time + override_melee_cooldown_time
	else
		next_melee_use_time = world.time + melee_cooldown_time

/// Starts a cooldown time for this ability only
/datum/action/cooldown/mob_cooldown/proc/StartCooldownSelf(override_cooldown_time)
	if(isnum(override_cooldown_time))
		next_use_time = world.time + override_cooldown_time
	else
		next_use_time = world.time + cooldown_time
	update_cooldown_text()
	UpdateButtonIcon(status_only = TRUE)
	// Don't process a cooldown of 0 seconds
	if(next_use_time > world.time)
		START_PROCESSING(SSfastprocess, src)

/// Starts a cooldown time for the owner's other mob abilities that share a cooldown group with this one
/datum/action/cooldown/mob_cooldown/proc/StartCooldownOthers(override_cooldown_time)
	if(!length(owner?.actions))
		return
	for(var/datum/action/cooldown/mob_cooldown/shared_ability in owner.actions - src)
		if(!(shared_cooldown & shared_ability.shared_cooldown))
			continue
		if(isnum(override_cooldown_time))
			shared_ability.StartCooldownSelf(override_cooldown_time)
		else
			shared_ability.StartCooldownSelf(cooldown_time)

/// Resets the cooldown of this ability
/datum/action/cooldown/mob_cooldown/proc/ResetCooldown()
	next_use_time = world.time
	update_cooldown_text()
	UpdateButtonIcon(status_only = TRUE)

/// Re-enables this cooldown action
/datum/action/cooldown/mob_cooldown/proc/enable()
	action_disabled = FALSE
	UpdateButtonIcon(status_only = TRUE)

/// Disables this cooldown action
/datum/action/cooldown/mob_cooldown/proc/disable()
	action_disabled = TRUE
	UpdateButtonIcon(status_only = TRUE)

/// Re-enables all mob abilities of the owner
/datum/action/cooldown/mob_cooldown/proc/enable_cooldown_actions()
	for(var/datum/action/cooldown/mob_cooldown/cd_action in owner?.actions)
		cd_action.enable()

/// Disables all mob abilities of the owner
/datum/action/cooldown/mob_cooldown/proc/disable_cooldown_actions()
	for(var/datum/action/cooldown/mob_cooldown/cd_action in owner?.actions)
		cd_action.disable()

/// Cancels melee attacks of a basic mob while they are on cooldown.
/datum/action/cooldown/mob_cooldown/proc/handle_melee_attack(mob/source, atom/target)
	SIGNAL_HANDLER
	if(next_melee_use_time > world.time)
		return COMPONENT_HOSTILE_NO_ATTACK

/datum/action/cooldown/mob_cooldown/process()
	update_cooldown_text()
	if(!owner || next_use_time <= world.time)
		UpdateButtonIcon(status_only = TRUE)
		return PROCESS_KILL

/// Cooldown text on the button
/datum/action/cooldown/mob_cooldown/proc/update_cooldown_text()
	if(!button)
		return
	var/time_left = max(next_use_time - world.time, 0)
	if(!text_cooldown || !owner || time_left == 0 || time_left >= MOB_COOLDOWN_NO_DISPLAY_TIME)
		button.maptext = ""
		return
	button.maptext = MAPTEXT("<b>[cooldown_rounding > 0 ? round(time_left / 10, cooldown_rounding) : round(time_left / 10)]</b>")

/// Is the ability aimed right now (waiting for a click)
/datum/action/cooldown/mob_cooldown/proc/is_action_active()
	return click_to_activate && owner?.click_intercept == src

/datum/action/cooldown/mob_cooldown/UpdateButtonIcon(status_only = FALSE, force = FALSE)
	. = ..()
	if(. && is_action_active())
		button.color = COLOR_GREEN

/// Set our action as the click override on the passed mob.
/datum/action/cooldown/mob_cooldown/proc/set_click_ability(mob/on_who)
	SHOULD_CALL_PARENT(TRUE)
	on_who.click_intercept = src
	if(ranged_mousepointer)
		set_mouse_pointer(on_who, ranged_mousepointer)
	UpdateButtonIcon(status_only = TRUE)
	return TRUE

/**
 * Unset our action as the click override of the passed mob.
 *
 * if refund_cooldown is TRUE, we are being unset by the user clicking the action off
 * if refund_cooldown is FALSE, we are being forcefully unset, likely by someone actually using the action
 */
/datum/action/cooldown/mob_cooldown/proc/unset_click_ability(mob/on_who, refund_cooldown = TRUE)
	SHOULD_CALL_PARENT(TRUE)
	if(on_who.click_intercept == src)
		on_who.click_intercept = null
	if(ranged_mousepointer)
		set_mouse_pointer(on_who, null)
	UpdateButtonIcon(status_only = TRUE)
	return TRUE

/// The aiming pointer goes through mouse_override_icon of living mobs (like pet commands), so update_mouse_pointer() keeps it
/datum/action/cooldown/mob_cooldown/proc/set_mouse_pointer(mob/on_who, pointer)
	if(isliving(on_who))
		var/mob/living/living_who = on_who
		if(pointer)
			living_who.mouse_override_icon = pointer
		else if(living_who.mouse_override_icon == ranged_mousepointer)
			living_who.mouse_override_icon = null
		living_who.update_mouse_pointer()
		return
	if(pointer && on_who.client)
		on_who.client.mouse_pointer_icon = pointer
	else
		on_who.update_mouse_pointer()

#undef MOB_COOLDOWN_NO_DISPLAY_TIME
