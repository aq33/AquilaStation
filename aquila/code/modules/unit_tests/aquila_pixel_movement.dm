// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - pixel movement prototype: the mob slides inside its tile via step_x, changes tile at the edge, stops at walls and resets when removed
/datum/unit_test/aquila_pixel_movement

/datum/unit_test/aquila_pixel_movement/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/east = get_step(start, EAST)
	TEST_ASSERT(east && !is_blocked_turf(east, exclude_mobs = TRUE), "No free turf east of the test room corner")

	var/mob/living/carbon/human/walker = allocate(/mob/living/carbon/human, start)
	var/datum/component/pixel_movement/pixel = walker.AddComponent(/datum/component/pixel_movement)
	TEST_ASSERT(pixel, "Component did not attach to a human")
	TEST_ASSERT(walker.bound_width == 1 && walker.bound_height == 1, "Mob did not get the 1x1 bounding box")

	// One step east stays on the same tile, only step_x grows; step_size and glide follow the per-tick distance
	pixel_step(pixel, walker, EAST)
	TEST_ASSERT(walker.loc == start, "A single pixel step changed the tile")
	TEST_ASSERT(walker.step_x > 0, "step_x did not grow after a step east (step_x = [walker.step_x])")
	TEST_ASSERT(walker.step_size == walker.step_x, "step_size ([walker.step_size]) is not the distance moved ([walker.step_x]), the client would not smooth it")

	// Keep walking: the tile changes once the centre passes the edge and step_x is compensated
	for(var/i in 1 to 20)
		if(walker.loc != start)
			break
		pixel_step(pixel, walker, EAST)
	TEST_ASSERT(walker.loc == east, "Mob did not move to the east tile (loc [walker.loc] at [walker.x],[walker.y])")
	TEST_ASSERT(walker.step_x < 0, "step_x was not compensated after the tile change (step_x = [walker.step_x])")
	TEST_ASSERT(length(walker.locs) == 1, "Mob overlaps [length(walker.locs)] turfs")

	// Into a wall: the body stops a few pixels into the edge and the tile stays
	var/turf/back = get_step(east, WEST)
	var/turf/wall_side = get_step(back, WEST)
	if(wall_side && is_blocked_turf(wall_side, exclude_mobs = TRUE))
		for(var/i in 1 to 30)
			pixel_step(pixel, walker, WEST)
		TEST_ASSERT(walker.loc == back, "Mob walking west did not stop on the tile next to the wall")
		TEST_ASSERT(walker.step_x == -6, "Mob next to a wall should stop at -6 px, got [walker.step_x]")

	qdel(pixel)
	TEST_ASSERT(walker.step_x == 0 && walker.step_y == 0, "Removing the component left the mob shifted ([walker.step_x],[walker.step_y])")
	TEST_ASSERT(walker.bound_width == world.icon_size && walker.step_size == world.icon_size, "Removing the component did not restore bounds and step_size")

/// on_pre_move ignores a second call in the same tick, so tests clear the guard instead of sleeping
/datum/unit_test/aquila_pixel_movement/proc/pixel_step(datum/component/pixel_movement/pixel, mob/living/walker, dir)
	pixel.last_step = -1
	pixel.next_bump_try = 0
	pixel.on_pre_move(walker, get_step(walker, dir))

#undef TEST_ASSERT
