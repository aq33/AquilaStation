/*
 * AQUILA - Ekwipunek na siatce kratek (pomysł z Space Station 14, kod napisany od nowa)
 *
 * Plecaki, torby, skrzynki z narzędziami, apteczki, aktówki i pudełka trzymają przedmioty na siatce. Każdy przedmiot zajmuje prostokąt
 * zależny od w_class (GRID_SHAPE_*), można go przeciągnąć na inną kratkę i obrócić klawiszem E albo Q w trakcie przeciągania.
 * Wielkość siatki liczona jest z dawnej pojemności (max_combined_w_class), żeby zestawy startowe dalej się mieściły.
 *
 * Bezpieczeństwo: przedmiot włożony siłą (forceMove, new() w PopulateContents, włożenie z force) bez wolnego
 * miejsca nie znika, tylko ląduje w rzędzie „przepełnienia” nad siatką (czerwone podświetlenie), a do plecaka
 * nic więcej nie wejdzie, dopóki nie zrobi się miejsce. Pozostałe schowki (pasy, kabury, worki) zostają
 * na starym systemie wagi.
 */

/// Najszerszą siatkę ogranicza ekran: start w kolumnie 4 z widoku 17 kafli, obok jeszcze przycisk zamknięcia,
/// więc na siatkę zostaje 12 kafli po 32 px. Liczba kratek zależy od ich rozmiaru (grid_max_width())
#define GRID_STORAGE_MAX_PIXEL_WIDTH 384
/// Domyślna wysokość siatki
#define GRID_STORAGE_HEIGHT 4
/// Do tej wysokości siatka rośnie, gdy zawartość startowa się nie mieści (wyższa zasłaniałaby za dużo ekranu)
#define GRID_STORAGE_MAX_GROWN_HEIGHT 7
/// Kolory kafli według wielkości przedmiotu (mnożą szare kafle z aquila/icons/hud/storage_grid.dmi)
#define GRID_COLOR_TINY "#e8bf6a"
#define GRID_COLOR_SMALL "#86d9a1"
#define GRID_COLOR_NORMAL "#86b9ee"
#define GRID_COLOR_LARGE "#b39cf0"
#define GRID_COLOR_OVERFLOW "#ee7b7b"
/// Obrys podglądu lądowania, gdy przedmiot się mieści
#define GRID_COLOR_PREVIEW "#ffffff"
/// Bok kratki siatki w pikselach. Mniejszy niż kafel świata (32), żeby okno plecaka nie zasłaniało pół ekranu.
/// Kafle i tło w aquila/icons/hud/storage_grid.dmi są rysowane w tym rozmiarze
#define GRID_CELL_SIZE 24
/// Wysokość paska z nagłówkiem nad siatką
#define GRID_HEADER_HEIGHT 18

/datum/component/storage/concrete/grid
	/// Wymiary siatki w kratkach. 0 = siatka jeszcze nie ustawiona (setup_grid()), komponent działa wtedy po staremu
	var/grid_width = 0
	var/grid_height = 0
	/// Dawna pojemność w jednostkach w_class, z której policzono siatkę
	var/grid_base_weight = 0
	/// Dawny limit liczby przedmiotów
	var/grid_base_items = 0
	/// Czy zostaje dawny limit sztuk (małe schowki: skrzynki, apteczki, aktówki). Plecaki go nie mają, liczy się tylko miejsce
	var/grid_keep_item_limit = FALSE
	/// przedmiot -> list(kolumna, wiersz, obrócony). Kolumny i wiersze od 0, wiersz 0 to górny rząd
	var/list/grid_positions
	/// przedmiot -> /atom/movable/screen/storage_grid_item, podświetlenie kratek zajętych przez przedmiot
	var/list/grid_highlights
	/// list(kolumna, wiersz) wskazana kliknięciem w siatkę, używana przy najbliższym włożeniu
	var/list/pending_cell
	/// przedmiot -> list(transform, appearance_flags, ustawiony transform) sprzed powiększenia ikony na siatce.
	/// Przywracane przy wyjęciu i po zamknięciu okna przez ostatniego oglądającego, żeby powiększenie nie wyciekało
	/// do radiali i innych miejsc, które biorą wygląd przedmiotu ze schowka
	var/list/grid_saved_appearance
	/// Nagłówek nad siatką: nazwa schowka i zajęte kratki
	var/atom/movable/screen/storage_grid_header/grid_header
	/// przedmiot -> kąt (0/90/180/270) wybrany klawiszem E/Q w trakcie przeciągania, gdy obrócony kształt nie zmieścił się w miejscu.
	/// Obrót wchodzi przy upuszczeniu na siatce, a bez upuszczenia znika po puszczeniu przycisku myszy
	var/list/grid_pending_rotation
	/// Bok kratki w pikselach ekranu
	var/grid_cell_size = GRID_CELL_SIZE
	/// Wymiary siatki, dla których zbudowano nakładki tła (boxes)
	var/grid_background_key
	/// Rośnie przy każdym przerysowaniu siatki (każda zmiana układu przechodzi przez orient2hud()), żeby podgląd lądowania
	/// u przeciągającego przeliczył się także po ruchu innego przedmiotu
	var/grid_revision = 0
	/// list(REF przedmiotu, miejsce, world.time, kratka) z ostatniego can_be_inserted(), żeby handle_item_insertion()
	/// w tym samym ticku nie szukał miejsca drugi raz
	var/list/grid_fit_cache

/datum/component/storage/concrete/grid/Destroy()
	. = ..()
	QDEL_LIST_ASSOC_VAL(grid_highlights)
	QDEL_NULL(grid_header)
	restore_all_appearances()
	grid_positions = null
	grid_pending_rotation = null
	grid_fit_cache = null
	pending_cell = null

/// Ustawia siatkę na podstawie dawnej pojemności. Woła ją przedmiot po pełnej inicjalizacji (gdy podtypy ustawiły już max_combined_w_class)
/datum/component/storage/concrete/grid/proc/setup_grid()
	grid_base_weight = max_combined_w_class
	grid_base_items = max_items
	// Normalny przedmiot (waga 3) zajmuje 4 kratki, więc siatka ma o 1/3 więcej kratek niż dawna waga
	var/cells = max(CEILING(grid_base_weight * 4 / 3, 1), 1)
	grid_height = GRID_STORAGE_HEIGHT
	grid_width = CEILING(cells / grid_height, 1)
	var/max_width = grid_max_width()
	if(grid_width > max_width)
		grid_width = max_width
		grid_height = CEILING(cells / grid_width, 1)
	// Limit wagi przestaje obowiązywać, miejsce sprawdza siatka. Limit sztuk zostaje tylko w małych schowkach:
	// w plecakach przedmioty z przepełnienia też są w contents, więc nie mogą blokować wkładania na wolną kratkę
	if(!grid_keep_item_limit)
		max_items = INFINITY
	max_combined_w_class = INFINITY
	fit_initial_contents()
	refresh_mob_views()

/// Zawartość startowa ponad dawne limity (zestawy w pudełkach, np. kameleon, kostiumy, części) dostaje większą siatkę
/// zamiast lądować w przepełnieniu: najpierw szerzej do grid_max_width(), potem wyżej do GRID_STORAGE_MAX_GROWN_HEIGHT
/datum/component/storage/concrete/grid/proc/fit_initial_contents()
	var/atom/real_location = real_location()
	if(!length(real_location.contents))
		return
	while(TRUE)
		grid_positions = null
		settle_contents()
		var/unplaced = 0
		for(var/obj/item/I in real_location)
			if(!LAZYACCESS(grid_positions, I))
				unplaced++
		if(!unplaced)
			return
		if(grid_width < grid_max_width())
			grid_width++
		else if(grid_height < GRID_STORAGE_MAX_GROWN_HEIGHT)
			grid_height++
		else
			return

/// Najwięcej kratek w poziomie, ile mieści się na ekranie przy obecnym rozmiarze kratki
/datum/component/storage/concrete/grid/proc/grid_max_width()
	return max(1, round(GRID_STORAGE_MAX_PIXEL_WIDTH / grid_cell_size))

/// Najwyższa siatka, do jakiej rośnie zawartość startowa
/datum/component/storage/concrete/grid/proc/grid_max_grown_height()
	return GRID_STORAGE_MAX_GROWN_HEIGHT

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

/// Kąt ikony przedmiotu na siatce. Pozycja to list(kolumna, wiersz, obrócony[, kąt]); bez kąta (automatyczne ułożenie) obrócony znaczy 90°
/datum/component/storage/concrete/grid/proc/grid_angle(list/pos)
	if(length(pos) >= 4)
		return pos[4]
	return (pos && pos[3]) ? 90 : 0

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

/// Pierwsze wolne miejsce od lewego górnego rogu. Obrót dopiero wtedy, gdy bez obrotu przedmiot nie mieści się nigdzie
/datum/component/storage/concrete/grid/proc/find_first_spot(obj/item/I, list/occupancy)
	var/list/shape = grid_shape(I)
	var/list/rotations = shape[1] == shape[2] ? list(FALSE) : list(FALSE, TRUE)
	for(var/rotated in rotations)
		var/width = rotated ? shape[2] : shape[1]
		var/height = rotated ? shape[1] : shape[2]
		for(var/row in 0 to grid_height - 1)
			for(var/column in 0 to grid_width - 1)
				if(cells_free(occupancy, column, row, width, height))
					return list(column, row, rotated)
	return null

/// Liczba wolnych kratek (dla COMSIG_TRY_STORAGE_FILL_TYPE, które bez tego czytałoby nieskończony max_items)
/datum/component/storage/concrete/grid/remaining_space_items()
	if(!grid_width)
		return ..()
	. = 0
	for(var/cell in settle_contents())
		if(!cell)
			.++
	if(grid_keep_item_limit)
		var/atom/real_location = real_location()
		. = max(0, min(., max_items - length(real_location.contents)))

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
/datum/component/storage/concrete/grid/proc/find_spot_for(obj/item/I, list/cell, list/occupancy)
	if(!occupancy)
		occupancy = build_occupancy()
	. = null
	if(cell)
		. = find_spot_at(I, occupancy, cell, list(FALSE, TRUE))
	if(!.)
		. = find_first_spot(I, occupancy)

/// Porządkuje pozycje: usuwa przedmioty, których już nie ma, zdejmuje te, które zaczęły na coś zachodzić
/// (zmiana w_class w środku), i rozmieszcza przedmioty włożone bez pozycji. Co się nie zmieści, zostaje w przepełnieniu.
/// Zwraca mapę zajętości po uporządkowaniu, żeby wołający nie budował jej drugi raz
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
	return occupancy

/// screen_loc dla punktu odsuniętego o px, py pikseli od lewego dolnego rogu siatki. Kratki są mniejsze niż kafel ekranu,
/// więc pozycje liczymy w pikselach i rozkładamy na kafel i przesunięcie
/datum/component/storage/concrete/grid/proc/grid_loc(px, py)
	var/tile = world.icon_size
	var/total_x = (screen_start_x - 1) * tile + screen_pixel_x + px
	var/total_y = (screen_start_y - 1) * tile + screen_pixel_y + py
	var/tile_x = FLOOR(total_x / tile, 1)
	var/tile_y = FLOOR(total_y / tile, 1)
	return "[tile_x + 1]:[total_x - tile_x * tile],[tile_y + 1]:[total_y - tile_y * tile]"

/// Skala ikony przedmiotu na siatce: zawsze 1. Kratka ma 24 px, więc dopasowanie ikony 32 px do kratek dawało skalę
/// 0,75 albo 1,5, a przy ułamkowej skali piksele rozmywają się albo wychodzą nierówne. Ikona 32 px jest wyśrodkowana
/// na swoim kształcie: na dużych kształtach zostaje wolne miejsce, a na 1x1 i 1x2 szerszy sprite lekko wystaje poza kratkę
/datum/component/storage/concrete/grid/proc/grid_icon_scale(width, height)
	return 1

/// Piksel na ekranie (od lewego dolnego rogu siatki), w którym trzeba postawić ikonę 32 px, żeby jej środek
/// wypadł na środku prostokąta width x height kratek zaczynającego się w (px, py)
/datum/component/storage/concrete/grid/proc/grid_icon_loc(px, py, width, height)
	return grid_loc(px + width * grid_cell_size / 2 - world.icon_size / 2, py + height * grid_cell_size / 2 - world.icon_size / 2)

/// Tło siatki: jeden obiekt boxes z kratką w rogu i nakładkami pozostałych kratek. Klik w puste pole trafia w boxes
/datum/component/storage/concrete/grid/proc/update_background()
	boxes.screen_loc = grid_loc(0, 0)
	var/key = "[grid_width]x[grid_height]"
	if(grid_background_key == key)
		return
	grid_background_key = key
	boxes.icon = 'aquila/icons/hud/storage_grid.dmi'
	boxes.icon_state = "cell"
	// Pole ma przezroczysty margines i zaokrąglone rogi: bez tego klik w szczelinę między polami szedłby na świat pod HUD-em
	boxes.mouse_opacity = MOUSE_OPACITY_OPAQUE
	var/list/cells = list()
	for(var/y in 0 to grid_height - 1)
		for(var/x in 0 to grid_width - 1)
			if(!x && !y)
				continue
			var/mutable_appearance/cell = mutable_appearance('aquila/icons/hud/storage_grid.dmi', "cell")
			cell.pixel_x = x * grid_cell_size
			cell.pixel_y = y * grid_cell_size
			cells += cell
	boxes.overlays = cells

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
	var/column = FLOOR(offset_x / grid_cell_size, 1)
	var/screen_row = FLOOR(offset_y / grid_cell_size, 1)
	if(column >= grid_width || screen_row >= grid_height)
		return null
	return list(column, grid_height - 1 - screen_row)

/// Gdzie wyląduje przeciągany przedmiot, jeśli upuścić go nad kratką z params: list(kolumna, wiersz, obrócony, kąt, mieści się)
/// albo null poza siatką. Tego samego używają upuszczenie (move_item) i podgląd w trakcie przeciągania, więc podgląd nie kłamie
/datum/component/storage/concrete/grid/proc/drag_landing(obj/item/I, params)
	if(!grid_width || I.loc != real_location())
		return null
	var/list/cell = params_to_cell(params)
	if(!cell)
		return null
	var/list/pos = LAZYACCESS(grid_positions, I)
	var/pending = LAZYACCESS(grid_pending_rotation, I)
	var/list/rotations
	if(isnull(pending))
		if(pos)
			// Nad swoim miejscem bez obrotu: zostaje, gdzie był
			var/list/shape = grid_shape(I, pos[3])
			if(cell[1] >= pos[1] && cell[1] < pos[1] + shape[1] && cell[2] >= pos[2] && cell[2] < pos[2] + shape[2])
				return list(pos[1], pos[2], pos[3], grid_angle(pos), TRUE)
		rotations = list(pos ? pos[3] : FALSE, pos ? !pos[3] : TRUE)
	else
		rotations = list(pending % 180 != 0)
	var/list/spot = find_spot_at(I, build_occupancy(I), cell, rotations)
	// Kąt ikony: wybrany klawiszem, dotychczasowy, jeśli kształt się nie zmienił, albo domyślny dla nowego ułożenia
	var/angle
	if(!isnull(pending))
		angle = pending
	else if(spot)
		angle = (pos && spot[3] == pos[3]) ? grid_angle(pos) : (spot[3] ? 90 : 0)
	else
		angle = pos ? grid_angle(pos) : 0
	if(spot)
		return list(spot[1], spot[2], spot[3], angle, TRUE)
	// Nie mieści się: kształt zaczepiony lewym górnym rogiem w kratce pod kursorem, dociśnięty do krawędzi siatki
	var/rotated = rotations[1]
	var/list/shape = grid_shape(I, rotated)
	var/column = max(0, min(cell[1], grid_width - shape[1]))
	var/row = max(0, min(cell[2], grid_height - shape[2]))
	return list(column, row, rotated, angle, FALSE)

/// Przesuwa przedmiot, który już jest w środku, na kratkę spod kursora. Obrót wybrany w trakcie przeciągania (E/Q) wchodzi tutaj
/datum/component/storage/concrete/grid/proc/move_item(obj/item/I, mob/user, params)
	if(!grid_width || I.loc != real_location())
		return FALSE
	settle_contents()
	var/list/landing = drag_landing(I, params)
	if(!landing)
		return FALSE
	LAZYREMOVE(grid_pending_rotation, I)
	if(!landing[5])
		var/atom/host = parent
		host.balloon_alert(user, "nie mieści się tutaj")
		refresh_mob_views()
		return TRUE
	LAZYSET(grid_positions, I, landing.Copy(1, 5))
	refresh_mob_views()
	return TRUE

/// Odświeża podgląd lądowania przeciąganego przedmiotu u jednego klienta: obrys kształtu (biały, czerwony bez miejsca)
/// i półprzezroczysta ikona w ułożeniu, w jakim przedmiot wyląduje. Poza siatką podgląd znika
/datum/component/storage/concrete/grid/proc/update_drag_preview(client/viewer, obj/item/I, params)
	var/atom/movable/screen/storage_grid_preview/preview = viewer.storage_grid_preview
	// MouseDrag przychodzi przy każdym pikselu ruchu: liczymy lądowanie od nowa tylko po zmianie kratki, obrotu albo pozycji
	var/list/cell = params_to_cell(params)
	var/list/pos = LAZYACCESS(grid_positions, I)
	var/input_key = cell ? "[cell[1]],[cell[2]]|[LAZYACCESS(grid_pending_rotation, I)]|[pos ? jointext(pos, ",") : ""]|[grid_revision]" : null
	if(preview && preview.input_key == input_key && input_key)
		return
	var/list/landing = cell ? drag_landing(I, params) : null
	if(!landing)
		if(preview)
			preview.input_key = null
			viewer.screen -= preview
		return
	if(!preview)
		preview = new
		viewer.storage_grid_preview = preview
	preview.input_key = input_key
	apply_drag_preview(preview, I, landing)
	viewer.screen |= preview

/// Buduje wygląd podglądu dla miejsca lądowania z drag_landing(). Przebudowuje nakładki tylko po zmianie miejsca, obrotu albo przedmiotu
/datum/component/storage/concrete/grid/proc/apply_drag_preview(atom/movable/screen/storage_grid_preview/preview, obj/item/I, list/landing)
	var/list/shape = grid_shape(I, landing[3])
	var/width = shape[1]
	var/height = shape[2]
	var/size = grid_cell_size
	var/base_x = landing[1] * size
	var/base_y = (grid_height - landing[2] - height) * size
	preview.screen_loc = grid_loc(base_x, base_y)
	var/key = "[REF(I)]-[width]x[height]-[landing[4]]-[landing[5]]"
	if(preview.preview_key == key)
		return
	preview.preview_key = key
	var/list/layers = shape_tiles(width, height, landing[5] ? GRID_COLOR_PREVIEW : GRID_COLOR_OVERFLOW, 170)
	var/mutable_appearance/ghost = new(I)
	var/list/saved = LAZYACCESS(grid_saved_appearance, I)
	var/matrix/look = matrix(saved ? saved[1] : I.transform)
	var/scale = grid_icon_scale(width, height)
	if(scale != 1)
		look.Scale(scale)
	if(landing[4])
		look.Turn(landing[4])
	ghost.transform = look
	if(scale >= 1)
		ghost.appearance_flags |= PIXEL_SCALE
	ghost.alpha = 150
	ghost.maptext = null
	ghost.plane = FLOAT_PLANE
	ghost.layer = FLOAT_LAYER
	ghost.pixel_x = width * size / 2 - world.icon_size / 2
	ghost.pixel_y = height * size / 2 - world.icon_size / 2
	layers += ghost
	preview.overlays = layers

/// Obraca o 90° (E w prawo, Q w lewo) tylko podgląd przeciąganego przedmiotu. Przedmiot w schowku zostaje, jak leżał,
/// a wybrany obrót wchodzi dopiero przy upuszczeniu na siatce (move_item()). Bez upuszczenia przepada (clear_pending_rotation())
/datum/component/storage/concrete/grid/proc/rotate_item(obj/item/I, mob/user, clockwise = TRUE)
	if(!grid_width || I.loc != real_location())
		return FALSE
	settle_contents()
	var/list/pos = LAZYACCESS(grid_positions, I)
	var/current = LAZYACCESS(grid_pending_rotation, I)
	if(isnull(current))
		current = grid_angle(pos)
	var/angle = (current + (clockwise ? 90 : 270)) % 360
	// Powrót do ułożenia, w jakim przedmiot leży: podgląd zachowuje się jak bez obrotu
	if(pos && angle == grid_angle(pos))
		LAZYREMOVE(grid_pending_rotation, I)
	else
		LAZYSET(grid_pending_rotation, I, angle)
	return TRUE

/// Koniec przeciągania bez upuszczenia na siatce: wybrany obrót przepada
/datum/component/storage/concrete/grid/proc/clear_pending_rotation(obj/item/I)
	LAZYREMOVE(grid_pending_rotation, I)

/datum/component/storage/concrete/grid/proc/forget_item(atom/movable/thing)
	LAZYREMOVE(grid_positions, thing)
	LAZYREMOVE(grid_pending_rotation, thing)
	restore_appearance(thing)
	var/atom/movable/screen/storage_grid_item/highlight = LAZYACCESS(grid_highlights, thing)
	if(!highlight)
		return
	for(var/mob/M as anything in can_see_contents())
		M.client.screen -= highlight
	LAZYREMOVE(grid_highlights, thing)
	qdel(highlight)

/// Kolor kafla: według wielkości, czerwony w przepełnieniu
/datum/component/storage/concrete/grid/proc/grid_color(obj/item/I, overflow)
	if(overflow)
		return GRID_COLOR_OVERFLOW
	switch(I.w_class)
		if(WEIGHT_CLASS_TINY)
			return GRID_COLOR_TINY
		if(WEIGHT_CLASS_SMALL)
			return GRID_COLOR_SMALL
		if(WEIGHT_CLASS_NORMAL)
			return GRID_COLOR_NORMAL
	return GRID_COLOR_LARGE

/// Nakładki kafli kształtu width x height: każda kratka z ramką tylko na zewnętrznych bokach (maska sąsiadów N=1, S=2, E=4, W=8,
/// dy rośnie w górę ekranu). color i alpha ustawiają się na każdej nakładce, gdy są podane
/datum/component/storage/concrete/grid/proc/shape_tiles(width, height, color, alpha)
	. = list()
	for(var/dy in 0 to height - 1)
		for(var/dx in 0 to width - 1)
			var/mask = (dy < height - 1 ? 1 : 0) | (dy > 0 ? 2 : 0) | (dx < width - 1 ? 4 : 0) | (dx > 0 ? 8 : 0)
			var/mutable_appearance/tile = mutable_appearance('aquila/icons/hud/storage_grid.dmi', "tile-[mask]")
			if(color)
				tile.color = color
			if(alpha)
				tile.alpha = alpha
			tile.pixel_x = dx * grid_cell_size
			tile.pixel_y = dy * grid_cell_size
			. += tile

/// Kafel przedmiotu: jeden obiekt ekranu w lewym dolnym rogu kształtu
/datum/component/storage/concrete/grid/proc/update_highlight(obj/item/I, px, py, width, height, overflow)
	var/atom/movable/screen/storage_grid_item/highlight = LAZYACCESS(grid_highlights, I)
	if(!highlight)
		highlight = new(null, src, I)
		LAZYSET(grid_highlights, I, highlight)
	highlight.name = I.name
	highlight.color = grid_color(I, overflow)
	highlight.screen_loc = grid_loc(px, py)
	var/shape_key = "[width]x[height]"
	if(highlight.shape_key == shape_key)
		return
	highlight.shape_key = shape_key
	highlight.overlays = shape_tiles(width, height)

/// Skaluje ikonę przedmiotu do kratek (grid_icon_scale()) i obraca ją o kąt z siatki
/datum/component/storage/concrete/grid/proc/apply_appearance(obj/item/I, scale, angle = 0)
	var/list/saved = LAZYACCESS(grid_saved_appearance, I)
	if(!saved)
		saved = list(I.transform, I.appearance_flags, null)
		LAZYSET(grid_saved_appearance, I, saved)
	else if(!same_matrix(I.transform, saved[3]))
		// Przedmiot sam zmienił sobie transform od naszego ustawienia: jego wersja staje się nową bazą
		saved[1] = I.transform
	var/matrix/display = matrix(saved[1])
	if(scale != 1)
		display.Scale(scale)
	if(angle)
		display.Turn(angle)
	I.transform = display
	// Powiększenie bez wygładzania (ostre piksele), zmniejszenie z wygładzaniem, żeby nie gubić cienkich linii sprite'a
	I.appearance_flags = scale >= 1 ? (saved[2] | PIXEL_SCALE) : (saved[2] & ~PIXEL_SCALE)
	saved[3] = display

/datum/component/storage/concrete/grid/proc/restore_appearance(atom/movable/thing)
	var/list/saved = LAZYACCESS(grid_saved_appearance, thing)
	if(!saved)
		return
	// Transform cofamy tylko wtedy, gdy wciąż jest nasz; zmianę zrobioną przez sam przedmiot zostawiamy
	if(same_matrix(thing.transform, saved[3]))
		thing.transform = saved[1]
	thing.appearance_flags = saved[2]
	LAZYREMOVE(grid_saved_appearance, thing)

/datum/component/storage/concrete/grid/proc/restore_all_appearances()
	for(var/atom/movable/thing as anything in grid_saved_appearance?.Copy())
		restore_appearance(thing)

/datum/component/storage/concrete/grid/proc/same_matrix(matrix/first, matrix/second)
	if(!first || !second)
		return FALSE
	return first.a == second.a && first.b == second.b && first.c == second.c && first.d == second.d && first.e == second.e && first.f == second.f

/// Nagłówek nad siatką: nazwa schowka, zajęte kratki i liczba przedmiotów, które się nie mieszczą
/datum/component/storage/concrete/grid/proc/update_header(overflow_count)
	if(!grid_header)
		grid_header = new(null, src)
	var/used = 0
	for(var/obj/item/I as anything in grid_positions)
		var/list/shape = grid_shape(I)
		used += shape[1] * shape[2]
	var/total = grid_width * grid_height
	var/atom/host = parent
	var/text = "<b>[capitalize(host.name)]</b> <font color='[used >= total ? GRID_COLOR_OVERFLOW : "#c8d0d8"]'>[used]/[total]</font>"
	if(grid_keep_item_limit)
		var/atom/real_location = real_location()
		var/count = length(real_location.contents)
		text += " <font color='[count >= max_items ? GRID_COLOR_OVERFLOW : "#c8d0d8"]'>· [count]/[max_items] szt.</font>"
	if(overflow_count)
		text += " <font color='[GRID_COLOR_OVERFLOW]'>· nie mieści się: [overflow_count]</font>"
	grid_header.maptext = MAPTEXT(text)
	// Tekst idzie w jednej linii (pasek ma GRID_HEADER_HEIGHT), więc szerokość nie zależy od siatki: małe schowki z długą
	// nazwą (np. „zardzewiała niebieska skrzynka narzędziowa”) inaczej zawijały tekst i liczniki znikały pod paskiem
	grid_header.maptext_width = max(grid_width * grid_cell_size, GRID_STORAGE_MAX_PIXEL_WIDTH)
	grid_header.screen_loc = grid_loc(0, grid_height * grid_cell_size)

/datum/component/storage/concrete/grid/orient2hud()
	if(!grid_width)
		return ..()
	settle_contents()
	grid_revision++
	var/size = grid_cell_size
	update_background()
	var/atom/real_location = real_location()
	var/overflow_index = 0
	for(var/obj/O in real_location)
		if(QDELETED(O))
			continue
		O.mouse_opacity = MOUSE_OPACITY_OPAQUE
		// Stos pokazuje liczbę sztuk także w plecaku (aquila/code/game/objects/items/stacks/stack_amount.dm)
		if(istype(O, /obj/item/stack))
			var/obj/item/stack/stack = O
			stack.update_amount_maptext()
		else
			O.maptext = ""
		O.layer = ABOVE_HUD_LAYER
		O.plane = ABOVE_HUD_PLANE
		var/list/pos = isitem(O) ? LAZYACCESS(grid_positions, O) : null
		var/width = 1
		var/height = 1
		// Lewy dolny róg zajmowanego prostokąta w pikselach od lewego dolnego rogu siatki
		var/px
		var/py
		if(pos)
			var/list/shape = grid_shape(O, pos[3])
			width = shape[1]
			height = shape[2]
			px = pos[1] * size
			py = (grid_height - pos[2] - height) * size
		else
			// Przepełnienie: rzędy nad nagłówkiem
			px = (overflow_index % grid_width) * size
			py = grid_height * size + GRID_HEADER_HEIGHT + round(overflow_index / grid_width) * size
			overflow_index++
		// Ikona na środku zajmowanego prostokąta
		O.screen_loc = grid_icon_loc(px, py, width, height)
		if(isitem(O))
			// Mysz łapie kafel przedmiotu (storage_grid_item, dokładnie jego kratki), nie sama ikona: ikona 32 px wystaje
			// poza kratki 24 px i przejmowałaby kliknięcia sąsiednich kratek. Wyjęcie przywraca mouse_opacity (_removal_reset)
			O.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
			// Obrót wybrany w trakcie przeciągania widać tylko na podglądzie, przedmiot leży po staremu do upuszczenia
			apply_appearance(O, grid_icon_scale(width, height), grid_angle(pos))
			update_highlight(O, px, py, width, height, !pos)
	update_header(overflow_index)
	// Przepełniony schowek albo limit sztuk: wolne kratki na czerwono (kafle przedmiotów leżą nad tłem i zostają w swoich kolorach)
	boxes.color = (overflow_index || (grid_keep_item_limit && length(real_location.contents) >= max_items)) ? GRID_COLOR_OVERFLOW : null
	closer.screen_loc = grid_loc(grid_width * size, 0)

/datum/component/storage/concrete/grid/show_to(mob/M)
	. = ..()
	if(!. || !grid_width)
		return
	for(var/thing in grid_highlights)
		M.client.screen |= grid_highlights[thing]
	if(grid_header)
		M.client.screen |= grid_header

/datum/component/storage/concrete/grid/hide_from(mob/M)
	. = ..()
	// Nikt już nie patrzy: przedmioty wracają do zwykłego wyglądu
	if(!length(can_see_contents()))
		restore_all_appearances()
	if(!M.client)
		return
	for(var/thing in grid_highlights)
		M.client.screen -= grid_highlights[thing]
	if(grid_header)
		M.client.screen -= grid_header

/datum/component/storage/concrete/grid/_removal_reset(atom/movable/thing)
	. = ..()
	forget_item(thing)

/datum/component/storage/concrete/grid/can_be_inserted(obj/item/I, stop_messages = FALSE, mob/M)
	. = ..()
	if(!. || !grid_width)
		return
	var/list/spot = find_spot_for(I, pending_cell, settle_contents())
	if(!spot)
		grid_fit_cache = null
		if(!stop_messages)
			var/atom/host = parent
			host.balloon_alert(M, "brak miejsca")
		return FALSE
	grid_fit_cache = list(REF(I), spot, world.time, pending_cell ? jointext(pending_cell, ",") : null)

/datum/component/storage/concrete/grid/handle_item_insertion(obj/item/I, prevent_warning = FALSE, mob/M, datum/component/storage/remote)
	if(!grid_width || !istype(I))
		return ..()
	// Miejsce znalezione przed chwilą w can_be_inserted() dla tego przedmiotu i tej kratki jest aktualne: nic się nie zmieniło w tym ticku
	var/list/spot
	var/list/cached = grid_fit_cache
	grid_fit_cache = null
	if(cached && cached[1] == REF(I) && cached[3] == world.time && cached[4] == (pending_cell ? jointext(pending_cell, ",") : null) && !LAZYACCESS(grid_positions, I))
		var/list/cached_spot = cached[2]
		var/list/shape = grid_shape(I, cached_spot[3])
		if(cells_free(build_occupancy(), cached_spot[1], cached_spot[2], shape[1], shape[2]))
			spot = cached_spot
	if(!spot)
		spot = find_spot_for(I, pending_cell, settle_contents())
	pending_cell = null
	// Pozycję zapisujemy przed włożeniem, bo włożenie od razu odświeża ekran. Bez miejsca (włożenie siłą) przedmiot trafia do przepełnienia
	var/had_position = LAZYACCESS(grid_positions, I)
	if(spot && !had_position)
		LAZYSET(grid_positions, I, spot)
	. = ..()
	if(!. && !had_position && I.loc != real_location())
		LAZYREMOVE(grid_positions, I)
	// Bazowa wersja na koniec ustawia przedmiotowi MOUSE_OPACITY_OPAQUE już po przerysowaniu siatki (orient2hud()),
	// a ikona 32 px łapałaby wtedy kliknięcia sąsiednich kratek. Mysz łapie kafel przedmiotu, jak po każdym przerysowaniu
	if(. && grid_width && I.loc == real_location()) // bez siatki klasyczny widok nie przywraca przezroczystości
		I.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/datum/component/storage/concrete/grid/attackby(datum/source, obj/item/I, mob/M, params)
	// Kliknięcie w siatkę trzymanym przedmiotem przychodzi z /atom/movable/screen/storage bez źródła sygnału
	if(!source && grid_width)
		pending_cell = params_to_cell(params)
	. = ..()
	pending_cell = null

/// Napełnianie typem (COMSIG_TRY_STORAGE_FILL_TYPE): bazowa wersja tworzy tyle sztuk, ile zwróci remaining_space_items(),
/// a wolne kratki to nie liczba przedmiotów 2x2. Bez force kończymy, gdy kolejna sztuka nie dostanie miejsca na siatce
/datum/component/storage/concrete/grid/signal_fill_type(datum/source, type, amount = 20, force = FALSE)
	if(!grid_width || force)
		return ..()
	var/atom/real_location = real_location()
	for(var/i in 1 to amount)
		if(grid_keep_item_limit && length(real_location.contents) >= max_items)
			break
		var/obj/item/filler = new type(real_location)
		if(QDELETED(src))
			return TRUE
		if(!istype(filler))
			break
		handle_item_insertion(filler, TRUE)
		if(!LAZYACCESS(grid_positions, filler))
			qdel(filler)
			break
	return TRUE

/// Siatka z zachowanym dawnym limitem sztuk: skrzynki z narzędziami, apteczki, aktówki, pudełka
/datum/component/storage/concrete/grid/limited
	grid_keep_item_limit = TRUE

/// Podświetlenie kratek zajętych przez przedmiot. Kliknięcia i przeciąganie przekazuje do przedmiotu,
/// żeby dało się go chwycić za każdą zajmowaną kratkę, nie tylko za środek
/atom/movable/screen/storage_grid_item
	name = "przedmiot"
	icon = null
	layer = HUD_LAYER + 0.5
	plane = HUD_PLANE
	var/obj/item/item
	/// "szerokośćxwysokość" kształtu, dla którego zbudowano nakładki kafli
	var/shape_key

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

/// Podpowiedź i obrys przedmiotu po najechaniu, bo sama ikona przedmiotu na siatce nie łapie myszy
/atom/movable/screen/storage_grid_item/MouseEntered(location, control, params)
	. = ..()
	if(!QDELETED(item))
		item.MouseEntered(location, control, params)

/atom/movable/screen/storage_grid_item/MouseExited(location, control, params)
	. = ..()
	if(!QDELETED(item))
		item.MouseExited(location, control, params)

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

/// Podgląd lądowania przeciąganego przedmiotu. Należy do klienta, który przeciąga, i nie łapie myszy,
/// żeby upuszczenie trafiło w siatkę pod spodem
/atom/movable/screen/storage_grid_preview
	name = ""
	icon = null
	layer = ABOVE_HUD_LAYER + 1
	plane = ABOVE_HUD_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	/// Miejsce, obrót i przedmiot, dla których zbudowano nakładki
	var/preview_key
	/// Kratka pod kursorem, obrót i pozycja, dla których ostatnio liczono lądowanie
	var/input_key

/// Nagłówek siatki z nazwą schowka i liczbą zajętych kratek
/atom/movable/screen/storage_grid_header
	name = ""
	icon = null
	maptext_height = GRID_HEADER_HEIGHT
	maptext_y = 2
	layer = HUD_LAYER + 0.5
	plane = HUD_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/storage_grid_header/Initialize(mapload, datum/component/storage/new_master)
	. = ..()
	master = new_master

/// Schowek bez siatki (pasy, kieszenie, kabury): czy limit sztuk albo wagi jest wyczerpany
/datum/component/storage/proc/storage_hud_full()
	var/atom/real_location = real_location()
	if(length(real_location.contents) >= max_items)
		return TRUE
	var/total = 0
	for(var/obj/item/I in real_location)
		total += I.w_class
	return total >= max_combined_w_class

// Pełny schowek bez siatki: puste pola na czerwono, żeby było widać, że nic więcej nie wejdzie.
// Tylko gdy jakieś pole jest puste: schowek z kompletem sztuk (np. pas 7/7) nie ma czego oznaczać
/datum/component/storage/standard_orient_objs(rows, cols, list/obj/item/numerical_display_contents)
	. = ..()
	var/atom/real_location = real_location()
	var/shown = islist(numerical_display_contents) ? length(numerical_display_contents) : length(real_location.contents)
	boxes.color = (shown < rows * cols && storage_hud_full()) ? GRID_COLOR_OVERFLOW : null

#undef GRID_COLOR_TINY
#undef GRID_COLOR_SMALL
#undef GRID_COLOR_NORMAL
#undef GRID_COLOR_LARGE
#undef GRID_COLOR_OVERFLOW
#undef GRID_COLOR_PREVIEW
#undef GRID_CELL_SIZE
#undef GRID_HEADER_HEIGHT
#undef GRID_STORAGE_MAX_PIXEL_WIDTH
#undef GRID_STORAGE_HEIGHT
#undef GRID_STORAGE_MAX_GROWN_HEIGHT
