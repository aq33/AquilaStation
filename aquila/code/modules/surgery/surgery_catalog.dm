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

/// Sekcje katalogu w kolejności zakładek: id (SURGERY_SECTION_*), nazwa i podpowiedź, w co celować
GLOBAL_LIST_INIT(surgery_catalog_sections, list(
	list("id" = SURGERY_SECTION_GENERAL, "name" = "Otwarcie i zamknięcie", "hint" = "Podstawowe kroki na dowolnej części ciała: nacięcie, dostęp do kości i organów, zamknięcie. Celuj w część ciała, którą operujesz."),
	list("id" = SURGERY_SECTION_WOUNDS, "name" = "Rany i kości", "hint" = "Leczenie ran, oparzeń, złamań i zwichnięć na dowolnej części ciała. Celuj w zranioną część."),
	list("id" = SURGERY_SECTION_HEAD, "name" = "Głowa", "hint" = "Mózg i czaszka. Celuj w głowę."),
	list("id" = SURGERY_SECTION_FACE, "name" = "Oczy, uszy i usta", "hint" = "Oczy, uszy, zęby, język i twarz. Celuj w oczy, głowę albo usta, zależnie od operacji."),
	list("id" = SURGERY_SECTION_CHEST, "name" = "Klatka piersiowa i brzuch", "hint" = "Serce, płuca, wątroba, żołądek i jama ciała. Organy brzucha też leżą w strefie klatki piersiowej, więc celuj w klatkę."),
	list("id" = SURGERY_SECTION_GROIN, "name" = "Pachwina", "hint" = "Wyrostek, ogon i narządy płciowe. Celuj w pachwinę."),
	list("id" = SURGERY_SECTION_LIMBS, "name" = "Ręce i nogi", "hint" = "Amputacje, protezy i implanty w kończynach. Celuj w daną rękę albo nogę."),
	list("id" = SURGERY_SECTION_MECHANIC, "name" = "Mechaniczne (IPC i protezy)", "hint" = "Operacje na robotycznych częściach ciała i pacjentach IPC. Zamiast skalpela i piły używasz głównie śrubokręta, klucza i łomu."),
	list("id" = SURGERY_SECTION_OTHER, "name" = "Inne stworzenia", "hint" = "Operacje na szlamach i innych stworzeniach bez zwykłego ciała."),
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
		"sections" = get_catalog_sections(),
		"time" = time / (1 SECONDS),
		"locked" = !!(operation_flags & OPERATION_LOCKED),
		"mechanic" = !!(operation_flags & OPERATION_MECHANIC),
		"priority" = !!(operation_flags & OPERATION_PRIORITY_NEXT_STEP),
		"looping" = !!(operation_flags & OPERATION_LOOPING),
	)

/// Sekcje katalogu (SURGERY_SECTION_*): catalog_sections albo wywnioskowane z typu, plus „mechaniczne” przy OPERATION_MECHANIC
/datum/surgery_operation/proc/get_catalog_sections()
	var/list/sections = length(catalog_sections) ? catalog_sections.Copy() : get_default_catalog_sections()
	if(operation_flags & OPERATION_MECHANIC)
		sections |= SURGERY_SECTION_MECHANIC
	return sections

/// Sekcje, gdy operacja nie ma catalog_sections. Operacje na kończynach (/limb) muszą je mieć ustawione jawnie.
/datum/surgery_operation/proc/get_default_catalog_sections()
	return list()

/// Operacje na całym mobie: według strefy, którą sprawdzają (brak strefy = dowolna część ciała)
/datum/surgery_operation/basic/get_default_catalog_sections()
	if(isnull(target_zone))
		return list(SURGERY_SECTION_GENERAL)
	return list(surgery_zone_to_catalog_section(target_zone))

/// Operacje na organach: według organu
/datum/surgery_operation/organ/get_default_catalog_sections()
	switch(initial(target_type.slot))
		if(ORGAN_SLOT_BRAIN)
			return list(SURGERY_SECTION_HEAD)
		if(ORGAN_SLOT_EYES, ORGAN_SLOT_EARS, ORGAN_SLOT_TONGUE)
			return list(SURGERY_SECTION_FACE)
	return list(surgery_zone_to_catalog_section(initial(target_type.zone)))

/// Bioware: według strefy, w której się ją robi
/datum/surgery_operation/limb/bioware/get_default_catalog_sections()
	return list(surgery_zone_to_catalog_section(required_zone))

/// Sekcja katalogu dla strefy ciała
/proc/surgery_zone_to_catalog_section(zone)
	switch(zone)
		if(BODY_ZONE_HEAD)
			return SURGERY_SECTION_HEAD
		if(BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH)
			return SURGERY_SECTION_FACE
		if(BODY_ZONE_CHEST)
			return SURGERY_SECTION_CHEST
		if(BODY_ZONE_PRECISE_GROIN)
			return SURGERY_SECTION_GROIN
		if(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
			return SURGERY_SECTION_LIMBS
	return SURGERY_SECTION_GENERAL

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
		tools += list(list("name" = tool_name, "speed" = round(100 / multiplier, 1)))
	return tools

/// Nazwa zalecanego (pierwszego) narzędzia po polsku
/datum/surgery_operation/proc/get_catalog_recommended_tool()
	var/list/tools = get_catalog_tools()
	var/list/first_tool = tools[1]
	return first_tool["name"]
