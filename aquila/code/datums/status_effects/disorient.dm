// Port BeeStation/BeeStation-Hornet#14750: dezorientacja z broni obezwładniających.
// Zabiera staminę (bez overstam nigdy poniżej progu stamcritu), dodaje zamieszanie i spowolnienie,
// a powala (knockdown/paralyze/stun) dopiero cel, który już jest wyczerpany.
// Różnice: confusion to u nas zmienna `confused`, spowolnienie przez ID movespeed, bez drenażu energii IPC i bez alertu.

/mob/living/proc/Disorient(amount, stamina_amount, ignore_canstun, knockdown, stun, paralyze, overstam, stack_status = TRUE, protection = 0)
	if(!stamina)
		return
	var/disorient_multiplier = 1 - (clamp(protection, 0, 100) / 100)
	var/stamina_multiplier = LERP(disorient_multiplier, 1, 0.25)

	var/stam2deal = stamina_amount * stamina_multiplier
	// Bez overstam nie da się zbić staminy do stamcritu samą bronią obezwładniającą
	if(overstam)
		stamina.adjust(-stam2deal)
	else
		var/threshold = stamina.maximum * STAMINA_STUN_THRESHOLD_MODIFIER
		stam2deal = min(stam2deal, max(stamina.current - threshold, 0))
		if(stam2deal)
			stamina.adjust(-stam2deal)

	// Zamieszanie do 15 s (confused liczy się w tickach Life, po 2 s)
	confused = max(confused, min(confused + CEILING(amount / 20, 1), CEILING((15 SECONDS) / 20, 1)))

	if(HAS_TRAIT(src, TRAIT_EXHAUSTED))
		var/list/applied = list()
		if(knockdown && (stack_status ? AdjustKnockdown(knockdown, ignore_canstun = ignore_canstun) : Knockdown(knockdown, ignore_canstun = ignore_canstun)))
			applied += "knocked down ([DisplayTimeText(knockdown)])"
		if(paralyze && (stack_status ? AdjustParalyzed(paralyze, ignore_canstun = ignore_canstun) : Paralyze(paralyze, ignore_canstun = ignore_canstun)))
			applied += "paralyzed ([DisplayTimeText(paralyze)])"
		if(stun && (stack_status ? AdjustStun(stun, ignore_canstun = ignore_canstun) : Stun(stun, ignore_canstun = ignore_canstun)))
			applied += "stunned ([DisplayTimeText(stun)])"
		if(length(applied))
			. = TRUE
			log_message("was [english_list(applied)] by a disorient while exhausted", LOG_ATTACK)

	if(amount > 0)
		var/datum/status_effect/incapacitating/disoriented/existing = has_status_effect(STATUS_EFFECT_DISORIENTED)
		if(existing)
			existing.duration = world.time + min(max(existing.duration - world.time, 0) + amount, 15 SECONDS)
		else
			apply_status_effect(STATUS_EFFECT_DISORIENTED, min(amount, 15 SECONDS))

/mob/living/proc/IsDisoriented()
	return has_status_effect(STATUS_EFFECT_DISORIENTED)

/datum/status_effect/incapacitating/disoriented
	id = "disoriented"
	tick_interval = 1 SECONDS
	status_type = STATUS_EFFECT_UNIQUE

/datum/status_effect/incapacitating/disoriented/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_DISORIENTED, TRAIT_STATUS_EFFECT(id))
	owner.add_movespeed_modifier(MOVESPEED_ID_DISORIENT, TRUE, 0, override = TRUE, multiplicative_slowdown = 1)

/datum/status_effect/incapacitating/disoriented/on_remove()
	REMOVE_TRAIT(owner, TRAIT_DISORIENTED, TRAIT_STATUS_EFFECT(id))
	owner.remove_movespeed_modifier(MOVESPEED_ID_DISORIENT)
	return ..()

/datum/status_effect/incapacitating/disoriented/tick()
	if(owner.IsParalyzed() || owner.IsStun() || owner.IsImmobilized())
		return
	INVOKE_ASYNC(owner, TYPE_PROC_REF(/atom/movable, twitch))
	playsound(owner, 'aquila/sound/effects/electric_shock_short.ogg', 35, TRUE, 0.5, 1.5)

///Krótkie szarpnięcie spritem
/atom/movable/proc/twitch()
	var/degrees = rand(-45, 45)
	transform = transform.Turn(degrees)
	var/old_x = pixel_x
	var/old_y = pixel_y
	pixel_x += rand(-3, 3)
	pixel_y += rand(-1, 1)
	sleep(0.2 SECONDS)
	transform = transform.Turn(-degrees)
	pixel_x = old_x
	pixel_y = old_y
