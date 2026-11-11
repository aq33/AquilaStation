// AQUILA - przyciski mocy genetycznych w jednym stylu: ikony z Goonstation (goon/icons/mob/genetics_powers.dmi, CC BY-NC-SA 3.0).
// Ramka jest wrysowana w ikonę, więc przyciski mają przezroczyste tło (aquila/icons/mob/actions/tlo_puste.dmi).

/obj/effect/proc_holder
	/// Plik tła przycisku akcji; puste = domyślne icons/mob/actions/backgrounds.dmi
	var/action_background_icon

/datum/action/spell_action/New(Target)
	. = ..()
	var/obj/effect/proc_holder/holder = target
	if(holder?.action_background_icon)
		button_icon = holder.action_background_icon

// --- stary system zaklęć (proc_holder)

/obj/effect/proc_holder/spell/aimed/firebreath
	action_icon = 'goon/icons/mob/genetics_powers.dmi'
	base_icon_state = "firebreath"
	action_icon_state = "firebreath0"
	action_background_icon = 'aquila/icons/mob/actions/tlo_puste.dmi'
	action_background_icon_state = "puste"

/obj/effect/proc_holder/spell/aimed/cryo
	action_icon = 'goon/icons/mob/genetics_powers.dmi'
	base_icon_state = "cryokinesis"
	action_icon_state = "cryokinesis0"
	action_background_icon = 'aquila/icons/mob/actions/tlo_puste.dmi'
	action_background_icon_state = "puste"

/obj/effect/proc_holder/spell/targeted/vore
	action_icon = 'goon/icons/mob/genetics_powers.dmi'
	action_icon_state = "mattereater"
	action_background_icon = 'aquila/icons/mob/actions/tlo_puste.dmi'
	action_background_icon_state = "puste"

/obj/effect/proc_holder/spell/targeted/mindread
	action_icon = 'goon/icons/mob/genetics_powers.dmi'
	action_icon_state = "telepathy"
	action_background_icon = 'aquila/icons/mob/actions/tlo_puste.dmi'
	action_background_icon_state = "puste"

/obj/effect/proc_holder/spell/self/void
	action_icon = 'goon/icons/mob/genetics_powers.dmi'
	action_icon_state = "dimensionshift"
	action_background_icon = 'aquila/icons/mob/actions/tlo_puste.dmi'
	action_background_icon_state = "puste"

/obj/effect/proc_holder/spell/self/self_amputation
	action_icon = 'goon/icons/mob/genetics_powers.dmi'
	action_icon_state = "shoot_limb"
	action_background_icon = 'aquila/icons/mob/actions/tlo_puste.dmi'
	action_background_icon_state = "puste"

// --- nowy system zaklęć (/datum/action/cooldown/spell)

/datum/action/cooldown/spell/pointed/paradise_empath
	icon_icon = 'goon/icons/mob/genetics_powers.dmi'
	button_icon_state = "empath"
	button_icon = 'aquila/icons/mob/actions/tlo_puste.dmi'
	background_icon_state = "puste"

/datum/action/cooldown/spell/pointed/paradise_polymorph
	icon_icon = 'goon/icons/mob/genetics_powers.dmi'
	button_icon_state = "polymorphism"
	button_icon = 'aquila/icons/mob/actions/tlo_puste.dmi'
	background_icon_state = "puste"

/datum/action/cooldown/spell/paradise/immolate
	icon_icon = 'goon/icons/mob/genetics_powers.dmi'
	button_icon_state = "immolate"
	button_icon = 'aquila/icons/mob/actions/tlo_puste.dmi'
	background_icon_state = "puste"

/datum/action/cooldown/spell/paradise/leap
	icon_icon = 'goon/icons/mob/genetics_powers.dmi'
	button_icon_state = "jumpy"
	button_icon = 'aquila/icons/mob/actions/tlo_puste.dmi'
	background_icon_state = "puste"

/datum/action/cooldown/spell/adrenaline
	icon_icon = 'goon/icons/mob/genetics_powers.dmi'
	button_icon_state = "adrenaline"
	button_icon = 'aquila/icons/mob/actions/tlo_puste.dmi'
	background_icon_state = "puste"

/datum/action/cooldown/spell/touch/lay_on_hands
	icon_icon = 'goon/icons/mob/genetics_powers.dmi'
	button_icon_state = "healingtouch"
	button_icon = 'aquila/icons/mob/actions/tlo_puste.dmi'
	background_icon_state = "puste"

/datum/action/cooldown/spell/toggle/monke_xray
	icon_icon = 'goon/icons/mob/genetics_powers.dmi'
	button_icon_state = "eye"
	button_icon = 'aquila/icons/mob/actions/tlo_puste.dmi'
	background_icon_state = "puste"
