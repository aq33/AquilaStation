// AQUILA: port of BeeStation/BeeStation-Hornet code/modules/mob/living/basic/vermin/lizard.dm (BeeStation/BeeStation-Hornet#14771, tg port)
// Polish lines from our simple animal lizard (the janitor's pet Wags-His-Tail on several ships). It hunts butterflies and
// cockroaches as before. Our old lizard had 5 health (Bee: 10) and its "Lizard" faction; no new "tongue" emote.
/*
* ## Lizards
*
* Green things that crawl around and eat bugs. Not to be confused with the human species lizardpersons, these are just small little fellas.
*/
/mob/living/basic/lizard
	name = "jaszczurka"
	desc = "Urocza, malutka jaszczurka."
	icon_state = "lizard"
	icon_living = "lizard"
	icon_dead = "lizard_dead"
	icon_gib = "lizard_gib"
	held_state = "lizard"
	speak_emote = list("syczy")
	health = 5
	maxHealth = 5
	faction = list(FACTION_LIZARD)
	attack_verb_continuous = "gryzie"
	melee_damage = 1
	response_help_continuous = "głaszcze"
	response_disarm_continuous = "przegania"
	response_harm_continuous = "depcze"
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST, MOB_REPTILE)
	gold_core_spawnable = FRIENDLY_SPAWN
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	ventcrawler = VENTCRAWLER_ALWAYS
	chat_color = "#64F88A"
	ai_controller = /datum/ai_controller/basic_controller/lizard

	/// Typecache of things that we seek out to eat. Yummy.
	var/static/list/edibles = typecacheof(list(
		/mob/living/basic/butterfly,
		/mob/living/basic/cockroach,
	))

/mob/living/basic/lizard/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/pet_bonus, "z zadowoleniem wystawia język!")
	AddElement(/datum/element/basic_eating, heal_amt = 2, food_types = edibles)
	ai_controller.set_blackboard_key(BB_BASIC_FOODS, edibles)

/datum/ai_controller/basic_controller/lizard
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/lizard,
	)

/datum/ai_planning_subtree/random_speech/lizard
	speech_chance = 1
	emote_hear = list("tupie dookoła.", "cicho syczy.")
	emote_see = list("wystawia język.", "przekrzywia głowę.", "robi obrót.")
