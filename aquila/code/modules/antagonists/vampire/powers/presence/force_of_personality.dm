/datum/action/vampire/force_of_personality
	name = "Siła Osobowości"
	desc = "Roztocz przytłaczającą aurę autorytetu, przed którą otoczenie mimowolnie się cofa."
	button_icon_state = "power_fop"
	power_explanation = "Roztaczasz wokół siebie aurę, która subtelnie odpycha ludzi.\n\
						Działa na osoby w promieniu 3 pól. Nikt nie będzie mógł z własnej woli do ciebie podejść.\n\
						Cele muszą cię widzieć, żeby aura zadziałała."
	power_flags = BP_AM_TOGGLE | BP_AM_STATIC_COOLDOWN
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_IN_FRENZY
	vitaecost = 20
	constant_vitaecost = 1
	cooldown_time = 10 SECONDS
	/// The range of the aura in tiles, this is further than the actual effect just so we can hit them with the status effect before they even get close enough.
	var/aura_range = 7

/datum/action/vampire/force_of_personality/activate_power()
	. = ..()
	to_chat(owner, span_notice("Roztaczasz wokół siebie przytłaczający autorytet."), type = MESSAGE_TYPE_INFO)

/datum/action/vampire/force_of_personality/deactivate_power()
	. = ..()
	to_chat(owner, span_notice("Wycofujesz swoją władczą obecność."), type = MESSAGE_TYPE_INFO)

/datum/action/vampire/force_of_personality/use_power()
	. = ..()
	for(var/mob/living/victim in oviewers(aura_range, owner))
		if(!can_affect(victim))
			continue
		if(!victim.has_status_effect(/datum/status_effect/intimidated))
			victim.apply_status_effect(/datum/status_effect/intimidated, owner)
		else
			var/datum/status_effect/intimidated/existing = victim.has_status_effect(/datum/status_effect/intimidated)
			existing.refresh()

/// Checks if this victim can be affected by the force of personality aura
/datum/action/vampire/force_of_personality/proc/can_affect(mob/living/victim)
	if(!victim.client)
		return FALSE
	if(victim.has_unlimited_silicon_privilege)
		return FALSE
	if(victim.stat != CONSCIOUS)
		return FALSE
	if(victim.is_blind() || victim.is_nearsighted_currently())
		return FALSE
	if(HAS_MIND_TRAIT(victim, TRAIT_VAMPIRE_ALIGNED) || is_curator_job(victim?.mind?.assigned_role))
		return FALSE
	return TRUE

/// Status effect for being affected by Force of Personality
/datum/status_effect/intimidated
	id = "intimidated"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 10 SECONDS
	tick_interval = 0.2 SECONDS
	alert_type = null
	/// The vampire projecting the aura
	var/mob/living/source_vampire
	/// The range at which the effect triggers
	var/trigger_range = 3
	COOLDOWN_DECLARE(message_cooldown)

/datum/status_effect/intimidated/on_creation(mob/living/new_owner, mob/living/vampire)
	source_vampire = vampire
	return ..()

/datum/status_effect/intimidated/Destroy()
	source_vampire = null
	return ..()

/datum/status_effect/intimidated/on_apply()
	if(!iscarbon(owner))
		return FALSE
	return TRUE

/datum/status_effect/intimidated/refresh()
	duration = world.time + initial(duration)

/datum/status_effect/intimidated/tick(seconds_between_ticks)
	if(QDELETED(source_vampire) || source_vampire.stat == DEAD)
		qdel(src)
		return

	if(INCAPACITATED_IGNORING(owner, INCAPABLE_RESTRAINTS))
		return

	// Only check if we're within range of the vampire
	if(get_dist(owner, source_vampire) > trigger_range)
		return

	// Step away from the vampire
	if(owner.get_body_position() == STANDING_UP)
		var/away_dir = get_dir(source_vampire.loc, owner.loc)
		var/turf/retreat_turf = get_step(owner.loc, away_dir)
		// Make sure we're not stepping into the vampire or into a wall
		if(retreat_turf && !is_blocked_turf(retreat_turf))
			if(COOLDOWN_FINISHED(src, message_cooldown))
				COOLDOWN_START(src, message_cooldown, 3 SECONDS)
				owner.visible_message(span_warning("[owner] pospiesznie cofa się o krok."), span_awe("Nie śmiesz się zbliżyć..."))
			owner.Move(retreat_turf, away_dir)

/datum/status_effect/intimidated/get_examine_text()
	return span_warning("Unika wzroku i trzyma się na dystans.")
