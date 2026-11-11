// AQUILA: port of BeeStation/BeeStation-Hornet code/modules/mob/living/basic/pets/cat/cat.dm (bee/master 0adf0fe9ae)
// Polish names, lines and sounds of our simple animal cats. No pet cult (decision D10), no stove interaction
// (commented out in Bee). The feral cat, Jerry, the tabby and the cat house are in cat_house.dm.

/mob/living/basic/pet/cat
	name = "kot"
	desc = "Kotek!!"
	icon = 'icons/mob/pets.dmi'
	icon_state = "cat2"
	icon_living = "cat2"
	icon_dead = "cat2_dead"
	gender = MALE
	speak_emote = list("mruczy", "miauczy")
	see_in_dark = 6
	ventcrawler = VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	minimum_survivable_temperature = 200
	maximum_survivable_temperature = 400
	unsuitable_atmos_damage = 1
	butcher_results = list(/obj/item/food/meat/slab = 2, /obj/item/organ/ears/cat = 1, /obj/item/organ/tail/cat = 1, /obj/item/organ/tongue/cat = 1)
	response_help_continuous = "głaszcze"
	response_disarm_continuous = "delikatnie odsuwa na bok"
	response_harm_continuous = "kopie"
	gold_core_spawnable = FRIENDLY_SPAWN
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	ai_controller = /datum/ai_controller/basic_controller/cat
	held_state = "cat2"
	attack_verb_continuous = "drapie"
	attack_sound = 'sound/weapons/slash.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	chat_color = "#FFD586"
	speech_sound = "cat"
	do_footstep = TRUE

	///icon of the collar we can wear
	var/collar_icon_state = "cat"
	///can this cat breed?
	var/can_breed = TRUE
	///can hold items?
	var/can_hold_item = TRUE
	///list of items we can carry
	var/static/list/huntable_items = list(
		/obj/item/fish,
		/obj/item/food/deadmouse,
		/obj/item/food/fishmeat,
	)
	///list of pet commands we follow
	var/static/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/follow/start_active,
		/datum/pet_command/perform_trick_sequence,
	)

	///item we are currently holding
	var/obj/item/held_food
	/// AQUILA: when we picked up held_food (the AI eats prey it could not deliver to a kitten)
	var/held_food_since = 0
	///mutable appearance for held item
	var/mutable_appearance/held_item_overlay
	///callback for after a kitten is born
	var/datum/callback/post_birth_callback

/mob/living/basic/pet/cat/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/obeys_commands, pet_commands)
	AddElement(/datum/element/wears_collar, collar_icon_state = collar_icon_state, collar_resting_icon_state = TRUE)
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/pet_bonus, "mruczy!", /datum/mood_event/pet_animal, 'aquila/sound/misc/purr.ogg')
	// AQUILA: cats are tamed by feeding them their prey from the hand, so their pet commands can be reached without the lasso
	// (Bee and tg have nothing that befriends a cat). The prey the cat attacks itself is still picked up, see on_pre_eat().
	AddComponent(/datum/component/tameable, food_types = huntable_items, tame_chance = 30, bonus_tame_chance = 15, unique = FALSE)
	RegisterSignal(src, COMSIG_MOB_PRE_EAT, PROC_REF(on_pre_eat))
	add_verb(/mob/living/proc/lay_down)
	ai_controller.set_blackboard_key(BB_HUNTABLE_PREY, typecacheof(huntable_items))
	if(can_breed)
		add_breeding_component()
	if(can_hold_item)
		RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(pre_attack))

/mob/living/basic/pet/cat/Destroy()
	post_birth_callback = null
	held_food = null
	return ..()

/// Hissing at whoever hits it, as our simple animal cats did
/mob/living/basic/pet/cat/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(user.combat_mode && stat != DEAD)
		manual_emote("syczy!")

/// AQUILA: prey the cat attacks itself goes into its mouth (pre_attack) instead of being eaten, unless the mouth is full
/mob/living/basic/pet/cat/proc/on_pre_eat(mob/living/source, atom/food, mob/living/feeder, list/effect_mult)
	SIGNAL_HANDLER
	if(isnull(feeder) && can_hold_item && !held_food)
		return COMSIG_MOB_CANCEL_EAT
	return NONE

/mob/living/basic/pet/cat/proc/pre_attack(mob/living/source, atom/movable/target)
	SIGNAL_HANDLER
	if(!is_type_in_list(target, huntable_items) || held_food)
		return
	target.forceMove(src)

/mob/living/basic/pet/cat/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone != held_food)
		return
	held_food = null
	update_appearance(UPDATE_OVERLAYS)

/mob/living/basic/pet/cat/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(is_type_in_list(arrived, huntable_items))
		held_food = arrived
		held_food_since = world.time
		update_appearance(UPDATE_OVERLAYS)
	return ..()

/mob/living/basic/pet/cat/update_overlays()
	. = ..()
	if(stat == DEAD || resting || !held_food)
		return
	held_item_overlay = null
	if(istype(held_food, /obj/item/fish))
		held_item_overlay = mutable_appearance('aquila/icons/mob/pets_cat_held.dmi', "cat_fish_overlay")
	if(istype(held_food, /obj/item/food/deadmouse))
		held_item_overlay = mutable_appearance('aquila/icons/mob/pets_cat_held.dmi', "cat_mouse_overlay")
	if(held_item_overlay)
		. += held_item_overlay

/mob/living/basic/pet/cat/update_resting()
	. = ..()
	if(stat == DEAD)
		return
	update_appearance(UPDATE_ICON_STATE)

/mob/living/basic/pet/cat/update_icon_state()
	. = ..()
	if(stat == DEAD)
		return
	if (resting)
		icon_state = "[icon_living]_rest"
		return
	icon_state = "[icon_living]"

/mob/living/basic/pet/cat/proc/add_breeding_component()
	var/static/list/baby_types = list(
		/mob/living/basic/pet/cat/kitten = 1,
	)
	AddComponent(\
		/datum/component/breed,\
		can_breed_with = typecacheof(list(/mob/living/basic/pet/cat)),\
		baby_paths = baby_types,\
		post_birth = post_birth_callback,\
	)

/mob/living/basic/pet/cat/space
	name = "kosmiczny kot"
	desc = "To kot... w kosmosie!"
	icon_state = "spacecat"
	icon_living = "spacecat"
	icon_dead = "spacecat_dead"
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = TCMB
	maximum_survivable_temperature = T0C + 40
	held_state = "spacecat"

/mob/living/basic/pet/cat/breadcat
	name = "kot w chlebie"
	desc = "To kot... w chlebie!"
	icon_state = "breadcat"
	icon_living = "breadcat"
	icon_dead = "breadcat_dead"
	ai_controller = /datum/ai_controller/basic_controller/cat/bread
	held_state = "breadcat"
	butcher_results = list(/obj/item/food/meat/slab = 2, /obj/item/organ/ears/cat = 1, /obj/item/organ/tail/cat = 1, /obj/item/organ/tongue/cat = 1, /obj/item/food/breadslice/plain = 1)
	collar_icon_state = null

/mob/living/basic/pet/cat/original
	name = "Batsy"
	desc = "Owoc obcego DNA i znudzonych genetyków."
	gender = FEMALE
	icon_state = "original"
	icon_living = "original"
	icon_dead = "original_dead"
	collar_icon_state = null
	unique_pet = TRUE
	held_state = "original"

/mob/living/basic/pet/cat/kitten
	name = "kociak"
	desc = "Ojejuuu."
	icon_state = "kitten"
	icon_living = "kitten"
	icon_dead = "kitten_dead"
	density = FALSE
	pass_flags = PASSMOB
	mob_size = MOB_SIZE_SMALL
	can_breed = FALSE
	ai_controller = /datum/ai_controller/basic_controller/cat/kitten
	can_hold_item = FALSE
	collar_icon_state = "kitten"

/mob/living/basic/pet/cat/_proc
	name = "Proc"
	gender = MALE
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/basic/pet/cat/halal
	name = "kot arabski"
	desc = "To kot z agalem na głowie."
	gender = MALE
	icon_state = "cathalal"
	icon_living = "cathalal"
	collar_icon_state = null
	held_state = "cathalal"

/datum/ai_planning_subtree/random_speech/cats
	speech_chance = 10
	sound = list('aquila/sound/misc/meow.ogg') // AQUILA: the meow our simple animal cats played
	speak = list("Miau!", "Fff!", "Mrrr!", "SSSSSS")
	emote_hear = list("miauczy.", "pomiaukuje.")
	emote_see = list("potrząsa głową.", "drży.", "przeciąga się, czekając na drapanie po brzuszku.", "macha ogonem.", "przykuca na tylnych łapach.", "nastawia uszu.", "wylizuje futerko.", "rusza wąsikami.", "otrząsa futerko.")
