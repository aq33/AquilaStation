// AQUILA - katalog wszystkich operacji do programu PDA „Operacje” i komputera operacyjnego.
// Generowany z operacji nowego szkieletu (GLOB.operations, aquila/code/modules/surgery_tg/), więc nowe operacje pojawiają się w nim same.

GLOBAL_LIST(surgery_catalog)

/// Polskie nazwy typów narzędzi z implements
GLOBAL_LIST_INIT(surgery_tool_names, list(
	TOOL_SCALPEL = "skalpel",
	TOOL_HEMOSTAT = "hemostat",
	TOOL_RETRACTOR = "retraktor",
	TOOL_BONESET = "nastawiacz kości",
	TOOL_CAUTERY = "kauter",
	TOOL_DRILL = "wiertarka chirurgiczna",
	TOOL_SAW = "piła chirurgiczna",
	TOOL_BLOODFILTER = "filtr krwi",
	TOOL_SCREWDRIVER = "śrubokręt",
	TOOL_WRENCH = "klucz",
	TOOL_CROWBAR = "łom",
	TOOL_WIRECUTTER = "przecinak",
	TOOL_WELDER = "spawarka",
	TOOL_MULTITOOL = "multitool",
	TOOL_KNIFE = "nóż",
	TOOL_ANALYZER = "analizator",
	TOOL_MINING = "kilof",
	TOOL_SHOVEL = "łopata",
	TOOL_ROLLINGPIN = "wałek",
	TOOL_RUSTSCRAPER = "skrobaczka do rdzy",
	IMPLEMENT_HAND = "pusta ręka",
))

/// Wszystkie operacje w formacie dla TGUI (NtosSurgeryLookup, OperatingComputer). Bez wersji ukrytych (OPERATION_NO_WIKI, np. abduktorów).
/proc/get_surgery_catalog()
	if(GLOB.surgery_catalog)
		return GLOB.surgery_catalog

	var/list/catalog = list()
	for(var/operation_type in GLOB.operations.operations_by_typepath)
		var/datum/surgery_operation/operation = GLOB.operations.operations_by_typepath[operation_type]
		if(operation.operation_flags & OPERATION_NO_WIKI)
			continue
		catalog += list(operation.get_catalog_entry())
	GLOB.surgery_catalog = catalog
	return catalog

/// Pozycja katalogu
/datum/surgery_operation/proc/get_catalog_entry()
	return list(
		"id" = "[type]",
		"name" = capitalize(rnd_name || name),
		"desc" = rnd_desc || desc,
		"tools" = get_catalog_tools(),
		"requirements" = get_requirements(),
		"time" = time / (1 SECONDS),
		"locked" = !!(operation_flags & OPERATION_LOCKED),
		"mechanic" = !!(operation_flags & OPERATION_MECHANIC),
		"priority" = !!(operation_flags & OPERATION_PRIORITY_NEXT_STEP),
		"looping" = !!(operation_flags & OPERATION_LOOPING),
	)

/// Narzędzia operacji: nazwa i sprawność w procentach (100% = czas bazowy), w kolejności z implements
/datum/surgery_operation/proc/get_catalog_tools()
	var/list/tools = list()
	if(!length(implements))
		tools += list(list("name" = "dowolne narzędzie albo pusta ręka", "speed" = 100))
		return tools
	for(var/implement in implements)
		var/tool_name
		if(implement == /obj/item)
			tool_name = get_any_tool()
		else if(ispath(implement))
			var/atom/tool_type = implement
			tool_name = initial(tool_type.name)
		else
			tool_name = GLOB.surgery_tool_names[implement] || "[implement]"
		var/multiplier = implements[implement] || 1
		tools += list(list("name" = tool_name, "speed" = round(100 / multiplier)))
	return tools

/// Nazwa zalecanego (pierwszego) narzędzia po polsku
/datum/surgery_operation/proc/get_catalog_recommended_tool()
	var/list/tools = get_catalog_tools()
	var/list/first_tool = tools[1]
	return first_tool["name"]
