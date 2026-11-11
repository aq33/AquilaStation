// AQUILA - kosmici z zestawu Kapitana Bomby (aq33/NSV13#304, sprite: Reprimann)
// Sam antagonista/event nie jest portowany, moby są dostępne do spawnu przez adminów i z eventu Portal Storm: Kurwinoxy.
// Basic moby (mobabilities cz. 2), przeróbka własna: zwykłe moby walczące wręcz, szukają celu poza swoją frakcją.

/mob/living/basic/kurwinoxy
	name = "Kurwinox"
	desc = "Co za skurwiel, nie dość że brzydki to jeszcze gównem zajeżdża."
	icon = 'aquila/icons/mob/animal.dmi'
	icon_state = "kurwinox_b_chod"
	icon_living = "kurwinox_b_chod"
	icon_dead = "kurwinox_b"
	maxHealth = 80
	health = 80
	faction = list("Kurwinox")
	combat_mode = TRUE
	melee_damage = 25 //Te skurwysyny to nie żart
	death_message = "Sra pod siebie i przestaje się ruszać."
	ai_controller = /datum/ai_controller/basic_controller/kurwinoxy

/mob/living/basic/kurwinoxy/czerwony
	desc = "Co za skurwiel, nie dość że gównem zajeżdża to jeszcze brzydki."
	icon_state = "kurwinox_cz_chod"
	icon_living = "kurwinox_cz_chod"
	icon_dead = "kurwinox_cz"
	maxHealth = 150
	health = 150
	melee_damage = 35 //Te skurwysyny to nie żart

/mob/living/basic/clowiekmaupa
	name = "maupa"
	desc = "Co to kurwa jest"
	icon = 'aquila/icons/mob/animal.dmi'
	icon_state = "bestia"
	icon_living = "bestia"
	icon_dead = "bestia"
	maxHealth = 666
	health = 666
	faction = list("Kurwinox")
	combat_mode = TRUE
	melee_damage = 40
	ai_controller = /datum/ai_controller/basic_controller/kurwinoxy

/// Szuka każdego spoza frakcji Kurwinoxów i bije wręcz
/datum/ai_controller/basic_controller/kurwinoxy
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
