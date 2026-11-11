// AQUILA: port of tgstation/tgstation code/modules/mob/living/basic/space_fauna/ghost.dm (tg 926bf40c5a)
// Replaces our simple animal ghost (code/modules/mob/living/simple_animal/hostile/retaliate/ghost.dm). Polish lines, health,
// light, ghost tracking beacon, discovery points and the mapped hair vars of our ghost; random "duch: Imię Nazwisko" names
// as before. Not ported: tg's random hairstyles (our hair vars take the sprite state, tg's take the accessory name) and the
// swarm subtype (no ectoplasmic anomaly here).

/mob/living/basic/ghost
	name = "duch"
	desc = "Dusza zmarłego. Straszne."
	icon = 'icons/mob/mob.dmi'
	icon_state = "ghost"
	icon_living = "ghost"
	mob_biotypes = list(MOB_SPIRIT, MOB_UNDEAD)
	speak_emote = list("płacze")
	response_help_continuous = "przenika przez"
	response_disarm_continuous = "popycha"
	response_harm_continuous = "uderza"
	combat_mode = TRUE
	healable = FALSE
	basic_mob_flags = DEL_ON_DEATH
	speed = 0
	maxHealth = 40
	health = 40
	melee_damage = 15
	attack_verb_continuous = "chwyta"
	attack_sound = 'sound/hallucinations/growl1.ogg'
	death_message = "zawodzi, rozpadając się w stos ektoplazmy!"
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	pressure_resistance = 300
	gold_core_spawnable = NO_SPAWN //too spooky for science
	light_system = MOVABLE_LIGHT
	light_range = 1 // same glowing as visible player ghosts
	light_power = 2
	discovery_points = 1000
	ai_controller = /datum/ai_controller/basic_controller/ghost

	/// Hair sprite state suffix ("hair_[style]" in human_face.dmi), set on maps
	var/ghost_hair_style
	var/ghost_hair_color
	var/mutable_appearance/ghost_hair
	/// Facial hair sprite state suffix ("facial_[style]"), set on maps
	var/ghost_facial_hair_style
	var/ghost_facial_hair_color
	var/mutable_appearance/ghost_facial_hair
	/// Random "duch: name" or the mapped name
	var/random = TRUE

/mob/living/basic/ghost/Initialize(mapload)
	. = ..()
	var/static/list/drops = list(/obj/item/ectoplasm)
	AddElement(/datum/element/death_drops, drops)
	AddElement(/datum/element/simple_flying)
	AddElement(/datum/element/ai_retaliate)
	give_hair()
	if(random)
		switch(rand(0,1))
			if(0)
				name = "duch: [pick(GLOB.first_names_male)] [pick(GLOB.last_names_male)]"
			if(1)
				name = "duch: [pick(GLOB.first_names_female)] [pick(GLOB.last_names_female)]"
	AddComponent(/datum/component/tracking_beacon, "ghost", null, null, TRUE, "#9e4d91", TRUE, TRUE)

/mob/living/basic/ghost/proc/give_hair()
	if(ghost_hair_style != null)
		ghost_hair = mutable_appearance('icons/mob/human_face.dmi', "hair_[ghost_hair_style]", -HAIR_LAYER)
		ghost_hair.alpha = 200
		ghost_hair.color = ghost_hair_color
		add_overlay(ghost_hair)
	if(ghost_facial_hair_style != null)
		ghost_facial_hair = mutable_appearance('icons/mob/human_face.dmi', "facial_[ghost_facial_hair_style]", -HAIR_LAYER)
		ghost_facial_hair.alpha = 200
		ghost_facial_hair.color = ghost_facial_hair_color
		add_overlay(ghost_facial_hair)

/datum/ai_controller/basic_controller/ghost
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
