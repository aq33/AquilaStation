// AQUILA: port of tgstation/tgstation code/modules/mob/living/basic/space_fauna/spaceman.dm (tg 926bf40c5a)
// Replaces the spaceman of code/modules/mob/living/simple_animal/hostile/retaliate/spaceman.dm (Polish lines and stats of
// ours). The NT private security officer of that file stays a simple animal until the troopers are ported.

/mob/living/basic/spaceman
	name = "kosmonauta"
	desc = "Co to, do diabła, jest..?"
	icon_state = "old"
	icon_living = "old"
	icon_dead = "old_dead"
	icon_gib = "clown_gib"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	gender = MALE
	response_help_continuous = "szturcha"
	response_disarm_continuous = "delikatnie odsuwa na bok"
	response_harm_continuous = "uderza"
	combat_mode = TRUE
	maxHealth = 100
	health = 100
	speed = 0
	melee_damage = 10
	attack_verb_continuous = "uderza"
	attack_sound = 'sound/weapons/punch1.ogg'
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	do_footstep = TRUE
	ai_controller = /datum/ai_controller/basic_controller/spaceman

/mob/living/basic/spaceman/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)

/datum/ai_controller/basic_controller/spaceman
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity/pacifist,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
