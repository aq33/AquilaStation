/datum/action/cooldown/spell/caretaker
	name = "Caretaker’s Last Refuge"
	desc = "Przenosi cię do Schronienia Opiekuna, czyniąc cię przezroczystym i niematerialnym. \
		W Schronieniu nic nie ogranicza twojego ruchu, ale nie możesz używać rąk ani rzucać zaklęć. \
		Nie wejdziesz do Schronienia w pobliżu innych świadomych istot, \
		a kontakt z przedmiotami antymagicznymi może cię z niego wyrzucić."
	background_icon_state = "bg_ecult"
	overlay_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "caretaker"
	sound = 'sound/effects/curse2.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 1 MINUTES

	invocation_type = INVOCATION_NONE
	spell_requirements = NONE

/datum/action/cooldown/spell/caretaker/Remove(mob/living/remove_from)
	remove_from.remove_status_effect(/datum/status_effect/caretaker_refuge)
	return ..()

/datum/action/cooldown/spell/caretaker/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/caretaker/before_cast(mob/living/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	for(var/mob/living/alive in orange(5, owner))
		if(alive.stat != DEAD && alive.client && (owner in view(alive)))
			owner.balloon_alert(owner, "inne umysły w pobliżu!")
			return . | SPELL_CANCEL_CAST

	if(!cast_on.has_status_effect(/datum/status_effect/caretaker_refuge))
		return SPELL_NO_IMMEDIATE_COOLDOWN // cooldown only on exit

/datum/action/cooldown/spell/caretaker/cast(mob/living/cast_on)
	. = ..()

	var/mob/living/carbon/carbon_user = owner
	if(carbon_user.has_status_effect(/datum/status_effect/caretaker_refuge))
		carbon_user.remove_status_effect(/datum/status_effect/caretaker_refuge)
	else
		carbon_user.apply_status_effect(/datum/status_effect/caretaker_refuge)
	return TRUE
