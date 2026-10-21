// AQUILA - zgodność ścieżek Rdzy i Pustki heretyka z tg (system siły rdzy, rdzewienie turfów,
// leczenie na rdzy, burza pustki). Rdzeń woła tylko /atom/proc/rust_heretic_act(rust_strength).

// --- Defines z tg (code/__DEFINES/turfs.dm, _flags.dm, traits, colors)
#ifndef RUST_RESISTANCE_BASIC
#define RUST_RESISTANCE_BASIC 1
#endif
#ifndef RUST_RESISTANCE_REINFORCED
#define RUST_RESISTANCE_REINFORCED 2
#endif
#ifndef RUST_RESISTANCE_ABSOLUTE
#define RUST_RESISTANCE_ABSOLUTE 5
#endif
/// Flaga turf_flags - turf nigdy nie rdzewieje (u nas turfy nie mają turf_flags, dodane niżej)
#ifndef NO_RUST
#define NO_RUST (1<<0)
#endif
/// Mob/obiekt odporny na efekty rdzy heretyka
#ifndef TRAIT_RUSTIMMUNE
#define TRAIT_RUSTIMMUNE "rust_immune"
#endif
#ifndef MOVETYPES_NOT_TOUCHING_GROUND
#define MOVETYPES_NOT_TOUCHING_GROUND (FLYING|FLOATING)
#endif
#ifndef COLOR_RUSTED_GLASS
#define COLOR_RUSTED_GLASS "#917c65"
#endif
#ifndef IS_ROBOTIC_LIMB
#define IS_ROBOTIC_LIMB(limb) (limb.bodytype & BODYTYPE_ROBOTIC)
#endif

// --- Odporność turfów na rdzę (tg: /turf/var/rust_resistance i turf_flags & NO_RUST)

/turf
	///This turf's resistance to getting rusted
	var/rust_resistance = RUST_RESISTANCE_BASIC
	/// AQUILA - u nas tylko flaga NO_RUST
	var/turf_flags = NONE

/// Check if the heretic is strong enough to rust this turf, and if so, rusts the turf with an added visual effect.
/turf/rust_heretic_act(rust_strength = RUST_RESISTANCE_BASIC)
	if((rust_strength < rust_resistance))
		return FALSE

	if (rust_turf(magic = TRUE))
		new /obj/effect/glowing_rune(src)
		return TRUE
	return FALSE

/// Override this to change behaviour when being rusted
/turf/proc/rust_turf(magic = FALSE)
	if ((turf_flags & NO_RUST) || HAS_TRAIT(src, TRAIT_RUSTIMMUNE) || HAS_TRAIT(src, TRAIT_RUSTY))
		return FALSE
	AddElement(magic ? /datum/element/rust/heretic : /datum/element/rust)
	return TRUE

/turf/closed/wall/rust_turf(magic = FALSE)
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		ScrapeAway()
		return TRUE

	return ..()

/turf/closed/wall/r_wall
	rust_resistance = RUST_RESISTANCE_REINFORCED

/turf/closed/wall/r_wall/rust_turf(magic = FALSE)
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		ChangeTurf(/turf/closed/wall/rust)
		return TRUE
	return ..()

// u nas kadłub syndykatu to plastytan
/turf/closed/wall/r_wall/syndicate
	rust_resistance = RUST_RESISTANCE_TITANIUM

/turf/closed/wall/mineral/titanium
	rust_resistance = RUST_RESISTANCE_TITANIUM

/turf/closed/wall/mineral/titanium/rust_turf(magic = FALSE)
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		ChangeTurf(/turf/closed/wall/rust)
		return TRUE
	return ..()

/turf/closed/wall/mineral/plastitanium
	rust_resistance = RUST_RESISTANCE_TITANIUM

/turf/closed/wall/mineral/plastitanium/rust_turf(magic = FALSE)
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		ChangeTurf(/turf/closed/wall/rust)
		return TRUE
	return ..()

/turf/closed/wall/mineral/diamond
	rust_resistance = RUST_RESISTANCE_REINFORCED

/turf/closed/wall/mineral/uranium
	rust_resistance = RUST_RESISTANCE_REINFORCED

/turf/closed/wall/mineral/abductor
	rust_resistance = RUST_RESISTANCE_ORGANIC

/turf/closed/indestructible
	rust_resistance = RUST_RESISTANCE_ABSOLUTE
	turf_flags = NO_RUST

/turf/open/floor/rust_turf(magic = FALSE)
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		return FALSE
	// AQUILA - podtypów poszycia (np. airless) nie podmieniamy na zwykłe poszycie
	if(!istype(src, /turf/open/floor/plating))
		ChangeTurf(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
	return ..()

/turf/open/floor/engine
	rust_resistance = RUST_RESISTANCE_REINFORCED

/turf/open/floor/circuit
	rust_resistance = RUST_RESISTANCE_REINFORCED

/turf/open/floor/mineral/titanium
	rust_resistance = RUST_RESISTANCE_TITANIUM

/turf/open/floor/mineral/plastitanium
	rust_resistance = RUST_RESISTANCE_TITANIUM

/turf/open/floor/mineral/diamond
	rust_resistance = RUST_RESISTANCE_REINFORCED

/turf/open/floor/mineral/uranium
	rust_resistance = RUST_RESISTANCE_REINFORCED

/turf/open/floor/mineral/abductor
	rust_resistance = RUST_RESISTANCE_ORGANIC

/turf/open/floor/plating/abductor
	rust_resistance = RUST_RESISTANCE_ORGANIC

/turf/open/floor/grass
	rust_resistance = RUST_RESISTANCE_ORGANIC

// u nas grunty planet to podtypy poszycia (w tg /turf/open/misc z NO_RUST)
/turf/open/floor/plating/asteroid
	turf_flags = NO_RUST

/turf/open/floor/plating/ashplanet
	turf_flags = NO_RUST

/turf/open/floor/plating/beach
	turf_flags = NO_RUST

/turf/open/floor/plating/ice
	turf_flags = NO_RUST

/turf/open/floor/plating/dirt
	turf_flags = NO_RUST

/turf/open/floor/plating/ironsand
	turf_flags = NO_RUST

// holodek nie może zamieniać się w poszycie
/turf/open/floor/holofloor
	turf_flags = NO_RUST

/turf/open/water
	turf_flags = NO_RUST

/turf/open/chasm
	rust_resistance = RUST_RESISTANCE_ABSOLUTE
	turf_flags = NO_RUST

/turf/open/lava
	rust_resistance = RUST_RESISTANCE_ABSOLUTE
	turf_flags = NO_RUST

/turf/open/openspace
	rust_resistance = RUST_RESISTANCE_ABSOLUTE
	turf_flags = NO_RUST

/turf/open/space
	rust_resistance = RUST_RESISTANCE_ABSOLUTE
	turf_flags = NO_RUST

// --- Turfy zardzewiałe przez heretyka (do map, jak w tg)

/turf/open/floor/plating/heretic_rust
	color = COLOR_GREEN_GRAY

/turf/open/floor/plating/heretic_rust/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/rust/heretic)
	color = null

/turf/closed/wall/heretic_rust
	color = COLOR_GREEN_GRAY

/turf/closed/wall/heretic_rust/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/rust/heretic)
	color = null

/turf/closed/wall/r_wall/heretic_rust
	color = COLOR_GREEN_GRAY

/turf/closed/wall/r_wall/heretic_rust/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/rust/heretic)
	color = null

// --- Drzwi okienne (tg: windowdoor.dm)

/obj/machinery/door/window/rust_heretic_act(rust_strength)
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		return FALSE

	add_atom_colour(COLOR_RUSTED_GLASS, FIXED_COLOUR_PRIORITY)
	AddElement(/datum/element/rust)
	armor = getArmor()
	take_damage(obj_integrity * 0.5)
	return TRUE

// --- Mob i rdza (tg: atom_act.dm, mob_helpers.dm)

///wrapper proc that passes our mob's rust_strength to the target we are rusting
/mob/living/proc/do_rust_heretic_act(atom/target)
	var/datum/antagonist/heretic/heretic_data = GET_HERETIC(src)
	var/result = target.rust_heretic_act(heretic_data?.rust_strength)
	SEND_SIGNAL(src, COMSIG_MOB_RUST_HERETIC_ACT, target, result)

/// Returns true if the mob is on a rusty tile, really low level just because we call it in a bunch of unrelated places
/mob/proc/is_touching_rust(check_flying = FALSE)
	if (check_flying && (movement_type & MOVETYPES_NOT_TOUCHING_GROUND))
		return FALSE
	if (HAS_TRAIT(src, TRAIT_MAGICALLY_PHASED) || (movement_type & VENTCRAWLING))
		return FALSE
	var/turf/our_turf = get_turf(src)
	return HAS_TRAIT(our_turf, TRAIT_RUSTY)

// --- Rdza heretyka (tg: /datum/element/rust/heretic)

/// For rust applied by heretics
/datum/element/rust/heretic

/datum/element/rust/heretic/Attach(atom/target, rust_icon, rust_icon_state)
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE)
		return .
	RegisterSignal(target, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
	RegisterSignal(target, COMSIG_ATOM_EXITED, PROC_REF(on_exited))

/datum/element/rust/heretic/Detach(atom/source)
	. = ..()
	UnregisterSignal(source, COMSIG_ATOM_ENTERED)
	UnregisterSignal(source, COMSIG_ATOM_EXITED)
	for(var/obj/effect/glowing_rune/rune_to_remove in source)
		qdel(rune_to_remove)
	for(var/mob/living/victim in source)
		victim.remove_status_effect(/datum/status_effect/rust_corruption)

/datum/element/rust/heretic/proc/on_entered(turf/source, atom/movable/entered, ...)
	SIGNAL_HANDLER

	if (HAS_TRAIT(entered, TRAIT_RUSTIMMUNE) || HAS_TRAIT(entered, TRAIT_MAGICALLY_PHASED) || entered.movement_type & (MOVETYPES_NOT_TOUCHING_GROUND | VENTCRAWLING))
		return

	if(ismecha(entered))
		var/obj/mecha/victim = entered
		victim.take_damage(20, armour_penetration = 100)
		return
	if(!isliving(entered))
		return
	var/mob/living/victim = entered
	if(IS_HERETIC(victim))
		return
	if(victim.can_block_magic(MAGIC_RESISTANCE))
		return
	victim.apply_status_effect(/datum/status_effect/rust_corruption)

/datum/element/rust/heretic/proc/on_exited(turf/source, atom/movable/gone)
	SIGNAL_HANDLER
	if(!isliving(gone))
		return
	var/mob/living/leaver = gone
	leaver.remove_status_effect(/datum/status_effect/rust_corruption)

// --- Status rdzy pod nogami (tg: code/datums/status_effects/debuffs/rust_corruption.dm)

/datum/status_effect/rust_corruption
	alert_type = null
	id = "rust_turf_effects"
	tick_interval = 2 SECONDS
	remove_on_fullheal = TRUE

/datum/status_effect/rust_corruption/tick(seconds_between_ticks)
	if(issilicon(owner) || isbot(owner))
		owner.adjust_brute_loss(10 * seconds_between_ticks)
		return
	owner.adjust_disgust(5 * seconds_between_ticks)
	owner.reagents?.remove_all(0.75 * seconds_between_ticks)
	if(!iscarbon(owner))
		return
	var/mob/living/carbon/carbon_owner = owner
	for(var/obj/item/bodypart/robotic_limb as anything in carbon_owner.get_bodyparts())
		if(IS_ROBOTIC_LIMB(robotic_limb))
			robotic_limb.receive_damage(10)

// --- Leczenie na rdzy (tg: code/datums/elements/rust_healing.dm)

/// Buffs and heals the target while standing on rust.
/datum/element/rust_healing
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	/// How much HP to heal per second
	var/heal_amount
	/// How much stamina to heal per second
	var/stamina_heal_amount

/datum/element/rust_healing/Attach(atom/target, baton_resistance = TRUE, heal_amount = 3, stamina_heal_amount = 10)
	. = ..()
	if (!isliving(target))
		return COMPONENT_INCOMPATIBLE

	if (baton_resistance)
		RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(target, COMSIG_LIVING_LIFE, PROC_REF(on_life))

	src.heal_amount = heal_amount
	src.stamina_heal_amount = stamina_heal_amount
	ADD_TRAIT(target, TRAIT_RUSTIMMUNE, type)

/datum/element/rust_healing/Detach(atom/source)
	. = ..()
	UnregisterSignal(source, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_LIFE))
	REMOVE_TRAIT(source, TRAIT_RUSTIMMUNE, type)
	REMOVE_TRAIT(source, TRAIT_BATON_RESISTANCE, type)

/*
 * Signal proc for [COMSIG_MOVABLE_MOVED].
 *
 * Checks if we should have baton resistance on the new turf.
 */
/datum/element/rust_healing/proc/on_move(mob/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	if(source.is_touching_rust())
		ADD_TRAIT(source, TRAIT_BATON_RESISTANCE, type)
	else
		REMOVE_TRAIT(source, TRAIT_BATON_RESISTANCE, type)

/**
 * Signal proc for [COMSIG_LIVING_LIFE].
 *
 * Gradually heals the heretic ([source]) on rust,
 * including baton knockdown and stamina damage.
 */
/datum/element/rust_healing/proc/on_life(mob/living/source, seconds_per_tick)
	SIGNAL_HANDLER
	if(!source.is_touching_rust())
		return

	// Heals all damage + Stamina
	var/need_mob_update = FALSE
	var/delta_time = DELTA_WORLD_TIME(SSmobs) * 0.5 // SSmobs.wait is 2 secs, so this should be halved.
	need_mob_update += source.adjust_brute_loss(-heal_amount * delta_time, updating_health = FALSE)
	need_mob_update += source.adjust_fire_loss(-heal_amount * delta_time, updating_health = FALSE)
	need_mob_update += source.adjust_tox_loss(-heal_amount * delta_time, updating_health = FALSE, forced = TRUE) // Slimes are people too
	need_mob_update += source.adjust_oxy_loss(-heal_amount / 2 * delta_time, updating_health = FALSE)
	need_mob_update += source.adjust_stamina_loss(-stamina_heal_amount * delta_time, updating_stamina = FALSE)
	if(need_mob_update)
		source.updatehealth()
		new /obj/effect/temp_visual/heal(get_turf(source), COLOR_BROWN)
	// Reduces duration of stuns/etc
	source.AdjustAllImmobility((-0.5 SECONDS) * delta_time)
	// Heals blood loss
	source.adjust_blood_volume(2.5 * delta_time, maximum = BLOOD_VOLUME_NORMAL)
	// Slowly regulates your body temp
	source.adjust_bodytemperature((BODYTEMP_NORMAL - source.bodytemperature) / 5)

// --- Stożek zimna (tg: code/modules/spells/spell_types/cone/cone_of_cold.dm), baza dla Void Blast

/datum/action/cooldown/spell/cone/staggered/cone_of_cold
	name = "Cone of Cold"
	desc = "Wystrzeliwuje przed siebie mroźny stożek."

	school = SCHOOL_EVOCATION
	cooldown_time = 30 SECONDS

	invocation = "ISAGE!" // What killed the dinosaurs? THE ICE AGE
	invocation_type = INVOCATION_SHOUT

	cone_levels = 4
	respect_density = TRUE
	delay_between_level = 0.05 SECONDS

	/// What flags do we pass to MakeSlippery when affecting turfs?
	/// null / NONE / TURF_DRY means the turf is unaffected
	var/turf_freeze_type = TURF_WET_PERMAFROST
	/// How long do turfs remain slippery / frozen for?
	/// 0 seconds means the turf is unaffected, INFINITY means it's made perma-wet
	var/unfreeze_turf_duration = 45 SECONDS

	/// What status effect do we apply when affecting mobs?
	/// null means no status effect is applied
	var/datum/status_effect/frozen_status_effect_path = /datum/status_effect/freon
	/// How long do mobs remain frozen for?
	/// 0 seconds means no status effect is applied, INFINITY means infinite duration (or default duration of the status effect)
	var/unfreeze_mob_duration = 20 SECONDS
	/// How much brute do we apply on freeze?
	var/on_freeze_brute_damage = 10
	/// How much burn do we apply on freeze?
	var/on_freeze_burn_damage = 20

	/// How long do objects remain frozen for?
	/// 0 seconds mean no objects are frozen, INFINITY means infinite duration freeze
	var/unfreeze_object_duration = 20 SECONDS

/datum/action/cooldown/spell/cone/staggered/cone_of_cold/do_turf_cone_effect(turf/target_turf, atom/caster, level)
	if(!turf_freeze_type || unfreeze_turf_duration <= 0 SECONDS) // 0 duration = don't apply the slip
		return
	if(!isopenturf(target_turf))
		return
	var/turf/open/frozen_floor = target_turf
	frozen_floor.MakeSlippery(turf_freeze_type, unfreeze_turf_duration, permanent = (unfreeze_turf_duration == INFINITY))

/datum/action/cooldown/spell/cone/staggered/cone_of_cold/do_mob_cone_effect(mob/living/target_mob, atom/caster, level)
	if(target_mob.can_block_magic(antimagic_flags) || target_mob == caster || HAS_TRAIT(target_mob, TRAIT_RESISTCOLD))
		return

	if(ispath(frozen_status_effect_path) && unfreeze_mob_duration > 0 SECONDS) // 0 duration = don't apply the status effect
		var/datum/status_effect/freeze = target_mob.apply_status_effect(frozen_status_effect_path)
		// AQUILA - u nas duration to absolutny czas końca
		if(freeze && unfreeze_mob_duration != INFINITY)
			freeze.duration = world.time + unfreeze_mob_duration

	if(on_freeze_brute_damage || on_freeze_burn_damage)
		target_mob.take_overall_damage(on_freeze_brute_damage, on_freeze_burn_damage)

	to_chat(target_mob, span_userdanger("Czujesz przeszywający chłód!"))

/datum/action/cooldown/spell/cone/staggered/cone_of_cold/do_obj_cone_effect(obj/target_obj, atom/caster, level)
	if(unfreeze_object_duration <= 0 SECONDS) // 0 duration = don't apply a freeze
		return
	// AQUILA - u nas zamrażanie obiektów to make_frozen_visual()/make_unfrozen()
	if((target_obj.resistance_flags & FREEZE_PROOF) || (target_obj.obj_flags & FROZEN))
		return
	target_obj.make_frozen_visual()
	if(unfreeze_object_duration == INFINITY) // Infinity duration = don't set an unfreeze timer
		return
	addtimer(CALLBACK(target_obj, TYPE_PROC_REF(/obj, make_unfrozen)), unfreeze_object_duration)

// --- Burza pustki (tg: code/datums/proximity_monitor/fields/void_storm.dm)

/*!
 * Void storm for the void heretic ascension
 *
 * Follows the heretic around and acts like an aura with damaging effects for non-heretics
 */
/datum/proximity_monitor/advanced/void_storm
	// lazylist that keeps track of the overlays added
	var/list/turf_effects
	var/static/image/storm_overlay = image('icons/effects/weather_effects.dmi', "snow_storm")

/datum/proximity_monitor/advanced/void_storm/New(atom/_host, range, _ignore_if_not_on_turf)
	. = ..()
	recalculate_field()

/datum/proximity_monitor/advanced/void_storm/Destroy()
	. = ..()
	for(var/turf/target as anything in turf_effects)
		qdel(turf_effects[target])
	turf_effects = null

// AQUILA - u nas nie ma edge_is_a_field, więc krawędź liczymy jako zwykłe pole
/datum/proximity_monitor/advanced/void_storm/update_new_turfs()
	// "field_turfs"/"edge_turfs" - klucze FIELD_TURFS_KEY/EDGE_TURFS_KEY z field.dm (tam są #undef)
	. = list("field_turfs" = list(), "edge_turfs" = list())
	if(ignore_if_not_on_turf && !isturf(host.loc))
		return
	var/turf/center = get_turf(host)
	if(!center)
		return
	for(var/turf/target in RANGE_TURFS(current_range, center))
		.["field_turfs"] += target

/datum/proximity_monitor/advanced/void_storm/cleanup_field_turf(turf/target)
	. = ..()
	var/obj/effect/abstract/effect = LAZYACCESS(turf_effects, target)
	LAZYREMOVE(turf_effects, target)
	if(effect)
		qdel(effect)

/datum/proximity_monitor/advanced/void_storm/setup_field_turf(turf/target)
	. = ..()
	// AQUILA - nasz recalculate_field woła setup także dla pól, które już mają efekt, więc tylko odświeżamy przezroczystość
	var/obj/effect/abstract/effect = LAZYACCESS(turf_effects, target)
	if(!effect)
		effect = new(target) // Makes the field visible to players.
		effect.color = COLOR_BLACK
		effect.icon = storm_overlay.icon
		effect.icon_state = storm_overlay.icon_state
		effect.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		effect.layer = ABOVE_ALL_MOB_LAYER
		LAZYSET(turf_effects, target, effect)
	effect.alpha = 255 - get_dist(target, host.loc) * 23

/// AQUILA - pogoda pustki przy wniebowstąpieniu: jak w tg tylko efekt wizualny (obrażenia zadaje aura heretyka)
/datum/weather/void_storm/ascension
	weather_overlay = "light_snow"

/datum/weather/void_storm/ascension/weather_act(mob/living/L)
	return

/// AQUILA - tg wysyła COMSIG_ATOM_PRE_BULLET_ACT przed trafieniem pociskiem; u nas brak tego sygnału w rdzeniu
/mob/living/carbon/human/bullet_act(obj/item/projectile/P, def_zone, piercing_hit = FALSE)
	if(SEND_SIGNAL(src, COMSIG_ATOM_PRE_BULLET_ACT, P, def_zone) & COMPONENT_BULLET_PIERCED)
		return BULLET_ACT_FORCE_PIERCE
	return ..()

// --- Fala z portalu pustki (tg: temporary_visuals/miscellaneous.dm; bazowy circle_wave jest w _compat/bladecosmic.dm)

/obj/effect/temp_visual/circle_wave/void_conduit
	color = COLOR_FULL_TONER_BLACK
	duration = 12 SECONDS
	amount_to_scale = 12

// --- Osiągnięcia wzniesienia (tg: code/datums/achievements/misc_achievements.dm)
/datum/award/achievement/misc/rust_ascension
	name = "Hills of Rust"
	desc = "Przywołałeś kawałek Rdzawych Wzgórz, a Wzgórza cię przyjęły."
	database_id = "Rust"

/datum/award/achievement/misc/void_ascension
	name = "All that perish"
	desc = "Miejsce innego bytu, innego czasu. Tam wszystko się kończy... ale może to dopiero początek?"
	database_id = "Void"

/// AQUILA - u nas nie ma issnowturf (śnieg to podtypy poszycia i trawy)
/proc/is_heretic_snow_turf(turf/checked)
	return istype(checked, /turf/open/floor/plating/asteroid/snow) || istype(checked, /turf/open/floor/plating/snowed) || istype(checked, /turf/open/floor/grass/snow)
