// AQUILA: port of tgstation/tgstation code/modules/mob/living/basic/ruin_defender/zombie.dm (tg 926bf40c5a)
// Replaces our simple animal zombie (code/modules/mob/living/simple_animal/hostile/zombie.dm). Kept from ours: the look
// built from a zombie human in a job outfit (`zombiejob`, mapped too; tg's dynamic human appearance is not here), the zombie
// corpse dropped on death instead of tg's remains, health, damage and speed. The "hugbox" zombie of the maintenance traps
// lives here now (was in mainttraps.dm). tg's rotten zombie keeps its "stupid" controller (no smashing obstacles).

/// Everyone knows what a zombie is
/mob/living/basic/zombie
	name = "powłóczące nogami zwłoki"
	desc = "Gdy w piekle zabraknie miejsca, umarli będą chodzić po kosmosie."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "zombie"
	icon_living = "zombie"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	maxHealth = 100
	health = 100
	melee_damage = 21
	attack_verb_continuous = "gryzie"
	attack_sound = 'sound/hallucinations/growl1.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	combat_mode = TRUE
	status_flags = CANPUSH
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	faction = list("hostile")
	basic_mob_flags = DEL_ON_DEATH
	mobchatspan = "bartender"
	discovery_points = 3000
	ai_controller = /datum/ai_controller/basic_controller/zombie
	/// Job whose outfit the zombie wears (job title, as on maps)
	var/zombiejob = JOB_NAME_MEDICALDOCTOR
	/// Chance to spread zombieism on hit
	/// Only for admins because we don't actually want romerol to get into the round from space ruins generally speaking
	var/infection_chance = 0
	/// The zombie human dropped when this one dies
	var/obj/effect/mob_spawn/human/corpse/delayed/corpse

/mob/living/basic/zombie/Initialize(mapload)
	. = ..()
	setup_visuals()

/mob/living/basic/zombie/Destroy()
	QDEL_NULL(corpse)
	return ..()

/mob/living/basic/zombie/proc/setup_visuals()
	var/datum/character_save/CS = new
	CS.pref_species = new /datum/species/zombie
	CS.be_random_body = TRUE
	var/datum/job/J = SSjob.GetJob(zombiejob)
	if(!J) // maps var-edit zombiejob with old English titles that no longer exist (localized or renamed jobs)
		zombiejob = initial(zombiejob)
		J = SSjob.GetJob(zombiejob)
	var/datum/outfit/O
	if(J.outfit)
		O = new J.outfit
		//They have claws now.
		O.r_hand = null
		O.l_hand = null

	var/icon/P = get_flat_human_icon("zombie_[zombiejob]", J , CS, "zombie", outfit_override = O)
	icon = P
	corpse = new(src)
	corpse.outfit = O
	corpse.mob_species = /datum/species/zombie
	corpse.mob_name = name

/mob/living/basic/zombie/death(gibbed)
	if(corpse)
		var/obj/effect/mob_spawn/human/corpse/delayed/dropped = corpse
		corpse = null
		dropped.forceMove(drop_location())
		dropped.create()
	return ..()

/mob/living/basic/zombie/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if (!. || !infection_chance || !ishuman(target) || !prob(infection_chance))
		return
	try_to_zombie_infect(target)

/// Weaker variant used if you want to put more of them in one place, won't attack obstacles
/mob/living/basic/zombie/rotten
	name = "gnijące zwłoki"
	desc = "Ten nieumarły potwór jest mocno rozłożony."
	health = 60
	maxHealth = 60
	melee_damage = 11
	ai_controller = /datum/ai_controller/basic_controller/zombie/stupid

/mob/living/basic/zombie/rotten/assistant
	zombiejob = JOB_NAME_ASSISTANT

/// Zombie of the maintenance traps (trickyspawner): weaker bite, leaves the knocked out alone
/mob/living/basic/zombie/hugbox
	melee_damage = 12 //zombies have a base of 21, a bit much
	mobchatspan = "chaplain"
	discovery_points = 1000
	ai_controller = /datum/ai_controller/basic_controller/zombie/hugbox

/datum/ai_planning_subtree/random_speech/zombie
	speech_chance = 1
	emote_hear = list("jęczy.", "stęka.", "charczy.")
	emote_see = list("drga.", "wzdryga się.")

/datum/ai_controller/basic_controller/zombie
	blackboard = list(
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS, // AQUILA: braains (our stat_attack), tg HARD_CRIT
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/random_speech/zombie,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_controller/basic_controller/zombie/stupid
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/zombie,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_controller/basic_controller/zombie/hugbox
	blackboard = list(
		BB_TARGET_MINIMUM_STAT = CONSCIOUS,
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
