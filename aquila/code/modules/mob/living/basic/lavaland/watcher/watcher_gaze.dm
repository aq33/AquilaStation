// AQUILA: port of tgstation code/modules/mob/living/basic/lavaland/watcher/watcher_gaze.dm (tg 926bf40c5a). The AI uses it,
// so Activate() does not sleep: tg waits in a do_after(), here a timer fires the gaze and TRAIT_IMMOBILIZED holds the watcher
// still meanwhile (maintain_distance would walk it away); being moved or stunned in the meantime still breaks the gaze. We lack tg's eye overlay sprites
// and its proximity monitor: the watcher glows red while charging and the victims are checked when the gaze fires.
// tg's icewing stare only hit people resistant to cold (reversed check); here it skips them.

/**
 * Do something nasty to everyone nearby if they're looking at us.
 */
/datum/action/cooldown/mob_cooldown/watcher_gaze
	name = "Oślepiające spojrzenie"
	desc = "Po chwili oślepia każdego, kto na ciebie patrzy."
	icon_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "gaze"
	background_icon_state = "bg_demon"
	cooldown_time = 20 SECONDS
	click_to_activate = FALSE
	shared_cooldown = NONE
	/// At what range do we check for vision?
	var/effect_radius = 7
	/// How long after pressing the button do we give people to turn around?
	var/wait_delay = 1.6 SECONDS
	/// Timer until the gaze fires
	var/stage_timer
	/// Where the owner stood when it started charging
	var/turf/charge_turf

/datum/action/cooldown/mob_cooldown/watcher_gaze/Activate(atom/target)
	if (stage_timer)
		return FALSE
	owner.visible_message(span_warning("Oko [owner] złowieszczo się żarzy!"))
	animate(owner, color = "#FF6060", time = wait_delay * 0.5)
	charge_turf = get_turf(owner)
	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, REF(src))
	stage_timer = addtimer(CALLBACK(src, PROC_REF(trigger_effect)), wait_delay, TIMER_STOPPABLE)
	StartCooldown(360 SECONDS, 360 SECONDS)
	return TRUE

/datum/action/cooldown/mob_cooldown/watcher_gaze/Destroy()
	deltimer(stage_timer)
	stage_timer = null
	if (owner)
		REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, REF(src))
	return ..()

/datum/action/cooldown/mob_cooldown/watcher_gaze/Remove(mob/removed_from)
	deltimer(stage_timer)
	stage_timer = null
	if (removed_from)
		REMOVE_TRAIT(removed_from, TRAIT_IMMOBILIZED, REF(src))
		animate(removed_from, color = null, time = 0.2 SECONDS)
	return ..()

/// Do some effects to whoever is looking at us
/datum/action/cooldown/mob_cooldown/watcher_gaze/proc/trigger_effect()
	stage_timer = null
	if (QDELETED(owner))
		return
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, REF(src))
	animate(owner, color = null, time = 0.4 SECONDS)
	StartCooldown()
	var/mob/living/living_owner = owner
	if (living_owner.stat != CONSCIOUS || living_owner.incapacitated() || get_turf(owner) != charge_turf)
		return
	for (var/mob/living/viewer in viewers(effect_radius, owner))
		if (!valid_target(viewer))
			continue
		apply_effect(viewer)
	living_owner.Stun(1.5 SECONDS, ignore_canstun = TRUE)

/datum/action/cooldown/mob_cooldown/watcher_gaze/proc/valid_target(mob/living/viewer)
	if (!istype(viewer) || viewer.stat || viewer == owner)
		return FALSE
	if (!(viewer.dir & get_dir(viewer, owner)))
		return FALSE
	return TRUE

/// Do something bad to someone who was looking at us
/datum/action/cooldown/mob_cooldown/watcher_gaze/proc/apply_effect(mob/living/viewer)
	if (!viewer.flash_act(4, FALSE, TRUE, TRUE))
		return FALSE
	viewer.set_confusion_if_lower(12 SECONDS)
	to_chat(viewer, span_warning("Przeszywające spojrzenie [owner] cię oślepia!"))
	return TRUE

/// Magmawing glare burns you
/datum/action/cooldown/mob_cooldown/watcher_gaze/fire
	name = "Palące spojrzenie"
	desc = "Po chwili podpala i przewraca każdego, kto na ciebie patrzy."

/datum/action/cooldown/mob_cooldown/watcher_gaze/fire/apply_effect(mob/living/viewer)
	to_chat(viewer, span_warning("Palące spojrzenie [owner] powala cię na ziemię!"))
	viewer.Paralyze(3 SECONDS)
	viewer.adjust_fire_stacks(10)
	viewer.IgniteMob()
	return TRUE

/// Icewing glare freezes you
/datum/action/cooldown/mob_cooldown/watcher_gaze/ice
	name = "Lodowate spojrzenie"
	desc = "Po chwili zamraża i odrzuca każdego, kto na ciebie patrzy."
	/// Max distance to throw people looking at us
	var/max_throw = 3

/datum/action/cooldown/mob_cooldown/watcher_gaze/ice/apply_effect(mob/living/viewer)
	if (HAS_TRAIT(viewer, TRAIT_RESISTCOLD))
		return FALSE
	to_chat(viewer, span_warning("Siła lodowatego spojrzenia [owner] cię odrzuca!"))
	viewer.apply_status_effect(/datum/status_effect/freon/watcher)
	viewer.safe_throw_at(get_edge_target_turf(owner, get_dir(owner, viewer)), max_throw, 1, owner, force = MOVE_FORCE_EXTREMELY_STRONG)
	return TRUE
