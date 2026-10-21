/*!
 * Contains the "Void Chill" status effect. Harmful debuff which freezes and slows down non-heretics
 * Cannot affect silicons (How are you gonna freeze a robot?)
 */
/datum/status_effect/void_chill
	id = "void_chill"
	duration = 30 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/void_chill
	status_type = STATUS_EFFECT_REFRESH //Custom code
	on_remove_on_mob_delete = TRUE
	remove_on_fullheal = TRUE
	///Current amount of stacks we have
	var/stacks
	///Maximum of stacks that we could possibly get
	var/stack_limit = 5
	///icon for the overlay
	var/image/stacks_overlay

/datum/status_effect/void_chill/on_creation(mob/living/new_owner, new_stacks, ...)
	. = ..()
	if(!. || QDELETED(owner))
		return
	RegisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_stacks_overlay))
	set_stacks(new_stacks)
	owner.add_atom_colour(COLOR_BLUE_LIGHT, TEMPORARY_COLOUR_PRIORITY)
	owner.update_appearance(UPDATE_OVERLAYS)

/datum/status_effect/void_chill/on_apply()
	if(owner.can_block_magic())
		return FALSE
	if(issilicon(owner))
		return FALSE
	if(IS_HERETIC_OR_MONSTER(owner))
		return FALSE
	return TRUE

/datum/status_effect/void_chill/on_remove()
	UnregisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS)
	owner.update_appearance(UPDATE_OVERLAYS)
	owner.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_BLUE_LIGHT)
	owner.remove_movespeed_modifier(MOVESPEED_ID_VOID_CHILL)
	owner.remove_alt_appearance("heretic_status")
	REMOVE_TRAIT(owner, TRAIT_HYPOTHERMIC, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/void_chill/tick(seconds_between_ticks)
	owner.adjust_bodytemperature(-12 * stacks * seconds_between_ticks)

/datum/status_effect/void_chill/refresh(mob/living/new_owner, new_stacks, forced = FALSE)
	. = ..()
	if(forced)
		set_stacks(new_stacks)
	else
		adjust_stacks(new_stacks)
	owner.update_appearance(UPDATE_OVERLAYS)

///Updates the overlay that gets applied on our victim
/datum/status_effect/void_chill/proc/update_stacks_overlay(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER

	linked_alert?.update_appearance(UPDATE_OVERLAYS|UPDATE_DESC)
	owner.remove_alt_appearance("heretic_status")
	stacks_overlay = image('aquila/icons/effects/effects.dmi', owner, "void_chill_partial")
	if(stacks >= 5)
		stacks_overlay = image('aquila/icons/effects/effects.dmi', owner, "void_chill_oh_fuck")
	owner.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/heretic, "heretic_status", stacks_overlay, NONE)

/**
 * Setter and adjuster procs for stacks
 *
 * Arguments:
 * - new_stacks
 *
 */

/datum/status_effect/void_chill/proc/set_stacks(new_stacks)
	stacks = max(0, min(stack_limit, new_stacks))
	update_movespeed(stacks)

/datum/status_effect/void_chill/proc/adjust_stacks(new_stacks)
	stacks = max(0, min(stack_limit, stacks + new_stacks))
	update_movespeed(stacks)
	if(stacks >= 5)
		ADD_TRAIT(owner, TRAIT_HYPOTHERMIC, TRAIT_STATUS_EFFECT(id))

///Updates the movespeed of owner based on the amount of stacks of the debuff
/datum/status_effect/void_chill/proc/update_movespeed(stacks)
	// AQUILA - tg: /datum/movespeed_modifier/void_chill (zmienny); u nas modyfikator po identyfikatorze
	owner.add_movespeed_modifier(MOVESPEED_ID_VOID_CHILL, update = TRUE, priority = 100, override = TRUE, multiplicative_slowdown = (0.5 * stacks))
	if(linked_alert)
		linked_alert.maptext = MAPTEXT("<span style='text-align:center'>[stacks]</span>")

/datum/status_effect/void_chill/lasting
	id = "lasting_void_chill"
	duration = STATUS_EFFECT_PERMANENT

//---- Screen alert
/atom/movable/screen/alert/status_effect/void_chill
	name = "Void Chill"
	desc = "Coś zamraża cię od środka i z zewnątrz. Nigdy wcześniej nie czułeś tak przytłaczającego zimna..."
	icon = 'aquila/icons/hud/screen_alert.dmi'
	icon_state = "heretic_template"
	overlay_state = "void_chill_minor"

/atom/movable/screen/alert/status_effect/void_chill/update_overlays()
	if(istype(attached_effect, /datum/status_effect/void_chill))
		var/datum/status_effect/void_chill/chill_effect = attached_effect
		overlay_state = chill_effect.stacks >= 5 ? "void_chill_oh_fuck" : "void_chill_minor"
	return ..()

/atom/movable/screen/alert/status_effect/void_chill/update_desc(updates)
	. = ..()
	if(!istype(attached_effect, /datum/status_effect/void_chill))
		return
	var/datum/status_effect/void_chill/chill_effect = attached_effect
	if(chill_effect.stacks >= 5)
		desc = "Miałeś szansę uciec, teraz jest za późno. Możesz już nigdy nie poczuć ciepła..."

/// tg: nakładka widoczna tylko dla heretyków i ich sług
/datum/atom_hud/alternate_appearance/basic/heretic

/datum/atom_hud/alternate_appearance/basic/heretic/New()
	..()
	for(var/mob in GLOB.player_list)
		if(mobShouldSee(mob))
			add_hud_to(mob)

/datum/atom_hud/alternate_appearance/basic/heretic/mobShouldSee(mob/viewer)
	if(IS_HERETIC_OR_MONSTER(viewer))
		return TRUE
	return FALSE
