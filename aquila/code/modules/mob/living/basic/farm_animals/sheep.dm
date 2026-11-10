// AQUILA: our simple animal sheep (not in BeeStation/BeeStation-Hornet#14771) as a basic mob, so the goat, the cow and the sheep
// all use the Bee udder component (decision D9). Shearing with a razor, wool and the Polish lines are ours; no tg mob_harvest.
// Our old sheep defined attackby() twice, so the razor won over the beaker: it can be milked again now.
/mob/living/basic/sheep
	name = "owca"
	desc = "Jaka puchata!"
	icon_state = "sheep"
	icon_living = "sheep"
	icon_dead = "sheep_dead"
	gender = FEMALE
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	speak_emote = list("beczy")
	see_in_dark = 6
	butcher_results = list(/obj/item/food/meat/slab = 4)
	response_help_continuous = "głaszcze"
	response_disarm_continuous = "delikatnie odsuwa na bok"
	response_harm_continuous = "kopie"
	attack_verb_continuous = "kopie"
	attack_sound = 'sound/weapons/punch1.ogg'
	attack_vis_effect = ATTACK_EFFECT_KICK
	health = 40
	maxHealth = 40
	gold_core_spawnable = FRIENDLY_SPAWN
	blood_volume = BLOOD_VOLUME_NORMAL
	do_footstep = TRUE
	ai_controller = /datum/ai_controller/basic_controller/sheep
	/// Was the wool cut and has not grown back yet
	var/shaved = FALSE
	/// How long the wool grows back
	var/wool_regrow_time = 3 MINUTES

/mob/living/basic/sheep/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/udder, /obj/item/udder/sheep)
	AddElement(/datum/element/ai_retaliate)

/mob/living/basic/sheep/attackby(obj/item/I, mob/living/user, params)
	if(!istype(I, /obj/item/razor))
		return ..()
	if(shaved)
		to_chat(user, span_warning("Owca nie ma dość wełny, spróbuj później..."))
		return TRUE
	user.visible_message("[user] zaczyna golić [src] za pomocą [I].", span_notice("Zaczynasz golić [src] za pomocą [I]..."))
	if(!do_after(user, 5 SECONDS, target = src))
		return TRUE
	if(shaved)
		user.visible_message("[src] jest już ostrzyżona!")
		return TRUE
	shear(user, I)
	return TRUE

/// Cuts the wool off: wool on the floor, sheared sprite, regrows later
/mob/living/basic/sheep/proc/shear(mob/living/user, obj/item/tool)
	if(user)
		user.visible_message("[user] strzyże trochę wełny z [src] za pomocą [tool].", span_notice("Strzyżesz trochę wełny z [src] za pomocą [tool]."))
	playsound(loc, 'sound/items/welder2.ogg', 20, TRUE)
	shaved = TRUE
	icon_living = "sheep_sheared"
	icon_dead = "sheep_sheared_dead"
	icon_state = stat == DEAD ? icon_dead : icon_living
	new /obj/item/stack/sheet/cotton/wool(get_turf(src), 8)
	addtimer(CALLBACK(src, PROC_REF(generate_wool)), wool_regrow_time)

/mob/living/basic/sheep/proc/generate_wool()
	if(stat != CONSCIOUS)
		return
	shaved = FALSE
	icon_living = "sheep"
	icon_dead = "sheep_dead"
	icon_state = icon_living

/obj/item/udder/sheep
	name = "wymię owcy"
	reagent_produced_typepath = /datum/reagent/consumable/milk/sheep

/datum/ai_controller/basic_controller/sheep
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/random_speech/sheep,
	)

/datum/ai_planning_subtree/random_speech/sheep
	speech_chance = 1
	speak = list("bee?", "bee", "BEEEEEE")
	emote_hear = list("ryczy.")
	emote_see = list("skubie trawę.")
