// AQUILA: port of tgstation/tgstation code/modules/mob/living/basic/farm_animals/deer/deer.dm and deer_ai.dm (tg 926bf40c5a)
// Replaces our simple animal deer of the grasslands_hunt bitrunning domain. That one fled with BYOND's walk_away(), which
// nothing ever cancelled, so a dead, stunned or pulled deer kept running away from the hunter.
// Changes against tg (decision D9): the deer flees from any conscious human it sees (as our old deer did), not only from
// whoever hit it, through simple_find_nearest_target_to_flee + flee_target, which end with the AI when the deer dies.
// Polish lines and the icon of our old deer; our health, damage and meat (no grassfed slab). No ice deer (no ice moon).

/mob/living/basic/deer
	name = "sarna"
	desc = "Łagodne, spokojne zwierzę leśne. Jak to się znalazło w kosmosie?"
	icon = 'aquila/icons/mob/bitrunning_mobs.dmi'
	icon_state = "deer-doe"
	icon_living = "deer-doe"
	icon_dead = "deer-doe-dead"
	gender = FEMALE
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	speak_emote = list("chrząka", "cicho chrząka")
	butcher_results = list(/obj/item/food/meat/slab = 3)
	response_help_continuous = "głaszcze"
	response_disarm_continuous = "delikatnie odpycha"
	response_harm_continuous = "kopie"
	attack_verb_continuous = "bodzie"
	attack_sound = 'sound/weapons/punch1.ogg'
	health = 75
	maxHealth = 75
	melee_damage = 5
	gold_core_spawnable = FRIENDLY_SPAWN
	do_footstep = TRUE
	ai_controller = /datum/ai_controller/basic_controller/deer
	/// Things that will scare us into being stationary. Vehicles are scary to deers because they might have headlights.
	var/static/list/stationary_scary_things = list(/obj/vehicle)

/mob/living/basic/deer/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	var/time_to_freeze_for = (rand(5, 10) SECONDS)
	ai_controller.set_blackboard_key(BB_STATIONARY_SECONDS, time_to_freeze_for)
	ai_controller.set_blackboard_key(BB_STATIONARY_COOLDOWN, (time_to_freeze_for * (rand(3, 5))))
	ai_controller.set_blackboard_key(BB_STATIONARY_TARGETS, typecacheof(stationary_scary_things))

/datum/ai_controller/basic_controller/deer
	blackboard = list(
		BB_STATIONARY_MOVE_TO_TARGET = TRUE,
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/deer_threats,
		BB_AGGRO_RANGE = 5,
		BB_BASIC_MOB_FLEE_DISTANCE = 7,
	)
	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/deer,
		/datum/ai_planning_subtree/stare_at_thing,
		/datum/ai_planning_subtree/simple_find_nearest_target_to_flee, // AQUILA: humans in sight and attackers, tg: attackers only
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/rest_at_home,
		/datum/ai_planning_subtree/play_with_friends,
		/datum/ai_planning_subtree/find_and_hunt_target/mark_territory,
		/datum/ai_planning_subtree/find_and_hunt_target/graze,
		/datum/ai_planning_subtree/find_and_hunt_target/drink_water,
	)

/datum/ai_planning_subtree/random_speech/deer
	speech_chance = 1
	emote_see = list("strzyże uszami.", "skubie trawę.", "rozgląda się czujnie.")

/**
 * AQUILA: what the deer runs from: any conscious human it can see (our old deer) and anything that hurt it (tg).
 * Humans share the deer's neutral faction, so the faction check is off.
 */
/datum/targeting_strategy/basic/deer_threats

/datum/targeting_strategy/basic/deer_threats/can_attack(mob/living/living_mob, atom/the_target, vision_range)
	if(!isliving(the_target))
		return FALSE
	if(!ishuman(the_target) && !(the_target in living_mob.ai_controller?.blackboard[BB_BASIC_MOB_RETALIATE_LIST]))
		return FALSE
	return ..()

/datum/targeting_strategy/basic/deer_threats/faction_check(datum/ai_controller/controller, mob/living/living_mob, mob/living/the_target)
	return FALSE

///subtree to go around drinking water
/datum/ai_planning_subtree/find_and_hunt_target/drink_water
	target_key = BB_DEER_WATER_TARGET
	finding_behavior = /datum/ai_behavior/find_and_set/in_list/turf_types
	hunting_behavior = /datum/ai_behavior/hunt_target/drink_water
	hunt_targets = list(/turf/open/water)
	hunt_range = 7
	hunt_chance = 5

/datum/ai_behavior/hunt_target/drink_water
	always_reset_target = TRUE
	hunt_cooldown = 20 SECONDS

/datum/ai_behavior/hunt_target/drink_water/target_caught(mob/living/hunter, atom/hunted)
	var/static/list/possible_emotes = list("pije wodę!", "tańczy w wodzie!", "radośnie pluska się w wodzie!")
	hunter.manual_emote(pick(possible_emotes))

///subtree to go around grazing
/datum/ai_planning_subtree/find_and_hunt_target/graze
	target_key = BB_DEER_GRASS_TARGET
	finding_behavior = /datum/ai_behavior/find_and_set/in_list/turf_types
	hunting_behavior = /datum/ai_behavior/hunt_target/eat_grass
	hunt_targets = list(/turf/open/floor/grass) // AQUILA: we have no /turf/open/misc/grass
	hunt_range = 7
	hunt_chance = 45

/datum/ai_behavior/hunt_target/eat_grass
	always_reset_target = TRUE
	hunt_cooldown = 15 SECONDS

/datum/ai_behavior/hunt_target/eat_grass/target_caught(mob/living/hunter, atom/hunted)
	var/static/list/possible_emotes = list("je trawę!", "pałaszuje trawę!", "przeżuwa trawę!")
	hunter.manual_emote(pick(possible_emotes))

///subtree to go around playing with other deers
/datum/ai_planning_subtree/play_with_friends

/datum/ai_planning_subtree/play_with_friends/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/static/list/emote_list = list("bawi się z", "tańczy z", "świętuje z")
	var/static/list/friend_types = typecacheof(list(/mob/living/basic/deer))
	if(controller.blackboard_key_exists(BB_DEER_PLAYFRIEND))
		controller.queue_behavior(/datum/ai_behavior/emote_on_target/deer_play, BB_DEER_PLAYFRIEND, emote_list)
	if(DT_PROB(3, delta_time))
		controller.queue_behavior(/datum/ai_behavior/find_hunt_target/valid_deer, BB_DEER_PLAYFRIEND, friend_types)
		return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/emote_on_target/deer_play

/datum/ai_behavior/emote_on_target/deer_play/run_emote(mob/living/living_pawn, atom/target, list/emote_list)
	. = ..()
	living_pawn.spin(spintime = 4, speed = 1)

/datum/ai_behavior/find_hunt_target/valid_deer
	hunts_mobs_only = TRUE

/datum/ai_behavior/find_hunt_target/valid_deer/valid_dinner(mob/living/source, mob/living/deer, radius, datum/ai_controller/controller, delta_time)
	if(deer == source) // AQUILA: hearers() lists the deer itself
		return FALSE
	if(deer.stat == DEAD)
		return FALSE
	if(!can_see(source, deer, radius))
		return FALSE
	deer.ai_controller?.set_blackboard_key(BB_DEER_PLAYFRIEND, source)
	return TRUE

///subtree to mark trees as territories
/datum/ai_planning_subtree/find_and_hunt_target/mark_territory
	target_key = BB_DEER_TREE_TARGET
	finding_behavior = /datum/ai_behavior/find_hunt_target
	hunting_behavior = /datum/ai_behavior/hunt_target/mark_territory
	hunt_targets = list(/obj/structure/flora/tree)
	hunt_range = 7
	hunt_chance = 75

/datum/ai_behavior/hunt_target/mark_territory
	always_reset_target = TRUE
	hunt_cooldown = 15 SECONDS

/datum/ai_behavior/hunt_target/mark_territory/target_caught(mob/living/hunter, atom/hunted)
	hunter.manual_emote("znakuje kopytami [hunted]!")
	hunter.ai_controller.set_blackboard_key(BB_DEER_TREEHOME, hunted)

/datum/ai_planning_subtree/find_and_hunt_target/mark_territory/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(controller.blackboard_key_exists(BB_DEER_TREEHOME)) //already found our home, abort!
		return
	return ..()

/datum/ai_planning_subtree/rest_at_home

/datum/ai_planning_subtree/rest_at_home/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(controller.blackboard[BB_DEER_RESTING] > world.time) //we're resting for now, nothing more to do
		return SUBTREE_RETURN_FINISH_PLANNING
	if(!controller.blackboard_key_exists(BB_DEER_TREEHOME) || controller.blackboard[BB_DEER_NEXT_REST_TIMER] > world.time)
		return
	controller.queue_behavior(/datum/ai_behavior/return_home, BB_DEER_TREEHOME)

/datum/ai_behavior/return_home
	required_distance = 0
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	///minimum time till next rest
	var/minimum_time = 2 MINUTES
	///maximum time till next rest
	var/maximum_time = 4 MINUTES

/datum/ai_behavior/return_home/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	var/list/possible_turfs = get_adjacent_open_turfs(target)
	shuffle_inplace(possible_turfs)
	for(var/turf/possible_turf as anything in possible_turfs)
		if(!is_blocked_turf(possible_turf)) // AQUILA: our is_blocked_turf() is a global proc
			set_movement_target(controller, possible_turf)
			return TRUE
	return FALSE

/datum/ai_behavior/return_home/perform(delta_time, datum/ai_controller/controller, target_key)
	var/mob/living/living_pawn = controller.pawn
	var/static/list/possible_emotes = list("daje odpocząć nogom...", "ziewa i ucina sobie drzemkę...", "zwija się w kłębek i odpoczywa...")
	living_pawn.manual_emote(pick(possible_emotes))
	controller.set_blackboard_key(BB_DEER_RESTING, world.time + 15 SECONDS)
	controller.set_blackboard_key(BB_DEER_NEXT_REST_TIMER, world.time + rand(minimum_time, maximum_time))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
