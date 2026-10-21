
////////////////////////////////////
///// Rendering stats window ///////
////////////////////////////////////

// AQUILA: główny panel mecha jest w TGUI (okno "Mecha", na wzór tg), a okno
// dostępu/serwisu (przeciągnięcie karty ID z zewnątrz) to okno "MechaAccess"
// z datumem /datum/mecha_access_panel niżej. Opisy modułów to nadal HTML
// z get_equip_info() (odnośniki do Topic() modułów i select_equip).

/obj/mecha/ui_status(mob/user, datum/ui_state/state)
	if(user != occupant)
		return UI_CLOSE
	if(user.incapacitated())
		return UI_DISABLED
	return UI_INTERACTIVE

/obj/mecha/ui_interact(mob/user, datum/tgui/ui)
	if(user != occupant)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Mecha", name)
		ui.open()

/obj/mecha/ui_static_data(mob/user)
	var/list/data = list()
	data["internal_damage_keys"] = list(
		"MECHA_INT_FIRE" = MECHA_INT_FIRE,
		"MECHA_INT_TEMP_CONTROL" = MECHA_INT_TEMP_CONTROL,
		"MECHA_INT_TANK_BREACH" = MECHA_INT_TANK_BREACH,
		"MECHA_INT_CONTROL_LOST" = MECHA_INT_CONTROL_LOST,
		"MECHA_INT_SHORT_CIRCUIT" = MECHA_INT_SHORT_CIRCUIT,
	)
	data["warning_high_pressure"] = WARNING_HIGH_PRESSURE
	data["min_frequency"] = radio?.freerange ? MIN_FREE_FREQ : MIN_FREQ
	data["max_frequency"] = radio?.freerange ? MAX_FREE_FREQ : MAX_FREQ
	return data

/obj/mecha/ui_data(mob/user)
	var/list/data = list()
	data["name"] = name
	data["integrity"] = round(obj_integrity, 1)
	data["integrity_max"] = max_integrity
	var/charge = get_charge()
	data["has_cell"] = !isnull(charge)
	data["power_level"] = isnull(charge) ? 0 : round(charge, 1)
	data["power_max"] = cell ? cell.maxcharge : 0
	data["internal_damage"] = internal_damage
	data["lights"] = lights
	data["has_lights"] = !!lights_power
	data["enclosed"] = enclosed
	data["has_tank"] = !!internal_tank
	data["use_internal_tank"] = use_internal_tank
	if(internal_tank)
		var/datum/gas_mixture/int_tank_air = internal_tank.return_air()
		data["tank_pressure"] = round(int_tank_air.return_pressure(), 0.01)
		data["tank_temperature"] = round(int_tank_air.return_temperature(), 0.1)
		data["port_connected"] = !!internal_tank.connected_port
	data["cabin_pressure"] = round(return_pressure(), 0.01)
	data["cabin_temperature"] = round(return_temperature(), 0.1)
	data["dna_lock"] = dna_lock
	data["id_upload"] = add_req_access
	data["maint_access"] = maint_access
	data["maint_protocols"] = construction_state != MECHA_LOCKED
	data["has_radio"] = !!radio
	if(radio)
		data["radio_broadcasting"] = radio.broadcasting
		data["radio_listening"] = radio.listening
		data["radio_frequency"] = radio.frequency
	// Akcje specjalne mecha (stan + przełączanie przez istniejące przyciski akcji)
	var/list/actions = list()
	if(defense_action.owner)
		actions += list(list("key" = "defense", "name" = "Tryb obronny", "state" = defense_mode ? "Włączony" : "Wyłączony", "active" = defense_mode))
	if(overload_action.owner)
		actions += list(list("key" = "overload", "name" = "Przeciążenie siłowników nóg", "state" = leg_overload_mode ? "Włączone" : "Wyłączone", "active" = leg_overload_mode))
	if(smoke_action.owner)
		actions += list(list("key" = "smoke", "name" = "Zasłona dymna", "state" = "Ładunki: [smoke]", "active" = FALSE))
	if(zoom_action.owner)
		actions += list(list("key" = "zoom", "name" = "Przybliżenie", "state" = zoom_mode ? "Włączone" : "Wyłączone", "active" = zoom_mode))
	if(switch_damtype_action.owner)
		actions += list(list("key" = "damtype", "name" = "Narzędzia ramion", "state" = "[damtype]", "active" = FALSE))
	if(phasing_action.owner)
		actions += list(list("key" = "phasing", "name" = "Modulator fazowy", "state" = phasing ? "Włączony" : "Wyłączony", "active" = phasing))
	data["actions"] = actions
	// Wyposażenie; "info" to HTML z get_equip_info() z odnośnikami do akcji modułów
	var/list/modules = list()
	for(var/obj/item/mecha_parts/mecha_equipment/equip as anything in equipment)
		modules += list(list(
			"ref" = REF(equip),
			"name" = equip.name,
			"info" = equip.get_equip_info(),
			"selected" = (selected == equip),
			"selectable" = equip.selectable,
			"detachable" = equip.detachable,
			"ready" = equip.equip_ready,
		))
	data["modules"] = modules
	data["max_equip"] = max_equip
	// Ładownia (Ripley i szafkomech)
	var/list/cargo_list = get_tgui_cargo()
	data["has_cargo"] = !isnull(cargo_list)
	if(cargo_list)
		var/list/cargo_data = list()
		for(var/obj/O in cargo_list)
			cargo_data += list(list("name" = "[O]", "ref" = REF(O)))
		data["cargo"] = cargo_data
	return data

/// AQUILA: ładownia mecha do okna TGUI (cargo jest zdefiniowane osobno na Ripleyu i szafkomechu)
/obj/mecha/proc/get_tgui_cargo()
	if(istype(src, /obj/mecha/working/ripley))
		var/obj/mecha/working/ripley/R = src
		return R.cargo
	if(istype(src, /obj/mecha/working/lockermech))
		var/obj/mecha/working/lockermech/L = src
		return L.cargo
	return null

/obj/mecha/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(usr != occupant || usr.incapacitated())
		return
	switch(action)
		if("changename")
			var/userinput = stripped_input(usr, "Wybierz nową nazwę egzoszkieletu.", "Zmień nazwę egzoszkieletu", "", MAX_NAME_LEN)
			if(!userinput || usr != occupant || usr.incapacitated())
				return
			name = userinput
			return TRUE
		if("toggle_lights")
			INVOKE_ASYNC(lights_action, TYPE_PROC_REF(/datum/action/innate, Activate))
			return TRUE
		if("toggle_internals")
			if(!internal_tank || !enclosed)
				return
			INVOKE_ASYNC(internals_action, TYPE_PROC_REF(/datum/action/innate, Activate))
			return TRUE
		if("toggle_action")
			var/datum/action/innate/mecha/mech_action
			switch(params["key"])
				if("defense")
					mech_action = defense_action
				if("overload")
					mech_action = overload_action
				if("smoke")
					mech_action = smoke_action
				if("zoom")
					mech_action = zoom_action
				if("damtype")
					mech_action = switch_damtype_action
				if("phasing")
					mech_action = phasing_action
			if(!mech_action?.owner)
				return
			INVOKE_ASYNC(mech_action, TYPE_PROC_REF(/datum/action/innate, Activate))
			return TRUE
		if("select_equip")
			var/obj/item/mecha_parts/mecha_equipment/equip = locate(params["ref"]) in equipment
			if(!equip || !equip.selectable)
				return
			selected = equip
			occupant_message("Przełączasz na [equip].")
			visible_message("[src] raises [equip].")
			return TRUE
		if("detach")
			var/obj/item/mecha_parts/mecha_equipment/equip = locate(params["ref"]) in equipment
			if(!equip || !equip.detachable)
				return
			equip.detach()
			return TRUE
		if("drop_from_cargo")
			var/list/cargo_list = get_tgui_cargo()
			var/obj/O = locate(params["ref"]) in cargo_list
			if(!O)
				return
			occupant_message("<span class='notice'>Wyładowujesz [O].</span>")
			O.forceMove(drop_location())
			cargo_list -= O
			log_message("Unloaded [O].", LOG_MECHA)
			return TRUE
		if("rmictoggle")
			if(!radio)
				return
			radio.broadcasting = !radio.broadcasting
			return TRUE
		if("rspktoggle")
			if(!radio)
				return
			radio.listening = !radio.listening
			return TRUE
		if("rfreq")
			if(!radio)
				return
			var/new_frequency = text2num(params["frequency"])
			if(isnull(new_frequency))
				return
			radio.set_frequency(sanitize_frequency(round(new_frequency), radio.freerange))
			return TRUE
		if("toggle_id_upload")
			add_req_access = !add_req_access
			return TRUE
		if("toggle_maint_access")
			if(construction_state)
				occupant_message("<span class='danger'>Działają protokoły serwisowe</span>")
				return
			maint_access = !maint_access
			return TRUE
		if("toggle_port")
			if(!internal_tank)
				return
			if(internal_tank.connected_port)
				if(internal_tank.disconnect())
					occupant_message("Odłączono od portu systemu powietrza.")
					log_message("Disconnected from gas port.", LOG_MECHA)
				else
					occupant_message("<span class='warning'>Nie można odłączyć od portu systemu powietrza!</span>")
			else
				var/obj/machinery/atmospherics/components/unary/portables_connector/possible_port = locate() in loc
				if(internal_tank.connect(possible_port))
					occupant_message("Podłączono do portu systemu powietrza.")
					log_message("Connected to gas port.", LOG_MECHA)
				else
					occupant_message("<span class='warning'>Nie można podłączyć do portu systemu powietrza!</span>")
			return TRUE
		if("dna_lock")
			if(obj_flags & EMAGGED)
				occupant_message("Konsola sterowania świeci na czerwono, nie zdoławszy powiązać się z twoim DNA.")
				return
			if(!iscarbon(occupant) || !occupant.dna)
				occupant_message("Konsola sterowania świeci na czerwono, nie zdoławszy powiązać się z twoim DNA.")
				return
			dna_lock = occupant.dna.unique_enzymes
			occupant_message("Konsola sterowania jasno błyska, wiążąc się z twoim DNA.")
			return TRUE
		if("reset_dna")
			dna_lock = null
			return TRUE
		if("repair_int_control_lost")
			if(!(internal_damage & MECHA_INT_CONTROL_LOST))
				return
			occupant_message("Ponowna kalibracja układu koordynacji.")
			log_message("Recalibration of coordination system started.", LOG_MECHA)
			addtimer(CALLBACK(src, PROC_REF(stationary_repair), loc), 100, TIMER_UNIQUE)
			return TRUE

/// Otwiera okno dostępu/serwisu dla kogoś z kartą ID przy mechu (z attackby)
/obj/mecha/proc/output_maintenance_dialog(obj/item/card/id/id_card, mob/user)
	if(!id_card || !user)
		return
	var/datum/mecha_access_panel/panel = new(src, id_card)
	panel.ui_interact(user)

/**
 * Okno dostępu i protokołów serwisowych mecha dla osoby z kartą ID stojącej obok.
 * Osobny datum, bo okno "Mecha" na samym mechu jest tylko dla pilota.
 */
/datum/mecha_access_panel
	var/obj/mecha/mech
	var/obj/item/card/id/id_card
	/// FALSE - protokoły serwisowe, TRUE - edycja kodów dostępu
	var/editing_access = FALSE

/datum/mecha_access_panel/New(obj/mecha/new_mech, obj/item/card/id/new_card)
	. = ..()
	mech = new_mech
	id_card = new_card

/datum/mecha_access_panel/Destroy(force)
	mech = null
	id_card = null
	return ..()

/datum/mecha_access_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MechaAccess", mech.name)
		ui.open()

/datum/mecha_access_panel/ui_close(mob/user, datum/tgui/tgui)
	. = ..()
	qdel(src)

/datum/mecha_access_panel/ui_status(mob/user, datum/ui_state/state)
	if(QDELETED(mech) || QDELETED(id_card))
		return UI_CLOSE
	if(!in_range(mech, user))
		return UI_CLOSE
	if(user.incapacitated())
		return UI_DISABLED
	return UI_INTERACTIVE

/datum/mecha_access_panel/ui_data(mob/user)
	var/list/data = list()
	data["editing_access"] = editing_access
	data["add_req_access"] = mech.add_req_access
	data["maint_access"] = mech.maint_access
	data["maint_active"] = mech.construction_state > MECHA_LOCKED
	data["hatch_open"] = mech.construction_state == MECHA_OPEN_HATCH
	data["has_cell"] = !!mech.cell
	data["has_scanmod"] = !!mech.scanmod
	data["has_capacitor"] = !!mech.capacitor
	data["internal_tank_valve"] = mech.internal_tank_valve
	if(editing_access)
		var/list/stored = list()
		for(var/a in mech.operation_req_access)
			stored += list(list("id" = a, "desc" = get_access_desc(a)))
		data["stored_access"] = stored
		var/list/card = list()
		for(var/a in id_card.access)
			if(a in mech.operation_req_access)
				continue
			var/a_name = get_access_desc(a)
			if(!a_name)
				continue //there's some strange access without a name
			card += list(list("id" = a, "desc" = a_name))
		data["card_access"] = card
	return data

/datum/mecha_access_panel/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("req_access")
			if(!mech.add_req_access)
				return
			editing_access = TRUE
			return TRUE
		if("back")
			editing_access = FALSE
			return TRUE
		if("maint_access")
			if(!mech.maint_access)
				return
			if(mech.construction_state == MECHA_LOCKED)
				mech.construction_state = MECHA_SECURE_BOLTS
				to_chat(usr, "Śruby mocujące są teraz odsłonięte.")
			else if(mech.construction_state == MECHA_SECURE_BOLTS)
				mech.construction_state = MECHA_LOCKED
				to_chat(usr, "Śruby mocujące są teraz schowane.")
			return TRUE
		if("drop_cell")
			if(mech.construction_state == MECHA_OPEN_HATCH && mech.cell)
				mech.cell.forceMove(get_turf(mech))
				mech.cell = null
			return TRUE
		if("drop_scanmod")
			if(mech.construction_state == MECHA_OPEN_HATCH && mech.scanmod)
				mech.scanmod.forceMove(get_turf(mech))
				mech.scanmod = null
			return TRUE
		if("drop_cap")
			if(mech.construction_state == MECHA_OPEN_HATCH && mech.capacitor)
				mech.capacitor.forceMove(get_turf(mech))
				mech.capacitor = null
			return TRUE
		if("add_req_access")
			if(!mech.add_req_access)
				return
			var/access = text2num(params["access"])
			if(!(access in id_card.access))
				return
			mech.operation_req_access |= access
			return TRUE
		if("del_req_access")
			if(!mech.add_req_access)
				return
			mech.operation_req_access -= text2num(params["access"])
			return TRUE
		if("finish_req_access")
			mech.add_req_access = 0
			editing_access = FALSE
			return TRUE
		if("set_internal_tank_valve")
			if(!mech.construction_state)
				return
			var/new_pressure = text2num(params["pressure"])
			if(isnull(new_pressure))
				return
			mech.internal_tank_valve = new_pressure
			to_chat(usr, "<span class='notice'>Wewnętrzny zawór ciśnienia ustawiono na [mech.internal_tank_valve] kPa.</span>")
			return TRUE

/////////////////
///// Topic /////
/////////////////

/obj/mecha/Topic(href, href_list)
	..()

	if(!usr || usr != occupant || usr.incapacitated())
		return

	//Selects the mech equipment/weapon (odnośnik z get_equip_info() w oknie TGUI).
	if(href_list["select_equip"])
		var/obj/item/mecha_parts/mecha_equipment/equip = locate(href_list["select_equip"]) in src
		if(!equip || !equip.selectable)
			return
		selected = equip
		occupant_message("Przełączasz na [equip].")
		visible_message("[src] raises [equip].")
		SStgui.update_uis(src)
		return

///Repairs internal damage if the mech hasn't moved.
/obj/mecha/proc/stationary_repair(location)
	if(location == loc)
		clearInternalDamage(MECHA_INT_CONTROL_LOST)
		occupant_message("<span class='notice'>Kalibracja udana.</span>")
		log_message("Recalibration of coordination system finished with 0 errors.", LOG_MECHA)
	else
		occupant_message("<span class='warning'>Kalibracja nieudana!</span>")
		log_message("Recalibration of coordination system failed with 1 error.", LOG_MECHA, color="red")
