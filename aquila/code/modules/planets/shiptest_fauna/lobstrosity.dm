// AQUILA: homarzysko (lobstrosity) - port of tgstation code/modules/mob/living/basic/lavaland/lobstrosity/ (AGPLv3) on our
// basic mobs, with the tropical variant of Shiptest (mining_mobs/lobstrosity.dm /beach, AGPLv3). Sprites: tgstation
// icons/mob/simple/icemoon/icemoon_monsters.dmi (CC BY-SA 3.0), copied to aquila/icons/planets/fauna/planet_fauna.dmi.
// Changes against tg:
// - tg's behaviour tree is rewritten on our planning subtrees: the lobstrosity charges from afar (our planet_charge.dm),
//   snips in melee and flees when hurt (tg also keeps its distance until the target is down and rests after a charge);
// - no limb snipping (amputating_limbs), fishing, taming, pet commands, crab speech or rush gland: we have none of those;
// - no emissive overlay; crab meat and bones as tg's butchering.

/// Slow crustacean that charges and snips
/mob/living/basic/mining/lobstrosity
	name = "arktyczne homarzysko"
	desc = "Te włochate skorupiaki pełzają i mnożą się w podziemnych jeziorach głęboko pod lodem. Szczególnie smakują im palce."
	icon = 'aquila/icons/planets/fauna/planet_fauna.dmi'
	icon_state = "arctic_lobstrosity"
	icon_living = "arctic_lobstrosity"
	icon_dead = "arctic_lobstrosity_dead"
	mouse_opacity = MOUSE_OPACITY_ICON
	friendly_verb_continuous = "szczęka szczypcami na"
	speak_emote = list("szczęka szczypcami")
	speed = 3
	maxHealth = 150
	health = 150
	obj_damage = 15
	melee_damage = 17
	melee_attack_cooldown = 1 SECONDS
	attack_verb_continuous = "szczypie"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	weather_immunities = list("snow")
	butcher_results = list(/obj/item/food/meat/slab/rawcrab = 2, /obj/item/stack/sheet/bone = 2)
	do_footstep = TRUE
	ai_controller = /datum/ai_controller/basic_controller/lobstrosity
	/// Our charge
	var/datum/action/cooldown/mob_cooldown/planet_charge/lobster/charge

/mob/living/basic/mining/lobstrosity/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_flee_while_injured, stop_fleeing_at = 0.6, start_fleeing_below = 0.3)
	charge = new(src)
	charge.Grant(src)
	ai_controller.set_blackboard_key(BB_TARGETED_ACTION, charge)

/mob/living/basic/mining/lobstrosity/Destroy()
	QDEL_NULL(charge)
	return ..()

/// A player in the lobstrosity charges by clicking something out of reach
/mob/living/basic/mining/lobstrosity/RangedAttack(atom/target, modifiers)
	. = ..()
	charge?.Trigger(target = target)

/// Tropical lobstrosity of the beach and water planets (Shiptest)
/mob/living/basic/mining/lobstrosity/beach
	name = "tropikalne homarzysko"
	desc = "Wynaturzony cud ewolucji. Na tropikalnych plażach dieta z krabów zabarwia jego pancerz na czerwono. Uważaj na szarżę."
	icon_state = "lobstrosity"
	icon_living = "lobstrosity"
	icon_dead = "lobstrosity_dead"
	weather_immunities = list()

/// Charge a long way and knock down for longer
/datum/action/cooldown/mob_cooldown/planet_charge/lobster
	name = "Szarża homarzyska"
	desc = "Szarżuje na cel z dużej odległości i przewraca go."
	cooldown_time = 6 SECONDS
	charge_distance = 8
	knockdown_duration = 2.5 SECONDS
	wall_stun_duration = 2 SECONDS

/datum/ai_controller/basic_controller/lobstrosity
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_AGGRO_RANGE = 7,
		BB_BASIC_MOB_FLEE_DISTANCE = 6,
		BB_BASIC_MOB_STOP_FLEEING = TRUE,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/targeted_mob_ability/planet_charge,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/lobstrosity,
	)

/datum/ai_planning_subtree/random_speech/lobstrosity
	speech_chance = 2
	emote_hear = list("szczęka szczypcami.", "terkocze.")
