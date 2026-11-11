// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// TRUE when BYOND draws something with this plane and layer on top of the turf (plane first, then layer)
/proc/aquila_test_drawn_above(atom_plane, atom_layer, turf/floor)
	return atom_plane > floor.plane || (atom_plane == floor.plane && atom_layer > floor.layer)

/// AQUILA - lattices, catwalks and hull plates on a floor are drawn above it, hidden pipes on every piping layer
/// lie above a catwalk and under a covered catwalk, which also blocks clicks on them
/datum/unit_test/aquila_audyt_warstwy_layers

/datum/unit_test/aquila_audyt_warstwy_layers/Run()
	var/turf/floor = run_loc_floor_bottom_left
	var/obj/structure/hull_plate/plate_type = /obj/structure/hull_plate
	TEST_ASSERT(aquila_test_drawn_above(initial(plate_type.plane), initial(plate_type.layer), floor), "A hull plate is drawn under the floor turf")

	var/obj/structure/lattice/lattice = allocate(/obj/structure/lattice, floor)
	TEST_ASSERT(aquila_test_drawn_above(lattice.plane, lattice.layer, floor), "A lattice is drawn under the floor turf")
	qdel(lattice)

	var/obj/structure/lattice/catwalk/catwalk = allocate(/obj/structure/lattice/catwalk, floor)
	TEST_ASSERT(aquila_test_drawn_above(catwalk.plane, catwalk.layer, floor), "A catwalk is drawn under the floor turf")

	var/obj/machinery/atmospherics/pipe/simple/general/hidden/pipe = allocate(/obj/machinery/atmospherics/pipe/simple/general/hidden, floor)
	for(var/piping_layer in PIPING_LAYER_MIN to PIPING_LAYER_MAX)
		pipe.piping_layer = piping_layer
		pipe.update_layer()
		TEST_ASSERT(pipe.layer > catwalk.layer, "A hidden pipe on piping layer [piping_layer] ([pipe.layer]) is under a catwalk ([catwalk.layer])")
		TEST_ASSERT(!pipe.IsObscured(), "A catwalk blocks clicks on a hidden pipe on piping layer [piping_layer]")
	qdel(catwalk)

	var/obj/structure/lattice/catwalk/over/ship/covered = allocate(/obj/structure/lattice/catwalk/over/ship, floor)
	TEST_ASSERT(covered.flags_1 & PREVENT_CLICK_UNDER_1, "A closed covered catwalk does not block clicks under it")
	for(var/piping_layer in PIPING_LAYER_MIN to PIPING_LAYER_MAX)
		pipe.piping_layer = piping_layer
		pipe.update_layer()
		TEST_ASSERT(pipe.layer < covered.layer, "A hidden pipe on piping layer [piping_layer] ([pipe.layer]) is drawn over a covered catwalk ([covered.layer])")
		TEST_ASSERT(pipe.IsObscured(), "A hidden pipe on piping layer [piping_layer] can be clicked through a closed covered catwalk")
	TEST_ASSERT(covered.layer < CLOSED_TURF_LAYER, "A covered catwalk is above the walls")

/// AQUILA - a lattice on a floor shows up on a photo (the camera sorted by layer only and painted the turf over it)
/datum/unit_test/aquila_audyt_warstwy_photo

/datum/unit_test/aquila_audyt_warstwy_photo/Run()
	var/turf/floor = run_loc_floor_bottom_left
	var/obj/item/camera/camera = allocate(/obj/item/camera, run_loc_floor_top_right)
	camera.silent = TRUE
	// Like a 3x3 shot from /obj/item/camera/captureimage(): the scene is cloned into a reservation
	var/datum/turf_reservation/clone_area = SSmapping.RequestBlockReservation(3, 3)
	var/icon/without = camera.camera_get_icon(list(floor), floor, 96, 96, clone_area, 1, 1, 3, 3)
	var/obj/structure/lattice/lattice = allocate(/obj/structure/lattice, floor)
	// Smoothing draws the lattice with corner overlays later (SSicon_smooth, SSoverlays), the plain sprite is enough for the sort
	lattice.smooth = SMOOTH_FALSE
	lattice.icon_state = "lattice"
	var/icon/with = camera.camera_get_icon(list(floor), floor, 96, 96, clone_area, 1, 1, 3, 3)
	qdel(clone_area)
	var/floor_drawn = FALSE
	var/differs = FALSE
	for(var/x in 33 to 64)
		for(var/y in 33 to 64)
			if(without.GetPixel(x, y))
				floor_drawn = TRUE
			if(without.GetPixel(x, y) != with.GetPixel(x, y))
				differs = TRUE
	TEST_ASSERT(floor_drawn, "The floor is not on the photo")
	TEST_ASSERT(differs, "A lattice on the floor does not show up on a photo")

/// AQUILA - an item put into a grid storage does not catch clicks with its whole 32 px icon over the neighbouring cells
/datum/unit_test/aquila_audyt_warstwy_grid_click

/datum/unit_test/aquila_audyt_warstwy_grid_click/Run()
	var/obj/item/storage/backpack/bag = allocate(/obj/item/storage/backpack)
	var/datum/component/storage/concrete/grid/grid = bag.GetComponent(/datum/component/storage/concrete/grid)
	TEST_ASSERT(grid?.grid_width, "A backpack has no grid")
	var/obj/item/screwdriver/tool = allocate(/obj/item/screwdriver)
	TEST_ASSERT(grid.handle_item_insertion(tool, TRUE), "A screwdriver did not fit into an empty backpack")
	TEST_ASSERT_EQUAL(tool.loc, bag, "The screwdriver is not in the backpack")
	TEST_ASSERT_EQUAL(tool.mouse_opacity, MOUSE_OPACITY_TRANSPARENT, "An item put into a grid storage catches clicks with its whole icon")

/// AQUILA - admin boxes with capacity 1000 do not get a grid taller than the screen
/datum/unit_test/aquila_audyt_warstwy_admin_boxes

/datum/unit_test/aquila_audyt_warstwy_admin_boxes/Run()
	for(var/box_type in list(/obj/item/storage/box/material, /obj/item/storage/box/debugtools))
		var/obj/item/storage/box/box = allocate(box_type)
		var/datum/component/storage/concrete/grid/grid = box.GetComponent(/datum/component/storage/concrete/grid)
		if(!grid)
			continue
		TEST_ASSERT(grid.grid_height <= grid.grid_max_grown_height(), "[box_type] has a grid [grid.grid_width]x[grid.grid_height], its contents are off the screen")

/// AQUILA - a right click with a cable coil on a power machine lays one cable under the machine and stops there
/datum/unit_test/aquila_audyt_warstwy_cable_rmb

/datum/unit_test/aquila_audyt_warstwy_cable_rmb/Run()
	var/turf/user_turf = run_loc_floor_bottom_left
	var/turf/machine_turf = get_step(user_turf, EAST)
	var/user_turf_type = user_turf.type
	var/machine_turf_type = machine_turf.type
	user_turf = user_turf.ChangeTurf(/turf/open/floor/plating)
	machine_turf = machine_turf.ChangeTurf(/turf/open/floor/plating)

	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, user_turf)
	var/obj/machinery/power/terminal/terminal = allocate(/obj/machinery/power/terminal, machine_turf)
	var/obj/item/stack/cable_coil/coil = allocate(/obj/item/stack/cable_coil, user_turf)
	user.put_in_active_hand(coil)
	coil.melee_attack_chain(user, terminal, "[RIGHT_CLICK]=1")

	var/cables_under_machine = 0
	for(var/obj/structure/cable/cable in machine_turf)
		cables_under_machine++
	var/cables_under_user = 0
	for(var/obj/structure/cable/cable in user_turf)
		cables_under_user++
	var/coil_left = coil.amount

	// Floors go back before the asserts, so a failed test does not leave plating for other tests (Destroy() clears the contents)
	user_turf.ChangeTurf(user_turf_type)
	machine_turf.ChangeTurf(machine_turf_type)

	TEST_ASSERT_EQUAL(cables_under_machine, 1, "A right click with a coil did not lay one cable under the machine")
	TEST_ASSERT_EQUAL(cables_under_user, 0, "After the right click the machine also got the coil in attackby() and laid a cable under the user")
	TEST_ASSERT_EQUAL(coil_left, MAXCOIL - 1, "A right click with a coil used more than one piece of cable")

/// AQUILA - a mob without hands cannot fold a chair by dragging it onto itself, a human still can
/datum/unit_test/aquila_audyt_warstwy_chair_drag

/datum/unit_test/aquila_audyt_warstwy_chair_drag/Run()
	var/turf/floor = run_loc_floor_bottom_left
	var/obj/structure/chair/chair = allocate(/obj/structure/chair, floor)
	var/mob/living/basic/pet/dog/corgi/dog = allocate(/mob/living/basic/pet/dog/corgi, floor)
	usr = dog
	chair.MouseDrop(dog, floor, floor)
	usr = null
	TEST_ASSERT(!QDELETED(chair), "A corgi folded a chair by dragging it onto itself")

	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human, floor)
	usr = human
	chair.MouseDrop(human, floor, floor)
	usr = null
	TEST_ASSERT(QDELETED(chair), "A human could not fold a chair by dragging it onto themselves")
	TEST_ASSERT(istype(human.get_active_held_item(), /obj/item/chair) || istype(human.get_inactive_held_item(), /obj/item/chair), "The folded chair is not in the human's hands")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
