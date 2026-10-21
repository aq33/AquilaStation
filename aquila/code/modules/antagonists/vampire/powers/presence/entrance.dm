/**
 *	ENTRANCE
 *	A stunning spell that slows, mutes, and impairs the target for a short duration.
 *	Like a softer mesmerize - target isn't fully out of commission but is very impaired.
 */
/datum/action/vampire/targeted/entrance
	name = "Oczarowanie"
	desc = "Na chwilę przykuj uwagę śmiertelnika, spowalniając go, odbierając mu głos i otępiając."
	button_icon_state = "power_entrance"
	power_explanation = "Kliknij dowolnego gracza, żeby go oczarować i na chwilę osłabić.\n\
		Cel zostanie spowolniony, oniemieje i przez krótki czas nie będzie mógł używać przedmiotów.\n\
		To łagodniejsza forma kontroli - cel nadal może się ruszać i stawiać opór, ale jest mocno utrudniony."
	power_flags = NONE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 80
	cooldown_time = 60 SECONDS
	target_range = 7
	prefire_message = "Kogo oczarujesz?"

/datum/action/vampire/targeted/entrance/check_valid_target(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE

	if(!iscarbon(target_atom))
		return FALSE
	var/mob/living/carbon/carbon_target = target_atom

	if(!carbon_target.mind)
		owner.balloon_alert(owner, "[carbon_target]: brak umysłu.")
		return FALSE

	if(HAS_MIND_TRAIT(carbon_target, TRAIT_VAMPIRE_ALIGNED) || is_curator_job(carbon_target?.mind?.assigned_role))
		owner.balloon_alert(owner, "odporność na twoją prezencję.")
		return FALSE

	if(carbon_target.stat != CONSCIOUS)
		owner.balloon_alert(owner, "[carbon_target]: [(carbon_target.stat == DEAD || HAS_TRAIT(carbon_target, TRAIT_FAKEDEATH)) ? "nie żyje" : "bez przytomności"].")
		return FALSE

	if(carbon_target.has_status_effect(/datum/status_effect/entranced))
		owner.balloon_alert(owner, "[carbon_target]: już oczarowany.")
		return FALSE

	return TRUE

/datum/action/vampire/targeted/entrance/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/carbon/carbon_target = target_atom

	carbon_target.apply_status_effect(/datum/status_effect/entranced, 20 SECONDS)

	owner.balloon_alert(owner, "oczarowano: [carbon_target]")
	to_chat(carbon_target, span_awe("W twojej głowie robi się pusto..."), type = MESSAGE_TYPE_WARNING)
	to_chat(owner, span_notice("Przykuwasz uwagę i otępiasz: [carbon_target]."), type = MESSAGE_TYPE_INFO)

/// Status effect for being entranced
/datum/status_effect/entranced
	id = "entranced"
	status_type = STATUS_EFFECT_UNIQUE
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = /atom/movable/screen/alert/status_effect/entranced

/datum/status_effect/entranced/on_creation(mob/living/new_owner, set_duration)
	if(IS_FINITE(set_duration))
		duration = set_duration
	return ..()

/datum/status_effect/entranced/on_apply()
	if(!iscarbon(owner))
		return FALSE
	owner.add_traits(list(TRAIT_MUTE, TRAIT_HANDS_BLOCKED), TRAIT_STATUS_EFFECT(id))
	owner.add_movespeed_modifier_type(/datum/movespeed_modifier/status_effect/entranced)
	owner.set_jitter_if_lower(duration)
	owner.add_client_colour(/datum/client_colour/glass_colour/pink)
	return TRUE

/datum/status_effect/entranced/on_remove()
	owner.remove_traits(list(TRAIT_MUTE, TRAIT_HANDS_BLOCKED), TRAIT_STATUS_EFFECT(id))
	owner.remove_movespeed_modifier_type(/datum/movespeed_modifier/status_effect/entranced)
	owner.remove_client_colour(/datum/client_colour/glass_colour/pink)
	to_chat(owner, span_awe("Umysł ci się rozjaśnia i odzyskujesz skupienie."))

/datum/status_effect/entranced/get_examine_text()
	return span_warning("Ma otępiały, nieobecny wzrok.")

/// Alert for entranced status
/atom/movable/screen/alert/status_effect/entranced
	name = "Oczarowanie"
	desc = "Twój umysł pochwyciła nadnaturalna obecność. Nie możesz mówić ani używać przedmiotów."
	icon_state = "hypnosis"

/// Movespeed modifier for the entranced status effect
/datum/movespeed_modifier/status_effect/entranced
	multiplicative_slowdown = 2
