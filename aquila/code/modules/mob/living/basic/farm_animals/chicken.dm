// AQUILA: port of BeeStation/BeeStation-Hornet code/modules/mob/living/basic/farm_animals/chicken/chicken.dm and chick.dm
// (BeeStation/BeeStation-Hornet#14771, tg port), decision D13: chicks grow into chickens, the flock is capped by our max_chickens config.
// Polish lines, colours, held sprites and chat colours from our simple animal chicken and chick. Changes against Bee:
// - one counter for chickens and chicks (GLOB.total_chickens, as before); a chicken or chick leaves it when it dies (Bee: only when
//   deleted, so corpses kept blocking eggs) and comes back on revival;
// - the cap is checked when the egg is laid and again when it hatches (Bee: only when laid, so a pile of eggs overshot it);
// - eggs are our plain /obj/item/food/egg (no "organic egg"), no new cluck/chirp emotes and idle sounds (D13); petting uses Polish lines;
// - the chick uses its speech subtree (Bee defined it but did not put it in the controller) and grows also when it was mapped in.

/// Adds the mob to the shared chicken counter (chickens and chicks)
/mob/living/basic/proc/count_as_chicken(counted)
	if(counted)
		GLOB.total_chickens++
	else
		GLOB.total_chickens--

/// Can one more chicken come into the world (config max_chickens)
/proc/chicken_cap_free()
	return GLOB.total_chickens < CONFIG_GET(number/max_chickens)

/* ## Chickens
*
* Not-entirely-flightless domesticated birds that lay eggs, which are then consumed by humans and other animals.
*/
/mob/living/basic/chicken
	name = "\improper kura"
	desc = "Oby jajka w tym sezonie się udały."
	gender = FEMALE
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	icon_state = "chicken_brown"
	icon_living = "chicken_brown"
	icon_dead = "chicken_brown_dead"
	held_state = "chicken_brown"
	head_icon = 'icons/mob/pets_held_large.dmi'
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	density = FALSE
	butcher_results = list(/obj/item/food/meat/slab/chicken = 2)
	response_help_continuous = "głaszcze"
	response_disarm_continuous = "delikatnie odsuwa na bok"
	response_harm_continuous = "kopie"
	attack_verb_continuous = "kopie"
	friendly_verb_continuous = "trąca łebkiem"
	speak_emote = list("gdacze", "pogdakuje")
	health = 15
	maxHealth = 15
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	ventcrawler = VENTCRAWLER_ALWAYS
	gold_core_spawnable = FRIENDLY_SPAWN
	chat_color = "#FFDC9B"
	mobchatspan = "stationengineer"
	do_footstep = TRUE

	ai_controller = /datum/ai_controller/basic_controller/chicken

	///boolean deciding whether eggs laid by this chicken can hatch into chicks
	var/fertile = TRUE
	/// What we lay
	var/egg_type = /obj/item/food/egg
	/// What makes us lay more
	var/list/food_types = list(/obj/item/food/grown/wheat)
	/// Lines when fed
	var/list/feed_messages = list("Radośnie gdacze.")
	/// Colours we come in
	var/list/valid_colors = list("brown", "black", "white")
	/// Icon state prefix of our colours
	var/icon_prefix = "chicken"
	/// Is this mob in GLOB.total_chickens now
	var/counted_chicken = FALSE

/mob/living/basic/chicken/Initialize(mapload)
	. = ..()
	update_chicken_count(TRUE)
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/pet_bonus, "radośnie gdacze!")
	if(length(valid_colors))
		AddElement(/datum/element/animal_variety, icon_prefix, pick(valid_colors), modify_pixels = TRUE)
	held_state = icon_state
	setup_egg_layer()

/// Chickens lay eggs; turkeys do not
/mob/living/basic/chicken/proc/setup_egg_layer()
	if(!egg_type)
		return
	AddComponent(\
		/datum/component/egg_layer, \
		egg_type, \
		food_types, \
		feed_messages = feed_messages, \
		lay_messages = EGG_LAYING_MESSAGES, \
		eggs_left = 0, \
		eggs_added_from_eating = rand(1, 4), \
		max_eggs_held = 8, \
		egg_laid_callback = CALLBACK(src, PROC_REF(egg_laid)), \
	)

/mob/living/basic/chicken/proc/update_chicken_count(counted)
	if(counted_chicken == counted)
		return
	counted_chicken = counted
	count_as_chicken(counted)

/mob/living/basic/chicken/death(gibbed)
	update_chicken_count(FALSE)
	return ..()

/mob/living/basic/chicken/revive(full_heal = FALSE, admin_revive = FALSE)
	. = ..()
	if(. && stat != DEAD)
		update_chicken_count(TRUE)

/mob/living/basic/chicken/Destroy()
	update_chicken_count(FALSE)
	return ..()

/mob/living/basic/chicken/proc/egg_laid(obj/item/egg)
	if(!fertile || !chicken_cap_free() || !prob(25))
		return
	egg.AddComponent(\
		/datum/component/fertile_egg, \
		embryo_type = /mob/living/basic/chick, \
		minimum_growth_rate = 1, \
		maximum_growth_rate = 2, \
		total_growth_required = 200, \
		current_growth = 0, \
		location_allowlist = typecacheof(list(/turf)), \
		spoilable = TRUE, \
		can_hatch = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(chicken_cap_free)), \
	)

/datum/ai_controller/basic_controller/chicken
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/random_speech/chicken,
	)

/datum/ai_planning_subtree/random_speech/chicken
	speech_chance = 2
	speak = list("Ko!", "KOOOOOO KO KO KO!", "Ko-ko.")
	emote_hear = list("gdacze.")
	emote_see = list("dziobie ziemię.", "zawzięcie trzepocze skrzydłami.")

/**
 * ## Chicks
 *
 * Baby birds that grow into big chickens.
 */
/mob/living/basic/chick
	name = "\improper pisklę"
	desc = "Urocze! Choć narobi strasznego hałasu."
	icon_state = "chick"
	icon_living = "chick"
	icon_dead = "chick_dead"
	icon_gib = "chick_gib"
	held_state = "chick"
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	gender = FEMALE
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	speak_emote = list("piszczy")
	density = FALSE
	butcher_results = list(/obj/item/food/meat/slab/chicken = 1)
	response_help_continuous = "głaszcze"
	response_disarm_continuous = "delikatnie odsuwa na bok"
	response_harm_continuous = "kopie"
	attack_verb_continuous = "kopie"
	health = 3
	maxHealth = 3
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	ventcrawler = VENTCRAWLER_ALWAYS
	gold_core_spawnable = FRIENDLY_SPAWN
	chat_color = "#FFDC9B"
	do_footstep = TRUE
	ai_controller = /datum/ai_controller/basic_controller/chick

	/// What we grow into.
	var/grow_as = /mob/living/basic/chicken
	/// Is this mob in GLOB.total_chickens now
	var/counted_chicken = FALSE

/mob/living/basic/chick/Initialize(mapload)
	. = ..()
	pixel_x = base_pixel_x + rand(-6, 6)
	pixel_y = base_pixel_y + rand(0, 10)
	update_chicken_count(TRUE)

	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/pet_bonus, "radośnie piszczy!")

	if(!isnull(grow_as)) // we don't have a set time to grow up beyond whatever RNG dictates, and if we somehow get a client, all growth halts.
		AddComponent(\
			/datum/component/growth_and_differentiation,\
			growth_time = null,\
			growth_path = grow_as,\
			growth_probability = 100,\
			lower_growth_value = 0.5,\
			upper_growth_value = 1,\
			signals_to_kill_on = list(COMSIG_MOB_CLIENT_LOGIN),\
			optional_checks = CALLBACK(src, PROC_REF(ready_to_grow)),\
		)

/// We don't grow into a chicken if we're not conscious.
/mob/living/basic/chick/proc/ready_to_grow()
	return (stat == CONSCIOUS) && !istype(loc, /obj/item/clothing/head/mob_holder)

/mob/living/basic/chick/proc/update_chicken_count(counted)
	if(counted_chicken == counted)
		return
	counted_chicken = counted
	count_as_chicken(counted)

/mob/living/basic/chick/death(gibbed)
	update_chicken_count(FALSE)
	return ..()

/mob/living/basic/chick/revive(full_heal = FALSE, admin_revive = FALSE)
	. = ..()
	if(. && stat != DEAD)
		update_chicken_count(TRUE)

/mob/living/basic/chick/Destroy()
	update_chicken_count(FALSE)
	return ..()

/// Variant of chick that just spawns in the holodeck so you can pet it. Doesn't grow up.
/mob/living/basic/chick/permanent
	grow_as = null

/datum/ai_controller/basic_controller/chick
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_FIND_MOM_TYPES = list(/mob/living/basic/chicken),
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/look_for_adult,
		/datum/ai_planning_subtree/random_speech/chick,
	)

/datum/ai_planning_subtree/random_speech/chick
	speech_chance = 2
	speak = list("Pi.", "Pi?", "Pi-pi.", "Piii!")
	emote_hear = list("piszczy.")
	emote_see = list("dziobie ziemię.", "trzepocze malutkimi skrzydełkami.")
