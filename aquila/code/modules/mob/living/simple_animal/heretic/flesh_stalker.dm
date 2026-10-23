/// Durable ambush mob with an EMP ability
/mob/living/simple_animal/hostile/heretic_summon/stalker
	name = "\improper Flesh Stalker"
	real_name = "Flesh Stalker"
	desc = "Obrzydlistwo sklecone z rozmaitych szczątków. Za każdym mrugnięciem wygląda trochę inaczej."
	icon_state = "stalker"
	icon_living = "stalker"
	maxHealth = 150
	health = 150
	// AQUILA - tg: 15-20 obrażeń
	melee_damage = 18
	sight = SEE_MOBS
	/// Actions to grant on spawn
	var/static/list/actions_to_add = list(
		/datum/action/cooldown/spell/emp/eldritch,
		/datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash,
		/datum/action/cooldown/spell/shapeshift/eldritch,
	)

/mob/living/simple_animal/hostile/heretic_summon/stalker/Initialize(mapload)
	. = ..()
	grant_actions_by_list(actions_to_add)
