// AQUILA: port of tgstation code/modules/mob/living/basic/lavaland/legion/legion_ai.dm (tg 926bf40c5a). No target priority
// strategies here (tg's mining one prefers NODE drones and whoever attacked a mob nearby), no radio speech and no lines
// copied from the corpse inside.

/// Keep away and launch skulls at every opportunity, prioritising injured allies
/datum/ai_controller/basic_controller/legion
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/legion,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_AGGRO_RANGE = 5, // Unobservant
		BB_RANGED_SKIRMISH_MIN_DISTANCE = 4,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 6,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/call_reinforcements/mining,
		/datum/ai_planning_subtree/random_speech/legion,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/maintain_distance,
		/datum/ai_planning_subtree/targeted_mob_ability,
	)

/// Chase and attack whatever we are targeting, if it's friendly we will heal them
/datum/ai_controller/basic_controller/legion_brood
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/legion,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/// Target nearby friendlies if they are hurt (and are not themselves Legions)
/datum/targeting_strategy/basic/legion

/datum/targeting_strategy/basic/legion/faction_check(datum/ai_controller/controller, mob/living/living_mob, mob/living/the_target)
	if (!living_mob.faction_check_mob(the_target, exact_match = check_factions_exactly))
		return FALSE
	if (istype(the_target, living_mob.type))
		return TRUE
	var/atom/created_by = living_mob.ai_controller.blackboard[BB_LEGION_BROOD_CREATOR]
	if (!QDELETED(created_by) && istype(the_target, created_by.type))
		return TRUE
	return the_target.stat == DEAD || the_target.health >= the_target.maxHealth

/// Make spooky sounds
/datum/ai_planning_subtree/random_speech/legion
	speech_chance = 1
	speak = list("Chodź...", "Legion...", "Dlaczego...?")
	emote_hear = list("jęczy.", "zawodzi.", "skomli.")
	emote_see = list("drga.", "wzdryga się.")
