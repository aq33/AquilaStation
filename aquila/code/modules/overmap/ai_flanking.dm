/// AQUILA - AI flanking: when two or more AI ships of one faction go for the same target, they split up around it.
/// The first one (the anchor) comes straight in; the others take slots on either side of the anchor's line of attack and behind the target,
/// a pincer: a target that turns to face the anchor shows its side and stern to the rest. Reckless commanders ignore this and charge head on.
/// Stage 2 of the AI plan, switched with AI morale (Debug > Toggle AI morale).

#define AI_TEMPERAMENT_RECKLESS "brawurowy"

/// Distance from the target a flanker holds (inside gun reach, OVERMAP_AI_GUN_RANGE 25); standoff ships hold further out
#define AI_FLANK_RADIUS 18
/// Close enough to the slot to stop and fight
#define AI_FLANK_ARRIVE 4

/// Slot offsets from the target's heading, for attacker 2, 3, 4...; the anchor (attacker 1) has no slot
GLOBAL_LIST_INIT(ai_flank_offsets, list(90, -90, 180, 135, -135))

/// Does this ship take part in a flank on target
/obj/structure/overmap/proc/is_ai_flanker(obj/structure/overmap/target)
	// Reckless commanders charge on their own, so they are not part of the formation
	return ai_controlled && last_target == target && !ai_fleeing && mass > MASS_TINY && !is_ai_carrier() && ai_temperament != AI_TEMPERAMENT_RECKLESS

/// list(index of this ship among the attackers of target (1 = anchor), the anchor), or null if there is nobody to flank with
/obj/structure/overmap/proc/get_ai_flank_index(obj/structure/overmap/target, list/ships)
	var/index = 0
	var/count = 0
	var/obj/structure/overmap/anchor
	for(var/obj/structure/overmap/other as anything in ships)
		if(!istype(other) || other.faction != faction || other.z != z || !other.is_ai_flanker(target))
			continue
		count++
		if(count == 1)
			anchor = other
		if(other == src)
			index = count
	if(count < 2 || !index)
		return
	return list(index, anchor)

/// Turf this ship should take to flank target, or null to attack it head on
/obj/structure/overmap/proc/get_ai_flank_point(obj/structure/overmap/target, list/ships = current_system?.system_contents)
	if(!GLOB.ai_morale_enabled || ai_temperament == AI_TEMPERAMENT_RECKLESS || !is_ai_hostile(target) || !is_ai_flanker(target))
		return
	var/list/flank = get_ai_flank_index(target, ships)
	if(!flank || flank[1] < 2)
		return // Anchor or alone
	var/index = flank[1]
	var/obj/structure/overmap/anchor = flank[2]
	// Slots hang off the anchor's line of attack, not the target's heading: AI ships turn all the time,
	// and slots measured from the heading spun round faster than our slow ships could follow
	var/list/offsets = GLOB.ai_flank_offsets
	var/bearing = overmap_angle(target, anchor) + offsets[((index - 2) % length(offsets)) + 1]
	var/radius = max(AI_FLANK_RADIUS, get_ai_standoff_range(target))
	var/slot_x = WRAP(round(target.x + sin(bearing) * radius), 1, world.maxx + 1)
	var/slot_y = WRAP(round(target.y + cos(bearing) * radius), 1, world.maxy + 1)
	return locate(slot_x, slot_y, target.z)

/obj/structure/overmap/move_toward(atom/target, ram_target = FALSE, ignore_all_collisions = FALSE)
	if(ram_target || !isovermap(target))
		return ..()
	var/turf/slot = get_ai_flank_point(target)
	if(!slot)
		return ..()
	if(overmap_dist(src, slot) > AI_FLANK_ARRIVE)
		return ..(slot) // Fly to the slot; standoff and avoidance work as usual on the way
	// In position: hold, nose on the target
	brakes = TRUE
	move_mode = null
	enable_dampeners()
	desired_angle = overmap_angle(src, target)

#undef AI_TEMPERAMENT_RECKLESS
#undef AI_FLANK_RADIUS
#undef AI_FLANK_ARRIVE
