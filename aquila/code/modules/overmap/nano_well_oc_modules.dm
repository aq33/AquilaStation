/**
 * AQUILA - moduły podkręcania studni nanonaprawczej (APNW).
 *
 * Moduły (`/obj/item/apnw_oc_module/power`, `/load`, `/cooling`, nsv13/code/modules/overmap/armour/nano_well.dm)
 * działały, ale nie było ich skąd wziąć. Tu: projekty w badaniach (Zaawansowana inżynieria), towar
 * w Minsky Heavy Engineering i wyjmowanie modułów łomem, żeby dało się je przełożyć do innej studni.
 * Grzanie powietrza przy mocy powyżej 3 MW zostaje bez zmian (upstream).
 */

/// Moduł nie bije studni przy wkładaniu (attackby studni najpierw woła /obj/attackby)
/obj/item/apnw_oc_module
	item_flags = NOBLUDGEON

/obj/machinery/armour_plating_nanorepair_well/examine(mob/user)
	. = ..()
	if(locate(/obj/item/apnw_oc_module) in contents)
		. += "<span class='notice'>Zainstalowane moduły podkręcania da się wyważyć łomem.</span>"

/// Łom wyjmuje ostatnio włożony moduł podkręcania i przywraca parametr, który zmieniał
/obj/machinery/armour_plating_nanorepair_well/crowbar_act(mob/living/user, obj/item/tool)
	var/obj/item/apnw_oc_module/module
	for(var/obj/item/apnw_oc_module/installed in contents)
		module = installed
	if(!module)
		return ..()
	to_chat(user, "<span class='notice'>Zaczynasz wyważać [module.name] ze studni...</span>")
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 50))
		return TRUE
	if(module.loc != src)
		return TRUE
	remove_oc_module(module)
	module.forceMove(drop_location())
	if(user)
		user.put_in_hands(module)
		to_chat(user, "<span class='notice'>Wyważasz [module.name] ze studni. Studnia wraca do zwykłych parametrów.</span>")
	return TRUE

/// Cofa działanie modułu (wartości ustawiane przy instalacji w nano_well.dm)
/obj/machinery/armour_plating_nanorepair_well/proc/remove_oc_module(obj/item/apnw_oc_module/module)
	if(istype(module, /obj/item/apnw_oc_module/power))
		maximum_power_allocation = initial(maximum_power_allocation)
		power_allocation = min(power_allocation, maximum_power_allocation)
	else if(istype(module, /obj/item/apnw_oc_module/load))
		system_stress_threshold = initial(system_stress_threshold)
		system_stress = min(system_stress, system_stress_threshold * 2)
	else if(istype(module, /obj/item/apnw_oc_module/cooling))
		system_cooling = initial(system_cooling)
	playsound(src, "sparks", 50, TRUE)
	update_icon()

// --- Badania ---

/datum/design/apnw_oc_power
	name = "Moduł podkręcania studni nanonaprawczej (nadmiar mocy)"
	desc = "Podnosi limit mocy studni nanonaprawczej z 3 do 12 MW. Powyżej 3 MW studnia grzeje powietrze w pomieszczeniu."
	id = "apnw_oc_power"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1000, /datum/material/gold = 1000, /datum/material/uranium = 500)
	build_path = /obj/item/apnw_oc_module/power
	category = list("Misc")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/apnw_oc_load
	name = "Moduł podkręcania studni nanonaprawczej (przeciążenie)"
	desc = "Podwaja obciążenie, które studnia nanonaprawcza znosi bez narastania stresu."
	id = "apnw_oc_load"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1000, /datum/material/silver = 1000, /datum/material/titanium = 1000)
	build_path = /obj/item/apnw_oc_module/load
	category = list("Misc")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/apnw_oc_cooling
	name = "Moduł podkręcania studni nanonaprawczej (chłodzenie)"
	desc = "Studnia nanonaprawcza zbija stres systemu 2,5 raza szybciej."
	id = "apnw_oc_cooling"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1000, /datum/material/silver = 1000, /datum/material/plasma = 1000)
	build_path = /obj/item/apnw_oc_module/cooling
	category = list("Misc")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/techweb_node/adv_engi/New()
	. = ..()
	design_ids += list("apnw_oc_power", "apnw_oc_load", "apnw_oc_cooling")

// --- Handlarz ---

/datum/trader_item/apnw_oc_power
	name = "Moduł podkręcania studni nanonaprawczej (nadmiar mocy)"
	desc = "Podnosi limit mocy studni nanonaprawczej z 3 do 12 MW. Powyżej 3 MW studnia grzeje pomieszczenie."
	price = 6000
	stock = 1
	unlock_path = /obj/item/apnw_oc_module/power

/datum/trader_item/apnw_oc_load
	name = "Moduł podkręcania studni nanonaprawczej (przeciążenie)"
	desc = "Studnia znosi dwa razy większe obciążenie pomp, zanim zacznie narastać stres."
	price = 6000
	stock = 1
	unlock_path = /obj/item/apnw_oc_module/load

/datum/trader_item/apnw_oc_cooling
	name = "Moduł podkręcania studni nanonaprawczej (chłodzenie)"
	desc = "Studnia zbija stres systemu 2,5 raza szybciej."
	price = 6000
	stock = 1
	unlock_path = /obj/item/apnw_oc_module/cooling

/// Stocznia z częściami i modyfikacjami okrętów: dopisane do jej listy, bez przypisywania listy od nowa
/datum/trader/minsky/New()
	. = ..()
	sold_items |= list(/datum/trader_item/apnw_oc_power, /datum/trader_item/apnw_oc_load, /datum/trader_item/apnw_oc_cooling)
