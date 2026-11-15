// AQUILA: demon lodowy (ice demon) - port of tgstation code/modules/mob/living/basic/icemoon/ice_demon/ (ice_demon.dm,
// ice_demon_abilities.dm, ice_demon_ai.dm; AGPLv3) on our basic mobs, with Shiptest's primordial demon (mining_mobs/
// ice_demon.dm /old_demon, AGPLv3). Sprites: tgstation icons/mob/simple/icemoon/icemoon_monsters.dmi and Shiptest
// icons/mob/icemoon/icemoon_monsters.dmi (CC BY-SA 3.0), copied to aquila/icons/planets/fauna/planet_fauna.dmi.
// Changes against tg:
// - tg's behaviour tree is rewritten on our planning subtrees: the demon keeps its distance and shoots ice, teleports away
//   when someone gets next to it (or now and then to a tile three steps from its target, as Shiptest's demon does before
//   it shoots), freezes the floor around itself when cornered and conjures two afterimages once badly hurt;
// - the afterimages are a mob ability (tg: a conjure spell) and do not share damage with the demon (no joint_damage);
//   they fade away after 15 s as in tg;
// - it does not flee from lit welders and flares (tg's flee_from_fire subtree), no crusher trophy;
// - the ice blast is our temperature projectile (it chills towards 150 K, tg lowers body temperature by 75 K);
// - the primordial demon is a bigger ice demon (Shiptest stats) that leaves bluespace crystals and sometimes a bluespace
//   anomaly core; Shiptest's "random" ice demon is a primordial one 15% of the time.

/// Blackboard keys of the ice demon
#define BB_DEMON_TELEPORT_ABILITY "BB_demon_teleport_ability"
#define BB_DEMON_TELEPORT_DESTINATION "BB_demon_teleport_destination"
#define BB_DEMON_SLIP_ABILITY "BB_demon_slip_ability"
#define BB_DEMON_CLONE_ABILITY "BB_demon_clone_ability"

/mob/living/basic/mining/ice_demon
	name = "demoniczny obserwator"
	desc = "Istota uformowana w całości z lodu, z której wnętrza bije energia bluespace."
	icon = 'aquila/icons/planets/fauna/planet_fauna.dmi'
	icon_state = "ice_demon"
	icon_living = "ice_demon"
	icon_dead = "ice_demon"
	icon_gib = "syndicate_gib"
	mouse_opacity = MOUSE_OPACITY_ICON
	basic_mob_flags = DEL_ON_DEATH
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	speak_emote = list("skrzeczy telepatycznie")
	speed = 2
	maxHealth = 150
	health = 150
	obj_damage = 40
	melee_damage = 15
	attack_verb_continuous = "tnie"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	weather_immunities = list("snow", "lava", "ash")
	death_message = "blednie, gdy rozpraszają się energie, które wiązały go z tym światem."
	death_sound = 'sound/magic/demon_dies.ogg'
	ai_controller = /datum/ai_controller/basic_controller/ice_demon
	/// Projectile we shoot
	var/projectile_type = /obj/item/projectile/temp/ice_demon
	/// Bluespace crystals left on death
	var/crystal_amount = 3

/mob/living/basic/mining/ice_demon/Initialize(mapload)
	. = ..()
	var/static/list/innate_actions = list(
		/datum/action/cooldown/mob_cooldown/slippery_ice_floors = BB_DEMON_SLIP_ABILITY,
		/datum/action/cooldown/mob_cooldown/ice_demon_teleport = BB_DEMON_TELEPORT_ABILITY,
		/datum/action/cooldown/mob_cooldown/ice_demon_afterimages = BB_DEMON_CLONE_ABILITY,
	)
	grant_actions_by_list(innate_actions)
	AddComponent(/datum/component/ranged_attacks, projectile_type = projectile_type, projectile_sound = 'sound/weapons/pierce.ogg', cooldown_time = 1.5 SECONDS)
	AddElement(/datum/element/simple_flying)

/mob/living/basic/mining/ice_demon/death(gibbed)
	var/turf/death_turf = get_turf(src)
	if(death_turf)
		new /obj/item/stack/ore/bluespace_crystal(death_turf, crystal_amount)
		drop_extra_loot(death_turf)
	return ..()

/// Rare loot on top of the crystals
/mob/living/basic/mining/ice_demon/proc/drop_extra_loot(turf/death_turf)
	if(prob(5))
		new /obj/item/assembly/signaler/anomaly/bluespace(death_turf)

/// Shiptest's primordial demon: older, bigger, angrier
/mob/living/basic/mining/ice_demon/old
	name = "pradawny demon"
	desc = "Na początku była tylko pustka. Z pustki przyszły potwory."
	icon_state = "old_demon"
	icon_living = "old_demon"
	icon_dead = "old_demon"
	maxHealth = 300
	health = 300
	obj_damage = 100
	melee_damage = 25
	attack_verb_continuous = "rozpłatuje"
	death_message = "wrzeszczy z wściekłości, wracając do pustki."
	projectile_type = /obj/item/projectile/temp/ice_demon/old
	crystal_amount = 10

/mob/living/basic/mining/ice_demon/old/drop_extra_loot(turf/death_turf)
	if(prob(20))
		new /obj/item/assembly/signaler/anomaly/bluespace(death_turf)

/// An ice demon, now and then a primordial one (Shiptest: 15%)
/mob/living/basic/mining/ice_demon/random

/mob/living/basic/mining/ice_demon/random/Initialize(mapload)
	if(prob(15))
		new /mob/living/basic/mining/ice_demon/old(loc)
		return INITIALIZE_HINT_QDEL
	return ..()

/obj/item/projectile/temp/ice_demon
	name = "lodowy pocisk"
	icon_state = "ice_2"
	damage = 5
	damage_type = BURN
	flag = "energy"
	temperature = 150

/obj/item/projectile/temp/ice_demon/old
	damage = 10
	temperature = 100

/// Short-lived copy of the demon
/mob/living/basic/mining/demon_afterimage
	name = "powidok demonicznego obserwatora"
	desc = "Czy to jakaś iluzja?"
	icon = 'aquila/icons/planets/fauna/planet_fauna.dmi'
	icon_state = "ice_demon"
	icon_living = "ice_demon"
	icon_dead = "ice_demon"
	icon_gib = "syndicate_gib"
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_ICON
	basic_mob_flags = DEL_ON_DEATH
	speed = 5
	maxHealth = 20
	health = 20
	melee_damage = 5
	attack_verb_continuous = "tnie"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	alpha = 80
	kill_count = FALSE
	discovery_points = 0
	ai_controller = /datum/ai_controller/basic_controller/simple_hostile
	/// How long we exist for
	var/existence_period = 15 SECONDS

/mob/living/basic/mining/demon_afterimage/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	fade_into_nothing(life_time = existence_period)

/// Teleport to a target tile
/datum/action/cooldown/mob_cooldown/ice_demon_teleport
	name = "Teleportacja bluespace"
	desc = "Teleportuje się w wybrane miejsce."
	icon_icon = 'icons/obj/telescience.dmi'
	button_icon_state = "bluespace_crystal"
	cooldown_time = 3 SECONDS
	/// Time before the teleport
	var/time_delay = 0.5 SECONDS

/datum/action/cooldown/mob_cooldown/ice_demon_teleport/Activate(atom/target_atom)
	var/turf/destination = get_turf(target_atom)
	if(!destination || isclosedturf(destination) || destination.z != owner.z)
		owner.balloon_alert(owner, "zablokowane!")
		return FALSE
	animate(owner, transform = matrix().Scale(0.8), time = time_delay, easing = SINE_EASING)
	addtimer(CALLBACK(src, PROC_REF(teleport_to_turf), destination), time_delay)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/ice_demon_teleport/proc/teleport_to_turf(turf/destination)
	if(QDELETED(owner))
		return
	animate(owner, transform = matrix(), time = 0.5 SECONDS, easing = SINE_EASING)
	if(owner.stat == DEAD)
		return
	do_teleport(owner, destination, channel = TELEPORT_CHANNEL_BLUESPACE, forced = TRUE)

/// Slippery ice all around
/datum/action/cooldown/mob_cooldown/slippery_ice_floors
	name = "Śliska posadzka"
	desc = "Pokrywa ziemię wokół śliskim lodem."
	icon_icon = 'icons/effects/freeze.dmi'
	button_icon_state = "ice_cube"
	cooldown_time = 2 SECONDS
	click_to_activate = FALSE
	/// Radius of the ice
	var/radius = 1
	/// Delay between the rings of ice
	var/spread_duration = 0.2 SECONDS

/datum/action/cooldown/mob_cooldown/slippery_ice_floors/Activate(atom/target_atom)
	var/turf/center = get_turf(owner)
	if(!center)
		return FALSE
	for(var/ring in 0 to radius)
		var/list/ring_turfs = list()
		for(var/turf/ring_turf as anything in RANGE_TURFS(ring, center))
			if(abs(ring_turf.x - center.x) + abs(ring_turf.y - center.y) == ring)
				ring_turfs += ring_turf
		addtimer(CALLBACK(src, PROC_REF(spawn_icy_floors), ring_turfs), ring * spread_duration)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/slippery_ice_floors/proc/spawn_icy_floors(list/ring_turfs)
	for(var/turf/location as anything in ring_turfs)
		if(isclosedturf(location) || isspaceturf(location))
			continue
		new /obj/effect/temp_visual/slippery_ice(location)

/obj/effect/temp_visual/slippery_ice
	name = "śliski lód"
	icon = 'icons/turf/floors/ice_turf.dmi'
	icon_state = "ice_turf-6"
	layer = BELOW_MOB_LAYER
	anchored = TRUE
	duration = 3 SECONDS
	alpha = 100
	/// How long it takes for the ice to set
	var/phase_in_period = 2 SECONDS

/obj/effect/temp_visual/slippery_ice/Initialize(mapload)
	. = ..()
	animate(src, alpha = 160, time = phase_in_period)
	animate(alpha = 0, time = duration - phase_in_period)
	addtimer(CALLBACK(src, PROC_REF(add_slippery_component)), phase_in_period)

/obj/effect/temp_visual/slippery_ice/proc/add_slippery_component()
	AddComponent(/datum/component/slippery, 2 SECONDS)

/// Two afterimages to help in the fight
/datum/action/cooldown/mob_cooldown/ice_demon_afterimages
	name = "Powidoki"
	desc = "Tworzy dwa iluzoryczne sobowtóry, które pomagają w walce."
	icon_icon = 'aquila/icons/planets/fauna/planet_fauna.dmi'
	button_icon_state = "ice_demon"
	cooldown_time = 1 MINUTES
	click_to_activate = FALSE
	/// Afterimages we made
	var/list/afterimages = list()
	/// How many can be around at once
	var/max_afterimages = 2

/datum/action/cooldown/mob_cooldown/ice_demon_afterimages/Destroy()
	afterimages = null
	return ..()

/datum/action/cooldown/mob_cooldown/ice_demon_afterimages/Activate(atom/target_atom)
	var/turf/center = get_turf(owner)
	if(!center)
		return FALSE
	for(var/mob/living/existing as anything in afterimages)
		if(QDELETED(existing))
			afterimages -= existing
	var/list/free_turfs = list()
	for(var/turf/open/nearby in orange(1, center))
		if(!is_blocked_turf(nearby, exclude_mobs = TRUE))
			free_turfs += nearby
	var/mob/living/living_owner = owner
	var/atom/target = living_owner.ai_controller?.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	while(length(afterimages) < max_afterimages && length(free_turfs))
		var/mob/living/basic/mining/demon_afterimage/afterimage = new(pick_n_take(free_turfs))
		afterimage.faction = living_owner.faction.Copy()
		afterimages += afterimage
		if(target)
			afterimage.ai_controller?.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, target)
	StartCooldown()
	return TRUE

/datum/ai_controller/basic_controller/ice_demon
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_RANGED_SKIRMISH_MIN_DISTANCE = 3,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 7,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/ice_demon_afterimages,
		/datum/ai_planning_subtree/ice_demon_teleport,
		/datum/ai_planning_subtree/ice_demon_slip,
		/datum/ai_planning_subtree/maintain_distance,
		/datum/ai_planning_subtree/ranged_skirmish,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/// Conjure the afterimages once below 75% health
/datum/ai_planning_subtree/ice_demon_afterimages

/datum/ai_planning_subtree/ice_demon_afterimages/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/mob/living/pawn = controller.pawn
	if(!controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET) || pawn.health > pawn.maxHealth * 0.75)
		return
	var/datum/action/cooldown/clone = controller.blackboard[BB_DEMON_CLONE_ABILITY]
	if(!clone?.IsAvailable())
		return
	controller.queue_behavior(/datum/ai_behavior/use_mob_ability, BB_DEMON_CLONE_ABILITY)

/// Teleport away from someone next to us, now and then to a tile three steps from the target
/datum/ai_planning_subtree/ice_demon_teleport
	/// Chance per planning to hop around a target that is not next to us
	var/hop_chance = 15

/datum/ai_planning_subtree/ice_demon_teleport/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(QDELETED(target) || !isturf(target.loc))
		return
	var/datum/action/cooldown/teleport = controller.blackboard[BB_DEMON_TELEPORT_ABILITY]
	if(!teleport?.IsAvailable())
		return
	var/distance = get_dist(controller.pawn, target)
	var/turf/destination
	if(distance <= 1)
		destination = ice_demon_find_teleport_turf(target, 4, 6)
	else if(prob(hop_chance))
		destination = ice_demon_find_teleport_turf(target, 3, 3)
	if(!destination)
		return
	controller.set_blackboard_key(BB_DEMON_TELEPORT_DESTINATION, destination)
	controller.queue_behavior(/datum/ai_behavior/targeted_mob_ability, BB_DEMON_TELEPORT_ABILITY, BB_DEMON_TELEPORT_DESTINATION)
	return SUBTREE_RETURN_FINISH_PLANNING

/// A free open tile min-max steps from the target, in sight of it
/proc/ice_demon_find_teleport_turf(atom/target, min_distance, max_distance)
	var/list/candidates = list()
	for(var/turf/open/candidate in view(max_distance, get_turf(target)))
		var/distance = get_dist(candidate, target)
		if(distance < min_distance || distance > max_distance || isspaceturf(candidate) || islava(candidate) || ischasm(candidate))
			continue
		if(is_blocked_turf(candidate, exclude_mobs = FALSE))
			continue
		candidates += candidate
	if(length(candidates))
		return pick(candidates)

/// Freeze the floor when someone is next to us and we cannot teleport away
/datum/ai_planning_subtree/ice_demon_slip

/datum/ai_planning_subtree/ice_demon_slip/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(QDELETED(target) || get_dist(controller.pawn, target) > 1)
		return
	var/datum/action/cooldown/slip = controller.blackboard[BB_DEMON_SLIP_ABILITY]
	if(!slip?.IsAvailable())
		return
	controller.queue_behavior(/datum/ai_behavior/use_mob_ability, BB_DEMON_SLIP_ABILITY)

#undef BB_DEMON_TELEPORT_ABILITY
#undef BB_DEMON_TELEPORT_DESTINATION
#undef BB_DEMON_SLIP_ABILITY
#undef BB_DEMON_CLONE_ABILITY
