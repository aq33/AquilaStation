// AQUILA: port of tgstation code/modules/mob/living/basic/space_fauna/hivebot/ (_hivebot.dm, hivebot_subtree.dm,
// hivebot_behavior.dm) from the last revision before behaviour trees (tg 926bf40c5a), on the Bee AI core.
// Polish names and lines of our simple animal hivebots. Changes against tg:
// - no hivebot mechanic (decision D12: new content, machine repair and the foam wall spell);
// - no appearance_on_aggro: our icons/mob/hivebot.dmi has no "*_attack" states;
// - the ranged hivebots fire the projectile directly like our simple animal (no casings left on the floor);
// - kept from our simple animal: the gold core spawn of every hivebot, ghost possession (playable, D14) and silence
//   (should_talk = FALSE); the AI binary chatter of hive_communicate is still said (relay_message lets the AI speak).

/// Blackboard key: the hivebot we go to beep at
#define BB_HIVE_PARTNER "BB_hive_partner"

/obj/item/projectile/hivebotbullet
	damage = 10
	damage_type = BRUTE

/mob/living/basic/hivebot
	name = "hivebot"
	hardattacks = TRUE // nasty blocks (energy sword, chainsaw) do not hurt it, as our simple animal
	desc = "Mały robot."
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "basic"
	icon_living = "basic"
	icon_dead = "basic"
	basic_mob_flags = DEL_ON_DEATH
	gender = NEUTER
	mob_biotypes = list(MOB_ROBOTIC)

	health = 15
	maxHealth = 15
	healable = FALSE
	melee_damage = 3
	attack_verb_continuous = "drapie"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	speak_emote = list("stwierdza")

	faction = list("hivebot")
	death_message = "rozpada się na kawałki!"
	gold_core_spawnable = HOSTILE_SPAWN
	do_footstep = TRUE
	playable = TRUE
	should_talk = FALSE

	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	ai_controller = /datum/ai_controller/basic_controller/hivebot
	/// Does this type do ranged attacks?
	var/ranged_attacker = FALSE
	/// How often can we shoot?
	var/ranged_attack_cooldown = 3 SECONDS

/mob/living/basic/hivebot/Initialize(mapload)
	. = ..()
	var/static/list/death_loot = list(/obj/effect/decal/cleanable/robot_debris)
	AddElement(/datum/element/death_drops, death_loot)
	find_candidates()
	if(!ranged_attacker)
		return
	AddComponent(/datum/component/ranged_attacks, projectile_type = /obj/item/projectile/hivebotbullet, cooldown_time = ranged_attack_cooldown)

/mob/living/basic/hivebot/attack_ghost(mob/dead/observer/user)
	. = ..()
	give_to_ghost(user)

/mob/living/basic/hivebot/death(gibbed)
	do_sparks(3, TRUE, src)
	return ..()

/mob/living/basic/hivebot/range
	name = "hivebot"
	desc = "Niewielki robot. Ten jest uzbrojony!"
	icon_state = "ranged"
	icon_living = "ranged"
	icon_dead = "ranged"
	ranged_attacker = TRUE
	ai_controller = /datum/ai_controller/basic_controller/hivebot/ranged

/mob/living/basic/hivebot/rapid
	icon_state = "ranged"
	icon_living = "ranged"
	icon_dead = "ranged"
	ranged_attacker = TRUE
	ai_controller = /datum/ai_controller/basic_controller/hivebot/ranged/rapid
	ranged_attack_cooldown = 1.5 SECONDS

/mob/living/basic/hivebot/strong
	name = "silny hivebot"
	icon_state = "strong"
	icon_living = "strong"
	icon_dead = "strong"
	desc = "Robot. Ten jest uzbrojony i wygląda na twardego!"
	health = 80
	maxHealth = 80
	ranged_attacker = TRUE
	ai_controller = /datum/ai_controller/basic_controller/hivebot/ranged

/datum/ai_controller/basic_controller/hivebot
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/hive_communicate,
	)

/datum/ai_controller/basic_controller/hivebot/ranged
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/hivebot,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/hive_communicate,
	)

/datum/ai_controller/basic_controller/hivebot/ranged/rapid
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/hivebot_rapid,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/hive_communicate,
	)

/datum/ai_planning_subtree/basic_ranged_attack_subtree/hivebot
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/hivebot

/datum/ai_planning_subtree/basic_ranged_attack_subtree/hivebot_rapid
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/hivebot_rapid

/datum/ai_behavior/basic_ranged_attack/hivebot
	action_cooldown = 3 SECONDS
	avoid_friendly_fire = TRUE

/datum/ai_behavior/basic_ranged_attack/hivebot_rapid
	action_cooldown = 1.5 SECONDS
	avoid_friendly_fire = TRUE

/// Now and then a hivebot walks up to another one and beeps binary at it
/datum/ai_planning_subtree/hive_communicate
	/// Chance to go and relay a message
	var/relay_chance = 10

/datum/ai_planning_subtree/hive_communicate/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(!DT_PROB(relay_chance, delta_time))
		return
	if(controller.blackboard_key_exists(BB_HIVE_PARTNER))
		controller.queue_behavior(/datum/ai_behavior/relay_message, BB_HIVE_PARTNER)
		return SUBTREE_RETURN_FINISH_PLANNING
	controller.queue_behavior(/datum/ai_behavior/find_and_set/hive_partner, BB_HIVE_PARTNER, /mob/living/basic/hivebot)

/datum/ai_behavior/find_and_set/hive_partner

/datum/ai_behavior/find_and_set/hive_partner/search_tactic(datum/ai_controller/controller, locate_path, search_range = 10)
	var/mob/living/living_pawn = controller.pawn
	var/list/hive_partners = list()
	for(var/mob/living/target in oview(search_range, living_pawn))
		if(!istype(target, locate_path))
			continue
		if(target.stat == DEAD)
			continue
		hive_partners += target
	if(length(hive_partners))
		return pick(hive_partners)

/// Goes to another hivebot and beeps a few binary digits at it
/datum/ai_behavior/relay_message
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	/// Length of the message we will relay
	var/length_of_message = 4

/datum/ai_behavior/relay_message/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/relay_message/perform(delta_time, datum/ai_controller/controller, target_key)
	var/mob/living/target = controller.blackboard[target_key]
	var/mob/living/living_pawn = controller.pawn
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/message_relayed = ""
	for(var/i in 1 to length_of_message)
		message_relayed += prob(50) ? "1" : "0"
	// AQUILA: silent mobs (should_talk = FALSE, against possessed players chatting) still beep through their AI
	var/could_talk = living_pawn.should_talk
	living_pawn.should_talk = TRUE
	INVOKE_ASYNC(living_pawn, TYPE_PROC_REF(/atom/movable, say), message_relayed, null, list(), TRUE, null, FALSE, "AI Controller")
	living_pawn.should_talk = could_talk
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/relay_message/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)
