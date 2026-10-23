/datum/action/cooldown/spell/touch/star_touch
	name = "Star Touch"
	desc = "Nakłada na cel gwiezdny znak. \
		Jeśli ofiara już ma gwiezdny znak, wiąże cię z nią kosmicznym promieniem. \
		Jeśli więź przetrwa 8 sekund, ofiara zaśnie i zostanie przeniesiona do ciebie. \
		Star Touch usuwa też kosmiczne runy, a użyty w dłoni przenosi cię do twojego Star Gazera."
	background_icon_state = "bg_ecult"
	overlay_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "star_touch"

	sound = 'sound/items/welder.ogg'
	school = SCHOOL_FORBIDDEN
	cooldown_time = 15 SECONDS
	invocation = "ST'R 'N'RG'!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	antimagic_flags = MAGIC_RESISTANCE

	hand_path = /obj/item/melee/spell_hand/star_touch
	/// Stores the weakref for the Star Gazer after ascending
	var/datum/weakref/star_gazer
	/// If the heretic is ascended or not
	var/ascended = FALSE

/datum/action/cooldown/spell/touch/star_touch/is_valid_target(atom/cast_on)
	if(!isliving(cast_on))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/touch/star_touch/on_antimagic_triggered(obj/item/melee/spell_hand/hand, atom/victim, mob/living/carbon/caster)
	victim.visible_message(
		span_danger("Zaklęcie odbija się od [victim]!"),
		span_danger("Zaklęcie odbija się od ciebie!"),
	)

/datum/action/cooldown/spell/touch/star_touch/cast_on_hand_hit(obj/item/melee/spell_hand/hand, mob/living/victim, mob/living/carbon/caster)
	if(!victim.has_status_effect(/datum/status_effect/star_mark))
		victim.apply_status_effect(/datum/status_effect/star_mark, caster)
		return TRUE
	victim.remove_status_effect(/datum/status_effect/star_mark)
	victim.drowsyness = max(victim.drowsyness, 4) // tg: adjust_drowsiness(8 SECONDS); u nas drowsyness spada co tyknięcie Life
	for(var/turf/cast_turf as anything in get_turfs(victim))
		create_cosmic_field(cast_turf, caster)
	caster.apply_status_effect(/datum/status_effect/cosmic_beam, victim)
	return TRUE

/datum/action/cooldown/spell/touch/star_touch/proc/get_turfs(mob/living/victim)
	var/list/target_turfs = list(get_turf(owner))
	var/range = ascended ? 2 : 1
	var/list/directions = list(turn(owner.dir, 90), turn(owner.dir, 270))
	for(var/direction in directions)
		for(var/i in 1 to range)
			target_turfs += get_ranged_target_turf(owner, direction, i)
	return target_turfs

/// To set the star gazer
/datum/action/cooldown/spell/touch/star_touch/proc/set_star_gazer(mob/living/simple_animal/hostile/heretic_summon/star_gazer/star_gazer_mob)
	star_gazer = WEAKREF(star_gazer_mob)

/// To obtain the star gazer if there is one
/datum/action/cooldown/spell/touch/star_touch/proc/get_star_gazer()
	var/mob/living/simple_animal/hostile/heretic_summon/star_gazer/star_gazer_resolved = star_gazer?.resolve()
	if(star_gazer_resolved)
		return star_gazer_resolved
	return FALSE

/obj/item/melee/spell_hand/star_touch
	name = "Star Touch"
	desc = "Złowroga aura, która wykrzywia wokół siebie bieg rzeczywistości. \
		Osoby z gwiezdnym znakiem zasypiają na 4 sekundy, a osoby bez niego dostają go."
	icon = 'aquila/icons/obj/weapons/hand.dmi'
	icon_state = "star"
	item_state = "star"
	lefthand_file = 'aquila/icons/mob/inhands/antag/star_touch_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/antag/star_touch_righthand.dmi'

/obj/item/melee/spell_hand/star_touch/Initialize(mapload, datum/action/cooldown/spell/spell)
	. = ..()
	AddComponent(\
		/datum/component/effect_remover, \
		success_feedback = "Usuwasz %THEEFFECT.", \
		on_clear_callback = CALLBACK(src, PROC_REF(after_clear_rune)), \
		effects_we_clear = list(/obj/effect/cosmic_rune), \
	)

// tg: ranged_interact_with_atom - cel w zasięgu 3 pól (jak w tg; znak nie jest wymagany)
/obj/item/melee/spell_hand/star_touch/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(proximity_flag || !isliving(target) || !isliving(user))
		return
	var/mob/living/living_target = target
	if(get_dist(living_target, user) > 3)
		return
	// AQUILA - tg nie sprawdza widoczności, więc dłoń sięgała przez ściany
	if(!(living_target in view(3, user)))
		return
	INVOKE_ASYNC(src, TYPE_PROC_REF(/obj/item, melee_attack_chain), user, living_target, click_parameters)

/*
 * Callback for effect_remover component.
 */
/obj/item/melee/spell_hand/star_touch/proc/after_clear_rune(obj/effect/target, mob/living/user)
	new /obj/effect/temp_visual/cosmic_rune_fade(get_turf(target))
	var/datum/action/cooldown/spell/touch/star_touch/star_touch_spell = spell_which_made_us?.resolve()
	star_touch_spell?.spell_feedback()
	var/datum/action/cooldown/spell/cosmic_rune/rune_spell = locate() in user.actions
	var/obj/effect/cosmic_rune/first_rune = rune_spell?.first_rune?.resolve()
	var/obj/effect/cosmic_rune/second_rune = rune_spell?.second_rune?.resolve()
	if(!QDELETED(first_rune) && first_rune != target)
		new /obj/effect/temp_visual/cosmic_rune_fade(get_turf(first_rune))
		QDEL_NULL(first_rune)
	if(!QDELETED(second_rune) && second_rune != target)
		new /obj/effect/temp_visual/cosmic_rune_fade(get_turf(second_rune))
		QDEL_NULL(second_rune)
	// AQUILA - tg tu kasuje całe zaklęcie (qdel), co wygląda na błąd; zużywamy tylko dłoń
	remove_hand_with_no_refund(user)

/obj/item/melee/spell_hand/star_touch/ignition_effect(atom/to_light, mob/user)
	. = span_rose("[user] bez wysiłku pstryka palcami przy [to_light], podpalając to kosmiczną energią. Ale czad!")
	remove_hand_with_no_refund(user)

/obj/item/melee/spell_hand/star_touch/attack_self(mob/living/user)
	var/datum/action/cooldown/spell/touch/star_touch/star_touch_spell = spell_which_made_us?.resolve()
	var/mob/living/simple_animal/hostile/heretic_summon/star_gazer/star_gazer_mob = star_touch_spell?.get_star_gazer()
	if(!star_gazer_mob)
		balloon_alert(user, "brak Star Gazera!")
		return ..()
	new /obj/effect/temp_visual/cosmic_explosion(get_turf(user))
	do_teleport(
		user,
		get_turf(star_gazer_mob),
		no_effects = TRUE,
		channel = TELEPORT_CHANNEL_MAGIC,
		asoundin = 'aquila/sound/effects/magic/cosmic_energy.ogg',
		asoundout = 'aquila/sound/effects/magic/cosmic_energy.ogg',
	)
	remove_hand_with_no_refund(user)

/obj/effect/ebeam/cosmic
	name = "cosmic beam"

/datum/status_effect/cosmic_beam
	id = "cosmic_beam"
	tick_interval = STATUS_EFFECT_NO_TICK
	duration = 8 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	/// Stores the current beam target
	var/mob/living/current_target
	/// The maximum range of the beam
	var/max_range = 8
	/// Wether the beam is active or not
	var/active = FALSE
	/// The storage for the beam
	var/datum/beam/current_beam = null
	/// The effect trail that we add to our victim
	var/cosmic_effect_trail
	/// Whether the teleport was successful or not
	var/successful_teleport = FALSE

/datum/status_effect/cosmic_beam/on_creation(mob/living/new_owner, mob/living/current_target)
	cosmic_effect_trail = cosmic_trail_based_on_passive(new_owner)
	start_beam(current_target, new_owner)
	return ..()

/datum/status_effect/cosmic_beam/on_remove()
	if(current_target && get_dist(owner, current_target) <= max_range)
		yoink_victim()
		successful_teleport = TRUE
	lose_target()
	return ..()

/// Puts the victim to sleep and teleports them to the casters' location
/datum/status_effect/cosmic_beam/proc/yoink_victim()
	current_target.apply_effect(8 SECONDS, EFFECT_UNCONSCIOUS)
	do_teleport(current_target, get_turf(owner), channel = TELEPORT_CHANNEL_MAGIC, forced = TRUE)
	current_target.apply_status_effect(/datum/status_effect/star_mark)

/datum/status_effect/cosmic_beam/be_replaced()
	lose_target()
	return ..()

/**
 * Proc that always is called when we want to end the beam and makes sure things are cleaned up, see beam_died()
 */
/datum/status_effect/cosmic_beam/proc/lose_target()
	if(active)
		UnregisterSignal(current_beam, COMSIG_PARENT_QDELETING)
		QDEL_NULL(current_beam)
		active = FALSE
	if(current_target)
		UnregisterSignal(current_target, COMSIG_PARENT_QDELETING)
		on_beam_release(current_target)
	current_target = null

/**
 * Proc that is only called when the beam fails due to something, so not when manually ended.
 * manual disconnection = lose_target, so it can silently end
 * automatic disconnection = beam_died, so we can give a warning message first
 */
/datum/status_effect/cosmic_beam/proc/beam_died()
	SIGNAL_HANDLER
	if(successful_teleport)
		return
	if(current_beam && !QDELETED(current_beam))
		UnregisterSignal(current_beam, COMSIG_PARENT_QDELETING)
	current_beam = null
	active = FALSE
	to_chat(owner, span_warning("Twoja kosmiczna więź z [current_target] została zerwana!"))
	lose_target()
	qdel(src)

/// Used for starting the beam when a target has been acquired
/datum/status_effect/cosmic_beam/proc/start_beam(atom/target, mob/living/user)

	if(current_target)
		lose_target()
	if(!isliving(target))
		return

	current_target = target
	active = TRUE
	// AQUILA - nasz Beam() domyślnie znika po 5 s, a więź trwa 8 s
	current_beam = user.Beam(current_target, icon_state = "cosmic_beam", time = initial(duration) + 2 SECONDS, maxdistance = max_range, beam_type = /obj/effect/ebeam/cosmic)
	RegisterSignal(current_beam, COMSIG_PARENT_QDELETING, PROC_REF(beam_died))
	RegisterSignal(current_target, COMSIG_PARENT_QDELETING, PROC_REF(beam_died))

	SSblackbox.record_feedback("tally", "gun_fired", 1, type)
	if(current_target)
		on_beam_hit(current_target, user)

/// What to add when the beam connects to a target
/datum/status_effect/cosmic_beam/proc/on_beam_hit(mob/living/target, mob/living/user)
	if(isstargazer(target))
		return
	ADD_TRAIT(target, TRAIT_NO_TELEPORT, REF(src))
	target.AddElement(cosmic_effect_trail, /obj/effect/forcefield/cosmic_field/star_touch)

/// What to remove when the beam disconnects from a target
/datum/status_effect/cosmic_beam/proc/on_beam_release(mob/living/target)
	if(isstargazer(target))
		return
	REMOVE_TRAIT(target, TRAIT_NO_TELEPORT, REF(src))
	target.RemoveElement(cosmic_effect_trail, /obj/effect/forcefield/cosmic_field/star_touch)
