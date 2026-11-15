// AQUILA - okno pieca łukowego (MunitionsForge.tsx) zamiast form odlewniczych: wyrób, materiał albo stop, klasa,
// koszt z silosu i właściwości wyrobu w jednym oknie. Obudowy głowic wymagają zbadanych głowic torped (jak dawna forma).

/// Grupy wyrobów w oknie: nazwa grupy -> typ bazowy (wyrobami są podtypy)
GLOBAL_LIST_INIT(aq_forge_groups, list(
	"Łuski" = /obj/item/munition_part/body/casings,
	"Pociski działowe" = /obj/item/munition_part/body/shell,
	"Obudowy głowic" = /obj/item/munition_part/body/warhead,
	"Wkładki do pancerza" = /obj/item/munition_part/body/armor_insert,
	"Wypełnienia" = /obj/item/munition_part/filler,
	"Zapalniki" = /obj/item/munition_part/fuze,
))

/// Typ bazowy grupy -> węzeł techwebu, bez którego piec jej nie odleje
GLOBAL_LIST_INIT(aq_forge_group_nodes, list(
	/obj/item/munition_part/body/warhead = "basic_torpedo_components",
))

/// Wszystkie wyroby pieca: nazwa grupy -> lista typów części
GLOBAL_LIST_INIT(aq_forge_products, init_aq_forge_products())

/proc/init_aq_forge_products()
	. = list()
	for(var/group in GLOB.aq_forge_groups)
		var/list/products = list()
		for(var/path in subtypesof(GLOB.aq_forge_groups[group]))
			if(ispath(path, /obj/item/munition_part/body))
				var/obj/item/munition_part/body/body = path
				if(!initial(body.product_path) && !initial(body.forge_standalone))
					continue
			products += path
		.[group] = products

/// Typ bazowy grupy, do której należy wyrób
/proc/aq_forge_group_root(product)
	for(var/group in GLOB.aq_forge_groups)
		if(ispath(product, GLOB.aq_forge_groups[group]))
			return GLOB.aq_forge_groups[group]

/// Czy to wyrób z katalogu pieca (typ bazowy grupy albo korpus bez wyrobu nim nie jest)
/proc/aq_forge_is_product(product)
	for(var/group in GLOB.aq_forge_products)
		if(product in GLOB.aq_forge_products[group])
			return TRUE
	return FALSE

/// Czy piec może już odlewać ten wyrób (wyrób z katalogu i zbadany węzeł grupy)
/proc/aq_forge_product_available(product)
	if(!aq_forge_is_product(product))
		return FALSE
	var/root = aq_forge_group_root(product)
	var/node = GLOB.aq_forge_group_nodes[root]
	if(!node)
		return TRUE
	return !!SSresearch.science_tech?.researched_nodes[node]

/obj/machinery/munitions_forge/arc_forge/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MunitionsForge")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/munitions_forge/arc_forge/ui_static_data(mob/user)
	. = list()
	var/list/groups = list()
	for(var/group in GLOB.aq_forge_products)
		var/list/items = list()
		for(var/obj/item/munition_part/path as anything in GLOB.aq_forge_products[group])
			items += list(list("id" = "[path]", "name" = initial(path.name)))
		groups += list(list("name" = group, "items" = items))
	.["groups"] = groups
	var/list/qualities = list()
	for(var/datum/munition_quality/quality_type as anything in munition_quality_levels())
		var/datum/munition_quality/quality = get_munition_quality(quality_type)
		qualities += list(list("level" = quality.level, "roman" = quality.roman, "name" = quality.name))
	.["qualities"] = qualities

/obj/machinery/munitions_forge/arc_forge/ui_data(mob/user)
	. = list()
	var/datum/component/material_container/container = get_container()
	.["connected"] = !!container
	.["silo"] = !!materials?.silo
	.["operating"] = operating
	.["produced"] = produced_part ? "[produced_part]" : null
	.["working_part"] = working_part ? "[working_part]" : null
	.["working_heat"] = working_part?.forge_heat
	.["selected_product"] = "[selected_product]"
	.["selected_material"] = "[selected_material?.material_type]"
	.["selected_alloy"] = selected_alloy ? "[selected_alloy.material_type]" : null
	var/datum/munition_quality/quality = get_munition_quality(selected_quality)
	.["selected_quality"] = quality.level
	var/is_body = ispath(selected_product, /obj/item/munition_part/body)
	.["uses_material"] = is_body
	var/list/locked = list()
	for(var/group in GLOB.aq_forge_products)
		for(var/path in GLOB.aq_forge_products[group])
			if(!aq_forge_product_available(path))
				locked += "[path]"
	.["locked"] = locked
	var/list/mats = list()
	for(var/key in GLOB.munition_materials)
		var/datum/munition_material/M = GLOB.munition_materials[key]
		mats += list(list("id" = "[M.material_type]", "name" = M.name, "sheets" = container ? round(container.get_material_amount(M.material_type) / MINERAL_MATERIAL_AMOUNT, 0.1) : 0))
	.["materials"] = mats
	var/total_sheets = 0
	for(var/list/mat as anything in mats)
		total_sheets += mat["sheets"]
	.["empty"] = container && !total_sheets
	var/list/cost = list()
	var/can_pay = !!container
	for(var/mat in current_cost())
		var/datum/munition_material/M = get_munition_material(mat)
		var/have = container ? container.get_material_amount(mat) : 0
		cost += list(list("name" = M ? M.name : "[mat]", "need" = round(current_cost()[mat] / MINERAL_MATERIAL_AMOUNT, 0.1), "have" = round(have / MINERAL_MATERIAL_AMOUNT, 0.1)))
		if(have < current_cost()[mat])
			can_pay = FALSE
	.["cost"] = cost
	.["can_cast"] = can_pay && !operating && !produced_part && !working_part && aq_forge_product_available(selected_product)
	var/datum/munition_material/material = current_material()
	var/list/stats = list()
	if(is_body)
		stats += list(list("name" = "materiał", "value" = material.name))
		stats += list(list("name" = "obrażenia", "value" = "×[round(material.damage_mult * quality.bonus, 0.01)]"))
		stats += list(list("name" = "przebicie", "value" = "[material.armour_pen_add >= 0 ? "+" : ""][material.armour_pen_add]"))
		stats += list(list("name" = "prędkość", "value" = "×[material.speed_mult]"))
		stats += list(list("name" = "wytrzymałość", "value" = "×[round(material.integrity_mult * quality.bonus, 0.01)]"))
	else
		stats += list(list("name" = "jakość", "value" = "×[quality.bonus]"))
	.["stats"] = stats
	.["rough"] = quality.level == 0

/obj/machinery/munitions_forge/arc_forge/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(!allowed(usr))
		to_chat(usr, "<span class='warning'>Brak dostępu.</span>")
		return TRUE
	switch(action)
		if("select_product")
			var/product = text2path(params["id"])
			if(!aq_forge_is_product(product))
				return TRUE
			selected_product = product
			return TRUE
		if("select_material")
			var/datum/munition_material/M = get_munition_material(text2path(params["id"]))
			if(!M)
				return TRUE
			selected_material = M
			if(selected_alloy == M)
				selected_alloy = null
			return TRUE
		if("select_alloy")
			var/id = params["id"]
			selected_alloy = id ? get_munition_material(text2path(id)) : null
			if(selected_alloy == selected_material)
				selected_alloy = null
			return TRUE
		if("select_quality")
			var/level = text2num(params["level"])
			for(var/datum/munition_quality/quality_type as anything in munition_quality_levels())
				if(initial(quality_type.level) == level)
					selected_quality = quality_type
			return TRUE
		if("cast")
			if(working_part)
				to_chat(usr, "<span class='warning'>W piecu leży [working_part]. Dogrzej go albo wyjmij Alt+klikiem.</span>")
				return TRUE
			start_operation(usr)
			return TRUE
		if("reheat")
			if(working_part)
				start_operation(usr)
			return TRUE
		if("take")
			if(produced_part && !operating && isliving(usr))
				var/obj/item/munition_part/part = produced_part
				produced_part = null
				part.hand_over(usr)
				update_icon()
			return TRUE
