

/*
Destructive Analyzer

It is used to destroy hand-held objects and advance technological research. Controls are in the linked R&D console.

Note: Must be placed within 3 tiles of the R&D Console
*/
/obj/machinery/rnd/destructive_analyzer
	name = "analizator destrukcyjny"
	desc = "Poznawaj naukę, niszcząc rzeczy!"
	icon_state = "d_analyzer"
	circuit = /obj/item/circuitboard/machine/destructive_analyzer
	var/decon_mod = 0

/obj/machinery/rnd/destructive_analyzer/RefreshParts()
	var/T = 0
	for(var/obj/item/stock_parts/S in component_parts)
		T += S.rating
	decon_mod = T


/obj/machinery/rnd/destructive_analyzer/proc/ConvertReqString2List(list/source_list)
	var/list/temp_list = params2list(source_list)
	for(var/O in temp_list)
		temp_list[O] = text2num(temp_list[O])
	return temp_list

/obj/machinery/rnd/destructive_analyzer/disconnect_console()
	linked_console.linked_destroy = null
	..()

/obj/machinery/rnd/destructive_analyzer/Insert_Item(obj/item/O, mob/living/user)
	if(!user.combat_mode)
		. = 1
		if(!is_insertion_ready(user))
			return
		if(!user.transferItemToLoc(O, src))
			to_chat(user, "<span class='warning'>[O] przykleił ci się do ręki, nie możesz włożyć go do [src.name]!</span>")
			return
		busy = TRUE
		loaded_item = O
		to_chat(user, "<span class='notice'>Dodajesz [O.name] do [src.name]!</span>")
		flick("d_analyzer_la", src)
		addtimer(CALLBACK(src, PROC_REF(finish_loading)), 10)
		if (linked_console)
			linked_console.updateUsrDialog()

/obj/machinery/rnd/destructive_analyzer/proc/finish_loading()
	update_icon()
	reset_busy()

/obj/machinery/rnd/destructive_analyzer/update_icon()
	if(loaded_item)
		icon_state = "d_analyzer_l"
	else
		icon_state = initial(icon_state)

/obj/machinery/rnd/destructive_analyzer/proc/reclaim_materials_from(obj/item/thing)
	. = 0
	var/datum/component/material_container/storage = linked_console?.linked_lathe?.materials.mat_container
	if(storage) //Also sends salvaged materials to a linked protolathe, if any.
		for(var/material in thing.materials)
			var/can_insert = min((storage.max_amount - storage.total_amount), (min(thing.materials[material]*(decon_mod/10), thing.materials[material])))
			storage.insert_amount_mat(can_insert, material)
			. += can_insert
		if (.)
			linked_console.linked_lathe.materials.silo_log(src, "reclaimed", 1, "[thing.name]", thing.materials)

/obj/machinery/rnd/destructive_analyzer/proc/destroy_item(obj/item/thing, innermode = FALSE)
	if(QDELETED(thing) || QDELETED(src) || QDELETED(linked_console))
		return FALSE
	if(thing.resistance_flags & INDESTRUCTIBLE)
		playsound(src, 'sound/machines/nuke/angry_beep.ogg', 50, FALSE)
		return FALSE
	if(!innermode)
		flick("d_analyzer_process", src)
		busy = TRUE
		addtimer(CALLBACK(src, PROC_REF(reset_busy)), 24)
		use_power(250)
		if(thing == loaded_item)
			loaded_item = null
		var/list/food = thing.GetDeconstructableContents()
		for(var/obj/item/innerthing in food)
			destroy_item(innerthing, TRUE)
	reclaim_materials_from(thing)
	for(var/mob/M in thing)
		M.death()
	if(istype(thing, /obj/item/stack/sheet))
		var/obj/item/stack/sheet/S = thing
		if(S.amount > 1 && !innermode)
			S.amount--
			loaded_item = S
		else
			qdel(S)
	else
		qdel(thing)
	if (!innermode)
		update_icon()
	return TRUE

/// confirmed - TRUE, gdy gracz potwierdził już w oknie TGUI (wtedy bez input()).
/obj/machinery/rnd/destructive_analyzer/proc/user_try_decon_id(id, mob/user, confirmed = FALSE)
	if(!istype(loaded_item) || !istype(linked_console))
		return FALSE

	if (id && id != RESEARCH_MATERIAL_RECLAMATION_ID)
		var/datum/techweb_node/TN = SSresearch.techweb_node_by_id(id)
		if(!istype(TN))
			return FALSE
		var/dpath = loaded_item.type
		var/list/worths = TN.boost_item_paths[dpath]
		var/list/differences = list()
		var/list/already_boosted = linked_console.stored_research.boosted_nodes[TN.id]
		for(var/i in worths)
			var/used = already_boosted? already_boosted[i] : 0
			var/value = min(worths[i], TN.research_costs[i]) - used
			if(value > 0)
				differences[i] = value
		if(length(worths) && !length(differences))
			return FALSE
		if(!confirmed)
			var/choice = input("Czy na pewno chcesz zniszczyć [loaded_item], by [!length(worths) ? "odkryć: [TN.display_name]" : "wzmocnić: [TN.display_name] o [json_encode(differences)] pkt"]?") in list("Kontynuuj", "Anuluj")
			if(choice == "Anuluj" || !choice)
				return FALSE
			if(QDELETED(loaded_item) || QDELETED(linked_console) || !user.Adjacent(linked_console) || QDELETED(src))
				return FALSE
		SSblackbox.record_feedback("nested tally", "item_deconstructed", 1, list("[TN.id]", "[loaded_item.type]"))
		if(destroy_item(loaded_item))
			linked_console.stored_research.boost_with_path(SSresearch.techweb_node_by_id(TN.id), dpath)

	else
		var/list/point_value = techweb_item_point_check(loaded_item)
		if(linked_console.stored_research.deconstructed_items[loaded_item.type])
			point_value = list()
		var/user_mode_string = ""
		if(length(point_value))
			user_mode_string = " za [json_encode(point_value)] pkt"
		else if(loaded_item.materials.len)
			user_mode_string = " w celu odzysku materiałów"
		if(!confirmed)
			var/choice = input("Czy na pewno chcesz zniszczyć [loaded_item][user_mode_string]?") in list("Kontynuuj", "Anuluj")
			if(choice != "Kontynuuj")
				return FALSE
			if(QDELETED(loaded_item) || QDELETED(linked_console) || !user.Adjacent(linked_console) || QDELETED(src))
				return FALSE
		var/loaded_type = loaded_item.type
		if(destroy_item(loaded_item))
			linked_console.stored_research.add_point_list(point_value)
			linked_console.stored_research.deconstructed_items[loaded_type] = point_value
	return TRUE

/obj/machinery/rnd/destructive_analyzer/proc/unload_item()
	if(!loaded_item)
		return FALSE
	loaded_item.forceMove(get_turf(src))
	loaded_item = null
	update_icon()
	return TRUE

// AQUILA: samodzielne okno analizatora (port DestructiveAnalyzer z tg) - obok obsługi z konsoli B+R
/obj/machinery/rnd/destructive_analyzer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DestructiveAnalyzer")
		ui.open()

/obj/machinery/rnd/destructive_analyzer/ui_data(mob/user)
	var/list/data = list()
	var/datum/techweb/research = linked_console?.stored_research
	data["server_connected"] = !!(linked_console && research)
	data["busy"] = busy
	data["node_data"] = list()
	data["item_mats"] = list()
	if(!loaded_item || QDELETED(loaded_item) || !research)
		data["loaded_item"] = null
		return data
	data["loaded_item"] = loaded_item.name
	data["item_icon"] = icon2base64(getFlatIcon(image(icon = loaded_item.icon, icon_state = loaded_item.icon_state), no_anim = TRUE))
	data["indestructible"] = !(loaded_item.resistance_flags & INDESTRUCTIBLE)
	data["already_deconstructed"] = !!research.deconstructed_items[loaded_item.type]
	var/list/points = techweb_item_point_check(loaded_item)
	data["recoverable_points"] = length(points) ? techweb_point_display_generic(points, FALSE) : null
	for(var/material in loaded_item.materials)
		data["item_mats"] += "[CallMaterialName(material)] x [loaded_item.materials[material]]"
	for(var/node_id in techweb_item_boost_check(loaded_item))
		var/datum/techweb_node/node = SSresearch.techweb_node_by_id(node_id)
		if(!istype(node))
			continue
		var/list/worths = node.boost_item_paths[loaded_item.type]
		var/list/already_boosted = research.boosted_nodes[node.id]
		var/list/differences = list()
		for(var/point_type in worths)
			var/used = already_boosted ? already_boosted[point_type] : 0
			var/value = min(worths[point_type], node.research_costs[point_type]) - used
			if(value > 0)
				differences[point_type] = value
		data["node_data"] += list(list(
			"node_name" = node.display_name,
			"node_path" = node.id,
			"node_hidden" = !!research.hidden_nodes[node.id],
			"node_available" = !research.researched_nodes[node.id] && (!length(worths) || length(differences)),
			"node_boost" = length(differences) ? techweb_point_display_generic(differences, FALSE) : null,
		))
	return data

/obj/machinery/rnd/destructive_analyzer/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("eject_item")
			if(busy)
				to_chat(usr, "<span class='warning'>[src] jest teraz zajęty.</span>")
				return TRUE
			if(unload_item() && linked_console)
				linked_console.updateUsrDialog()
			return TRUE
		if("deconstruct")
			if(busy)
				to_chat(usr, "<span class='warning'>[src] jest teraz zajęty.</span>")
				return TRUE
			if(!linked_console || QDELETED(linked_console))
				say("Brak połączenia z konsolą B+R!")
				return TRUE
			if(!user_try_decon_id(params["deconstruct_path"], usr, TRUE))
				say("Analiza destrukcyjna nie powiodła się!")
			return TRUE
