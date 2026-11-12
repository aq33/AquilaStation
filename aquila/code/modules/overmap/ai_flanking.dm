/// AQUILA - AI flanking: when two or more AI ships of one faction go for the same target, they split up around it.
/// The first one (the anchor) comes straight in; the others take slots on either side of the anchor's line of attack and behind the target,
/// a pincer: a target that turns to face the anchor shows its side and stern to the rest. Reckless commanders ignore this and charge head on.
/// Stage 2 of the AI plan, switched with AI morale (Debug > Toggle AI morale).

#define AI_TEMPERAMENT_RECKLESS "brawurowy"

/// Distance from the target a flanker holds (inside gun reach, OVERMAP_AI_GUN_RANGE 25); standoff ships hold further out
#define AI_FLANK_RADIUS 18
/// Close enough to the slot to stop and fight
#define AI_FLANK_ARRIVE 4

/// Slot offsets from the anchor's line of attack, by how many flankers there are (not counting the anchor), lowest first.
/// Flankers are matched to slots in the order they already stand around the target, so nobody crosses over to the far side.
GLOBAL_LIST_INIT(ai_flank_slots, list(list(90), list(-90, 90), list(-90, 90, 180), list(-135, -90, 90, 135), list(-135, -90, 90, 135, 180)))

/// Does this ship take part in a flank on target
/obj/structure/overmap/proc/is_ai_flanker(obj/structure/overmap/target)
	// Reckless commanders charge on their own, so they are not part of the formation
	return ai_controlled && last_target == target && !ai_fleeing && mass > MASS_TINY && !is_ai_carrier() && ai_temperament != AI_TEMPERAMENT_RECKLESS && !CHECK_BITFIELD(ai_flags, AI_FLAG_BOARDER) // Boarders have to get close

/// Ships of our faction attacking target as a formation, in a stable order; the first one is the anchor
/obj/structure/overmap/proc/get_ai_flank_attackers(obj/structure/overmap/target, list/ships)
	. = list()
	for(var/obj/structure/overmap/other as anything in ships)
		if(istype(other) && other.faction == faction && other.z == z && other.is_ai_flanker(target))
			. += other

/// Signed angle from axis to bearing, -180 to 180
/proc/ai_flank_relative_angle(axis, bearing)
	return ((round(bearing - axis) % 360) + 540) % 360 - 180

/// Turf this ship should take to flank target, or null to attack it head on
/obj/structure/overmap/proc/get_ai_flank_point(obj/structure/overmap/target, list/ships = current_system?.system_contents)
	if(!GLOB.ai_morale_enabled || ai_temperament == AI_TEMPERAMENT_RECKLESS || !is_ai_hostile(target) || !is_ai_flanker(target))
		return
	var/list/attackers = get_ai_flank_attackers(target, ships)
	if(length(attackers) < 2 || attackers[1] == src || !(src in attackers))
		return // Anchor or alone
	var/obj/structure/overmap/anchor = attackers[1]
	// Slots hang off the anchor's line of attack, not the target's heading: AI ships turn all the time,
	// and slots measured from the heading spun round faster than our slow ships could follow
	var/axis = overmap_angle(target, anchor)
	// Flankers sorted by where they already are relative to that line
	var/list/sorted = list()
	var/list/side = list()
	for(var/i in 2 to length(attackers))
		var/obj/structure/overmap/flanker = attackers[i]
		var/rel = ai_flank_relative_angle(axis, overmap_angle(target, flanker))
		side[flanker] = rel
		var/pos = length(sorted) + 1
		for(var/j in 1 to length(sorted))
			if(rel < side[sorted[j]])
				pos = j
				break
		sorted.Insert(pos, flanker)
	var/list/slots = GLOB.ai_flank_slots[min(length(sorted), length(GLOB.ai_flank_slots))]
	var/offset
	if(length(sorted) == 1)
		offset = side[src] < 0 ? -90 : 90 // A lone flanker takes the side it is already on
	else
		offset = slots[min(sorted.Find(src), length(slots))]
	var/bearing = axis + offset
	var/radius = max(AI_FLANK_RADIUS, get_ai_standoff_range(target))
	var/slot_x = WRAP(round(target.x + sin(bearing) * radius), 1, world.maxx + 1)
	var/slot_y = WRAP(round(target.y + cos(bearing) * radius), 1, world.maxy + 1)
	return locate(slot_x, slot_y, target.z)

/obj/structure/overmap/move_toward(atom/target, ram_target = FALSE, ignore_all_collisions = FALSE)
	if(ram_target || !isovermap(target))
		return ..()
	// Cel znany tylko z meldunku floty: flankowanie liczyłoby miejsce od jego prawdziwej pozycji,
	// więc lecimy do meldunku (overmap_scale.dm, get_ai_blind_point)
	if(get_ai_blind_point(target))
		return ..()
	var/turf/slot = get_ai_flank_point(target)
	if(!slot)
		return ..()
	if(overmap_dist(src, slot) > AI_FLANK_ARRIVE)
		return ..(slot, FALSE, ignore_all_collisions) // Fly to the slot; standoff and avoidance work as usual on the way
	// In position: hold, nose on the target
	brakes = TRUE
	move_mode = null
	enable_dampeners()
	desired_angle = overmap_angle(src, target)

#undef AI_TEMPERAMENT_RECKLESS
#undef AI_FLANK_RADIUS
#undef AI_FLANK_ARRIVE
