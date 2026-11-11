// AQUILA: port of tgstation code/modules/mob/living/basic/alien/ (_alien.dm, alien_ai.dm, drone.dm, sentinel.dm, queen.dm, maid.dm)
// from the last revision before behaviour trees (tg 926bf40c5a), on the Bee AI core. Polish names and lines of our simple animal
// xenomorphs (the hunter, drone, sentinel, queen, empress, maid and the shuttle barmaid). Changes against tg:
// - `plants_off` stays a mob var (mapped drones and empresses switch weeding off with it; tg kept it on the shared idle
//   behaviour, so it did nothing), and the weed and egg cooldowns count per mob, not per shared idle behaviour;
// - the queen lays eggs only if not `sterile` (our var, TRUE by default; tg: can_lay_eggs = FALSE);
// - temperature: no cold damage down to 0 K and 20 brute a tick above 350 K, like our simple animal (tg: cold damage below 250 K);
// - the projectile is our /obj/item/projectile/neurotox (30 brute, as our simple animal; tg: /obj/projectile/neurotoxin/damaging);
// - no butt sprite, xeno blood or gibs procs (our basic mobs lack them), no FLAMMABLE_MOB flag (basic mobs burn here anyway);
// - the maid cleans in melee_attack() (we have no early_melee_attack()); the barmaid keeps GODMODE everywhere (no
//   area_based_godmode) and our captain + bar access card, sommelier and barmaster traits;
// - gold core spawns as our simple animals (hunter, drone, sentinel and maid hostile; queens not).
/mob/living/basic/alien
	name = "łowca obcych"
	desc = "Sssss!"
	icon = 'icons/mob/alien.dmi'
	icon_state = "alienh"
	icon_living = "alienh"
	icon_dead = "alienh_dead"
	icon_gib = "syndicate_gib"
	gender = FEMALE
	status_flags = CANPUSH
	butcher_results = list(
		/obj/item/food/meat/slab/xeno = 4,
		/obj/item/stack/sheet/animalhide/xeno = 1,
	)
	response_help_continuous = "szturcha"
	response_disarm_continuous = "popycha"
	response_harm_continuous = "uderza"

	maxHealth = 125
	health = 125
	bubble_icon = "alien"
	combat_mode = TRUE
	faction = list(FACTION_ALIEN)
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	unique_name = TRUE

	speed = 0
	obj_damage = 60
	speak_emote = list("syczy")
	speech_sound = "hiss"
	melee_damage = 25
	attack_verb_continuous = "tnie"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	gold_core_spawnable = HOSTILE_SPAWN
	death_sound = 'sound/voice/hiss6.ogg'
	death_message = "wydaje słabnący, gardłowy wrzask, a z paszczy bulgocze mu zielona krew..."
	chat_color = "#9EE08F"
	mobchatspan = "alienmobsay"
	do_footstep = TRUE
	discovery_points = 2000

	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	unsuitable_cold_damage = 2
	unsuitable_heat_damage = 20

	ai_controller = /datum/ai_controller/basic_controller/alien
	/// Mapped xenomorphs can be told not to plant weeds
	var/plants_off = FALSE
	/// Idle ticks until the next weed node
	var/plant_cooldown = 30

///Places alien weeds on the turf the mob is currently standing on.
/mob/living/basic/alien/proc/place_weeds()
	if(!isturf(loc) || isspaceturf(loc))
		return
	if(locate(/obj/structure/alien/weeds/node) in get_turf(src))
		return
	visible_message("<span class='alertalien'>[src] sadzi obce chwasty!</span>")
	new /obj/structure/alien/weeds/node(loc)

///Lays an egg on the turf the mob is currently standing on.
/mob/living/basic/alien/proc/lay_alien_egg()
	if(!isturf(loc) || isspaceturf(loc))
		return
	if(locate(/obj/structure/alien/egg) in get_turf(src))
		return
	visible_message("<span class='alertalien'>[src] składa jajo!</span>")
	new /obj/structure/alien/egg(loc)

/mob/living/basic/alien/drone
	name = "dron obcych"
	icon_state = "aliend"
	icon_living = "aliend"
	icon_dead = "aliend_dead"
	melee_damage = 15
	ai_controller = /datum/ai_controller/basic_controller/alien/drone

/mob/living/basic/alien/sentinel
	name = "strażnik obcych"
	icon_state = "aliens"
	icon_living = "aliens"
	icon_dead = "aliens_dead"
	health = 150
	maxHealth = 150
	melee_damage = 15
	ai_controller = /datum/ai_controller/basic_controller/alien/sentinel
	///The type of projectile that fires from attacks.
	var/projectiletype = /obj/item/projectile/neurotox
	///The sound that plays when the projectile is fired.
	var/projectilesound = 'sound/weapons/pierce.ogg'

/mob/living/basic/alien/sentinel/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ranged_attacks, projectile_type = projectiletype, projectile_sound = projectilesound, cooldown_time = 1 SECONDS)

/mob/living/basic/alien/queen
	name = "królowa ksenomorfów"
	icon_state = "alienq"
	icon_living = "alienq"
	icon_dead = "alienq_dead"
	health = 250
	maxHealth = 250
	melee_damage = 15
	status_flags = NONE //can't shove the queen, kiddo.
	unique_name = FALSE
	gold_core_spawnable = NO_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/alien/queen
	///The type of projectile that fires from attacks.
	var/projectiletype = /obj/item/projectile/neurotox
	///The sound that plays when the projectile is fired.
	var/projectilesound = 'sound/weapons/pierce.ogg'
	/// A sterile queen lays no eggs
	var/sterile = TRUE
	/// Idle ticks until the next egg
	var/egg_cooldown = 30

/mob/living/basic/alien/queen/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ranged_attacks, projectile_type = projectiletype, projectile_sound = projectilesound, cooldown_time = 1 SECONDS)

/mob/living/basic/alien/queen/large
	name = "cesarzowa ksenomorfów"
	icon = 'icons/mob/alienqueen.dmi'
	icon_state = "alienq"
	icon_living = "alienq"
	icon_dead = "alienq_dead"
	bubble_icon = "alienroyal"
	maxHealth = 400
	health = 400
	butcher_results = list(
		/obj/item/food/meat/slab/xeno = 10,
		/obj/item/stack/sheet/animalhide/xeno = 2,
	)
	mob_size = MOB_SIZE_LARGE

/obj/item/projectile/neurotox
	name = "neurotoksyna"
	damage = 30
	icon_state = "toxin"

/mob/living/basic/alien/maid
	name = "lubieżna pokojówka ksenomorfów"
	melee_damage = 0
	combat_mode = FALSE
	friendly_verb_continuous = "pieści"
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	gold_core_spawnable = HOSTILE_SPAWN
	icon_state = "maid"
	icon_living = "maid"
	icon_dead = "maid_dead"

/mob/living/basic/alien/maid/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/cleaning)

/// The maid cleans what she attacks instead of hurting it
/mob/living/basic/alien/maid/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	if(!ismovable(target))
		return ..()
	face_atom(target)
	if(!ignore_cooldown)
		changeNext_move(melee_attack_cooldown)
	if(SEND_SIGNAL(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, target) & COMPONENT_HOSTILE_NO_ATTACK)
		return FALSE
	if(istype(target, /obj/effect/decal/cleanable))
		visible_message("[src] sprząta [target].")
		qdel(target)
		return TRUE
	SEND_SIGNAL(target, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
	visible_message("[src] poleruje [target].")
	return TRUE

/datum/ai_controller/basic_controller/alien
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_controller/basic_controller/alien/sentinel
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/alien,
	)

/datum/ai_controller/basic_controller/alien/drone
	idle_behavior = /datum/idle_behavior/idle_random_walk/plant_weeds

/datum/ai_controller/basic_controller/alien/queen
	idle_behavior = /datum/idle_behavior/idle_random_walk/plant_weeds/queen

	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/alien,
	)

/**
 * Alien projectile
 * Try to avoid friendly fire, and has a 3 second delay.
 */
/datum/ai_planning_subtree/basic_ranged_attack_subtree/alien
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/alien

/datum/ai_behavior/basic_ranged_attack/alien
	action_cooldown = 3 SECONDS
	required_distance = 3
	avoid_friendly_fire = TRUE

/// Wanders about and now and then plants a weed node
/datum/idle_behavior/idle_random_walk/plant_weeds

/datum/idle_behavior/idle_random_walk/plant_weeds/perform_idle_behavior(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/basic/alien/alien_pawn = controller.pawn
	if(!istype(alien_pawn) || alien_pawn.plants_off)
		return
	alien_pawn.plant_cooldown--
	if(alien_pawn.plant_cooldown <= 0)
		alien_pawn.plant_cooldown = initial(alien_pawn.plant_cooldown)
		alien_pawn.place_weeds()

/// A queen also lays eggs, unless she is sterile
/datum/idle_behavior/idle_random_walk/plant_weeds/queen

/datum/idle_behavior/idle_random_walk/plant_weeds/queen/perform_idle_behavior(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/basic/alien/queen/queen_pawn = controller.pawn
	if(!istype(queen_pawn) || queen_pawn.sterile)
		return
	queen_pawn.egg_cooldown--
	if(queen_pawn.egg_cooldown <= 0)
		queen_pawn.egg_cooldown = initial(queen_pawn.egg_cooldown)
		queen_pawn.lay_alien_egg()
