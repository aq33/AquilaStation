// AQUILA: port of BeeStation/BeeStation-Hornet code/modules/mob/living/basic/vermin/mothroach.dm (bee/master 0adf0fe9ae)
// Polish name and lines from our simple animal mothroach; resting sprite through update_resting() like before.
/mob/living/basic/mothroach
	name = "ćmokaraluch"
	desc = "Pradawny przodek ćmy, który zaskakująco przypomina krzyżówkę ćmy z karaluchem."
	icon_state = "mothroach"
	icon_living = "mothroach"
	icon_dead = "mothroach_dead"
	held_state = "mothroach"
	held_lh = 'icons/mob/pets_held_lh.dmi'
	held_rh = 'icons/mob/pets_held_rh.dmi'
	head_icon = 'icons/mob/pets_held.dmi'
	butcher_results = list(/obj/item/food/meat/slab/mothroach = 3, /obj/item/stack/sheet/animalhide/mothroach = 1)
	mob_biotypes = list(MOB_ORGANIC, MOB_BUG)
	mob_size = MOB_SIZE_SMALL
	health = 25
	maxHealth = 25
	speed = 1.25
	gold_core_spawnable = FRIENDLY_SPAWN
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	ventcrawler = VENTCRAWLER_ALWAYS
	attacked_sound = 'sound/voice/moth/scream_moth.ogg'

	verb_say = "trzepocze"
	verb_ask = "trzepocze pytająco"
	verb_exclaim = "trzepocze głośno"
	verb_yell = "trzepocze głośno"
	speak_emote = list("trzepocze")
	response_disarm_continuous = "przegania"
	response_harm_continuous = "uderza"
	response_help_continuous = "głaszcze"

	faction = list(FACTION_NEUTRAL)

	ai_controller = /datum/ai_controller/basic_controller/mothroach

/mob/living/basic/mothroach/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/pet_bonus, "radośnie piszczy!", emote_sound = 'sound/voice/moth/scream_moth.ogg')

/mob/living/basic/mothroach/update_resting()
	. = ..()
	if(stat == DEAD)
		return
	if(resting)
		icon_state = "[icon_living]_rest"
	else
		icon_state = "[icon_living]"

/datum/ai_controller/basic_controller/mothroach
	blackboard = list()

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/mothroach,
		/datum/ai_planning_subtree/find_and_hunt_target/mothroach,
	)

/datum/ai_planning_subtree/random_speech/mothroach
	speech_chance = 2
	emote_hear = list("trzepocze.", "trzepocze skrzydełkami.", "gwałtownie trzepocze skrzydełkami!")

/datum/ai_planning_subtree/find_and_hunt_target/mothroach
	hunt_range = 3
	hunt_targets = list(/obj/effect/decal/cleanable/cobweb, /obj/structure/spider/stickyweb)
	hunting_behavior = /datum/ai_behavior/hunt_target/mothroach

/datum/ai_behavior/hunt_target/mothroach
	hunt_cooldown = 25 SECONDS
	hunt_emote = "skubie"
