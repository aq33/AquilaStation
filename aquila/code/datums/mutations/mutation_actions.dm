// AQUILA - mutacje z nowymi zaklęciami (/datum/action/cooldown/spell) i deklaratywnymi traitami, jak power_path i mutation_traits w tg

/// Zdolność z nowego systemu zaklęć nadawana przez mutację
/datum/mutation/var/datum/action/cooldown/spell/action_path
/// Nadana zdolność z action_path
/datum/mutation/var/datum/action/cooldown/spell/action_power
/// Traity nadawane na czas trwania mutacji
/datum/mutation/var/list/mutation_traits

/datum/mutation/on_acquiring(mob/living/carbon/C)
	. = ..()
	if(. || !owner)
		return
	// Osobne źródło na mutację - dwie mutacje z tym samym traitem nie zdejmują go sobie nawzajem
	if(length(mutation_traits))
		owner.add_traits(mutation_traits, REF(src))

/datum/mutation/on_losing(mob/living/carbon/owner)
	. = ..()
	if(.)
		return
	if(action_power)
		QDEL_NULL(action_power)
	if(length(mutation_traits))
		owner.remove_traits(mutation_traits, REF(src))

/datum/mutation/grant_spell()
	if(ispath(action_path) && owner && !action_power)
		action_power = new action_path(owner)
		action_power.background_icon_state = "bg_tech_blue"
		action_power.Grant(owner)
		return TRUE
	return ..()

/datum/mutation/modify()
	if(!modified && owner && action_power)
		action_power.cooldown_time *= GET_MUTATION_ENERGY(src)
		modified = TRUE
		return
	return ..()
