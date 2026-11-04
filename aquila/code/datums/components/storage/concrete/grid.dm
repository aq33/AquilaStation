/*
 * AQUILA - Ekwipunek na siatce kratek (pomysł z Space Station 14, kod napisany od nowa)
 *
 * Plecaki, torby na ramię i torby podróżne trzymają przedmioty na siatce. Każdy przedmiot zajmuje prostokąt
 * zależny od w_class (GRID_SHAPE_*), można go przeciągnąć na inną kratkę albo obrócić (upuszczając na nim samym).
 * Wielkość siatki liczona jest z dawnej pojemności (max_combined_w_class), żeby zestawy startowe dalej się mieściły.
 *
 * Bezpieczeństwo: przedmiot włożony siłą (forceMove, new() w PopulateContents, włożenie z force) bez wolnego
 * miejsca nie znika, tylko ląduje w rzędzie „przepełnienia” nad siatką (czerwone podświetlenie), a do plecaka
 * nic więcej nie wejdzie, dopóki nie zrobi się miejsce. Pozostałe schowki (pudełka, pasy, kabury, worki)
 * zostają na starym systemie wagi.
 */

/// Najszerszą siatkę ogranicza ekran: start w kolumnie 4, widok 17 kratek, obok jeszcze przycisk zamknięcia
#define GRID_STORAGE_MAX_WIDTH 12
/// Domyślna wysokość siatki
#define GRID_STORAGE_HEIGHT 4

/datum/component/storage/concrete/grid
	/// Wymiary siatki w kratkach. 0 = siatka jeszcze nie ustawiona (setup_grid()), komponent działa wtedy po staremu
	var/grid_width = 0
	var/grid_height = 0
	/// Dawna pojemność w jednostkach w_class, z której policzono siatkę
	var/grid_base_weight = 0
	/// Dawny limit liczby przedmiotów
	var/grid_base_items = 0
	/// przedmiot -> list(kolumna, wiersz, obrócony). Kolumny i wiersze od 0, wiersz 0 to górny rząd
	var/list/grid_positions
	/// przedmiot -> /atom/movable/screen/storage_grid_item, podświetlenie kratek zajętych przez przedmiot
	var/list/grid_highlights
	/// list(kolumna, wiersz) wskazana kliknięciem w siatkę, używana przy najbliższym włożeniu
	var/list/pending_cell

/datum/component/storage/concrete/grid/Destroy()
	. = ..()
	QDEL_LIST_ASSOC_VAL(grid_highlights)
	grid_positions = null
	pending_cell = null

/// Ustawia siatkę na podstawie dawnej pojemności. Woła ją przedmiot po pełnej inicjalizacji (gdy podtypy ustawiły już max_combined_w_class)
/datum/component/storage/concrete/grid/proc/setup_grid()
	grid_base_weight = max_combined_w_class
	grid_base_items = max_items
	// Normalny przedmiot (waga 3) zajmuje 4 kratki, więc siatka ma o 1/3 więcej kratek niż dawna waga
	var/cells = max(CEILING(grid_base_weight * 4 / 3, 1), 1)
	grid_height = GRID_STORAGE_HEIGHT
	grid_width = CEILING(cells / grid_height, 1)
	if(grid_width > GRID_STORAGE_MAX_WIDTH)
		grid_width = GRID_STORAGE_MAX_WIDTH
		grid_height = CEILING(cells / grid_width, 1)
	// Stare limity przestają obowiązywać, miejsce sprawdza siatka. max_items zostaje równe liczbie kratek, bo czyta go kilka miejsc w storage.dm
	max_items = grid_width * grid_height
	max_combined_w_class = INFINITY
	refresh_mob_views()

/// Kształt przedmiotu na siatce: list(szerokość, wysokość)
/datum/component/storage/concrete/grid/proc/grid_shape(obj/item/I, rotated = FALSE)
	var/width = 1
	var/height = 1
	switch(I.w_class)
		if(WEIGHT_CLASS_TINY)
			width = 1
			height = 1
		if(WEIGHT_CLASS_SMALL)
			width = 1
			height = 2
		if(WEIGHT_CLASS_NORMAL)
			width = 2
			height = 2
		if(WEIGHT_CLASS_BULKY)
			width = 2
			height = 4
		if(WEIGHT_CLASS_HUGE)
			width = 4
			height = 4
		else
			if(I.w_class > WEIGHT_CLASS_HUGE)
				width = 5
				height = 5
	return rotated ? list(height, width) : list(width, height)

/// Czy prostokąt mieści się w siatce i nie zachodzi na zajęte kratki
/datum/component/storage/concrete/grid/proc/cells_free(list/occupancy, column, row, width, height)
	if(column < 0 || row < 0 || column + width > grid_width || row + height > grid_height)
		return FALSE
	for(var/y in row to row + height - 1)
		for(var/x in column to column + width - 1)
			if(occupancy[x + y * grid_width + 1])
				return FALSE
	return TRUE

/datum/component/storage/concrete/grid/proc/mark_cells(list/occupancy, obj/item/I, column, row, width, height)
	for(var/y in row to row + height - 1)
		for(var/x in column to column + width - 1)
			occupancy[x + y * grid_width + 1] = I

/// Mapa zajętości kratek (indeks: kolumna + wiersz * szerokość + 1). ignore pomija jeden przedmiot (przy przesuwaniu)
/datum/component/storage/concrete/grid/proc/build_occupancy(obj/item/ignore)
	var/list/occupancy = new /list(grid_width * grid_height)
	for(var/obj/item/I as anything in grid_positions)
		if(I == ignore)
			continue
		var/list/pos = grid_positions[I]
		var/list/shape = grid_shape(I, pos[3])
		mark_cells(occupancy, I, pos[1], pos[2], shape[1], shape[2])
	return occupancy

/// Pierwsze wolne miejsce od lewego górnego rogu, najpierw bez obrotu
/datum/component/storage/concrete/grid/proc/find_first_spot(obj/item/I, list/occupancy)
	var/list/shape = grid_shape(I)
	var/square = shape[1] == shape[2]
	for(var/row in 0 to grid_height - 1)
		for(var/column in 0 to grid_width - 1)
			if(cells_free(occupancy, column, row, shape[1], shape[2]))
				return list(column, row, FALSE)
			if(!square && cells_free(occupancy, column, row, shape[2], shape[1]))
				return list(column, row, TRUE)
	return null

/// Miejsce, w którym przedmiot zakrywa wskazaną kratkę. rotations to kolejność prób obrotu
/datum/component/storage/concrete/grid/proc/find_spot_at(obj/item/I, list/occupancy, list/cell, list/rotations)
	for(var/rotated in rotations)
		var/list/shape = grid_shape(I, rotated)
		for(var/dy in 0 to shape[2] - 1)
			for(var/dx in 0 to shape[1] - 1)
				if(cells_free(occupancy, cell[1] - dx, cell[2] - dy, shape[1], shape[2]))
					return list(cell[1] - dx, cell[2] - dy, rotated)
	return null

/// Miejsce dla nowego przedmiotu: przy wskazanej kratce, a jeśli tam się nie mieści, pierwsze wolne
/datum/component/storage/concrete/grid/proc/find_spot_for(obj/item/I, list/cell)
	var/list/occupancy = build_occupancy()
	. = null
	if(cell)
		. = find_spot_at(I, occupancy, cell, list(FALSE, TRUE))
	if(!.)
		. = find_first_spot(I, occupancy)

/// Porządkuje pozycje: usuwa przedmioty, których już nie ma, zdejmuje te, które zaczęły na coś zachodzić
/// (zmiana w_class w środku), i rozmieszcza przedmioty włożone bez pozycji. Co się nie zmieści, zostaje w przepełnieniu
/datum/component/storage/concrete/grid/proc/settle_contents()
	var/atom/real_location = real_location()
	var/list/occupancy = new /list(grid_width * grid_height)
	for(var/obj/item/I as anything in grid_positions?.Copy())
		if(QDELETED(I) || I.loc != real_location)
			forget_item(I)
			continue
		var/list/pos = grid_positions[I]
		var/list/shape = grid_shape(I, pos[3])
		if(!cells_free(occupancy, pos[1], pos[2], shape[1], shape[2]))
			grid_positions -= I
			continue
		mark_cells(occupancy, I, pos[1], pos[2], shape[1], shape[2])
	for(var/obj/item/I in real_location)
		if(QDELETED(I) || LAZYACCESS(grid_positions, I))
			continue
		var/list/spot = find_first_spot(I, occupancy)
		if(!spot)
			continue
		LAZYSET(grid_positions, I, spot)
		var/list/shape = grid_shape(I, spot[3])
		mark_cells(occupancy, I, spot[1], spot[2], shape[1], shape[2])

/// Zamienia parametry kliknięcia (screen-loc) na kratkę siatki: list(kolumna, wiersz) albo null poza siatką
/datum/component/storage/concrete/grid/proc/params_to_cell(params)
	if(!grid_width || !params)
		return null
	var/list/modifiers = params2list(params)
	var/screen_loc = LAZYACCESS(modifiers, "screen-loc")
	if(!screen_loc)
		return null
	var/list/axes = splittext(screen_loc, ",")
	if(length(axes) != 2)
		return null
	// Oś X może mieć przed sobą nazwę mapy („mapwindow.map:5:12”), więc bierzemy dwa ostatnie pola
	var/list/x_parts = splittext(axes[1], ":")
	var/list/y_parts = splittext(axes[2], ":")
	if(length(x_parts) < 2 || length(y_parts) < 2)
		return null
	var/tile_x = text2num(x_parts[length(x_parts) - 1])
	var/pixel_x = text2num(x_parts[length(x_parts)])
	var/tile_y = text2num(y_parts[1])
	var/pixel_y = text2num(y_parts[2])
	if(!isnum(tile_x) || !isnum(pixel_x) || !isnum(tile_y) || !isnum(pixel_y))
		return null
	var/size = world.icon_size
	// Piksele w screen-loc liczone są od 1
	var/offset_x = (tile_x - 1) * size + pixel_x - 1 - ((screen_start_x - 1) * size + screen_pixel_x)
	var/offset_y = (tile_y - 1) * size + pixel_y - 1 - ((screen_start_y - 1) * size + screen_pixel_y)
	if(offset_x < 0 || offset_y < 0)
		return null
	var/column = FLOOR(offset_x / size, 1)
	var/screen_row = FLOOR(offset_y / size, 1)
	if(column >= grid_width || screen_row >= grid_height)
		return null
	return list(column, grid_height - 1 - screen_row)

/// Przesuwa przedmiot, który już jest w środku, na kratkę spod kursora. Upuszczenie na nim samym obraca go
/datum/component/storage/concrete/grid/proc/move_item(obj/item/I, mob/user, params)
	if(!grid_width || I.loc != real_location())
		return FALSE
	var/list/cell = params_to_cell(params)
	if(!cell)
		return FALSE
	settle_contents()
	var/atom/host = parent
	var/list/occupancy = build_occupancy(I)
	var/list/pos = LAZYACCESS(grid_positions, I)
	var/list/spot
	if(pos)
		var/list/shape = grid_shape(I, pos[3])
		if(cell[1] >= pos[1] && cell[1] < pos[1] + shape[1] && cell[2] >= pos[2] && cell[2] < pos[2] + shape[2])
			// Upuszczony na swoim miejscu: obrót wokół lewego górnego rogu, a jeśli tam brak miejsca, wokół kratki pod kursorem
			var/list/rotated_shape = grid_shape(I, !pos[3])
			if(rotated_shape[1] == shape[1])
				return TRUE
			if(cells_free(occupancy, pos[1], pos[2], rotated_shape[1], rotated_shape[2]))
				spot = list(pos[1], pos[2], !pos[3])
			else
				spot = find_spot_at(I, occupancy, cell, list(!pos[3]))
			if(!spot)
				host.balloon_alert(user, "nie da się obrócić")
				return TRUE
	if(!spot)
		spot = find_spot_at(I, occupancy, cell, list(pos ? pos[3] : FALSE, pos ? !pos[3] : TRUE))
	if(!spot)
		host.balloon_alert(user, "nie mieści się tutaj")
		return TRUE
	LAZYSET(grid_positions, I, spot)
	refresh_mob_views()
	return TRUE

/datum/component/storage/concrete/grid/proc/forget_item(atom/movable/thing)
	LAZYREMOVE(grid_positions, thing)
	var/atom/movable/screen/storage_grid_item/highlight = LAZYACCESS(grid_highlights, thing)
	if(!highlight)
		return
	for(var/mob/M as anything in can_see_contents())
		M.client.screen -= highlight
	LAZYREMOVE(grid_highlights, thing)
	qdel(highlight)

/datum/component/storage/concrete/grid/proc/update_highlight(obj/item/I, screen_x, screen_y, width, height, overflow)
	var/atom/movable/screen/storage_grid_item/highlight = LAZYACCESS(grid_highlights, I)
	if(!highlight)
		highlight = new(null, src, I)
		LAZYSET(grid_highlights, I, highlight)
	highlight.name = I.name
	highlight.color = overflow ? "#d07070" : "#8fb0d0"
	highlight.screen_loc = "[screen_x]:[screen_pixel_x],[screen_y]:[screen_pixel_y] to [screen_x + width - 1]:[screen_pixel_x],[screen_y + height - 1]:[screen_pixel_y]"

/datum/component/storage/concrete/grid/orient2hud()
	if(!grid_width)
		return ..()
	settle_contents()
	var/size = world.icon_size
	boxes.screen_loc = "[screen_start_x]:[screen_pixel_x],[screen_start_y]:[screen_pixel_y] to [screen_start_x + grid_width - 1]:[screen_pixel_x],[screen_start_y + grid_height - 1]:[screen_pixel_y]"
	var/atom/real_location = real_location()
	var/overflow_index = 0
	for(var/obj/O in real_location)
		if(QDELETED(O))
			continue
		O.mouse_opacity = MOUSE_OPACITY_OPAQUE
		O.maptext = ""
		O.layer = ABOVE_HUD_LAYER
		O.plane = ABOVE_HUD_PLANE
		var/list/pos = isitem(O) ? LAZYACCESS(grid_positions, O) : null
		var/width = 1
		var/height = 1
		var/screen_x
		var/screen_y
		if(pos)
			var/list/shape = grid_shape(O, pos[3])
			width = shape[1]
			height = shape[2]
			screen_x = screen_start_x + pos[1]
			screen_y = screen_start_y + grid_height - pos[2] - height
		else
			// Przepełnienie: rzędy nad siatką
			screen_x = screen_start_x + overflow_index % grid_width
			screen_y = screen_start_y + grid_height + round(overflow_index / grid_width)
			overflow_index++
		// Ikona na środku zajmowanego prostokąta
		O.screen_loc = "[screen_x]:[screen_pixel_x + (width - 1) * size / 2],[screen_y]:[screen_pixel_y + (height - 1) * size / 2]"
		if(isitem(O))
			update_highlight(O, screen_x, screen_y, width, height, !pos)
	closer.screen_loc = "[screen_start_x + grid_width]:[screen_pixel_x],[screen_start_y]:[screen_pixel_y]"

/datum/component/storage/concrete/grid/show_to(mob/M)
	. = ..()
	if(!. || !grid_width)
		return
	for(var/thing in grid_highlights)
		M.client.screen |= grid_highlights[thing]

/datum/component/storage/concrete/grid/hide_from(mob/M)
	. = ..()
	if(!M.client)
		return
	for(var/thing in grid_highlights)
		M.client.screen -= grid_highlights[thing]

/datum/component/storage/concrete/grid/_removal_reset(atom/movable/thing)
	. = ..()
	forget_item(thing)

/datum/component/storage/concrete/grid/can_be_inserted(obj/item/I, stop_messages = FALSE, mob/M)
	. = ..()
	if(!. || !grid_width)
		return
	settle_contents()
	if(!find_spot_for(I, pending_cell))
		if(!stop_messages)
			var/atom/host = parent
			host.balloon_alert(M, "brak miejsca")
		return FALSE

/datum/component/storage/concrete/grid/handle_item_insertion(obj/item/I, prevent_warning = FALSE, mob/M, datum/component/storage/remote)
	if(!grid_width || !istype(I))
		return ..()
	settle_contents()
	var/list/spot = find_spot_for(I, pending_cell)
	pending_cell = null
	// Pozycję zapisujemy przed włożeniem, bo włożenie od razu odświeża ekran. Bez miejsca (włożenie siłą) przedmiot trafia do przepełnienia
	var/had_position = LAZYACCESS(grid_positions, I)
	if(spot && !had_position)
		LAZYSET(grid_positions, I, spot)
	. = ..()
	if(!. && !had_position && I.loc != real_location())
		LAZYREMOVE(grid_positions, I)

/datum/component/storage/concrete/grid/attackby(datum/source, obj/item/I, mob/M, params)
	// Kliknięcie w siatkę trzymanym przedmiotem przychodzi z /atom/movable/screen/storage bez źródła sygnału
	if(!source && grid_width)
		pending_cell = params_to_cell(params)
	. = ..()
	pending_cell = null

/// Podświetlenie kratek zajętych przez przedmiot. Kliknięcia i przeciąganie przekazuje do przedmiotu,
/// żeby dało się go chwycić za każdą zajmowaną kratkę, nie tylko za środek
/atom/movable/screen/storage_grid_item
	name = "przedmiot"
	icon_state = "block"
	alpha = 150
	layer = HUD_LAYER + 0.5
	plane = HUD_PLANE
	var/obj/item/item

/atom/movable/screen/storage_grid_item/Initialize(mapload, datum/component/storage/new_master, obj/item/new_item)
	. = ..()
	master = new_master
	item = new_item

/atom/movable/screen/storage_grid_item/Destroy()
	item = null
	master = null
	return ..()

/atom/movable/screen/storage_grid_item/Click(location, control, params)
	if(QDELETED(item) || !usr?.client)
		return TRUE
	usr.client.Click(item, location, control, params)
	return TRUE

/atom/movable/screen/storage_grid_item/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	if(QDELETED(item))
		return
	return item.MouseDrop(over, src_location, over_location, src_control, over_control, params)

/// Przeciąganie przedmiotu po siatce plecaka, w którym leży
/obj/item/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	if((item_flags & IN_STORAGE) && over && usr && loc)
		var/datum/component/storage/concrete/grid/grid = loc.GetComponent(/datum/component/storage/concrete/grid)
		if(grid?.grid_width && usr.active_storage == grid && !usr.incapacitated())
			var/over_grid = (over == grid.boxes) || (over.loc == loc && isitem(over))
			if(!over_grid && istype(over, /atom/movable/screen/storage_grid_item))
				var/atom/movable/screen/storage_grid_item/highlight = over
				over_grid = highlight.master == grid
			if(over_grid && grid.move_item(src, usr, params))
				remove_outline()
				return
	return ..()

#undef GRID_STORAGE_MAX_WIDTH
#undef GRID_STORAGE_HEIGHT
