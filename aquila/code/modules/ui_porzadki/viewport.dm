// AQ - porządki w UI: widok gry dopasowuje się do okna, bez czarnych pasów.
// tg ma stały widok i tylko przesuwa splitter (attempt_auto_fit_viewport przy on-size). U nas widok
// rośnie w poziomie (szerokie okno) albo w pionie (wąskie, wysokie okno), a potem splitter zawsze
// dociąga panel mapy do dokładnych proporcji widoku. Skin (interface/skin.dmf, mainwindow on-size)
// woła .auto_fit_viewport przy każdej zmianie rozmiaru okna i panelu mapy (przeciągnięcie granicy czatu),
// mob/Login() - po wejściu w moba.

/// Przy przeciąganiu krawędzi okna on-size leci wiele razy - dopasowujemy dopiero po chwili spokoju
#define AUTO_FIT_VIEWPORT_DELAY (0.3 SECONDS)
/// Podstawowy (najmniejszy) bok widoku w kafelkach
#define BASE_VIEW_TILES 15
/// Najdłuższy bok widoku w kafelkach
#define MAX_DYNAMIC_VIEW_TILES 31
/// Najwęższy panel czatu/statystyk (px), jaki może zostać po dopasowaniu mapy
#define MIN_INFO_PANEL_WIDTH 250

/client/verb/auto_fit_viewport()
	set name = ".auto_fit_viewport"
	set hidden = TRUE
	addtimer(CALLBACK(src, PROC_REF(fit_view_to_window)), AUTO_FIT_VIEWPORT_DELAY, TIMER_UNIQUE | TIMER_OVERRIDE)

/// Najbliższa nieparzysta liczba kafelków (postać zostaje na środku), w granicach widoku
/proc/dynamic_view_tiles(tiles)
	return clamp(round((tiles - 1) / 2, 1) * 2 + 1, BASE_VIEW_TILES, MAX_DYNAMIC_VIEW_TILES)

/// Widok z proporcji miejsca na mapę, potem splitter dociągnięty do proporcji widoku
/client/proc/fit_view_to_window()
	if(!prefs)
		return
	var/dynamic = (prefs.toggles2 & PREFTOGGLE_2_WIDESCREEN) && !prefs.pixel_size && view_size && !view_size.isZooming() && !isnewplayer(mob)
	if(!dynamic)
		if(prefs.toggles2 & PREFTOGGLE_2_AUTO_FIT_VIEWPORT)
			fit_viewport()
		return
	var/list/sizes = params2list(winget(src, "mainwindow.split;mapwindow", "size"))
	var/list/map_size = splittext(sizes["mapwindow.size"], "x")
	var/list/split_size = splittext(sizes["mainwindow.split.size"], "x")
	if(length(map_size) != 2 || length(split_size) != 2)
		return
	var/map_height = text2num(map_size[2])
	// miejsce na mapę: obecny panel, ale tak, żeby czatowi zostało minimum
	var/map_width = min(text2num(map_size[1]), text2num(split_size[1]) - MIN_INFO_PANEL_WIDTH)
	if(map_width <= 0 || map_height <= 0)
		return
	var/aspect = map_width / map_height
	var/tiles_wide = BASE_VIEW_TILES
	var/tiles_high = BASE_VIEW_TILES
	if(aspect >= 1)
		tiles_wide = dynamic_view_tiles(BASE_VIEW_TILES * aspect)
	else
		tiles_high = dynamic_view_tiles(BASE_VIEW_TILES / aspect)
	var/new_view = "[tiles_wide]x[tiles_high]"
	if(view != new_view || view_size.default != new_view)
		view_size.setDefault(new_view)
	if(chat_keeps_room_after_fit())
		fit_viewport()

/// Czy po dopasowaniu panelu mapy do proporcji widoku czatowi zostanie dość miejsca
/client/proc/chat_keeps_room_after_fit()
	var/list/sizes = params2list(winget(src, "mainwindow.split;mapwindow", "size"))
	var/list/map_size = splittext(sizes["mapwindow.size"], "x")
	var/list/split_size = splittext(sizes["mainwindow.split.size"], "x")
	if(length(map_size) != 2 || length(split_size) != 2)
		return FALSE
	var/list/view_tiles = getviewsize(view)
	var/desired_width = text2num(map_size[2]) * view_tiles[1] / view_tiles[2]
	// już dopasowane - bez tego każde przesunięcie splittera (on-size mapy) wołałoby kolejne poprawki
	if(abs(text2num(map_size[1]) - desired_width) <= 3)
		return FALSE
	return text2num(split_size[1]) - desired_width >= MIN_INFO_PANEL_WIDTH

#undef AUTO_FIT_VIEWPORT_DELAY
#undef BASE_VIEW_TILES
#undef MAX_DYNAMIC_VIEW_TILES
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

/// Po wejściu w moba (spawn, duch, przejęcie ciała) mob/Login() ustawia domyślny widok - przeliczamy go do okna
/mob/Login()
	. = ..()
	if(client)
		addtimer(CALLBACK(client, TYPE_PROC_REF(/client, fit_view_to_window)), 1 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)
