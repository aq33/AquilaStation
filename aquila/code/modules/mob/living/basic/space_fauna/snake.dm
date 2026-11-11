// AQUILA: port of BeeStation/BeeStation-Hornet code/modules/mob/living/basic/space_fauna/snake.dm (BeeStation/BeeStation-Hornet#14771, tg port)
// Polish lines from our simple animal snake; a ghost can still take a snake over (Aquila, decision D14). Changes against Bee:
// - our venom reagent (/datum/reagent/toxin/venom, as before) and the venom gland udder gives it too; the snake of the rod of
//   Asclepius passes its healing chemical as the special reagent (Bee's Initialize argument) instead of setting poison_type;
// - the snake can be picked up and worn on the head, as our old snake;
// - mice are hunted through find_food like in Bee: a caught mouse is swallowed (basic_eating), Polish taming line;
// - no spoken hisses (our snake does not talk, should_talk = FALSE), only the emotes.
/mob/living/basic/snake
	name = "wąż"
	desc = "Śliski wąż. Te beznogie gady to zmora zarówno myszy, jak i poszukiwaczy przygód."
	icon_state = "snake"
	icon_living = "snake"
	icon_dead = "snake_dead"
	speak_emote = list("syczy")

	health = 20
	maxHealth = 20
	melee_damage = 6
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE

	attack_verb_continuous = "gryzie"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE

	response_help_continuous = "głaszcze"
	response_disarm_continuous = "przegania"
	response_harm_continuous = "nadeptuje na"

	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	ventcrawler = VENTCRAWLER_ALWAYS
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	held_state = "snake"
	chat_color = "#26F55A"

	faction = list(FACTION_HOSTILE)
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST, MOB_REPTILE)
	gold_core_spawnable = FRIENDLY_SPAWN
	playable = TRUE
	should_talk = FALSE

	ai_controller = /datum/ai_controller/basic_controller/snake

	/// how many units of venom are injected in target per attack
	var/venom_dose = 3
	/// what the bite injects
	var/venom_type = /datum/reagent/toxin/venom
	/// List of stuff (mice) that we want to eat
	var/static/list/edibles = list(
		/mob/living/basic/mouse,
		/obj/item/food/deadmouse,
	)

/mob/living/basic/snake/Initialize(mapload, special_reagent)
	if(special_reagent)
		venom_type = special_reagent
	. = ..()
	AddElement(/datum/element/ai_retaliate)

	AddElement(/datum/element/basic_eating, heal_amt = 2, food_types = edibles)
	ai_controller.set_blackboard_key(BB_BASIC_FOODS, typecacheof(edibles))

	AddComponent(\
		/datum/component/tameable, \
		food_types = list(/obj/item/food/deadmouse), \
		tame_chance = 75, \
		bonus_tame_chance = 10, \
	) // snakes are really fond of food, especially in the cold darkness of space :)

	AddElement(/datum/element/venomous, venom_type, venom_dose)
	AddComponent(/datum/component/udder, /obj/item/udder/venom, reagent_produced_typepath = venom_type)
	find_candidates()

/mob/living/basic/snake/attack_ghost(mob/dead/observer/user)
	. = ..()
	give_to_ghost(user)

/mob/living/basic/snake/befriend(mob/living/new_friend)
	. = ..()
	if(!.)
		return
	visible_message("[src] radośnie syczy, przywiązując się do [new_friend].")

/**
 * # venom udder subtype
 *
 * Used by snakes, I guess other venomous creatures if you want to.
 */
/obj/item/udder/venom
	name = "gruczoł jadowy"

/obj/item/udder/venom/initial_conditions()
	// AQUILA: a snake starts with an empty gland (Bee: the default 20 units of the reagent)
	if(udder_mob)
		START_PROCESSING(SSobj, src)

/// Snakes are primarily concerned with getting those tasty, tasty mice, but aren't afraid to strike back at those who attack them
/datum/ai_controller/basic_controller/snake
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
	)

	ai_traits = DEFAULT_AI_FLAGS | STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/snake,
	)

/datum/ai_planning_subtree/random_speech/snake
	speech_chance = 1
	emote_hear = list("syczy.")
	emote_see = list("pełznie dookoła.", "zerka.", "wpatruje się.")
