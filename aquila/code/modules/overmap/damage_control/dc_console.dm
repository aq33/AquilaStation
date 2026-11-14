/// AQUILA - konsola kontroli uszkodzeń („Damage Control Coordination”, Alpha 3 z roadmapy NSV; plan walki na overmapie).
/// Schemat pokładów okrętu: przedziały (obszary okrętu) z ciśnieniem, pożarem, wyłomem i zasilaniem na żywo z atmosu
/// i alarmów, pancerz ćwiartek i nanonaprawcze pompy pancerza. Koordynator ustawia priorytet przedziału, a ekipy
/// inżynierii dostają go na PDA (zwykła wiadomość przez telekomunikację).

#define DC_PRIORITY_MAX 3
/// Poniżej tego ciśnienia (kPa) przedział ma wyłom
#define DC_BREACH_PRESSURE 20
/// Poniżej tego ciśnienia (kPa) przedział ma za mało powietrza
#define DC_LOW_PRESSURE 70
#define DC_BROADCAST_COOLDOWN (3 SECONDS)

/// Obrys obszaru i pola do pomiaru ciśnienia: list(z, x0, y0, x1, y1, list(pola)); liczony raz na obszar
GLOBAL_LIST_EMPTY(dc_area_bounds)

/proc/dc_area_bounds(area/A)
	if(GLOB.dc_area_bounds[A])
		return GLOB.dc_area_bounds[A]
	var/z = 0
	var/x0 = world.maxx
	var/y0 = world.maxy
	var/x1 = 0
	var/y1 = 0
	var/list/open = list()
	for(var/turf/T in A)
		if(!z)
			z = T.z
		if(T.z != z)
			continue
		x0 = min(x0, T.x)
		y0 = min(y0, T.y)
		x1 = max(x1, T.x)
		y1 = max(y1, T.y)
		if(isopenturf(T) && !isspaceturf(T))
			open += T
	if(!z)
		return null
	var/list/samples = list()
	for(var/i in 1 to min(5, length(open)))
		samples += open[round(1 + (i - 1) * (length(open) - 1) / max(1, min(5, length(open)) - 1))]
	GLOB.dc_area_bounds[A] = list(z, x0, y0, x1, y1, samples)
	return GLOB.dc_area_bounds[A]

/// Najniższe ciśnienie (kPa) w polach pomiarowych obszaru; wyłom w jednym miejscu przedziału widać od razu
/proc/dc_area_pressure(list/bounds)
	var/lowest = INFINITY
	for(var/turf/open/T as anything in bounds[6])
		var/datum/gas_mixture/air = T.return_air()
		if(air)
			lowest = min(lowest, air.return_pressure())
	return lowest == INFINITY ? 0 : lowest

/obj/item/circuitboard/computer/ship/damage_control
	name = "konsola kontroli uszkodzeń (płytka komputera)"
	build_path = /obj/machinery/computer/ship/damage_control

/obj/machinery/computer/ship/damage_control
	name = "konsola kontroli uszkodzeń"
	desc = "Schemat pokładów z wyłomami, pożarami i ciśnieniem w przedziałach. Koordynator wysyła stąd priorytety napraw na PDA ekip."
	icon_screen = "alert:0"
	icon_keyboard = "atmos_key"
	circuit = /obj/item/circuitboard/computer/ship/damage_control
	/// Przedział (obszar) -> priorytet 1..3
	var/list/priorities = list()
	var/next_broadcast = 0
	/// Nanonaprawcze pompy pancerza okrętu (szukane przy otwarciu okna)
	var/list/pumps

/obj/machinery/computer/ship/damage_control/ui_interact(mob/user, datum/tgui/ui)
	if(!has_overmap())
		to_chat(user, "<span class='warning'>Konsola nie jest połączona z żadnym okrętem.</span>")
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DamageControl", "Kontrola uszkodzeń")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/ship/damage_control/proc/find_pumps()
	pumps = list()
	for(var/obj/machinery/armour_plating_nanorepair_pump/pump in GLOB.machines)
		if(pump.OM == linked)
			pumps += pump

/// Stan przedziału: wyłom, pożar, mało powietrza albo w porządku
/proc/dc_area_state(area/A, pressure)
	if(pressure < DC_BREACH_PRESSURE)
		return "breach"
	if(A.fire)
		return "fire"
	if(pressure < DC_LOW_PRESSURE)
		return "low"
	return "ok"

/obj/machinery/computer/ship/damage_control/ui_data(mob/user)
	var/list/data = list()
	if(!linked)
		return data
	var/list/decks = list()
	for(var/area/A as anything in linked.linked_areas)
		if(QDELETED(A))
			continue
		var/list/bounds = dc_area_bounds(A)
		if(!bounds)
			continue
		var/pressure = dc_area_pressure(bounds)
		var/key = "[bounds[1]]"
		if(!decks[key])
			decks[key] = list()
		decks[key] += list(list(
			"id" = "\ref[A]",
			"name" = A.name,
			"x0" = bounds[2],
			"y0" = bounds[3],
			"x1" = bounds[4],
			"y1" = bounds[5],
			"pressure" = round(pressure),
			"state" = dc_area_state(A, pressure),
			"power" = A.powered(AREA_USAGE_EQUIP),
			"priority" = priorities[A] || 0,
		))
	var/list/deck_list = list()
	var/number = 0
	for(var/key in decks)
		number++
		deck_list += list(list("z" = text2num(key), "name" = "Pokład [number]", "areas" = decks[key]))
	data["decks"] = deck_list
	data["armour"] = linked.get_armour_report()
	if(isnull(pumps))
		find_pumps()
	var/list/pump_data = list()
	for(var/obj/machinery/armour_plating_nanorepair_pump/pump as anything in pumps)
		if(QDELETED(pump))
			continue
		pump_data += list(list("quadrant" = pump.quadrant, "online" = pump.online && !pump.stress_shutdown && !(pump.machine_stat & (BROKEN|NOPOWER)), "stress" = pump.stress_shutdown))
	data["pumps"] = pump_data
	return data

/obj/machinery/computer/ship/damage_control/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(. || action != "set_priority")
		return
	var/area/A = locate(params["id"])
	if(!istype(A) || !(A in linked?.linked_areas))
		return TRUE
	var/priority = clamp(text2num(params["priority"]) || 0, 0, DC_PRIORITY_MAX)
	if(priority)
		priorities[A] = priority
		broadcast_priority(A, priority, usr)
	else
		priorities -= A
	return TRUE

/// Priorytet przedziału na PDA inżynierii (i dowództwa) przez zwykłą telekomunikację
/obj/machinery/computer/ship/damage_control/proc/broadcast_priority(area/A, priority, mob/user)
	if(world.time < next_broadcast)
		return
	next_broadcast = world.time + DC_BROADCAST_COOLDOWN
	var/list/bounds = dc_area_bounds(A)
	var/problem = bounds ? dc_area_state(A, dc_area_pressure(bounds)) : "ok"
	var/problem_text = list("breach" = "wyłom", "fire" = "pożar", "low" = "mało powietrza", "ok" = "przegląd")[problem]
	var/list/targets = list()
	for(var/obj/item/modular_computer/tablet as anything in GLOB.TabletMessengers)
		if(!tablet.saved_job || !tablet.saved_identification)
			continue
		if((tablet.saved_job in GLOB.engineering_positions) || (tablet.saved_job in GLOB.command_positions))
			targets += tablet
	log_game("[key_name(user)] ustawił priorytet [priority] przedziału [A.name] na konsoli kontroli uszkodzeń")
	if(!length(targets))
		return
	var/datum/signal/subspace/messaging/tablet_msg/signal = new(src, list(
		"name" = "Kontrola uszkodzeń",
		"job" = "Konsola okrętowa",
		"message" = "Priorytet [priority]: [A.name] ([problem_text]).",
		"ref" = REF(src),
		"targets" = targets,
		"emojis" = FALSE,
		"photo" = null,
		"automated" = TRUE,
	))
	signal.send_to_receivers()

#undef DC_PRIORITY_MAX
#undef DC_BREACH_PRESSURE
#undef DC_LOW_PRESSURE
#undef DC_BROADCAST_COOLDOWN
