/// AQUILA - nowe wnętrza abordażu Syndykatu (aquila/code/modules/overmap/syndicate_interiors.dm): każde wczytuje się do SSmapping,
/// ma rozmiar poziomu abordażu i elementy, których potrzebuje abordaż (ster, IFF, punkty patrolu KNPC, odpady reaktora, obszar wnętrza).
/datum/unit_test/aquila_syndicate_interiors

/datum/unit_test/aquila_syndicate_interiors/Run()
	var/list/required = list(
		"/area/ruin/powered/nsv13/boarding_interior",
		"/obj/machinery/computer/ship/helm/syndicate",
		"/obj/machinery/computer/ship/ftl_computer/syndicate",
		"/obj/effect/landmark/iff_console_spawner",
		"/obj/effect/landmark/patrol_node",
		"/obj/effect/landmark/nuclear_waste_spawner",
		"/obj/machinery/door/airlock/ship/external/glass",
	)
	var/list/templates = list(
		/datum/map_template/boarding/barracuda, /datum/map_template/boarding/flak_frigate, /datum/map_template/boarding/kadesh,
		/datum/map_template/boarding/inquisitor, /datum/map_template/boarding/aspala,
		/datum/map_template/boarding/pirate_hauler, /datum/map_template/boarding/pirate_raider,
		/datum/map_template/boarding/pirate_gunboat, /datum/map_template/boarding/pirate_dreadnought,
		/datum/map_template/boarding/fist_of_sol, /datum/map_template/boarding/sols_revenge,
	)
	for(var/template_type in templates)
		var/datum/map_template/template = SSmapping.boarding_templates[template_type]
		if(!template)
			return Fail("[template_type] nie trafił do SSmapping.boarding_templates")
		if(template.width != 255 || template.height != 255)
			return Fail("[template_type] ma rozmiar [template.width]x[template.height] zamiast 255x255")
		var/datum/parsed_map/parsed = new(template.mappath)
		if(!parsed.bounds)
			return Fail("[template_type]: mapy nie da się sparsować")
		var/text = file2text(template.mappath)
		for(var/path in required)
			if(!findtext(text, path))
				return Fail("[template_type]: na mapie brakuje [path]")
