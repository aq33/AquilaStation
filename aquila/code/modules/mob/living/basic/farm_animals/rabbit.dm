// AQUILA: port of BeeStation/BeeStation-Hornet code/modules/mob/living/basic/farm_animals/rabbit.dm (BeeStation/BeeStation-Hornet#14771, tg port)
// Our rabbits were chicken subtypes in code/modules/holiday/easter.dm (Easter rabbit, space rabbit) and Cabin.dm (plain rabbit).
// Paths as in Bee: the plain rabbit is /mob/living/basic/rabbit, the Easter one lays surprise eggs. We keep our icons
// (icons/mob/easter.dmi: b_rabbit = plain, rabbit = Easter, s_rabbit = space) and our Polish lines; the plain rabbit has no
// spoken lines, like our old one.
/mob/living/basic/rabbit
	name = "\improper królik"
	desc = "Najbardziej hipisowski skoczek w okolicy."
	icon = 'icons/mob/easter.dmi'
	icon_state = "b_rabbit_white"
	icon_living = "b_rabbit_white"
	icon_dead = "b_rabbit_white_dead"
	base_icon_state = "b_rabbit"
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	health = 15
	maxHealth = 15
	mob_size = MOB_SIZE_SMALL
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	gold_core_spawnable = FRIENDLY_SPAWN
	speak_emote = list("pociąga nosem", "drga")
	response_help_continuous = "głaszcze"
	response_disarm_continuous = "delikatnie odsuwa na bok"
	response_harm_continuous = "kopie"
	attack_verb_continuous = "kopie"
	attack_sound = 'sound/weapons/punch1.ogg'
	attack_vis_effect = ATTACK_EFFECT_KICK
	butcher_results = list(/obj/item/food/meat/slab = 1)
	unsuitable_cold_damage = 0.5 // Cold damage is 0.5 here to account for low health on the rabbit.
	unsuitable_heat_damage = 0.5 // Heat damage is 0.5 here to account for low health on the rabbit.
	minimum_survivable_temperature = 0
	ventcrawler = VENTCRAWLER_ALWAYS
	chat_color = "#FFDC9B"
	mobchatspan = "assistant"
	ai_controller = /datum/ai_controller/basic_controller/rabbit

/mob/living/basic/rabbit/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/pet_bonus, "radośnie skacze dookoła!")
	AddElement(/datum/element/animal_variety, base_icon_state, pick("brown", "black", "white"), TRUE)
	held_state = icon_state
	if(prob(20) && name == initial(name)) // bunny
		name = "króliczek"
		real_name = name

/// The easter subtype of rabbits, will lay eggs and say Eastery catchphrases.
/mob/living/basic/rabbit/easter
	icon_state = "rabbit_white"
	icon_living = "rabbit_white"
	icon_dead = "rabbit_white_dead"
	base_icon_state = "rabbit"
	minimum_survivable_temperature = 250
	ai_controller = /datum/ai_controller/basic_controller/rabbit/easter
	///passed to the egg_layer component as how many eggs it starts out as able to lay.
	var/initial_egg_amount = 10
	///passed to the egg_layer component as how many eggs it's allowed to hold at most.
	var/max_eggs_held = 8

/mob/living/basic/rabbit/easter/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/egg_layer, \
		/obj/item/suprise_egg/loaded, \
		list(/obj/item/food/grown/carrot),\
		list("Radośnie skubie.", "Radośnie chrupie."),\
		list("chowa jajko.", "podejrzanie się kręci.", "zaczyna robić straszny harmider.", "zaczyna się wiercić."),\
		initial_egg_amount,\
		rand(1, 4),\
		max_eggs_held,\
	)

/// Same deal as the standard easter subtype, but these ones are able to brave the cold of space with their handy gas mask.
/mob/living/basic/rabbit/easter/space
	icon_state = "s_rabbit_white"
	icon_living = "s_rabbit_white"
	icon_dead = "s_rabbit_white_dead"
	base_icon_state = "s_rabbit"
	ai_controller = /datum/ai_controller/basic_controller/rabbit/easter/space
	unsuitable_atmos_damage = 0 // Zero because we are meant to survive in space.
	minimum_survivable_temperature = 0 // Minimum Allowable Body Temp, zero because we are meant to survive in space and we have a fucking RABBIT SPACE MASK.
	maximum_survivable_temperature = 1500 // Maximum Allowable Body Temp, 1500 because we might overheat and die in said RABBIT SPACE MASK.
	unsuitable_cold_damage = 0 // Zero because we are meant to survive in space.

/datum/ai_controller/basic_controller/rabbit
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/random_speech/rabbit,
	)

/datum/ai_controller/basic_controller/rabbit/easter
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/random_speech/rabbit/easter,
	)

/datum/ai_controller/basic_controller/rabbit/easter/space
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/random_speech/rabbit/easter/space,
	)

/datum/ai_planning_subtree/random_speech/rabbit
	speech_chance = 2
	emote_hear = list("skacze.")
	emote_see = list("skacze dookoła", "podskakuje w górę i w dół")

/// For the easter subvariant of rabbits, these ones actually speak catchphrases.
/datum/ai_planning_subtree/random_speech/rabbit/easter
	speak = list("Wskocz w Wielkanoc!", "Chodźcie po jajka!", "Nagrody dla wszystkich!")

/// These ones have a space mask on, so their catchphrases are muffled.
/datum/ai_planning_subtree/random_speech/rabbit/easter/space
	speak = list("Hmph mmph mmmph!", "Mmphe mmphe mmphe!", "Hmm mmm mmm!")
