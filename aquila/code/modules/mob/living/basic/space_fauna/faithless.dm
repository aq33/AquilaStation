// AQUILA: port of tgstation/tgstation code/modules/mob/living/basic/space_fauna/faithless.dm (tg 926bf40c5a)
// Replaces our simple animal Faithless (code/modules/mob/living/simple_animal/hostile/faithless.dm). Polish lines and
// stats of ours; from tg: it smashes the lights it sees, drags away the people it knocked out (mob_grabber), knocks
// people down now and then and, controlled by a player outside combat mode, pries airlocks open (door_pryer).

/mob/living/basic/faithless
	name = "Niewierny"
	desc = "Wiara Spełniacza Życzeń w ludzkość, wcielona."
	icon_state = "faithless"
	icon_living = "faithless"
	icon_dead = "faithless_dead"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	gender = MALE
	response_help_continuous = "przenika przez"
	response_disarm_continuous = "popycha"
	response_harm_continuous = "uderza"
	speed = 0
	maxHealth = 80
	health = 80
	spacewalk = TRUE

	obj_damage = 50
	melee_damage = 15
	attack_verb_continuous = "chwyta"
	attack_sound = 'sound/hallucinations/growl1.ogg'
	melee_attack_cooldown = 1 SECONDS
	speak_emote = list("warczy")

	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	minimum_survivable_temperature = 0

	faction = list("faithless")
	gold_core_spawnable = HOSTILE_SPAWN
	do_footstep = TRUE

	ai_controller = /datum/ai_controller/basic_controller/faithless

	/// What are the odds we paralyze a target on attack
	var/paralyze_chance = 12
	/// How long do we paralyze a target for if we attack them
	var/paralyze_duration = 2 SECONDS

/mob/living/basic/faithless/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/door_pryer)
	AddElement(/datum/element/mob_grabber, steal_from_others = FALSE)
	AddComponent(/datum/component/aggro_emote, emote_list = string_list(list("zawodzi")), emote_chance = 25)

/mob/living/basic/faithless/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if (!. || !isliving(target))
		return

	var/mob/living/living_target = target
	if (prob(paralyze_chance))
		living_target.Paralyze(paralyze_duration)
		living_target.visible_message(span_danger("[src] przewraca [target]!"), \
			span_userdanger("[src] cię przewraca!"))

/datum/ai_planning_subtree/random_speech/faithless
	speech_chance = 1
	emote_see = list("zawodzi.")

/datum/ai_controller/basic_controller/faithless
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS,
		BB_LOW_PRIORITY_HUNTING_TARGET = null, // lights
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/attack_obstacle_in_path/low_priority_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_and_hunt_target/look_for_light_fixtures,
		/datum/ai_planning_subtree/random_speech/faithless,
	)
