// AQUILA: port of tgstation code/modules/mob/living/basic/lavaland/watcher/ (watcher.dm, watcher_ai.dm, tg 926bf40c5a) in place
// of our simple animal watchers (/mob/living/simple_animal/hostile/asteroid/basilisk/watcher and its wings). Polish lines,
// sprites, health and our frost/magma/ice projectiles (aquila/.../lavaland/watcher/watcher_projectiles.dm). Changes against
// tg: no diamond magnet (no magnet component here), no ready-to-shoot eye overlay or emissives, the tendril watcher is the
// plain one; `random` (cave generators) is a magmawing or an icewing one time in a hundred, as before.

/// A floating eyeball which keeps its distance and sometimes make you look away.
/mob/living/basic/mining/watcher
	name = "obserwator"
	desc = "Lewitujące, podobne do oka stworzenie, utrzymywane w powietrzu przez przypominające skrzydła sploty ścięgien. Z jego ciała wystaje ostry kryształowy kolec."
	icon = 'icons/mob/lavaland/watcher.dmi'
	icon_state = "watcher"
	icon_living = "watcher"
	icon_dead = "watcher_dead"
	icon_gib = "syndicate_gib"
	pixel_x = -10
	base_pixel_x = -10
	speak_emote = list("woła telepatycznie")
	speed = 3
	maxHealth = 200
	health = 200
	obj_damage = 60
	melee_damage = 15
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = "przebija"
	throw_blocked_message = "nieszkodliwie odbija się od"
	crusher_loot = /obj/item/crusher_trophy/watcher_wing
	discovery_points = 2000
	ai_controller = /datum/ai_controller/basic_controller/watcher
	butcher_results = list(/obj/item/stack/ore/diamond = 2, /obj/item/stack/sheet/sinew = 2, /obj/item/stack/sheet/bone = 1)
	/// How often can we shoot?
	var/ranged_cooldown = 3 SECONDS
	/// What kind of beams we got?
	var/projectile_type = /obj/item/projectile/temp/basilisk
	/// Sound to play when we shoot
	var/shoot_sound = 'sound/weapons/pierce.ogg'
	/// Typepath of our gaze ability
	var/gaze_attack = /datum/action/cooldown/mob_cooldown/watcher_gaze

/mob/living/basic/mining/watcher/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	AddComponent(/datum/component/ai_target_timer)
	AddComponent(/datum/component/ranged_attacks, projectile_type = projectile_type, projectile_sound = shoot_sound, cooldown_time = ranged_cooldown)

	var/datum/action/cooldown/mob_cooldown/watcher_gaze/gaze = new gaze_attack(src)
	gaze.Grant(src)
	ai_controller.set_blackboard_key(BB_GENERIC_ACTION, gaze)
	AddComponent(/datum/component/revenge_ability, gaze, targeting = GET_TARGETING_STRATEGY(ai_controller.blackboard[BB_TARGETING_STRATEGY]))

/// More durable, burning projectiles
/mob/living/basic/mining/watcher/magmawing
	name = "ogniskrzydły obserwator"
	desc = "Niektóre obserwatory wychowane bardzo blisko lawy przystosowują się do ekstremalnego gorąca i używają lawy zarówno jako broni, jak i skrzydeł."
	icon_state = "watcher_magmawing"
	icon_living = "watcher_magmawing"
	icon_dead = "watcher_magmawing_dead"
	maxHealth = 215 //Compensate for the lack of slowdown on projectiles with a bit of extra health
	health = 215
	light_system = MOVABLE_LIGHT
	light_range = 3
	light_power = 2.5
	light_color = LIGHT_COLOR_LAVA
	projectile_type = /obj/item/projectile/temp/basilisk/magmawing
	gaze_attack = /datum/action/cooldown/mob_cooldown/watcher_gaze/fire
	crusher_loot = /obj/item/crusher_trophy/blaster_tubes/magma_wing
	crusher_drop_chance = 60

/// Less durable, freezing projectiles
/mob/living/basic/mining/watcher/icewing
	name = "lodoskrzydły obserwator"
	desc = "Bardzo rzadko niektóre obserwatory wiodą nędzny żywot z dala od źródeł ciepła. Bez ciepła stają się lodowe i kruche, ale wystrzeliwują znacznie silniejsze mroźne podmuchy."
	icon_state = "watcher_icewing"
	icon_living = "watcher_icewing"
	icon_dead = "watcher_icewing_dead"
	maxHealth = 170
	health = 170
	projectile_type = /obj/item/projectile/temp/basilisk/icewing
	gaze_attack = /datum/action/cooldown/mob_cooldown/watcher_gaze/ice
	butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/bone = 1) //No sinew; the wings are too fragile to be usable
	crusher_loot = /obj/item/crusher_trophy/watcher_wing/ice_wing
	crusher_drop_chance = 30

/// Watcher of the cave generators: one in a hundred has magma or ice wings
/mob/living/basic/mining/watcher/random

/mob/living/basic/mining/watcher/random/Initialize(mapload)
	. = ..()
	if(prob(1))
		if(prob(75))
			new /mob/living/basic/mining/watcher/magmawing(loc)
		else
			new /mob/living/basic/mining/watcher/icewing(loc)
		return INITIALIZE_HINT_QDEL

/datum/ai_controller/basic_controller/watcher
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_RANGED_SKIRMISH_MIN_DISTANCE = 3,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 5,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/call_reinforcements/mining,
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/maintain_distance,
		/datum/ai_planning_subtree/use_mob_ability/gaze,
		/datum/ai_planning_subtree/ranged_skirmish/watcher,
	)

/datum/ai_planning_subtree/use_mob_ability/gaze
	finish_planning = TRUE

/datum/ai_planning_subtree/use_mob_ability/gaze/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/mob/living/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if (!isliving(target))
		return // Don't do this if there's nothing hostile around or if our target is a mech
	var/time_on_target = controller.blackboard[BB_BASIC_MOB_HAS_TARGET_TIME] || 0
	if (time_on_target < 5 SECONDS)
		return // We need to spend some time acquiring our target first
	return ..()

/datum/ai_planning_subtree/ranged_skirmish/watcher
	min_range = 0
