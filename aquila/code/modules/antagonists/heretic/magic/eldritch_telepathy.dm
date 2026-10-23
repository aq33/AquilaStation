// AQUILA - u nas nie było zaklęć z listą celów (tg: spell_types/list_target), więc baza i telepatia są tutaj, 1:1 z tg.

/**
 * ## List Target spells
 *
 * These spells will prompt the user with a tgui list
 * of all nearby targets that they select on to cast.
 *
 * To add effects on cast, override "cast(atom/cast_on)".
 * The cast_on atom is the atom that was selected by the list.
 */
/datum/action/cooldown/spell/list_target
	/// The message displayed as the title of the tgui target input list.
	var/choose_target_message = "Wybierz cel."
	/// Radius around the caster that living targets are picked to choose from
	var/target_radius = 7

/datum/action/cooldown/spell/list_target/PreActivate(atom/caster)
	var/list/list_targets = get_list_targets(caster, target_radius)
	if(!length(list_targets))
		caster.balloon_alert(caster, "brak celów w pobliżu!")
		return FALSE

	var/atom/chosen = tgui_input_list(caster, choose_target_message, name, sortNames(list_targets))
	if(QDELETED(src) || QDELETED(caster) || QDELETED(chosen) || !can_cast_spell())
		return FALSE

	if(get_dist(chosen, caster) > target_radius)
		caster.balloon_alert(caster, "za daleko!")
		return FALSE

	return Activate(chosen)

/// Get a list of living targets in radius of the center to put in the target list.
/datum/action/cooldown/spell/list_target/proc/get_list_targets(atom/center, target_radius = 7)
	var/list/things = list()
	for(var/mob/living/nearby_living in view(target_radius, center))
		if(nearby_living == owner || nearby_living == center)
			continue

		things += nearby_living

	return things

/datum/action/cooldown/spell/list_target/telepathy
	name = "Telepathy"
	desc = "Telepatycznie przekazuje wiadomość wybranej osobie."
	icon_icon = 'icons/mob/actions/actions_revenant.dmi'
	button_icon_state = "r_transmit"

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	antimagic_flags = MAGIC_RESISTANCE_MIND

	choose_target_message = "Wybierz, do kogo chcesz szepnąć."

	/// The message we send to the next person via telepathy.
	var/message
	/// The span surrounding the telepathy message
	var/telepathy_span = "notice"
	/// The bolded span surrounding the telepathy message
	var/bold_telepathy_span = "boldnotice"

/datum/action/cooldown/spell/list_target/telepathy/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	message = tgui_input_text(owner, "Co chcesz szepnąć do [cast_on]?", "[src]", max_length = MAX_MESSAGE_LEN)
	if(QDELETED(src) || QDELETED(owner) || QDELETED(cast_on) || !can_cast_spell())
		return . | SPELL_CANCEL_CAST

	if(get_dist(cast_on, owner) > target_radius)
		owner.balloon_alert(owner, "za daleko!")
		return . | SPELL_CANCEL_CAST

	if(!message)
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/list_target/telepathy/cast(mob/living/cast_on)
	. = ..()
	log_directed_talk(owner, cast_on, message, LOG_SAY, name)

	var/formatted_message = "<span class='[telepathy_span]'>[message]</span>"

	var/failure_message_for_ghosts = ""

	to_chat(owner, "<span class='[bold_telepathy_span]'>Przekazujesz do [cast_on]:</span> [formatted_message]")
	if(!cast_on.can_block_magic(antimagic_flags))
		cast_on.balloon_alert(cast_on, "słyszysz głos")
		to_chat(cast_on, "<span class='[bold_telepathy_span]'>Słyszysz głos w swojej głowie...</span> [formatted_message]")
	else
		owner.balloon_alert(owner, "przekaz zablokowany!")
		to_chat(owner, span_warning("Coś zablokowało twój przekaz!"))
		failure_message_for_ghosts = "<span class='[bold_telepathy_span]'> (zablokowane antymagią)</span>"

	for(var/mob/dead/ghost as anything in GLOB.dead_mob_list)
		if(!isobserver(ghost))
			continue

		var/from_link = FOLLOW_LINK(ghost, owner)
		var/from_mob_name = "<span class='[bold_telepathy_span]'>[owner] [src]</span>"
		from_mob_name += failure_message_for_ghosts
		from_mob_name += "<span class='[bold_telepathy_span]'>:</span>"
		var/to_link = FOLLOW_LINK(ghost, cast_on)
		var/to_mob_name = span_name("[cast_on]")

		to_chat(ghost, "[from_link] [from_mob_name] [formatted_message] [to_link] [to_mob_name]")

// Given to heretic monsters.
/datum/action/cooldown/spell/list_target/telepathy/eldritch
	name = "Eldritch Telepathy"
	school = SCHOOL_FORBIDDEN
	background_icon_state = "bg_ecult"
	overlay_icon_state = "bg_ecult"
	invocation_type = INVOCATION_NONE
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND
