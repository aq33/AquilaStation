// AQ - porządki w UI: powiększona minimapa (holomapa) na HUD-zie.
// Ikona ma 480x480 px i rysuje statek po 1 px na kafelek, więc w oknie wychodziła malutka.
// Skalę dobieramy do widoku gracza tak, żeby legenda (lewy dolny róg ikony) i cały statek
// zostały na ekranie. Kliknięcia w legendę dalej działają, bo icon-x/icon-y są w pikselach ikony.

/// Największe powiększenie minimapy
#define HOLOMAP_MAX_SCALE 1.6
/// Odległość lewej krawędzi legendy od środka ikony (+ zapas na podpisy)
#define HOLOMAP_LEGEND_REACH_X (HOLOMAP_ICON_SIZE / 2 - HOLOMAP_LEGEND_X + 4)
#define HOLOMAP_LEGEND_REACH_Y (HOLOMAP_ICON_SIZE / 2 - HOLOMAP_LEGEND_Y + 4)

/atom/movable/screen/holomap/proc/fit_to_view(client/viewer)
	if(!viewer)
		return
	var/list/view_size = getviewsize(viewer.view)
	var/half_width = view_size[1] * world.icon_size / 2
	var/half_height = view_size[2] * world.icon_size / 2
	var/scale = min(
		HOLOMAP_MAX_SCALE,
		half_width / HOLOMAP_LEGEND_REACH_X,
		half_height / HOLOMAP_LEGEND_REACH_Y,
		half_width / (world.maxx / 2 + 4),
		half_height / (world.maxy / 2 + 4),
	)
	scale = max(1, FLOOR(scale, 0.05))
	transform = matrix(scale, 0, 0, 0, scale, 0)

#undef HOLOMAP_MAX_SCALE
#undef HOLOMAP_LEGEND_REACH_X
#undef HOLOMAP_LEGEND_REACH_Y
