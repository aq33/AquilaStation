// AQUILA: port of tgstation code/modules/mob/living/basic/lavaland/legion/legion_brood.dm and spawn_legions.dm
// (tg 926bf40c5a) in place of our simple animal legion skull (/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion).
// Polish lines and stats of our simple animal. Changes against tg: one skull sprite (no random states, no emissives), the
// target_circle telegraph instead of tg's skull marker, infesting runs asynchronously (a human's death() can sleep),
// a dwarf is told by the dwarfism mutation (we have no TRAIT_DWARF), no despawn effect.

/// A spooky skull which heals lavaland mobs, attacks miners, and infests their bodies
/mob/living/basic/mining/legion_brood
	name = "legion"
	desc = "Jeden z wielu."
	icon_state = "legion_head"
	icon_living = "legion_head"
	icon_dead = "legion_head"
	icon_gib = "syndicate_gib"
	basic_mob_flags = DEL_ON_DEATH
	mob_size = MOB_SIZE_SMALL
	pass_flags = PASSTABLE | PASSMOB
	layer = ABOVE_MOB_LAYER
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	friendly_verb_continuous = "bzyczy przy"
	maxHealth = 1
	health = 1
	melee_damage = 12
	obj_damage = 0
	attack_verb_continuous = "gryzie"
	speak_emote = list("rozbrzmiewa echem")
	attack_sound = 'sound/weapons/pierce.ogg'
	throw_blocked_message = "zostaje strząśnięty przez"
	density = FALSE
	discovery_points = 0
	ai_controller = /datum/ai_controller/basic_controller/legion_brood
	kill_count = FALSE
	ranged_armour = FALSE
	/// Reference to a guy who made us
	var/datum/weakref/created_by

/mob/living/basic/mining/legion_brood/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	AddComponent(/datum/component/swarming, 12, 12)
	addtimer(CALLBACK(src, PROC_REF(death)), 10 SECONDS)

/mob/living/basic/mining/legion_brood/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	if (ishuman(target))
		var/mob/living/carbon/human/victim = target
		if (victim.stat > SOFT_CRIT)
			INVOKE_ASYNC(src, PROC_REF(infest), victim)
			return FALSE

	var/mob/living/mob_creator = created_by?.resolve()
	if(isnull(mob_creator))
		created_by = null

	if (isliving(target) && faction_check_mob(target) && !istype(target, mob_creator?.type))
		var/mob/living/living_target = target
		visible_message(span_warning("[src] stapia się z ciałem [living_target]!"))
		living_target.apply_status_effect(/datum/status_effect/regenerative_core)
		new /obj/effect/temp_visual/heal(get_turf(living_target), "#80F5FF")
		death()
		return FALSE
	return ..()

/// Turn the targeted mob into one of us
/mob/living/basic/mining/legion_brood/proc/infest(mob/living/carbon/human/target)
	if (QDELETED(src) || QDELETED(target) || stat == DEAD)
		return
	visible_message(span_warning("[name] wgryza się w ciało [target]!"))
	var/spawn_type = get_legion_type(target)
	var/mob/living/basic/mining/legion/new_legion = new spawn_type(target.loc)
	new_legion.consume(target)
	new_legion.faction = faction.Copy()
	qdel(src)

/// Returns the kind of legion we make out of the target
/mob/living/basic/mining/legion_brood/proc/get_legion_type(mob/living/carbon/human/target)
	if (target.dna?.check_mutation(DWARFISM))
		return /mob/living/basic/mining/legion/dwarf
	return /mob/living/basic/mining/legion

/// Sets someone as our creator, mostly so you can't use skulls to heal yourself
/mob/living/basic/mining/legion_brood/proc/assign_creator(mob/living/creator, copy_full_faction = TRUE)
	if (copy_full_faction)
		faction = creator.faction.Copy()
	else
		faction |= REF(creator)
	created_by = WEAKREF(creator)
	if (!ai_controller)
		return
	ai_controller.set_blackboard_key(BB_LEGION_BROOD_CREATOR, creator)
	if (!creator.ai_controller)
		return
	// Inherit our creator's target
	ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, creator.ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET])

/// Launches a skull at a distant location
/datum/action/cooldown/mob_cooldown/skull_launcher
	name = "Wystrzel legion"
	desc = "Wystrzeliwuje żywy kawałek twojego ciała w odległe miejsce."
	icon_icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	button_icon_state = "legion_head"
	background_icon_state = "bg_demon"
	click_to_activate = TRUE
	cooldown_time = 4 SECONDS
	melee_cooldown_time = 0
	shared_cooldown = NONE
	/// If a mob is not clicked directly, inherit targeting data from this blackboard key and setting it upon this target key
	var/ai_target_key = BB_BASIC_MOB_CURRENT_TARGET
	/// What are we actually spawning?
	var/spawn_type = /mob/living/basic/mining/legion_brood
	/// How far can we fire?
	var/max_range = 7

/datum/action/cooldown/mob_cooldown/skull_launcher/IsAvailable(feedback = FALSE)
	. = ..()
	if (!.)
		return
	if (!isturf(owner.loc))
		if (feedback)
			owner.balloon_alert(owner, "brak miejsca!")
		return FALSE
	return TRUE

/datum/action/cooldown/mob_cooldown/skull_launcher/Activate(atom/target)
	var/turf/target_turf = get_turf(target)
	if (isnull(target_turf))
		return FALSE

	if (get_dist(owner, target_turf) > max_range)
		target_turf = get_ranged_target_turf_direct(owner, target_turf, max_range)

	if (is_blocked_turf(target_turf))
		var/list/near_turfs = RANGE_TURFS(1, target_turf) - target_turf
		for (var/turf/check_turf as anything in near_turfs)
			if (is_blocked_turf(check_turf))
				near_turfs -= check_turf
		if (length(near_turfs))
			target_turf = pick(near_turfs)
		else if(is_blocked_turf(target_turf, exclude_mobs = TRUE))
			owner.balloon_alert(owner, "brak miejsca!")
			StartCooldown(0.5 SECONDS)
			return FALSE

	var/ai_target = isliving(target) ? target : null
	if (isnull(ai_target))
		ai_target = owner.ai_controller?.blackboard[ai_target_key]

	var/target_dir = get_dir(owner, target)

	var/obj/effect/temp_visual/legion_skull_depart/launch = new(get_turf(owner))
	launch.set_appearance(spawn_type)
	launch.dir = target_dir
	new /obj/effect/temp_visual/legion_brood_indicator(target_turf)
	var/obj/effect/temp_visual/legion_skull_land/land = new(target_turf)
	land.dir = target_dir
	land.set_appearance(spawn_type, CALLBACK(src, PROC_REF(spawn_skull), target_turf, ai_target))
	StartCooldown()
	return TRUE

/// Actually create a mob
/datum/action/cooldown/mob_cooldown/skull_launcher/proc/spawn_skull(turf/spawn_location, target)
	if (QDELETED(owner))
		return
	var/mob/living/basic/mining/legion_brood/brood = new spawn_type(spawn_location)
	if (istype(brood))
		brood.assign_creator(owner)
	if (!isnull(target))
		brood.ai_controller?.set_blackboard_key(ai_target_key, target)
		brood.face_atom(target)
	else
		brood.dir = get_dir(owner, spawn_location)

/// Animation for launching a skull
/obj/effect/temp_visual/legion_skull_depart
	name = "wystrzelony legion"
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "legion_head"
	duration = 0.25 SECONDS

/// Copy appearance from the passed atom type
/obj/effect/temp_visual/legion_skull_depart/proc/set_appearance(atom/spawned_type)
	icon = initial(spawned_type.icon)
	icon_state = initial(spawned_type.icon_state)
	animate(src, alpha = 0, pixel_y = 72, time = duration)

/// Animation for landing a skull
/obj/effect/temp_visual/legion_skull_land
	name = "lądujący legion"
	duration = 0.5 SECONDS
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "legion_head"
	alpha = 0
	pixel_y = 72

/// Copy appearance from the passed atom type and store what to do on animation complete
/obj/effect/temp_visual/legion_skull_land/proc/set_appearance(atom/spawned_type, datum/callback/on_completed)
	icon = initial(spawned_type.icon)
	icon_state = initial(spawned_type.icon_state)
	animate(src, alpha = 0, pixel_y = 72, time = duration / 2)
	animate(alpha = 255, pixel_y = 0, time = duration / 2)
	addtimer(on_completed, duration)

/// A skull is going to be here! Oh no!
/obj/effect/temp_visual/legion_brood_indicator
	name = "miejsce lądowania legionu"
	duration = 0.75 SECONDS
	layer = BELOW_MOB_LAYER
	icon = 'icons/mob/telegraphing/telegraph.dmi'
	icon_state = "target_circle"
	alpha = 0

/obj/effect/temp_visual/legion_brood_indicator/Initialize(mapload)
	. = ..()
	animate(src, alpha = 255, time = 0.5 SECONDS)
	animate(alpha = 0, time = 0.25 SECONDS)
