// AQUILA - u nas nie było zaklęcia oślepienia z tg (spell_types/pointed/blind.dm), więc baza jest tutaj.
/datum/action/cooldown/spell/pointed/blind
	name = "Blind"
	desc = "To zaklęcie na chwilę oślepia jeden cel."
	button_icon_state = "blind"

	sound = 'sound/magic/blind.ogg'
	school = SCHOOL_TRANSMUTATION
	cooldown_time = 30 SECONDS

	invocation = "STI KALY."
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	active_msg = "Przygotowujesz się do oślepienia celu..."

	/// The amount of blind to apply
	var/eye_blind_duration = 20 SECONDS
	/// The amount of blurriness to apply
	var/eye_blur_duration = 40 SECONDS

/datum/action/cooldown/spell/pointed/blind/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(cast_on))
		return FALSE

	var/mob/living/carbon/human/human_target = cast_on
	return !human_target.is_blind()

/datum/action/cooldown/spell/pointed/blind/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_notice("Swędzi cię oko, ale zaraz przechodzi."))
		to_chat(owner, span_warning("Zaklęcie nie zadziałało!"))
		return FALSE

	to_chat(cast_on, span_warning("Twoje oczy wyją z bólu!"))
	cast_on.adjust_temp_blindness(eye_blind_duration)
	cast_on.set_eye_blur_if_lower(eye_blur_duration)
	return TRUE

// Given to heretic monsters.
/datum/action/cooldown/spell/pointed/blind/eldritch
	name = "Eldritch Blind"
	background_icon_state = "bg_ecult"
	overlay_icon_state = "bg_ecult"

	school = SCHOOL_FORBIDDEN
	invocation = "E'E'S."
	spell_requirements = NONE

	cast_range = 10
