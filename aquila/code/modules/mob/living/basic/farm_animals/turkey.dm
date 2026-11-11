// AQUILA: port of BeeStation/BeeStation-Hornet code/modules/mob/living/basic/farm_animals/turkey.dm (BeeStation/BeeStation-Hornet#14771)
// Our turkey was a chicken subtype without eggs; now it is its own mob as in Bee. Polish lines and our gobble sound.
// Tom, the mascot of the exploration shuttles, is a subtype instead of a map var edit.
/mob/living/basic/turkey
	name = "\improper indyk"
	desc = "Znowu nadszedł ten czas."
	icon_state = "turkey_plain"
	icon_living = "turkey_plain"
	icon_dead = "turkey_plain_dead"
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	speak_emote = list("gdacze", "gulgocze")
	density = FALSE
	health = 15
	maxHealth = 15
	melee_damage = 5
	response_help_continuous = "głaszcze"
	response_disarm_continuous = "delikatnie odsuwa na bok"
	response_harm_continuous = "kopie"
	attack_verb_continuous = "dziobie"
	attack_sound = 'sound/creatures/turkey.ogg'
	butcher_results = list(/obj/item/food/meat/slab/chicken = 2)
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	ventcrawler = VENTCRAWLER_ALWAYS
	gold_core_spawnable = FRIENDLY_SPAWN
	chat_color = "#FFDC9B"
	do_footstep = TRUE
	ai_controller = /datum/ai_controller/basic_controller/turkey

/mob/living/basic/turkey/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/pet_bonus, "radośnie gulgocze!")

/mob/living/basic/turkey/tom
	name = "Tom"
	desc = "Weteran Programu Eksperymentów na Zwierzętach Nanotrasen, który próbował odtworzyć organiczny skafander kosmiczny spotykany u niektórych wrogich istot. Dziś Tom jest maskotką załogi eksploracyjnej Nanotrasen."
	gender = MALE
	unsuitable_atmos_damage = 0
	health = 200
	maxHealth = 200
	minimum_survivable_temperature = TCMB
	gold_core_spawnable = NO_SPAWN

/datum/ai_controller/basic_controller/turkey
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/random_speech/turkey,
	)

/datum/ai_planning_subtree/random_speech/turkey
	speech_chance = 2
	speak = list("Gul!", "GUL GUL GUL!", "Ko.")
	emote_hear = list("gulgocze.")
	emote_see = list("dziobie ziemię.", "zawzięcie trzepocze skrzydłami.")
