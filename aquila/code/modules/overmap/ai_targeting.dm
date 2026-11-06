/// AQUILA - tactical target switching: upstream AI keeps its first target until it loses it. Now every few seconds the commander
/// looks at what it can see and switches to a clearly better target: whoever is shooting at us, a crippled ship to finish off,
/// something close enough for the guns, or a target our weapons suit (fighters for flak boats, big hulls for torpedo boats).
/// Reckless commanders rarely look around (target fixation), cautious ones care most about who is shooting them.
/// Part of AI morale (ai_morale.dm), switched with it (Debug > Toggle AI morale).

#define AI_TEMPERAMENT_CAUTIOUS "ostrożny"
#define AI_TEMPERAMENT_RECKLESS "brawurowy"

/// How often the commander reconsiders its target
#define AI_RETARGET_INTERVAL (4 SECONDS)
/// A new target has to score this much more than the current one, so ships do not flip every check
#define AI_RETARGET_MARGIN 25
/// After a switch the commander sticks with the new target at least this long (the sandbox showed ships flipping back and forth)
#define AI_RETARGET_COMMIT (12 SECONDS)
/// Chance per check that a reckless commander looks around at all
#define AI_RETARGET_RECKLESS_CHANCE 25
/// Someone who hit us this recently counts as shooting at us
#define AI_ATTACKER_MEMORY (15 SECONDS)
/// Score parts
#define AI_TARGET_BASE 100
#define AI_TARGET_PER_TILE 1
#define AI_TARGET_GUN_REACH 25
#define AI_TARGET_IN_GUN_REACH 20
#define AI_TARGET_CRIPPLED 40
#define AI_TARGET_ATTACKER 50
#define AI_TARGET_PAINTING_US 25
#define AI_TARGET_SUITS_TORPEDOES 15
#define AI_TARGET_SUITS_FLAK 40
#define AI_TARGET_FIGHTER_PENALTY 30
#define AI_TARGET_FLAGSHIP 10

/obj/structure/overmap
	/// AQUILA - lazy list, ship => world.time it last hit us
	var/list/ai_attackers
	var/ai_next_retarget = 0

/obj/structure/overmap/bullet_act(obj/item/projectile/P)
	var/obj/structure/overmap/shooter = P?.overmap_firer
	. = ..()
	if(ai_controlled && istype(shooter) && shooter != src && !QDELETED(src))
		LAZYSET(ai_attackers, shooter, world.time)

/obj/structure/overmap/proc/get_ai_retarget_chance()
	return ai_temperament == AI_TEMPERAMENT_RECKLESS ? AI_RETARGET_RECKLESS_CHANCE : 100

/// Could this ship pick other as a target right now (same rules as seek_new_target)
/obj/structure/overmap/proc/is_valid_ai_retarget(obj/structure/overmap/other)
	if(!is_ai_hostile(other) || other.essential)
		return FALSE
	if(overmap_dist(src, other) > max(max_tracking_range, other.sensor_profile))
		return FALSE
	return other.is_sensor_visible(src) >= SENSOR_VISIBILITY_TARGETABLE

/// How much this commander wants to shoot at other
/obj/structure/overmap/proc/get_ai_target_score(obj/structure/overmap/other)
	var/dist = overmap_dist(src, other)
	. = AI_TARGET_BASE - dist * AI_TARGET_PER_TILE
	if(dist <= AI_TARGET_GUN_REACH)
		. += AI_TARGET_IN_GUN_REACH
	if(other.max_integrity)
		. += AI_TARGET_CRIPPLED * clamp(1 - other.obj_integrity / other.max_integrity, 0, 1)
	var/last_hit = LAZYACCESS(ai_attackers, other)
	if(last_hit && world.time < last_hit + AI_ATTACKER_MEMORY)
		. += AI_TARGET_ATTACKER * (ai_temperament == AI_TEMPERAMENT_CAUTIOUS ? 1.5 : 1)
	if(LAZYFIND(other.target_painted, src))
		. += AI_TARGET_PAINTING_US
	if(other.mass <= MASS_TINY)
		if(CHECK_BITFIELD(ai_flags, AI_FLAG_ANTI_FIGHTER))
			. += AI_TARGET_SUITS_FLAK
		else if(mass > MASS_TINY)
			. -= AI_TARGET_FIGHTER_PENALTY // Capital guns are wasted on fighters
	else if(has_ai_torpedoes())
		. += AI_TARGET_SUITS_TORPEDOES
	if(other.role == MAIN_OVERMAP)
		. += AI_TARGET_FLAGSHIP

/obj/structure/overmap/proc/prune_ai_attackers()
	for(var/datum/shooter as anything in ai_attackers?.Copy())
		if(QDELETED(shooter) || world.time > ai_attackers[shooter] + AI_ATTACKER_MEMORY)
			LAZYREMOVE(ai_attackers, shooter)

/// Best target in sight, or null if nothing beats the current one by AI_RETARGET_MARGIN
/obj/structure/overmap/proc/choose_ai_tactical_target(list/candidates = current_system?.system_contents)
	var/obj/structure/overmap/current = last_target
	var/current_score = (istype(current) && is_valid_ai_retarget(current)) ? get_ai_target_score(current) : -INFINITY
	var/best_score = current_score + AI_RETARGET_MARGIN
	for(var/obj/structure/overmap/other as anything in candidates)
		if(other == current || !istype(other) || !is_valid_ai_retarget(other))
			continue
		var/score = get_ai_target_score(other)
		if(score > best_score)
			best_score = score
			. = other

/obj/structure/overmap/proc/ai_tactical_retarget()
	// Boarders hunt for ships with an interior, fleeing ships do not care any more
	if(!last_target || ai_fleeing || CHECK_BITFIELD(ai_flags, AI_FLAG_BOARDER) || world.time < ai_next_retarget)
		return
	ai_next_retarget = world.time + AI_RETARGET_INTERVAL
	prune_ai_attackers()
	if(!ai_temperament)
		roll_ai_temperament()
	if(!prob(get_ai_retarget_chance()))
		return // Target fixation
	var/obj/structure/overmap/better = choose_ai_tactical_target()
	if(!better)
		return
	if(fleet && last_target)
		fleet.stop_reporting(last_target, src)
	add_enemy(better)
	last_target = better
	ai_next_retarget = world.time + AI_RETARGET_COMMIT
	if(fleet)
		fleet.start_reporting(better, src)

/obj/structure/overmap/ai_process()
	if(GLOB.ai_morale_enabled && ai_controlled && z && current_system)
		ai_tactical_retarget()
	return ..()

#undef AI_TEMPERAMENT_CAUTIOUS
#undef AI_TEMPERAMENT_RECKLESS
#undef AI_RETARGET_INTERVAL
#undef AI_RETARGET_MARGIN
#undef AI_RETARGET_COMMIT
#undef AI_RETARGET_RECKLESS_CHANCE
#undef AI_ATTACKER_MEMORY
#undef AI_TARGET_BASE
#undef AI_TARGET_PER_TILE
#undef AI_TARGET_GUN_REACH
#undef AI_TARGET_IN_GUN_REACH
#undef AI_TARGET_CRIPPLED
#undef AI_TARGET_ATTACKER
#undef AI_TARGET_PAINTING_US
#undef AI_TARGET_SUITS_TORPEDOES
#undef AI_TARGET_SUITS_FLAK
#undef AI_TARGET_FIGHTER_PENALTY
#undef AI_TARGET_FLAGSHIP
