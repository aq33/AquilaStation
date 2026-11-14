// AQUILA: siarkodemon (brimdemon) - port of tgstation code/modules/mob/living/basic/lavaland/brimdemon/ (brimdemon.dm,
// brimbeam.dm, brimdemon_ai.dm; AGPLv3) on our basic mob system, for the lava planet fauna (Shiptest's lava biome and burrow
// spawn the brimdemon). Sprites: tgstation icons/mob/simple/lavaland/lavaland_monsters.dmi (CC BY-SA 3.0), copied to
// aquila/icons/planets/fauna/brimdemon.dmi.
// Changes against tg:
// - the beam ability does not sleep (our AI must not sleep in Activate()): tg waits in two do_after() calls, here timers run
//   the charge and the beam, TRAIT_IMMOBILIZED holds the demon still; being moved, incapacitated, killed or hit in melee
//   from the side or back breaks the charge and the beam, as tg's do_after() checks did; the beam keeps the direction it
//   was aimed in;
// - the AI is the pre-behaviour-tree tg controller (planning subtrees) with a port of tg's move_to_cardinal behaviour:
//   bite when adjacent, fire when lined up on a cardinal direction, otherwise walk to a tile in line with the target;
// - no brimdust decal, brimdust sac (monster cores) and ore sensor: we have no monster core system, the demon gives meat;
// - no emissive overlays, no crusher trophy (Shiptest's brimdemon fang), no claw footsteps (our footstep component);
// - the beam sound is our laser cannon (tg's brimdemon.ogg is not in our sound files).

/// Lavaland mob which tries to line up with its target and fire a laser
/mob/living/basic/mining/brimdemon
	name = "siarkodemon"
	desc = "Niestabilne stworzenie przypominające olbrzymią rogatą czaszkę. Na niemal każdy bodziec odpowiada wiązką piekielnej energii."
	icon = 'aquila/icons/planets/fauna/brimdemon.dmi'
	icon_state = "brimdemon"
	icon_living = "brimdemon"
	icon_dead = "brimdemon_dead"
	icon_gib = "syndicate_gib"
	speed = 3
	maxHealth = 250
	health = 250
	friendly_verb_continuous = "drapie"
	speak_emote = list("rechocze")
	melee_damage = 7.5
	attack_sound = 'sound/weapons/bite.ogg'
	melee_attack_cooldown = 0.6 SECONDS
	attack_vis_effect = ATTACK_EFFECT_BITE
	attack_verb_continuous = "gryzie"
	throw_blocked_message = "nieszkodliwie odbija się od"
	death_message = "zawodzi, gdy piekielna energia ucieka z jego ran, zostawiając pustą skorupę."
	death_sound = 'sound/magic/demon_dies.ogg'
	light_system = MOVABLE_LIGHT
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	light_power = 2
	light_range = 1.4
	discovery_points = 2000
	ai_controller = /datum/ai_controller/basic_controller/brimdemon
	butcher_results = list(/obj/item/food/meat/slab = 2)
	/// How we get blasting
	var/datum/action/cooldown/mob_cooldown/brimbeam/beam
	/// Icon state used when the brimbeam ability is being fired
	var/firing_icon_state = "brimdemon_firing"

/mob/living/basic/mining/brimdemon/Initialize(mapload)
	. = ..()
	beam = new(src)
	beam.Grant(src)
	ai_controller.set_blackboard_key(BB_TARGETED_ACTION, beam)

/mob/living/basic/mining/brimdemon/Destroy()
	QDEL_NULL(beam)
	return ..()

/// A player in the demon fires the beam by clicking something out of reach
/mob/living/basic/mining/brimdemon/RangedAttack(atom/target, modifiers)
	. = ..()
	beam?.Trigger(target = target)

/mob/living/basic/mining/brimdemon/death(gibbed)
	. = ..()
	if (gibbed || QDELETED(src) || !isturf(loc))
		return
	var/obj/effect/temp_visual/brim_burst/bang = new(loc)
	forceMove(bang)

/// Show a funny animation before doing an explosion
/obj/effect/temp_visual/brim_burst
	name = "pękający siarkodemon"
	icon = 'aquila/icons/planets/fauna/brimdemon.dmi'
	icon_state = "brimdemon_dead"
	duration = 1.9 SECONDS
	randomdir = FALSE

/obj/effect/temp_visual/brim_burst/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(bang)), duration - 1)
	animate(src, color = "#ff8888", transform = matrix().Scale(1.1), time = 0.7 SECONDS)
	animate(color = "#ffffff", transform = matrix(), time = 0.2 SECONDS)
	animate(color = "#ff4444", transform = matrix().Scale(1.3), time = 0.5 SECONDS)
	animate(color = "#ffffff", transform = matrix(), time = 0.2 SECONDS)
	animate(color = "#ff0000", transform = matrix().Scale(1.5), time = 0.3 SECONDS)

/obj/effect/temp_visual/brim_burst/Destroy()
	release_contents()
	return ..()

/// Make an explosion
/obj/effect/temp_visual/brim_burst/proc/bang()
	if (QDELETED(src))
		return
	var/turf/origin_turf = get_turf(src)
	if (isnull(origin_turf))
		return
	playsound(origin_turf, 'sound/effects/pop_expl.ogg', 50)
	new /obj/effect/temp_visual/explosion/fast(origin_turf)
	for (var/mob/living/target in range(1, origin_turf))
		var/armor = target.run_armor_check(attack_flag = "bomb", silent = TRUE)
		target.apply_damage(20, BURN, blocked = armor)
	release_contents()

/// Put the body back where we are
/obj/effect/temp_visual/brim_burst/proc/release_contents()
	var/atom/drop_spot = drop_location()
	for (var/atom/movable/thing as anything in contents)
		thing.forceMove(drop_spot)

/// Fires a bloody beam. Brimdemon Blast!
/datum/action/cooldown/mob_cooldown/brimbeam
	name = "Siarkowy podmuch"
	desc = "Wypuszcza nawałnicę piekielnej energii w wybranym kierunku."
	icon_icon = 'aquila/icons/planets/fauna/brimdemon.dmi'
	button_icon_state = "brimdemon_firing"
	background_icon_state = "bg_demon"
	click_to_activate = TRUE
	cooldown_time = 3 SECONDS
	melee_cooldown_time = 0
	shared_cooldown = NONE
	/// How far does our beam go?
	var/beam_range = 10
	/// How long does our beam last?
	var/beam_duration = 2 SECONDS
	/// How long do we wind up before firing?
	var/charge_duration = 1 SECONDS
	/// A list of all the beam parts.
	var/list/beam_parts = list()
	/// Direction the beam was aimed in
	var/beam_dir
	/// Timer of the charge, then of the beam
	var/blast_timer
	/// Are we charging or firing right now
	var/blasting = FALSE
	/// Charge warning overlay
	var/mutable_appearance/direction_overlay

/datum/action/cooldown/mob_cooldown/brimbeam/Destroy()
	stop_blast(start_cooldown = FALSE)
	return ..()

/datum/action/cooldown/mob_cooldown/brimbeam/Remove(mob/removed_from)
	stop_blast(start_cooldown = FALSE)
	return ..()

/datum/action/cooldown/mob_cooldown/brimbeam/Activate(atom/target)
	if (blasting)
		return FALSE
	StartCooldown(360 SECONDS)
	blasting = TRUE
	owner.face_atom(target)
	beam_dir = owner.dir
	owner.move_resist = MOVE_FORCE_VERY_STRONG
	owner.balloon_alert_to_viewers("ładuje...")
	direction_overlay = mutable_appearance('aquila/icons/planets/fauna/brimdemon.dmi', "brimdemon_telegraph_dir")
	owner.add_overlay(direction_overlay)
	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, REF(src))
	RegisterSignal(owner, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_owner_attacked))
	RegisterSignals(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_DEATH), PROC_REF(on_owner_disrupted))
	RegisterSignal(owner, COMSIG_MOB_INCAPACITATE_CHANGED, PROC_REF(on_owner_incapacitated))
	blast_timer = addtimer(CALLBACK(src, PROC_REF(finish_charge)), charge_duration, TIMER_STOPPABLE)
	return TRUE

/// Charged up, fire if nothing stopped us
/datum/action/cooldown/mob_cooldown/brimbeam/proc/finish_charge()
	blast_timer = null
	if (QDELETED(owner))
		return
	if (direction_overlay)
		owner.cut_overlay(direction_overlay)
		direction_overlay = null
	owner.setDir(beam_dir)
	if (!fire_laser())
		var/static/list/fail_emotes = list("kaszle.", "rzęzi.", "wypluwa kłąb czarnego dymu.")
		owner.manual_emote(pick(fail_emotes))
		stop_blast()
		return
	if (istype(owner, /mob/living/basic/mining/brimdemon))
		var/mob/living/basic/mining/brimdemon/demon = owner
		demon.icon_state = demon.firing_icon_state
	blast_timer = addtimer(CALLBACK(src, PROC_REF(stop_blast)), beam_duration, TIMER_STOPPABLE)

/// Being hit in melee from anywhere but the front stops the blast
/datum/action/cooldown/mob_cooldown/brimbeam/proc/on_owner_attacked(datum/source, atom/attacker, attack_flags, direction)
	SIGNAL_HANDLER
	if (!(attack_flags & ATTACK_RANGED) && !(direction & owner.dir))
		stop_blast()

/// Moved or killed: what tg's do_after() would have broken on
/datum/action/cooldown/mob_cooldown/brimbeam/proc/on_owner_disrupted(datum/source)
	SIGNAL_HANDLER
	stop_blast()

/// Stunned or knocked out: the other thing tg's do_after() would have broken on
/datum/action/cooldown/mob_cooldown/brimbeam/proc/on_owner_incapacitated(datum/source)
	SIGNAL_HANDLER
	var/mob/living/living_owner = owner
	if (!istype(living_owner) || living_owner.stat != CONSCIOUS || living_owner.incapacitated())
		stop_blast()

/// Is a blast being charged or fired
/datum/action/cooldown/mob_cooldown/brimbeam/proc/is_blasting()
	return blasting

/// End the charge or the beam and clean up
/datum/action/cooldown/mob_cooldown/brimbeam/proc/stop_blast(start_cooldown = TRUE)
	if (!blasting)
		return
	blasting = FALSE
	deltimer(blast_timer)
	blast_timer = null
	extinguish_laser()
	if (!owner)
		return
	if (direction_overlay)
		owner.cut_overlay(direction_overlay)
		direction_overlay = null
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, REF(src))
	UnregisterSignal(owner, list(COMSIG_ATOM_WAS_ATTACKED, COMSIG_MOVABLE_MOVED, COMSIG_LIVING_DEATH, COMSIG_MOB_INCAPACITATE_CHANGED))
	owner.move_resist = initial(owner.move_resist)
	if (istype(owner, /mob/living/basic/mining/brimdemon) && owner.stat != DEAD)
		var/mob/living/basic/mining/brimdemon/demon = owner
		demon.icon_state = demon.icon_living
	if (start_cooldown)
		StartCooldown()

/// Create a laser in the direction we are facing
/datum/action/cooldown/mob_cooldown/brimbeam/proc/fire_laser()
	owner.visible_message(span_danger("[owner] wystrzeliwuje siarkowy promień!"))
	playsound(owner, 'sound/weapons/lasercannonfire.ogg', 100, FALSE, 3)
	var/turf/origin_turf = get_turf(owner)
	var/turf/target_turf = get_ranged_target_turf(owner, beam_dir, beam_range)
	if (isnull(origin_turf) || isnull(target_turf))
		return FALSE
	var/list/affected_turfs = getline(origin_turf, target_turf) - origin_turf
	for (var/turf/affected_turf as anything in affected_turfs)
		if (affected_turf.opacity)
			break
		var/blocked = FALSE
		for (var/obj/potential_block in affected_turf)
			if (potential_block.opacity)
				blocked = TRUE
				break
		if (blocked)
			break
		var/obj/effect/brimbeam/new_brimbeam = new(affected_turf)
		new_brimbeam.dir = beam_dir
		beam_parts += new_brimbeam
		new_brimbeam.assign_creator(owner)
		for (var/mob/living/hit_mob in affected_turf)
			hit_mob.apply_damage(25, BURN, blocked = hit_mob.run_armor_check(null, "laser", silent = TRUE))
			to_chat(hit_mob, span_userdanger("Siarkowy promień [owner] przypieka cię!"))
		RegisterSignal(new_brimbeam, COMSIG_PARENT_QDELETING, PROC_REF(on_beam_part_deleted)) // In case idk a singularity eats it or something
	if (!length(beam_parts))
		return FALSE
	var/atom/last_brimbeam = beam_parts[length(beam_parts)]
	last_brimbeam.icon_state = "brimbeam_end"
	var/atom/first_brimbeam = beam_parts[1]
	first_brimbeam.icon_state = "brimbeam_start"
	return TRUE

/// A part of the beam went away before we were done
/datum/action/cooldown/mob_cooldown/brimbeam/proc/on_beam_part_deleted(datum/source)
	SIGNAL_HANDLER
	beam_parts -= source
	stop_blast()

/// Get rid of our laser when we are done with it
/datum/action/cooldown/mob_cooldown/brimbeam/proc/extinguish_laser()
	if (!length(beam_parts))
		return FALSE
	for (var/obj/effect/brimbeam/beam as anything in beam_parts)
		UnregisterSignal(beam, COMSIG_PARENT_QDELETING)
		beam.disperse()
	beam_parts = list()
	return TRUE

/// Segments of the actual beam, these hurt if you stand in them
/obj/effect/brimbeam
	name = "siarkowy promień"
	icon = 'aquila/icons/planets/fauna/brimdemon.dmi'
	icon_state = "brimbeam_mid"
	layer = ABOVE_MOB_LAYER
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	light_power = 2
	light_range = 2
	/// Who made us?
	var/datum/weakref/creator

/obj/effect/brimbeam/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/effect/brimbeam/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/effect/brimbeam/process()
	var/ignore = creator?.resolve()
	for (var/mob/living/hit_mob in get_turf(src))
		if (hit_mob != ignore)
			hit_mob.apply_damage(7, BURN, blocked = hit_mob.run_armor_check(null, "laser", silent = TRUE))

/// Ignore damage dealt to this mob
/obj/effect/brimbeam/proc/assign_creator(mob/living/maker)
	creator = WEAKREF(maker)

/// Disappear
/obj/effect/brimbeam/proc/disperse()
	animate(src, time = 0.5 SECONDS, alpha = 0)
	QDEL_IN(src, 0.5 SECONDS)

/**
 * Slap someone who is nearby, line up with target, blast with a beam
 */
/datum/ai_controller/basic_controller/brimdemon
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/call_reinforcements/mining,
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/brimdemon,
		/datum/ai_planning_subtree/targeted_mob_ability/brimbeam,
		/datum/ai_planning_subtree/move_to_cardinal/brimdemon,
	)

/// Is our brimdemon busy charging or firing its beam
/proc/brimdemon_blasting(datum/ai_controller/controller)
	var/datum/action/cooldown/mob_cooldown/brimbeam/beam = controller.blackboard[BB_TARGETED_ACTION]
	return istype(beam) && beam.is_blasting()

/// Bite only what is next to us, otherwise we keep our distance for the beam
/datum/ai_planning_subtree/basic_melee_attack_subtree/brimdemon

/datum/ai_planning_subtree/basic_melee_attack_subtree/brimdemon/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if (QDELETED(target) || get_dist(controller.pawn, target) > 1 || brimdemon_blasting(controller))
		return
	return ..()

/// Brimdemon's beam only fires when the target is lined up on a cardinal direction.
/datum/ai_planning_subtree/targeted_mob_ability/brimbeam
	/// How far away can we shoot from
	var/max_range = 9

/datum/ai_planning_subtree/targeted_mob_ability/brimbeam/additional_ability_checks(datum/ai_controller/controller, datum/action/cooldown/using_action)
	var/atom/target = controller.blackboard[target_key]
	if (QDELETED(target) || !isturf(target.loc))
		return FALSE
	if (get_dist(controller.pawn, target) > max_range)
		return FALSE
	return (get_dir(controller.pawn, target) in GLOB.cardinals)

/**
 * AQUILA: tg's move_to_cardinal (code/datums/ai/basic_mobs/basic_subtrees/move_to_cardinal.dm, before the behaviour tree
 * rewrite) on our planning subtrees: walk to the nearest free tile lined up with the target on a cardinal direction.
 */
/datum/ai_planning_subtree/move_to_cardinal
	/// Behaviour to execute to line ourselves up
	var/move_behaviour = /datum/ai_behavior/move_to_cardinal
	/// Blackboard key in which to store selected target
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET

/datum/ai_planning_subtree/move_to_cardinal/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	if (!controller.blackboard_key_exists(target_key))
		return
	controller.queue_behavior(move_behaviour, target_key)
	return SUBTREE_RETURN_FINISH_PLANNING

/// Move to a position where we can attack our target in a cardinal direction
/datum/ai_behavior/move_to_cardinal
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	required_distance = 0
	/// How close to our target is too close?
	var/minimum_distance = 1
	/// How far away is too far?
	var/maximum_distance = 9

/datum/ai_behavior/move_to_cardinal/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if (QDELETED(target) || !isturf(target.loc))
		return FALSE
	target_nearest_cardinal(controller, target)
	return TRUE

/// Set our movement target to the closest free tile in line with the target
/datum/ai_behavior/move_to_cardinal/proc/target_nearest_cardinal(datum/ai_controller/controller, atom/target)
	var/atom/move_target
	var/closest = INFINITY
	for (var/dir in GLOB.cardinals)
		var/turf/cardinal_turf = get_ranged_target_turf(target, dir, minimum_distance)
		if (isnull(cardinal_turf) || is_blocked_turf(cardinal_turf, exclude_mobs = TRUE))
			continue
		var/distance_to = get_dist(controller.pawn, cardinal_turf)
		if (distance_to >= closest)
			continue
		closest = distance_to
		move_target = cardinal_turf
	if (isnull(move_target))
		move_target = target
	set_movement_target(controller, move_target)

/datum/ai_behavior/move_to_cardinal/perform(delta_time, datum/ai_controller/controller, target_key)
	var/atom/target = controller.blackboard[target_key]
	if (QDELETED(target) || !isturf(target.loc))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/distance_to_target = get_dist(controller.pawn, target)
	if (distance_to_target > maximum_distance)
		return AI_BEHAVIOR_INSTANT
	if (!(get_dir(controller.pawn, target) in GLOB.cardinals) || distance_to_target < minimum_distance)
		target_nearest_cardinal(controller, target)
		return AI_BEHAVIOR_INSTANT
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/move_to_cardinal/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	if (!succeeded)
		return
	var/atom/target = controller.blackboard[target_key]
	var/mob/living/pawn = controller.pawn
	if (!QDELETED(target) && !brimdemon_blasting(controller))
		pawn.face_atom(target)

/datum/ai_planning_subtree/move_to_cardinal/brimdemon
	move_behaviour = /datum/ai_behavior/move_to_cardinal/brimdemon

/datum/ai_behavior/move_to_cardinal/brimdemon
	minimum_distance = 2
