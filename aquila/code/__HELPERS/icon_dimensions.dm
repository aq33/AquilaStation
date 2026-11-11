// Wymiary ikon z pamięci podręcznej, z tgstation/tgstation#88266 (`get_icon_dimensions_pure`, bez metadanych rust-g).
// Wszystkie stany w jednym .dmi mają ten sam rozmiar, więc wystarczy klucz po pliku. HUD-y (zdrowie, ID, diagnostyka)
// liczyły wcześniej `icon(icon, icon_state, dir).Height()` przy każdej aktualizacji, czyli tworzyły nową ikonę.

GLOBAL_LIST_EMPTY(icon_dimensions)

/// Zwraca list("width" = szerokość, "height" = wysokość) ikony. Pliki są zapamiętywane, ikony tworzone w trakcie gry nie.
/// icon_state i dir są używane tylko dla ikon spoza pamięci, żeby nie kopiować wszystkich stanów dużej ikony.
/proc/get_icon_dimensions(icon_path, icon_state, dir)
	// Ikona utworzona w trakcie gry (dyn.rsc albo /icon) może istnieć na miliony sposobów, więc jej nie zapamiętujemy.
	if(!isfile(icon_path) || !length("[icon_path]"))
		var/icon/my_icon = icon(icon_path, icon_state, dir)
		return list("width" = my_icon.Width(), "height" = my_icon.Height())
	if(isnull(GLOB.icon_dimensions[icon_path]))
		var/icon/my_icon = icon(icon_path)
		GLOB.icon_dimensions[icon_path] = list("width" = my_icon.Width(), "height" = my_icon.Height())
	return GLOB.icon_dimensions[icon_path]

/// Szerokość ikony atomu w pikselach, z pamięci podręcznej.
/// U nas na razie bez wywołań poza testem; zostaje dla portów z tg, który używa jej obok get_cached_height().
/atom/proc/get_cached_width()
	if(isnull(icon))
		return 0
	var/list/dimensions = get_icon_dimensions(icon, icon_state, dir)
	return dimensions["width"]

/// Wysokość ikony atomu w pikselach, z pamięci podręcznej.
/atom/proc/get_cached_height()
	if(isnull(icon))
		return 0
	var/list/dimensions = get_icon_dimensions(icon, icon_state, dir)
	return dimensions["height"]
