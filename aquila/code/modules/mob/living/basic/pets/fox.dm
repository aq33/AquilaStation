// AQUILA: port of BeeStation/BeeStation-Hornet code/modules/mob/living/basic/pets/fox.dm (BeeStation/BeeStation-Hornet#14771, tg port)
// Polish lines from our simple animal fox. Changes against Bee:
// - no pet cult (decision D10), no new "yap" emote: petting shows a Polish line;
// - Renault, the captain's fox, hunts only vermin (mice and cockroaches): a fox hunts small animals when nobody looks, and on
//   our ships the captain's fox would otherwise go for Ian and Runtime at night. The path is lowercase as in Bee (/fox/renault).
/*
* Foxes are cowardly creatures that will hunt any small animals, but only when no one is looking.
*/
/mob/living/basic/pet/fox
	name = "lis"
	desc = "To lis."
	icon = 'icons/mob/pets.dmi'
	icon_state = "fox"
	icon_living = "fox"
	icon_dead = "fox_dead"

	can_be_held = TRUE
	held_state = "fox"
	worn_slot_flags = ITEM_SLOT_HEAD
	see_in_dark = 6

	speak_emote = list("skrzeczy", "szczeka")
	chat_color = "#FFAE64"
	mobchatspan = "fox"

	butcher_results = list(/obj/item/food/meat/slab = 3)

	response_help_continuous = "głaszcze"
	response_disarm_continuous = "delikatnie odsuwa na bok"
	response_harm_continuous = "kopie"

	gold_core_spawnable = FRIENDLY_SPAWN

	melee_damage = 5
	attack_verb_continuous = "gryzie"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	do_footstep = TRUE

	ai_controller = /datum/ai_controller/basic_controller/fox

	///list of our pet commands we follow
	var/static/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/move,
		/datum/pet_command/free,
		/datum/pet_command/follow/start_active,
		/datum/pet_command/attack,
		/datum/pet_command/perform_trick_sequence,
	)

/mob/living/basic/pet/fox/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/obeys_commands, pet_commands)
	AddElement(/datum/element/wears_collar, collar_icon_state = "fox")
	AddElement(/datum/element/pet_bonus, "radośnie szczeka!")
	AddElement(/datum/element/tiny_mob_hunter, MOB_SIZE_SMALL)
	AddElement(/datum/element/ai_retaliate)

/datum/ai_controller/basic_controller/fox
	blackboard = list(
		BB_ALWAYS_IGNORE_FACTION = TRUE,
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/of_size/ours_or_smaller,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_FLEE_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/target_retaliate/to_flee,
		/datum/ai_planning_subtree/flee_target/from_flee_key,
		/datum/ai_planning_subtree/simple_find_target/not_while_observed,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/fox,
	)

// An AI controller for more docile foxes.
/datum/ai_controller/basic_controller/fox/docile
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/target_retaliate/to_flee,
		/datum/ai_planning_subtree/flee_target/from_flee_key,
		/datum/ai_planning_subtree/random_speech/fox,
	)

/datum/ai_planning_subtree/random_speech/fox
	speech_chance = 1
	speak = list("Ack-Ack", "Ack-Ack-Ack-Ackawoooo", "Geckers", "Awoo", "Tchoff")
	emote_hear = list("wyje.", "szczeka.")
	emote_see = list("potrząsa głową.", "drży.")

// A more docile subtype that won't attack other animals.
/mob/living/basic/pet/fox/docile
	ai_controller = /datum/ai_controller/basic_controller/fox/docile

// AQUILA: the fox AI that hunts only vermin, so Renault keeps the ship clean of mice without eating the crew's pets
/datum/ai_controller/basic_controller/fox/vermin_hunter
	blackboard = list(
		BB_ALWAYS_IGNORE_FACTION = TRUE,
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/vermin_only,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_FLEE_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

/// AQUILA: only living mice and cockroaches (not the pets of the crew, not player controlled vermin)
/datum/targeting_strategy/basic/vermin_only
	var/static/list/vermin_types = typecacheof(list(/mob/living/basic/mouse, /mob/living/basic/cockroach))

/datum/targeting_strategy/basic/vermin_only/can_attack(mob/living/living_mob, atom/the_target, vision_range)
	if(!is_type_in_typecache(the_target, vermin_types))
		return FALSE
	var/mob/living/vermin = the_target
	if(vermin.client)
		return FALSE
	return ..()

// The captain's fox, Renault
/mob/living/basic/pet/fox/renault
	name = "Renault"
	desc = "Renault, wierny lis Kapitana."
	gender = FEMALE
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	ai_controller = /datum/ai_controller/basic_controller/fox/vermin_hunter
