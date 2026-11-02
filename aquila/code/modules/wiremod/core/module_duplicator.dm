// Duplikator modułów z tg (/obj/machinery/module_duplicator w code/modules/wiremod/core/component_printer.dm).
// U nas osobna maszyna: materiały z silosu przez /datum/component/remote_materials (jak w naszych fabrykatorach),
// a okno to ModuleDuplicator (ComponentPrinter z tg na naszej przeglądarce projektów Fabrication/).

/// Module duplicator, allows you to save and recreate module components.
/obj/machinery/module_duplicator
	name = "duplikator modułów"
	desc = "Pozwala powielać moduły i układy scalone, żeby nie składać ich od nowa. Przyłóż do maszyny moduł albo układ, by zapisać go jako wzór."
	icon = 'aquila/icons/obj/wiremod/wiremod_fab.dmi'
	icon_state = "module-fab-idle"
	circuit = /obj/item/circuitboard/machine/module_duplicator
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100

	///List of designs scanned and saved
	var/list/scanned_designs = list()
	///Constant material cost per component
	var/cost_per_component = MINERAL_MATERIAL_AMOUNT / 10
	///Cost efficiency of this machine
	var/efficiency_coeff = 1

/obj/machinery/module_duplicator/Initialize(mapload)
	AddComponent(/datum/component/remote_materials, "modfab", mapload, TRUE, TRUE)
	return ..()

/// Lokalny pojemnik albo pojemnik podłączonego silosu.
/obj/machinery/module_duplicator/proc/get_material_container()
	var/datum/component/remote_materials/materials = GetComponent(/datum/component/remote_materials)
	return materials?.mat_container

/obj/machinery/module_duplicator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ModuleDuplicator", name)
		ui.open()

/obj/machinery/module_duplicator/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/sheetmaterials),
		get_asset_datum(/datum/asset/spritesheet/research_designs),
	)

/obj/machinery/module_duplicator/RefreshParts()
	. = ..()

	var/datum/component/remote_materials/materials = GetComponent(/datum/component/remote_materials)
	if(materials)
		var/total_storage = 0
		for(var/obj/item/stock_parts/matter_bin/bin in component_parts)
			total_storage += bin.rating * (37.5 * MINERAL_MATERIAL_AMOUNT)
		materials.set_local_size(total_storage)

	efficiency_coeff = 0

	for(var/obj/item/stock_parts/manipulator/manipulator in component_parts)
		///we do -1 because normal manipulators rating of 1 gives us 1-1=0 i.e no decrement in cost
		efficiency_coeff += manipulator.rating - 1

	///linear interpolation between full cost i.e 1 & 1/8th the cost i.e 0.125
	///we do it in 6 steps because maximum rating of 2 manipulators is 8 but -1 gives us 6
	efficiency_coeff = 1.0 + ((0.125 - 1.0) * (efficiency_coeff / 6))

	update_static_data_for_all_viewers()

/obj/machinery/module_duplicator/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("print")
			if(machine_stat & (NOPOWER|BROKEN))
				return TRUE
			var/design_id = text2num(params["design_id"])

			if(!design_id || design_id < 1 || design_id > length(scanned_designs))
				return TRUE

			var/list/design = scanned_designs[design_id]
			var/datum/component/remote_materials/remote = GetComponent(/datum/component/remote_materials)
			var/datum/component/material_container/materials = remote?.mat_container
			if(!materials)
				say("Brak dostępu do magazynu materiałów.")
				return TRUE
			if(remote.on_hold())
				say("Dostęp do minerałów jest wstrzymany, skontaktuj się z kwatermistrzem.")
				return TRUE

			if(!materials.has_materials(design["materials"], efficiency_coeff))
				say("Za mało materiałów.")
				return TRUE

			materials.use_materials(design["materials"], efficiency_coeff)
			remote.silo_log(src, "built", -1, design["name"], design["materials"])
			use_power(active_power_usage)
			print_module(design)
			balloon_alert_to_viewers("wydrukowano [design["name"]]")
			return TRUE
		if("remove_mat")
			var/datum/component/remote_materials/remote = GetComponent(/datum/component/remote_materials)
			var/datum/material/material = locate(params["ref"])
			var/amount = text2num(params["amount"])
			if(!remote || !istype(material) || !amount)
				return TRUE
			if(!(material in remote.mat_container?.materials))
				return TRUE
			remote.eject_sheets(material, amount)
			return TRUE

/obj/machinery/module_duplicator/proc/print_module(list/design)
	flick("module-fab-print", src)
	addtimer(CALLBACK(src, PROC_REF(finish_module_print), design), 1.6 SECONDS)

/obj/machinery/module_duplicator/proc/finish_module_print(list/design)
	var/atom/movable/created_atom
	if(design["integrated_circuit"])
		var/obj/item/integrated_circuit/circuit = new(drop_location())
		var/list/errors = list()
		circuit.load_circuit_data(design["dupe_data"], errors)
		if(length(errors))
			stack_trace("Error loading user saved circuit [errors.Join(", ")].")
		created_atom = circuit
	else
		var/obj/item/circuit_component/module/module = new(drop_location())
		module.load_data_from_list(design["dupe_data"])
		created_atom = module
	created_atom.pixel_x = created_atom.base_pixel_x + rand(-5, 5)
	created_atom.pixel_y = created_atom.base_pixel_y + rand(-5, 5)

/obj/machinery/module_duplicator/attackby(obj/item/tool, mob/living/user, params)
	var/list/data = list()

	if(istype(tool, /obj/item/circuit_component/module))
		var/obj/item/circuit_component/module/module = tool
		if(HAS_TRAIT(module, TRAIT_CIRCUIT_UNDUPABLE))
			balloon_alert(user, "nie da się zapisać tego modułu!")
			return TRUE

		data["dupe_data"] = list()
		module.save_data_to_list(data["dupe_data"])

		data["name"] = module.display_name
		data["desc"] = "Moduł zapisany przez [user]."
		data["materials"] = list(getmaterialref(/datum/material/glass) = module.circuit_size * cost_per_component)
	else if(istype(tool, /obj/item/integrated_circuit))
		var/obj/item/integrated_circuit/integrated_circuit = tool
		if(HAS_TRAIT(integrated_circuit, TRAIT_CIRCUIT_UNDUPABLE))
			balloon_alert(user, "nie da się zapisać tego układu!")
			return TRUE

		data["dupe_data"] = integrated_circuit.convert_to_json()

		data["name"] = integrated_circuit.display_name
		data["desc"] = "Układ scalony zapisany przez [user]."

		var/list/materials = list(getmaterialref(/datum/material/glass) = integrated_circuit.current_size * cost_per_component)
		var/datum/design/circuit_design = SSresearch.techweb_design_by_id("integrated_circuit")
		for(var/material_key in circuit_design?.materials)
			var/datum/material/material = istype(material_key, /datum/material) ? material_key : getmaterialref(material_key)
			if(!material)
				continue
			materials[material] += circuit_design.materials[material_key]

		data["materials"] = materials
		data["integrated_circuit"] = TRUE

	if(!length(data))
		return ..()

	if(!data["name"])
		balloon_alert(user, "najpierw nadaj mu nazwę!")
		return TRUE

	for(var/list/component_data as anything in scanned_designs)
		if(component_data["name"] == data["name"])
			balloon_alert(user, "ta nazwa już jest zapisana!")
			return TRUE

	flick("module-fab-scan", src)
	addtimer(CALLBACK(src, PROC_REF(finish_module_scan), user, data), 1.4 SECONDS)
	return TRUE

/obj/machinery/module_duplicator/proc/finish_module_scan(mob/user, data)
	scanned_designs += list(data)

	balloon_alert(user, "zapisano moduł")
	playsound(src, 'sound/machines/ping.ogg', 50)

	update_static_data_for_all_viewers()

/obj/machinery/module_duplicator/ui_data(mob/user)
	var/list/data = list()
	data["materials"] = fabricator_ui_materials(get_material_container())
	return data

/obj/machinery/module_duplicator/ui_static_data(mob/user)
	var/list/data = list()
	var/list/designs = list()

	var/datum/asset/spritesheet/research_designs/spritesheet = get_asset_datum(/datum/asset/spritesheet/research_designs)
	var/icon_size = spritesheet.icon_size_id("integrated_circuit")
	var/icon_class = "[icon_size == "[spritesheet.name]32x32" ? "" : "[icon_size] "]integrated_circuit"

	var/index = 1
	for(var/list/design as anything in scanned_designs)
		var/list/cost = list()
		var/list/materials = design["materials"]
		for(var/datum/material/mat as anything in materials)
			cost[mat.name] = round(materials[mat] * efficiency_coeff)

		designs["[index]"] = list(
			"name" = design["name"],
			"desc" = design["desc"],
			"cost" = cost,
			"reagentCost" = list(),
			"id" = "[index]",
			"icon" = icon_class,
			"categories" = list("/Zapisane układy"),
			"constructionTime" = 0,
		)
		index++

	data["designs"] = designs

	return data

/obj/machinery/module_duplicator/crowbar_act(mob/living/user, obj/item/tool)
	return default_deconstruction_crowbar(tool)

/obj/machinery/module_duplicator/screwdriver_act(mob/living/user, obj/item/tool)
	return default_deconstruction_screwdriver(user, "module-fab-o", "module-fab-idle", tool)

/obj/item/circuitboard/machine/module_duplicator
	name = "duplikator modułów (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/module_duplicator
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 2,
	)

/datum/design/board/module_duplicator
	name = "Projekt maszyny (duplikator modułów)"
	desc = "Płytka obwodu duplikatora modułów, który kopiuje układy scalone."
	id = "module_duplicator"
	build_path = /obj/item/circuitboard/machine/module_duplicator
	category = list("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
