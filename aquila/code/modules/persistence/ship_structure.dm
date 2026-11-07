/**
 * AQUILA - Trwała struktura statku.
 *
 * Ściany, podłogi (z uszkodzeniami), okna, kraty, dźwigary, kratownice, drzwi, kable, rury i maszyny
 * zostają między rundami tak, jak zostawiła je załoga: zbudowane, przeniesione, obrócone, ulepszone i zniszczone.
 * Przedmioty wczytują się z mapy jak zwykle (szafki i automaty się uzupełniają). Maszyny krytyczne dla celów
 * antagonistów i misji okrętu zawsze stoją tak, jak na mapie.
 *
 * Zapis to różnica względem świeżo wczytanej mapy:
 * - SSship_structure w Initialize() robi zdjęcie poziomów statku (baseline) i dopiero potem nakłada zapis,
 * - na koniec rundy CollectData() porównuje stan świata z tym zdjęciem i zapisuje tylko zmienione pola.
 * Każde pole zapisu pamięta, co stało na nim na mapie. Jeśli mapa w repo się zmieniła (albo pole
 * wylosowało inny wariant), wpis jest pomijany, więc poprawki mapperów nie gryzą się z zapisem.
 *
 * Po nałożeniu zapisu:
 * - dziury do kosmosu łata spieniony metal (podłoga z pianki i ściana z pianki),
 * - rzeczy wiszące na zburzonej ścianie przechodzą na sąsiednią ścianę (APC bez innej ściany na swoim polu
 *   przywraca swoją ścianę),
 * - rzeczy z mapy, które wylądowały w nowo postawionej ścianie, są wypychane na sąsiednie pole.
 * Zniszczenie statku kasuje zapis. Admin może wyłączyć zapis rundy albo skasować zapis (Server -> Ship Structure).
 */

#define SHIP_STRUCTURE_DIR "data/ship_structure/"
#define SHIP_STRUCTURE_VERSION 1
/// Sygnatura „pustego kosmosu”: takich pól nie trzymamy w zdjęciu
#define SHIP_STRUCTURE_SPACE ""
/// Jak daleko (w polach) szukamy nowej ściany dla rzeczy wiszącej na zburzonej ścianie
#define SHIP_STRUCTURE_MOUNT_RANGE 2

/**
 * Maszyny, od których zależą cele antagonistów albo misje okrętu. Nie są zapisywane:
 * zawsze stoją tak, jak na mapie (zniszczone wracają, przeniesione wracają na miejsce).
 */
/proc/ship_structure_critical_types()
	return list(
	// Cele antagonistów
	/obj/machinery/telecomms/hub,
	/obj/machinery/computer/communications,
	/obj/machinery/rnd/server,
	/obj/machinery/nuclearbomb,
	/obj/machinery/ai/data_core,
	// Lot i misje okrętu
	/obj/machinery/computer/ship/helm,
	/obj/machinery/computer/ship/navigation,
	/obj/machinery/computer/ship/tactical,
	/obj/machinery/computer/ship/dradis,
	/obj/machinery/computer/ship/ftl_computer,
	/obj/machinery/computer/ship/ftl_core,
	/obj/machinery/atmospherics/components/binary/drive_pylon,
	/obj/machinery/computer/ship/salvage
	)

/// Maszyny, które zachowują się jak przedmioty (wracają z mapy, nowe nie przechodzą): przenośne i chwilowe
/proc/ship_structure_untracked_types()
	return list(
	/obj/machinery/portable_atmospherics,
	/obj/machinery/syndicatebomb,
	/obj/machinery/doomsday_device,
	/obj/machinery/field/containment,
	/obj/machinery/shieldwall,
	/obj/machinery/power/singularity_beacon,
	/obj/machinery/abductor
	)

/// Obiekty, które są częścią struktury statku i są zapisywane: konstrukcje, instalacje i wszystkie maszyny poza wyjątkami
GLOBAL_LIST_INIT(ship_structure_tracked, ship_structure_tracked_types())

/proc/ship_structure_tracked_types()
	var/list/result = typecacheof(list(
		/obj/structure/window,
		/obj/structure/grille,
		/obj/structure/girder,
		/obj/structure/lattice,
		/obj/structure/cable,
		/obj/machinery,
		/obj/structure/foamedmetal
	)) - typecacheof(ship_structure_critical_types()) - typecacheof(ship_structure_untracked_types())
	return result

/// Zmienne maszyn z mapy, które trzeba przenieść na odtworzoną maszynę (powiązania przycisków, sieci kamer, dostęp)
GLOBAL_LIST_INIT(ship_structure_machine_vars, list(
	"name",
	"id",
	"id_tag",
	"network",
	"frequency",
	"c_tag",
	"req_access",
	"req_one_access",
	"req_access_txt",
	"req_one_access_txt",
	"areastring"
))

/// Rzeczy wiszące na ścianach, które przenosimy, gdy ich ściana zniknie
GLOBAL_LIST_INIT(ship_structure_wallmounts, typecacheof(list(
	/obj/machinery/power/apc,
	/obj/machinery/airalarm,
	/obj/machinery/firealarm,
	/obj/machinery/light,
	/obj/machinery/light_switch,
	/obj/machinery/button,
	/obj/machinery/status_display,
	/obj/machinery/newscaster,
	/obj/machinery/requests_console,
	/obj/machinery/defibrillator_mount,
	/obj/machinery/flasher,
	/obj/machinery/door_timer,
	/obj/machinery/computer/security/telescreen,
	/obj/machinery/turretid,
	/obj/machinery/keycard_auth,
	/obj/machinery/digital_clock,
	/obj/item/radio/intercom,
	/obj/structure/sign,
	/obj/structure/extinguisher_cabinet,
	/obj/structure/fireaxecabinet,
	/obj/structure/noticeboard,
	/obj/structure/mirror,
	/obj/structure/reagent_dispensers/peppertank
)) - typecacheof(/obj/machinery/light/floor))

/// Sygnatura pola: typ turfa i jego uszkodzenia
/proc/ship_structure_turf_sig(turf/T)
	. = "[T.type]"
	if(isfloorturf(T))
		var/turf/open/floor/F = T
		if(F.broken || F.burnt)
			. += ";[F.broken ? 1 : 0];[F.burnt ? 1 : 0]"
	else if(istype(T, /turf/closed/wall/r_wall))
		var/turf/closed/wall/r_wall/R = T
		if(R.d_state != INTACT)
			. += ";[R.d_state]"

/// Sygnatura obiektu struktury: "typ;kierunek;dodatki". Te same sygnatury = ten sam obiekt dla porównania rund.
/proc/ship_structure_obj_sig(obj/O)
	if(istype(O, /obj/structure/cable))
		var/obj/structure/cable/C = O
		return "[O.type];0;[C.cable_color];[C.multiz ? 1 : 0]"
	// Instalacja atmosferyczna: kierunek i warstwa decydują o połączeniach
	if(istype(O, /obj/machinery/atmospherics))
		var/obj/machinery/atmospherics/A = O
		return "[O.type];[O.dir];[A.piping_layer];[A.pipe_color]"
	// Pozostałe maszyny bez kierunku w sygnaturze (obrót to zmiana stanu, nie wymiana maszyny),
	// poza wiatrołapami i drzwiami przeciwpożarowymi, które stoją na krawędzi pola
	if(istype(O, /obj/machinery) && !istype(O, /obj/machinery/door/window) && !istype(O, /obj/machinery/door/firedoor))
		return "[O.type];0"
	. = "[O.type];[O.dir]"
	if(istype(O, /obj/structure/girder))
		var/obj/structure/girder/G = O
		. += ";[G.state]"
	else if(istype(O, /obj/structure/window))
		. += ";[O.anchored ? 1 : 0]"

/proc/ship_structure_hash(list/sigs)
	if(!length(sigs))
		return md5("")
	return md5(jointext(sort_list(sigs.Copy()), "|"))

/// Pole zamknięte jak ściana: pełne okno albo ściana z pianki (wtedy odchodzą z niego także przedmioty)
/proc/ship_structure_turf_sealed(turf/T)
	if(locate(/obj/structure/foamedmetal) in T)
		return TRUE
	for(var/obj/structure/window/W in T)
		if(W.fulltile)
			return TRUE
	return FALSE

/// Kierunek ściany, na której wisi obiekt, albo 0
/proc/ship_structure_mount_dir(obj/O)
	if(!GLOB.ship_structure_wallmounts[O.type] || !O.anchored)
		return 0
	if(istype(O, /obj/machinery/light))
		return O.dir
	if(abs(O.pixel_y) >= 16 && abs(O.pixel_y) >= abs(O.pixel_x))
		return O.pixel_y > 0 ? NORTH : SOUTH
	if(abs(O.pixel_x) >= 16)
		return O.pixel_x > 0 ? EAST : WEST
	return 0

/// Przewiesza obiekt ze ściany old_dir na ścianę new_dir (kierunek i przesunięcie obracają się razem)
/proc/ship_structure_hang(obj/O, old_dir, new_dir)
	if(old_dir != new_dir)
		O.setDir(turn(O.dir, dir2angle(old_dir) - dir2angle(new_dir)))
	if(istype(O, /obj/machinery/light))
		O.setDir(new_dir)
	else
		var/offset = max(abs(O.pixel_x), abs(O.pixel_y))
		O.pixel_x = (new_dir & EAST) ? offset : ((new_dir & WEST) ? -offset : 0)
		O.pixel_y = (new_dir & NORTH) ? offset : ((new_dir & SOUTH) ? -offset : 0)
	O.update_appearance()

/datum/ship_structure
	/// Poziomy statku w stałej kolejności; klucze pól używają indeksu z tej listy, nie numeru z
	var/list/z_levels
	/// list(x1, y1, x2, y2) albo null = cały poziom (testy używają małego bloku)
	var/list/bounds
	/// Zdjęcie świeżo wczytanej mapy: klucz pola -> list(sygnatura turfa, list(sygnatury obiektów))
	var/list/baseline
	/// Plik zapisu albo null (testy)
	var/save_path
	/// Ile rund ma już ten zapis
	var/rounds = 0
	/// TRUE = ta runda nie nadpisze zapisu (admin)
	var/skip_save = FALSE
	/// Testy: każde pole liczy się jako wnętrze statku
	var/force_ship_area = FALSE
	/// Podsumowanie ostatniego wczytania dla admina
	var/last_report = "brak"
	/// Obszary promów (odświeżane przy każdym zdjęciu i wczytaniu)
	var/list/shuttle_areas

/datum/ship_structure/New(list/z_levels, list/bounds)
	. = ..()
	src.z_levels = z_levels.Copy()
	src.bounds = bounds

/datum/ship_structure/proc/key_for(turf/T)
	var/z_index = z_levels.Find(T.z)
	if(!z_index)
		return
	return "[T.x];[T.y];[z_index]"

/datum/ship_structure/proc/turf_for(key)
	var/list/parts = splittext(key, ";")
	if(length(parts) != 3)
		return
	var/z_index = text2num(parts[3])
	if(!z_index || z_index > length(z_levels))
		return
	return locate(text2num(parts[1]), text2num(parts[2]), z_levels[z_index])

/datum/ship_structure/proc/get_turfs()
	. = list()
	for(var/z in z_levels)
		if(bounds)
			. += block(locate(bounds[1], bounds[2], z), locate(bounds[3], bounds[4], z))
		else
			. += Z_TURFS(z)

/// Pola, których nie zapisujemy: promy (odlatują i wracają w innych miejscach) i tranzyt.
/// Prom poznajemy po obszarze, po obszarach zadokowanych promów i po turfie położonym na pole przez prom.
/datum/ship_structure/proc/skip_turf(turf/T)
	if(istype(T.loc, /area/shuttle) || istype(T, /turf/open/space/transit))
		return TRUE
	if(islist(T.baseturfs) && (/turf/baseturf_skipover/shuttle in T.baseturfs))
		return TRUE
	return shuttle_areas?[T.loc]

/// Odświeża listę obszarów wszystkich promów (część promów NSV nie ma obszarów /area/shuttle)
/datum/ship_structure/proc/cache_shuttle_areas()
	shuttle_areas = list()
	for(var/obj/docking_port/mobile/port as anything in SSshuttle.mobile)
		for(var/area/A as anything in port.shuttle_areas)
			shuttle_areas[A] = TRUE

/datum/ship_structure/proc/is_ship_area(area/A)
	if(force_ship_area)
		return TRUE
	return A && !istype(A, /area/space) && !istype(A, /area/shuttle)

/// Obiekty struktury na polu. Maszyna odkręcona (kroplówka, emiter w magazynie, sprzęt wożony po statku)
/// to sprzęt luzem jak przedmiot: nie jest częścią statku i wraca z mapy.
/datum/ship_structure/proc/tracked_objs(turf/T)
	. = list()
	for(var/obj/O in T)
		if(!GLOB.ship_structure_tracked[O.type] || QDELETED(O))
			continue
		if(!O.anchored && istype(O, /obj/machinery))
			continue
		. += O

/// Kierunek maszyny jest stanem do zapisania (obrót), a nie częścią sygnatury.
/// Nie dotyczy drzwi (obracają się same), instalacji atmosferycznej (kierunek w sygnaturze) i rzeczy na ścianach (przewiesza je load).
/proc/ship_structure_dir_is_state(obj/O)
	return istype(O, /obj/machinery) && !istype(O, /obj/machinery/door) && !istype(O, /obj/machinery/atmospherics) && !GLOB.ship_structure_wallmounts[O.type]

/**
 * Zdjęcie struktury: klucz pola -> list(sygnatura turfa, sygnatury obiektów, wytrzymałość obiektów, kierunki obiektów).
 * with_objects = TRUE dokłada piąty element z referencjami do obiektów
 * (do zapisu nowych maszyn i uszkodzeń; nie trzymać dłużej niż w jednej procedurze).
 */
/datum/ship_structure/proc/capture(with_objects = FALSE)
	. = list()
	cache_shuttle_areas()
	for(var/turf/T as anything in get_turfs())
		if(skip_turf(T))
			continue
		var/list/objs = tracked_objs(T)
		if(!length(objs) && isspaceturf(T))
			continue
		var/list/sigs = list()
		var/list/integrity = list()
		var/list/dirs = list()
		for(var/obj/O as anything in objs)
			sigs += ship_structure_obj_sig(O)
			integrity += round(O.obj_integrity, 1)
			dirs += O.dir
		var/list/entry = list(ship_structure_turf_sig(T), sigs, integrity, dirs)
		if(with_objects)
			entry += list(objs)
		.[key_for(T)] = entry
		CHECK_TICK

/// Dane obiektu potrzebne do odtworzenia go w następnej rundzie
/datum/ship_structure/proc/obj_record(sig, obj/O)
	. = list("s" = sig)
	if(O.obj_integrity < O.max_integrity)
		.["i"] = round(O.obj_integrity, 1)
	if(!istype(O, /obj/machinery))
		return
	var/obj/machinery/M = O
	.["dir"] = M.dir
	if(M.pixel_x)
		.["px"] = M.pixel_x
	if(M.pixel_y)
		.["py"] = M.pixel_y
	var/list/saved_vars = list()
	for(var/var_name in GLOB.ship_structure_machine_vars)
		if(!(var_name in M.vars))
			continue
		var/value = M.vars[var_name]
		if(islist(value))
			var/list/value_list = value
			if(!length(value_list))
				continue
			var/list/copy = list()
			for(var/entry in value_list)
				if(istext(entry) || isnum(entry))
					copy += entry
			value = copy
		else if(!istext(value) && !isnum(value))
			continue
		else if(value == initial(M.vars[var_name]))
			continue
		saved_vars[var_name] = value
	if(length(saved_vars))
		.["v"] = saved_vars
	// Części (płytka i ulepszenia), z których złożono maszynę
	if(length(M.component_parts))
		var/list/parts = list()
		for(var/obj/item/part in M.component_parts)
			parts += "[part.type]"
		if(length(parts))
			.["p"] = parts

/// Różnica między zdjęciem mapy a stanem z capture(TRUE): klucz pola -> rekord zmian
/datum/ship_structure/proc/diff(list/old_state, list/new_state)
	. = list()
	var/list/keys = list()
	for(var/key in old_state)
		keys[key] = TRUE
	for(var/key in new_state)
		keys[key] = TRUE
	for(var/key in keys)
		var/list/old_entry = old_state[key]
		var/list/new_entry = new_state[key]
		var/old_turf = old_entry ? old_entry[1] : SHIP_STRUCTURE_SPACE
		var/list/old_sigs = old_entry ? old_entry[2] : list()
		var/new_turf = new_entry ? new_entry[1] : SHIP_STRUCTURE_SPACE
		var/list/new_sigs = new_entry ? new_entry[2] : list()
		var/list/new_objs = (new_entry && length(new_entry) >= 5) ? new_entry[5] : list()
		var/list/old_integrity = (old_entry && length(old_entry) >= 3) ? old_entry[3] : list()
		var/list/old_dirs = (old_entry && length(old_entry) >= 4) ? old_entry[4] : list()

		var/list/removed = old_sigs.Copy()
		var/list/removed_integrity = old_integrity.Copy()
		var/list/removed_dirs = old_dirs.Copy()
		var/list/added = list()
		var/list/damaged = list()
		for(var/i in 1 to length(new_sigs))
			var/sig = new_sigs[i]
			var/obj/O = i <= length(new_objs) ? new_objs[i] : null
			var/index = removed.Find(sig)
			if(index)
				// Uszkodzenie i obrót liczą się względem stanu z mapy (np. zmapowane połamane kraty)
				var/map_integrity = index <= length(removed_integrity) ? removed_integrity[index] : null
				var/map_dir = index <= length(removed_dirs) ? removed_dirs[index] : null
				removed.Cut(index, index + 1)
				if(index <= length(removed_integrity))
					removed_integrity.Cut(index, index + 1)
				if(index <= length(removed_dirs))
					removed_dirs.Cut(index, index + 1)
				if(!O)
					continue
				var/new_integrity = (O.obj_integrity < O.max_integrity && round(O.obj_integrity, 1) != map_integrity) ? round(O.obj_integrity, 1) : null
				var/new_dir = (ship_structure_dir_is_state(O) && !isnull(map_dir) && O.dir != map_dir) ? O.dir : null
				if(!isnull(new_integrity) || !isnull(new_dir))
					damaged += list(list(sig, new_integrity, new_dir))
			else
				added += list(O ? obj_record(sig, O) : list("s" = sig))

		if(old_turf == new_turf && !length(removed) && !length(added) && !length(damaged))
			continue
		var/list/record = list("ot" = old_turf, "oh" = ship_structure_hash(old_sigs))
		if(old_turf != new_turf)
			if(new_turf == SHIP_STRUCTURE_SPACE)
				var/turf/T = turf_for(key)
				new_turf = T ? "[T.type]" : "[/turf/open/space/basic]"
			record["t"] = new_turf
		if(length(removed))
			record["r"] = removed
		if(length(added))
			record["a"] = added
		if(length(damaged))
			record["d"] = damaged
		.[key] = record
		CHECK_TICK

/// Zmienia turf zgodnie z sygnaturą. Budowa na kosmosie kładzie poszycie pod spód, jak przy budowie przez gracza.
/datum/ship_structure/proc/set_turf(turf/T, sig)
	var/list/fields = splittext(sig, ";")
	var/turf/path = text2path(fields[1])
	if(!ispath(path, /turf))
		return T
	if(T.type != path)
		if(isspaceturf(T) && !ispath(path, /turf/open/space) && !ispath(path, /turf/open/openspace))
			if(ispath(path, /turf/open/floor/plating))
				T = T.PlaceOnTop(path)
			else
				T = T.PlaceOnTop(list(/turf/open/floor/plating, path))
		else
			T = T.ChangeTurf(path)
	if(isfloorturf(T) && length(fields) >= 3)
		var/turf/open/floor/F = T
		if(fields[2] == "1")
			F.break_tile()
		if(fields[3] == "1")
			F.burn_tile()
	else if(istype(T, /turf/closed/wall/r_wall) && length(fields) >= 2)
		var/turf/closed/wall/r_wall/R = T
		R.d_state = text2num(fields[2])
		R.update_appearance()
	return T

/datum/ship_structure/proc/set_integrity(obj/O, value)
	if(!isnum(value))
		return
	O.obj_integrity = clamp(value, 1, O.max_integrity)
	O.update_appearance()

/// Tworzy obiekt struktury z rekordu tak, jakby zbudował go gracz
/datum/ship_structure/proc/create_obj(turf/T, list/record)
	var/list/fields = splittext(record["s"], ";")
	var/obj/path = text2path(fields[1])
	if(!ispath(path, /obj) || !GLOB.ship_structure_tracked[path])
		return
	var/obj_dir = text2num(fields[2])
	var/obj/O
	if(ispath(path, /obj/structure/cable))
		var/obj/structure/cable/cable_path = path
		var/cable_colour = (length(fields) >= 3 && length(fields[3])) ? fields[3] : initial(cable_path.cable_color)
		O = new path(T, cable_colour, length(fields) >= 4 && fields[4] == "1")
	else if(ispath(path, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/P = new path(T)
		P.setDir(obj_dir)
		P.set_init_directions()
		var/pipe_layer = length(fields) >= 3 ? text2num(fields[3]) : PIPING_LAYER_DEFAULT
		var/pipe_colour = (length(fields) >= 4 && length(fields[4])) ? fields[4] : null
		P.on_construction(pipe_colour, pipe_layer || PIPING_LAYER_DEFAULT)
		O = P
	else if(ispath(path, /obj/structure/window) || ispath(path, /obj/machinery/door/window))
		O = new path(T, obj_dir)
	else
		O = new path(T)
		if(obj_dir)
			O.setDir(obj_dir)
	if(QDELETED(O))
		return
	if(istype(O, /obj/structure/girder) && length(fields) >= 3)
		var/obj/structure/girder/G = O
		G.state = text2num(fields[3])
		G.update_appearance()
	else if(istype(O, /obj/structure/window) && length(fields) >= 3 && fields[3] == "0")
		var/obj/structure/window/W = O
		W.anchored = FALSE
		W.state = WINDOW_OUT_OF_FRAME
		W.air_update_turf()
	set_integrity(O, record["i"])
	return O

/// Maszyny (poza rurami) odtwarzamy razem w trybie ładowania mapy: kierunek, przesunięcie i zmienne
/// z zapisu są ustawione przed Initialize(mapload = TRUE), więc APC dostaje ogniwo i terminal,
/// a przyciski, kamery i drzwi swoje id, tak jak przy wczytaniu szablonu. pending = list(list(turf, rekord), ...)
/datum/ship_structure/proc/create_machines(list/pending)
	var/list/created = list()
	var/list/created_records = list()
	SSatoms.map_loader_begin()
	for(var/list/item in pending)
		var/turf/T = item[1]
		var/list/record = item[2]
		var/list/fields = splittext(record["s"], ";")
		var/obj/machinery/path = text2path(fields[1])
		if(!ispath(path, /obj/machinery) || !GLOB.ship_structure_tracked[path])
			continue
		// Terminal APC powstaje razem z APC
		if(ispath(path, /obj/machinery/power/terminal) && (locate(/obj/machinery/power/terminal) in T))
			continue
		var/obj/machinery/M = new path(T)
		var/machine_dir = isnum(record["dir"]) ? record["dir"] : text2num(fields[2])
		if(machine_dir)
			M.dir = machine_dir
		if(isnum(record["px"]))
			M.pixel_x = record["px"]
		if(isnum(record["py"]))
			M.pixel_y = record["py"]
		if(istype(M, /obj/machinery/atmospherics) && length(fields) >= 4)
			var/obj/machinery/atmospherics/A = M
			A.piping_layer = text2num(fields[3]) || PIPING_LAYER_DEFAULT
			if(length(fields[4]))
				A.pipe_color = fields[4]
		var/list/saved_vars = record["v"]
		if(islist(saved_vars))
			for(var/var_name in saved_vars)
				if((var_name in GLOB.ship_structure_machine_vars) && (var_name in M.vars))
					M.vars[var_name] = saved_vars[var_name]
		created += M
		created_records += list(record)
	SSatoms.map_loader_stop()
	SSatoms.InitializeAtoms(created)

	for(var/i in 1 to length(created))
		var/obj/machinery/M = created[i]
		if(QDELETED(M))
			continue
		var/list/record = created_records[i]
		set_parts(M, record["p"])
		if(istype(M, /obj/machinery/atmospherics))
			connect_atmos(M)
		set_integrity(M, record["i"])
	for(var/obj/machinery/power/P in created)
		if(!QDELETED(P) && !P.powernet)
			P.connect_to_network()
	for(var/obj/machinery/power/apc/APC in created)
		if(APC.terminal && !APC.terminal.powernet)
			APC.terminal.connect_to_network()
	return created

/// Wymienia części maszyny na zapisane (ulepszenia), jeśli różnią się od domyślnych
/datum/ship_structure/proc/set_parts(obj/machinery/M, list/part_types)
	if(!islist(part_types) || !length(part_types) || !islist(M.component_parts))
		return
	var/list/current = list()
	for(var/obj/item/part in M.component_parts)
		current += "[part.type]"
	if(ship_structure_hash(current) == ship_structure_hash(part_types))
		return
	var/list/paths = list()
	for(var/part_type in part_types)
		var/obj/item/part_path = text2path(part_type)
		if(!ispath(part_path, /obj/item))
			return // nieznana część (zmiana kodu): zostają domyślne
		paths += part_path
	for(var/obj/item/old_part in M.component_parts)
		qdel(old_part)
	M.component_parts = list()
	for(var/obj/item/part_path as anything in paths)
		var/obj/item/part = new part_path(M)
		M.component_parts += part
		if(istype(part, /obj/item/circuitboard))
			M.circuit = part
	M.RefreshParts()

/// Podłącza maszynę atmosferyczną do sąsiednich rur tak jak przy budowie przez gracza
/datum/ship_structure/proc/connect_atmos(obj/machinery/atmospherics/A)
	A.atmos_init()
	for(var/obj/machinery/atmospherics/node in A.pipeline_expansion())
		node.atmos_init()
		node.add_member(A)
	SSair.add_to_rebuild_queue(A)

/**
 * Nakłada zapisane zmiany na świeżą mapę i sprząta skutki (pianka, rzeczy na ścianach).
 * Zwraca list(nałożone pola, pominięte pola).
 */
/datum/ship_structure/proc/apply(list/delta)
	var/list/applied = list()
	var/list/breach_candidates = list()
	var/list/opened = list()
	var/list/closed = list()
	var/list/pending_machines = list()
	/// Pola, na których zapis postawił gęsty obiekt
	var/list/blocked = list()
	var/skipped = 0
	cache_shuttle_areas()
	for(var/key in delta)
		var/list/record = delta[key]
		var/turf/T = turf_for(key)
		if(!islist(record) || !T || skip_turf(T))
			skipped++
			continue
		var/list/objs = tracked_objs(T)
		var/list/sigs = list()
		for(var/obj/O as anything in objs)
			sigs += ship_structure_obj_sig(O)
		var/current_turf = (!length(sigs) && isspaceturf(T)) ? SHIP_STRUCTURE_SPACE : ship_structure_turf_sig(T)
		if(current_turf != record["ot"] || ship_structure_hash(sigs) != record["oh"])
			skipped++ // na mapie stoi tu teraz coś innego niż przy zapisie
			continue

		var/was_space = isspaceturf(T)
		var/was_closed = isclosedturf(T)
		for(var/sig in record["r"])
			var/index = sigs.Find(sig)
			if(!index)
				continue
			var/obj/O = objs[index]
			sigs.Cut(index, index + 1)
			objs.Cut(index, index + 1)
			qdel(O)
		if(istext(record["t"]))
			T = set_turf(T, record["t"])
		for(var/list/damage in record["d"])
			if(length(damage) < 2)
				continue
			var/index = sigs.Find(damage[1])
			if(!index)
				continue
			var/obj/O = objs[index]
			sigs.Cut(index, index + 1)
			objs.Cut(index, index + 1)
			set_integrity(O, damage[2])
			if(length(damage) >= 3 && isnum(damage[3]))
				O.setDir(damage[3])
		for(var/list/added in record["a"])
			if(!istext(added["s"]))
				continue
			var/obj/added_path = text2path(splittext(added["s"], ";")[1])
			if(ispath(added_path, /obj/machinery) && !ispath(added_path, /obj/machinery/atmospherics/pipe))
				pending_machines += list(list(T, added))
			else
				var/obj/created = create_obj(T, added)
				if(created?.density)
					blocked[T] = TRUE

		applied += T
		if(!was_space)
			breach_candidates += T
		if(was_closed && !isclosedturf(T))
			opened += T
		else if(!was_closed && isclosedturf(T))
			closed += T
		CHECK_TICK

	// Maszyny po turfach i konstrukcjach, a przed pianką (śluzy uszczelniają przejścia)
	for(var/obj/machinery/M as anything in create_machines(pending_machines))
		if(!QDELETED(M) && M.density && isturf(M.loc))
			blocked[M.loc] = TRUE
	var/list/mount_turfs = list()
	for(var/turf/T as anything in closed)
		mount_turfs |= evict_contents(T)
	// Pola, na których zapis postawił coś gęstego, a mapa coś tam położyła (np. kanister pod przeniesionym automatem)
	for(var/turf/T as anything in blocked)
		if(T in closed)
			continue
		mount_turfs |= evict_contents(T, only_dense = !ship_structure_turf_sealed(T))
	patch_breaches(breach_candidates)
	for(var/turf/T as anything in opened)
		mount_turfs |= T
		for(var/dir in GLOB.cardinals)
			var/turf/neighbour = get_step(T, dir)
			if(neighbour)
				mount_turfs |= neighbour
	fix_wallmounts(mount_turfs, opened)
	return list(applied, skipped)

/// Pole jest częścią kadłuba: leży w obszarze statku albo graniczy z otwartym polem statku
/datum/ship_structure/proc/is_hull_turf(turf/T)
	if(is_ship_area(T.loc))
		return TRUE
	for(var/dir in GLOB.cardinals)
		var/turf/neighbour = get_step(T, dir)
		if(neighbour && !isclosedturf(neighbour) && is_ship_area(neighbour.loc))
			return TRUE
	return FALSE

/// Łata pianką dziury w kadłubie: kosmos -> podłoga z pianki, nieszczelne pole przy kosmosie -> ściana z pianki
/datum/ship_structure/proc/patch_breaches(list/turfs)
	. = 0
	for(var/turf/T as anything in turfs)
		if(!is_hull_turf(T))
			continue
		if(isspaceturf(T))
			T = T.PlaceOnTop(/turf/open/floor/plating/foam)
			.++
		if(!isopenturf(T) || (locate(/obj/structure/foamedmetal) in T))
			continue
		for(var/dir in GLOB.cardinals)
			var/turf/neighbour = get_step(T, dir)
			if(!neighbour || !isspaceturf(neighbour) || !T.CanAtmosPass(neighbour))
				continue
			new /obj/structure/foamedmetal(T)
			.++
			break

/// Rzeczy z mapy, które wylądowały w nowej ścianie, idą na sąsiednie otwarte pole. Zwraca pola, na które trafiły.
/// only_dense = TRUE: pole nie jest zamknięte, tylko zapis postawił na nim coś gęstego (maszynę), więc odchodzą
/// tylko gęste rzeczy i moby, a przedmioty mogą zostać pod maszyną jak w zwykłej grze.
/datum/ship_structure/proc/evict_contents(turf/T, only_dense = FALSE)
	. = list()
	for(var/atom/movable/AM as anything in T.contents.Copy())
		if(isobj(AM))
			var/obj/O = AM
			// Instalacje pod podłogą i to, co jest częścią struktury, zostaje na miejscu, jak przy budowie przez gracza
			if(is_structure_part(O) || iseffect(O) || istype(O, /obj/machinery/atmospherics) || istype(O, /obj/structure/disposalpipe) \
				|| istype(O, /obj/machinery/power/terminal) || istype(O, /obj/machinery/power/apc))
				continue
			if(only_dense && !O.density)
				continue
		else if(!ismob(AM))
			continue
		var/turf/destination = free_turf_near(T)
		if(!destination)
			return
		AM.forceMove(destination)
		. |= destination

/// Obiekt jest częścią struktury statku (zapisywany typ; maszyna tylko przykręcona)
/datum/ship_structure/proc/is_structure_part(obj/O)
	return GLOB.ship_structure_tracked[O.type] && (O.anchored || !istype(O, /obj/machinery))

/// Pole, na które można coś odstawić: otwarte i bez gęstych obiektów
/datum/ship_structure/proc/is_free_turf(turf/T)
	if(!T || isclosedturf(T) || T.density || isspaceturf(T))
		return FALSE
	for(var/obj/O in T)
		if(O.density)
			return FALSE
	return TRUE

/// Najbliższe wolne pole: najpierw sąsiednie w linii prostej, potem dalej (do SHIP_STRUCTURE_MOUNT_RANGE)
/datum/ship_structure/proc/free_turf_near(turf/T)
	for(var/dir in GLOB.cardinals)
		var/turf/neighbour = get_step(T, dir)
		if(is_free_turf(neighbour))
			return neighbour
	for(var/distance in 1 to SHIP_STRUCTURE_MOUNT_RANGE)
		for(var/turf/candidate in orange(distance, T))
			if(get_dist(T, candidate) == distance && is_free_turf(candidate))
				return candidate

/// Przewiesza rzeczy ze zburzonych ścian. opened = pola, na których stała ściana z mapy.
/datum/ship_structure/proc/fix_wallmounts(list/turfs, list/opened)
	for(var/turf/T as anything in turfs)
		for(var/obj/O in T)
			if(!GLOB.ship_structure_wallmounts[O.type] || !O.anchored)
				continue
			var/mount_dir = ship_structure_mount_dir(O)
			if(!mount_dir)
				// Wisiał na samej ścianie (np. tabliczka bez przesunięcia): idzie na sąsiednią ścianę
				if((T in opened) && !isclosedturf(T))
					for(var/dir in GLOB.cardinals)
						var/turf/wall = get_step(T, dir)
						if(isclosedturf(wall))
							O.forceMove(wall)
							break
				continue
			if(!isclosedturf(T) && isclosedturf(get_step(T, mount_dir)))
				continue // jego ściana stoi
			if(!isclosedturf(T) && rehang_in_place(O, mount_dir))
				continue
			if(istype(O, /obj/machinery/power/apc))
				restore_wall(get_step(T, mount_dir)) // APC nie zmienia pola (terminal pod spodem)
				continue
			relocate_mount(O, mount_dir)

/datum/ship_structure/proc/rehang_in_place(obj/O, mount_dir)
	var/turf/T = O.loc
	for(var/dir in GLOB.cardinals)
		if(isclosedturf(get_step(T, dir)))
			ship_structure_hang(O, mount_dir, dir)
			return TRUE
	return FALSE

/datum/ship_structure/proc/relocate_mount(obj/O, mount_dir)
	var/turf/origin = O.loc
	var/area/origin_area = get_area(origin)
	for(var/distance in 1 to SHIP_STRUCTURE_MOUNT_RANGE)
		for(var/turf/candidate in orange(distance, origin))
			if(get_dist(origin, candidate) != distance || isclosedturf(candidate) || candidate.density || get_area(candidate) != origin_area)
				continue
			var/best_dir = isclosedturf(get_step(candidate, mount_dir)) ? mount_dir : 0
			if(!best_dir)
				for(var/dir in GLOB.cardinals)
					if(isclosedturf(get_step(candidate, dir)))
						best_dir = dir
						break
			if(!best_dir)
				continue
			O.forceMove(candidate)
			ship_structure_hang(O, mount_dir, best_dir)
			return TRUE
	return FALSE

/// Przywraca ścianę z mapy na polu (używane dla APC, które nie ma gdzie zawisnąć)
/datum/ship_structure/proc/restore_wall(turf/T)
	if(!T || isclosedturf(T))
		return
	var/list/entry = baseline?[key_for(T)]
	if(!entry)
		return
	set_turf(T, entry[1])

/// Wczytuje zapis i nakłada go na mapę. Wymaga zrobionego baseline.
/datum/ship_structure/proc/load()
	if(!save_path || !fexists(save_path))
		last_report = "brak zapisu, statek prosto z mapy"
		return
	var/list/data
	try
		data = json_decode(rustg_file_read(save_path))
	catch(var/exception/error)
		log_game("Ship structure: couldn't read [save_path] ([error]), starting from the map")
		last_report = "zapis uszkodzony, statek prosto z mapy"
		return
	if(!islist(data) || data["version"] != SHIP_STRUCTURE_VERSION || !islist(data["turfs"]))
		log_game("Ship structure: [save_path] has an unknown format, starting from the map")
		last_report = "nieznany format zapisu, statek prosto z mapy"
		return
	rounds = isnum(data["rounds"]) ? data["rounds"] : 0
	var/list/result = apply(data["turfs"])
	var/list/applied = result[1]
	last_report = "rundy w zapisie: [rounds], odtworzone pola: [length(applied)], pominięte (zmiana mapy): [result[2]]"
	log_game("Ship structure: loaded [save_path], [rounds] rounds, [length(applied)] turfs applied, [result[2]] skipped")

/datum/ship_structure/proc/save()
	if(!save_path || !baseline)
		return
	var/list/delta = diff(baseline, capture(TRUE))
	var/list/data = list(
		"version" = SHIP_STRUCTURE_VERSION,
		"map" = SSmapping.config?.map_name,
		"rounds" = rounds + 1,
		"turfs" = delta,
	)
	rustg_file_write(json_encode(data), save_path)
	log_game("Ship structure: saved [length(delta)] changed turfs to [save_path]")

/datum/ship_structure/proc/wipe(reason)
	skip_save = TRUE
	if(save_path && fexists(save_path))
		fdel(save_path)
	log_game("Ship structure: save [save_path] wiped ([reason])")

/datum/ship_structure/proc/on_round_end()
	if(skip_save)
		log_game("Ship structure: saving skipped for this round")
		return
	if(SSticker.news_report == SHIP_DESTROYED || QDELETED(SSstar_system.main_overmap))
		wipe("the ship was destroyed")
		return
	save()

/**
 * Zdjęcie mapy i wczytanie zapisu: po atomach, atmosferze, zadokowanych promach (SSshuttle, -21) i minor mappingu (-40),
 * żeby wszystko, co stawia turfy na starcie, było już w zdjęciu; przed holomapami (-68), żeby widziały zmieniony układ.
 * Zapis idzie razem z resztą trwałych danych w SSpersistence.CollectData().
 */
SUBSYSTEM_DEF(ship_structure)
	name = "Ship Structure"
	flags = SS_NO_FIRE
	init_order = -60
	/// Trwała struktura statku (null = wyłączona w configu albo w testach)
	var/datum/ship_structure/structure

/datum/controller/subsystem/ship_structure/Initialize(start_timeofday)
#ifndef UNIT_TESTS
	if(CONFIG_GET(flag/ship_structure_persistence))
		load_structure()
#endif
	return ..()

/datum/controller/subsystem/ship_structure/proc/load_structure()
	var/list/levels = SSmapping.levels_by_trait(ZTRAIT_STATION)
	if(!length(levels))
		return
	structure = new(levels)
	structure.save_path = "[SHIP_STRUCTURE_DIR][ckey(SSmapping.config.map_path)].json"
	var/started = REALTIMEOFDAY
	structure.baseline = structure.capture()
	var/captured = REALTIMEOFDAY
	// Głosowanie z końca poprzedniej rundy (ship_structure_vote.dm): przewaga „odbuduj” = statek prosto z mapy
	if(structure.consume_last_vote())
		if(fexists(structure.save_path))
			fdel(structure.save_path)
		structure.last_report = "gracze zagłosowali za odbudową, statek prosto z mapy"
		log_game("Ship structure: players voted to rebuild the ship, [structure.save_path] dropped")
	else
		structure.load()
	log_game("Ship structure: map snapshot of [length(structure.baseline)] turfs took [(captured - started) / 10] s, loading the save [(REALTIMEOFDAY - captured) / 10] s")

/datum/controller/subsystem/persistence/CollectData()
	. = ..()
	SSship_structure.structure?.on_round_end()

/// Admin: stan zapisu, pominięcie zapisu tej rundy, skasowanie zapisu
/datum/admins/proc/ship_structure_admin()
	set category = "Server"
	set name = "Ship Structure"
	set desc = "Trwała struktura statku: stan, pominięcie zapisu, reset"
	if(!check_rights(R_SERVER))
		return
	var/datum/ship_structure/structure = SSship_structure.structure
	if(!structure)
		to_chat(usr, "<span class='warning'>Trwała struktura statku jest wyłączona (SHIP_STRUCTURE_PERSISTENCE w game_options.txt).</span>")
		return
	var/toggle = structure.skip_save ? "Zapisz strukturę po tej rundzie" : "Nie zapisuj tej rundy"
	var/choice = tgui_alert(usr, "Zapis: [structure.save_path]\nWczytanie: [structure.last_report] ([structure.last_vote_report])\nZapis po tej rundzie: [structure.skip_save ? "NIE" : "TAK"]", "Struktura statku", list(toggle, "Skasuj zapis", "Anuluj"))
	if(choice == toggle)
		structure.skip_save = !structure.skip_save
		log_admin("[key_name(usr)] set ship structure saving for this round to [structure.skip_save ? "off" : "on"].")
		message_admins("[key_name_admin(usr)] [structure.skip_save ? "wyłącza" : "włącza"] zapis struktury statku po tej rundzie.")
	else if(choice == "Skasuj zapis")
		if(tgui_alert(usr, "Skasować zapis struktury statku? Następna runda zacznie się na statku prosto z mapy. Tego nie da się cofnąć.", "Struktura statku", list("Skasuj", "Anuluj")) != "Skasuj")
			return
		structure.wipe("admin [key_name(usr)]")
		log_admin("[key_name(usr)] wiped the ship structure save.")
		message_admins("[key_name_admin(usr)] kasuje zapis struktury statku. Następna runda zacznie się na statku prosto z mapy.")

#undef SHIP_STRUCTURE_DIR
#undef SHIP_STRUCTURE_VERSION
#undef SHIP_STRUCTURE_SPACE
#undef SHIP_STRUCTURE_MOUNT_RANGE
