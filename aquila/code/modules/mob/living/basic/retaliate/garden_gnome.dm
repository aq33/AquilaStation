// AQUILA: port of BeeStation/BeeStation-Hornet code/modules/mob/living/basic/retaliate/garden_gnome.dm (bee/master 0adf0fe9ae)
// New content: the gnome, its greyscale config, speech and the hidden cargo crate (BeeStation/BeeStation-Hornet packs.dm).
/mob/living/basic/garden_gnome
	name = "krasnal ogrodowy"
	desc = "Zostałeś okrasnalony."
	icon = 'aquila/icons/mob/garden_gnome.dmi'
	icon_state = "gnome"
	icon_living = "gnome"
	pass_flags = PASSMOB
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	speed = 1
	maxHealth = 40
	health = 40
	basic_mob_flags = DEL_ON_DEATH

	obj_damage = 20
	melee_damage = 7
	attack_verb_continuous = "uderza"
	attack_sound = 'sound/weapons/punch1.ogg'
	melee_attack_cooldown = 1.2 SECONDS
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	speak_emote = list("oznajmia")
	do_footstep = TRUE

	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 500

	faction = list("gnomes")
	ai_controller = /datum/ai_controller/basic_controller/garden_gnome
	mob_size = MOB_SIZE_SMALL
	gold_core_spawnable = HOSTILE_SPAWN
	greyscale_config = /datum/greyscale_config/garden_gnome
	/// The damage resistence when sinked into the ground
	var/resistance_when_sinked = list(BRUTE = 0.5, BURN = 0.5, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	/// Realistically weighted list of usual gnome hat colours
	var/static/list/gnome_hat_colours = list(
		COLOR_GNOME_RED_ONE = 9,
		COLOR_GNOME_RED_TWO = 9,
		COLOR_GNOME_RED_THREE = 9,
		COLOR_GNOME_BLUE_ONE = 3,
		COLOR_GNOME_BLUE_TWO = 3,
		COLOR_GNOME_BLUE_THREE = 3,
		COLOR_GNOME_GREEN_ONE = 3,
		COLOR_GNOME_GREEN_TWO = 3,
		COLOR_GNOME_ORANGE = 3,
		COLOR_GNOME_BROWN_ONE = 3,
		COLOR_GNOME_YELLOW = 2,
		COLOR_GNOME_GREY = 2,
		COLOR_GNOME_PURPLE = 1,
		COLOR_GNOME_WHITE = 1,
		COLOR_GNOME_BLACK = 1,
	)
	/// The chosen hat colour
	var/chosen_hat_colour
	/// Realistically weighted list of usual gnome body colours
	var/static/list/gnome_body_colours = list(
		COLOR_GNOME_YELLOW = 6,
		COLOR_GNOME_RED_ONE = 3,
		COLOR_GNOME_RED_TWO = 3,
		COLOR_GNOME_RED_THREE = 3,
		COLOR_GNOME_BLUE_ONE = 3,
		COLOR_GNOME_BLUE_TWO = 3,
		COLOR_GNOME_BLUE_THREE = 3,
		COLOR_GNOME_GREEN_ONE = 3,
		COLOR_GNOME_GREEN_TWO = 3,
		COLOR_GNOME_BROWN_ONE = 3,
		COLOR_GNOME_ORANGE = 2,
		COLOR_GNOME_WHITE = 1,
		COLOR_GNOME_GREY = 1,
		COLOR_GNOME_PURPLE = 1,
		COLOR_GNOME_BLACK = 1,
	)
	/// Realistically weighted list of usual gnome pants colours
	var/static/list/gnome_pants_colours = list(
		COLOR_GNOME_BLUE_ONE = 6,
		COLOR_GNOME_BLUE_TWO = 6,
		COLOR_GNOME_BLUE_THREE = 6,
		COLOR_GNOME_GREEN_ONE = 6,
		COLOR_GNOME_GREEN_TWO = 6,
		COLOR_GNOME_BROWN_ONE = 3,
		COLOR_GNOME_BROWN_TWO = 3,
		COLOR_GNOME_RED_ONE = 1,
		COLOR_GNOME_ORANGE = 1,
		COLOR_GNOME_WHITE = 1,
		COLOR_GNOME_GREY = 1,
		COLOR_GNOME_PURPLE = 1,
		COLOR_GNOME_BLACK = 1,
	)
	/// Realistically weighted list of usual gnome beard colours
	var/static/list/gnome_beard_colours = list(
		COLOR_GNOME_WHITE = 9,
		COLOR_GNOME_GREY = 9,
		COLOR_GNOME_BROWN_ONE = 6,
		COLOR_GNOME_BROWN_TWO = 6,
		COLOR_GNOME_BLACK = 6,
		COLOR_GNOME_ORANGE = 3,
		COLOR_GNOME_GREEN_TWO = 1,
		COLOR_GNOME_RED_ONE = 1,
		COLOR_GNOME_PURPLE = 1,
	)

/mob/living/basic/garden_gnome/Initialize(mapload)
	. = ..()
	var/datum/callback/retaliate_callback = CALLBACK(src, PROC_REF(ai_retaliate_behaviour))
	chosen_hat_colour = pick_weight(gnome_hat_colours)
	apply_colour()
	AddElement(/datum/element/death_drops, list(/obj/effect/gibspawner/generic))
	AddComponent(/datum/component/ai_retaliate_advanced, retaliate_callback)
	AddComponent(/datum/component/swarming)
	AddComponent(/datum/component/ground_sinking, target_icon_state = icon_state, outline_colour = chosen_hat_colour, damage_res_sinked = resistance_when_sinked)
	AddComponent(/datum/component/caltrop, min_damage = 5, max_damage = 10, flags = CALTROP_BYPASS_SHOES, paralyze_duration = 1 SECONDS)

/mob/living/basic/garden_gnome/proc/apply_colour()
	if(!greyscale_config)
		return
	set_greyscale(colors = list(chosen_hat_colour, pick_weight(gnome_body_colours), pick_weight(gnome_pants_colours), pick_weight(gnome_beard_colours)))

/mob/living/basic/garden_gnome/proc/ai_retaliate_behaviour(mob/living/attacker)
	if(!istype(attacker))
		return
	for(var/mob/living/basic/garden_gnome/potential_gnome in oview(src, 7))
		potential_gnome.ai_controller.insert_blackboard_key_lazylist(BB_BASIC_MOB_RETALIATE_LIST, attacker)

/datum/ai_controller/basic_controller/garden_gnome
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/garden_gnome,
	)

/datum/greyscale_config/garden_gnome
	name = "Krasnal ogrodowy"
	icon_file = 'aquila/icons/mob/garden_gnome.dmi'
	json_config = 'aquila/code/modules/mob/living/basic/retaliate/garden_gnome.json'

/datum/ai_planning_subtree/random_speech/garden_gnome
	speech_chance = 5
	speak = list("Krasnal, nie elf!", "Krasnal, nie goblin!", "Siemka, kolego!")
	emote_hear = list("chrapie.", "beka.")
	emote_see = list("mruga.")

/datum/supply_pack/critter/garden_gnome
	name = "Skrzynia z krasnalami ogrodowymi"
	desc = "Zbierz je wszystkie do swojego ogródka. W zestawie trzy!"
	hidden = TRUE
	cost = 4000
	contains = list(/mob/living/basic/garden_gnome)
	crate_name = "skrzynia z krasnalami ogrodowymi"

/datum/supply_pack/critter/garden_gnome/generate()
	. = ..()
	for(var/i in 1 to 2)
		new /mob/living/basic/garden_gnome(.)
