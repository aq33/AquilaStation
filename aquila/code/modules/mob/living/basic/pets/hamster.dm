// AQUILA: port of BeeStation/BeeStation-Hornet code/modules/mob/living/basic/pets/hamster.dm (BeeStation/BeeStation-Hornet#14771)
// Polish lines from our simple animal hamster; Vector keeps our extrapolator disease and his Polish admin message.
// Bee's Vector registered the contact spreading only when he rolled a disease; the same here (no other change).
#define ROUNDSTART_DISEASE_PROB 5
#define TRANSMISSION_PROBABILITY 20

/mob/living/basic/pet/hamster
	name = "\improper chomik"
	real_name = "chomik"
	desc = "To chomik."

	icon_state = "hamster"
	icon_living = "hamster"
	icon_dead = "hamster_dead"

	can_be_held = TRUE
	held_state = "hamster"
	worn_slot_flags = ITEM_SLOT_HEAD
	see_in_dark = 5

	speak_emote = list("piszczy", "syczy", "kwiczy")
	chat_color = "#D3B277"

	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	faction = list("hamster")
	density = FALSE
	pass_flags = PASSMOB
	mob_size = MOB_SIZE_SMALL
	ventcrawler = VENTCRAWLER_ALWAYS
	gold_core_spawnable = FRIENDLY_SPAWN
	butcher_results = list(/obj/item/food/meat/slab/hamster = 1)
	do_footstep = TRUE

	response_help_continuous = "głaszcze"
	response_disarm_continuous = "pstryka"
	response_harm_continuous = "gryzie"

	ai_controller = /datum/ai_controller/basic_controller/hamster

/mob/living/basic/pet/hamster/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)

/mob/living/basic/pet/hamster/vector //now also viro's source of a solitary, shitty starter disease
	name = "Vector"
	desc = "To chomik Vector. Na pewno nie jest źródłem śmiertelnych chorób."
	var/datum/disease/vector_disease
	/// AQUILA: the random advanced disease an extrapolator can take from Vector
	var/list/extrapolatordisease = list()

/mob/living/basic/pet/hamster/vector/Initialize(mapload)
	. = ..()
	var/datum/disease/advance/extrapolated = new /datum/disease/advance/random(rand(2, 5), 9, 1 + rand(1, 3), infected = src)
	extrapolatordisease += extrapolated
	if(!prob(ROUNDSTART_DISEASE_PROB))
		return

	var/disease_type = pick(/datum/disease/cold, /datum/disease/flu, /datum/disease/fluspanish)
	vector_disease = new disease_type()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

	message_admins("Vector na starcie rundy dostaje chorobę: [vector_disease.name]. Nie linczujcie wirusologa!")
	log_game("Vector was roundstart infected with [vector_disease.name].")

/mob/living/basic/pet/hamster/vector/extrapolator_act(mob/user, obj/item/extrapolator/E, scan = TRUE)
	if(!length(extrapolatordisease))
		return FALSE
	if(scan)
		E.scan(src, extrapolatordisease, user)
	else
		E.extrapolate(src, extrapolatordisease, user)
	return TRUE

/mob/living/basic/pet/hamster/vector/proc/on_entered(datum/source, atom/movable/thing, atom/oldloc)
	SIGNAL_HANDLER
	if(!isliving(thing) || isnull(vector_disease) || !prob(TRANSMISSION_PROBABILITY))
		return
	var/mob/living/poor_soul = thing
	if(!poor_soul.HasDisease(vector_disease)) // I'm not actually sure if this check is needed, but better to be safe than sorry
		poor_soul.ContactContractDisease(vector_disease)

/datum/ai_controller/basic_controller/hamster
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/random_speech/hamster,
	)

/datum/ai_planning_subtree/random_speech/hamster
	speech_chance = 1
	speak = list("Pi", "PIII!")
	emote_hear = list("piszczy.", "syczy.", "kwiczy.")
	emote_see = list("drepcze", "ogląda swoje pazurki", "turla się")

#undef ROUNDSTART_DISEASE_PROB
#undef TRANSMISSION_PROBABILITY
