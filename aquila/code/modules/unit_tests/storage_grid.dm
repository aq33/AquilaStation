// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Parametry kliknięcia 5 pikseli od lewego dolnego rogu kratki, tak jak przysłałby je klient.
/// Kratki są mniejsze niż kafel ekranu, więc piksel rozkładamy na kafel i przesunięcie (screen-loc liczy piksele od 1)
/proc/aquila_grid_cell_params(datum/component/storage/concrete/grid/grid, column, row)
	var/tile = world.icon_size
	var/total_x = (grid.screen_start_x - 1) * tile + grid.screen_pixel_x + column * grid.grid_cell_size + 5
	var/total_y = (grid.screen_start_y - 1) * tile + grid.screen_pixel_y + (grid.grid_height - 1 - row) * grid.grid_cell_size + 5
	var/tile_x = FLOOR(total_x / tile, 1)
	var/tile_y = FLOOR(total_y / tile, 1)
	return "screen-loc=[tile_x + 1]:[total_x - tile_x * tile + 1],[tile_y + 1]:[total_y - tile_y * tile + 1]"

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

	// Obrót klawiszem (E/Q w trakcie przeciągania) obraca tylko podgląd: small na (0,0) leży pionowo do upuszczenia,
	// a upuszczony na swoim miejscu kładzie się poziomo i ikona obraca się razem z nim
	TEST_ASSERT(SEND_SIGNAL(bag, COMSIG_TRY_STORAGE_TAKE, tiny, run_loc_floor_bottom_left), "Could not take the tiny item out")
	TEST_ASSERT(SEND_SIGNAL(bag, COMSIG_TRY_STORAGE_TAKE, small_a, run_loc_floor_bottom_left), "Could not take the small item out")
	grid.pending_cell = list(0, 0)
	TEST_ASSERT(SEND_SIGNAL(bag, COMSIG_TRY_STORAGE_INSERT, small_a, null, TRUE), "Small item did not fit at a chosen cell")
	pos = grid.grid_positions[small_a]
	TEST_ASSERT(pos[1] == 0 && pos[2] == 0 && !pos[3], "Small item was not placed upright at the chosen cell")
	var/small_scale = grid.grid_icon_scale(1, 2)
	TEST_ASSERT(grid.rotate_item(small_a, null, TRUE), "Rotation was not handled")
	pos = grid.grid_positions[small_a]
	TEST_ASSERT(pos[1] == 0 && pos[2] == 0 && !pos[3] && grid.grid_angle(pos) == 0, "Rotating while dragging turned the item in the bag instead of the preview")
	TEST_ASSERT_EQUAL(grid.grid_pending_rotation[small_a], 90, "Clockwise preview angle")
	grid.orient2hud()
	var/matrix/turned = small_a.transform
	TEST_ASSERT(abs(turned.a - small_scale) < 0.01 && abs(turned.b) < 0.01, "Item icon in the bag turned before the drop")
	var/list/rotated_landing = grid.drag_landing(small_a, aquila_grid_cell_params(grid, 0, 0))
	TEST_ASSERT(rotated_landing && rotated_landing[3] && rotated_landing[4] == 90 && rotated_landing[5], "The preview does not show the chosen rotation")
	TEST_ASSERT(grid.move_item(small_a, null, aquila_grid_cell_params(grid, 0, 0)), "Drop with a rotation was not handled")
	pos = grid.grid_positions[small_a]
	TEST_ASSERT(pos[1] == 0 && pos[2] == 0 && pos[3], "Small item was not rotated in place on drop")
	TEST_ASSERT_EQUAL(grid.grid_angle(pos), 90, "Clockwise rotation angle")
	grid.orient2hud()
	turned = small_a.transform
	TEST_ASSERT(abs(turned.a) < 0.01 && abs(abs(turned.b) - small_scale) < 0.01, "Item icon was not turned with its shape")
	// Upuszczenie na sobie samym niczego już nie obraca
	TEST_ASSERT(grid.move_item(small_a, null, aquila_grid_cell_params(grid, 0, 0)), "Drop on itself was not handled")
	pos = grid.grid_positions[small_a]
	TEST_ASSERT(pos[3] && grid.grid_angle(pos) == 90, "Drop on itself changed the rotation")
	// Q z powrotem: pionowo, ikona prosto
	TEST_ASSERT(grid.rotate_item(small_a, null, FALSE), "Counter-clockwise rotation was not handled")
	TEST_ASSERT(grid.move_item(small_a, null, aquila_grid_cell_params(grid, 0, 0)), "Counter-clockwise drop was not handled")
	pos = grid.grid_positions[small_a]
	TEST_ASSERT(!pos[3] && grid.grid_angle(pos) == 0, "Counter-clockwise rotation did not undo the turn")
	grid.orient2hud()
	turned = small_a.transform
	TEST_ASSERT(abs(turned.a - small_scale) < 0.01 && abs(turned.b) < 0.01, "Item icon stayed turned after rotating back")
	TEST_ASSERT(!grid.move_item(small_a, null, "screen-loc=1:1,1:1"), "A drop outside the grid was treated as a move")

	// Obrót bez miejsca w miejscu czeka na upuszczenie: small pionowo w (0,0), obok tiny w (1,0)
	var/obj/item/storage/backpack/turn_bag = allocate(/obj/item/storage/backpack)
	var/datum/component/storage/concrete/grid/turn_grid = turn_bag.GetComponent(/datum/component/storage/concrete/grid)
	var/obj/item/turning = make_item(WEIGHT_CLASS_SMALL)
	turn_grid.pending_cell = list(0, 0)
	TEST_ASSERT(SEND_SIGNAL(turn_bag, COMSIG_TRY_STORAGE_INSERT, turning, null, TRUE), "Small item did not fit into an empty bag")
	var/obj/item/side_blocker = make_item(WEIGHT_CLASS_TINY)
	turn_grid.pending_cell = list(1, 0)
	TEST_ASSERT(SEND_SIGNAL(turn_bag, COMSIG_TRY_STORAGE_INSERT, side_blocker, null, TRUE), "Side blocker did not fit")
	TEST_ASSERT(turn_grid.rotate_item(turning, null, TRUE), "Blocked rotation was not handled")
	pos = turn_grid.grid_positions[turning]
	TEST_ASSERT(!pos[3], "Item rotated into an occupied cell")
	TEST_ASSERT_EQUAL(turn_grid.grid_pending_rotation[turning], 90, "Blocked rotation was not kept for the drop")
	TEST_ASSERT(turn_grid.move_item(turning, null, aquila_grid_cell_params(turn_grid, 3, 3)), "Drop with a pending rotation was not handled")
	pos = turn_grid.grid_positions[turning]
	TEST_ASSERT(pos[1] == 3 && pos[2] == 3 && pos[3], "Pending rotation was not applied on drop")
	TEST_ASSERT(isnull(LAZYACCESS(turn_grid.grid_pending_rotation, turning)), "Pending rotation stayed after the drop")
	// Podgląd lądowania liczy to samo co upuszczenie. Teraz: turning poziomo w (3,3)-(4,3), side_blocker w (1,0)
	var/list/landing = turn_grid.drag_landing(turning, aquila_grid_cell_params(turn_grid, 3, 3))
	TEST_ASSERT(landing && landing[1] == 3 && landing[2] == 3 && landing[3] && landing[5], "Landing over its own place should keep the position")
	landing = turn_grid.drag_landing(turning, aquila_grid_cell_params(turn_grid, 0, 2))
	TEST_ASSERT(landing && landing[1] == 0 && landing[2] == 2 && landing[3] && landing[4] == 90 && landing[5], "Landing over a free cell")
	landing = turn_grid.drag_landing(turning, aquila_grid_cell_params(turn_grid, 1, 0))
	TEST_ASSERT(landing && !landing[5], "Landing over an occupied cell should not fit")
	TEST_ASSERT(!turn_grid.drag_landing(turning, "screen-loc=1:1,1:1"), "Landing found outside the grid")
	// Po obrocie klawiszem (180°, pionowo, w miejscu przy dolnej krawędzi) podgląd pokazuje nowe ułożenie
	TEST_ASSERT(turn_grid.rotate_item(turning, null, TRUE), "Second rotation was not handled")
	landing = turn_grid.drag_landing(turning, aquila_grid_cell_params(turn_grid, 0, 2))
	TEST_ASSERT(landing && landing[1] == 0 && landing[2] == 2 && !landing[3] && landing[4] == 180 && landing[5], "Landing does not follow the rotation chosen while dragging")
	var/atom/movable/screen/storage_grid_preview/preview = allocate(/atom/movable/screen/storage_grid_preview)
	turn_grid.apply_drag_preview(preview, turning, landing)
	TEST_ASSERT_EQUAL(length(preview.overlays), 3, "Preview of a 1x2 item should have 2 cell outlines and the ghost icon")
	TEST_ASSERT(turn_grid.move_item(turning, null, aquila_grid_cell_params(turn_grid, 0, 2)), "Drop after the preview was not handled")
	pos = turn_grid.grid_positions[turning]
	TEST_ASSERT(pos[1] == landing[1] && pos[2] == landing[2] && pos[3] == landing[3] && turn_grid.grid_angle(pos) == landing[4], "Drop landed somewhere else than the preview showed")
	// Obrót kwadratu zmienia tylko ikonę
	var/obj/item/square = make_item(WEIGHT_CLASS_NORMAL)
	TEST_ASSERT(SEND_SIGNAL(turn_bag, COMSIG_TRY_STORAGE_INSERT, square, null, TRUE), "Normal item did not fit")
	var/list/square_pos = turn_grid.grid_positions[square]
	var/list/square_cell = list(square_pos[1], square_pos[2])
	TEST_ASSERT(turn_grid.rotate_item(square, null, FALSE), "Square rotation was not handled")
	// Obrót w trakcie przeciągania obraca tylko podgląd: przedmiot w plecaku leży po staremu do upuszczenia
	TEST_ASSERT_EQUAL(turn_grid.grid_angle(turn_grid.grid_positions[square]), 0, "Rotating while dragging turned the item in the bag instead of the preview")
	TEST_ASSERT_EQUAL(turn_grid.grid_pending_rotation[square], 270, "Square counter-clockwise preview angle")
	TEST_ASSERT(turn_grid.move_item(square, null, aquila_grid_cell_params(turn_grid, square_cell[1], square_cell[2])), "Square drop was not handled")
	TEST_ASSERT_EQUAL(turn_grid.grid_angle(turn_grid.grid_positions[square]), 270, "Square counter-clockwise angle after the drop")

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

	// Wygląd na siatce: ikona 2x2 powiększona, kafel z 4 nakładek, nagłówek z zajętością; po wyjęciu przedmiot wraca do dawnego wyglądu
	var/obj/item/storage/backpack/look_bag = allocate(/obj/item/storage/backpack)
	var/datum/component/storage/concrete/grid/look_grid = look_bag.GetComponent(/datum/component/storage/concrete/grid)
	var/obj/item/big = make_item(WEIGHT_CLASS_NORMAL)
	var/old_flags = big.appearance_flags
	TEST_ASSERT(SEND_SIGNAL(look_bag, COMSIG_TRY_STORAGE_INSERT, big, null, TRUE), "Normal item did not fit into an empty bag")
	look_grid.orient2hud()
	// The icon overflows its 24 px cells, so only the item tile catches the mouse
	TEST_ASSERT_EQUAL(big.mouse_opacity, MOUSE_OPACITY_TRANSPARENT, "An item icon on the grid catches clicks meant for neighbouring cells")
	var/matrix/shown = big.transform
	// Ikony nie są skalowane do kratek (24 px): ułamkowa skala 0,75 albo 1,5 rozmywała piksele
	TEST_ASSERT_EQUAL(shown.a, 1, "Normal item icon was scaled, so its pixels get blurry or uneven")
	TEST_ASSERT_EQUAL(look_grid.grid_icon_scale(1, 1), 1, "A 1x1 icon is scaled, so it gets blurry")
	TEST_ASSERT(big.appearance_flags & PIXEL_SCALE, "Scaled icon has no PIXEL_SCALE")
	var/atom/movable/screen/storage_grid_item/tile = look_grid.grid_highlights[big]
	TEST_ASSERT_EQUAL(length(tile.overlays), 4, "A 2x2 item tile should have 4 cell overlays")
	TEST_ASSERT(findtext(look_grid.grid_header.maptext, "4/28"), "Header does not show used cells: [look_grid.grid_header.maptext]")
	TEST_ASSERT(SEND_SIGNAL(look_bag, COMSIG_TRY_STORAGE_TAKE, big, run_loc_floor_bottom_left), "Could not take the scaled item out")
	shown = big.transform
	TEST_ASSERT_EQUAL(shown.a, 1, "Item kept its grid scale after removal")
	TEST_ASSERT_EQUAL(big.mouse_opacity, initial(big.mouse_opacity), "Item stayed unclickable after removal from the grid")
	TEST_ASSERT_EQUAL(big.appearance_flags, old_flags, "Item kept its grid appearance flags after removal")
	TEST_ASSERT(!LAZYACCESS(look_grid.grid_highlights, big), "Tile of a removed item was not deleted")

	// Po zamknięciu okna przez ostatniego oglądającego powiększenie znika (radial skrzynki bierze wygląd przedmiotu ze schowka)
	var/mob/living/carbon/human/viewer = allocate(/mob/living/carbon/human)
	TEST_ASSERT(SEND_SIGNAL(look_bag, COMSIG_TRY_STORAGE_INSERT, big, null, TRUE), "Normal item did not go back into the bag")
	look_grid.orient2hud()
	LAZYOR(look_grid.is_using, viewer)
	look_grid.hide_from(viewer)
	shown = big.transform
	TEST_ASSERT_EQUAL(shown.a, 1, "Item kept its grid scale after the storage was closed")
	TEST_ASSERT_EQUAL(big.appearance_flags, old_flags, "Item kept its grid appearance flags after the storage was closed")

	// Zmiana transform zrobiona przez sam przedmiot w schowku nie jest nadpisywana przy wyjęciu
	look_grid.orient2hud()
	var/matrix/own = matrix()
	own.Turn(45)
	big.transform = own
	TEST_ASSERT(SEND_SIGNAL(look_bag, COMSIG_TRY_STORAGE_TAKE, big, run_loc_floor_bottom_left), "Could not take the turned item out")
	shown = big.transform
	TEST_ASSERT(look_grid.same_matrix(shown, own), "Item's own transform was overwritten on removal")

	// Napełnianie typem nie wychodzi poza siatkę: 7x4 mieści 6 pudełek 2x2, choć wolnych kratek jest 28
	var/obj/item/storage/backpack/fill_bag = allocate(/obj/item/storage/backpack)
	SEND_SIGNAL(fill_bag, COMSIG_TRY_STORAGE_FILL_TYPE, /obj/item/storage/box, 20)
	TEST_ASSERT_EQUAL(length(fill_bag.contents), 6, "Fill type put more boxes into the bag than its grid holds")

	// Okno w kratkach 24 px: tło ma pole na każdą kratkę, klik w daleką kolumnę trafia w nią, a nie w kafel ekranu
	TEST_ASSERT(grid.grid_cell_size < world.icon_size, "Grid cells are not smaller than screen tiles")
	grid.orient2hud()
	TEST_ASSERT_EQUAL(length(grid.boxes.overlays) + 1, grid.grid_width * grid.grid_height, "Grid background should have a field for every cell")
	var/list/far = grid.params_to_cell(aquila_grid_cell_params(grid, grid.grid_width - 1, 0))
	TEST_ASSERT(far && far[1] == grid.grid_width - 1 && far[2] == 0, "Click in the last column landed in another cell")
	TEST_ASSERT_EQUAL(grid.grid_loc(0, 0), "[grid.screen_start_x]:[grid.screen_pixel_x],[grid.screen_start_y]:[grid.screen_pixel_y]", "Grid origin screen_loc")
	TEST_ASSERT_EQUAL(grid.grid_loc(grid.grid_cell_size * 4, 0), "[grid.screen_start_x + 3]:[grid.screen_pixel_x],[grid.screen_start_y]:[grid.screen_pixel_y]", "Four 24 px cells should span three screen tiles")

	// Szerokość siatki liczona w pikselach ekranu: przy mniejszych kratkach mieści się ich więcej
	TEST_ASSERT_EQUAL(grid.grid_max_width() * grid.grid_cell_size <= 384, TRUE, "Widest grid does not fit the screen space")
	TEST_ASSERT(grid.grid_max_width() > 12, "Max width still counts 32 px tiles instead of grid cells")

	// Nagłówek idzie w jednej linii: długa nazwa małego schowka mieści się bez zawijania
	var/obj/item/storage/toolbox/long_name = allocate(/obj/item/storage/toolbox)
	long_name.name = "zardzewiała niebieska skrzynka narzędziowa"
	var/datum/component/storage/concrete/grid/long_grid = long_name.GetComponent(/datum/component/storage/concrete/grid)
	long_grid.orient2hud()
	TEST_ASSERT(long_grid.grid_header.maptext_width >= 384, "Header of a small storage is as narrow as its grid and wraps long names")

	// Podgląd lądowania liczy się od nowa po każdym przerysowaniu siatki, nawet gdy przesunął się inny przedmiot
	var/revision = grid.grid_revision
	grid.orient2hud()
	TEST_ASSERT(grid.grid_revision > revision, "Grid revision did not change on redraw")

	// Tło łapie klik na całej powierzchni, także w szczelinach między polami
	TEST_ASSERT_EQUAL(grid.boxes.mouse_opacity, MOUSE_OPACITY_OPAQUE, "Grid background lets clicks through the gaps")

	// Kliknięcie poza siatką nie wskazuje kratki
	TEST_ASSERT(!grid.params_to_cell("screen-loc=[grid.screen_start_x + grid.grid_width]:20,[grid.screen_start_y]:20"), "Cell found to the right of the grid")
	var/list/cell = grid.params_to_cell("screen-loc=mapwindow.map:[grid.screen_start_x]:20,[grid.screen_start_y]:20")
	TEST_ASSERT(cell && cell[1] == 0 && cell[2] == grid.grid_height - 1, "Screen-loc with a map name was not parsed")

	// Małe schowki zachowują dawny limit sztuk mimo wolnych kratek
	var/obj/item/storage/toolbox/toolbox = allocate(/obj/item/storage/toolbox)
	var/datum/component/storage/concrete/grid/toolbox_grid = toolbox.GetComponent(/datum/component/storage/concrete/grid)
	TEST_ASSERT(toolbox_grid?.grid_keep_item_limit, "Toolbox has no limited grid storage")
	for(var/obj/item/already in toolbox)
		qdel(already)
	for(var/i in 1 to toolbox_grid.max_items)
		TEST_ASSERT(SEND_SIGNAL(toolbox, COMSIG_TRY_STORAGE_INSERT, make_item(WEIGHT_CLASS_TINY), null, TRUE), "Tiny item [i] did not fit into the toolbox")
	var/free_cells = 0
	for(var/occupied in toolbox_grid.settle_contents())
		if(!occupied)
			free_cells++
	TEST_ASSERT(free_cells > 0, "Toolbox grid filled up before its item limit")
	TEST_ASSERT_EQUAL(toolbox_grid.remaining_space_items(), 0, "Free cells counted past the toolbox item limit")
	TEST_ASSERT(!SEND_SIGNAL(toolbox, COMSIG_TRY_STORAGE_INSERT, make_item(WEIGHT_CLASS_TINY), null, TRUE), "Toolbox accepted more items than its old item limit")

/// AQUILA - zawartość startowa (PopulateContents) każdego schowka na siatce mieści się na siatce, jeśli mieściła się w starych limitach
/datum/unit_test/storage_grid_populate

/datum/unit_test/storage_grid_populate/Run()
	var/list/failures = list()
	var/checked = 0
	var/list/roots = list(/obj/item/storage/backpack, /obj/item/storage/toolbox, /obj/item/storage/firstaid, /obj/item/storage/briefcase, /obj/item/storage/box)
	for(var/root in roots)
		for(var/storage_type in typesof(root))
			// Losowe odczynniki tego pudełka wymagają przepisów rundy, których nie ma w teście (runtime z core, nie z siatki)
			if(ispath(storage_type, /obj/item/storage/box/alchemist_random_chems))
				continue
			var/obj/item/storage/container = new storage_type(run_loc_floor_bottom_left)
			var/datum/component/storage/concrete/grid/grid = container.GetComponent(/datum/component/storage/concrete/grid)
			if(grid?.grid_width)
				checked++
				grid.settle_contents()
				var/old_weight = 0
				var/old_items = 0
				var/too_big = FALSE
				var/list/unplaced = list()
				for(var/obj/item/stored in container)
					old_weight += stored.w_class
					old_items++
					if(stored.w_class > grid.max_w_class)
						too_big = TRUE
					if(!LAZYACCESS(grid.grid_positions, stored))
						unplaced += "[stored.type]"
				// Mieszczące się w starych limitach musi wejść zawsze. Ponad limity (zestawy w pudełkach) siatka rośnie,
				// więc przepełnienie jest dopuszczalne dopiero przy siatce w największym rozmiarze
				var/within_old_limits = !too_big && old_weight <= grid.grid_base_weight && old_items <= grid.grid_base_items
				var/grid_maxed = grid.grid_width >= grid.grid_max_width() && grid.grid_height >= grid.grid_max_grown_height()
				if(length(unplaced) && (within_old_limits || !grid_maxed))
					failures += "[storage_type] ([grid.grid_width]x[grid.grid_height]): nie mieści się [jointext(unplaced, ", ")]"
			for(var/atom/movable/thing in container)
				qdel(thing)
			qdel(container)
	TEST_ASSERT(checked, "No grid storage was checked")
	if(length(failures))
		return Fail("Zawartość startowa nie mieści się na siatce:\n[jointext(failures, "\n")]")

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


/// AQUILA - obrót E/Q dopisuje się do zapisanych keybindów raz: skrót odpięty potem przez gracza nie wraca
/datum/unit_test/storage_grid_keybind_migration

/datum/unit_test/storage_grid_keybind_migration/Run()
	var/list/bindings = list("E" = list("quick_equip"), "Q" = list("drop_item"))
	var/list/migrations = list()
	TEST_ASSERT(storage_grid_migrate_keybinds(bindings, migrations), "First migration did nothing")
	TEST_ASSERT("storage_grid_rotate_right" in bindings["E"], "Rotate right was not added to E")
	TEST_ASSERT("quick_equip" in bindings["E"], "Quick equip was removed from E")
	TEST_ASSERT("storage_grid_rotate_left" in bindings["Q"], "Rotate left was not added to Q")
	// Gracz odpina obrót z E: kolejne wczytanie nie dopisuje go z powrotem
	bindings["E"] = list("quick_equip")
	TEST_ASSERT(!storage_grid_migrate_keybinds(bindings, migrations), "Migration ran twice")
	TEST_ASSERT(!("storage_grid_rotate_right" in bindings["E"]), "Unbound rotate came back after the migration")
	// Obrót przypisany przez gracza gdzie indziej nie dostaje drugiego klawisza
	var/list/custom = list("R" = list("storage_grid_rotate_right"), "E" = list("quick_equip"))
	storage_grid_migrate_keybinds(custom, list())
	TEST_ASSERT(!("storage_grid_rotate_right" in custom["E"]), "Rotate got a second key although the player bound it")
	TEST_ASSERT("storage_grid_rotate_left" in custom["Q"], "Missing rotate left was not added to a free Q")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
