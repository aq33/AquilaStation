/// AQUILA - AI morale: a ship that takes a beating, loses friends or thinks it is outgunned gets scared, keeps its distance,
/// and in the end runs and jumps out of the system. Commanders have a temperament and make mistakes:
/// they misjudge the odds, hesitate before opening fire, and reckless ones chase into the dark and ignore standoff orders.
/// Stage 1 of the AI plan; flanking and fleet distress calls come later.

/// Admin switch (Debug > Toggle AI morale)
GLOBAL_VAR_INIT(ai_morale_enabled, TRUE)

#define AI_TEMPERAMENT_CAUTIOUS "ostrożny"
#define AI_TEMPERAMENT_NORMAL "zwykły"
#define AI_TEMPERAMENT_RECKLESS "brawurowy"

/// Per slowprocess (0.7 s) decay of the recent damage sum: about 10 s of memory
#define AI_DAMAGE_DECAY 0.9
/// Per slowprocess decay of the shock from losing nearby allies
#define AI_SHOCK_DECAY 0.97
/// Fear per percent of hull lost recently
#define AI_FEAR_PER_BURST 2.5
/// Hull percentage below which damage keeps the crew scared, and fear per missing percent
#define AI_FEAR_HULL_LINE 60
#define AI_FEAR_PER_HULL 0.6
/// Shock from a nearby ally destroyed, and from one that ran away
#define AI_SHOCK_ALLY_LOST 15
#define AI_SHOCK_ALLY_FLED 7
/// Fear per point of enemy/own strength ratio above 1, and its bounds
#define AI_FEAR_PER_ODDS 25
#define AI_FEAR_ODDS_MIN -20
#define AI_FEAR_ODDS_MAX 40
/// Calm per ally nearby, and its cap
#define AI_CALM_PER_ALLY 5
#define AI_CALM_MAX 20
/// Range for counting enemies and for the shock of losing an ally; allies count as support at the smaller range
#define AI_MORALE_THREAT_RANGE 60
#define AI_MORALE_SUPPORT_RANGE 30
/// Strength ratio is recalculated every this many slowprocess ticks (it loops over the system)
#define AI_ODDS_INTERVAL 5
/// Fear thresholds
#define AI_FEAR_CAUTIOUS 30
/// Standoff of a scared ship: out of gun range of the enemy (OVERMAP_AI_GUN_RANGE 25 + band)
#define AI_FEAR_STANDOFF 35
/// A ship hesitates before opening fire at most this often
#define AI_HESITATION_COOLDOWN (15 SECONDS)
/// How often a ship between GLOB.ai_fear_retreat and GLOB.ai_fear_panic (ai_tuning.dm) rolls to break off
#define AI_RETREAT_ROLL_TIME (5 SECONDS)
/// A fleeing ship jumps once no enemy has hurt it for this long and the nearest enemy is this far away
#define AI_ESCAPE_QUIET_TIME (20 SECONDS)
#define AI_ESCAPE_DISTANCE 40
/// FTL spool before the jump
#define AI_ESCAPE_SPOOL_TIME (10 SECONDS)
/// Reckless ships chase a lost target to where it would be after this long
#define AI_PURSUIT_LEAD_TIME 20

/obj/structure/overmap
	/// AQUILA - 0 to 100, see ai_morale.dm
	var/ai_fear = 0
	/// AQUILA - commander temperament, rolled on first use
	var/ai_temperament
	/// AQUILA - how wrong this commander is about the odds, a fraction (-0.3 to 0.3), rolled with the temperament
	var/ai_odds_error = 0
	/// AQUILA - decaying sum of hull lost recently
	var/ai_recent_damage = 0
	var/ai_last_integrity
	var/ai_last_hurt = -AI_ESCAPE_QUIET_TIME
	/// AQUILA - decaying fear from allies lost nearby
	var/ai_shock = 0
	/// AQUILA - cached enemy/own strength ratio and the tick counter for it
	var/ai_odds_ratio = 1
	var/ai_odds_tick = 0
	var/ai_next_retreat_roll = 0
	/// AQUILA - running away, and when the FTL spool ends (0 = not spooling)
	var/ai_fleeing = FALSE
	var/ai_escape_at = 0
	/// AQUILA - set right before a ship jumps out, so its allies take it as a retreat and not a loss
	var/ai_escaped = FALSE
	/// AQUILA - commander hesitation after picking a new target
	var/ai_hold_fire_until = 0
	/// AQUILA - no new hesitation before this world.time, and the target the commander last hesitated over
	var/ai_next_hesitation = 0
	var/datum/weakref/ai_hesitated_target

/obj/structure/overmap/proc/roll_ai_temperament()
	if(CHECK_BITFIELD(ai_flags, AI_FLAG_ELITE))
		ai_temperament = pick(AI_TEMPERAMENT_NORMAL, AI_TEMPERAMENT_RECKLESS)
	else
		ai_temperament = pick(prob(30); AI_TEMPERAMENT_CAUTIOUS, prob(45); AI_TEMPERAMENT_NORMAL, prob(25); AI_TEMPERAMENT_RECKLESS)
	ai_odds_error = rand(-30, 30) / 100

/// Ships that never run: stations, fighters, anything with an interior or a mission role.
/// Supply ships and carriers do: their own retreat goal only keeps them away, it never gets them out of the system.
/obj/structure/overmap/proc/can_ai_flee()
	if(!ai_controlled || essential || nodamage || mass <= MASS_TINY || mass >= MASS_IMMOBILE)
		return FALSE
	if(CHECK_BITFIELD(ai_flags, AI_FLAG_STATIONARY))
		return FALSE
	if(length(occupying_levels) || reserved_z || role != NORMAL_OVERMAP)
		return FALSE
	// The last warship of a defence (boss) fleet fights to the end: its escape would take the whole fleet out of the system
	if(fleet?.fleet_trait == FLEET_TRAIT_DEFENSE && !has_other_ai_warships())
		return FALSE
	return TRUE

/obj/structure/overmap/proc/get_ai_fear_mult()
	if(CHECK_BITFIELD(ai_flags, AI_FLAG_ELITE))
		return 0.6
	switch(ai_temperament)
		if(AI_TEMPERAMENT_CAUTIOUS)
			return 1.3
		if(AI_TEMPERAMENT_RECKLESS)
			return 0.7
	return 1

/// TRUE if other is something this ship should fight (or fear)
/obj/structure/overmap/proc/is_ai_hostile(obj/structure/overmap/other)
	return istype(other) && other != src && !QDELETED(other) && other.z == z && other.faction != faction && !istype(other, /obj/structure/overmap/asteroid) && !warcrime_blacklist[other.type]

/// Enemy strength we can see against ours plus nearby allies, as the commander (mis)judges it
/obj/structure/overmap/proc/update_ai_odds()
	var/own = max(obj_integrity, 1)
	var/enemy = 0
	for(var/obj/structure/overmap/other as anything in current_system?.system_contents)
		if(!istype(other) || other == src || other.z != z)
			continue
		var/dist = overmap_dist(src, other)
		if(other.faction == faction)
			if(dist <= AI_MORALE_SUPPORT_RANGE && !istype(other, /obj/structure/overmap/asteroid))
				own += other.obj_integrity
			continue
		if(dist <= AI_MORALE_THREAT_RANGE && is_ai_hostile(other) && other.is_sensor_visible(src) >= SENSOR_VISIBILITY_FAINT)
			enemy += other.obj_integrity
	ai_odds_ratio = (enemy / own) * (1 + ai_odds_error)

/obj/structure/overmap/proc/count_ai_support()
	. = 0
	for(var/obj/structure/overmap/other as anything in current_system?.system_contents)
		if(istype(other) && other != src && other.faction == faction && other.z == z && other.mass > MASS_TINY && !istype(other, /obj/structure/overmap/asteroid) && overmap_dist(src, other) <= AI_MORALE_SUPPORT_RANGE)
			.++

/// The fear this ship's situation calls for right now
/obj/structure/overmap/proc/get_ai_fear_target()
	var/burst = max_integrity ? (ai_recent_damage / max_integrity) * 100 : 0
	var/hull = max_integrity ? (obj_integrity / max_integrity) * 100 : 100
	var/raw = burst * AI_FEAR_PER_BURST
	raw += max(0, AI_FEAR_HULL_LINE - hull) * AI_FEAR_PER_HULL
	raw += ai_shock
	raw += clamp((ai_odds_ratio - 1) * AI_FEAR_PER_ODDS, AI_FEAR_ODDS_MIN, AI_FEAR_ODDS_MAX)
	raw -= min(AI_CALM_MAX, count_ai_support() * AI_CALM_PER_ALLY)
	return clamp(raw * get_ai_fear_mult() * GLOB.ai_fear_mult, 0, 100)

/obj/structure/overmap/proc/update_ai_morale()
	if(!ai_temperament)
		roll_ai_temperament()
	if(isnull(ai_last_integrity))
		ai_last_integrity = obj_integrity
	var/lost = ai_last_integrity - obj_integrity
	ai_last_integrity = obj_integrity
	ai_recent_damage *= AI_DAMAGE_DECAY
	if(lost > 0)
		ai_recent_damage += lost
		ai_last_hurt = world.time
	ai_shock *= AI_SHOCK_DECAY
	if(++ai_odds_tick >= AI_ODDS_INTERVAL)
		ai_odds_tick = 0
		update_ai_odds()
	var/target = get_ai_fear_target()
	// Fear comes fast and goes slowly
	ai_fear += (target - ai_fear) * (target > ai_fear ? 0.7 : 0.1)
	if(!can_ai_flee())
		if(ai_fleeing) // The way out closed, e.g. it is the last warship of a defence fleet now
			stop_ai_flight()
		return
	if(ai_fleeing)
		if(ai_fear < AI_FEAR_CAUTIOUS) // Rallied
			stop_ai_flight()
		return
	if(ai_fear >= GLOB.ai_fear_panic)
		start_ai_flight()
	else if(ai_fear >= GLOB.ai_fear_retreat && world.time >= ai_next_retreat_roll)
		ai_next_retreat_roll = world.time + AI_RETREAT_ROLL_TIME
		if(prob((ai_fear - GLOB.ai_fear_retreat) * 3))
			start_ai_flight()

/obj/structure/overmap/slowprocess()
	if(ai_controlled && GLOB.ai_morale_enabled && current_system && mass > MASS_TINY) // Fighters never flee, skip the fear maths for them
		update_ai_morale()
	return ..()

/obj/structure/overmap/proc/start_ai_flight()
	ai_fleeing = TRUE
	ai_escape_at = 0
	log_game("[src] ([ai_temperament], fear [round(ai_fear)]) breaks off and runs at [AREACOORD(src)]")

/obj/structure/overmap/proc/stop_ai_flight()
	ai_fleeing = FALSE
	ai_escape_at = 0

/// Nearest enemy this ship knows about, for running away from it
/obj/structure/overmap/proc/get_ai_nearest_threat()
	var/best_dist = INFINITY
	for(var/obj/structure/overmap/other as anything in current_system?.system_contents)
		if(!is_ai_hostile(other) || (other.mass <= MASS_TINY && other != last_target))
			continue
		var/dist = overmap_dist(src, other)
		if(dist < best_dist)
			best_dist = dist
			. = other

/// Tells the player ships that can see us
/obj/structure/overmap/proc/announce_ai_escape(message)
	for(var/obj/structure/overmap/other as anything in current_system?.system_contents)
		if(!istype(other) || other.ai_controlled || other.faction == faction || other.z != z || is_sensor_visible(other) < SENSOR_VISIBILITY_FAINT)
			continue
		var/text = "<span class='warning'>[message]</span>"
		if(other.tactical)
			other.tactical.visible_message(text)
		if(other.dradis)
			other.dradis.visible_message(text)

/obj/structure/overmap/proc/ai_escape()
	if(ai_escaped)
		return
	ai_escaped = TRUE
	// The last warship of a fleet does not leave alone: the whole fleet falls back with it,
	// otherwise its deletion would end the fleet with defeat() and give the players full credit for a kill
	if(fleet && !QDELETED(fleet) && !has_other_ai_warships())
		var/datum/star_system/left = current_system
		fleet.try_ai_retreat_jump()
		if(fleet?.current_system != left)
			ai_escaped = FALSE // It is still a ship of that fleet, just somewhere else now
			return
	announce_ai_escape("[src] wykonuje skok FTL i opuszcza system.")
	log_game("[src] escaped [current_system] by FTL")
	// A jump, not a death: no explosion, wreck or "reactor critical" warning to the ships that fought it
	destruction_effects = FALSE
	enemies = list()
	// Deleted after this tick: the flee goal runs inside ai_process(), which keeps going after choose_goal()
	QDEL_IN(src, 1)

/// Another ship of our fleet (not a fighter) is still in this system
/obj/structure/overmap/proc/has_other_ai_warships()
	for(var/obj/structure/overmap/other as anything in fleet?.all_ships)
		if(other != src && !QDELETED(other) && other.z == z && other.mass > MASS_TINY && !other.ai_escaped)
			return TRUE
	return FALSE

/// Running away: away from the nearest threat, afterburner when lined up, then spool the drive and jump once nobody is close
/datum/ai_goal/ai_flee
	name = "Break off and escape by FTL"
	score = AI_SCORE_MAXIMUM + 2 // Above lone "seek" (MAXIMUM) and stations (MAXIMUM + 1, they never flee)

/datum/ai_goal/ai_flee/check_score(obj/structure/overmap/OM)
	if(!..() || !GLOB.ai_morale_enabled || !OM.ai_fleeing || OM.ai_escaped || !OM.can_ai_flee())
		return 0
	return score

/datum/ai_goal/ai_flee/action(obj/structure/overmap/OM)
	..()
	var/obj/structure/overmap/threat = OM.get_ai_nearest_threat()
	if(threat)
		OM.move_away_from(threat)
		OM.enable_dampeners()
		var/heading_error = abs(((OM.desired_angle - OM.angle) + 540) % 360 - 180)
		if(world.time >= OM.next_maneuvre && heading_error < 20)
			OM.boost(NORTH)
	var/safe = (!threat || overmap_dist(OM, threat) >= AI_ESCAPE_DISTANCE) && world.time >= OM.ai_last_hurt + AI_ESCAPE_QUIET_TIME
	if(!safe)
		OM.ai_escape_at = 0 // Spool interrupted
		return
	if(SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CHECK_INTERDICT, OM) & (WEAK_INTERDICT|STRONG_INTERDICT))
		OM.ai_escape_at = 0 // Interdicted: keep running, and spool from scratch once it lifts
		return
	if(!OM.ai_escape_at)
		OM.ai_escape_at = world.time + AI_ESCAPE_SPOOL_TIME
		OM.announce_ai_escape("[OM] rozgrzewa napęd FTL.")
		return
	if(world.time >= OM.ai_escape_at)
		OM.ai_escape()

/// A scared ship keeps out of gun range; a reckless one ignores standoff orders and closes in anyway
/obj/structure/overmap/get_ai_standoff_range(atom/target)
	. = ..()
	if(!GLOB.ai_morale_enabled || !ai_controlled || CHECK_BITFIELD(ai_flags, AI_FLAG_BOARDER))
		return
	if(ai_temperament == AI_TEMPERAMENT_RECKLESS && !is_ai_carrier())
		return 0
	if(ai_fear >= AI_FEAR_CAUTIOUS && is_ai_hostile(target))
		return max(., AI_FEAR_STANDOFF)

/// Hesitation: a commander does not open fire on a new target straight away; cautious ones take longer, reckless ones not at all.
/// ai_fire() calls add_enemy() with the target, so this also covers targets the fleet assigned directly.
/// At most every AI_HESITATION_COOLDOWN: upstream swaps targets whenever someone else shoots, and supply ships
/// reset their target every tick, so hesitating on every swap kept some ships from ever firing.
/obj/structure/overmap/add_enemy(atom/target)
	. = ..()
	if(!GLOB.ai_morale_enabled || !ai_controlled || !last_target || world.time < ai_next_hesitation || ai_hesitated_target?.resolve() == last_target)
		return
	ai_next_hesitation = world.time + AI_HESITATION_COOLDOWN
	ai_hesitated_target = WEAKREF(last_target)
	if(!ai_temperament)
		roll_ai_temperament()
	switch(ai_temperament)
		if(AI_TEMPERAMENT_CAUTIOUS)
			ai_hold_fire_until = world.time + rand(2, 4) * 0.7 SECONDS
		if(AI_TEMPERAMENT_NORMAL)
			ai_hold_fire_until = world.time + rand(1, 3) * 0.7 SECONDS

/obj/structure/overmap/ai_fire(obj/structure/overmap/target)
	if(GLOB.ai_morale_enabled && world.time < ai_hold_fire_until)
		return // The target is already last_target, the commander just has not given the order yet
	return ..()

/obj/structure/overmap/ai_elite_fire(obj/structure/overmap/target)
	if(GLOB.ai_morale_enabled && world.time < ai_hold_fire_until)
		return
	return ..()

/// Fear shakes the gunners: from AI_FEAR_CAUTIOUS up, an AI ship fires its guns with a growing spread,
/// up to GLOB.ai_fear_max_spread degrees (ai_tuning.dm) at full fear. Torpedoes and missiles home in and are not affected.
/obj/structure/overmap/proc/get_ai_fear_spread(proj_type)
	if(!GLOB.ai_morale_enabled || !ai_controlled || ai_fear <= AI_FEAR_CAUTIOUS || !ispath(proj_type, /obj/item/projectile) || ispath(proj_type, /obj/item/projectile/guided_munition))
		return 0
	return GLOB.ai_fear_max_spread * (ai_fear - AI_FEAR_CAUTIOUS) / (100 - AI_FEAR_CAUTIOUS)

/obj/structure/overmap/fire_projectile(proj_type, atom/target, pixel_speed = null, user_override = null, firing_flags = NONE, ai_aim = FALSE, miss_chance = 5, max_miss_distance = 5, spread_override = null, projectile_speed = null)
	var/fear_spread = get_ai_fear_spread(proj_type)
	if(fear_spread)
		var/obj/item/projectile/prototype = proj_type
		spread_override = (isnull(spread_override) ? initial(prototype.spread) : spread_override) + fear_spread
	return ..(proj_type, target, pixel_speed, user_override, firing_flags, ai_aim, miss_chance, max_miss_distance, spread_override, projectile_speed)

/// Reckless commanders chase a target that slipped away to where they guess it went, away from their fleet
/obj/structure/overmap/ai_process()
	var/obj/structure/overmap/old_target = last_target
	. = ..()
	if(!GLOB.ai_morale_enabled || !ai_controlled || ai_temperament != AI_TEMPERAMENT_RECKLESS || ai_fleeing)
		return
	if(!istype(old_target) || last_target || QDELETED(old_target) || old_target.z != z || !old_target.velocity)
		return
	var/guess_x = WRAP(round(old_target.x + old_target.velocity.a * AI_PURSUIT_LEAD_TIME), 1, world.maxx + 1)
	var/guess_y = WRAP(round(old_target.y + old_target.velocity.e * AI_PURSUIT_LEAD_TIME), 1, world.maxy + 1)
	patrol_target = locate(guess_x, guess_y, z)

/// Losing an ally nearby shakes the others; one that ran away shakes them less
/obj/structure/overmap/proc/spread_ai_shock()
	var/shock = ai_escaped ? AI_SHOCK_ALLY_FLED : AI_SHOCK_ALLY_LOST
	for(var/obj/structure/overmap/other as anything in current_system?.system_contents)
		if(istype(other) && other != src && other.ai_controlled && other.faction == faction && other.z == z && overmap_dist(src, other) <= AI_MORALE_THREAT_RANGE)
			other.ai_shock += shock

/obj/structure/overmap/Destroy()
	if(GLOB.ai_morale_enabled && ai_controlled && current_system && z && mass > MASS_TINY)
		spread_ai_shock()
	return ..()

/world/AVerbsDebug()
	. = ..()
	. += /client/proc/toggle_ai_morale

/client/proc/toggle_ai_morale()
	set category = "Debug"
	set name = "Przełącz morale AI"
	set desc = "Włącza lub wyłącza strach, odwrót i błędy taktyczne okrętów AI."
	if(!check_rights(R_DEBUG))
		return
	GLOB.ai_morale_enabled = !GLOB.ai_morale_enabled
	var/state = GLOB.ai_morale_enabled ? "włączył" : "wyłączył"
	message_admins("[key_name_admin(usr)] [state] morale AI (strach, odwrót, błędy taktyczne).")
	log_admin("[key_name(usr)] toggled AI morale to [GLOB.ai_morale_enabled].")

#undef AI_TEMPERAMENT_CAUTIOUS
#undef AI_TEMPERAMENT_NORMAL
#undef AI_TEMPERAMENT_RECKLESS
#undef AI_DAMAGE_DECAY
#undef AI_SHOCK_DECAY
#undef AI_FEAR_PER_BURST
#undef AI_FEAR_HULL_LINE
#undef AI_FEAR_PER_HULL
#undef AI_SHOCK_ALLY_LOST
#undef AI_SHOCK_ALLY_FLED
#undef AI_FEAR_PER_ODDS
#undef AI_FEAR_ODDS_MIN
#undef AI_FEAR_ODDS_MAX
#undef AI_CALM_PER_ALLY
#undef AI_CALM_MAX
#undef AI_MORALE_THREAT_RANGE
#undef AI_MORALE_SUPPORT_RANGE
#undef AI_ODDS_INTERVAL
#undef AI_FEAR_CAUTIOUS
#undef AI_HESITATION_COOLDOWN
#undef AI_FEAR_STANDOFF
#undef AI_RETREAT_ROLL_TIME
#undef AI_ESCAPE_QUIET_TIME
#undef AI_ESCAPE_DISTANCE
#undef AI_ESCAPE_SPOOL_TIME
#undef AI_PURSUIT_LEAD_TIME
