/**
 * AQUILA - Trwała struktura statku.
 *
 * Ściany, podłogi (z uszkodzeniami), okna, kraty, dźwigary, kratownice, drzwi, kable, rury i maszyny
 * zostają między rundami tak, jak zostawiła je załoga: zbudowane, przeniesione, obrócone, przykręcone, ulepszone i zniszczone.
 * Przedmioty wczytują się z mapy jak zwykle (szafki i automaty się uzupełniają). Maszyny krytyczne dla celów
 * antagonistów i misji okrętu zawsze stoją tak, jak na mapie.
 *
 * Zapis to różnica względem świeżo wczytanej mapy:
 * - SSship_structure w Initialize() robi zdjęcie poziomów statku (baseline) i dopiero potem nakłada zapis,
 * - na koniec rundy CollectData() porównuje stan świata z tym zdjęciem i zapisuje tylko zmienione pola.
 * Każde pole zapisu pamięta, co stało na nim na mapie. Jeśli mapa w repo się zmieniła (albo pole
 * wylosowało inny wariant), wpis jest pomijany, więc poprawki mapperów nie gryzą się z zapisem.
 * Pola zajęte przez prom w którymkolwiek zdjęciu nie są porównywane wcale.
 *
 * Maszyny i rury są odtwarzane jak przy wczytywaniu mapy: zmienne z zapisu ustawia preloader przed New(),
 * a sieci rur na zmienionych polach są budowane od nowa (jak przy szablonie mapy).
 *
 * Po nałożeniu zapisu:
 * - dziury do kosmosu łata spieniony metal (podłoga z pianki i ściana z pianki), tylko tam, gdzie na mapie było szczelnie,
 * - rzeczy wiszące na zburzonej ścianie przechodzą na sąsiednią ścianę (APC bez innej ściany na swoim polu
 *   przywraca swoją ścianę, jeśli nic na niej nie stoi),
 * - rzeczy z mapy, które wylądowały w nowo postawionej ścianie albo pod nową maszyną, są wypychane na sąsiednie pole.
 * Zniszczenie statku kasuje zapis. Głosowanie po rundzie (ship_structure_vote.dm) może kazać zacząć na nowym statku.
 * Admin może wyłączyć zapis rundy albo skasować zapis (Server -> Ship Structure).
 *
 * Zabezpieczenia:
 * - błąd przy jednym polu nie przerywa nakładania reszty; zapis, przy którym wystąpiły błędy, idzie do kwarantanny (.broken),
 * - przed nadpisaniem zapisu zostaje kopia (.bak), z której wczytujemy, gdy główny plik jest uszkodzony,
 * - gdy plik mapy w repo się zmienił, rury i kable zostają z mapy (inaczej przebudowa załogi urywa się na zmienionych polach),
 * - pola losowego pokoju (np. silnika) przyjmują zapis tylko przy tym samym wylosowanym wariancie,
 * - klatka magnesu (asteroidy, wraki) nie jest zapisywana: każda runda zaczyna się z pustą klatką.
 */

#define SHIP_STRUCTURE_DIR "data/ship_structure/"
#define SHIP_STRUCTURE_VERSION 2
/// Jaka część pól statku zamieniona w kosmos oznacza mocno zniszczony statek (remis w głosowaniu = nowy statek)
#define SHIP_STRUCTURE_HEAVY_DAMAGE 0.1
/// Sygnatura „pustego kosmosu”: takich pól nie trzymamy w zdjęciu
#define SHIP_STRUCTURE_SPACE ""
/// Znacznik pola zajętego przez prom: takie pole nie jest porównywane
#define SHIP_STRUCTURE_SHUTTLE "shuttle"
/// Jak daleko (w polach) szukamy nowej ściany dla rzeczy wiszącej albo wolnego pola dla wypychanej rzeczy
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
	// Cel sabotażu, a event kryształów usuwa ją na czas trwania
	/obj/machinery/power/supermatter_crystal,
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
	/obj/machinery/iv_drip,
	/obj/machinery/syndicatebomb,
	/obj/machinery/doomsday_device,
	/obj/machinery/field/containment,
	/obj/machinery/shieldwall,
	/obj/machinery/power/singularity_beacon,
	/obj/machinery/abductor,
	// Generator Tesli/osobliwości znika, gdy powstaje kula; zapisany jako usunięty kasowałby go w następnej rundzie z tym samym silnikiem
	/obj/machinery/the_singularitygen,
	// Osłonę tworzy wieżyczka w Initialize; zapisana dawałaby drugą, osieroconą osłonę co rundę
	/obj/machinery/porta_turret_cover,
	// Cel gangu: bez swojego gangu w następnej rundzie to tylko przeszkoda
	/obj/machinery/dominator
	)

/// Maszyny, które losują id w Initialize: id nie trafia do sygnatury, inaczej pole z mapy różniłoby się co rundę
/proc/ship_structure_random_id_types()
	return list(
		/obj/machinery/computer/teleporter
	)

GLOBAL_LIST_INIT(ship_structure_random_id, typecacheof(ship_structure_random_id_types()))

/// Obiekty tworzone jak przy wczytywaniu mapy (preloader i Initialize(mapload)): maszyny i rury zsypu
/proc/ship_structure_preloaded(path)
	return ispath(path, /obj/machinery) || ispath(path, /obj/structure/disposalpipe) || ispath(path, /obj/structure/disposaloutlet)

/// Instalacje przebiegające przez wiele pól (rury, kable, zsyp): po zmianie pliku mapy zostają z mapy
/proc/ship_structure_is_installation(path)
	return ispath(path, /obj/machinery/atmospherics) || ispath(path, /obj/structure/cable) \
		|| ispath(path, /obj/structure/disposalpipe) || ispath(path, /obj/structure/disposaloutlet)

GLOBAL_LIST_INIT(ship_structure_critical, typecacheof(ship_structure_critical_types()))

/// Pola wylosowanych pokoi (np. silników): pole => room_id wariantu, który się na nim wczytał
GLOBAL_LIST_EMPTY(ship_structure_room_turfs)

/datum/map_template/random_room/stationinitload(turf/T, centered = FALSE)
	. = ..()
	ship_structure_mark_room(src, T, centered)

/datum/map_template/random_room/load(turf/T, centered = FALSE, init_atmos = TRUE, finalize = TRUE)
	. = ..()
	if(.)
		ship_structure_mark_room(src, T, centered)

/proc/ship_structure_mark_room(datum/map_template/random_room/template, turf/T, centered)
	if(!T)
		return
	// Wariant to szablon razem z treścią pliku: poprawka mappera w szablonie też odcina stary zapis tych pól
	var/room_key = template.room_id
	if(istext(template.mappath) && fexists(template.mappath))
		room_key = "[template.room_id]:[rustg_hash_file(RUSTG_HASH_MD5, template.mappath)]"
	for(var/turf/room_turf as anything in template.get_affected_turfs(T, centered))
		GLOB.ship_structure_room_turfs[room_turf] = room_key

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
		/obj/structure/foamedmetal,
		/obj/structure/disposalpipe,
		/obj/structure/disposaloutlet
	)) -typecacheof(ship_structure_critical_types()) - typecacheof(ship_structure_untracked_types())
	return result

/// Zmienne maszyn, które przenosimy na odtworzoną maszynę (powiązania, sieci, dostęp, stan instalacji)
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
	"areastring",
	// Odwrócone filtry i miksery, sieci rur bluespace, kolor i warstwa rur kanalizacji
	"flipped",
	"bluespace_network_name",
	"duct_color",
	"duct_layer"
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
	/obj/machinery/camera,
	/obj/item/radio/intercom,
	/obj/structure/sign,
	/obj/structure/extinguisher_cabinet,
	/obj/structure/fireaxecabinet,
	/obj/structure/noticeboard,
	/obj/structure/mirror,
	/obj/structure/reagent_dispensers/peppertank
)) - typecacheof(/obj/machinery/light/floor))

/// Turfy, których gracz nie zbuduje ani nie usunie (np. ściany areny heretyka): zmiana na nie nie trafia do zapisu
/proc/ship_structure_indestructible_turf(path)
	return ispath(path, /turf/closed/indestructible) || ispath(path, /turf/open/indestructible)

/// Sygnatura pola: typ turfa, jego uszkodzenia i materiał ściany albo podłogi z materiału
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
	var/materials_field = ship_structure_materials_field(T)
	if(materials_field)
		. += ";[materials_field]"

/// Ściana i podłoga z materiału biorą materiał z płytki albo arkusza, nie z typu, więc zapis go pamięta
/proc/ship_structure_has_materials(turf/T)
	return istype(T, /turf/open/floor/material) || istype(T, /turf/closed/wall/material)

/**
 * Pole materiałów w sygnaturze: "m=/datum/material/gold:500" (kilka materiałów po przecinku, posortowane),
 * "mt=" dla materiału z metalgenu (sam wygląd, bez zwrotu arkuszy).
 */
/proc/ship_structure_materials_field(turf/T)
	if(!ship_structure_has_materials(T) || !length(T.custom_materials))
		return null
	var/list/entries = list()
	for(var/datum/material/material as anything in T.custom_materials)
		entries += "[material.type]:[T.custom_materials[material]]"
	sortTim(entries, GLOBAL_PROC_REF(cmp_text_asc))
	return "[HAS_TRAIT(T, TRAIT_MATERIALS_TRANSMUTED) ? "mt" : "m"]=[entries.Join(",")]"

/// Nakłada na pole materiały z sygnatury (pole „m=” albo „mt=”), jeśli różnią się od obecnych
/proc/ship_structure_apply_materials(turf/T, list/fields)
	if(!ship_structure_has_materials(T))
		return
	var/wanted_field
	for(var/field in fields)
		if(findtext(field, "m=", 1, 3) || findtext(field, "mt=", 1, 4))
			wanted_field = field
			break
	if(!wanted_field || wanted_field == ship_structure_materials_field(T))
		return
	var/transmuted = findtext(wanted_field, "mt=", 1, 4)
	var/list/materials = list()
	for(var/entry in splittext(copytext(wanted_field, transmuted ? 4 : 3), ","))
		var/list/parts = splittext(entry, ":")
		if(length(parts) != 2)
			continue
		var/material_type = text2path(parts[1])
		var/amount = text2num(parts[2])
		if(ispath(material_type, /datum/material) && amount > 0)
			materials[material_type] = amount
	if(!length(materials))
		return
	if(transmuted)
		ADD_TRAIT(T, TRAIT_MATERIALS_TRANSMUTED, METALGEN_TRAIT)
	else
		REMOVE_TRAIT(T, TRAIT_MATERIALS_TRANSMUTED, METALGEN_TRAIT)
	T.set_custom_materials(materials)

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
	// poza wiatrołapami i drzwiami przeciwpożarowymi, które stoją na krawędzi pola.
	// id rozróżnia dwie takie same maszyny na jednym polu (np. przyciski różnych drzwi).
	if(istype(O, /obj/machinery) && !istype(O, /obj/machinery/door/window) && !istype(O, /obj/machinery/door/firedoor))
		if(GLOB.ship_structure_random_id[O.type])
			return "[O.type];0"
		var/identity = ("id" in O.vars) ? O.vars["id"] : null
		if(isnull(identity) && ("id_tag" in O.vars))
			identity = O.vars["id_tag"]
		return (istext(identity) || isnum(identity)) ? "[O.type];0;[identity]" : "[O.type];0"
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

/// Nazwy zmiennych zapisywanych dla danej maszyny
/proc/ship_structure_var_names(obj/machinery/M)
	. = GLOB.ship_structure_machine_vars
	// Emiter i generator pola: przykręcony i przyspawany (state) to część rozstawionego silnika
	if(istype(M, /obj/machinery/power/emitter) || istype(M, /obj/machinery/field/generator))
		. = . + "state"

/// Zmienne i części maszyny, które przenosimy do następnej rundy: list("v" = zmienne, "p" = części)
/proc/ship_structure_machine_payload(obj/machinery/M)
	. = list()
	var/list/saved_vars = list()
	for(var/var_name in ship_structure_var_names(M))
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
	// Części (płytka i ulepszenia), z których złożono maszynę; stosy z ilością ("typ:ilość")
	if(length(M.component_parts))
		var/list/parts = list()
		for(var/obj/item/part in M.component_parts)
			if(istype(part, /obj/item/stack))
				var/obj/item/stack/stack = part
				parts += "[part.type]:[stack.amount]"
			else
				parts += "[part.type]"
		if(length(parts))
			.["p"] = parts

/// Stan obiektu porównywany z mapą: "wytrzymałość;kierunek;przykręcony;hash zmiennych;hash części"
/proc/ship_structure_obj_state(obj/O)
	var/vars_hash = ""
	var/parts_hash = ""
	if(istype(O, /obj/machinery) && !istype(O, /obj/machinery/atmospherics))
		var/list/payload = ship_structure_machine_payload(O)
		if(payload["v"])
			vars_hash = md5(json_encode(payload["v"]))
		if(payload["p"])
			parts_hash = md5(json_encode(payload["p"]))
	return "[round(O.obj_integrity, 1)];[O.dir];[O.anchored ? 1 : 0];[vars_hash];[parts_hash]"

/// Pole zamknięte jak ściana: pełne okno albo ściana z pianki (wtedy odchodzą z niego także przedmioty)
/proc/ship_structure_turf_sealed(turf/T)
	if(locate(/obj/structure/foamedmetal) in T)
		return TRUE
	for(var/obj/structure/window/W in T)
		if(W.fulltile)
			return TRUE
	return FALSE

/// Pole przepuszcza powietrze do kosmosu (sąsiedni kosmos albo kosmos pod otwartą przestrzenią)
/proc/ship_structure_open_to_space(turf/T)
	if(isspaceturf(T))
		return TRUE
	if(!isopenturf(T))
		return FALSE
	for(var/dir in GLOB.cardinals)
		var/turf/neighbour = get_step(T, dir)
		if(neighbour && isspaceturf(neighbour) && T.CanAtmosPass(neighbour))
			return TRUE
	if(istype(T, /turf/open/openspace))
		var/turf/below = SSmapping.get_turf_below(T)
		if(!below || isspaceturf(below))
			return TRUE
	return FALSE

/// Kierunek ściany, na której wisi obiekt, albo 0
/proc/ship_structure_mount_dir(obj/O)
	if(!GLOB.ship_structure_wallmounts[O.type] || !O.anchored)
		return 0
	if(istype(O, /obj/machinery/light))
		return O.dir
	// Kamera patrzy od ściany, na której wisi
	if(istype(O, /obj/machinery/camera))
		return (O.dir in GLOB.cardinals) ? turn(O.dir, 180) : 0
	if(abs(O.pixel_y) >= 16 && abs(O.pixel_y) >= abs(O.pixel_x))
		return O.pixel_y > 0 ? NORTH : SOUTH
	if(abs(O.pixel_x) >= 16)
		return O.pixel_x > 0 ? EAST : WEST
	return 0

/// Przewiesza obiekt ze ściany old_dir na ścianę new_dir (kierunek i przesunięcie obracają się razem)
/proc/ship_structure_hang(obj/O, old_dir, new_dir)
	if(istype(O, /obj/machinery/light))
		O.setDir(new_dir)
	else if(istype(O, /obj/machinery/camera))
		O.setDir(turn(new_dir, 180))
	else
		if(old_dir != new_dir)
			O.setDir(turn(O.dir, dir2angle(old_dir) - dir2angle(new_dir)))
		var/offset = max(abs(O.pixel_x), abs(O.pixel_y))
		O.pixel_x = (new_dir & EAST) ? offset : ((new_dir & WEST) ? -offset : 0)
		O.pixel_y = (new_dir & NORTH) ? offset : ((new_dir & SOUTH) ? -offset : 0)
		O.paradise_wall_place() // przesunięcie i kierunek dla nowej strony ściany (urządzenia 32x32 mają różne odległości na każdej stronie)
	O.update_appearance()

/datum/ship_structure
	/// Poziomy statku w stałej kolejności; klucze pól używają indeksu z tej listy, nie numeru z
	var/list/z_levels
	/// list(x1, y1, x2, y2) albo null = cały poziom (testy używają małego bloku)
	var/list/bounds
	/// Zdjęcie świeżo wczytanej mapy, kształt jak w capture()
	var/list/baseline
	/// Plik zapisu albo null (testy)
	var/save_path
	/// Ile rund ma już ten zapis
	var/rounds = 0
	/// TRUE = ta runda nie nadpisze zapisu (admin)
	var/skip_save = FALSE
	/// TRUE = zapis tej rundy już powstał (koniec rundy)
	var/saved_this_round = FALSE
	/// Testy: każde pole liczy się jako wnętrze statku
	var/force_ship_area = FALSE
	/// Podsumowanie ostatniego wczytania dla admina
	var/last_report = "brak"
	/// Obszary promów (odświeżane przy każdym zdjęciu i wczytaniu)
	var/list/shuttle_areas
	/// Pola klatek magnesu (odświeżane razem z obszarami promów)
	var/list/cage_turfs
	/// Ile pól nie dało się nałożyć przez błąd (runtime) przy ostatnim wczytaniu
	var/load_errors = 0
	/// TRUE = plik mapy zmienił się od zapisu: zmiany rur i kabli są pomijane
	var/keep_map_installations = FALSE
	/// TRUE = zapis pamięta wylosowane pokoje, więc pola pokoju sprawdzamy z bieżącym wariantem
	var/check_rooms = FALSE
	/// TRUE = statek skończył rundę mocno zniszczony (remis albo brak głosów = nowy statek)
	var/heavy_damage = FALSE

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
	if(isshuttleturf(T))
		return TRUE
	// Klatka magnesu: asteroida albo wrak to nie struktura statku, następna runda zaczyna z pustą klatką
	if(cage_turfs?[T] || istype(T.loc, /area/space/shipbreak))
		return TRUE
	return shuttle_areas?[T.loc]

/// Odświeża listę obszarów wszystkich promów (część promów NSV nie ma obszarów /area/shuttle) i pól klatek magnesu
/datum/ship_structure/proc/cache_shuttle_areas()
	shuttle_areas = list()
	for(var/obj/docking_port/mobile/port as anything in SSshuttle.mobile)
		for(var/area/A as anything in port.shuttle_areas)
			shuttle_areas[A] = TRUE
	cage_turfs = list()
	for(var/obj/machinery/computer/ship/mineral_magnet/magnet in GLOB.machines)
		for(var/turf/T as anything in magnet.get_cage_turfs())
			cage_turfs[T] = TRUE

/datum/ship_structure/proc/is_ship_area(area/A)
	if(force_ship_area)
		return TRUE
	return A && !istype(A, /area/space) && !istype(A, /area/shuttle)

/// Obiekt jest częścią struktury statku (zapisywany typ, który gracz może zmienić)
/datum/ship_structure/proc/is_structure_part(obj/O)
	return GLOB.ship_structure_tracked[O.type] && !(O.resistance_flags & INDESTRUCTIBLE)

/// Obiekty struktury na polu. Duża maszyna (np. działo 3x3) jest w zawartości każdego zajętego pola,
/// ale liczy się tylko na swoim polu (loc), inaczej przeniesiona powstałaby na każdym z nich.
/datum/ship_structure/proc/tracked_objs(turf/T)
	. = list()
	for(var/obj/O in T)
		if(O.loc == T && !QDELETED(O) && is_structure_part(O))
			. += O

/// Kierunek maszyny jest stanem do zapisania (obrót), a nie częścią sygnatury.
/// Nie dotyczy drzwi (obracają się same), instalacji atmosferycznej (kierunek w sygnaturze) i rzeczy na ścianach (przewiesza je load).
/proc/ship_structure_dir_is_state(obj/O)
	return istype(O, /obj/machinery) && !istype(O, /obj/machinery/door) && !istype(O, /obj/machinery/atmospherics) && !GLOB.ship_structure_wallmounts[O.type]

/**
 * Zdjęcie struktury: klucz pola -> list(sygnatura turfa, sygnatury obiektów, stany obiektów)
 * albo SHIP_STRUCTURE_SHUTTLE dla pola zajętego przez prom.
 * with_objects = TRUE dokłada czwarty element z referencjami do obiektów
 * (do zapisu nowych maszyn i zmian; nie trzymać dłużej niż w jednej procedurze).
 */
/datum/ship_structure/proc/capture(with_objects = FALSE)
	. = list()
	cache_shuttle_areas()
	for(var/turf/T as anything in get_turfs())
		CHECK_TICK
		if(skip_turf(T))
			.[key_for(T)] = SHIP_STRUCTURE_SHUTTLE
			continue
		var/list/objs = tracked_objs(T)
		if(!length(objs) && isspaceturf(T))
			continue
		var/list/sigs = list()
		var/list/states = list()
		for(var/obj/O as anything in objs)
			sigs += ship_structure_obj_sig(O)
			states += ship_structure_obj_state(O)
		var/list/entry = list(ship_structure_turf_sig(T), sigs, states)
		if(with_objects)
			entry += list(objs)
		.[key_for(T)] = entry

/// Dane nowego obiektu potrzebne do odtworzenia go w następnej rundzie
/datum/ship_structure/proc/obj_record(sig, obj/O)
	. = list("s" = sig)
	if(O.obj_integrity < O.max_integrity)
		.["i"] = round(O.obj_integrity, 1)
	if(!istype(O, /obj/machinery))
		return
	var/obj/machinery/M = O
	.["dir"] = M.dir
	.["px"] = M.pixel_x
	.["py"] = M.pixel_y
	.["an"] = M.anchored ? 1 : 0
	var/list/payload = ship_structure_machine_payload(M)
	if(payload["v"])
		.["v"] = payload["v"]
	if(payload["p"])
		.["p"] = payload["p"]

/// Zmiany obiektu z mapy, który został na swoim polu (uszkodzenie, obrót, przykręcenie, zmienne, części)
/datum/ship_structure/proc/kept_record(sig, obj/O, map_state)
	var/list/map_fields = splittext(map_state, ";")
	if(length(map_fields) < 5)
		return
	. = list()
	var/integrity = round(O.obj_integrity, 1)
	if(O.obj_integrity < O.max_integrity && "[integrity]" != map_fields[1])
		.["i"] = integrity
	if(ship_structure_dir_is_state(O) && "[O.dir]" != map_fields[2])
		.["dir"] = O.dir
	if(istype(O, /obj/machinery) && "[O.anchored ? 1 : 0]" != map_fields[3])
		.["an"] = O.anchored ? 1 : 0
	if(istype(O, /obj/machinery) && !istype(O, /obj/machinery/atmospherics))
		var/list/payload = ship_structure_machine_payload(O)
		var/vars_hash = payload["v"] ? md5(json_encode(payload["v"])) : ""
		var/parts_hash = payload["p"] ? md5(json_encode(payload["p"])) : ""
		if(vars_hash != map_fields[4])
			.["v"] = payload["v"] || list()
		// Części liczą się tylko, gdy maszyna miała je już na mapie (niektóre, np. działa, dokładają je po starcie)
		if(length(map_fields[5]) && parts_hash != map_fields[5])
			.["p"] = payload["p"] || list()
	if(!length(.))
		return null
	.["s"] = sig

/// Różnica między zdjęciem mapy a stanem z capture(TRUE): klucz pola -> rekord zmian
/datum/ship_structure/proc/diff(list/old_state, list/new_state)
	. = list()
	for(var/key in old_state | new_state)
		CHECK_TICK
		var/list/old_entry = old_state[key]
		var/list/new_entry = new_state[key]
		// Pole zajęte przez prom w którymkolwiek zdjęciu nie jest porównywane
		if(old_entry == SHIP_STRUCTURE_SHUTTLE || new_entry == SHIP_STRUCTURE_SHUTTLE)
			continue
		var/old_turf = old_entry ? old_entry[1] : SHIP_STRUCTURE_SPACE
		var/list/old_sigs = old_entry ? old_entry[2] : list()
		var/list/old_states = old_entry ? old_entry[3] : list()
		var/new_turf = new_entry ? new_entry[1] : SHIP_STRUCTURE_SPACE
		var/list/new_sigs = new_entry ? new_entry[2] : list()
		var/list/new_objs = new_entry ? new_entry[4] : list()

		var/turf/T = turf_for(key)
		// Turf, którego gracz nie zbuduje ani nie usunie (arena heretyka i podobne), zostaje jak na mapie
		if(T && ship_structure_indestructible_turf(T.type))
			continue

		var/list/removed = old_sigs.Copy()
		var/list/removed_states = old_states.Copy()
		var/list/added = list()
		var/list/kept = list()
		for(var/i in 1 to length(new_sigs))
			var/sig = new_sigs[i]
			var/obj/O = new_objs[i]
			var/index = removed.Find(sig)
			if(!index)
				added += list(obj_record(sig, O))
				continue
			var/map_state = removed_states[index]
			removed.Cut(index, index + 1)
			removed_states.Cut(index, index + 1)
			var/list/changes = kept_record(sig, O, map_state)
			if(changes)
				kept += list(changes)

		if(old_turf == new_turf && !length(removed) && !length(added) && !length(kept))
			continue
		var/list/record = list("ot" = old_turf, "oh" = ship_structure_hash(old_sigs))
		// Pole losowego pokoju pamięta wylosowany wariant
		var/room_id = T ? GLOB.ship_structure_room_turfs[T] : null
		if(room_id)
			record["room"] = room_id
		if(old_turf != new_turf)
			if(new_turf == SHIP_STRUCTURE_SPACE)
				new_turf = T ? "[T.type]" : "[/turf/open/space/basic]"
			record["t"] = new_turf
		if(length(removed))
			record["r"] = removed
		if(length(added))
			record["a"] = added
		if(length(kept))
			record["d"] = kept
		.[key] = record

/**
 * Zmienia turf zgodnie z sygnaturą tak, jak zrobiłaby to gra: budowa kładzie nowy turf na wierzch,
 * a rozbiórka zdejmuje warstwy do turfa, który leży niżej (stos baseturfów zostaje taki jak w grze).
 * Uszkodzenia są ustawiane dokładnie według sygnatury, więc naprawa z poprzedniej rundy też zostaje.
 */
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
		else if(ispath(path, /turf/open/space))
			T = T.ChangeTurf(path)
		else
			var/list/stack = islist(T.baseturfs) ? T.baseturfs : list(T.baseturfs)
			var/depth = 0
			for(var/i in length(stack) to 1 step -1)
				if(stack[i] == path)
					depth = length(stack) - i + 1
					break
			T = depth ? T.ScrapeAway(depth) : T.PlaceOnTop(path)
			if(T.type != path)
				T = T.ChangeTurf(path)
	if(isfloorturf(T))
		var/turf/open/floor/F = T
		var/want_broken = length(fields) >= 3 && fields[2] == "1"
		var/want_burnt = length(fields) >= 3 && fields[3] == "1"
		if((F.broken && !want_broken) || (F.burnt && !want_burnt))
			F.broken = FALSE
			F.burnt = FALSE
			F.icon_state = initial(F.icon_state)
			F.update_appearance()
		if(want_broken)
			F.break_tile()
		if(want_burnt)
			F.burn_tile()
	else if(istype(T, /turf/closed/wall/r_wall))
		var/turf/closed/wall/r_wall/R = T
		var/wanted_state = length(fields) >= 2 ? text2num(fields[2]) : INTACT
		if(R.d_state != wanted_state)
			R.d_state = wanted_state
			R.update_appearance()
	ship_structure_apply_materials(T, fields)
	return T

/datum/ship_structure/proc/set_integrity(obj/O, value)
	if(!isnum(value))
		return
	O.obj_integrity = clamp(value, 1, O.max_integrity)
	O.update_appearance()

/// Tworzy konstrukcję z rekordu tak, jakby zbudował ją gracz (maszyny i rury idą przez create_machines)
/datum/ship_structure/proc/create_obj(turf/T, list/record)
	var/list/fields = splittext(record["s"], ";")
	var/obj/path = text2path(fields[1])
	if(!ispath(path, /obj) || !GLOB.ship_structure_tracked[path] || ship_structure_preloaded(path))
		return
	var/obj_dir = text2num(fields[2])
	var/obj/O
	if(ispath(path, /obj/structure/cable))
		var/obj/structure/cable/cable_path = path
		var/cable_colour = (length(fields) >= 3 && length(fields[3])) ? fields[3] : initial(cable_path.cable_color)
		O = new path(T, cable_colour, length(fields) >= 4 && fields[4] == "1")
	else if(ispath(path, /obj/structure/window))
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

/**
 * Maszyny i rury odtwarzamy razem w trybie ładowania mapy. Kierunek, przesunięcie, przykręcenie i zmienne z zapisu
 * ustawia preloader przed New(), tak jak przy wczytaniu szablonu, więc New() i Initialize(mapload = TRUE)
 * liczą wszystko od właściwych wartości (połączenia rur, terminal i przesunięcie APC, id przycisków).
 * pending = list(list(turf, rekord), ...)
 */
/datum/ship_structure/proc/create_machines(list/pending)
	var/list/created = list()
	var/list/created_records = list()
	// APC tworzy swój terminal w Initialize, więc zapisany terminal na jego polu byłby drugi
	var/list/apc_turfs = list()
	for(var/list/item in pending)
		var/list/item_record = item[2]
		var/obj/machinery/apc_path = text2path(splittext(item_record["s"], ";")[1])
		if(ispath(apc_path, /obj/machinery/power/apc))
			apc_turfs[item[1]] = TRUE

	SSatoms.map_loader_begin()
	for(var/list/item in pending)
		// Błąd przy jednej maszynie nie może zostawić SSatoms w trybie ładowania mapy ani włączonego preloadera
		try
			var/obj/created_obj = create_preloaded(item[1], item[2], apc_turfs)
			if(created_obj)
				created += created_obj
				created_records += list(item[2])
		catch(var/exception/error)
			GLOB.use_preloader = FALSE
			load_errors++
			var/turf/failed_turf = item[1]
			log_runtime("Ship structure: couldn't create [json_encode(item[2])] at [AREACOORD(failed_turf)]: [error] ([error.file]:[error.line])")
	SSatoms.map_loader_stop()
	SSatoms.InitializeAtoms(created)

	for(var/i in 1 to length(created))
		var/obj/O = created[i]
		if(QDELETED(O))
			continue
		var/list/record = created_records[i]
		if(istype(O, /obj/machinery))
			set_parts(O, record["p"])
		set_integrity(O, record["i"])
	return created

/// Tworzy jedną maszynę albo rurę zsypu z rekordu (w trybie ładowania mapy, zmienne przez preloader)
/datum/ship_structure/proc/create_preloaded(turf/T, list/record, list/apc_turfs)
	var/list/fields = splittext(record["s"], ";")
	var/obj/path = text2path(fields[1])
	if(!ship_structure_preloaded(path) || !GLOB.ship_structure_tracked[path])
		return
	if(ispath(path, /obj/machinery/power/terminal) && apc_turfs[T])
		return
	var/list/attributes = list()
	var/machine_dir = isnum(record["dir"]) ? record["dir"] : text2num(fields[2])
	if(machine_dir)
		attributes["dir"] = machine_dir
	if(isnum(record["px"]))
		attributes["pixel_x"] = record["px"]
	if(isnum(record["py"]))
		attributes["pixel_y"] = record["py"]
	if(isnum(record["an"]))
		attributes["anchored"] = record["an"] ? TRUE : FALSE
	if(ispath(path, /obj/machinery/atmospherics) && length(fields) >= 4)
		attributes["piping_layer"] = text2num(fields[3]) || PIPING_LAYER_DEFAULT
		if(length(fields[4]))
			attributes["pipe_color"] = fields[4]
	world.preloader_setup(attributes, path)
	var/obj/created = new path(T)
	GLOB.use_preloader = FALSE
	// Zmienne z zapisu ustawiamy po New(), a przed Initialize() (ten idzie w InitializeAtoms), i tylko te, które typ
	// nadal ma: preloader ustawiałby je na ślepo, a zmienna usunięta z kodu dawałaby runtime w New()
	var/list/saved_vars = record["v"]
	if(islist(saved_vars))
		try
			for(var/var_name in saved_vars)
				if((var_name in (GLOB.ship_structure_machine_vars + "state")) && (var_name in created.vars))
					var/value = saved_vars[var_name]
					created.vars[var_name] = islist(value) ? deepCopyList(value) : value
		catch(var/exception/error)
			// Bez Initialize() maszyna zostałaby na polu w połowie zbudowana
			qdel(created)
			throw error
	return created

/// Wymienia części maszyny na zapisane (ulepszenia), jeśli różnią się od obecnych. Części leżą w nullspace jak przy budowie z ramy.
/datum/ship_structure/proc/set_parts(obj/machinery/M, list/part_types)
	if(!islist(part_types) || !length(part_types) || !islist(M.component_parts))
		return
	var/list/current = list()
	for(var/obj/item/part in M.component_parts)
		if(istype(part, /obj/item/stack))
			var/obj/item/stack/stack = part
			current += "[part.type]:[stack.amount]"
		else
			current += "[part.type]"
	if(ship_structure_hash(current) == ship_structure_hash(part_types))
		return
	var/list/paths = list()
	var/list/amounts = list()
	for(var/part_entry in part_types)
		var/list/part_fields = splittext("[part_entry]", ":")
		var/obj/item/part_path = text2path(part_fields[1])
		if(!ispath(part_path, /obj/item))
			return // nieznana część (zmiana kodu): zostają obecne
		paths += part_path
		amounts += length(part_fields) >= 2 ? max(1, text2num(part_fields[2]) || 1) : 0
	for(var/obj/item/old_part in M.component_parts)
		qdel(old_part)
	M.component_parts = list()
	for(var/i in 1 to length(paths))
		var/obj/item/part_path = paths[i]
		var/obj/item/part = ispath(part_path, /obj/item/stack) ? new part_path(null, amounts[i] || 1) : new part_path(null)
		M.component_parts += part
		if(istype(part, /obj/item/circuitboard))
			M.circuit = part
	M.RefreshParts()

/// Stosuje zmiany obiektu z mapy, który został na swoim polu
/datum/ship_structure/proc/apply_kept(obj/O, list/changes)
	set_integrity(O, changes["i"])
	if(isnum(changes["dir"]))
		O.setDir(changes["dir"])
	if(!istype(O, /obj/machinery))
		return
	var/obj/machinery/M = O
	if(isnum(changes["an"]))
		M.anchored = changes["an"] ? TRUE : FALSE
		if(istype(M, /obj/machinery/power))
			var/obj/machinery/power/P = M
			if(P.anchored)
				P.connect_to_network()
			else
				P.disconnect_from_network()
	var/list/saved_vars = changes["v"]
	if(islist(saved_vars))
		var/list/allowed = ship_structure_var_names(M)
		for(var/var_name in saved_vars)
			if((var_name in allowed) && (var_name in M.vars))
				var/value = saved_vars[var_name]
				M.vars[var_name] = islist(value) ? deepCopyList(value) : value
	set_parts(M, changes["p"])
	M.update_appearance()

/// Pola wokół zmienionego pola, na których leżą końce tych samych rur (sąsiednie i pod/nad)
/datum/ship_structure/proc/atmos_neighbourhood(turf/T)
	. = list(T)
	for(var/dir in GLOB.cardinals)
		var/turf/neighbour = get_step(T, dir)
		if(neighbour)
			. += neighbour
	var/turf/above = SSmapping.get_turf_above(T)
	if(above)
		. += above
	var/turf/below = SSmapping.get_turf_below(T)
	if(below)
		. += below

/**
 * Buduje od nowa sieci rur, które przechodzą przez zmienione pola, tak jak przy szablonie mapy.
 * SSair nie działa w trakcie inicjalizacji, więc po usunięciu rury z mapy jej sieć jest rozbita, a nowe rury
 * nie mają jeszcze sieci; zwykłe łączenie (on_construction) trafiałoby w puste sieci. Gaz przechodzi do nowych sieci.
 */
/datum/ship_structure/proc/rebuild_atmos(list/turfs)
	var/list/machines = list()
	for(var/turf/T as anything in turfs)
		for(var/turf/near as anything in atmos_neighbourhood(T))
			for(var/obj/machinery/atmospherics/A in near)
				if(!QDELETED(A))
					machines[A] = TRUE
	if(!length(machines))
		return
	for(var/obj/machinery/atmospherics/A as anything in machines)
		A.atmos_init()
	for(var/obj/machinery/atmospherics/A as anything in machines)
		if(istype(A, /obj/machinery/atmospherics/pipe))
			var/obj/machinery/atmospherics/pipe/P = A
			if(P.parent && !QDELETED(P.parent))
				qdel(P.parent)
		else if(istype(A, /obj/machinery/atmospherics/components))
			var/obj/machinery/atmospherics/components/C = A
			for(var/datum/pipeline/line in C.parents.Copy())
				if(!QDELETED(line))
					qdel(line)
	for(var/obj/machinery/atmospherics/A as anything in machines)
		if(QDELETED(A))
			continue
		for(var/datum/pipeline/line as anything in A.get_rebuild_targets())
			line.build_pipeline_blocking(A)

/**
 * Nakłada zapisane zmiany na świeżą mapę i sprząta skutki (sieci rur, pianka, rzeczy na ścianach).
 * Zwraca list(liczba nałożonych pól, liczba pominiętych pól).
 */
/datum/ship_structure/proc/apply(list/delta)
	var/applied = 0
	var/skipped = 0
	/// Wspólny stan nakładania pól (listy wypełnia apply_record)
	var/list/context = list(
		"breach" = list(),
		"opened" = list(),
		"closed" = list(),
		"pending" = list(),
		/// Pola, na których zapis postawił gęsty obiekt
		"blocked" = list(),
		/// Pola, na których zmieniła się instalacja atmosferyczna
		"atmos" = list(),
		/// Maszyny zasilania, którym zmieniło się przykręcenie albo które powstały
		"power" = list(),
	)
	var/list/breach_candidates = context["breach"]
	var/list/opened = context["opened"]
	var/list/closed = context["closed"]
	var/list/blocked = context["blocked"]
	var/list/atmos_changed = context["atmos"]
	var/list/power_changed = context["power"]
	cache_shuttle_areas()
	for(var/key in delta)
		// Błąd przy jednym polu (np. kod maszyny zmienił się od zapisu) nie przerywa nakładania reszty i sprzątania
		try
			if(apply_record(key, delta[key], context))
				applied++
			else
				skipped++
		catch(var/exception/error)
			skipped++
			load_errors++
			log_runtime("Ship structure: couldn't apply the record at [key]: [error] ([error.file]:[error.line])")
		CHECK_TICK

	// Maszyny po turfach i konstrukcjach, a przed pianką (śluzy uszczelniają przejścia)
	for(var/obj/O as anything in create_machines(context["pending"]))
		if(QDELETED(O) || !isturf(O.loc))
			continue
		if(O.density && !(O.flags_1 & ON_BORDER_1))
			blocked[O.loc] = TRUE
		if(istype(O, /obj/machinery/power))
			power_changed |= O
	rebuild_atmos(atmos_changed)
	for(var/obj/machinery/power/P as anything in power_changed)
		if(!QDELETED(P) && P.anchored && !P.powernet)
			P.connect_to_network()
		if(istype(P, /obj/machinery/power/apc))
			var/obj/machinery/power/apc/APC = P
			if(APC.terminal && !APC.terminal.powernet)
				APC.terminal.connect_to_network()

	var/list/mount_turfs = list()
	for(var/turf/T as anything in closed)
		mount_turfs |= evict_contents(T)
	// Pola, na których zapis postawił coś gęstego, a mapa coś tam położyła (np. kanister pod przeniesionym automatem)
	for(var/turf/T as anything in blocked)
		if(closed[T])
			continue
		mount_turfs |= evict_contents(T, only_dense = !ship_structure_turf_sealed(T))
	mount_turfs |= patch_breaches(breach_candidates)
	for(var/turf/T as anything in opened)
		mount_turfs |= T
		for(var/dir in GLOB.cardinals)
			var/turf/neighbour = get_step(T, dir)
			if(neighbour)
				mount_turfs |= neighbour
	fix_wallmounts(mount_turfs, opened)
	relocate_spawn_points(closed)
	return list(applied, skipped)

/**
 * Nakłada zapis jednego pola. Zwraca TRUE, gdy pole zostało zmienione, FALSE, gdy rekord pominięto
 * (prom, klatka magnesu, inna mapa albo inny wariant losowego pokoju na tym polu).
 */
/datum/ship_structure/proc/apply_record(key, list/record, list/context)
	var/turf/T = turf_for(key)
	if(!islist(record) || !T || skip_turf(T))
		return FALSE
	// Losowy pokój (np. silnik): zapis z innego wariantu nie pasuje do tego, który wylosowano teraz
	if(check_rooms && record["room"] != GLOB.ship_structure_room_turfs[T])
		return FALSE
	var/list/objs = tracked_objs(T)
	var/list/sigs = list()
	for(var/obj/O as anything in objs)
		sigs += ship_structure_obj_sig(O)
	var/current_turf = (!length(sigs) && isspaceturf(T)) ? SHIP_STRUCTURE_SPACE : ship_structure_turf_sig(T)
	if(current_turf != record["ot"] || ship_structure_hash(sigs) != record["oh"])
		return FALSE // na mapie stoi tu teraz coś innego niż przy zapisie

	var/list/atmos_changed = context["atmos"]
	var/list/power_changed = context["power"]
	var/list/blocked = context["blocked"]
	var/list/pending_machines = context["pending"]
	var/has_critical = ship_structure_has_critical(T)
	var/was_space = isspaceturf(T)
	var/was_closed = isclosedturf(T)
	var/was_open_to_space = ship_structure_open_to_space(T)
	for(var/sig in record["r"])
		if(keep_map_installations && ship_structure_is_installation(text2path(splittext(sig, ";")[1])))
			continue
		var/index = sigs.Find(sig)
		if(!index)
			continue
		var/obj/O = objs[index]
		sigs.Cut(index, index + 1)
		objs.Cut(index, index + 1)
		if(istype(O, /obj/machinery/atmospherics))
			atmos_changed[T] = TRUE
		qdel(O)
	if(istext(record["t"]))
		// Maszyna krytyczna wraca z mapy zawsze, więc nie zamurowujemy jej ścianą postawioną przez załogę
		if(!(has_critical && ispath(text2path(splittext(record["t"], ";")[1]), /turf/closed)))
			T = set_turf(T, record["t"])
	for(var/list/changes in record["d"])
		if(!istext(changes["s"]))
			continue
		if(keep_map_installations && ship_structure_is_installation(text2path(splittext(changes["s"], ";")[1])))
			continue
		var/index = sigs.Find(changes["s"])
		if(!index)
			continue
		var/obj/O = objs[index]
		sigs.Cut(index, index + 1)
		objs.Cut(index, index + 1)
		apply_kept(O, changes)
		if(istype(O, /obj/machinery/power) && isnum(changes["an"]))
			power_changed |= O
	for(var/list/added in record["a"])
		if(!istext(added["s"]))
			continue
		var/obj/added_path = text2path(splittext(added["s"], ";")[1])
		if(keep_map_installations && ship_structure_is_installation(added_path))
			continue
		if(ship_structure_preloaded(added_path))
			pending_machines += list(list(T, added))
			if(ispath(added_path, /obj/machinery/atmospherics))
				atmos_changed[T] = TRUE
		else
			var/obj/created = create_obj(T, added)
			if(created?.density && !(created.flags_1 & ON_BORDER_1))
				// Okno albo ściana z pianki na polu maszyny krytycznej odcięłyby ją od załogi
				if(has_critical)
					qdel(created)
				else
					blocked[T] = TRUE

	if(!was_space && !was_open_to_space)
		var/list/breach_candidates = context["breach"]
		breach_candidates[T] = TRUE
	if(was_closed && !isclosedturf(T))
		var/list/opened = context["opened"]
		opened[T] = TRUE
	else if(!was_closed && isclosedturf(T))
		var/list/closed = context["closed"]
		closed[T] = TRUE
	return TRUE

/// Na polu stoi maszyna, która zawsze wraca z mapy (cele antagonistów, lot)
/proc/ship_structure_has_critical(turf/T)
	for(var/obj/O in T)
		if(GLOB.ship_structure_critical[O.type])
			return TRUE
	return FALSE

/**
 * Punkty startu, które przy starcie zapamiętały tylko pole (latejoin, xenomorfy, blob, sprzęt ochrony, infiltrator)
 * i już nie istnieją jako obiekty: pole zamurowane przez zapis zamieniamy na wolne pole obok albo usuwamy z listy.
 */
/datum/ship_structure/proc/relocate_spawn_points(list/closed)
	if(!length(closed))
		return
	for(var/list/points in list(SSjob.latejoin_trackers, GLOB.xeno_spawn, GLOB.blobstart, GLOB.secequipment, GLOB.infiltrator_start))
		for(var/i in length(points) to 1 step -1)
			var/turf/T = points[i]
			if(!closed[T])
				continue
			var/turf/destination = free_turf_near(T)
			if(destination)
				points[i] = destination
			else
				points.Cut(i, i + 1)

/// Pole jest częścią kadłuba: leży w obszarze statku albo graniczy z otwartym polem statku
/datum/ship_structure/proc/is_hull_turf(turf/T)
	if(is_ship_area(T.loc))
		return TRUE
	for(var/dir in GLOB.cardinals)
		var/turf/neighbour = get_step(T, dir)
		if(neighbour && !isclosedturf(neighbour) && is_ship_area(neighbour.loc))
			return TRUE
	return FALSE

/**
 * Łata pianką dziury w kadłubie na polach, które na mapie były szczelne (turfs = takie pola, które się zmieniły).
 * Najpierw podłoga z pianki na wszystkich dziurach (kosmos i otwarta przestrzeń nad kosmosem), potem ściana z pianki
 * tylko tam, gdzie pole dalej przepuszcza powietrze do kosmosu, więc wielopolowa dziura nie zarasta ścianami.
 * Rzeczy z mapy spod ściany z pianki idą obok. Zwraca pola, na które coś odstawiono.
 */
/datum/ship_structure/proc/patch_breaches(list/turfs)
	. = list()
	var/list/hull = list()
	for(var/turf/T as anything in turfs)
		if(!is_hull_turf(T))
			continue
		if(isspaceturf(T))
			T = T.PlaceOnTop(/turf/open/floor/plating/foam)
		else if(istype(T, /turf/open/openspace))
			var/turf/below = SSmapping.get_turf_below(T)
			if(!below || isspaceturf(below))
				T = T.PlaceOnTop(/turf/open/floor/plating/foam)
		hull += T
	for(var/turf/T as anything in hull)
		if(!isopenturf(T) || (locate(/obj/structure/foamedmetal) in T) || !ship_structure_open_to_space(T))
			continue
		new /obj/structure/foamedmetal(T)
		. |= evict_contents(T)

/**
 * Rzeczy z mapy, które wylądowały w nowej ścianie, idą na sąsiednie otwarte pole. Zwraca pola, na które trafiły.
 * only_dense = TRUE: pole nie jest zamknięte, tylko zapis postawił na nim coś gęstego (maszynę), więc odchodzą
 * tylko gęste rzeczy i moby, a przedmioty mogą zostać pod maszyną jak w zwykłej grze.
 * Punkty startu (landmarki) przy zamkniętym polu też idą obok, żeby nikt nie zaczynał rundy w ścianie.
 */
/datum/ship_structure/proc/evict_contents(turf/T, only_dense = FALSE)
	. = list()
	for(var/atom/movable/AM as anything in T.contents.Copy())
		if(isobj(AM))
			var/obj/O = AM
			if(istype(O, /obj/effect/landmark))
				if(only_dense)
					continue
			// Instalacje pod podłogą, struktura i maszyny stojące zawsze jak na mapie zostają na miejscu
			else if(is_structure_part(O) || iseffect(O) || (O.resistance_flags & INDESTRUCTIBLE) || GLOB.ship_structure_critical[O.type] \
				|| istype(O, /obj/machinery/atmospherics) || istype(O, /obj/structure/disposalpipe))
				continue
			else if(only_dense && !O.density)
				continue
		else if(!ismob(AM))
			continue
		var/turf/destination = free_turf_near(T)
		if(!destination)
			return
		AM.forceMove(destination)
		. |= destination

/// Pole, na które można coś odstawić: otwarte, w obszarze statku i bez gęstych obiektów
/datum/ship_structure/proc/is_free_turf(turf/T)
	if(!T || isclosedturf(T) || T.density || isspaceturf(T) || !is_ship_area(T.loc))
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
	for(var/turf/candidate as anything in spiral_range_turfs(SHIP_STRUCTURE_MOUNT_RANGE, T, TRUE))
		if(is_free_turf(candidate))
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
				if(opened[T] && !isclosedturf(T))
					for(var/dir in GLOB.cardinals)
						var/turf/wall = get_step(T, dir)
						if(isclosedturf(wall))
							O.forceMove(wall)
							break
				continue
			// Kamera może stać też z dala od ściany: ruszamy ją tylko wtedy, gdy zniknęła ściana, przy której wisiała
			if(istype(O, /obj/machinery/camera) && !isclosedturf(T) && !opened[get_step(T, mount_dir)])
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
	for(var/turf/candidate as anything in spiral_range_turfs(SHIP_STRUCTURE_MOUNT_RANGE, origin, TRUE))
		if(isclosedturf(candidate) || candidate.density || get_area(candidate) != origin_area)
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

/// Przywraca ścianę z mapy na polu (APC, które nie ma gdzie zawisnąć), o ile załoga nie postawiła tam drzwi, okna ani maszyny
/datum/ship_structure/proc/restore_wall(turf/T)
	if(!T || isclosedturf(T))
		return
	var/list/entry = baseline?[key_for(T)]
	if(!islist(entry))
		return
	for(var/obj/O in T)
		if(is_structure_part(O) && O.density)
			return
	set_turf(T, entry[1])
	evict_contents(T)

/// Wczytuje zapis i nakłada go na mapę. Wymaga zrobionego baseline.
/// Czyta plik zapisu; zwraca dane albo null (brak, uszkodzony, nieznany format)
/datum/ship_structure/proc/read_save(path)
	if(!path || !fexists(path))
		return null
	var/list/data
	try
		data = json_decode(rustg_file_read(path))
	catch(var/exception/error)
		log_game("Ship structure: couldn't read [path] ([error])")
		return null
	if(!islist(data) || data["version"] != SHIP_STRUCTURE_VERSION || !islist(data["turfs"]))
		log_game("Ship structure: [path] has an unknown format")
		return null
	return data

/datum/ship_structure/proc/load()
	if(!save_path || (!fexists(save_path) && !fexists("[save_path].bak")))
		last_report = "brak zapisu, statek prosto z mapy"
		return
	var/list/data = read_save(save_path)
	var/source = save_path
	if(!data)
		// Serwer padł w trakcie zapisu albo plik jest uszkodzony: kopia sprzed ostatniego zapisu
		data = read_save("[save_path].bak")
		source = "[save_path].bak"
		// Uszkodzony plik główny nie może trafić do kopii przy następnym zapisie
		quarantine("unreadable, loading the backup", with_backup = FALSE)
	if(!data)
		log_game("Ship structure: no readable save for [save_path], starting from the map")
		last_report = "zapis uszkodzony, statek prosto z mapy"
		return
	rounds = isnum(data["rounds"]) ? data["rounds"] : 0
	// Zmieniony plik mapy: przebudowa rur i kabli urwałaby się na polach zmienionych przez mappera, więc zostają z mapy.
	// Zapis bez sumy kontrolnej (sprzed jej wprowadzenia) traktujemy tak samo: nie wiadomo, na jakiej mapie powstał,
	// a sygnatury pól z rurami zsypu i wieżyczkami zmieniły się razem z nią, więc te pola i tak się nie nałożą.
	var/map_hash = ship_structure_map_hash()
	keep_map_installations = map_hash && data["map_hash"] != map_hash
	check_rooms = data["rooms"] ? TRUE : FALSE
	load_errors = 0
	var/list/result
	try
		result = apply(data["turfs"])
	catch(var/exception/error)
		load_errors++
		log_runtime("Ship structure: applying [source] failed: [error] ([error.file]:[error.line])")
	if(!result)
		result = list(0, 0)
	last_report = "rundy w zapisie: [rounds], odtworzone pola: [result[1]], pominięte: [result[2]]"
	if(keep_map_installations)
		last_report += ", plik mapy się zmienił (rury i kable z mapy)"
	if(source != save_path)
		last_report += ", wczytano kopię zapasową"
	log_game("Ship structure: loaded [source], [rounds] rounds, [result[1]] turfs applied, [result[2]] skipped, [load_errors] errors[keep_map_installations ? ", map file changed, pipes and cables kept from the map" : ""]")
	if(load_errors)
		// Ten sam zapis dawałby te same błędy co rundę: odkładamy go, a następna runda zapisze statek od nowa
		quarantine("[load_errors] errors while loading")
		last_report += ", błędy: [load_errors] (zapis odłożony jako .broken)"
		message_admins("Trwała struktura statku: [load_errors] błędów przy wczytaniu zapisu (szczegóły w logu runtime). Plik odłożony jako [save_path].broken.")

/**
 * Odkłada zapis jako .broken (do obejrzenia), żeby nie wczytywać go ponownie.
 * with_backup = TRUE odkłada też kopię zapasową: inaczej następne wczytanie bez nowego zapisu (runda bez zapisu,
 * padnięcie serwera) wzięłoby starszy statek z kopii albo te same błędy, jeśli pochodziły z kopii.
 */
/datum/ship_structure/proc/quarantine(reason, with_backup = TRUE)
	if(!save_path)
		return
	var/list/paths = list(save_path)
	if(with_backup)
		paths += "[save_path].bak"
	for(var/path in paths)
		if(!fexists(path))
			continue
		fcopy(path, "[path].broken")
		fdel(path)
		log_game("Ship structure: [path] moved to [path].broken ([reason])")

/// Suma kontrolna plików mapy statku (pusta w testach i bez konfiguracji)
/proc/ship_structure_map_hash()
	var/datum/map_config/config = SSmapping.config
	if(!config?.map_path)
		return null
	var/list/files = islist(config.map_file) ? config.map_file : list(config.map_file)
	var/list/hashes = list()
	for(var/file_name in files)
		var/path = "_maps/[config.map_path]/[file_name]"
		if(!fexists(path))
			return null
		hashes += rustg_hash_file(RUSTG_HASH_MD5, path)
	return md5(jointext(hashes, "|"))

/datum/ship_structure/proc/save()
	if(!save_path || !baseline)
		return
	var/list/current = capture(TRUE)
	var/list/delta = diff(baseline, current)
	heavy_damage = is_heavily_damaged(delta)
	var/list/data = list(
		"version" = SHIP_STRUCTURE_VERSION,
		"map" = SSmapping.config?.map_name,
		"map_hash" = ship_structure_map_hash(),
		"rooms" = TRUE,
		"rounds" = rounds + 1,
		"turfs" = delta,
	)
	// Kopia poprzedniego zapisu: padnięcie serwera w trakcie zapisu zostawia uszkodzony plik
	if(fexists(save_path))
		fcopy(save_path, "[save_path].bak")
	rustg_file_write(json_encode(data), save_path)
	saved_this_round = TRUE
	log_game("Ship structure: saved [length(delta)] changed turfs to [save_path][heavy_damage ? ", the ship is heavily damaged" : ""]")

/**
 * Statek jest mocno zniszczony, gdy co najmniej SHIP_STRUCTURE_HEAVY_DAMAGE pól statku z mapy stało się kosmosem.
 * Podłoga z pianki to dziura załatana przy wczytaniu, więc liczy się tak samo (inaczej zniszczenia z poprzednich rund znikałyby).
 */
/datum/ship_structure/proc/is_heavily_damaged(list/delta)
	var/ship_turfs = 0
	for(var/key in baseline)
		var/list/entry = baseline[key]
		if(islist(entry) && !ispath(text2path(entry[1]), /turf/open/space))
			ship_turfs++
	if(!ship_turfs)
		return FALSE
	var/holes = 0
	for(var/key in delta)
		var/list/record = delta[key]
		if(!istext(record["t"]) || record["ot"] == SHIP_STRUCTURE_SPACE || ispath(text2path(record["ot"]), /turf/open/space))
			continue
		var/turf/new_path = text2path(splittext(record["t"], ";")[1])
		if(ispath(new_path, /turf/open/space) || ispath(new_path, /turf/open/openspace) || ispath(new_path, /turf/open/floor/plating/foam))
			holes++
	return holes >= ship_turfs * SHIP_STRUCTURE_HEAVY_DAMAGE

/datum/ship_structure/proc/wipe(reason)
	skip_save = TRUE
	saved_this_round = FALSE
	if(save_path)
		for(var/path in list(save_path, "[save_path].bak"))
			if(fexists(path))
				fdel(path)
	log_game("Ship structure: save [save_path] wiped ([reason])")

/datum/ship_structure/proc/on_round_end()
	// Zniszczenie statku kasuje zapis także wtedy, gdy admin wyłączył zapis tej rundy
	if(SSticker.news_report == SHIP_DESTROYED || QDELETED(SSstar_system.main_overmap))
		wipe("the ship was destroyed")
		return
	if(skip_save)
		log_game("Ship structure: saving skipped for this round")
		return
	// Błąd w trakcie porównania zostawia poprzedni zapis (i jego kopię) bez zmian
	try
		save()
	catch(var/exception/error)
		saved_this_round = FALSE
		log_runtime("Ship structure: saving failed: [error] ([error.file]:[error.line])")
		message_admins("Trwała struktura statku: zapis tej rundy się nie udał (szczegóły w logu runtime). Zostaje zapis z poprzedniej rundy.")

/// Kasuje zapisy wszystkich statków (nowa kampania: mapa gwiezdna jest wspólna dla wszystkich statków)
/proc/ship_structure_wipe_all(reason)
	SSship_structure.structure?.wipe(reason)
	for(var/file_name in flist(SHIP_STRUCTURE_DIR))
		if(copytext(file_name, -5) == ".json" || copytext(file_name, -9) == ".json.bak")
			fdel("[SHIP_STRUCTURE_DIR][file_name]")
	log_game("Ship structure: all ship saves wiped ([reason])")

/**
 * Zdjęcie mapy i wczytanie zapisu: po atomach, atmosferze, zadokowanych promach (SSshuttle, -21) i minor mappingu (-40),
 * żeby wszystko, co stawia turfy na starcie, było już w zdjęciu; przed holomapami (-68), żeby widziały zmieniony układ.
 * Zapis idzie razem z resztą trwałych danych w SSpersistence.CollectData(), a wynik głosowania o statku
 * rozstrzyga się przy restarcie świata (Shutdown), dla mapy, na której grano.
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

/datum/controller/subsystem/ship_structure/Shutdown()
	structure?.apply_vote()
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
	var/list/options = list()
	var/toggle
	var/save_state
	if(SSticker.current_state >= GAME_STATE_FINISHED)
		// Zapis powstaje na koniec rundy, przed głosowaniem; teraz można go już tylko skasować
		save_state = structure.saved_this_round ? "zapisany" : "nie zapisano"
	else
		toggle = structure.skip_save ? "Zapisz strukturę po tej rundzie" : "Nie zapisuj tej rundy"
		options += toggle
		save_state = structure.skip_save ? "NIE" : "TAK"
	options += list("Skasuj zapis", "Anuluj")
	var/choice = tgui_alert(usr, "Zapis: [structure.save_path]\nWczytanie: [structure.last_report]\nZapis po tej rundzie: [save_state]\nGłosowanie: [structure.vote_report()]", "Struktura statku", options)
	if(toggle && choice == toggle)
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
#undef SHIP_STRUCTURE_SHUTTLE
#undef SHIP_STRUCTURE_MOUNT_RANGE
#undef SHIP_STRUCTURE_HEAVY_DAMAGE
