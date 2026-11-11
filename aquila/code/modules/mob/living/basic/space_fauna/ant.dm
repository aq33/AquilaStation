// AQUILA: port of tgstation/tgstation code/modules/mob/living/basic/space_fauna/ant.dm (tg 926bf40c5a)
// Replaces our simple animal giant ant (code/modules/mob/living/simple_animal/hostile/ant.dm). Polish lines, health and
// damage of ours; from tg: it bites back whoever hurts it (fleeing when it cannot), clacks happily when petted.
// Not ported: the allergic bite (we have no allergies) and the "clack" emote (pet_bonus prints the line itself).

/mob/living/basic/ant
	name = "olbrzymia mrówka"
	desc = "Wijąca się masa mrówek, sklejona w uroczego zwierzaka!"
	icon = 'icons/mob/pets.dmi'
	icon_state = "ant"
	icon_living = "ant"
	icon_dead = "ant_dead"
	speak_emote = list("brzęczy", "terkocze")
	gender = PLURAL // We are Ven-ant
	pass_flags = PASSTABLE
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = list(MOB_ORGANIC, MOB_BUG)
	see_in_dark = 6
	obj_damage = 5
	melee_damage = 7.5 //Higher health than a base carp, so much lower damage.
	attack_verb_continuous = "gryzie"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	butcher_results = list(/obj/effect/decal/cleanable/ants = 3) //It's just a bunch of ants glued together into a larger ant
	response_help_continuous = "głaszcze"
	response_disarm_continuous = "delikatnie odsuwa na bok"
	response_harm_continuous = "kopie"
	gold_core_spawnable = FRIENDLY_SPAWN
	faction = list("neutral")
	health = 100
	maxHealth = 100
	light_range = 1.5 // Bioluminescence!
	light_color = "#d43229" // The ants that comprise the giant ant still glow red despite the sludge.
	minimum_survivable_temperature = 200
	maximum_survivable_temperature = 400
	ventcrawler = VENTCRAWLER_ALWAYS
	do_footstep = TRUE

	ai_controller = /datum/ai_controller/basic_controller/ant

/mob/living/basic/ant/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/pet_bonus, "radośnie klekocze!")
	AddElement(/datum/element/ai_retaliate)

/datum/ai_planning_subtree/random_speech/ant
	speech_chance = 1
	speak = list("BZZZZT!", "CHTCHTCHT!", "Bzzz", "ChtChtCht")
	emote_hear = list("brzęczy.", "klekocze.")
	emote_see = list("potrząsa głową.", "porusza czułkami.")

/datum/ai_controller/basic_controller/ant
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/ant,
	)
