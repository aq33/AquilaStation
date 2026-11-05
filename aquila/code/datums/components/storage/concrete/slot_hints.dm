/*
 * AQUILA - Znak w pustych przegródkach pasa
 *
 * Pasy nie mają siatki kratek (aquila/code/datums/components/storage/concrete/grid.dm): mieszczą przedmioty
 * na sztuki, w przegródkach. Żeby było to widać, każda pusta przegródka pokazuje wyblakły znak skrzyżowanego
 * klucza i młotka (aquila/icons/hud/storage_slot_hint.dmi), ten sam w każdym pasie.
 */

/datum/component/storage/concrete/slot_hints
	/// Obiekty ekranu ze znakiem, po jednym na pustą przegródkę (nieużywane są ukryte)
	var/list/atom/movable/screen/storage_slot_hint/hint_screens

/datum/component/storage/concrete/slot_hints/Destroy()
	QDEL_LIST(hint_screens)
	return ..()

/datum/component/storage/concrete/slot_hints/orient2hud()
	. = ..()
	update_slot_hints()

/// Rozmieszcza znaki w przegródkach za ostatnim przedmiotem, w tym samym układzie co standard_orient_objs()
/datum/component/storage/concrete/slot_hints/proc/update_slot_hints()
	var/atom/real_location = real_location()
	var/occupied = display_numerical_stacking ? length(_process_numerical_display()) : length(real_location.contents)
	var/columns = clamp(max_items, 1, screen_max_columns)
	var/rows = clamp(CEILING(occupied / columns, 1), 1, screen_max_rows)
	var/empty = max(columns * rows - occupied, 0)
	while(length(hint_screens) < empty)
		LAZYADD(hint_screens, new /atom/movable/screen/storage_slot_hint(null, src))
	for(var/i in 1 to length(hint_screens))
		var/atom/movable/screen/storage_slot_hint/hint = hint_screens[i]
		if(i > empty)
			hint.invisibility = INVISIBILITY_ABSTRACT
			hint.screen_loc = null
			continue
		hint.invisibility = 0
		var/index = occupied + i - 1
		hint.screen_loc = "[screen_start_x + index % columns]:[screen_pixel_x],[screen_start_y + round(index / columns)]:[screen_pixel_y]"

/datum/component/storage/concrete/slot_hints/show_to(mob/M)
	. = ..()
	if(. && M.client)
		M.client.screen |= hint_screens

/datum/component/storage/concrete/slot_hints/hide_from(mob/M)
	. = ..()
	if(M.client)
		M.client.screen -= hint_screens

/// Wyblakły znak narzędzi w pustej przegródce pasa. Nie łapie kliknięć, więc klik trafia w przegródkę pod spodem
/atom/movable/screen/storage_slot_hint
	name = "wolna przegródka"
	icon = 'aquila/icons/hud/storage_slot_hint.dmi'
	icon_state = "tools"
	alpha = 90
	layer = HUD_LAYER + 0.5
	plane = HUD_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/storage_slot_hint/Initialize(mapload, datum/component/storage/new_master)
	. = ..()
	master = new_master

/atom/movable/screen/storage_slot_hint/Destroy()
	master = null
	return ..()
