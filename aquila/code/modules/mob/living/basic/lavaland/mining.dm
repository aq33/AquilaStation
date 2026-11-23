// AQUILA: port of tgstation code/modules/mob/living/basic/lavaland/mining.dm (tg 926bf40c5a, decision 3 of
// raport/mobabilities_03_pozostale.md). Polish lines and stats of our simple animal mining mobs
// (/mob/living/simple_animal/hostile/asteroid, which stays the base of the elites, the fugu and the curse blob).
// Changes against tg:
// - no ranged_armour element: shots under 30 damage that are not brute do a third of their damage and weak throws bounce
//   off, as for our simple animal mining mobs (tg: ×0.3 for everything under 30 except kinetic shots);
// - the crusher trophy goes through our crusher_damage status effect (crusher_loot element below);
// - no ashwalker faction (we have no ashwalkers on active maps), no lighting cutoff colours (our see_in_dark/lighting_alpha).

///prototype for mining mobs
/mob/living/basic/mining
	hardattacks = TRUE // nasty blocks (energy sword, chainsaw) do not hurt it, as our simple animal
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	combat_mode = TRUE
	status_flags = NONE //don't inherit standard basicmob flags
	mob_size = MOB_SIZE_LARGE
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	faction = list("mining")
	weather_immunities = list("lava", "ash")
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	obj_damage = 30
	discovery_points = 1000
	/// Message to output if throwing damage is absorbed
	var/throw_blocked_message = "odbija się od"
	/// What crusher trophy this mob drops, if any
	var/crusher_loot
	/// What is the chance the mob drops it if all their health was taken by crusher attacks
	var/crusher_drop_chance = 25
	/// Does this mob count for mining mob kills counter?
	var/kill_count = TRUE
	/// Do weak shots and throws hurt it less (tg: the ranged_armour element)
	var/ranged_armour = TRUE

/mob/living/basic/mining/Initialize(mapload)
	. = ..()
	if(crusher_loot)
		AddElement(/datum/element/crusher_loot, crusher_loot, crusher_drop_chance, basic_mob_flags & DEL_ON_DEATH)
	// relay_attackers comes with it: the AI retaliates and the abilities triggered by attacks hear about them
	AddElement(/datum/element/ai_retaliate)

/mob/living/basic/mining/death(gibbed)
	if(kill_count)
		SSblackbox.record_feedback("tally", "mobs_killed_mining", 1, type)
	return ..()

/// Reduces damage from most projectiles to curb off-screen kills (our simple animal mining mobs)
/mob/living/basic/mining/bullet_act(obj/item/projectile/P, def_zone, piercing_hit = FALSE)
	if(ranged_armour && P.damage < 30 && P.damage_type != BRUTE)
		P.damage = (P.damage / 3)
		visible_message(span_danger("[P] ma osłabione działanie na [src]!"))
	return ..()

/// No floor tiling them to death, wiseguy
/mob/living/basic/mining/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(ranged_armour && isitem(AM))
		var/obj/item/thrown_item = AM
		if(thrown_item.throwforce <= 20)
			visible_message(span_notice("[thrown_item.name] [throw_blocked_message] [name]!"))
			return
	return ..()

/**
 * Crusher Loot; makes the attached mob drop a crusher trophy if enough of its damage came from a kinetic crusher
 * (tg code/datums/elements/crusher_loot.dm, without replace_all and guaranteed drops, which no mining mob here uses).
 */
/datum/element/crusher_loot
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH
	id_arg_index = 2
	/// Path of the trophy dropped
	var/trophy_type
	/// Chance to drop the trophy, lowered by the mob only taking partial crusher damage instead of full
	var/drop_mod
	/// If true, will immediately spawn the item instead of putting it in butcher loot.
	var/drop_immediately

/datum/element/crusher_loot/Attach(datum/target, trophy_type, drop_mod = 25, drop_immediately = FALSE)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	src.trophy_type = trophy_type
	src.drop_mod = drop_mod
	src.drop_immediately = drop_immediately
	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/datum/element/crusher_loot/Detach(datum/target)
	UnregisterSignal(target, COMSIG_LIVING_DEATH)
	return ..()

/datum/element/crusher_loot/proc/on_death(mob/living/target, gibbed)
	SIGNAL_HANDLER
	var/datum/status_effect/crusher_damage/damage = target.has_status_effect(STATUS_EFFECT_CRUSHERDAMAGETRACKING)
	if(!damage || !prob((damage.total_damage / target.maxHealth) * drop_mod)) // on average, you'll need to kill 4 creatures before getting the item
		return
	if(drop_immediately)
		new trophy_type(target.drop_location())
		return
	LAZYSET(target.guaranteed_butcher_results, trophy_type, 1)

// AQUILA: basic mobs made by a spawner leave its list through on_basic_spawned_gone() (aquila/code/datums/components/spawner_basic.dm)
