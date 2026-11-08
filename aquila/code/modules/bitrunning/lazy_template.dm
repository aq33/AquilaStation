/**
 * Uproszczony port /datum/lazy_template z tg.
 * Mapa ładuje się dopiero na żądanie, do nowej rezerwacji turfów.
 * U nas opiera się na zwykłym /datum/map_template z returns_created_atoms.
 */
/// Ile szablonów ładuje się teraz naraz (każde trzyma SSair wyłączone)
GLOBAL_VAR_INIT(lazy_template_loads, 0)

/// Początek ładowania: atmosfera stoi, dopóki nie skończy się ostatnie z nakładających się ładowań
/proc/lazy_template_load_started()
	GLOB.lazy_template_loads++
	SSair.can_fire = FALSE

/// Koniec ładowania. Licznik zamiast zapamiętanego stanu: dwa nakładające się ładowania (albo ładowanie wnętrza statku,
/// które samo wyłącza i włącza SSair) zapamiętywały FALSE od siebie nawzajem i atmosfera stała do końca rundy.
/// Po ostatnim ładowaniu SSair rusza zawsze, tak jak po ładowaniu wnętrza w nsv13/.../boarding/interiors.dm.
/proc/lazy_template_load_finished()
	GLOB.lazy_template_loads = max(GLOB.lazy_template_loads - 1, 0)
	if(!GLOB.lazy_template_loads)
		SSair.can_fire = TRUE

/datum/lazy_template
	/// Unikalny klucz szablonu
	var/key
	/// Folder z mapą (ścieżka względem katalogu gry)
	var/map_dir = "_maps/templates/lazy_templates"
	/// Nazwa pliku mapy bez .dmm
	var/map_name
	/// Czy turfy mają być kładzione na wierzch rezerwacji (baseturfy zostają pod spodem)
	var/place_on_top = FALSE
	/// Rezerwacje, w których ten szablon jest załadowany
	var/list/datum/turf_reservation/reservations = list()
	/// Dolny lewy turf ostatniego załadowania
	var/turf/bottom_left

/datum/lazy_template/Destroy(force)
	for(var/datum/turf_reservation/reservation as anything in reservations)
		// turf/empty() oszczędza landmarki - sprzątamy je sami, żeby eventy nie spawnowały rzeczy w pustej rezerwacji
		for(var/turf/tile as anything in reservation.reserved_turfs)
			for(var/obj/effect/landmark/landmark in tile)
				qdel(landmark)
		reservation.Release()
		qdel(reservation)
	reservations.Cut()
	bottom_left = null
	return ..()

/// Pełna ścieżka do pliku mapy
/datum/lazy_template/proc/get_map_path()
	return "[map_dir]/[map_name].dmm"

/**
 * Ładuje mapę do nowej rezerwacji.
 * Po załadowaniu wysyła COMSIG_LAZY_TEMPLATE_LOADED z listą stworzonych atomów.
 * Zwraca rezerwację albo null.
 */
/datum/lazy_template/proc/lazy_load()
	var/path = get_map_path()
	if(!fexists(path))
		CRASH("lazy_template [key]: brak pliku mapy [path]")

	var/datum/map_template/template = new(path, "lazy_template_[key]")
	if(!template.width || !template.height)
		CRASH("lazy_template [key]: nie udało się odczytać rozmiaru [path]")

	var/datum/turf_reservation/reservation = SSmapping.RequestBlockReservation(template.width, template.height)
	if(!reservation)
		CRASH("lazy_template [key]: brak miejsca na rezerwację [template.width]x[template.height]")

	reservations += reservation
	bottom_left = locate(reservation.bottom_left_coords[1], reservation.bottom_left_coords[2], reservation.bottom_left_coords[3])

	template.should_place_on_top = place_on_top
	template.returns_created_atoms = TRUE
	// Atomy dużej mapy inicjują się przez kilka ticków; bez pauzy SSair widzi niezainicjowane powietrze i rozrzuca meble
	lazy_template_load_started()
	var/list/bounds
	try
		bounds = template.load(bottom_left)
	catch(var/exception/load_error)
		lazy_template_load_finished()
		throw load_error
	lazy_template_load_finished()
	if(!bounds)
		reservations -= reservation
		reservation.Release()
		qdel(reservation)
		CRASH("lazy_template [key]: ładowanie [path] nie powiodło się")

	var/list/created_atoms = template.created_atoms.Copy()
	template.created_atoms.Cut()
	// Turfy i obszary też są „stworzone”, a landmarki i spawnery muszą tu trafić nawet przy wczesnym ładowaniu
	for(var/turf/tile as anything in reservation.reserved_turfs)
		created_atoms |= tile
		for(var/atom/movable/thing as anything in tile)
			created_atoms |= thing

	SEND_SIGNAL(src, COMSIG_LAZY_TEMPLATE_LOADED, created_atoms)
	return reservation
