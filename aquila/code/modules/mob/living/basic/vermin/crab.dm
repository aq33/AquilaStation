// AQUILA: port of BeeStation/BeeStation-Hornet code/modules/mob/living/basic/vermin/crab.dm (BeeStation/BeeStation-Hornet#14771, tg port)
// Polish lines from our simple animal crabs. Changes against Bee:
// - no crab speech replacements (the json replaces English words, our chat is Polish) and no swimming (go_for_swim needs tg water);
// - sideways walking through a Move() override (we have no move loop signals for Bee's element);
// - Coffee keeps her capital path (admin "make crab" buttons, maps), the evil crab stays hostile-spawnable as before.
//Look Sir, free crabs!
/mob/living/basic/crab
	name = "krab"
	desc = "Darmowe kraby!"
	icon_state = "crab"
	icon_living = "crab"
	icon_dead = "crab_dead"

	held_state = "crab"
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD

	butcher_results = list(/obj/item/food/meat/rawcrab = 2)

	speak_emote = list("klika")
	response_help_continuous = "głaszcze"
	response_disarm_continuous = "delikatnie odsuwa na bok"
	response_harm_continuous = "depcze"
	friendly_verb_continuous = "szczypie"

	gold_core_spawnable = FRIENDLY_SPAWN
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	ventcrawler = VENTCRAWLER_ALWAYS
	chat_color = "#FFA656"
	mobchatspan = "blob"

	attack_verb_continuous = "szczypie"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	melee_damage = 2

	ai_controller = /datum/ai_controller/basic_controller/crab

/mob/living/basic/crab/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/tiny_mob_hunter, MOB_SIZE_TINY)
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/ai_flee_while_injured)

//COFFEE! SQUEEEEEEEEE!
/mob/living/basic/crab/Coffee
	name = "Coffee"
	real_name = "Coffee"
	desc = "To Coffee, ten drugi zwierzak!"
	gender = FEMALE
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/crab/evil
	name = "zły krab"
	real_name = "zły krab"
	desc = "Niepokojący, prawda? Na pewno knuje coś nikczemnego..."
	icon_state = "evilcrab"
	icon_living = "evilcrab"
	icon_dead = "evilcrab_dead"
	held_state = "evilcrab"
	response_help_continuous = "szturcha"
	response_disarm_continuous = "popycha"
	gold_core_spawnable = HOSTILE_SPAWN

/mob/living/basic/crab/kreb
	name = "Kreb"
	desc = "To prawdziwy krab. Pozostałe kraby to tylko przebrane żarłoczki samce!"
	real_name = "Kreb"
	icon_state = "kreb"
	icon_living = "kreb"
	icon_dead = "kreb_dead"
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/crab/evil/kreb
	name = "Zły Kreb"
	real_name = "Zły Kreb"
	icon_state = "evilkreb"
	icon_living = "evilkreb"
	icon_dead = "evilkreb_dead"
	gold_core_spawnable = NO_SPAWN

///The basic ai controller for crabs
/datum/ai_controller/basic_controller/crab
	blackboard = list(
		BB_ALWAYS_IGNORE_FACTION = TRUE,
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/of_size/smaller,
		BB_FLEE_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = DEFAULT_AI_FLAGS | STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee/from_flee_key,
		/datum/ai_planning_subtree/flee_target/from_flee_key,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/crab,
	)

/datum/ai_planning_subtree/random_speech/crab
	speech_chance = 1
	emote_hear = list("klika.")
	emote_see = list("klekocze.")

/// Strictly smaller mobs only (BeeStation/BeeStation-Hornet#14771, for crabs)
/datum/targeting_strategy/basic/of_size/smaller
	inclusive = FALSE

/// Crabs walk sideways (Bee: sideway_movement element on move loop signals, which we do not have; our Move() sets the facing
/// before and after moving, so the crab picks its facing once the move is done).
/// Keeps the old facing unless the crab walks straight ahead or backward, then turns it by 90 degrees.
/mob/living/basic/crab/Move(atom/newloc, direct, glide_size_override)
	var/facing_before_move = dir
	var/turf/old_turf = loc
	. = ..()
	if(!. || !isturf(old_turf) || !isturf(loc))
		return
	var/direction = get_dir(old_turf, loc)
	var/new_dir = facing_before_move
	if(direction == facing_before_move || direction == REVERSE_DIR(facing_before_move))
		new_dir = turn(facing_before_move, pick(90, -90))
	setDir(new_dir)
