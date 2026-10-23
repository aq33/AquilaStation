///Tracking reasons
/datum/antagonist/heretic_monster
	name = "\improper Pradawny horror"
	roundend_category = "heretycy"
	antagpanel_category = "Heretic Beast"
	antag_moodlet = /datum/mood_event/heretics
	banning_key = ROLE_HERETIC_MONSTER
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE
	/// AQUILA - ikonka w HUD-zie antagonistów (tg: antag_hud_name)
	var/antag_hud_name = "heretic_beast"
	/// AQUILA - dźwięk przy zostaniu potworem (tg: stinger_sound)
	var/stinger_sound = 'aquila/sound/music/antag/heretic/heretic_gain.ogg'
	/// Our master (a heretic)'s mind.
	var/datum/mind/master

/datum/antagonist/heretic_monster/greet()
	. = ..()
	if(!silent && owner.current && stinger_sound)
		owner.current.playsound_local(get_turf(owner.current), stinger_sound, 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)

/datum/antagonist/heretic_monster/on_removal()
	if(!silent)
		if(master?.current)
			to_chat(master.current, span_warning("Esencja twojego sługi, [owner], znika z twojego umysłu."))
		if(owner.current)
			to_chat(owner.current, span_deconversion_message("Twój umysł spowija mgła - [master ? "[master] nie jest już twoim panem" : "nie masz już pana"], jesteś wolny!"))
			owner.current.visible_message(span_deconversion_message("[owner.current] wygląda, jakby uwolnił się z łańcuchów Mansusa!"), ignored_mobs = owner.current)

	master = null
	return ..()

/datum/antagonist/heretic_monster/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/target = mob_override || owner.current
	ADD_TRAIT(target, TRAIT_HERETIC_SUMMON, REF(src))
	add_antag_hud(ANTAG_HUD_HERETIC, antag_hud_name, target)
	update_heretic_alt_appearances(target)

/datum/antagonist/heretic_monster/remove_innate_effects(mob/living/mob_override)
	var/mob/living/target = mob_override || owner.current
	REMOVE_TRAIT(target, TRAIT_HERETIC_SUMMON, REF(src))
	remove_antag_hud(ANTAG_HUD_HERETIC, target)
	update_heretic_alt_appearances(target, force_remove = !IS_HERETIC(target))
	return ..()

/*
 * Set our [master] var to a new mind.
 */
/datum/antagonist/heretic_monster/proc/set_owner(datum/mind/master)
	src.master = master
	owner.enslave_mind_to_creator(master.current)

	var/datum/objective/master_obj = new()
	master_obj.owner = owner
	master_obj.explanation_text = "Wspieraj swojego pana."
	master_obj.completed = TRUE

	objectives += master_obj
	owner.announce_objectives()
	to_chat(owner, span_boldnotice("Jesteś [ishuman(owner.current) ? "chodzącym trupem przywróconym" : "okropnym tworem sprowadzonym"] na ten plan przez Bramy Mansusa."))
	to_chat(owner, span_notice("Twoim panem jest [master]. Wspieraj go we wszystkim."))

/datum/antagonist/heretic_monster/get_antag_name() // good to recognise who's responsible with these monsters
	if(!master)
		return "Pradawny horror bez pana"
	return "Pradawny horror: [master.name]"
