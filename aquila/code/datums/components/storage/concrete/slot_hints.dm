/*
 * AQUILA - Podpowiedzi w pustych przegródkach pasa
 *
 * Pasy nie mają siatki kratek (aquila/code/datums/components/storage/concrete/grid.dm): mieszczą konkretne narzędzia
 * na sztuki. Żeby było to widać, każda pusta przegródka pokazuje wyblakłą sylwetkę przedmiotu, na który pas jest
 * przeznaczony (z jego listy can_hold). Najpierw idą rodzaje, których jeszcze nie ma w pasie, potem lista od nowa.
 */

/// Ile różnych sylwetek bierzemy z listy can_hold jednego pasa
#define SLOT_HINTS_MAX_TYPES 12

/datum/component/storage/concrete/slot_hints
	/// Obiekty ekranu z sylwetkami, po jednym na pustą przegródkę (nieużywane są ukryte)
	var/list/atom/movable/screen/storage_slot_hint/hint_screens

/datum/component/storage/concrete/slot_hints/Destroy()
	QDEL_LIST(hint_screens)
	return ..()

/// Rodzaje przedmiotów do sylwetek dla tego pasa, liczone raz na typ pasa
/datum/component/storage/concrete/slot_hints/proc/hint_types()
	var/static/list/cache_by_type = list()
	var/atom/host = parent
	var/list/cached = cache_by_type[host.type]
	if(cached)
		return cached
	// Pierwsze odświeżenie przychodzi, zanim ComponentInitialize pasa ustawi can_hold: wtedy nic nie zapamiętujemy
	if(!length(can_hold))
		return list()
	var/static/list/states_by_icon = list()
	. = list()
	for(var/hold_type in can_hold)
		// Lista can_hold z typecacheof zawiera też wszystkie podtypy, a sylwetkę bierzemy tylko z wpisanego typu
		if(can_hold[type2parent(hold_type)])
			continue
		var/obj/item/proto = hold_type
		var/hint_icon = initial(proto.icon)
		var/hint_state = initial(proto.icon_state)
		if(!hint_icon || !hint_state)
			continue
		var/list/states = states_by_icon[hint_icon]
		if(!states)
			states = icon_states(hint_icon)
			states_by_icon[hint_icon] = states
		if(!(hint_state in states))
			continue
		. += hold_type
		if(length(.) >= SLOT_HINTS_MAX_TYPES)
			break
	cache_by_type[host.type] = .

/datum/component/storage/concrete/slot_hints/orient2hud()
	. = ..()
	update_slot_hints()

/// Rozmieszcza sylwetki w przegródkach za ostatnim przedmiotem, w tym samym układzie co standard_orient_objs()
/datum/component/storage/concrete/slot_hints/proc/update_slot_hints()
	var/list/types = hint_types()
	var/atom/real_location = real_location()
	var/occupied = display_numerical_stacking ? length(_process_numerical_display()) : length(real_location.contents)
	var/columns = clamp(max_items, 1, screen_max_columns)
	var/rows = clamp(CEILING(occupied / columns, 1), 1, screen_max_rows)
	var/empty = length(types) ? max(columns * rows - occupied, 0) : 0
	while(length(hint_screens) < empty)
		LAZYADD(hint_screens, new /atom/movable/screen/storage_slot_hint(null, src))
	// Najpierw rodzaje, których w pasie brakuje
	var/list/order = list()
	for(var/hint_type in types)
		if(!(locate(hint_type) in real_location))
			order += hint_type
	if(!length(order))
		order = types
	for(var/i in 1 to length(hint_screens))
		var/atom/movable/screen/storage_slot_hint/hint = hint_screens[i]
		if(i > empty)
			hint.invisibility = INVISIBILITY_ABSTRACT
			hint.screen_loc = null
			continue
		var/obj/item/proto = order[(i - 1) % length(order) + 1]
		hint.icon = initial(proto.icon)
		hint.icon_state = initial(proto.icon_state)
		hint.name = initial(proto.name)
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

/// Wyblakła sylwetka przedmiotu w pustej przegródce pasa. Nie łapie kliknięć, więc klik trafia w przegródkę pod spodem
/atom/movable/screen/storage_slot_hint
	name = ""
	alpha = 80
	color = list(0.3, 0.3, 0.3, 0, 0.59, 0.59, 0.59, 0, 0.11, 0.11, 0.11, 0, 0, 0, 0, 1)
	layer = HUD_LAYER + 0.5
	plane = HUD_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/storage_slot_hint/Initialize(mapload, datum/component/storage/new_master)
	. = ..()
	master = new_master

/atom/movable/screen/storage_slot_hint/Destroy()
	master = null
	return ..()

#undef SLOT_HINTS_MAX_TYPES
