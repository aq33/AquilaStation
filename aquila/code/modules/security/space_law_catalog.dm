// AQUILA - prawo kosmiczne do programu PDA „Prawo kosmiczne”: te same dane co terminal GenPop (config/space_law.json)

GLOBAL_LIST(space_law_catalog)

/// Zwraca kategorie przestępstw z ich artykułami, w kolejności z configu
/proc/get_space_law_catalog()
	if(GLOB.space_law_catalog)
		return GLOB.space_law_catalog

	var/list/crime_list
	try
		crime_list = json_decode(file2text(file("config/space_law.json")))
	catch(var/exception/error)
		log_config("Nie udało się wczytać config/space_law.json dla programu PDA: [error]")
	if(!length(crime_list))
		crime_list = list()
		for(var/datum/crime/crime_path as anything in subtypesof(/datum/crime))
			if(isnull(initial(crime_path.name)))
				continue
			LAZYADD(crime_list[initial(crime_path.category)], list(list(
				"name" = initial(crime_path.name),
				"tooltip" = initial(crime_path.tooltip),
				"colour" = initial(crime_path.colour),
				"icon" = initial(crime_path.icon),
				"sentence" = initial(crime_path.sentence),
			)))

	var/list/catalog = list()
	for(var/category in crime_list)
		catalog += list(list("name" = category, "crimes" = crime_list[category]))
	GLOB.space_law_catalog = catalog
	return catalog

/// Kary dostępne na okręcie dla podpowiedzi w programie PDA: terminal GenPop, konsola gułagu i netpod (cyfrowe wygnanie).
/// z_levels: poziomy, na których szukać (domyślnie poziomy okrętu; test podaje poziom swojego pokoju)
/proc/get_space_law_facilities(list/z_levels = SSmapping.levels_by_trait(ZTRAIT_STATION))
	var/list/facilities = list("genpop" = FALSE, "gulag" = FALSE, "exile" = FALSE)
	for(var/obj/machinery/machine as anything in GLOB.machines)
		if(!(machine.z in z_levels))
			continue
		if(istype(machine, /obj/machinery/genpop_interface))
			facilities["genpop"] = TRUE
		else if(istype(machine, /obj/machinery/computer/prisoner/gulag_teleporter_computer))
			facilities["gulag"] = TRUE
		else if(istype(machine, /obj/machinery/netpod))
			facilities["exile"] = TRUE
	return facilities
