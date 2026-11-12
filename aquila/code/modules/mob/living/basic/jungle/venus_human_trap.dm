// AQUILA: port of tgstation code/modules/mob/living/basic/jungle/venus_human_trap.dm (tg 926bf40c5a) in place of our simple animal
// venus_human_trap.dm. Polish names and lines, health and damage of our simple animal.
// Changes against tg:
// - the kudzu flower bud stays ours: it grows the trap itself after 2 minutes (no ghost role spawner, no growth stages);
// - the trap keeps 50 health and 25 damage, and no damage away from kudzu (the bitrunning domain segment has no vines);
// - the tangle ability uses our leash component (heretic compat) and our Beam(); lifesteal heals 5 a hit as in tg;
// - no plant biotype, language holder or venus trap sounds (we have neither), the slash sound of our simple trap.
/obj/structure/alien/resin/flower_bud_enemy //inheriting basic attack/damage stuff from alien structures
	name = "pąk kwiatu"
	desc = "Duża pulsująca roślina..."
	icon = 'icons/effects/spacevines.dmi'
	icon_state = "flower_bud"
	layer = SPACEVINE_MOB_LAYER
	opacity = 0
	canSmoothWith = list()
	smooth = SMOOTH_FALSE
	var/growth_time = 1200
	pressure_resistance = 200

/obj/structure/alien/resin/flower_bud_enemy/Initialize(mapload)
	. = ..()
	var/list/anchors = list()
	anchors += locate(x-2,y+2,z)
	anchors += locate(x+2,y+2,z)
	anchors += locate(x-2,y-2,z)
	anchors += locate(x+2,y-2,z)

	for(var/turf/T in anchors)
		var/datum/beam/B = Beam(T, "vine", time=INFINITY, maxdistance=5, beam_type=/obj/effect/ebeam/vine)
		B.sleep_time = 10 //these shouldn't move, so let's slow down updates to 1 second (any slower and the deletion of the vines would be too slow)
	addtimer(CALLBACK(src, PROC_REF(bear_fruit)), growth_time)

/obj/structure/alien/resin/flower_bud_enemy/proc/bear_fruit()
	visible_message("<span class='danger'>roślina wydała owoc!</span>")
	new /mob/living/basic/venus_human_trap(get_turf(src))
	qdel(src)


/obj/effect/ebeam/vine
	name = "gruba winorośl"
	mouse_opacity = MOUSE_OPACITY_ICON
	desc = "Gruba winorośl, bolesna w dotyku."

/obj/effect/ebeam/vine/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/ebeam/vine/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	if(isliving(AM))
		var/mob/living/L = AM
		if(!("vines" in L.faction))
			L.adjustBruteLoss(5)
			to_chat(L, "<span class='alert'>Kaleczysz się o ciernistą winorośl.</span>")

/**
 * Venus Human Trap
 *
 * The result of a kudzu flower bud, these enemies use vines to drag prey close to them for attack.
 * Each one can attach temporary vines to objects or mobs and drag them around with it.
 * Once the prey is in melee range, melee attacks from the venus human trap heal it, assuming the target is alive.
 */
/mob/living/basic/venus_human_trap
	name = "ludzka muchołówka"
	desc = "Teraz wiesz, jak czuje się mucha."
	icon_state = "venus_human_trap"
	icon_living = "venus_human_trap"
	layer = SPACEVINE_MOB_LAYER
	health = 50
	maxHealth = 50
	obj_damage = 60
	melee_damage = 25
	melee_attack_cooldown = 1.2 SECONDS
	combat_mode = TRUE
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	basic_mob_flags = DEL_ON_DEATH
	death_message = "rozpada się na kawałki roślinnej materii."
	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 100
	unsuitable_heat_damage = 5 // heat damage is different from cold damage since coldmos is significantly more common than plasmafires
	unsuitable_cold_damage = 2 // they now do take cold damage, but this should be sufficiently small that it does not cause major issues
	pressure_resistance = 200
	faction = list(FACTION_HOSTILE, "vines", "plants")
	discovery_points = 2000
	ai_controller = /datum/ai_controller/basic_controller/human_trap

/mob/living/basic/venus_human_trap/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/lifesteal, 5)
	var/static/list/innate_actions = list(
		/datum/action/cooldown/mob_cooldown/projectile_attack/vine_tangle = BB_TARGETED_ACTION,
	)
	grant_actions_by_list(innate_actions)

/// A player trap grabs with its vines by clicking something out of reach in combat mode (harm intent in the old controls)
/mob/living/basic/venus_human_trap/RangedAttack(atom/victim, params)
	if(!combat_mode)
		return
	var/datum/action/cooldown/mob_cooldown/tangle_ability = ai_controller?.blackboard[BB_TARGETED_ACTION]
	if(!istype(tangle_ability))
		return
	tangle_ability.Trigger(target = victim)

/datum/action/cooldown/mob_cooldown/projectile_attack/vine_tangle
	name = "Oplątanie"
	desc = "Chwyta cel lepką winoroślą, dzięki czemu możesz go ciągnąć za sobą."
	icon_icon = 'icons/effects/spacevines.dmi'
	button_icon_state = "Light1"
	cooldown_time = 8 SECONDS
	/// An assoc list of all the plant's vines (beam = leash)
	var/list/datum/beam/vines = list()
	/// How far away a plant can attach a vine to something
	var/vine_grab_distance = 4
	/// how long does a vine attached to something last (and its leash) (lasts twice as long on nonliving things)
	var/vine_duration = 2 SECONDS

/datum/action/cooldown/mob_cooldown/projectile_attack/vine_tangle/Remove(mob/remove_from)
	for(var/datum/beam/vine as anything in vines)
		qdel(vines[vine])
		qdel(vine)
	vines.Cut()
	return ..()

/datum/action/cooldown/mob_cooldown/projectile_attack/vine_tangle/Activate(atom/movable/target_atom)
	if(!ismovable(target_atom) || istype(target_atom, /obj/structure/spacevine) || target_atom == owner)
		return FALSE
	if(target_atom.anchored)
		owner.balloon_alert(owner, "nie da się przyciągnąć!")
		return FALSE
	if(get_dist(owner, target_atom) > vine_grab_distance)
		owner.balloon_alert(owner, "za daleko!")
		return FALSE
	for(var/turf/blockage as anything in (getline(owner, target_atom) - list(get_turf(owner), get_turf(target_atom))))
		if(is_blocked_turf(blockage, exclude_mobs = TRUE))
			owner.balloon_alert(owner, "droga zablokowana!")
			return FALSE

	var/datum/beam/new_vine = owner.Beam(target_atom, "vine", time = vine_duration * (ismob(target_atom) ? 1 : 2), maxdistance = vine_grab_distance + 2, beam_type = /obj/effect/ebeam/vine)
	var/component = target_atom.AddComponent(/datum/component/leash, owner, vine_grab_distance)
	RegisterSignal(new_vine, COMSIG_PARENT_QDELETING, PROC_REF(remove_vine))
	vines[new_vine] = component
	if(isliving(target_atom))
		var/mob/living/victim = target_atom
		victim.Knockdown(2 SECONDS)
	StartCooldown()
	return TRUE

/**
 * Removes a vine from the list.
 * Called specifically when the vine is about to be destroyed, so we don't have any null references.
 */
/datum/action/cooldown/mob_cooldown/projectile_attack/vine_tangle/proc/remove_vine(datum/beam/vine)
	SIGNAL_HANDLER
	qdel(vines[vine])
	vines -= vine

/datum/ai_controller/basic_controller/human_trap
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability/continue_planning,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
