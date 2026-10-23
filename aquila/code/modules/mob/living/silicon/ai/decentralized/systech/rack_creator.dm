/obj/machinery/rack_creator
	name = "składarka racków"
	desc = "Łączy kości RAM i procesory w samodzielny rack dla systemów sztucznej inteligencji. Pamięć drukuje z materiałów."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "circuit_imprinter"
	base_icon_state = "circuit_imprinter"
	layer = BELOW_OBJ_LAYER

	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	active_power_usage = 1000
	circuit = /obj/item/circuitboard/machine/rack_creator

	var/list/inserted_cpus = list()
	///List containing lists with the name, capacity and cost of every RAM stick to be added.
	var/list/ram_expansions = list()

	var/datum/component/material_container/materials
	var/efficiency_coeff = 1

/obj/machinery/rack_creator/Initialize(mapload)
	materials = AddComponent(/datum/component/material_container, list(/datum/material/iron, /datum/material/glass, /datum/material/silver, /datum/material/gold, /datum/material/bluespace), 0, TRUE, /obj/item/stack)
	. = ..()
	RefreshParts()

/obj/machinery/rack_creator/Destroy()
	materials?.retrieve_all()
	materials = null
	for(var/obj/item/ai_cpu/CPU as anything in inserted_cpus)
		CPU.forceMove(drop_location())
	inserted_cpus.Cut()
	return ..()

/obj/machinery/rack_creator/RefreshParts()
	var/mat_capacity = 0
	for(var/obj/item/stock_parts/matter_bin/new_matter_bin in component_parts)
		mat_capacity += new_matter_bin.rating * 40 * MINERAL_MATERIAL_AMOUNT
	materials.max_amount = mat_capacity

	var/total_rating = 1.1
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		total_rating = clamp(total_rating - (M.rating * 0.1), 0, 1)
	efficiency_coeff = max(round(total_rating, 0.1), 0.1)

/obj/machinery/rack_creator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiRackCreator", name)
		ui.open()

/obj/machinery/rack_creator/ui_static_data(mob/user)
	var/list/data = list()
	data["SHEET_MATERIAL_AMOUNT"] = MINERAL_MATERIAL_AMOUNT
	return data

/obj/machinery/rack_creator/proc/materials_to_text(list/cost)
	var/list/parts = list()
	for(var/mat_type in cost)
		var/datum/material/mat = getmaterialref(mat_type)
		parts += "[mat.name]: [cost[mat_type] * efficiency_coeff]"
	return jointext(parts, ", ")

/obj/machinery/rack_creator/ui_data(mob/user)
	var/list/data = list()

	data["materials"] = materials.ui_data()
	data["can_print"] = check_resources()

	data["cpus"] = list()
	data["total_cpu"] = 0
	data["power_usage"] = 0
	var/list/power_usage_unweighted = list()
	for(var/obj/item/ai_cpu/CPU as anything in inserted_cpus)
		var/cpu_power_usage = CPU.get_power_usage()
		var/cpu_efficiency = CPU.get_efficiency()
		data["cpus"] += list(list(
			"speed" = CPU.speed,
			"efficiency" = cpu_efficiency,
			"power_usage" = cpu_power_usage,
		))
		data["total_cpu"] += CPU.speed
		data["power_usage"] += cpu_power_usage
		power_usage_unweighted += list(list(
			"usage" = cpu_power_usage,
			"efficiency" = cpu_efficiency,
		))

	var/total_efficiency = 1
	if(data["power_usage"])
		total_efficiency = 0
		for(var/list/usage as anything in power_usage_unweighted)
			var/weight = usage["usage"] / data["power_usage"]
			total_efficiency += (usage["efficiency"] / 100) * weight

	data["efficiency"] = total_efficiency

	data["ram"] = list()
	data["total_ram"] = 0
	for(var/list/RAM as anything in ram_expansions)
		data["ram"] += list(list(
			"capacity" = RAM["capacity"],
			"name" = RAM["name"],
			"cost" = materials_to_text(RAM["cost"]),
		))
		data["total_ram"] += RAM["capacity"]

	data["power_usage"] += length(ram_expansions) * AI_POWER_PER_CARD

	data["possible_ram"] = list()
	for(var/datum/design/ram/D as anything in subtypesof(/datum/design/ram))
		D = SSresearch.techweb_design_by_id(initial(D.id))
		if(!D)
			continue
		data["possible_ram"] += list(list(
			"name" = D.name,
			"capacity" = D.capacity,
			"cost" = materials_to_text(D.ram_materials),
			"id" = D.id,
			"unlocked" = SSresearch.science_tech.isDesignResearchedID(D.id) ? TRUE : FALSE,
		))

	data["unlocked_ram"] = 1
	data["unlocked_cpu"] = 1
	for(var/i in 2 to 4)
		if(slotUnlockedRAM(i))
			data["unlocked_ram"] = i
		if(slotUnlockedCPU(i))
			data["unlocked_cpu"] = i

	return data

/obj/machinery/rack_creator/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/sheetmaterials),
	)

/obj/machinery/rack_creator/proc/check_resources()
	var/list/total_cost = list()
	for(var/list/RAM as anything in ram_expansions)
		for(var/mat in RAM["cost"])
			total_cost[mat] += RAM["cost"][mat] * efficiency_coeff

	if(!length(total_cost))
		return -1
	if(materials.has_materials(total_cost))
		return total_cost
	return FALSE

/obj/machinery/rack_creator/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/ai_cpu))
		insert_cpu(user, I)
		return TRUE
	return ..()

/obj/machinery/rack_creator/proc/insert_cpu(mob/living/user, obj/item/ai_cpu/cpu)
	if(length(inserted_cpus) >= AI_MAX_CPUS_PER_RACK)
		to_chat(user, span_warning("Do tego racka nie zmieści się więcej procesorów!"))
		return FALSE
	if(!slotUnlockedCPU(length(inserted_cpus) + 1))
		to_chat(user, span_warning("To gniazdo nie zostało jeszcze zbadane!"))
		return FALSE
	if(!user.transferItemToLoc(cpu, src))
		return FALSE
	inserted_cpus += cpu
	SStgui.update_uis(src)
	return TRUE

/obj/machinery/rack_creator/screwdriver_act(mob/living/user, obj/item/I)
	default_deconstruction_screwdriver(user, "[base_icon_state]_t", base_icon_state, I)
	return TRUE

/obj/machinery/rack_creator/crowbar_act(mob/living/user, obj/item/I)
	default_deconstruction_crowbar(I)
	return TRUE

/obj/machinery/rack_creator/proc/slotUnlockedCPU(slot_number)
	switch(slot_number)
		if(1)
			return TRUE
		if(2)
			return SSresearch.science_tech.isNodeResearchedID("ai_cpu_2")
		if(3)
			return SSresearch.science_tech.isNodeResearchedID("ai_cpu_3")
		if(4)
			return SSresearch.science_tech.isNodeResearchedID("ai_cpu_4")

/obj/machinery/rack_creator/proc/slotUnlockedRAM(slot_number)
	switch(slot_number)
		if(1)
			return TRUE
		if(2)
			return SSresearch.science_tech.isNodeResearchedID("ai_ram_2")
		if(3)
			return SSresearch.science_tech.isNodeResearchedID("ai_ram_3")
		if(4)
			return SSresearch.science_tech.isNodeResearchedID("ai_ram_4")

/obj/machinery/rack_creator/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	var/mob/living/user = usr
	switch(action)
		if("insert_cpu")
			var/obj/item/ai_cpu/cpu = user.get_active_held_item()
			if(!istype(cpu))
				to_chat(user, span_warning("Nie trzymasz procesora!"))
				return
			insert_cpu(user, cpu)
			. = TRUE
		if("remove_cpu")
			var/index = text2num(params["cpu_index"])
			if(!index || index > length(inserted_cpus) || index < 1)
				return
			var/obj/item/ai_cpu/cpu = inserted_cpus[index]
			inserted_cpus -= cpu
			if(!user.put_in_hands(cpu))
				cpu.forceMove(drop_location())
			. = TRUE
		if("insert_ram")
			if(length(ram_expansions) >= AI_MAX_RAM_PER_RACK)
				to_chat(user, span_warning("Do tego racka nie zmieści się więcej pamięci!"))
				return
			var/datum/design/ram/D = SSresearch.science_tech.isDesignResearchedID(params["ram_type"])
			if(!istype(D))
				return
			if(!slotUnlockedRAM(length(ram_expansions) + 1))
				to_chat(user, span_warning("To gniazdo nie zostało jeszcze zbadane!"))
				return
			ram_expansions += list(list(
				"name" = D.name,
				"capacity" = D.capacity,
				"cost" = D.ram_materials.Copy(),
			))
			. = TRUE
		if("remove_ram")
			var/index = text2num(params["ram_index"])
			if(!index || index > length(ram_expansions) || index < 1)
				return
			ram_expansions.Cut(index, index + 1)
			. = TRUE

		if("finalize")
			if(!length(ram_expansions) && !length(inserted_cpus))
				say("Brak RAM i procesorów. Przerwano.")
				return
			var/total_cost = check_resources()
			if(!total_cost)
				say("Za mało materiałów.")
				return
			if(islist(total_cost))
				materials.use_materials(total_cost)

			var/obj/item/server_rack/new_rack = new(src)
			for(var/obj/item/ai_cpu/CPU as anything in inserted_cpus)
				CPU.forceMove(new_rack)
				new_rack.contained_cpus += CPU
			inserted_cpus = list()

			var/total_ram = 0
			var/list/new_custom_materials = list()
			new_custom_materials[getmaterialref(/datum/material/iron)] = 1000
			for(var/list/RAM as anything in ram_expansions)
				for(var/mat in RAM["cost"])
					new_custom_materials[getmaterialref(mat)] += RAM["cost"][mat] * efficiency_coeff
				total_ram += RAM["capacity"]

			new_rack.set_custom_materials(new_custom_materials)
			new_rack.contained_ram = total_ram
			ram_expansions.Cut()

			flick("[base_icon_state]_ani", src)
			addtimer(CALLBACK(src, PROC_REF(finalize_post), new_rack), 1.5 SECONDS)
			. = TRUE
		if("remove_mat")
			var/datum/material/material = locate(params["ref"]) in materials.materials
			var/amount = text2num(params["amount"])
			if(!material || !amount)
				return
			materials.retrieve_sheets(amount, material, drop_location())
			. = TRUE

/obj/machinery/rack_creator/proc/finalize_post(obj/item/server_rack/rack)
	if(QDELETED(rack))
		return
	rack.forceMove(drop_location())
