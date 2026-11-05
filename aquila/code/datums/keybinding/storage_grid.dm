// AQUILA - obrót przedmiotu na siatce ekwipunku (aquila/code/datums/components/storage/concrete/grid.dm) klawiszami E i Q
// w trakcie przeciągania. Te same klawisze mają szybkie założenie i upuszczenie, więc nasze skróty działają tylko wtedy,
// gdy gracz trzyma myszą przedmiot z otwartej siatki, a wtedy przejmują klawisz (waga WEIGHT_LOWEST idzie przed WEIGHT_MOB).

#define COMSIG_KB_STORAGE_GRID_ROTATE_RIGHT_DOWN "keybinding_storage_grid_rotate_right_down"
#define COMSIG_KB_STORAGE_GRID_ROTATE_LEFT_DOWN "keybinding_storage_grid_rotate_left_down"

/client
	/// Przedmiot przeciągany właśnie po siatce schowka (słaba referencja, żeby klient nie trzymał usuniętego przedmiotu)
	var/datum/weakref/storage_grid_drag
	/// Ostatnie parametry myszy z MouseDrag, żeby po obrocie klawiszem odświeżyć podgląd bez ruszania myszą
	var/storage_grid_drag_params
	/// Podgląd lądowania przeciąganego przedmiotu, widoczny tylko dla tego klienta
	var/atom/movable/screen/storage_grid_preview/storage_grid_preview

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
	// Przy każdym ruchu sprawdzamy, co faktycznie jest przeciągane: zapamiętany przedmiot z wcześniejszego przeciągania,
	// którego koniec nie doszedł, nie może przejąć podglądu ani klawiszy E/Q przy przeciąganiu czegoś innego
	var/obj/item/I = storage_grid_drag_target(src_object)
	if(storage_grid_drag?.resolve() != I)
		storage_grid_drag_end()
		if(I)
			storage_grid_drag = WEAKREF(I)
	if(I)
		storage_grid_update_preview(params)

/client/MouseDown(object, location, control, params)
	// Nowe wciśnięcie przycisku zaczyna nowe przeciąganie albo klik, więc stare przeciąganie na pewno się skończyło
	storage_grid_drag_end()
	return ..()

/// Odświeża podgląd lądowania dla przeciąganego przedmiotu. Bez params bierze ostatnie położenie myszy
/client/proc/storage_grid_update_preview(params)
	if(params)
		storage_grid_drag_params = params
	var/obj/item/I = storage_grid_drag?.resolve()
	if(!I || storage_grid_drag_target(I) != I)
		storage_grid_hide_preview()
		return
	var/datum/component/storage/concrete/grid/grid = I.loc.GetComponent(/datum/component/storage/concrete/grid)
	grid.update_drag_preview(src, I, storage_grid_drag_params)

/client/proc/storage_grid_hide_preview()
	if(!storage_grid_preview)
		return
	screen -= storage_grid_preview
	QDEL_NULL(storage_grid_preview)

/client/MouseDrop(src_object, over_object, src_location, over_location, src_control, over_control, params)
	. = ..()
	storage_grid_drag_end()

/client/MouseUp(object, location, control, params)
	. = ..()
	storage_grid_drag_end()

/// Koniec przeciągania. Obrót, który nie zdążył wejść przy upuszczeniu, przepada w następnym ticku (po MouseDrop, w dowolnej kolejności zdarzeń)
/client/proc/storage_grid_drag_end()
	storage_grid_hide_preview()
	storage_grid_drag_params = null
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
		user.storage_grid_hide_preview()
		return FALSE
	var/datum/component/storage/concrete/grid/grid = I.loc.GetComponent(/datum/component/storage/concrete/grid)
	grid.rotate_item(I, user.mob, clockwise)
	// Podgląd od razu pokazuje nowe ułożenie i miejsce lądowania, bez czekania na ruch myszy
	user.storage_grid_update_preview()
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

/// Nazwa jednorazowej migracji, która dopisuje obrót pod E i Q do zapisanych keybindów
#define STORAGE_GRID_KEYBIND_MIGRATION "storage_grid_rotate"

/// Zapisane keybindy nie dostają nowych skrótów same. Raz na gracza dopisujemy obrót pod E i Q obok dotychczasowych
/// skrótów (wtedy przejmuje klawisz tylko w trakcie przeciągania po siatce), o ile gracz nie ma go już gdzieś przypisanego.
/// Migracja zapisuje się w migrations, więc skrót, który gracz potem odepnie, nie wraca przy następnym logowaniu.
/// Zwraca TRUE, jeśli tym razem coś zmieniła
/proc/storage_grid_migrate_keybinds(list/key_bindings, list/migrations)
	if(!islist(key_bindings) || !islist(migrations) || (STORAGE_GRID_KEYBIND_MIGRATION in migrations))
		return FALSE
	migrations += STORAGE_GRID_KEYBIND_MIGRATION
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
	return TRUE

/datum/preferences/load_from_database()
	. = ..()
	if(!islist(keybind_migrations))
		keybind_migrations = list()
	storage_grid_migrate_keybinds(key_bindings, keybind_migrations)

#undef STORAGE_GRID_KEYBIND_MIGRATION
#undef COMSIG_KB_STORAGE_GRID_ROTATE_RIGHT_DOWN
#undef COMSIG_KB_STORAGE_GRID_ROTATE_LEFT_DOWN
