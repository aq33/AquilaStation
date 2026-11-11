// AQUILA: port of BeeStation/BeeStation-Hornet code/modules/mob/living/basic/farm_animals/cow/_cow.dm (bee/master 0adf0fe9ae)
// Polish lines and tipping of our simple animal cow (no tippable component here: right click tips it, as before).
// Riding after taming uses our old riding component (decision D6). The wisdom cow is in cow_wisdom.dm, Tyson in pets/dog/security_dog.dm.

//cow
/mob/living/basic/cow
	name = "krowa"
	desc = "Słynie z mleka. Tylko jej nie przewracaj."
	icon_state = "cow"
	icon_living = "cow"
	icon_dead = "cow_dead"
	icon_gib = "cow_gib"
	gender = FEMALE
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	speak_emote = list("muczy", "muczy upiornie")
	speed = 1.1
	see_in_dark = 6
	butcher_results = list(/obj/item/food/meat/slab = 6)
	response_help_continuous = "głaszcze"
	response_disarm_continuous = "delikatnie odsuwa na bok"
	response_harm_continuous = "kopie"
	attack_verb_continuous = "kopie"
	attack_sound = 'sound/weapons/punch1.ogg'
	attack_vis_effect = ATTACK_EFFECT_KICK
	health = 50
	maxHealth = 50
	gold_core_spawnable = FRIENDLY_SPAWN
	blood_volume = BLOOD_VOLUME_NORMAL
	ai_controller = /datum/ai_controller/basic_controller/cow
	chat_color = "#FFFFFF"
	speech_sound = "cow"
	do_footstep = TRUE
	/// what this cow munches on, and what can be used to tame it.
	var/list/food_types = list(/obj/item/food/grown/wheat)
	/// message sent when tamed
	var/tame_message = "radośnie muczy"
	/// singular version for player cows
	var/self_tame_message = "radośnie muczysz"

/mob/living/basic/cow/Initialize(mapload)
	AddElement(/datum/element/pet_bonus, "radośnie muczy!")
	udder_component()
	setup_eating()
	. = ..()
	ai_controller.set_blackboard_key(BB_BASIC_FOODS, typecacheof(food_types))

///wrapper for the udder component addition so you can have uniquely uddered cow subtypes
/mob/living/basic/cow/proc/udder_component()
	AddComponent(/datum/component/udder)

/*
 * food related components and elements are set up here for a few reasons:
 *
 * * static list can be created per-subtype, since static lists cannot be inherited and then changed
 * * all eating-related components and elements share the same pool of food the mob likes
 */
/mob/living/basic/cow/proc/setup_eating()
	var/static/list/food_types
	if(!food_types)
		food_types = src.food_types.Copy()
	AddComponent(/datum/component/tameable, food_types = food_types, tame_chance = 25, bonus_tame_chance = 15)

/mob/living/basic/cow/tamed(mob/living/tamer, atom/food)
	visible_message("[src] [tame_message], wyraźnie przywiązując się do [tamer].", "[capitalize(self_tame_message)], uznając [tamer] za nowego kumpla.")
	setup_tamed_riding()

/// Tipping a cow over with the right mouse button (disarm intent in the old controls), our simple animal cow did this
/mob/living/basic/cow/attack_hand(mob/living/carbon/human/user, list/modifiers)
	if(!stat && LAZYACCESS(modifiers, RIGHT_CLICK) && icon_state != icon_dead)
		user.visible_message(span_warning("[user] przewraca [src]."), span_notice("Przewracasz [src]."))
		to_chat(src, span_userdanger("[user] cię przewraca!"))
		Paralyze(60, ignore_canstun = TRUE)
		icon_state = icon_dead
		addtimer(CALLBACK(src, PROC_REF(tip_back), user), rand(20, 50))
		return TRUE
	return ..()

/mob/living/basic/cow/proc/tip_back(mob/living/carbon/user)
	if(stat && user)
		return
	icon_state = icon_living
	var/external
	var/internal
	switch(pick(1, 2, 3, 4))
		if(1, 2, 3)
			var/text = pick("błagalnie.", "proszącym wzrokiem.", "z rezygnacją.")
			external = "[src] patrzy na [user] [text]"
			internal = "Patrzysz na [user] [text]"
		if(4)
			external = "[src] wydaje się pogodzony ze swoim losem."
			internal = "Godzisz się ze swoim losem."
	visible_message(span_notice("[external]"), span_revennotice("[internal]"))

/datum/ai_planning_subtree/random_speech/cow
	speech_chance = 1
	speak = list("muu?", "muu", "MUUUUUU")
	emote_hear = list("ryczy.")
	emote_see = list("potrząsa głową.")
