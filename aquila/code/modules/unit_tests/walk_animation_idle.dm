// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - animacja chodu podpina bufor i fragmenty dopiero przy kroku i zdejmuje je w bezruchu,
/// oddając przedmioty w dłoniach jako zwykłe nakładki
/datum/unit_test/walk_animation_idle

/datum/unit_test/walk_animation_idle/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/next = get_step(start, EAST)
	TEST_ASSERT(isopenturf(next), "No open turf east of the test room corner")

	var/mob/living/carbon/human/walker = allocate(/mob/living/carbon/human, start)
	var/obj/item/crowbar/held = allocate(/obj/item/crowbar)
	walker.put_in_hands(held)
	var/datum/component/walk_animation/animation = walker.GetComponent(/datum/component/walk_animation)
	TEST_ASSERT(animation, "Human without a client has no walk animation")

	TEST_ASSERT(!animation.active, "Walk animation is active before the first step")
	TEST_ASSERT(walker.render_target != animation.body_target, "Standing human draws only into the walk buffer")
	TEST_ASSERT(length(walker.overlays_standing[HANDS_LAYER]), "Standing human has no held item overlay")

	var/area/test_area = get_area(start)
	var/old_gravity = test_area.has_gravity
	test_area.has_gravity = STANDARD_GRAVITY // w nieważkości animacja chodu się nie włącza, a pokój testowy nie ma generatora
	walker.Move(next, EAST)
	test_area.has_gravity = old_gravity
	TEST_ASSERT(walker.loc == next, "Human did not step east")
	TEST_ASSERT(animation.active, "Walk animation did not activate on a step")
	TEST_ASSERT(walker.render_target == animation.body_target, "Walking human does not draw into the walk buffer")
	TEST_ASSERT(animation.limbs["leg_a"] in walker.vis_contents, "Walking human has no leg fragment")
	TEST_ASSERT(!length(walker.overlays_standing[HANDS_LAYER]), "Held item stayed on the mob while walking")
	var/list/leg_filter = animation.limbs["leg_a"].filter_data?["walk_mask"]
	TEST_ASSERT(leg_filter?["render_source"] == "*walk_mask_leg_a_[walk_mask_dir(walker.dir)]", "Leg fragment does not use the shared mask for its direction")
	var/list/mask_screens = get_walk_mask_screens()
	TEST_ASSERT(length(mask_screens) == 20, "There are [length(mask_screens)] shared walk masks instead of 20 (5 masks x 4 directions)")
	var/mask_found = FALSE
	for(var/atom/movable/screen/walk_mask/mask as anything in mask_screens)
		if(mask.render_target == leg_filter["render_source"])
			mask_found = TRUE
			break
	TEST_ASSERT(mask_found, "No shared mask renders to [leg_filter["render_source"]], so the leg fragment would stay empty")
	// maska utworzona w trakcie startu serwera (pierwszy klient przed SSatoms) też musi się zainicjalizować
	var/old_atoms_state = SSatoms.initialized
	SSatoms.initialized = INITIALIZATION_INSSATOMS
	var/atom/movable/screen/walk_mask/early_mask = new(null, "leg_a", NORTH)
	SSatoms.initialized = old_atoms_state
	var/early_target = early_mask.render_target
	qdel(early_mask)
	TEST_ASSERT(early_target == "*walk_mask_leg_a_[NORTH]", "Walk mask created during server startup was never initialized (render_target [early_target])")

	animation.idle_after = 0
	animation.check_idle()
	TEST_ASSERT(!animation.active, "Walk animation stayed active after the idle delay")
	TEST_ASSERT(walker.render_target != animation.body_target, "Idle human still draws only into the walk buffer")
	TEST_ASSERT(!(animation.limbs["leg_a"] in walker.vis_contents), "Idle human kept the leg fragment")
	TEST_ASSERT(length(walker.overlays_standing[HANDS_LAYER]), "Held item overlay was not restored after walking")

	TEST_ASSERT(walk_mask_dir(NORTHEAST) == EAST && walk_mask_dir(SOUTHWEST) == WEST && walk_mask_dir(NORTH) == NORTH, "Diagonal directions do not map to side masks")

#undef TEST_ASSERT
