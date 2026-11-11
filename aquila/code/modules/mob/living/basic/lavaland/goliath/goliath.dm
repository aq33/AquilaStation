// AQUILA: port of tgstation code/modules/mob/living/basic/lavaland/goliath/goliath.dm (tg 926bf40c5a) in place of our simple
// animal goliaths (/mob/living/simple_animal/hostile/asteroid/goliath, /beast, /beast/ancient). Polish lines, sprites and
// stats of our simple animals. Changes against tg:
// - our tentacles (grab and stun, aquila/code/modules/mob/living/basic/lavaland/goliath/tentacle.dm) instead of tg's
//   tentacle legcuffs; the tentacle line spawns them one tile at a time along the line;
// - riding like the cow (decision 3 of raport/mobabilities_03_pozostale.md): eating ash flora tames it (tameable component)
//   and the tamed goliath is ridden through our old riding component with the saddle sprite; no saddle item, no digging;
// - ancient = our old asteroid goliath sprite ("goliat"), immortal = our old ancient goliath ("pradawny goliat");
// - no emissives, no shovel hands, no change_force_on_death element (death() resets the forces).
/// Slow moving mob which attempts to immobilise its target
/mob/living/basic/mining/goliath
	name = "goliat"
	desc = "Potężna, opancerzona bestia z długimi wiciami wyginającymi się z grzbietu."
	icon_state = "goliath"
	icon_living = "goliath"
	icon_dead = "goliath_dead"
	icon_gib = "syndicate_gib"
	mouse_opacity = MOUSE_OPACITY_ICON
	gender = MALE // Female ones are the bipedal elites
	speed = 12
	maxHealth = 300
	health = 300
	friendly_verb_continuous = "zawodzi na"
	speak_emote = list("ryczy gromko")
	obj_damage = 100
	melee_damage = 25
	attack_sound = 'sound/weapons/punch1.ogg'
	attack_verb_continuous = "miażdży na proch"
	throw_blocked_message = "nie przebija twardej skóry"
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	crusher_loot = /obj/item/crusher_trophy/goliath_tentacle
	do_footstep = TRUE
	discovery_points = 2000
	ai_controller = /datum/ai_controller/basic_controller/goliath
	butcher_results = list(/obj/item/food/meat/slab/goliath = 2, /obj/item/stack/sheet/bone = 2)
	guaranteed_butcher_results = list(/obj/item/stack/sheet/animalhide/goliath_hide = 1)
	/// Icon state to use when tentacles are available
	var/tentacle_warning_state = "goliath2"
	/// Can this kind of goliath be tamed?
	var/tameable = TRUE
	/// Slight cooldown to prevent double-dipping if we use both abilities at once
	COOLDOWN_DECLARE(ability_animation_cooldown)
	/// Our base tentacles ability
	var/datum/action/cooldown/mob_cooldown/goliath_tentacles/tentacles
	/// Our melee tentacles ability
	var/datum/action/cooldown/mob_cooldown/tentacle_burst/melee_tentacles
	/// Our long-ranged tentacles ability
	var/datum/action/cooldown/mob_cooldown/tentacle_grasp/tentacle_line

/mob/living/basic/mining/goliath/Initialize(mapload)
	. = ..()
	var/static/list/goliath_foods = list(/obj/item/food/grown/ash_flora)
	AddElement(/datum/element/basic_eating, heal_amt = 10, food_types = goliath_foods)
	AddComponent(/datum/component/ai_target_timer)
	if (tameable)
		AddComponent(/datum/component/tameable, food_types = goliath_foods, tame_chance = 10, bonus_tame_chance = 5)

	var/datum/targeting_strategy/targeting = GET_TARGETING_STRATEGY(ai_controller.blackboard[BB_TARGETING_STRATEGY])
	tentacles = new(src)
	tentacles.Grant(src)
	melee_tentacles = new(src)
	melee_tentacles.Grant(src)
	AddComponent(/datum/component/revenge_ability, melee_tentacles, targeting = targeting, max_range = 1, target_self = TRUE)
	tentacle_line = new(src)
	tentacle_line.Grant(src)
	AddComponent(/datum/component/revenge_ability, tentacle_line, targeting = targeting, min_range = 2, max_range = 9)

	tentacles_ready()
	RegisterSignal(src, COMSIG_MOB_ABILITY_FINISHED, PROC_REF(used_ability))
	ai_controller.set_blackboard_key(BB_BASIC_FOODS, typecacheof(goliath_foods))
	ai_controller.set_blackboard_key(BB_GOLIATH_TENTACLES, tentacles)

/mob/living/basic/mining/goliath/Destroy()
	QDEL_NULL(tentacles)
	QDEL_NULL(melee_tentacles)
	QDEL_NULL(tentacle_line)
	return ..()

/mob/living/basic/mining/goliath/death(gibbed)
	move_force = MOVE_FORCE_DEFAULT
	move_resist = MOVE_RESIST_DEFAULT
	pull_force = PULL_FORCE_DEFAULT
	return ..()

/mob/living/basic/mining/goliath/revive(full_heal = FALSE, admin_revive = FALSE)
	. = ..()
	if(!.)
		return
	move_force = initial(move_force)
	move_resist = initial(move_resist)
	pull_force = initial(pull_force)

// Goliaths can summon tentacles more frequently as they take damage, scary.
/mob/living/basic/mining/goliath/adjust_health(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if (amount <= 0 || isnull(tentacles))
		return
	if (tentacles.cooldown_time > 1 SECONDS)
		tentacles.cooldown_time -= 1 SECONDS

/// A tamed goliath carries its tamer like a tamed cow
/mob/living/basic/mining/goliath/tamed(mob/living/tamer, atom/food)
	. = ..()
	new /obj/effect/temp_visual/heart(loc)
	setup_tamed_riding()
	add_overlay("goliath_saddled")

/// Copy the tamer's faction (tg SET_FACTION_AND_ALLIES_FROM), so the goliath does not grab the tamer's crewmates
/mob/living/basic/mining/goliath/befriend(mob/living/new_friend)
	. = ..()
	if(!.)
		return
	faction = new_friend.faction.Copy()
	faction |= REF(new_friend)

/// When we use an ability, activate some kind of visual tell
/mob/living/basic/mining/goliath/proc/used_ability(mob/living/source, datum/action/cooldown/ability)
	SIGNAL_HANDLER
	if (stat == DEAD || ability.IsAvailable())
		return // We died or the action failed for some reason like being out of range
	if (istype(ability, /datum/action/cooldown/mob_cooldown/goliath_tentacles))
		if (ability.cooldown_time <= 2 SECONDS)
			return
		icon_state = icon_living
		addtimer(CALLBACK(src, PROC_REF(tentacles_ready)), ability.cooldown_time - 2 SECONDS)
		return
	if (!COOLDOWN_FINISHED(src, ability_animation_cooldown))
		return
	COOLDOWN_START(src, ability_animation_cooldown, 2 SECONDS)
	playsound(src, 'sound/magic/demon_attack1.ogg', 50, TRUE)
	Shake(1, 0, 1.5 SECONDS)

/// Called slightly before tentacles ability comes off cooldown, as a warning
/mob/living/basic/mining/goliath/proc/tentacles_ready()
	if (stat == DEAD)
		return
	icon_state = tentacle_warning_state

/// A player in the goliath digs tentacles under something out of reach
/mob/living/basic/mining/goliath/RangedAttack(atom/atom_target, params)
	. = ..()
	tentacles?.Trigger(target = atom_target)

/// ...and sends a line of tentacles at it with the secondary click
/mob/living/basic/mining/goliath/ranged_secondary_attack(atom/atom_target, modifiers)
	tentacle_line?.Trigger(target = atom_target)

/// Legacy Goliath mob with different sprites, largely the same behaviour (our old asteroid goliath)
/mob/living/basic/mining/goliath/ancient
	name = "goliat"
	desc = "Masywna bestia, która chwyta ofiary długimi mackami. W żadnym wypadku nie zaleca się jej drażnić."
	icon_state = "Goliath"
	icon_living = "Goliath"
	icon_dead = "Goliath_dead"
	tentacle_warning_state = "Goliath_preattack"
	throw_blocked_message = "nie przebija skalistej skóry"
	tameable = FALSE

/// Rare Goliath variant which occasionally replaces the normal mining mob, releases shitloads of tentacles
/mob/living/basic/mining/goliath/ancient/immortal
	name = "pradawny goliat"
	desc = "Goliaty są biologicznie nieśmiertelne, a nieliczne okazy przeżyły całe stulecia. Ten jest wyraźnie pradawny, a jego macki nieustannie przeorują ziemię wokół."
	maxHealth = 400
	health = 400
	crusher_drop_chance = 30
	/// Don't re-check nearby turfs for this long
	COOLDOWN_DECLARE(retarget_turfs_cooldown)
	/// List of places we might spawn a tentacle, if we're alive
	var/list/tentacle_target_turfs

/mob/living/basic/mining/goliath/ancient/immortal/Life(seconds, times_fired)
	. = ..()
	if (stat == DEAD || !isturf(loc))
		return
	if (!LAZYLEN(tentacle_target_turfs) || COOLDOWN_FINISHED(src, retarget_turfs_cooldown))
		cache_nearby_turfs()
	for (var/turf/target_turf as anything in tentacle_target_turfs)
		if (is_blocked_turf(target_turf, exclude_mobs = TRUE))
			tentacle_target_turfs -= target_turf
			continue
		if (prob(10))
			new /obj/effect/temp_visual/goliath_tentacle(target_turf, src)

/mob/living/basic/mining/goliath/ancient/immortal/Moved(atom/OldLoc, Dir)
	. = ..()
	if (loc == OldLoc || stat == DEAD || !isturf(loc))
		return
	cache_nearby_turfs()

/// Store nearby turfs in our list so we can pop them out later
/mob/living/basic/mining/goliath/ancient/immortal/proc/cache_nearby_turfs()
	COOLDOWN_START(src, retarget_turfs_cooldown, 5 SECONDS)
	LAZYCLEARLIST(tentacle_target_turfs)
	for(var/turf/open/floor in orange(4, loc))
		LAZYADD(tentacle_target_turfs, floor)

/// Goliath of the cave generators: one in a hundred is an immortal one
/mob/living/basic/mining/goliath/random

/mob/living/basic/mining/goliath/random/Initialize(mapload)
	. = ..()
	if(prob(1))
		new /mob/living/basic/mining/goliath/ancient/immortal(loc)
		return INITIALIZE_HINT_QDEL
