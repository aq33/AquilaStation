// AQUILA - Elektrolizer (plan maszynowni E6), port z Yogstation (code/game/machinery/electrolyzer.dm), okno z tg (Electrolyzer.tsx).
// Przenośna maszyna na ogniwie: rozkłada parę wodną z kafelka na wodór i tlen (2 H2O -> 2 H2 + O2).
// Po przykręceniu kluczem bierze prąd z APC i ładuje ogniwo. Różnice względem Yoga: bez receptury
// hipernoblium -> antynoblium (nie mamy antynoblium). Ikony z tg (icons/obj/pipes_n_cables/atmos.dmi, CC-BY-SA 3.0).

#define ELECTROLYZER_MODE_STANDBY "standby"
#define ELECTROLYZER_MODE_WORKING "working"

/obj/machinery/electrolyzer
	name = "elektrolizer"
	desc = "Rozkłada parę wodną z otoczenia na wodór i tlen. Gwarancja nie obejmuje klaunów."
	icon = 'aquila/icons/obj/atmospherics/electrolyzer.dmi'
	icon_state = "electrolyzer-off"
	anchored = FALSE
	density = TRUE
	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN | INTERACT_MACHINE_OFFLINE
	max_integrity = 250
	circuit = /obj/item/circuitboard/machine/electrolyzer
	use_power = IDLE_POWER_USE // przy NO_POWER_USE powered() zawsze zwraca TRUE i NOPOWER się nie ustawia
	idle_power_usage = 0
	/// Ogniwo zasilające, gdy maszyna nie jest przykręcona do sieci
	var/obj/item/stock_parts/cell/cell = /obj/item/stock_parts/cell
	/// Czy maszyna jest włączona
	var/on = FALSE
	/// ELECTROLYZER_MODE_STANDBY albo ELECTROLYZER_MODE_WORKING
	var/mode = ELECTROLYZER_MODE_STANDBY
	/// Mnożnik moli rozkładanych na tik, z laserów
	var/working_power = 1
	/// Oszczędność ogniwa, z kondensatora
	var/efficiency = 0.5
	/// Ile ładunku na tik oddaje sieć ogniwu
	var/charge_rate = 10

/obj/machinery/electrolyzer/get_cell()
	return cell

/obj/machinery/electrolyzer/Initialize(mapload)
	. = ..()
	if(ispath(cell))
		cell = new cell(src)
	update_appearance()

/obj/machinery/electrolyzer/on_construction()
	QDEL_NULL(cell)
	panel_open = TRUE
	update_appearance()
	return ..()

/obj/machinery/electrolyzer/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/machinery/electrolyzer/on_deconstruction()
	if(cell)
		component_parts += cell
		cell = null
	return ..()

/obj/machinery/electrolyzer/handle_atom_del(atom/A)
	if(A == cell)
		cell = null
	return ..()

/obj/machinery/electrolyzer/examine(mob/user)
	. = ..()
	. += "Jest [on ? "włączony" : "wyłączony"], a właz jest [panel_open ? "otwarty" : "zamknięty"]."
	if(cell)
		. += "Miernik ładunku pokazuje [round(cell.percent(), 1)]%."
	else
		. += "Nie ma w nim ogniwa zasilającego."

/obj/machinery/electrolyzer/update_icon_state()
	icon_state = "electrolyzer-[on ? mode : "off"]"
	return ..()

/obj/machinery/electrolyzer/update_overlays()
	. = ..()
	if(panel_open)
		. += "electrolyzer-open"

/// Czy maszyna ma prąd z sieci (przykręcona, APC działa)
/obj/machinery/electrolyzer/proc/has_grid_power()
	return anchored && !(machine_stat & NOPOWER)

/obj/machinery/electrolyzer/process_atmos()
	if(on && (machine_stat & (BROKEN|MAINT)))
		on = FALSE
	if(!on)
		update_appearance()
		return PROCESS_KILL
	var/grid = has_grid_power()
	if(!grid && (!cell || cell.charge <= 0))
		on = FALSE
		update_appearance()
		return PROCESS_KILL

	var/turf/open/location = loc
	if(!istype(location))
		if(mode != ELECTROLYZER_MODE_STANDBY)
			mode = ELECTROLYZER_MODE_STANDBY
			update_appearance()
		return
	if(mode != ELECTROLYZER_MODE_WORKING)
		mode = ELECTROLYZER_MODE_WORKING
		update_appearance()

	// Energia przed zmianą gazu: z pustego ogniwa nic się nie rozłoży
	var/datum/gas_mixture/env = location.return_air()
	var/split = electrolysis_amount(env)
	var/energy = (5 * split) / (efficiency + working_power)
	if(grid)
		// Sieć ładuje ogniwo także bez pary i płaci za ten ładunek
		var/charged = cell ? cell.give(charge_rate) : 0
		if(energy + charged > 0)
			use_power(energy + charged)
	else if(split > 0 && !cell.use(energy))
		on = FALSE
		update_appearance()
		return PROCESS_KILL
	electrolyze(env, split)

/// Ile moli pary wodnej elektrolizer rozłoży z tej mieszanki w jednym tiku
/obj/machinery/electrolyzer/proc/electrolysis_amount(datum/gas_mixture/env)
	if(!env)
		return 0
	return max(0, min(env.get_moles(GAS_H2O) * 0.1, 3 * working_power))

/// Rozkłada parę wodną z mieszanki na wodór i tlen (split moli, domyślnie electrolysis_amount()), zwraca liczbę rozłożonych moli wody
/obj/machinery/electrolyzer/proc/electrolyze(datum/gas_mixture/env, split)
	if(!env)
		return 0
	if(isnull(split))
		split = electrolysis_amount(env)
	if(split <= 0)
		return 0
	env.adjust_moles(GAS_H2O, -split)
	env.adjust_moles(GAS_H2, split)
	env.adjust_moles(GAS_O2, split / 2)
	return split

/obj/machinery/electrolyzer/RefreshParts()
	var/lasers = 0
	var/capacitors = 0
	for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
		lasers += laser.rating
	for(var/obj/item/stock_parts/capacitor/capacitor in component_parts)
		capacitors += capacitor.rating
		charge_rate = initial(charge_rate) * capacitor.rating
	working_power = lasers / 2
	efficiency = (capacitors + 1) * 0.5

/obj/machinery/electrolyzer/attackby(obj/item/I, mob/user, params)
	add_fingerprint(user)
	if(default_unfasten_wrench(user, I))
		return
	if(istype(I, /obj/item/stock_parts/cell))
		if(!panel_open)
			to_chat(user, span_warning("Najpierw otwórz właz, żeby włożyć ogniwo."))
			return
		if(cell)
			to_chat(user, span_warning("W środku jest już ogniwo."))
			return
		if(!user.transferItemToLoc(I, src))
			return
		cell = I
		user.visible_message(span_notice("[user] wkłada ogniwo do [src]."), span_notice("Wkładasz ogniwo do [src]."))
		SStgui.update_uis(src)
		return
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		panel_open = !panel_open
		user.visible_message(span_notice("[user] [panel_open ? "otwiera" : "zamyka"] właz [src]."), span_notice("[panel_open ? "Otwierasz" : "Zamykasz"] właz [src]."))
		update_appearance()
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/electrolyzer/ui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/electrolyzer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Electrolyzer", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/electrolyzer/ui_data()
	var/list/data = list()
	data["open"] = panel_open
	data["on"] = on
	data["anchored"] = anchored
	data["hasPowercell"] = !isnull(cell)
	data["powerLevel"] = cell ? round(cell.percent(), 1) : 0
	return data

/obj/machinery/electrolyzer/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("power")
			on = !on
			mode = ELECTROLYZER_MODE_STANDBY
			usr.visible_message(span_notice("[usr] [on ? "włącza" : "wyłącza"] [src]."), span_notice("[on ? "Włączasz" : "Wyłączasz"] [src]."))
			update_appearance()
			if(on)
				SSair.start_processing_machine(src)
			else
				SSair.stop_processing_machine(src)
			return TRUE
		if("eject")
			if(panel_open && cell)
				cell.forceMove(drop_location())
				cell = null
				return TRUE

/obj/item/circuitboard/machine/electrolyzer
	name = "elektrolizer (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/electrolyzer
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stack/cable_coil = 3,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stack/sheet/mineral/gold = 1,
		/obj/item/stack/sheet/mineral/silver = 1)
	needs_anchored = FALSE

/datum/design/board/electrolyzer
	name = "Projekt maszyny (elektrolizer)"
	desc = "Płytka drukowana: elektrolizer."
	id = "electrolyzer"
	build_path = /obj/item/circuitboard/machine/electrolyzer
	category = list("Engineering Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/techweb_node/engineering/New()
	. = ..()
	design_ids += "electrolyzer"

#undef ELECTROLYZER_MODE_STANDBY
#undef ELECTROLYZER_MODE_WORKING
