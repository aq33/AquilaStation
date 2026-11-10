// AQUILA: port of BeeStation/BeeStation-Hornet code/modules/mob/living/basic/vermin/cockroach.dm (bee/master 0adf0fe9ae)
// Polish name, verbs and squash lines from our simple animal cockroach; ghosts can still take one over (Aquila).
/mob/living/basic/cockroach
	name = "karaluch"
	desc = "Na tej stacji aż roi się od robactwa."
	icon_state = "cockroach"
	icon_dead = "cockroach" //Make this work
	density = FALSE
	mob_biotypes = list(MOB_ORGANIC, MOB_BUG)
	mob_size = MOB_SIZE_TINY
	health = 1
	maxHealth = 1
	speed = 1.25
	can_be_held = TRUE
	gold_core_spawnable = FRIENDLY_SPAWN
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	ventcrawler = VENTCRAWLER_ALWAYS
	chat_color = "#BC7658"
	playable = TRUE
	should_talk = FALSE

	verb_say = "terkocze"
	verb_ask = "terkocze pytająco"
	verb_exclaim = "terkocze głośno"
	verb_yell = "terkocze głośno"
	response_help_continuous = "szturcha"
	response_disarm_continuous = "przegania"
	response_harm_continuous = "rozpłaszcza"
	speak_emote = list("terkocze")

	basic_mob_flags = DEL_ON_DEATH
	faction = list(FACTION_HOSTILE, FACTION_MAINT_CREATURES)
	// Cockroaches breathe anything, like our simple animal cockroach (Bee keeps the default oxygen needs)
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 270
	maximum_survivable_temperature = INFINITY

	ai_controller = /datum/ai_controller/basic_controller/cockroach

	///Are we squashable
	var/is_squashable = TRUE

/mob/living/basic/cockroach/strong
	is_squashable = FALSE

/mob/living/basic/cockroach/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/death_drops, list(/obj/effect/decal/cleanable/insectguts))
	if(is_squashable)
		AddComponent(/datum/component/squashable, squash_chance = 50, squash_damage = 1)

/mob/living/basic/cockroach/death(gibbed)
	if(SSticker.mode && SSticker.mode.station_was_nuked) //If the nuke is going off, then cockroaches are invincible. Keeps the nuke from killing them, cause cockroaches are immune to nukes.
		return
	..()

/mob/living/basic/cockroach/ex_act() //Explosions are a terrible way to handle a cockroach.
	return FALSE

/mob/living/basic/cockroach/attack_ghost(mob/dead/observer/user)
	. = ..()
	give_to_ghost(user)

/datum/ai_controller/basic_controller/cockroach
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_OWNER_SELF_HARM_RESPONSES = list(
			"*me z dezaprobatą macha czułkami.",
			"*me smutno terkocze."
		)
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/cockroach,
		/datum/ai_planning_subtree/find_and_hunt_target/cockroach,
	)

/datum/ai_planning_subtree/random_speech/cockroach
	speech_chance = 1
	emote_hear = list("terkocze.")

/datum/ai_planning_subtree/find_and_hunt_target/cockroach
	hunt_targets = list(/obj/effect/decal/cleanable/ants)
