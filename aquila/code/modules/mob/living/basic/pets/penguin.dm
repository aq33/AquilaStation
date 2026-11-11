// AQUILA: port of BeeStation/BeeStation-Hornet code/modules/mob/living/basic/pets/penguin/penguin.dm and penguin_ai.dm
// (BeeStation/BeeStation-Hornet#14771, tg port). Polish lines from our simple animal penguins. Changes against Bee:
// - waddling through our /datum/component/waddling (decision D13: no waddling element swap), no pet cult (D10);
// - penguin chicks grow into emperor penguins (one in six into the shamebrero one), mapped chicks do not (as in Bee);
// - the old cold tolerance (minbodytemp 0) and butcher results stay; no new "honk" emote, petting shows a Polish line.
/mob/living/basic/pet/penguin
	icon = 'icons/mob/penguins.dmi'
	gender = FEMALE

	speak_emote = list("skrzeczy", "gęga")
	response_help_continuous = "głaszcze"
	response_disarm_continuous = "pstryka"
	response_harm_continuous = "kopie"

	faction = list("penguin")
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	see_in_dark = 5
	minimum_survivable_temperature = 0
	butcher_results = list(/obj/item/organ/ears/penguin = 1, /obj/item/food/meat/slab/penguin = 3)
	chat_color = "#81D9FF"
	do_footstep = TRUE
	ai_controller = /datum/ai_controller/basic_controller/penguin

/mob/living/basic/pet/penguin/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/wears_collar)
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/ai_flee_while_injured)
	AddElement(/datum/element/pet_bonus, "radośnie gęga!")
	AddComponent(/datum/component/waddling)

/mob/living/basic/pet/penguin/emperor
	name = "pingwin cesarski"
	real_name = "pingwin"
	desc = "Cesarz wszystkiego, na co spojrzy."
	icon_state = "penguin"
	icon_living = "penguin"
	icon_dead = "penguin_dead"
	gold_core_spawnable = FRIENDLY_SPAWN

/mob/living/basic/pet/penguin/emperor/shamebrero
	name = "pingwin w hańbrero"
	desc = "Hańba wszystkiego, na co spojrzy."
	icon_state = "penguin_shamebrero"
	icon_living = "penguin_shamebrero"
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/basic/pet/penguin/baby
	name = "pisklę pingwina"
	real_name = "pingwin"
	desc = "Nie lata i ledwo się kołysze, a jednak jest księciem wszystkich piskląt."
	icon_state = "penguin_baby"
	icon_living = "penguin_baby"
	icon_dead = "penguin_baby_dead"
	density = FALSE
	pass_flags = PASSMOB
	mob_size = MOB_SIZE_SMALL
	butcher_results = list(/obj/item/organ/ears/penguin = 1, /obj/item/food/meat/slab/penguin = 1)
	ai_controller = /datum/ai_controller/basic_controller/penguin/baby
	///will it grow up?
	var/can_grow_up = TRUE

/mob/living/basic/pet/penguin/baby/Initialize(mapload)
	. = ..()
	if(!can_grow_up)
		return
	var/list/weight_mobtypes = list(
		/mob/living/basic/pet/penguin/emperor = 5,
		/mob/living/basic/pet/penguin/emperor/shamebrero = 1,
	)
	var/grown_type = pick_weight(weight_mobtypes)
	AddComponent(\
		/datum/component/growth_and_differentiation,\
		growth_time = null,\
		growth_path = grown_type,\
		growth_probability = 100,\
		lower_growth_value = 0.5,\
		upper_growth_value = 1,\
		signals_to_kill_on = list(COMSIG_MOB_CLIENT_LOGIN),\
		optional_checks = CALLBACK(src, PROC_REF(ready_to_grow)),\
	)

/mob/living/basic/pet/penguin/baby/proc/ready_to_grow()
	return (stat == CONSCIOUS) && !istype(loc, /obj/item/clothing/head/mob_holder)

/mob/living/basic/pet/penguin/baby/permanent
	can_grow_up = FALSE

/datum/ai_controller/basic_controller/penguin
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/random_speech/penguin,
	)

///ai controller for the baby penguin
/datum/ai_controller/basic_controller/penguin/baby
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_FIND_MOM_TYPES = list(/mob/living/basic/pet/penguin),
		BB_IGNORE_MOM_TYPES = list(/mob/living/basic/pet/penguin/baby),
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/look_for_adult,
		/datum/ai_planning_subtree/random_speech/penguin/baby,
	)

/datum/ai_planning_subtree/random_speech/penguin
	speech_chance = 1
	speak = list("Gah Gah!", "NOOT NOOT!", "NOOT!", "Noot", "noot", "Prah!", "Grah!")
	emote_hear = list("skrzeczy!", "gęga!", "nootuje.", "NOOTUJE!")
	emote_see = list("potrząsa dziobem.", "trzepocze skrzydłami.", "czyści pióra.")

/datum/ai_planning_subtree/random_speech/penguin/baby
	speak = list("gah", "noot noot", "noot!", "noot", "squeee!", "noo!")
