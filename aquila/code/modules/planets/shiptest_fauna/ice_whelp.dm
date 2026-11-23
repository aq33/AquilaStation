// AQUILA: młody smok lodowy (ice whelp) - port of tgstation code/modules/mob/living/basic/icemoon/ice_whelp/ (ice_whelp.dm,
// ice_whelp_abilities.dm, ice_whelp_ai.dm; AGPLv3) on our basic mobs. Sprites: tgstation icons/mob/simple/icemoon/
// icemoon_monsters.dmi (CC BY-SA 3.0), copied to aquila/icons/planets/fauna/planet_fauna.dmi.
// Changes against tg:
// - the ice breath and the ice eruption are subtypes of our fire_breath (space_dragon.dm); the cold "fire" is a blue flame
//   visual that freezes and burns whoever it touches, not a hotspot (our atmos fire cannot burn below room temperature),
//   and the wind-up is a timer instead of tg's do_after;
// - tg's behaviour tree is rewritten on our planning subtrees: erupt when the target is close, breathe a line of cold fire
//   from further away, otherwise chomp;
// - no sculpting icy rocks or devouring dead whelps (tg), no crusher trophy; a dragon hide and bones as tg's butchering.

/// Blackboard keys of the whelp's breaths
#define BB_WHELP_STRAIGHTLINE_FIRE "BB_whelp_straightline_fire"
#define BB_WHELP_WIDESPREAD_FIRE "BB_whelp_widespread_fire"

/mob/living/basic/mining/ice_whelp
	name = "młody smok lodowy"
	desc = "Potomek lodowego smoka. Słaby w porównaniu z rodzicem, ale wciąż przerażający."
	icon = 'aquila/icons/planets/fauna/planet_fauna.dmi'
	icon_state = "ice_whelp"
	icon_living = "ice_whelp"
	icon_dead = "ice_whelp_dead"
	mouse_opacity = MOUSE_OPACITY_ICON
	butcher_results = list(
		/obj/item/stack/ore/diamond = 3,
		/obj/item/stack/sheet/animalhide/ashdrake = 1,
		/obj/item/stack/sheet/bone = 10,
		/obj/item/stack/sheet/sinew = 2,
	)
	speed = 12
	maxHealth = 300
	health = 300
	obj_damage = 40
	armour_penetration = 20
	melee_damage = 20
	attack_verb_continuous = "kłapie zębami na"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	death_message = "pada na bok."
	death_sound = 'sound/magic/demon_dies.ogg'
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	weather_immunities = list("snow", "lava", "ash")
	do_footstep = TRUE
	ai_controller = /datum/ai_controller/basic_controller/ice_whelp

/mob/living/basic/mining/ice_whelp/Initialize(mapload)
	. = ..()
	var/static/list/innate_actions = list(
		/datum/action/cooldown/mob_cooldown/fire_breath/ice = BB_WHELP_STRAIGHTLINE_FIRE,
		/datum/action/cooldown/mob_cooldown/fire_breath/ice/eruption = BB_WHELP_WIDESPREAD_FIRE,
	)
	grant_actions_by_list(innate_actions)

/mob/living/basic/mining/ice_whelp/death(gibbed)
	move_force = MOVE_FORCE_DEFAULT
	move_resist = MOVE_RESIST_DEFAULT
	pull_force = PULL_FORCE_DEFAULT
	return ..()

/// A player in the whelp breathes ice by clicking something out of reach
/mob/living/basic/mining/ice_whelp/RangedAttack(atom/target, modifiers)
	. = ..()
	var/datum/action/cooldown/mob_cooldown/fire_breath/ice/breath = ai_controller?.blackboard[BB_WHELP_STRAIGHTLINE_FIRE]
	breath?.Trigger(target = target)

/// Breathe "fire" in a line (it is freezing cold)
/datum/action/cooldown/mob_cooldown/fire_breath/ice
	name = "Lodowe tchnienie"
	desc = "Zionie linią lodowatego ognia w stronę wroga."
	cooldown_time = 6 SECONDS
	fire_range = 7
	fire_damage = 10
	fire_delay = 0.85
	shared_cooldown = NONE
	/// Body temperature the cold fire pulls its victims towards
	var/chill_temperature = 150
	/// Time to warn people about what we are doing
	var/forecast_delay = 0.6 SECONDS
	/// What turf are we aiming at
	var/turf/target_turf
	/// Icon state of the warning overlay
	var/forecast_overlay_state = "ice_whelp_telegraph_dir"
	/// The warning overlay while it is shown
	var/image/forecast_overlay

/datum/action/cooldown/mob_cooldown/fire_breath/ice/Destroy()
	target_turf = null
	forecast_overlay = null
	return ..()

/datum/action/cooldown/mob_cooldown/fire_breath/ice/attack_sequence(atom/target)
	target_turf = get_turf(target)
	if(!target_turf)
		return
	owner.face_atom(target_turf)
	owner.Shake(1, 0, forecast_delay)
	forecast_overlay = image('aquila/icons/planets/fauna/planet_fauna.dmi', forecast_overlay_state)
	forecast_overlay.setDir(get_dir(owner, target_turf))
	owner.add_overlay(forecast_overlay)
	addtimer(CALLBACK(src, PROC_REF(finish_forecast)), forecast_delay)

/// Wind-up over: breathe unless something stopped us
/datum/action/cooldown/mob_cooldown/fire_breath/ice/proc/finish_forecast()
	if(QDELETED(owner))
		return
	if(forecast_overlay)
		owner.cut_overlay(forecast_overlay)
		forecast_overlay = null
	var/mob/living/living_owner = owner
	if(!istype(living_owner) || living_owner.stat != CONSCIOUS || living_owner.incapacitated())
		target_turf = null
		return
	playsound(owner.loc, fire_sound, 200, TRUE)
	breath_attack()

/// Actually breathe
/datum/action/cooldown/mob_cooldown/fire_breath/ice/proc/breath_attack()
	owner.face_atom(target_turf)
	fire_line(target_turf)
	target_turf = null

/// Cold fire: a blue flame that freezes and burns, no atmos fire
/datum/action/cooldown/mob_cooldown/fire_breath/ice/burn_turf(turf/fire_turf, list/hit_list, mob/living/source)
	new /obj/effect/temp_visual/cold_fire(fire_turf)
	for(var/mob/living/frozen in fire_turf.contents)
		if(frozen in hit_list)
			continue
		hit_list |= frozen
		on_burn_mob(frozen, source)
	for(var/obj/mecha/robotron in fire_turf.contents)
		if(robotron in hit_list)
			continue
		hit_list |= robotron
		robotron.take_damage(mech_damage, BURN, "melee", 1)

/datum/action/cooldown/mob_cooldown/fire_breath/ice/on_burn_mob(mob/living/frozen, mob/living/source)
	to_chat(frozen, span_userdanger("Trafia cię lodowe tchnienie [source]!"))
	frozen.adjustFireLoss(fire_damage)
	frozen.adjust_bodytemperature(chill_temperature - frozen.bodytemperature)

/// Breathe cold fire in all directions, ring by ring
/datum/action/cooldown/mob_cooldown/fire_breath/ice/eruption
	name = "Lodowa erupcja"
	desc = "Wypuszcza lodowaty ogień we wszystkich kierunkach."
	cooldown_time = 6 SECONDS
	click_to_activate = FALSE
	fire_range = 3
	forecast_delay = 1 SECONDS
	fire_delay = 1.5
	forecast_overlay_state = "ice_whelp_telegraph_all"

/datum/action/cooldown/mob_cooldown/fire_breath/ice/eruption/breath_attack()
	target_turf = null
	var/turf/center = get_turf(owner)
	if(!center)
		return
	var/list/hit_list = list(owner)
	for(var/ring in 1 to fire_range)
		var/list/ring_turfs = list()
		for(var/turf/open/kindling in RANGE_TURFS(ring, center))
			if(get_dist(center, kindling) != ring || is_blocked_turf(kindling, exclude_mobs = TRUE))
				continue
			ring_turfs += kindling
		addtimer(CALLBACK(src, PROC_REF(burn_ring), ring_turfs, hit_list), (ring - 1) * fire_delay)

/datum/action/cooldown/mob_cooldown/fire_breath/ice/eruption/proc/burn_ring(list/ring_turfs, list/hit_list)
	if(QDELETED(owner))
		return
	for(var/turf/open/kindling as anything in ring_turfs)
		burn_turf(kindling, hit_list, owner)

/// The flame of the cold breath
/obj/effect/temp_visual/cold_fire
	name = "lodowaty ogień"
	icon = 'icons/effects/fire.dmi'
	icon_state = "1"
	color = "#7fd4ff"
	layer = ABOVE_MOB_LAYER
	duration = 1 SECONDS

/datum/ai_controller/basic_controller/ice_whelp
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/ice_whelp_eruption,
		/datum/ai_planning_subtree/targeted_mob_ability/ice_whelp_breath,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/// Erupt when the target is within two tiles
/datum/ai_planning_subtree/ice_whelp_eruption

/datum/ai_planning_subtree/ice_whelp_eruption/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(QDELETED(target) || get_dist(controller.pawn, target) > 2)
		return
	var/datum/action/cooldown/eruption = controller.blackboard[BB_WHELP_WIDESPREAD_FIRE]
	if(!eruption?.IsAvailable())
		return
	controller.queue_behavior(/datum/ai_behavior/use_mob_ability, BB_WHELP_WIDESPREAD_FIRE)
	return SUBTREE_RETURN_FINISH_PLANNING

/// Breathe a line of cold fire from 3-7 tiles
/datum/ai_planning_subtree/targeted_mob_ability/ice_whelp_breath
	ability_key = BB_WHELP_STRAIGHTLINE_FIRE
	finish_planning = FALSE

/datum/ai_planning_subtree/targeted_mob_ability/ice_whelp_breath/additional_ability_checks(datum/ai_controller/controller, datum/action/cooldown/using_action)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target) || !isturf(target.loc))
		return FALSE
	var/distance = get_dist(controller.pawn, target)
	return distance >= 3 && distance <= 7 && can_see(controller.pawn, target, 7)

#undef BB_WHELP_STRAIGHTLINE_FIRE
#undef BB_WHELP_WIDESPREAD_FIRE
