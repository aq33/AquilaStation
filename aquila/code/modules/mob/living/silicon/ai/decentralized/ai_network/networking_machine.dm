// Nadajnik sieci SI (port Yogstation, networking_machines.dm). Łączy dwie odległe sieci ethernet bez kabla,
// także między pokładami stacji.

GLOBAL_LIST_EMPTY(ai_networking_machines)

/obj/machinery/ai/networking
	name = "nadajnik sieci SI"
	desc = "Mocny nadajnik z odbiornikiem. Łączy odległe sieci SI niemal bez opóźnień. Połączenie ustawia się w panelu albo ręcznie multitoolem, kluczem i śrubokrętem."
	icon = 'aquila/icons/obj/machines/networking_machine.dmi'
	icon_state = "base"
	density = TRUE
	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0
	max_integrity = 150
	circuit = /obj/item/circuitboard/machine/networking_machine

	///Etykieta widoczna dla innych nadajników
	var/label
	///Do mapowania: przy starcie rundy łączy się z nadajnikiem o tej etykiecie
	var/roundstart_connection
	///Nadajnik po drugiej stronie połączenia
	var/obj/machinery/ai/networking/partner
	///Obrót anteny w stopniach
	var/rotation_to_partner = 0
	///Zablokowany nadajnik nie przyjmuje nowych połączeń
	var/locked = FALSE
	///Nadajnik wybrany multitoolem do ręcznego połączenia
	var/obj/machinery/ai/networking/remote_connection_attempt
	var/mutable_appearance/dish_overlay

/obj/machinery/ai/networking/Initialize(mapload)
	. = ..()
	if(!label)
		label = num2hex(rand(1, 65535), -1)
	GLOB.ai_networking_machines += src
	dish_overlay = mutable_appearance(icon, "top", FLY_LAYER)
	update_appearance()
	if(mapload)
		return INITIALIZE_HINT_LATELOAD

/obj/machinery/ai/networking/LateInitialize()
	. = ..()
	roundstart_connect()

/obj/machinery/ai/networking/Destroy()
	GLOB.ai_networking_machines -= src
	disconnect()
	remote_connection_attempt = null
	return ..()

//Nadajnik nie grzeje się i nie potrzebuje chłodzenia
/obj/machinery/ai/networking/process_atmos()
	return FALSE

/obj/machinery/ai/networking/examine(mob/user)
	. = ..()
	. += span_notice("Etykieta: <b>[label]</b>.")
	if(partner)
		. += span_notice("Połączony z nadajnikiem <b>[partner.label]</b>.")
	else
		. += span_notice("Brak połączenia.")
	if(locked)
		. += span_warning("Nadajnik jest zablokowany.")

/obj/machinery/ai/networking/update_overlays()
	. = ..()
	var/matrix/turner = matrix()
	turner.Turn(rotation_to_partner - 180)
	dish_overlay.transform = turner
	. += dish_overlay

/obj/machinery/ai/networking/proc/roundstart_connect()
	for(var/obj/machinery/ai/networking/other as anything in GLOB.ai_networking_machines)
		if(partner)
			return
		if(other == src || other.partner)
			continue
		if(roundstart_connection && other.label == roundstart_connection)
			connect_to_partner(other, TRUE)
			return

///Czy da się połączyć z tym nadajnikiem (ten sam pokład albo oba na stacji)
/obj/machinery/ai/networking/proc/can_reach(obj/machinery/ai/networking/other)
	if(other == src || QDELETED(other))
		return FALSE
	if(other.z == z)
		return TRUE
	return is_station_level(z) && is_station_level(other.z)

/obj/machinery/ai/networking/proc/connect_to_partner(obj/machinery/ai/networking/target, forced = FALSE)
	remote_connection_attempt = null
	if(partner || target.partner || !can_reach(target))
		return FALSE
	if(target.locked && !forced)
		return FALSE
	partner = target
	target.partner = src
	rotation_to_partner = get_angle(src, target)
	target.rotation_to_partner = get_angle(target, src)
	update_appearance()
	target.update_appearance()
	queue_ai_network_rebuild()
	return TRUE

/obj/machinery/ai/networking/proc/disconnect()
	if(!partner)
		return
	var/obj/machinery/ai/networking/old_partner = partner
	partner = null
	old_partner.partner = null
	old_partner.rotation_to_partner = 0
	old_partner.update_appearance()
	rotation_to_partner = 0
	update_appearance()
	queue_ai_network_rebuild()

/obj/machinery/ai/networking/multitool_act(mob/living/user, obj/item/tool)
	if(partner)
		balloon_alert(user, "już połączony!")
		return TRUE
	remote_connection_attempt = null
	var/list/targets = list()
	for(var/obj/machinery/ai/networking/other as anything in GLOB.ai_networking_machines)
		if(other.partner || !can_reach(other))
			continue
		targets[other.label] = other
	var/choice = tgui_input_list(user, "Wybierz nadajnik, z którym chcesz się połączyć.", "Nadajnik sieci SI", targets)
	if(!choice || !user.canUseTopic(src, BE_CLOSE))
		return TRUE
	remote_connection_attempt = targets[choice]
	to_chat(user, span_notice("Nadajnik jest gotowy. Obróć antenę kluczem w stronę drugiego nadajnika, a potem zatwierdź połączenie śrubokrętem."))
	return TRUE

/obj/machinery/ai/networking/wrench_act(mob/living/user, obj/item/tool)
	if(partner)
		balloon_alert(user, "już połączony!")
		return TRUE
	var/new_rotation = tgui_input_number(user, "Obrót anteny (0-360):", "Nadajnik sieci SI", rotation_to_partner, 360, 0)
	if(isnull(new_rotation) || !user.canUseTopic(src, BE_CLOSE))
		return TRUE
	rotation_to_partner = clamp(new_rotation, 0, 360)
	tool.play_tool_sound(src)
	update_appearance()
	return TRUE

/obj/machinery/ai/networking/screwdriver_act(mob/living/user, obj/item/tool)
	if(partner)
		balloon_alert(user, "już połączony!")
		return TRUE
	if(!remote_connection_attempt)
		// Bez wybranego celu śrubokręt otwiera panel
		default_deconstruction_screwdriver(user, icon_state, icon_state, tool)
		return TRUE
	var/actual_angle = get_angle(src, remote_connection_attempt)
	var/obj/machinery/ai/networking/target = remote_connection_attempt
	if(abs(rotation_to_partner - actual_angle) < 20 && connect_to_partner(target))
		to_chat(user, span_notice("Połączono z nadajnikiem [target.label]!"))
	else
		to_chat(user, span_warning("Nie udało się nawiązać połączenia!"))
	return TRUE

/obj/machinery/ai/networking/wirecutter_act(mob/living/user, obj/item/tool)
	if(!partner)
		balloon_alert(user, "nie jest połączony!")
		return TRUE
	to_chat(user, span_notice("Przerywasz połączenie."))
	disconnect()
	return TRUE

/obj/machinery/ai/networking/crowbar_act(mob/living/user, obj/item/tool)
	default_deconstruction_crowbar(tool)
	return TRUE

/obj/machinery/ai/networking/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiNetworking", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/ai/networking/ui_data(mob/user)
	var/list/data = list()
	data["label"] = label
	data["connected"] = partner?.label
	data["locked"] = locked
	data["possible_targets"] = list()
	for(var/obj/machinery/ai/networking/other as anything in GLOB.ai_networking_machines)
		if(other != partner && (other.locked || !can_reach(other)))
			continue
		data["possible_targets"] += other.label
	return data

/obj/machinery/ai/networking/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("toggle_lock")
			locked = !locked
			return TRUE
	if(locked)
		return
	switch(action)
		if("switch_label")
			var/new_label = tgui_input_text(usr, "Nowa etykieta", "Etykieta nadajnika", label, 16)
			if(!new_label || locked)
				return
			for(var/obj/machinery/ai/networking/other as anything in GLOB.ai_networking_machines)
				if(other.label == new_label)
					to_chat(usr, span_warning("Nadajnik z taką etykietą już istnieje!"))
					return
			label = new_label
			return TRUE
		if("connect")
			var/target_label = params["target_label"]
			for(var/obj/machinery/ai/networking/other as anything in GLOB.ai_networking_machines)
				if(other.label != target_label)
					continue
				if(other.locked)
					to_chat(usr, span_warning("Nie można połączyć z [target_label]: nadajnik jest zablokowany."))
					return
				if(other.partner)
					to_chat(usr, span_warning("Nie można połączyć z [target_label]: nadajnik ma już połączenie."))
					return
				if(connect_to_partner(other))
					to_chat(usr, span_notice("Połączono z [target_label]."))
				return TRUE
		if("disconnect")
			disconnect()
			return TRUE

/obj/item/circuitboard/machine/networking_machine
	name = "nadajnik sieci SI (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/ai/networking
	req_components = list(
		/obj/item/stock_parts/matter_bin = 4,
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stock_parts/scanning_module = 4,
		/obj/item/stack/sheet/glass = 4,
		/obj/item/stack/cable_coil = 1,
	)

/datum/design/board/networking_machine
	name = "Machine Design (AI Networking Machine)"
	desc = "Płytka nadajnika łączącego odległe sieci SI."
	id = "networking_machine"
	build_path = /obj/item/circuitboard/machine/networking_machine
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/ethernet_coil
	name = "Ethernet Coil"
	id = "ethernet_coil"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 10, /datum/material/glass = 5)
	build_path = /obj/item/stack/ethernet_coil
	category = list("initial", "Tools", "Tool Designs")
	maxstack = MAXCOIL
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE
