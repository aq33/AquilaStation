// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Parametry kliknięcia w środek kratki siatki, tak jak przysłałby je klient
/proc/aquila_grid_cell_params(datum/component/storage/concrete/grid/grid, column, row)
	var/tile_x = grid.screen_start_x + column
	var/tile_y = grid.screen_start_y + (grid.grid_height - 1 - row)
	return "screen-loc=[tile_x]:[grid.screen_pixel_x + 5],[tile_y]:[grid.screen_pixel_y + 5]"

/datum/unit_test/storage_grid_mechanics/proc/make_item(w_class)
	var/obj/item/I = allocate(/obj/item)
	I.w_class = w_class
	return I

/// AQUILA - plecak na siatce: kształty z w_class, brak miejsca, przepełnienie przy włożeniu siłą, przesuwanie i obrót
/datum/unit_test/storage_grid_mechanics

/datum/unit_test/storage_grid_mechanics/Run()
	var/obj/item/storage/backpack/bag = allocate(/obj/item/storage/backpack)
	var/datum/component/storage/concrete/grid/grid = bag.GetComponent(/datum/component/storage/concrete/grid)
	TEST_ASSERT(grid, "Backpack has no grid storage")
	TEST_ASSERT_EQUAL(grid.grid_width, 7, "Backpack grid width")
	TEST_ASSERT_EQUAL(grid.grid_height, 4, "Backpack grid height")

	// 6 normalnych (2x2) zajmuje kolumny 0-5, zostaje kolumna 6 (1x4)
	var/list/normals = list()
	for(var/i in 1 to 6)
		var/obj/item/normal = make_item(WEIGHT_CLASS_NORMAL)
		TEST_ASSERT(SEND_SIGNAL(bag, COMSIG_TRY_STORAGE_INSERT, normal, null, TRUE), "Normal item [i] did not fit")
		normals += normal
	var/obj/item/extra_normal = make_item(WEIGHT_CLASS_NORMAL)
	TEST_ASSERT(!SEND_SIGNAL(bag, COMSIG_TRY_STORAGE_INSERT, extra_normal, null, TRUE), "Seventh normal item fit into a 1-wide gap")
	var/obj/item/small_a = make_item(WEIGHT_CLASS_SMALL)
	var/obj/item/small_b = make_item(WEIGHT_CLASS_SMALL)
	TEST_ASSERT(SEND_SIGNAL(bag, COMSIG_TRY_STORAGE_INSERT, small_a, null, TRUE), "Small item did not fit into the last column")
	TEST_ASSERT(SEND_SIGNAL(bag, COMSIG_TRY_STORAGE_INSERT, small_b, null, TRUE), "Second small item did not fit into the last column")
	var/list/pos = grid.grid_positions[small_a]
	TEST_ASSERT_EQUAL(pos[1], 6, "Small item column")
	var/obj/item/tiny = make_item(WEIGHT_CLASS_TINY)
	TEST_ASSERT(!SEND_SIGNAL(bag, COMSIG_TRY_STORAGE_INSERT, tiny, null, TRUE), "Tiny item fit into a full grid")

	// Włożenie siłą nie gubi przedmiotu: trafia do przepełnienia i wskakuje na siatkę, gdy zwolni się miejsce
	TEST_ASSERT(SEND_SIGNAL(bag, COMSIG_TRY_STORAGE_INSERT, tiny, null, TRUE, TRUE), "Forced insertion failed")
	TEST_ASSERT_EQUAL(tiny.loc, bag, "Forced item is not inside the bag")
	TEST_ASSERT(!LAZYACCESS(grid.grid_positions, tiny), "Forced item got a position in a full grid")
	var/obj/item/first = normals[1]
	TEST_ASSERT(SEND_SIGNAL(bag, COMSIG_TRY_STORAGE_TAKE, first, run_loc_floor_bottom_left), "Could not take an item out")
	TEST_ASSERT(!LAZYACCESS(grid.grid_positions, first), "Removed item kept its grid position")
	grid.settle_contents()
	pos = LAZYACCESS(grid.grid_positions, tiny)
	TEST_ASSERT(pos, "Overflowing item was not placed after space was freed")
	TEST_ASSERT_EQUAL(pos[1], 0, "Overflowing item column")
	TEST_ASSERT_EQUAL(pos[2], 0, "Overflowing item row")

	// Przesunięcie: tiny z (0,0) na (1,1), wolne są kratki 0-1 x 0-1
	TEST_ASSERT(grid.move_item(tiny, null, aquila_grid_cell_params(grid, 1, 1)), "Move was not handled")
	pos = grid.grid_positions[tiny]
	TEST_ASSERT_EQUAL(pos[1], 1, "Moved item column")
	TEST_ASSERT_EQUAL(pos[2], 1, "Moved item row")

	// Obrót: small na (0,0) pionowo, upuszczony na sobie kładzie się poziomo, jeśli jest miejsce
	TEST_ASSERT(SEND_SIGNAL(bag, COMSIG_TRY_STORAGE_TAKE, tiny, run_loc_floor_bottom_left), "Could not take the tiny item out")
	TEST_ASSERT(SEND_SIGNAL(bag, COMSIG_TRY_STORAGE_TAKE, small_a, run_loc_floor_bottom_left), "Could not take the small item out")
	grid.pending_cell = list(0, 0)
	TEST_ASSERT(SEND_SIGNAL(bag, COMSIG_TRY_STORAGE_INSERT, small_a, null, TRUE), "Small item did not fit at a chosen cell")
	pos = grid.grid_positions[small_a]
	TEST_ASSERT(pos[1] == 0 && pos[2] == 0 && !pos[3], "Small item was not placed upright at the chosen cell")
	TEST_ASSERT(grid.move_item(small_a, null, aquila_grid_cell_params(grid, 0, 0)), "Rotation was not handled")
	pos = grid.grid_positions[small_a]
	TEST_ASSERT(pos[3], "Small item was not rotated when dropped on itself")
	TEST_ASSERT(!grid.move_item(small_a, null, "screen-loc=1:1,1:1"), "A drop outside the grid was treated as a move")

	// Przedmioty z przepełnienia nie blokują wkładania na wolną kratkę (dawny limit max_items liczył całe contents)
	var/obj/item/storage/backpack/tiny_bag = allocate(/obj/item/storage/backpack)
	var/datum/component/storage/concrete/grid/tiny_grid = tiny_bag.GetComponent(/datum/component/storage/concrete/grid)
	var/obj/item/last_tiny
	for(var/i in 1 to tiny_grid.grid_width * tiny_grid.grid_height)
		last_tiny = make_item(WEIGHT_CLASS_TINY)
		TEST_ASSERT(SEND_SIGNAL(tiny_bag, COMSIG_TRY_STORAGE_INSERT, last_tiny, null, TRUE), "Tiny item [i] did not fit")
	var/obj/item/forced_normal = make_item(WEIGHT_CLASS_NORMAL)
	TEST_ASSERT(SEND_SIGNAL(tiny_bag, COMSIG_TRY_STORAGE_INSERT, forced_normal, null, TRUE, TRUE), "Forced normal item was not inserted")
	TEST_ASSERT(SEND_SIGNAL(tiny_bag, COMSIG_TRY_STORAGE_TAKE, last_tiny, run_loc_floor_bottom_left), "Could not take a tiny item out")
	TEST_ASSERT_EQUAL(tiny_grid.remaining_space_items(), 1, "Free cells next to an overflowing item")
	TEST_ASSERT(SEND_SIGNAL(tiny_bag, COMSIG_TRY_STORAGE_INSERT, last_tiny, null, TRUE), "Overflowing item blocked a free cell")

	// Bez obrotu, jeśli przedmiot mieści się prosto dalej na siatce: small w kolumnie 1, gdy kolumna 0 ma wolną tylko górną kratkę
	var/obj/item/storage/backpack/rotation_bag = allocate(/obj/item/storage/backpack)
	var/datum/component/storage/concrete/grid/rotation_grid = rotation_bag.GetComponent(/datum/component/storage/concrete/grid)
	var/obj/item/blocker = make_item(WEIGHT_CLASS_TINY)
	rotation_grid.pending_cell = list(0, 1)
	TEST_ASSERT(SEND_SIGNAL(rotation_bag, COMSIG_TRY_STORAGE_INSERT, blocker, null, TRUE), "Blocker did not fit")
	var/obj/item/upright = make_item(WEIGHT_CLASS_SMALL)
	TEST_ASSERT(SEND_SIGNAL(rotation_bag, COMSIG_TRY_STORAGE_INSERT, upright, null, TRUE), "Small item did not fit next to the blocker")
	pos = rotation_grid.grid_positions[upright]
	TEST_ASSERT(!pos[3], "Small item was rotated although it fits upright further in the grid")

	// Kliknięcie poza siatką nie wskazuje kratki
	TEST_ASSERT(!grid.params_to_cell("screen-loc=[grid.screen_start_x + grid.grid_width]:20,[grid.screen_start_y]:20"), "Cell found to the right of the grid")
	var/list/cell = grid.params_to_cell("screen-loc=mapwindow.map:[grid.screen_start_x]:20,[grid.screen_start_y]:20")
	TEST_ASSERT(cell && cell[1] == 0 && cell[2] == grid.grid_height - 1, "Screen-loc with a map name was not parsed")

/// AQUILA - zestawy startowe dalej mieszczą się w plecakach na siatce (każdy wariant plecaka, torby na ramię i podróżnej)
/datum/unit_test/storage_grid_outfits

/datum/unit_test/storage_grid_outfits/Run()
	var/list/failures = list()
	var/checked = 0
	for(var/outfit_type in subtypesof(/datum/outfit))
		var/datum/outfit/outfit = new outfit_type
		var/list/to_pack = list()
		if(outfit.box)
			to_pack[outfit.box] = 1
		for(var/path in outfit.backpack_contents)
			var/number = outfit.backpack_contents[path]
			to_pack[path] = (to_pack[path] || 0) + (isnum_safe(number) ? number : 1)
		var/list/bag_types = list()
		if(ispath(outfit.back, /obj/item/storage/backpack))
			bag_types |= outfit.back
			if(istype(outfit, /datum/outfit/job))
				var/datum/outfit/job/job_outfit = outfit
				bag_types |= list(job_outfit.backpack, job_outfit.satchel, job_outfit.duffelbag, /obj/item/storage/backpack/satchel/leather)
		qdel(outfit)
		if(!length(to_pack))
			continue
		for(var/bag_type in bag_types)
			if(!ispath(bag_type, /obj/item/storage/backpack))
				continue
			var/failure = check_packing(bag_type, to_pack)
			checked++
			if(failure)
				failures += "[outfit_type] w [bag_type]: [failure]"
	TEST_ASSERT(checked, "No outfit was checked")
	if(length(failures))
		return Fail("Zestawy startowe nie mieszczą się na siatce:\n[jointext(failures, "\n")]")

/// Pakuje zestaw jak /datum/outfit/equip (kolejno, bez siły). Zwraca opis błędu tylko wtedy, gdy przedmiot odrzuciła sama siatka,
/// a stare limity wagi i liczby by go przyjęły (inne odmowy, np. can_hold, były już wcześniej i nie są winą siatki)
/datum/unit_test/storage_grid_outfits/proc/check_packing(bag_type, list/to_pack)
	var/obj/item/storage/backpack/bag = new bag_type(run_loc_floor_bottom_left)
	var/datum/component/storage/concrete/grid/grid = bag.GetComponent(/datum/component/storage/concrete/grid)
	if(!grid?.grid_width)
		qdel(bag)
		return null
	var/old_weight = 0
	for(var/obj/item/already in bag)
		old_weight += already.w_class
	var/old_items = length(bag.contents)
	. = null
	for(var/path in to_pack)
		if(!ispath(path, /obj/item))
			continue
		for(var/i in 1 to to_pack[path])
			var/obj/item/I = new path(run_loc_floor_bottom_left)
			if(QDELETED(I))
				continue
			var/old_rules_fit = I.w_class <= grid.max_w_class && old_weight + I.w_class <= grid.grid_base_weight && old_items < grid.grid_base_items
			if(SEND_SIGNAL(bag, COMSIG_TRY_STORAGE_INSERT, I, null, TRUE))
				old_weight += I.w_class
				old_items++
				continue
			var/grid_refused = old_rules_fit && !grid.find_spot_for(I)
			qdel(I)
			if(grid_refused)
				. = "brak miejsca na [path]"
				break
		if(.)
			break
	for(var/atom/movable/thing in bag)
		qdel(thing)
	qdel(bag)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
