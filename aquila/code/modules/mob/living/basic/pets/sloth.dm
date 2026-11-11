// AQUILA: port of BeeStation/BeeStation-Hornet code/modules/mob/living/basic/pets/sloth.dm (BeeStation/BeeStation-Hornet#14771, tg port)
// Polish lines from our simple animal sloths (Paperwork and Citrus, the cargo pets). No new "slow smile" emote: petting shows a line.
/mob/living/basic/sloth
	name = "leniwiec"
	desc = "Urocze, zaspane stworzenie."
	icon = 'icons/mob/pets.dmi'
	icon_state = "sloth"
	icon_living = "sloth"
	icon_dead = "sloth_dead"

	speak_emote = list("ziewa")

	can_be_held = TRUE
	held_state = "sloth"

	response_help_continuous = "głaszcze"
	response_disarm_continuous = "delikatnie odsuwa na bok"
	response_harm_continuous = "kopie"

	attack_verb_continuous = "gryzie"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE

	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	gold_core_spawnable = FRIENDLY_SPAWN

	melee_damage = 18
	health = 50
	maxHealth = 50
	speed = 10 // speed is fucking weird man. they aren't fast though don't worry
	chat_color = "#728AE6"
	butcher_results = list(/obj/item/food/meat/slab = 3)
	do_footstep = TRUE

	ai_controller = /datum/ai_controller/basic_controller/sloth

/mob/living/basic/sloth/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/pet_bonus, "powoli się uśmiecha!")
	AddElement(/datum/element/ai_retaliate)
	AddComponent(/datum/component/tree_climber)

//Cargo Sloth
/mob/living/basic/sloth/paperwork
	name = "Paperwork"
	desc = "Leniwiec zaopatrzenia. Mniej więcej tak przydatny jak reszta techników."
	gender = MALE
	gold_core_spawnable = NO_SPAWN

//Cargo Sloth 2
/mob/living/basic/sloth/citrus
	name = "Citrus"
	desc = "Leniwiec zaopatrzenia. Ma na sobie okropny sweter."
	icon_state = "cool_sloth"
	icon_living = "cool_sloth"
	icon_dead = "cool_sloth_dead"
	gender = FEMALE
	butcher_results = list(/obj/item/toy/spinningtoy = 1)
	gold_core_spawnable = NO_SPAWN

/// They're really passive in game, so they just wanna get away if you start smacking them. No trees in space from them to use for clawing your eyes out, but they will try if desperate.
/datum/ai_controller/basic_controller/sloth
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_FLEE_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate/to_flee,
		/datum/ai_planning_subtree/flee_target/from_flee_key,
		/datum/ai_planning_subtree/climb_trees,
		/datum/ai_planning_subtree/random_speech/sloth,
	)

/datum/ai_planning_subtree/random_speech/sloth
	speech_chance = 1
	emote_hear = list("chrapie.", "ziewa.")
	emote_see = list("przysypia.", "rozgląda się sennie.")
