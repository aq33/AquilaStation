#define RENDER_RULE_PLANTSEED "RENDER_RULE_PLANTSEED"
#define RENDER_RULE_FRUIT "RENDER_RULE_FRUIT"
#define RENDER_RULE_TRAY "RENDER_RULE_TRAY"

/*
	The plant scanner shows some plant information and tray information
*/
/obj/item/plant_scanner
	name = "skaner roślin"
	desc = "Przenośne urządzenie do skanowania i analizy roślin. Działa też na tacach hydroponicznych.\n<span class='notice'>Użyj w dłoni, aby włączyć / wyłączyć zaawansowany skan.</span>"
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "plant_scanner"
	item_state = "analyzer"
	worn_icon_state = "plantanalyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_BELT
	custom_materials = list(/datum/material/iron=30, /datum/material/glass=20)
	///Refernece to our screen effect
	var/obj/effect/hydroponics_screen/screen

	var/list/buffer = list()
	///AQUILA - krótki stan zeskanowanej rośliny, pokazywany nad szczegółami
	var/list/status = list()
	var/last_time
	var/last_target
	var/render_rule = null

/obj/item/plant_scanner/Initialize(mapload)
	. = ..()
	screen = new(src, "plant_scanner_on")

/obj/item/plant_scanner/Destroy(force)
	. = ..()
	QDEL_NULL(screen)

/obj/item/plant_scanner/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PlantScanner")
		ui.open()

/obj/item/plant_scanner/ui_data(mob/user)
	var/list/data = list()
	data["buffer"] = buffer
	data["status"] = status
	data["last_time"] = last_time
	data["last_target"] = last_target
	data["render_rule"] = render_rule

	return data

/obj/item/plant_scanner/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	. = TRUE
	screen?.flash()
	//prepare UI data
	buffer.Cut()
	status.Cut()
	last_time = station_time_timestamp(format = "hh:mm")
	last_target = target.name
	//These cases are samey but it's easier to read them in this format
//Seed packet
	var/obj/item/plant_seeds/seeds = target
	if(istype(seeds))
		render_rule = RENDER_RULE_PLANTSEED
		for(var/datum/plant_feature/feature as anything in seeds.plant_features)
			buffer += list(list("feature" = feature.get_scan_dialogue(), "needs" = feature.get_need_dialogue()))
		. = FALSE
//Plant
	var/datum/component/plant/plant_component = target.GetComponent(/datum/component/plant)
	if(plant_component && length(plant_component.plant_features))
		render_rule = RENDER_RULE_PLANTSEED
		status = get_plant_status(plant_component)
		for(var/datum/plant_feature/feature as anything in plant_component.plant_features)
			buffer += list(list("feature" = feature.get_scan_dialogue(), "needs" = feature.get_need_dialogue()))
		. = FALSE
//Fruit
	var/list/genes = list()
	SEND_SIGNAL(target, COMSIG_PLANT_GET_GENES, genes)
	if(length(genes))
		render_rule = RENDER_RULE_FRUIT
		//Features
		buffer["genes"] = list()
		for(var/datum/plant_feature/feature as anything in genes[PLANT_GENE_INDEX_FEATURES])
			buffer["genes"] += list(list("feature" = feature.get_scan_dialogue(), "needs" = feature.get_need_dialogue()))
		//Reagents
		buffer["reagents"] = list()
		for(var/datum/reagent/reagent as anything in target.reagents?.reagent_list)
			buffer["reagents"] += list("[reagent?.volume]j. [reagent?.name]")
		. = FALSE
//Tray - AQUILA: krótki stan tacy i każdej rośliny w czacie, zamiast pełnego katalogu potrzeb
	var/obj/item/plant_tray/tray = target
	if(istype(tray) && tray.can_scan)
		render_rule = RENDER_RULE_TRAY
		buffer = get_tray_status(tray)
		to_chat(user, span_notice("<b>[capitalize(target.name)]</b><br>[jointext(buffer, "<br>")]"))
		playsound(src, 'sound/effects/fastbeep.ogg', 20)
		ui_update()
		return FALSE
//Fail state
	if(!.)
		playsound(src, 'sound/effects/fastbeep.ogg', 20)
		ui_interact(user)
		ui_update()
		return
	last_target = null
	render_rule = null
	ui_update()

/// AQUILA - stan rośliny w kilku liniach: zdrowie, wzrost, owoce, szkodniki i czego jej teraz brakuje
/obj/item/plant_scanner/proc/get_plant_status(datum/component/plant/plant)
	var/list/lines = list()
	var/datum/plant_feature/body/body = locate() in plant.plant_features
	var/datum/plant_feature/fruit/fruit = locate() in plant.plant_features
	if(body)
		var/max_health = max(1, initial(body.health))
		var/current_health = max(0, round(body.health))
		lines += "Zdrowie: [current_health]/[max_health] ([round(current_health / max_health * 100)]%)"
		if(body.yields <= 0)
			lines += "Wzrost: roślina uschła i nie da już plonów"
		else if(body.current_stage >= body.growth_stages)
			lines += "Wzrost: dojrzała, pozostałe plony: [body.yields == INFINITY ? "bez końca" : body.yields]"
		else
			lines += "Wzrost: [round(body.growth_time_elapsed / max(1, body.growth_time) * 100)]%"
	if(fruit)
		if(length(fruit.fruits))
			lines += "Owoce: [length(fruit.fruits)] do zebrania"
		else if(length(fruit.growth_timers))
			lines += "Owoce: rosną"
	var/pest_level = 0
	var/list/missing = list()
	for(var/datum/plant_feature/feature as anything in plant.plant_features)
		for(var/datum/plant_need/reagent/buff/pests/pests in feature.plant_needs)
			pest_level = max(pest_level, pests.pest_level)
		for(var/datum/plant_need/need as anything in feature.unmet_needs)
			if(QDELETED(need) || !(need in feature.plant_needs))
				continue
			missing |= need.get_short_description()
	if(pest_level >= 1)
		lines += "Szkodniki: [round(pest_level)]%"
	lines += length(missing) ? "Brakuje: [jointext(missing, "; ")]" : "Brakuje: nic"
	return lines

/// AQUILA - stan tacy: podłoże, płyny, chwasty, miejsce i krótki stan każdej rośliny
/obj/item/plant_scanner/proc/get_tray_status(obj/item/plant_tray/tray)
	var/list/lines = list()
	var/datum/component/planter/planter = tray.tray_component
	lines += "Podłoże: [planter?.substrate?.name || "brak"]"
	if(tray.reagents)
		lines += "Płyny: [round(tray.reagents.total_volume)]/[tray.reagents.maximum_volume] j., w tym woda: [round(tray.reagents.get_reagent_amount(/datum/reagent/water))] j."
	if(planter)
		lines += "Chwasty: [round(planter.weed_level)]% (przy 100% wyrasta chwast, usuwa je kultywator)"
		lines += "Wolne miejsce: [planter.plant_slots]/[initial(planter.plant_slots)]"
		for(var/datum/component/plant/plant as anything in planter.plants)
			lines += ""
			lines += "<b>[capitalize(plant.plant_item.name)]</b>"
			lines += get_plant_status(plant)
	return lines

#undef RENDER_RULE_PLANTSEED
#undef RENDER_RULE_FRUIT
#undef RENDER_RULE_TRAY
