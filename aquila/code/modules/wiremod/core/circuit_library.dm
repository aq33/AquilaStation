// Biblioteka układów gracza: każdy układ albo moduł zeskanowany w duplikatorze modułów trafia też do osobistej
// biblioteki skanującego, zapisanej na serwerze między rundami. W oknie duplikatora biblioteka to kategoria
// „Moje układy”, a druk z niej kosztuje tyle samo materiałów co druk zeskanowanego wzoru.

/// Ile projektów mieści biblioteka jednego gracza
#define CIRCUIT_LIBRARY_MAX_DESIGNS 20

/// ckey -> /datum/circuit_library, wczytane w tej rundzie
GLOBAL_LIST_EMPTY(circuit_libraries)

/datum/circuit_library
	var/ckey
	/// Projekty: list(name, desc, integrated_circuit, dupe_data, materials = list("ścieżka materiału" = ilość))
	var/list/designs = list()

/datum/circuit_library/New(owner_ckey)
	ckey = owner_ckey
	load()

/// Biblioteka gracza o tym ckey, null bez ckey
/proc/get_circuit_library(ckey)
	if(!ckey)
		return null
	var/datum/circuit_library/library = GLOB.circuit_libraries[ckey]
	if(!library)
		library = new /datum/circuit_library(ckey)
		GLOB.circuit_libraries[ckey] = library
	return library

/datum/circuit_library/proc/save_path()
	return "data/player_saves/[ckey[1]]/[ckey]/circuits.json"

/datum/circuit_library/proc/load()
	var/path = save_path()
	if(!fexists(path))
		return
	var/list/loaded = json_decode(file2text(path))
	if(!islist(loaded))
		return
	for(var/list/design in loaded)
		if(istext(design["name"]) && design["dupe_data"])
			designs += list(design)
	if(length(designs) > CIRCUIT_LIBRARY_MAX_DESIGNS)
		designs.Cut(CIRCUIT_LIBRARY_MAX_DESIGNS + 1)

/datum/circuit_library/proc/save()
	var/path = save_path()
	fdel(path)
	text2file(json_encode(designs), path)

/// Dodaje wzór z duplikatora (materiały jako datumy). Wzór o tej samej nazwie jest nadpisywany.
/// Zwraca FALSE, gdy biblioteka jest pełna.
/datum/circuit_library/proc/add_design(list/scanned)
	var/list/materials = list()
	for(var/datum/material/material as anything in scanned["materials"])
		materials["[material.type]"] = scanned["materials"][material]
	var/list/design = list(
		"name" = scanned["name"],
		"desc" = scanned["desc"],
		"integrated_circuit" = !!scanned["integrated_circuit"],
		"dupe_data" = scanned["dupe_data"],
		"materials" = materials,
	)
	for(var/i in 1 to length(designs))
		var/list/existing = designs[i]
		if(existing["name"] == design["name"])
			designs[i] = design
			save()
			return TRUE
	if(length(designs) >= CIRCUIT_LIBRARY_MAX_DESIGNS)
		return FALSE
	designs += list(design)
	save()
	return TRUE

/datum/circuit_library/proc/remove_design(index)
	if(index < 1 || index > length(designs))
		return FALSE
	designs.Cut(index, index + 1)
	save()
	return TRUE

/// Wzór w postaci, jakiej używa duplikator (materiały jako datumy), null przy złym indeksie
/datum/circuit_library/proc/design_for_printing(index)
	if(index < 1 || index > length(designs))
		return null
	var/list/saved = designs[index]
	var/list/materials = list()
	for(var/material_path in saved["materials"])
		var/path = text2path(material_path)
		if(!ispath(path, /datum/material))
			continue
		materials[getmaterialref(path)] = saved["materials"][material_path]
	return list(
		"name" = saved["name"],
		"desc" = saved["desc"],
		"integrated_circuit" = saved["integrated_circuit"],
		"dupe_data" = saved["dupe_data"],
		"materials" = materials,
	)

#undef CIRCUIT_LIBRARY_MAX_DESIGNS
