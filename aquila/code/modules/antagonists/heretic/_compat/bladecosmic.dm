// AQUILA - zgodność ścieżek Blade i Cosmic heretyka z tg: pola kosmiczne, ślady, arena Wolves Among Sheep,
// pomocnicze typy z tg i drobne nadpisania rdzenia potrzebne tym ścieżkom.

// U nas isstargazer() to rasa galaretowatych (jelly/stargazer). Kod heretyka z tg rozumie przez to moba Star Gazer,
// więc poszerzamy makro: działa dla obu (pliki rdzenia skompilowane wcześniej używają starej wersji).
#ifdef isstargazer
#undef isstargazer
#endif
#define isstargazer(A) (istype(A, /mob/living/simple_animal/hostile/heretic_summon/star_gazer) || is_species(A, /datum/species/jelly/stargazer))

#ifndef HERETIC_ARENA_TRAIT
#define HERETIC_ARENA_TRAIT "heretic_arena"
#endif

/// Id modyfikatora prędkości z pól kosmicznych (tg: /datum/movespeed_modifier/cosmic_field)
#define MOVESPEED_ID_COSMIC_FIELD "cosmic_field"

/// Tryby rozkazów Star Gazera
#define STAR_GAZER_COMMAND_FREE "free"
#define STAR_GAZER_COMMAND_FOLLOW "follow"
#define STAR_GAZER_COMMAND_IDLE "idle"
#define STAR_GAZER_COMMAND_ATTACK "attack"

// ---------------------------------------------------------------------------
// Ogólne helpery z tg

///Checks to see if `atom/source` is behind `atom/target`
/proc/check_behind(atom/source, atom/target)
	// Let's see if source is behind target
	// "Behind" is defined as 3 tiles directly to the back of the target
	// x . .
	// x > .
	// x . .

	// We'll take "same tile" as "behind" for ease
	if(target.loc == source.loc)
		return TRUE

	// We'll also assume lying down is behind, as mob directions when lying are unclear
	if(isliving(target))
		var/mob/living/living_target = target
		if(!(living_target.mobility_flags & MOBILITY_STAND))
			return TRUE

	// Exceptions aside, let's actually check if they're, yknow, behind
	var/dir_target_to_source = get_dir(target, source)
	if(target.dir & REVERSE_DIR(dir_target_to_source))
		return TRUE

	return FALSE

/**
 * ## Death link component
 *
 * When the owner of this component dies it also gibs a linked mob
 */
/datum/component/death_linked
	///The mob that also dies when the user dies
	var/datum/weakref/linked_mob

/datum/component/death_linked/Initialize(mob/living/target_mob)
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	if(isnull(target_mob))
		stack_trace("[type] added to [parent] with no linked mob.")
	src.linked_mob = WEAKREF(target_mob)

/datum/component/death_linked/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_MOB_DEATH, PROC_REF(on_death))

/datum/component/death_linked/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_MOB_DEATH)

///signal called by the stat of the target changing
/datum/component/death_linked/proc/on_death(mob/living/target, gibbed)
	SIGNAL_HANDLER
	var/mob/living/linked_mob_resolved = linked_mob?.resolve()
	linked_mob_resolved?.gib()

// Bazowy /obj/effect/temp_visual/circle_wave jest w aquila/code/game/objects/effects/temporary_visuals/circle_wave.dm
/obj/effect/temp_visual/circle_wave/star_blast
	color = COLOR_VOID_PURPLE

// Osiągnięcia wzniesienia (tg: code/datums/achievements/misc_achievements.dm)
/datum/award/achievement/misc/blade_ascension
	name = "Silver and Steel"
	desc = "Zostałeś mistrzem wszystkich pojedynkowiczów - wzorem ostrzy."
	database_id = "Blade"

/datum/award/achievement/misc/cosmic_ascension
	name = "It arrived"
	desc = "Udało ci się sprowadzić na stację istotę, której naprawdę nie powinno tu być."
	database_id = "Cosmos"

// ---------------------------------------------------------------------------
// Nadpisania rdzenia

// tg wysyła ten sygnał przy każdej aktualizacji zdrowia (używa go Stance of the Torn Champion)
/mob/living/updatehealth()
	. = ..()
	SEND_SIGNAL(src, COMSIG_LIVING_HEALTH_UPDATE)

// Węglowcy nie wołają ..() w updatehealth(), więc osobno
/mob/living/carbon/updatehealth()
	. = ..()
	SEND_SIGNAL(src, COMSIG_LIVING_HEALTH_UPDATE)

// tg: drabiny pytają o pozwolenie (arena Wolves Among Sheep blokuje ucieczkę po drabinie)
/obj/structure/ladder/travel(going_up, mob/user, is_ghost, obj/structure/ladder/ladder, needs_do_after = TRUE)
	if(!is_ghost && (SEND_SIGNAL(user, COMSIG_LADDER_TRAVEL, src, ladder, going_up) & LADDER_TRAVEL_BLOCK))
		return FALSE
	return ..()

/// Cecha: krwawienie z ran jest słabsze (Stance of the Torn Champion; u nas nie ma ran z tg, więc działamy na krwawieniu)
#define TRAIT_HERETIC_BLEED_RESISTANCE "heretic_bleed_resistance"

// Odpowiednik ran z tg: TRAIT_NEVER_WOUNDED nie krwawi wcale, TRAIT_HARDLY_WOUNDED i odporność pojedynkowicza osłabiają krwawienie
/mob/living/carbon/add_bleeding(bleed_level)
	if(HAS_TRAIT(src, TRAIT_NEVER_WOUNDED))
		return
	if(HAS_TRAIT(src, TRAIT_HERETIC_BLEED_RESISTANCE))
		bleed_level *= 0.6
	if(HAS_TRAIT(src, TRAIT_HARDLY_WOUNDED))
		bleed_level *= 0.5
	return ..(bleed_level)

// ---------------------------------------------------------------------------
// Pola kosmiczne (tg: code/game/objects/effects/forcefields.dm)

GLOBAL_LIST_EMPTY(active_cosmic_fields)

/// TRUE, jeśli w pobliżu atomu jest pole kosmiczne blokujące wybuchy (pasywka Cosmic poziom 2)
/proc/cosmic_field_disrupts(atom/thing)
	var/turf/our_turf = get_turf(thing)
	if(!our_turf)
		return FALSE
	for(var/obj/effect/forcefield/cosmic_field/potential_field as anything in GLOB.active_cosmic_fields)
		if(potential_field.z != our_turf.z)
			continue
		if(get_dist(potential_field, our_turf) < 3)
			new /obj/effect/temp_visual/revenant(our_turf)
			return TRUE
	return FALSE

/// The cosmic heretics forcefield
/obj/effect/forcefield/cosmic_field
	name = "Cosmic Field"
	desc = "Pole, przez które nie przejdzie nikt naznaczony kosmiczną gwiazdą."
	icon = 'aquila/icons/effects/eldritch.dmi'
	icon_state = "cosmic_carpet"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	layer = 2.85 // tg GIB_LAYER
	density = FALSE
	CanAtmosPass = ATMOS_PASS_NO
	timeleft = 30 SECONDS
	/// Flags for what antimagic can just ignore our forcefields
	var/antimagic_flags = MAGIC_RESISTANCE
	/// If we are able to slow down projectiles
	var/slows_projectiles = FALSE

/obj/effect/forcefield/cosmic_field/Initialize(mapload, flags = MAGIC_RESISTANCE)
	. = ..(mapload)
	antimagic_flags = flags
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
		COMSIG_ATOM_EXITED = PROC_REF(on_loc_exited),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	// Make sure that if we create a field, we apply whatever effects
	for(var/atom/movable/thing in get_turf(src))
		on_entered(src, thing)

/obj/effect/forcefield/cosmic_field/Destroy(force)
	// Make sure when the field goes away that the effects don't persist
	for(var/atom/movable/thing in get_turf(src))
		on_loc_exited(src, thing)
	GLOB.active_cosmic_fields -= src
	return ..()

/obj/effect/forcefield/cosmic_field/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(!isliving(mover))
		return
	var/mob/living/living_mover = mover
	if(living_mover.can_block_magic(antimagic_flags))
		return
	// Being buckled/pulled by a cosmic heretic will allow you through cosmic fields EVEN IF you have a star mark
	if(ismob(living_mover.buckled))
		var/mob/living/fireman = living_mover.buckled
		if(fireman.has_status_effect(/datum/status_effect/heretic_passive/cosmic))
			return
	if(isliving(living_mover.pulledby))
		var/mob/living/puller = living_mover.pulledby
		if(puller.has_status_effect(/datum/status_effect/heretic_passive/cosmic))
			return
	if(living_mover.has_status_effect(/datum/status_effect/star_mark))
		return FALSE

/obj/effect/forcefield/cosmic_field/proc/on_entered(datum/source, atom/movable/thing)
	SIGNAL_HANDLER
	if(istype(thing, /obj/item/projectile))
		if(!slows_projectiles)
			return
		var/obj/item/projectile/bullet = thing
		if(istype(bullet, /obj/item/projectile/magic/star_ball)) // Don't slow down star balls
			return
		bullet.speed /= 0.2 // 80% Slowdown (u nas speed to czas na pole, więc dzielimy)
		return

	if(!isliving(thing))
		return
	var/mob/living/living_mover = thing
	if(!living_mover.has_status_effect(/datum/status_effect/heretic_passive/cosmic))
		return
	living_mover.add_movespeed_modifier(MOVESPEED_ID_COSMIC_FIELD, update = TRUE, priority = 100, multiplicative_slowdown = -0.25, override = TRUE)

/obj/effect/forcefield/cosmic_field/proc/on_loc_exited(datum/source, atom/movable/thing)
	SIGNAL_HANDLER
	if(istype(thing, /obj/item/projectile))
		if(!slows_projectiles)
			return
		var/obj/item/projectile/bullet = thing
		if(istype(bullet, /obj/item/projectile/magic/star_ball)) // Don't speed up star balls
			return
		bullet.speed *= 0.2
		return

	if(!isliving(thing))
		return
	var/mob/living/living_mover = thing
	if(!living_mover.has_status_effect(/datum/status_effect/heretic_passive/cosmic))
		return
	// Na następnym polu też może być pole kosmiczne
	var/turf/new_turf = get_turf(living_mover)
	if(new_turf && new_turf != get_turf(src) && (locate(/obj/effect/forcefield/cosmic_field) in new_turf))
		return
	living_mover.remove_movespeed_modifier(MOVESPEED_ID_COSMIC_FIELD)

/// Adds the ability to slow down any projectiles that enters any turf we occupy
/obj/effect/forcefield/cosmic_field/proc/slows_projectiles()
	slows_projectiles = TRUE

/// Adds our cosmic field to the global list which bombs check to see if they have to stop exploding
/obj/effect/forcefield/cosmic_field/proc/prevents_explosions()
	GLOB.active_cosmic_fields |= src

/obj/effect/forcefield/cosmic_field/star_blast
	timeleft = 5 SECONDS

/obj/effect/forcefield/cosmic_field/star_touch
	timeleft = 30 SECONDS

/obj/effect/forcefield/cosmic_field/fast
	timeleft = 5 SECONDS

/obj/effect/forcefield/cosmic_field/extrafast
	timeleft = 2.5 SECONDS

// Pola kosmiczne z ulepszeniem gaszą granaty, bomby syndykatu i zawory transferowe (tg robi to w plikach tych przedmiotów)
/obj/item/grenade/prime(mob/living/lanced_by)
	if(cosmic_field_disrupts(src))
		active = FALSE
		update_icon()
		return FALSE
	return ..()

/obj/machinery/syndicatebomb/process()
	if(active && cosmic_field_disrupts(src))
		active = FALSE
		visible_message(span_warning("[src] gaśnie, tłumiony przez kosmiczną energię!"))
	return ..()

/obj/item/transfer_valve/toggle_valve(manual = FALSE)
	if(!valve_open && tank_one && tank_two && cosmic_field_disrupts(src))
		return
	return ..()

// ---------------------------------------------------------------------------
// Ślad z efektów (tg: code/datums/elements/effect_trail.dm)

/*
 * An element used for making a trail of effects appear behind a movable atom when it moves.
 */
/datum/element/effect_trail
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	/// The effect used for the trail generation.
	var/chosen_effect

/datum/element/effect_trail/Attach(datum/target, chosen_effect = /obj/effect/forcefield/cosmic_field)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(generate_effect))
	src.chosen_effect = chosen_effect

/datum/element/effect_trail/Detach(datum/target)
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
	return ..()

/// Generates an effect
/datum/element/effect_trail/proc/generate_effect(atom/movable/target_object)
	SIGNAL_HANDLER

	var/turf/open/open_turf = get_turf(target_object)
	if(!istype(open_turf))
		return
	new chosen_effect(open_turf)

/// If we are a cosmic heretic, this will return the appropriate effect trail based on our passive level. returns the default trail otherwise
/proc/cosmic_trail_based_on_passive(mob/living/source)
	if(isstargazer(source))
		return /datum/element/effect_trail/cosmic_field/antiprojectile

	var/datum/status_effect/heretic_passive/cosmic/cosmic_passive = source.has_status_effect(/datum/status_effect/heretic_passive/cosmic)
	if(!cosmic_passive)
		return /datum/element/effect_trail/cosmic_field
	if(cosmic_passive.passive_level == 3)
		return /datum/element/effect_trail/cosmic_field/antiprojectile
	if(cosmic_passive.passive_level == 2)
		return /datum/element/effect_trail/cosmic_field/antiexplosion
	return /datum/element/effect_trail

/datum/element/effect_trail/cosmic_field // Cosmic field subtype which applies any upgrades
	var/prevents_explosions = FALSE
	var/slows_projectiles = FALSE

/datum/element/effect_trail/cosmic_field/Attach(datum/target, chosen_effect)
	. = ..()
	if(!ispath(chosen_effect, /obj/effect/forcefield/cosmic_field))
		stack_trace("Tried to attach a cosmic_field effect trail with a non-cosmic field as the chosen effect")

/datum/element/effect_trail/cosmic_field/generate_effect(atom/movable/target_object)
	var/turf/open/open_turf = get_turf(target_object)
	if(!istype(open_turf))
		return
	var/obj/effect/forcefield/cosmic_field/new_field = new chosen_effect(open_turf)

	if(prevents_explosions)
		new_field.prevents_explosions()
	if(slows_projectiles)
		new_field.slows_projectiles()

/datum/element/effect_trail/cosmic_field/antiexplosion
	prevents_explosions = TRUE

/datum/element/effect_trail/cosmic_field/antiprojectile
	prevents_explosions = TRUE
	slows_projectiles = TRUE

// ---------------------------------------------------------------------------
// Arena Wolves Among Sheep (tg: code/datums/proximity_monitor/fields/heretic_arena.dm)

GLOBAL_LIST_EMPTY(heretic_arenas)

// Invisible effect that doesnt exist outside of containing the prox monitor
/obj/effect/abstract/heretic_arena
	icon = null
	icon_state = null
	alpha = 0
	invisibility = INVISIBILITY_ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	/// Proximity monitor that handles the effects we are looking for
	var/datum/proximity_monitor/advanced/heretic_arena/arena

/obj/effect/abstract/heretic_arena/Initialize(mapload, range, duration, caster)
	. = ..()
	arena = new(src, range, TRUE, caster)
	QDEL_IN(src, duration)
	GLOB.heretic_arenas += src

/obj/effect/abstract/heretic_arena/Destroy(force)
	QDEL_NULL(arena)
	GLOB.heretic_arenas -= src
	return ..()

/datum/proximity_monitor/advanced/heretic_arena
	/// Reference to the caster, the spell collapses if they leave the arena
	var/arena_caster
	/// List of mobs inside our arena
	var/list/contained_mobs = list()
	/// List of border walls we have placed on the edges of the monitor
	var/list/border_walls = list()
	/// List of blades we've so generously handed out to the participants
	var/list/welfare_blades = list()
	/// List of immunities given to our combatants
	var/static/list/given_immunities = list(
		TRAIT_BOMBIMMUNE,
		TRAIT_IGNORESLOWDOWN,
		TRAIT_NO_SLIP_ALL,
		TRAIT_NOBREATH,
		TRAIT_PIERCEIMMUNE,
		TRAIT_PUSHIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_SHOCKIMMUNE,
		TRAIT_SLEEPIMMUNE,
		TRAIT_STUNIMMUNE,
	)

/datum/proximity_monitor/advanced/heretic_arena/New(atom/_host, range, _ignore_if_not_on_turf, caster)
	arena_caster = caster // przed recalculate_field
	. = ..()
	recalculate_field()
	for(var/mob/living/carbon/human/human_in_range in range(range, _host))
		if(get_dist(human_in_range, _host) >= range) // na krawędzi stoi już ściana
			continue
		human_in_range.add_traits(given_immunities, HERETIC_ARENA_TRAIT)
		contained_mobs += human_in_range
		if(!IS_HERETIC(human_in_range))
			var/obj/item/melee/sickly_blade/training/new_blade = new(get_turf(human_in_range))
			welfare_blades += new_blade
			INVOKE_ASYNC(human_in_range, TYPE_PROC_REF(/mob, put_in_hands), new_blade)
			to_chat(human_in_range, span_boldbig("Ucieczka jest niemożliwa. Jedyne wyjście to pokonać innego uczestnika tej walki na śmierć i życie."))
			human_in_range.balloon_alert(human_in_range, "zacznij zabijać!")
		human_in_range.apply_status_effect(/datum/status_effect/arena_tracker)
		RegisterSignal(human_in_range, COMSIG_LADDER_TRAVEL, PROC_REF(on_try_ladder))
		RegisterSignal(human_in_range, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_pre_move))
		RegisterSignal(human_in_range, COMSIG_MOVABLE_MOVED, PROC_REF(on_participant_moved))

/datum/proximity_monitor/advanced/heretic_arena/Destroy()
	for(var/mob/living/carbon/human/mob in contained_mobs)
		mob.remove_traits(given_immunities, HERETIC_ARENA_TRAIT)
		mob.remove_status_effect(/datum/status_effect/arena_tracker)
		UnregisterSignal(mob, list(COMSIG_LADDER_TRAVEL, COMSIG_MOVABLE_PRE_MOVE, COMSIG_MOVABLE_MOVED))
		to_chat(mob, span_boldbig("Twoja żądza krwi została zaspokojona."))
		mob.balloon_alert(mob, "uciekaj z areny!")
	contained_mobs.Cut()
	for(var/turf/to_restore in border_walls)
		to_restore.ChangeTurf(border_walls[to_restore])
	border_walls.Cut()
	for(var/obj/to_refund as anything in welfare_blades)
		qdel(to_refund)
	welfare_blades.Cut()
	arena_caster = null
	return ..()

/datum/proximity_monitor/advanced/heretic_arena/setup_edge_turf(turf/target)
	. = ..()
	if(target in border_walls)
		return
	var/old_turf = target.type
	// Mob na krawędzi zostaje wypchnięty do środka, żeby nie utknął w ścianie
	for(var/mob/living/stuck in target)
		stuck.forceMove(get_step_towards(target, host))
	target.ChangeTurf(/turf/closed/indestructible/heretic_wall)
	border_walls[target] = old_turf

// Pola krawędzi nie sprzątamy przy przeliczaniu - ściany znikają dopiero w Destroy()
/datum/proximity_monitor/advanced/heretic_arena/cleanup_edge_turf(turf/target)
	if(!QDELETED(src) && (target in border_walls))
		return
	return ..()

/datum/proximity_monitor/advanced/heretic_arena/field_edge_uncrossed(atom/movable/movable, turf/location)
	if(!isliving(movable))
		return
	var/mob/living/living_mob = movable
	// Opuszczamy pole krawędzi; jeśli idziemy na zewnątrz, to wyszliśmy z areny
	if(get_dist(living_mob, host) <= current_range)
		return
	on_left_arena(living_mob)

/// Ktoś (zwycięzca) opuścił arenę
/datum/proximity_monitor/advanced/heretic_arena/proc/on_left_arena(mob/living/living_mob)
	addtimer(CALLBACK(living_mob, TYPE_PROC_REF(/mob/living, remove_status_effect), /datum/status_effect/arena_tracker), 10 SECONDS)
	living_mob.remove_traits(given_immunities, HERETIC_ARENA_TRAIT)
	if(living_mob == arena_caster)
		QDEL_IN(host, 3 SECONDS)

/// Prevents using ladders
/datum/proximity_monitor/advanced/heretic_arena/proc/on_try_ladder(mob/living/climber)
	SIGNAL_HANDLER
	var/datum/status_effect/arena_tracker/tracker = climber.has_status_effect(/datum/status_effect/arena_tracker)
	if(tracker?.arena_victor)
		return NONE
	return LADDER_TRAVEL_BLOCK

/// Blokuje zejście/wejście na inne piętro (tg: COMSIG_CAN_Z_MOVE)
/datum/proximity_monitor/advanced/heretic_arena/proc/on_pre_move(atom/movable/mover, atom/newloc)
	SIGNAL_HANDLER
	var/turf/new_turf = get_turf(newloc)
	if(new_turf && mover.z && new_turf.z != mover.z)
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/// If our caster teleports away (after winning presumably) we'll collapse the arena so that it doens't needlessly linger
/datum/proximity_monitor/advanced/heretic_arena/proc/on_participant_moved(atom/movable/mover, atom/old_loc)
	SIGNAL_HANDLER
	if(QDELETED(host))
		return
	// Zwykły krok przez krawędź obsługuje field_edge_uncrossed; tu łapiemy teleporty i inne skoki
	if(get_dist(mover, host) <= current_range && mover.z == host.z)
		return
	if(get_dist(old_loc, host) >= current_range && old_loc?.z == host.z)
		return
	if(mover == arena_caster)
		qdel(host)
		return
	on_left_arena(mover)

/turf/closed/indestructible/heretic_wall
	name = "eldritch wall"
	desc = "Ściana zamykająca owce wśród wilków. Lśni złowrogą energią - lepiej jej nie szturchać."
	icon = 'aquila/icons/turf/walls/heretic_arena_wall.dmi'
	icon_state = "eldritch_forcewall"
	opacity = FALSE
	pass_flags_self = NONE // No PASSCLOSEDTURF because only arena victors are allowed to go in or out

/turf/closed/indestructible/heretic_wall/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(isliving(mover))
		var/mob/living/living_mover = mover
		var/datum/status_effect/arena_tracker/tracker = living_mover.has_status_effect(/datum/status_effect/arena_tracker)
		if(tracker?.arena_victor)
			return TRUE

/turf/closed/indestructible/heretic_wall/Bumped(atom/movable/bumped_atom)
	. = ..()
	if(!isliving(bumped_atom))
		return
	var/mob/living/living_mob = bumped_atom
	var/atom/target = get_edge_target_turf(living_mob, get_dir(src, living_mob))
	living_mob.throw_at(target, 4, 5)
	to_chat(living_mob, span_userdanger("Ściana odpycha cię z ogromną siłą!"))

/**
 * Status applied to every mob in the heretic arena.
 * Tracks the last person to damage owner.
 * When owner enters crit, we send a signal to last_attacker status so they can leave the arena
 */
/datum/status_effect/arena_tracker
	id = "arena_tracker"
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	/// Tracks number of people crit
	var/crit_count = 0
	/// Tracks the last person who dealt damage to this mob
	var/datum/weakref/last_attacker
	/// If our mob is free to leave, set to true
	var/arena_victor = FALSE
	/// The overlay for our mob, changes color to indicate that they are a victor and are free to leave
	var/mutable_appearance/crown_overlay

/datum/status_effect/arena_tracker/on_apply()
	RegisterSignal(owner, COMSIG_MOB_STATCHANGE, PROC_REF(on_enter_crit))
	RegisterSignal(owner, COMSIG_ATOM_HITBY, PROC_REF(on_hitby))
	RegisterSignal(owner, COMSIG_PARENT_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(owner, list(COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_ATTACK_PAW), PROC_REF(on_attack_hand))
	RegisterSignal(owner, COMSIG_ATOM_ATTACK_ANIMAL, PROC_REF(on_attack_hand))
	RegisterSignal(owner, COMSIG_ATOM_BULLET_ACT, PROC_REF(on_bullet_act))
	owner.add_traits(list(TRAIT_ELDRITCH_ARENA_PARTICIPANT, TRAIT_NO_TELEPORT), TRAIT_STATUS_EFFECT(id))
	crown_overlay = mutable_appearance('aquila/icons/mob/effects/crown.dmi', "arena_fighter", -HALO_LAYER)
	crown_overlay.pixel_y = 24
	owner.add_overlay(crown_overlay)
	return TRUE

/datum/status_effect/arena_tracker/on_remove()
	UnregisterSignal(owner, list(COMSIG_MOB_STATCHANGE, COMSIG_ATOM_HITBY, COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_ATTACK_PAW, COMSIG_ATOM_ATTACK_ANIMAL, COMSIG_ATOM_BULLET_ACT))
	owner.remove_traits(list(TRAIT_ELDRITCH_ARENA_PARTICIPANT, TRAIT_NO_TELEPORT), TRAIT_STATUS_EFFECT(id))
	owner.cut_overlay(crown_overlay)
	crown_overlay = null

/// Called when you crit somebody to update your crown
/datum/status_effect/arena_tracker/proc/on_crit_somebody()
	owner.cut_overlay(crown_overlay)
	crown_overlay = mutable_appearance('aquila/icons/mob/effects/crown.dmi', "arena_victor", -HALO_LAYER)
	crown_overlay.pixel_y = 24
	owner.add_overlay(crown_overlay)
	owner.remove_traits(list(TRAIT_ELDRITCH_ARENA_PARTICIPANT, TRAIT_NO_TELEPORT), TRAIT_STATUS_EFFECT(id))
	crit_count++

	// The mansus celebrates your efforts
	if(IS_HERETIC(owner))
		// enemies are given 17 force 0 ap blades, heretics have 50 armor: meaning 30 healing reverses about 4 hits of damage
		owner.heal_overall_damage(round(30 / crit_count, DAMAGE_PRECISION), round(30 / crit_count, DAMAGE_PRECISION))
		owner.adjust_tox_loss(round(-20 / crit_count, DAMAGE_PRECISION), forced = TRUE) // Slime heretics everywhere...
		owner.adjust_oxy_loss(round(-20 / crit_count, DAMAGE_PRECISION), forced = TRUE)
		if(iscarbon(owner))
			var/mob/living/carbon/carbon_owner = owner
			carbon_owner.cauterise_wounds()
		if(crit_count == 3)
			var/datum/antagonist/heretic/our_heretic = GET_HERETIC(owner)
			var/datum/heretic_knowledge/spell/wolves_among_sheep/our_knowledge = our_heretic?.get_knowledge(/datum/heretic_knowledge/spell/wolves_among_sheep)
			our_knowledge?.add_charges(1)

	if(arena_victor) // No need to spam if we've already killed at least 1 person
		return
	if(IS_HERETIC(owner))
		to_chat(owner, span_big(span_hypnophrase("Mansus jest zadowolony z twojego występu, możesz już odejść.")))
	else
		to_chat(owner, span_big(span_hypnophrase("Dobrze się spisałeś, możesz już odejść.")))
	arena_victor = TRUE

// If our last attacker is an arena participant, we let them know they've scored a critical hit
/datum/status_effect/arena_tracker/proc/on_enter_crit(mob/source, new_stat)
	SIGNAL_HANDLER
	if(new_stat < SOFT_CRIT)
		return
	if(!last_attacker)
		return // Safety check in case they somehow enter crit with *nobody* attacking them
	var/mob/living/our_attacker = last_attacker.resolve()
	if(!isliving(our_attacker) || our_attacker == owner) // We don't allow people to crit themselves as a valid way to escape
		return
	var/datum/status_effect/arena_tracker/their_tracker = our_attacker.has_status_effect(/datum/status_effect/arena_tracker)
	if(!their_tracker)
		return // Somebody killed us who isn't an arena participant
	their_tracker.on_crit_somebody()

// U nas sygnał obrażeń nie niesie broni, więc śledzimy atakującego po samych atakach
/datum/status_effect/arena_tracker/proc/set_attacker(mob/attacker)
	if(ismob(attacker) && attacker != owner)
		last_attacker = WEAKREF(attacker)

/datum/status_effect/arena_tracker/proc/on_attackby(datum/source, obj/item/weapon, mob/living/user)
	SIGNAL_HANDLER
	set_attacker(user)

/datum/status_effect/arena_tracker/proc/on_attack_hand(datum/source, mob/user)
	SIGNAL_HANDLER
	set_attacker(user)

/datum/status_effect/arena_tracker/proc/on_bullet_act(datum/source, obj/item/projectile/hitting_projectile)
	SIGNAL_HANDLER
	if(istype(hitting_projectile))
		set_attacker(hitting_projectile.firer)

///Called when impacted by something thrown at us, setting the last attacker to the person throwing the item.
/datum/status_effect/arena_tracker/proc/on_hitby(datum/source, atom/movable/hitting, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	// Track being hit by a mob throwing a stick
	if(!isitem(hitting) || !throwingdatum)
		return
	set_attacker(throwingdatum.thrower)
