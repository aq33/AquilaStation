// AQUILA - blood trails and drops from tgstation (code/modules/mob/living/blood.dm make_blood_trail(),
// code/game/objects/effects/decals/cleanable/blood.dm trail_holder/trail, code/modules/mob/living/blood_types.dm drips).
// A trail is a holder decal with one blood decal per direction in its vis_contents: half pieces where a trail starts,
// straight pieces, corners and diagonals, so the trail joins up across tiles. Every piece and every drop is its own
// blood decal, so it dries and takes its colour (species blood colour, greyscale sprites) on its own.
// Trail sprites: tgstation icons/effects/blood.dmi (CC-BY-SA 3.0), in aquila/icons/effects/blood_trails.dmi.

/// Bleeding (our scale) above which walking leaves a trail. tg: get_bleed_rate() > 3
#define BLOOD_TRAIL_WALK_BLEED BLEED_CUT
/// Chance per step and point of bleeding to leave a trail while walking. tg: 16 on their bleed scale
#define BLOOD_TRAIL_WALK_CHANCE 20

/// Called from Move(): leaves a blood trail when dragged/crawling while hurt or walking while bleeding a lot (tg Move())
/mob/living/proc/aq_try_blood_trail(turf/start, was_facing)
	var/turf/target_turf = loc
	var/movement_direction = get_dir(start, target_turf)
	if(!isturf(start) || !isturf(target_turf) || !movement_direction)
		return
	var/lying_down = !(mobility_flags & MOBILITY_STAND)
	var/health_check = lying_down && prob(getBruteLoss() * 200 / maxHealth)
	// Xeno and other non-blood trails keep the old overlay trails
	if(get_blood_id() != /datum/reagent/blood)
		if(health_check)
			makeTrail(target_turf, start, was_facing)
		return
	var/blood_flow = aq_trail_bleed_rate()
	var/bleeding_check = blood_flow > BLOOD_TRAIL_WALK_BLEED && prob(blood_flow * BLOOD_TRAIL_WALK_CHANCE)
	if(health_check || bleeding_check)
		make_blood_trail(target_turf, start, was_facing, movement_direction)

/// How fast the mob bleeds for trails, held wounds bleed less
/mob/living/proc/aq_trail_bleed_rate()
	return 0

/mob/living/carbon/aq_trail_bleed_rate()
	var/datum/status_effect/bleeding/bleed = has_status_effect(STATUS_EFFECT_BLEED)
	if(!bleed)
		return 0
	. = bleed.bleed_rate
	if(HAS_TRAIT(src, TRAIT_BLEED_HELD))
		. = max(0, . - BLEED_RATE_MINOR)

/mob/living/proc/make_blood_trail(turf/target_turf, turf/start, was_facing, movement_direction)
	if(!has_gravity() || (movement_type & THROWN) || !isturf(start))
		return
	if(HAS_TRAIT(src, TRAIT_NO_BLOOD) || HAS_TRAIT(src, TRAIT_NO_BLEEDING) || IS_IN_STASIS(src) || !blood_volume)
		return

	var/base_bleed_rate = aq_trail_bleed_rate()
	var/base_brute = getBruteLoss()
	var/brute_ratio = round(base_brute / (maxHealth * 4), 0.1)
	var/bleeding_rate = round(base_bleed_rate / 4, 0.1)
	// We only leave a trail if we're below a certain blood threshold
	// The more brute damage we have, or the more we're bleeding, the less blood we need to leave a trail
	if(blood_volume < max(BLOOD_VOLUME_NORMAL * (1 - max(bleeding_rate, brute_ratio)), 0))
		return

	var/blood_to_add = BLOOD_AMOUNT_PER_DECAL * 0.1
	if(!(mobility_flags & MOBILITY_STAND))
		// Dragging costs blood, as in our old makeTrail()
		var/drag_amount = max(1, round(base_brute / maxHealth, 0.1) * 2)
		blood_to_add += drag_amount
		blood_volume = max(blood_volume - drag_amount, 0)
	else
		blood_to_add += base_bleed_rate
	// If we're very damaged or bleeding a lot, add even more blood to the trail (tg: bleed rate 7)
	if(base_brute >= 300 || base_bleed_rate >= BLEED_CRITICAL)
		blood_to_add *= 2

	var/trail_dir = REVERSE_DIR(movement_direction)
	// The mob is performing a diagonal movement so we need to make a diagonal trail
	// This is denoted by a negative direction (so we don't conflict with real dirs)
	if(movement_direction in GLOB.diagonals)
		trail_dir = -1 * movement_direction
		create_blood_trail_component(start, trail_dir, blood_to_add * 0.67, FALSE)
		create_blood_trail_component(target_turf, movement_direction, blood_to_add * 0.33, TRUE)
		return

	var/continuing_trail = FALSE
	// The mob is going a direction they were not previously facing: make a corner, if there is a trail a step back
	if(trail_dir != was_facing && trail_dir != REVERSE_DIR(was_facing))
		for(var/obj/effect/decal/cleanable/blood/trail_holder/past_trail in get_step(start, REVERSE_DIR(was_facing)))
			if(past_trail.get_trail_component(was_facing, check_reverse = TRUE, check_diagonals = TRUE, check_reverse_diagonals = TRUE))
				trail_dir |= was_facing
				continuing_trail = TRUE
				// In case we produced an invalid dir: go back on relevant axis
				if((trail_dir & (NORTH|SOUTH)) == (NORTH|SOUTH))
					trail_dir &= ~(was_facing & (NORTH|SOUTH))
				if((trail_dir & (EAST|WEST)) == (EAST|WEST))
					trail_dir &= ~(was_facing & (EAST|WEST))
				break

	if(continuing_trail || (trail_dir in GLOB.diagonals))
		create_blood_trail_component(start, trail_dir, blood_to_add * 0.67, FALSE)
		create_blood_trail_component(target_turf, movement_direction, blood_to_add * 0.33, TRUE)
		return

	// Moving straight: continue the half trail on our turf, or start the trail with a half piece
	for(var/obj/effect/decal/cleanable/blood/trail_holder/trail_holder in start)
		var/obj/effect/decal/cleanable/blood/trail/trail = trail_holder.get_trail_component(trail_dir)
		if(trail?.half_piece)
			continuing_trail = TRUE
			break

	create_blood_trail_component(start, trail_dir, blood_to_add * 0.67, !continuing_trail)
	create_blood_trail_component(target_turf, movement_direction, blood_to_add * 0.33, TRUE)

/mob/living/carbon/human/make_blood_trail(turf/target_turf, turf/start, was_facing, movement_direction)
	if((NOBLOOD in dna.species.species_traits) || !is_bleeding())
		return
	return ..()

/// Finds or makes the trail holder on the turf and adds a direction to it
/mob/living/proc/create_blood_trail_component(turf/trail_turf, trail_dir, blood_to_add, half_piece)
	if(!isturf(trail_turf) || isgroundlessturf(trail_turf) || isclosedturf(trail_turf))
		return
	// Our blood decals merge into one per turf; dried pieces turn fresh again when blood is added to them
	var/obj/effect/decal/cleanable/blood/trail_holder/trail = locate() in trail_turf
	if(trail)
		trail.add_bloodiness(blood_to_add)
	else
		trail = new(trail_turf, get_static_viruses())
		if(QDELETED(trail))
			return
		trail.add_bloodiness(blood_to_add - trail.bloodiness)
		var/datum/blood_type/trail_blood = get_blood_type(dna_blood_type())
		if(trail_blood?.glowy)
			trail.set_light(1, 0.5, trail_blood.blood_color)
	trail.transfer_mob_blood_dna(src)
	return trail.add_dir_to_trail(trail_dir, src, blood_to_add, half_piece)

// Trail holder (core type, made a child of blood in core)

/obj/effect/decal/cleanable/blood/trail_holder
	bloodiness = BLOOD_AMOUNT_PER_DECAL * 0.1
	/// Direction text -> trail piece in our vis_contents
	var/list/obj/effect/decal/cleanable/blood/trail/trail_components

/obj/effect/decal/cleanable/blood/trail_holder/Destroy()
	. = ..()
	QDEL_LIST_ASSOC_VAL(trail_components)
	trail_components = null

/**
 * Returns the trail component corresponding to the given direction
 *
 * * for_dir: The direction to get the trail for
 * * check_reverse: If TRUE, will also check for the reverse direction
 * * check_diagonals: If TRUE, will also check for any diagonal directions containing for_dir
 * * check_reverse_diagonals: If TRUE, will also check for any diagonal directions containing the reverse of for_dir
 */
/obj/effect/decal/cleanable/blood/trail_holder/proc/get_trail_component(for_dir, check_reverse = FALSE, check_diagonals = FALSE, check_reverse_diagonals = FALSE)
	. = LAZYACCESS(trail_components, "[for_dir]")
	if(.)
		return .
	if(check_reverse)
		. = LAZYACCESS(trail_components, "[REVERSE_DIR(for_dir)]")
		if(.)
			return .
	if(!check_diagonals)
		return null
	for(var/comp_dir_txt in trail_components)
		var/comp_dir = text2num(comp_dir_txt)
		if(comp_dir <= 0)
			continue
		if(comp_dir & for_dir)
			return LAZYACCESS(trail_components, comp_dir_txt)
		if(check_reverse_diagonals && (comp_dir & REVERSE_DIR(for_dir)))
			return LAZYACCESS(trail_components, comp_dir_txt)
	return null

/**
 * Adds a new direction to this trail, joining it with the pieces already here
 *
 * * new_dir: a cardinal direction, a diagonal direction (a corner), or a negative number for a straight diagonal trail
 * * source: mob we're sourcing blood from, if any
 * * blood_to_add: bloodiness given to the piece
 * * half_piece: only the start of a trail. Does not support corners
 */
/obj/effect/decal/cleanable/blood/trail_holder/proc/add_dir_to_trail(new_dir = NORTH, mob/living/source, blood_to_add = BLOOD_AMOUNT_PER_DECAL * 0.1, half_piece = FALSE)
	var/check_reverse = TRUE
	// Do not check the reverse dir if we're a diagonal corner
	if(new_dir > 0 && !(new_dir in GLOB.cardinals))
		check_reverse = FALSE
	var/obj/effect/decal/cleanable/blood/trail/new_trail = get_trail_component(new_dir, check_reverse = check_reverse, check_diagonals = half_piece)

	if(new_trail)
		// A full trail, or a half trail that fully overlaps with us: just add blood to it
		if(!new_trail.half_piece || half_piece && LAZYACCESS(trail_components, "[new_dir]") == new_trail)
			new_trail.add_piece_blood(source, blood_to_add)
			return new_trail
		// A mirrored half piece, or a half piece under a straight piece: make it a full piece
		new_trail.half_piece = FALSE
		new_trail.update_trail_state()
		new_trail.add_piece_blood(source, blood_to_add)
		return new_trail

	// We may be on the same tile as a corner
	if(half_piece && new_dir > 0)
		var/first_dir = (new_dir & (NORTH|SOUTH)) ? EAST : NORTH
		var/second_dir = (new_dir & (NORTH|SOUTH)) ? WEST : SOUTH
		new_trail = get_trail_component(new_dir | first_dir) || get_trail_component(new_dir | second_dir)
		if(new_trail)
			new_trail.add_piece_blood(source, blood_to_add)
			return new_trail
		// Look for perpendicular half pieces to merge into a corner with
		new_trail = get_trail_component(first_dir)
		if(!new_trail?.half_piece)
			new_trail = get_trail_component(second_dir)
		if(new_trail?.half_piece)
			new_trail.half_piece = FALSE
			LAZYREMOVE(trail_components, "[new_trail.dir]")
			new_trail.setDir(new_dir | new_trail.dir)
			LAZYSET(trail_components, "[new_trail.dir]", new_trail)
			new_trail.update_trail_state()
			new_trail.add_piece_blood(source, blood_to_add)
			return new_trail

	new_trail = new(src, source?.get_static_viruses())
	if(QDELETED(new_trail))
		return
	if(source)
		new_trail.add_mob_blood(source)
	else
		new_trail.add_blood_DNA(return_blood_DNA())
	new_trail.half_piece = half_piece
	new_trail.add_piece_blood(null, blood_to_add - new_trail.bloodiness)

	if(new_dir > 0)
		// add some free sprite variation by flipping it around
		if((new_dir in GLOB.cardinals) && prob(50) && !half_piece)
			new_trail.setDir(REVERSE_DIR(new_dir))
		else
			new_trail.setDir(new_dir)
	// negative dirs denote "straight diagonal" dirs
	else
		var/real_dir = abs(new_dir)
		new_trail.setDir(real_dir & (EAST|WEST))
		var/matrix/turned = matrix()
		switch(real_dir)
			if(NORTHEAST)
				turned.Turn(-45)
			if(NORTHWEST)
				turned.Turn(45)
			if(SOUTHEAST)
				turned.Turn(-135)
			if(SOUTHWEST)
				turned.Turn(135)
		new_trail.transform = turned
	new_trail.update_trail_state()

	LAZYSET(trail_components, "[new_dir]", new_trail)
	vis_contents += new_trail
	return new_trail

/// One piece of a blood trail, shown in a trail holder's vis_contents
/obj/effect/decal/cleanable/blood/trail
	name = "smuga krwi"
	desc = "Ślad krwi."
	icon = 'aquila/icons/effects/blood_trails.dmi'
	icon_state = "ltrails_1"
	random_icon_states = list("ltrails_1", "ltrails_2")
	vis_flags = VIS_INHERIT_LAYER | VIS_INHERIT_PLANE | VIS_INHERIT_ID
	appearance_flags = TILE_BOUND | PIXEL_SCALE | LONG_GLIDE | RESET_COLOR | KEEP_APART
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	bloodiness = BLOOD_AMOUNT_PER_DECAL * 0.1
	turf_loc_check = FALSE
	leaves_trace = FALSE // the holder leaves the trace
	/// Is this just half of a trail
	var/half_piece = FALSE
	/// Beyond a threshold we change to a bloodier icon state
	var/very_bloody = FALSE

/obj/effect/decal/cleanable/blood/trail/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	if(!istype(loc, /obj/effect/decal/cleanable/blood/trail_holder))
		return INITIALIZE_HINT_QDEL // only lives in a trail holder
	base_icon_state = icon_state

/// Adds blood from the mob and bloodiness, the piece gets the heavy sprite past a threshold
/obj/effect/decal/cleanable/blood/trail/proc/add_piece_blood(mob/living/source, amount)
	if(source)
		add_mob_blood(source)
	add_bloodiness(amount)
	if(very_bloody || bloodiness < 0.25 * BLOOD_AMOUNT_PER_DECAL)
		return
	very_bloody = TRUE
	base_icon_state = pick("trails_1", "trails_2")
	update_trail_state()

/obj/effect/decal/cleanable/blood/trail/proc/update_trail_state()
	icon_state = half_piece ? "[base_icon_state]_start" : base_icon_state

// Drops: each further drop on the turf is its own small decal in the first drop's vis_contents (tg make_blood_splatter())

/obj/effect/decal/cleanable/blood/drip
	/// Drops shown in our vis_contents
	var/list/obj/effect/decal/cleanable/blood/drip/part/drip_parts

/obj/effect/decal/cleanable/blood/drip/Destroy()
	. = ..()
	QDEL_LIST(drip_parts)

/obj/effect/decal/cleanable/blood/drip/proc/add_drip(mob/living/bleeder)
	drips++
	var/list/free_states = random_icon_states - icon_state
	for(var/obj/effect/decal/cleanable/blood/drip/part/existing as anything in drip_parts)
		free_states -= existing.icon_state
	var/obj/effect/decal/cleanable/blood/drip/part/new_drop = new(src)
	if(QDELETED(new_drop))
		return
	if(length(free_states))
		new_drop.icon_state = pick(free_states)
	new_drop.add_mob_blood(bleeder)
	LAZYADD(drip_parts, new_drop)
	vis_contents += new_drop

/obj/effect/decal/cleanable/blood/drip/part
	vis_flags = VIS_INHERIT_LAYER | VIS_INHERIT_PLANE | VIS_INHERIT_ID
	appearance_flags = TILE_BOUND | PIXEL_SCALE | LONG_GLIDE | RESET_COLOR | KEEP_APART
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	turf_loc_check = FALSE
	leaves_trace = FALSE // the first drop leaves the trace

#undef BLOOD_TRAIL_WALK_BLEED
#undef BLOOD_TRAIL_WALK_CHANCE
