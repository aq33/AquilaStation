// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
/// Must match PIXEL_MOVE_WALL_MARGIN in the component (16 px half tile - 11 px half body)
#define TEST_WALL_MARGIN 5

/// AQUILA - pixel movement prototype: acceleration, coasting, walls, directional windows, corners, mob swap and the tile-based hooks
/datum/unit_test/aquila_pixel_movement

/datum/unit_test/aquila_pixel_movement/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/east = get_step(start, EAST)
	var/turf/north = get_step(start, NORTH)
	var/turf/north_east = get_step(east, NORTH)
	TEST_ASSERT(east && north && north_east, "Test room is smaller than 2x2")
	TEST_ASSERT(!is_blocked_turf(east, exclude_mobs = TRUE) && !is_blocked_turf(north, exclude_mobs = TRUE) && !is_blocked_turf(north_east, exclude_mobs = TRUE), "No free 2x2 floor in the test room corner")

	// The test room has no gravity generator, and in zero gravity the component falls back to tile movement
	var/area/test_area = get_area(start)
	var/old_gravity = test_area.has_gravity
	test_area.has_gravity = STANDARD_GRAVITY
	// Earlier tests in a full run can leave the room floor wet; a slipped mob lies down, stops being dense and walks through others
	for(var/turf/open/floor in list(start, east, north, north_east, get_step(start, WEST)))
		floor.MakeDry(ALL, TRUE)
	. = run_checks(start, east, north, north_east)
	test_area.has_gravity = old_gravity

/datum/unit_test/aquila_pixel_movement/proc/run_checks(turf/start, turf/east, turf/north, turf/north_east)
	var/mob/living/carbon/human/walker = allocate(/mob/living/carbon/human, start)
	ADD_TRAIT(walker, TRAIT_NOSLIPALL, "unit_test")
	var/datum/component/pixel_movement/pixel = walker.AddComponent(/datum/component/pixel_movement)
	TEST_ASSERT(pixel, "Component did not attach to a human")
	TEST_ASSERT(walker.bound_width == 1 && walker.bound_height == 1, "Mob did not get the 1x1 bounding box")
	TEST_ASSERT(HAS_TRAIT(walker, TRAIT_PIXEL_MOVEMENT), "Mob did not get TRAIT_PIXEL_MOVEMENT")

	// One step east stays on the same tile; step_size and glide follow the distance, and the first tick is still accelerating
	pixel_step(pixel, walker, EAST)
	var/first_step = walker.step_x
	TEST_ASSERT(walker.loc == start, "A single pixel step changed the tile")
	TEST_ASSERT(first_step > 0, "step_x did not grow after a step east (step_x = [first_step])")
	TEST_ASSERT(walker.step_size == first_step, "step_size ([walker.step_size]) is not the distance moved ([first_step]), the client would not smooth it")
	pixel_step(pixel, walker, EAST)
	TEST_ASSERT(walker.step_x - first_step > first_step, "Second tick did not move further than the first ([first_step] then [walker.step_x - first_step] px), no acceleration")

	// Keep walking: the tile changes once the centre passes the edge and step_x is compensated
	for(var/i in 1 to 20)
		if(walker.loc != start)
			break
		pixel_step(pixel, walker, EAST)
	TEST_ASSERT(walker.loc == east, "Mob did not move to the east tile (loc [walker.loc] at [walker.x],[walker.y])")
	TEST_ASSERT(walker.step_x < 0, "step_x was not compensated after the tile change (step_x = [walker.step_x])")
	TEST_ASSERT(length(walker.locs) == 1, "Mob overlaps [length(walker.locs)] turfs")

	// Releasing the key: a short slide, then a stop
	var/released_at = walker.step_x
	for(var/i in 1 to 20)
		if(!pixel.vel_x)
			break
		pixel_coast(pixel)
	TEST_ASSERT(!pixel.vel_x && !pixel.vel_y, "Mob is still sliding 20 ticks after releasing the key")
	var/slide = walker.step_x - released_at
	TEST_ASSERT(walker.loc == east && slide > 0 && slide < 10, "Slide after releasing the key is [slide] px (loc [walker.x],[walker.y]), expected a few pixels")

	// Into a wall: the body stops a few pixels from the edge and loses its speed towards the wall
	var/turf/wall_side = get_step(start, WEST)
	if(wall_side && is_blocked_turf(wall_side, exclude_mobs = TRUE))
		for(var/i in 1 to 40)
			pixel_step(pixel, walker, WEST)
		TEST_ASSERT(walker.loc == start, "Mob walking west did not stop on the tile next to the wall")
		TEST_ASSERT(walker.step_x == -TEST_WALL_MARGIN, "Mob next to a wall should stop at -[TEST_WALL_MARGIN] px, got [walker.step_x]")
		TEST_ASSERT(!pixel.vel_x, "Mob pressed into a wall kept its speed towards it ([pixel.vel_x])")

	// A directional window on the east edge of our own tile blocks leaving east
	place(pixel, walker, start, 0, 0)
	var/obj/structure/window/window = allocate(/obj/structure/window, start, EAST)
	for(var/i in 1 to 10)
		pixel_step(pixel, walker, EAST)
	TEST_ASSERT(walker.loc == start && walker.step_x == TEST_WALL_MARGIN, "Directional window facing east did not stop the mob (loc [walker.x],[walker.y], step_x [walker.step_x])")
	qdel(window)

	// Body sticking out north next to a blocked north-east corner: walking east slides it off the corner first
	var/obj/structure/girder/corner = allocate(/obj/structure/girder, north_east)
	place(pixel, walker, start, 0, 10)
	for(var/i in 1 to 20)
		if(walker.loc != start)
			break
		pixel_step(pixel, walker, EAST)
		// The front of the body may enter the east column only once its side no longer overlaps the corner row
		TEST_ASSERT(walker.step_x <= TEST_WALL_MARGIN || walker.step_y <= TEST_WALL_MARGIN, "Body clips into the blocked corner (step [walker.step_x],[walker.step_y])")
	TEST_ASSERT(walker.loc == east && walker.step_y == TEST_WALL_MARGIN, "Mob did not slide off the corner and get past it (loc [walker.x],[walker.y], step [walker.step_x],[walker.step_y])")
	qdel(corner)

	// Another mob in the way: the bump at contact swaps places like in tile movement
	place(pixel, walker, start, 0, 0)
	var/mob/living/carbon/human/blocker = allocate(/mob/living/carbon/human, east)
	var/blocker_state = mob_state(blocker)
	var/walker_state = mob_state(walker)
	for(var/i in 1 to 20)
		if(walker.loc != start)
			break
		pixel_step(pixel, walker, EAST)
	TEST_ASSERT(walker.loc == east && blocker.loc == start, "Walking into a help-intent mob did not swap places (walker [walker.x],[walker.y] [walker_state] -> [mob_state(walker)], other [blocker.x],[blocker.y] [blocker_state] -> [mob_state(blocker)])")
	qdel(blocker)

	// Built-in step() hands such a mob its own tile and pixel offsets; the Move() hook turns it into a tile step.
	// Diagonal Move() splits into step() calls, so without the hook being pulled diagonally would always fail.
	place(pixel, walker, start, 7, -3)
	TEST_ASSERT(step(walker, NORTH) && walker.loc == north, "step() did not move the mob a whole tile north (loc [walker.x],[walker.y])")
	place(pixel, walker, start, 7, -3)
	walker.Move(north_east, NORTHEAST)
	TEST_ASSERT(walker.loc == north_east, "Diagonal Move() did not reach the north-east tile (loc [walker.x],[walker.y])")
	TEST_ASSERT(walker.step_size == world.icon_size, "A tile move by someone else left step_size at [walker.step_size], the client would jump instead of gliding")

	// forceMove keeps step_x in BYOND, the component puts the mob back in the middle of the tile
	place(pixel, walker, start, 9, 9)
	walker.forceMove(east)
	TEST_ASSERT(walker.step_x == 0 && walker.step_y == 0, "forceMove left the mob shifted ([walker.step_x],[walker.step_y])")

	// Buckling on the same tile has no forceMove
	place(pixel, walker, start, 9, -9)
	var/obj/structure/chair/chair = allocate(/obj/structure/chair, start)
	chair.buckle_mob(walker)
	TEST_ASSERT(walker.buckled == chair, "Mob did not buckle to the chair")
	TEST_ASSERT(walker.step_x == 0 && walker.step_y == 0, "Buckled mob sits next to the chair ([walker.step_x],[walker.step_y])")
	chair.unbuckle_mob(walker)
	qdel(chair)

	place(pixel, walker, start, 9, 9)
	qdel(pixel)
	TEST_ASSERT(walker.step_x == 0 && walker.step_y == 0, "Removing the component left the mob shifted ([walker.step_x],[walker.step_y])")
	TEST_ASSERT(walker.bound_width == world.icon_size && walker.step_size == world.icon_size, "Removing the component did not restore bounds and step_size")
	TEST_ASSERT(!HAS_TRAIT(walker, TRAIT_PIXEL_MOVEMENT), "Removing the component left TRAIT_PIXEL_MOVEMENT")

/// on_pre_move ignores a second call in the same tick, so tests clear the guards instead of sleeping
/datum/unit_test/aquila_pixel_movement/proc/pixel_step(datum/component/pixel_movement/pixel, mob/living/walker, dir)
	pixel.last_step = -1
	pixel.last_external_move = -1
	pixel.next_bump_try = 0
	pixel.on_pre_move(walker, get_step(walker, dir))

/datum/unit_test/aquila_pixel_movement/proc/pixel_coast(datum/component/pixel_movement/pixel)
	pixel.last_step = -1
	pixel.last_external_move = -1
	pixel.coast()

/datum/unit_test/aquila_pixel_movement/proc/mob_state(mob/living/carbon/human/H)
	return "(density [H.density], lying [H.lying], stand [!!(H.mobility_flags & MOBILITY_STAND)], stat [H.stat], combat [H.combat_mode], passmob [!!(H.pass_flags & PASSMOB)], blind [H.is_blind()], confused [H.confused], step [H.step_x],[H.step_y])"

/// Puts the mob at a given offset on a tile, standing still
/datum/unit_test/aquila_pixel_movement/proc/place(datum/component/pixel_movement/pixel, mob/living/walker, turf/where, offset_x, offset_y)
	walker.forceMove(where)
	pixel.stop_motion()
	walker.step_x = offset_x
	walker.step_y = offset_y
	walker.setDir(SOUTH)

#undef TEST_WALL_MARGIN
#undef TEST_ASSERT
