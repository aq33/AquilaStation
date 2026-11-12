// AQUILA: port of tgstation code/modules/mob/living/basic/lavaland/hivelord/ (tg 926bf40c5a) in place of our simple animal
// hivelord. Polish lines, sprites and health of our simple animal; ghosts can still take it over (playable, silent).
// Changes against tg: no clickbox component (the old opaque mouse_opacity instead), no despawn effect on the brood.

/// Mob which retreats and spawns annoying sub-mobs to attack you
/mob/living/basic/mining/hivelord
	name = "władca roju"
	desc = "Prawdziwie obca istota: nieustannie falująca masa nieznanej materii organicznej. Podczas ataku odrywają się od niej kawałki, które atakują razem z oryginałem."
	icon_state = "Hivelord"
	icon_living = "Hivelord"
	icon_dead = "Hivelord_dead"
	icon_gib = "syndicate_gib"
	mob_biotypes = list(MOB_ORGANIC)
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	speed = 2
	maxHealth = 75
	health = 75
	melee_damage = 0
	attack_verb_continuous = "rzuca się na"
	speak_emote = list("woła telepatycznie")
	attack_sound = 'sound/weapons/pierce.ogg'
	throw_blocked_message = "przelatuje prosto przez dziwne ciało"
	obj_damage = 0
	pass_flags = PASSTABLE
	discovery_points = 3000
	playable = TRUE
	should_talk = FALSE
	ai_controller = /datum/ai_controller/basic_controller/hivelord
	/// Mobs to spawn when we die, varedit this to be recursive to give the players a fun surprise
	var/death_spawn_type = /mob/living/basic/hivelord_brood
	/// Action which spawns worms
	var/datum/action/cooldown/mob_cooldown/hivelord_spawn/spawn_brood

/mob/living/basic/mining/hivelord/Initialize(mapload)
	. = ..()
	var/static/list/death_loot = list(/obj/item/organ/regenerative_core)
	AddElement(/datum/element/death_drops, death_loot)
	AddComponent(/datum/component/appearance_on_aggro, aggro_state = "Hivelord_alert")
	spawn_brood = new(src)
	spawn_brood.Grant(src)
	ai_controller.set_blackboard_key(BB_TARGETED_ACTION, spawn_brood)

/mob/living/basic/mining/hivelord/Destroy()
	QDEL_NULL(spawn_brood)
	return ..()

/mob/living/basic/mining/hivelord/attack_ghost(mob/dead/observer/user)
	. = ..()
	give_to_ghost(user, TRUE)

/mob/living/basic/mining/hivelord/death(gibbed)
	. = ..()
	mouse_opacity = MOUSE_OPACITY_ICON
	var/turf/our_turf = get_turf(src)
	if(isnull(our_turf))
		return
	var/list/safe_turfs = RANGE_TURFS(1, our_turf) - our_turf
	for (var/turf/check_turf as anything in safe_turfs)
		if (is_blocked_turf(check_turf, exclude_mobs = TRUE))
			safe_turfs -= check_turf

	for (var/i in 1 to 3)
		if (!length(safe_turfs))
			return
		var/turf/land_turf = pick_n_take(safe_turfs)
		var/obj/effect/temp_visual/hivebrood_spawn/forecast = new(land_turf)
		forecast.create_from(death_spawn_type, our_turf, CALLBACK(src, PROC_REF(complete_spawn), land_turf))

/// Spawns a worm on the specified turf
/mob/living/basic/mining/hivelord/proc/complete_spawn(turf/spawn_turf)
	var/mob/living/brood = new death_spawn_type(spawn_turf)
	brood.faction = faction.Copy()
	brood.ai_controller?.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, ai_controller?.blackboard[BB_BASIC_MOB_CURRENT_TARGET])
	brood.dir = get_dir(src, spawn_turf)

/// A player in the hivelord spawns brood by clicking something out of reach
/mob/living/basic/mining/hivelord/RangedAttack(atom/atom_target, params)
	. = ..()
	spawn_brood?.Trigger(target = atom_target)

/// Basically just keep away and shit out worms
/datum/ai_controller/basic_controller/hivelord
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_AGGRO_RANGE = 5, // Only get mad at people nearby
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/maintain_distance,
		/datum/ai_planning_subtree/targeted_mob_ability,
	)

/// Attack worms spawned by the hivelord
/mob/living/basic/hivelord_brood
	name = "pomiot władcy roju"
	desc = "Fragment władcy roju, który wspiera swój oryginał. Pojedynczy nie stanowi większego zagrożenia, ale..."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Hivelordbrood"
	icon_living = "Hivelordbrood"
	icon_dead = "Hivelordbrood"
	icon_gib = "syndicate_gib"
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	friendly_verb_continuous = "bzyczy przy"
	mob_size = MOB_SIZE_SMALL
	basic_mob_flags = DEL_ON_DEATH
	pass_flags = PASSTABLE | PASSMOB
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	faction = list("mining")
	weather_immunities = list("lava", "ash")
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY
	speed = 1.5
	maxHealth = 1
	health = 1
	melee_damage = 2
	attack_verb_continuous = "tnie"
	speak_emote = list("woła telepatycznie")
	attack_sound = 'sound/weapons/pierce.ogg'
	obj_damage = 0
	density = FALSE
	discovery_points = 0
	ai_controller = /datum/ai_controller/basic_controller/simple_hostile

/mob/living/basic/hivelord_brood/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	AddComponent(/datum/component/swarming)
	addtimer(CALLBACK(src, PROC_REF(death)), 10 SECONDS)
