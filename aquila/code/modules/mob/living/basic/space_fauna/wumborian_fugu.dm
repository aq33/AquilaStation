// AQUILA: port of tgstation code/modules/mob/living/basic/space_fauna/wumborian_fugu/ (wumborian_fugu.dm, inflation.dm,
// wumborian_ai.dm; tg 926bf40c5a) in place of our simple animal /hostile/asteroid/fugu. Polish names and lines of our simple animal.
// Changes against tg:
// - inflating is a mob ability (/datum/action/cooldown/mob_cooldown/fugu_expand) so the AI may use it (decision D6), the cooldown
//   is tg's 16 s; the inflated status has no screen alert (tg's alert overlay is not in our icons); invulnerability is our GODMODE flag;
// - inflated damage and wall tearing as our simple fugu (20 damage, 60 to objects) through the wall_tearer element (no reinforced walls);
// - the fugu gland stays an item and now also works on basic mobs (TRAIT_FUGU_GLANDED, wall_tearer), simple animals as before;
// - no seethrough_mob component, lava/ash storm traits or lighting cutoffs.
/// Movespeed modifier ID of the inflated fugu
#define MOVESPEED_ID_FUGU_INFLATED "fugu_inflated"

/**
 * # Wumborian Fugu
 *
 * A strange alien creature capable of increasing its mass when threatened, when not inflated it is virtually defenceless.
 * On death, the "fugu gland" is dropped, which can be used on mobs to increase their size, health, strength, and lets them smash walls.
 */
/mob/living/basic/wumborian_fugu
	name = "wumboriańska fugu"
	hardattacks = TRUE // nasty blocks (energy sword, chainsaw) do not hurt it, as our simple animal
	desc = "Wumboriańska fugu gwałtownie zwiększa masę ciała, by odstraszyć ofiarę. W tym stanie trzeba jej starannie unikać, bo jest prawie niezniszczalna, ale nie może utrzymać tej postaci w nieskończoność."
	icon = 'icons/mob/lavaland/64x64megafauna.dmi'
	icon_state = "Fugu0"
	icon_living = "Fugu0"
	icon_dead = "Fugu_dead"
	icon_gib = "syndicate_gib"
	pixel_x = -16
	base_pixel_x = -16
	mouse_opacity = MOUSE_OPACITY_ICON
	status_flags = CANSTUN
	gold_core_spawnable = HOSTILE_SPAWN
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	mob_size = MOB_SIZE_SMALL
	speed = 3 // 2 (run) + 3 = the old AI chase of 5 ds per tile (6 when inflated)
	maxHealth = 50
	health = 50
	combat_mode = TRUE
	obj_damage = 0
	melee_damage = 0
	attack_sound = 'sound/weapons/punch1.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	melee_attack_cooldown = 2.5 SECONDS
	attack_verb_continuous = "chrupie"
	friendly_verb_continuous = "unosi się przy"
	speak_emote = list("pyka")
	faction = list("mining")
	see_in_dark = 8
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY
	ai_controller = /datum/ai_controller/basic_controller/wumborian_fugu
	/// Ability used by the mob to become large, dangerous, and invulnerable
	var/datum/action/cooldown/mob_cooldown/fugu_expand/expand

/mob/living/basic/wumborian_fugu/Initialize(mapload)
	. = ..()
	var/static/list/death_loot = list(/obj/item/fugu_gland)
	AddElement(/datum/element/death_drops, death_loot)
	expand = new(src)
	expand.Grant(src)
	ai_controller.set_blackboard_key(BB_FUGU_INFLATE, expand)

/mob/living/basic/wumborian_fugu/Destroy()
	QDEL_NULL(expand)
	return ..()

/**
 * Action which inflates you, making you larger and stronger for the duration. Also invulnerable.
 * This is pretty much all just handled by a status effect.
 */
/datum/action/cooldown/mob_cooldown/fugu_expand
	name = "Nadmij się"
	desc = "Tymczasowo zwiększa twój rozmiar i czyni cię znacznie groźniejszą i wytrzymalszą! Nie dokuczaj fugu!"
	icon_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "expand"
	cooldown_time = 16 SECONDS
	melee_cooldown_time = 0
	click_to_activate = FALSE

/datum/action/cooldown/mob_cooldown/fugu_expand/IsAvailable(feedback = FALSE)
	. = ..()
	if (!.)
		return FALSE
	if(!istype(owner, /mob/living/basic/wumborian_fugu)) // A shame but there's not any good way to make this work on other mobs
		if (feedback)
			owner.balloon_alert(owner, "za mało rozciągliwa!")
		return FALSE
	if(HAS_TRAIT(owner, TRAIT_FUGU_GLANDED))
		if (feedback)
			owner.balloon_alert(owner, "JUŻ JESTEŚ WUMBO!")
		return FALSE
	return TRUE

/datum/action/cooldown/mob_cooldown/fugu_expand/Activate(atom/target)
	var/mob/living/living_owner = owner
	living_owner.apply_status_effect(/datum/status_effect/inflated)
	StartCooldown()
	return TRUE

/**
 * Status effect from the Expand action, makes you big and round and strong.
 */
/datum/status_effect/inflated
	id = "wumbo_inflated"
	duration = 10 SECONDS
	alert_type = null

/datum/status_effect/inflated/on_apply()
	var/mob/living/basic/wumborian_fugu/fugu = owner
	if (!istype(fugu))
		return FALSE
	RegisterSignal(fugu, COMSIG_MOB_STATCHANGE, PROC_REF(check_death))
	fugu.add_movespeed_modifier(MOVESPEED_ID_FUGU_INFLATED, multiplicative_slowdown = 1)
	ADD_TRAIT(fugu, TRAIT_FUGU_GLANDED, id)
	fugu.status_flags |= GODMODE
	fugu.AddElement(/datum/element/wall_tearer, allow_reinforced = FALSE)
	fugu.mob_size = MOB_SIZE_LARGE
	fugu.icon_state = "Fugu1"
	fugu.melee_damage = 20
	fugu.obj_damage = 60
	fugu.ai_controller?.set_blackboard_key(BB_BASIC_MOB_STOP_FLEEING, TRUE)
	fugu.ai_controller?.CancelActions()
	return TRUE

/datum/status_effect/inflated/on_remove()
	var/mob/living/basic/wumborian_fugu/fugu = owner
	if (!istype(fugu))
		return // Check again in case you changed mob after application but somehow kept the status effect
	UnregisterSignal(fugu, COMSIG_MOB_STATCHANGE)
	fugu.remove_movespeed_modifier(MOVESPEED_ID_FUGU_INFLATED)
	REMOVE_TRAIT(fugu, TRAIT_FUGU_GLANDED, id)
	fugu.status_flags &= ~GODMODE
	fugu.RemoveElement(/datum/element/wall_tearer, allow_reinforced = FALSE)
	fugu.mob_size = MOB_SIZE_SMALL
	fugu.melee_damage = 0
	if (fugu.stat != DEAD)
		fugu.icon_state = "Fugu0"
	fugu.obj_damage = 0
	fugu.ai_controller?.set_blackboard_key(BB_BASIC_MOB_STOP_FLEEING, FALSE)
	fugu.ai_controller?.CancelActions()

/// Remove status effect if we die
/datum/status_effect/inflated/proc/check_death(mob/living/source, new_stat)
	SIGNAL_HANDLER
	if (new_stat == DEAD)
		qdel(src)

/// Cowardly when small, aggressive when big. Tries to transform whenever possible.
/datum/ai_controller/basic_controller/wumborian_fugu
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability/inflate,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path/wumborian_fugu,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_planning_subtree/attack_obstacle_in_path/wumborian_fugu
	attack_behaviour = /datum/ai_behavior/attack_obstructions/wumborian_fugu

/datum/ai_behavior/attack_obstructions/wumborian_fugu
	can_attack_turfs = TRUE
	action_cooldown = 2.5 SECONDS

/datum/ai_planning_subtree/targeted_mob_ability/inflate
	ability_key = BB_FUGU_INFLATE

/obj/item/fugu_gland
	name = "gruczoł wumboriańskiej fugu"
	desc = "Klucz do zdolności wumboriańskiej fugu do dowolnego zwiększania masy. Ta obrzydliwa pozostałość może wywołać ten sam efekt u innych istot, dając im wielką siłę."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "fugu_gland"
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_NORMAL
	layer = ABOVE_MOB_LAYER
	var/list/banned_mobs

/obj/item/fugu_gland/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(!proximity_flag)
		return
	if(isbasicmob(target))
		glandify_basic_mob(target, user)
		return
	if(isanimal(target))
		var/mob/living/simple_animal/A = target
		if(A.buffed || (A.type in banned_mobs) || A.stat)
			to_chat(user, "<span class='warning'>Coś zakłóca działanie [src]. Nic z tego.</span>")
			return
		A.buffed++
		A.maxHealth *= 1.5
		A.health = min(A.maxHealth,A.health*1.5)
		A.melee_damage = max((A.melee_damage * 2), 10)
		A.transform *= 2
		A.environment_smash |= ENVIRONMENT_SMASH_STRUCTURES | ENVIRONMENT_SMASH_RWALLS
		to_chat(user, "<span class='info'>Zwiększasz rozmiar [A], dodając mu przypływu sił!</span>")
		qdel(src)

/// The gland on a basic mob (tg interact_with_atom()): bigger, tougher, stronger and tears down walls
/obj/item/fugu_gland/proc/glandify_basic_mob(mob/living/basic/animal, mob/user)
	if(HAS_TRAIT(animal, TRAIT_FUGU_GLANDED) || (animal.type in banned_mobs) || animal.stat)
		to_chat(user, "<span class='warning'>Coś zakłóca działanie [src]. Nic z tego.</span>")
		return
	ADD_TRAIT(animal, TRAIT_FUGU_GLANDED, type)
	animal.maxHealth *= 1.5
	animal.health = min(animal.maxHealth, animal.health * 1.5)
	animal.melee_damage = max((animal.melee_damage * 2), 10)
	animal.transform *= 2
	animal.AddElement(/datum/element/wall_tearer)
	to_chat(user, "<span class='info'>Zwiększasz rozmiar [animal], dodając mu przypływu sił!</span>")
	qdel(src)

/obj/item/fugu_gland/extrapolator_act(mob/user, var/obj/item/extrapolator/E, scan = TRUE)
	if(scan)
		to_chat(user, "<span class='info'>[src] ma potencjał do ekstrapolacji.</span>")
	else
		var/datum/disease/advance/R = new /datum/disease/advance/random(rand(1, 6), 4+(rand(1, 5)), /datum/symptom/growth)
		if(E.create_culture(R, user))
			qdel(src)
	return TRUE

#undef MOVESPEED_ID_FUGU_INFLATED
