// AQUILA - port z tgstation (code/datums/mutations/farsight.dm)

/datum/mutation/farsight
	name = "Dalekowzroczność"
	desc = "Oczy pacjenta widzą dalej niż zwykle."
	quality = POSITIVE
	instability = 10
	text_gain_indication = "<span class='notice'>Mrowią cię oczy.</span>"
	text_lose_indication = "<span class='notice'>Twoje oczy wracają do normy.</span>"
	difficulty = 16
	power_coeff = 1
	action_path = /datum/action/cooldown/spell/farsight

/datum/mutation/farsight/on_acquiring(mob/living/carbon/owner)
	if(..())
		return TRUE
	update_power()

/datum/mutation/farsight/modify()
	. = ..()
	update_power()

/datum/mutation/farsight/proc/update_power()
	var/datum/action/cooldown/spell/farsight/to_modify = action_power
	if(istype(to_modify))
		to_modify.set_sight_range(initial(to_modify.sight_range) * (GET_MUTATION_POWER(src) == 1 ? 1 : 3))

/datum/action/cooldown/spell/farsight
	name = "Dalekowzroczność"
	desc = "Widzisz dalej niż zwykle."
	icon_icon = 'aquila/icons/mutations/tg/actions.dmi'
	button_icon_state = "eye"
	cooldown_time = 8 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	antimagic_flags = NONE
	/// O ile powiększamy widok
	var/sight_range = 1
	/// Czy widok jest teraz powiększony
	var/active = FALSE

/datum/action/cooldown/spell/farsight/proc/set_sight_range(new_value)
	if(sight_range == new_value)
		return
	sight_range = new_value
	if(active)
		owner?.client?.view_size.setTo(sight_range)

/datum/action/cooldown/spell/farsight/cast(atom/cast_on)
	. = ..()
	var/mob/living/caster = cast_on
	if(active)
		caster.client?.view_size.resetToDefault()
		active = FALSE
		cooldown_time *= 2
	else
		caster.client?.view_size.setTo(sight_range)
		active = TRUE
		cooldown_time *= 0.5

/datum/action/cooldown/spell/farsight/is_action_active()
	return active

/datum/action/cooldown/spell/farsight/Remove(mob/living/remove_from)
	if(active)
		remove_from?.client?.view_size.resetToDefault()
		active = FALSE
		cooldown_time *= 2
	return ..()
