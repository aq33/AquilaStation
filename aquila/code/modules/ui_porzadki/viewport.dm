// AQ - porządki w UI: widok gry dopasowuje się do okna.
// Skin (interface/skin.dmf, mainwindow on-size) woła .auto_fit_viewport przy każdej zmianie
// rozmiaru okna. Szersze okno daje więcej kafelków w poziomie (wysokość zostaje), a potem
// panel mapy dopasowuje się do proporcji widoku - bez czarnych pasów po bokach.

/// Przy przeciąganiu krawędzi okna on-size leci wiele razy - dopasowujemy dopiero po chwili spokoju
#define AUTO_FIT_VIEWPORT_DELAY (0.3 SECONDS)
/// Najszerszy widok w kafelkach przy bardzo szerokim oknie
#define MAX_DYNAMIC_VIEW_WIDTH 31

/client/verb/auto_fit_viewport()
	set name = ".auto_fit_viewport"
	set hidden = TRUE
	addtimer(CALLBACK(src, PROC_REF(fit_view_to_window)), AUTO_FIT_VIEWPORT_DELAY, TIMER_UNIQUE | TIMER_OVERRIDE)

/// Szerokość widoku z proporcji panelu mapy, potem dopasowanie panelu (gdy włączone w ustawieniach)
/client/proc/fit_view_to_window()
	if(!prefs)
		return
	if((prefs.toggles2 & PREFTOGGLE_2_WIDESCREEN) && !prefs.pixel_size && view_size && !view_size.isZooming() && !isnewplayer(mob))
		var/list/map_size = splittext(winget(src, "mapwindow.map", "size"), "x")
		if(length(map_size) == 2)
			var/map_width = text2num(map_size[1])
			var/map_height = text2num(map_size[2])
			if(map_width && map_height)
				var/list/default_size = getviewsize(view_size.default)
				var/tiles_high = default_size[2]
				// najbliższa nieparzysta szerokość, żeby postać stała na środku
				var/tiles_wide = round((tiles_high * map_width / map_height - 1) / 2) * 2 + 1
				tiles_wide = clamp(tiles_wide, tiles_high, MAX_DYNAMIC_VIEW_WIDTH)
				if(tiles_wide != default_size[1])
					view_size.setDefault("[tiles_wide]x[tiles_high]")
	if((prefs.toggles2 & PREFTOGGLE_2_AUTO_FIT_VIEWPORT) && chat_keeps_room_after_fit())
		fit_viewport()

/// Najwęższy panel czatu/statystyk (px), jaki może zostać po dopasowaniu mapy
#define MIN_INFO_PANEL_WIDTH 250

/// Czy po dopasowaniu panelu mapy do proporcji widoku czatowi zostanie dość miejsca
/// (w wąskim, wysokim oknie fit_viewport() zabrałby mu prawie całą szerokość)
/client/proc/chat_keeps_room_after_fit()
	var/list/sizes = params2list(winget(src, "mainwindow.split;mapwindow", "size"))
	var/list/map_size = splittext(sizes["mapwindow.size"], "x")
	var/list/split_size = splittext(sizes["mainwindow.split.size"], "x")
	if(length(map_size) != 2 || length(split_size) != 2)
		return FALSE
	var/list/view_tiles = getviewsize(view)
	var/desired_width = text2num(map_size[2]) * view_tiles[1] / view_tiles[2]
	return text2num(split_size[1]) - desired_width >= MIN_INFO_PANEL_WIDTH

#undef AUTO_FIT_VIEWPORT_DELAY
#undef MAX_DYNAMIC_VIEW_WIDTH
#undef MIN_INFO_PANEL_WIDTH

/// Pełny ekran z ustawień włącza się od razu po wejściu, a nie dopiero po F11
/client/proc/apply_fullscreen_pref()
	set waitfor = FALSE
	// Jak menu pod Esc: chwila na załadowanie skinu, inaczej okno nie wchodzi w pełny ekran
	sleep(2 SECONDS)
	if(!src || !prefs)
		return
	if(prefs.toggles2 & PREFTOGGLE_2_FULLSCREEN)
		toggle_fullscreen(TRUE)
	else
		fit_view_to_window()
