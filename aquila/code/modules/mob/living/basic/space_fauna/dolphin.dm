// AQUILA - space dolphin as a basic mob (mobabilities part 2). Neither tg nor Bee has one, so this is our own conversion of
// code/modules/mob/living/simple_animal/hostile/retaliate/dolphin.dm (Bee) and its Aquila override, in the pattern of the
// cow and the turtle: Polish lines and stats of the old dolphin, retaliation through ai_retaliate, a bite that also tires
// people out, ghost possession (find_candidates()/give_to_ghost()), silent, flies through space (spacewalk). Spawned by
// the dolphin migration event and tamed with the space lasso.

/mob/living/basic/dolphin
	name = "kosmiczny delfin"
	desc = "Delfin w kosmosie."
	icon = 'icons/mob/animal.dmi'
	icon_state = "dolphin"
	icon_living = "dolphin"
	icon_dead = "dolphin_dead"
	icon_gib = "dolphin_gib"
	butcher_results = list(/obj/item/food/meat/slab/dolphinmeat = 2)
	response_help_continuous = "głaszcze"
	response_disarm_continuous = "delikatnie odsuwa na bok"
	response_harm_continuous = "uderza"
	speed = 0
	maxHealth = 25
	health = 25
	combat_mode = TRUE
	spacewalk = TRUE
	melee_damage = 15
	pass_flags = PASSTABLE
	attack_verb_continuous = "gryzie"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	speak_emote = list("terkocze", "piszczy", "klika")
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	faction = list("hostile")
	playable = TRUE
	should_talk = FALSE

	//Space dolphins aren't affected by cold.
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1500

	ai_controller = /datum/ai_controller/basic_controller/dolphin
	/// Stamina damage of a bite on a human
	var/bite_stamina_damage = 8

/mob/living/basic/dolphin/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	AddComponent(/datum/component/aggro_emote, emote_list = string_list(list("zgrzyta zębami")), emote_chance = 30)
	find_candidates()

/mob/living/basic/dolphin/attack_ghost(mob/dead/observer/user)
	. = ..()
	give_to_ghost(user)

/mob/living/basic/dolphin/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	. = ..()
	if(!. || !ishuman(target))
		return
	var/mob/living/carbon/human/bitten = target
	bitten.adjustStaminaLoss(bite_stamina_damage)

/// Swims around, bites back whoever hurts it
/datum/ai_controller/basic_controller/dolphin
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
