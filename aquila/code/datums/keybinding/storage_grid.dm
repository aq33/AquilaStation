// AQUILA - obrót przedmiotu na siatce ekwipunku (aquila/code/datums/components/storage/concrete/grid.dm) klawiszami E i Q
// w trakcie przeciągania. Te same klawisze mają szybkie założenie i upuszczenie, więc nasze skróty działają tylko wtedy,
// gdy gracz trzyma myszą przedmiot z otwartej siatki, a wtedy przejmują klawisz (waga WEIGHT_LOWEST idzie przed WEIGHT_MOB).

#define COMSIG_KB_STORAGE_GRID_ROTATE_RIGHT_DOWN "keybinding_storage_grid_rotate_right_down"
#define COMSIG_KB_STORAGE_GRID_ROTATE_LEFT_DOWN "keybinding_storage_grid_rotate_left_down"

/client
	/// Przedmiot przeciągany właśnie po siatce schowka (słaba referencja, żeby klient nie trzymał usuniętego przedmiotu)
	var/datum/weakref/storage_grid_drag

/// Przedmiot leżący na otwartej siatce, który gracz złapał: sam przedmiot albo jego podświetlenie na siatce
/client/proc/storage_grid_drag_target(atom/src_object)
	var/obj/item/I
	if(istype(src_object, /atom/movable/screen/storage_grid_item))
		var/atom/movable/screen/storage_grid_item/highlight = src_object
		I = highlight.item
	else if(isitem(src_object))
		I = src_object
	if(QDELETED(I) || !(I.item_flags & IN_STORAGE) || !I.loc)
		return null
	var/datum/component/storage/concrete/grid/grid = I.loc.GetComponent(/datum/component/storage/concrete/grid)
	if(!grid?.grid_width || mob?.active_storage != grid)
		return null
	return I

/client/MouseDrag(src_object, atom/over_object, src_location, over_location, src_control, over_control, params)
	. = ..()
	if(storage_grid_drag)
		return
	var/obj/item/I = storage_grid_drag_target(src_object)
	if(I)
		storage_grid_drag = WEAKREF(I)

/client/MouseDrop(src_object, over_object, src_location, over_location, src_control, over_control, params)
	. = ..()
	storage_grid_drag_end()

/client/MouseUp(object, location, control, params)
	. = ..()
	storage_grid_drag_end()

/// Koniec przeciągania. Obrót, który nie zdążył wejść przy upuszczeniu, przepada w następnym ticku (po MouseDrop, w dowolnej kolejności zdarzeń)
/client/proc/storage_grid_drag_end()
	if(!storage_grid_drag)
		return
	var/obj/item/I = storage_grid_drag.resolve()
	storage_grid_drag = null
	if(QDELETED(I) || !I.loc)
		return
	var/datum/component/storage/concrete/grid/grid = I.loc.GetComponent(/datum/component/storage/concrete/grid)
	if(grid && !isnull(LAZYACCESS(grid.grid_pending_rotation, I)))
		addtimer(CALLBACK(grid, TYPE_PROC_REF(/datum/component/storage/concrete/grid, clear_pending_rotation), I), 1)

/datum/keybinding/storage_grid
	category = CATEGORY_HUMAN
	weight = WEIGHT_LOWEST
	/// TRUE obraca w prawo, FALSE w lewo
	var/clockwise = TRUE

/datum/keybinding/storage_grid/down(client/user)
	. = ..()
	if(.)
		return
	var/obj/item/I = user.storage_grid_drag?.resolve()
	if(!I)
		return FALSE
	// Sprawdzamy jeszcze raz: przedmiot mógł w międzyczasie wypaść ze schowka, a okno mogło się zamknąć
	if(user.storage_grid_drag_target(I) != I || user.mob.incapacitated())
		user.storage_grid_drag = null
		return FALSE
	var/datum/component/storage/concrete/grid/grid = I.loc.GetComponent(/datum/component/storage/concrete/grid)
	grid.rotate_item(I, user.mob, clockwise)
	return TRUE

/datum/keybinding/storage_grid/rotate_right
	key = "E"
	name = "storage_grid_rotate_right"
	full_name = "Obróć przeciągany przedmiot w prawo"
	description = "Działa w trakcie przeciągania przedmiotu po siatce plecaka, skrzynki albo pudełka."
	keybind_signal = COMSIG_KB_STORAGE_GRID_ROTATE_RIGHT_DOWN

/datum/keybinding/storage_grid/rotate_left
	key = "Q"
	name = "storage_grid_rotate_left"
	full_name = "Obróć przeciągany przedmiot w lewo"
	description = "Działa w trakcie przeciągania przedmiotu po siatce plecaka, skrzynki albo pudełka."
	keybind_signal = COMSIG_KB_STORAGE_GRID_ROTATE_LEFT_DOWN
	clockwise = FALSE

// Zapisane keybindy nie dostają nowych skrótów same. Dopisujemy obrót pod E i Q obok dotychczasowych skrótów,
// jeśli gracz nie ma go nigdzie przypisanego (wtedy przejmuje klawisz tylko w trakcie przeciągania po siatce).
/datum/preferences/load_from_database()
	. = ..()
	if(!islist(key_bindings))
		return
	var/list/missing = list("storage_grid_rotate_right" = "E", "storage_grid_rotate_left" = "Q")
	for(var/bound_key in key_bindings)
		var/list/names = key_bindings[bound_key]
		if(!islist(names))
			continue
		for(var/kb_name in missing.Copy())
			if(kb_name in names)
				missing -= kb_name
	for(var/kb_name in missing)
		var/bound_key = missing[kb_name]
		var/list/names = key_bindings[bound_key]
		key_bindings[bound_key] = islist(names) ? names + kb_name : list(kb_name)

#undef COMSIG_KB_STORAGE_GRID_ROTATE_RIGHT_DOWN
#undef COMSIG_KB_STORAGE_GRID_ROTATE_LEFT_DOWN
