// Pulpit fabrykatora w formie urządzenia (port pomysłu polonium14/polonium-station#1283).
// Autolat, drukarka komponentów, protolaty, techfaby i drukarka płytek: zielony ekran z katalogiem,
// ploter rysujący drukowany przedmiot, kolejka jako papierowe zlecenia, wskaźniki materiałów,
// pole ilości, zbiornik odczynników i STOP. Fabrykator egzoszkieletów zostaje przy swoim oknie.
// Okno wybiera aq_fabricator_interface() (jednolinijkowe AQ EDIT w ui_interact w core).

/// Nazwa okna TGUI fabrykatora: pulpit albo stare okno (klawisz KLASYCZNE).
/obj/machinery/proc/aq_fabricator_interface(mob/user, classic_interface)
	return aq_wants_classic_ui(user) ? classic_interface : "LathePulpit"

/obj/machinery/modular_fabricator/ui_close(mob/user, datum/tgui/tgui)
	. = ..()
	aq_forget_classic_ui(user)

/obj/machinery/rnd/production/ui_close(mob/user)
	. = ..()
	aq_forget_classic_ui(user)

/obj/machinery/modular_fabricator/ui_static_data(mob/user)
	var/list/data = ..()
	data["queued"] = TRUE
	data["canSync"] = can_sync
	return data

/obj/machinery/modular_fabricator/ui_data(mob/user)
	var/list/data = ..()
	data["powered"] = !(machine_stat & NOPOWER)
	data["silo"] = FALSE
	data["hacked"] = !!(obj_flags & EMAGGED)
	// busy trwa od startu wydruku do końca make_item(); bez niego czekanie na materiały wyglądało jak druk
	if(busy && being_built && total_build_time && process_completion_world_tick)
		data["printing"] = list(
			"id" = being_built.id,
			"name" = being_built.name,
			"left" = max(0, process_completion_world_tick - world.time),
			"total" = total_build_time,
		)
	return data

/obj/machinery/modular_fabricator/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("classic")
			aq_open_classic_ui(usr)
			return TRUE
		if("stop_all")
			return aq_stop_all()

/// STOP przytrzymany: cała kolejka znika (materiały pobiera dopiero druk, więc nic nie przepada)
/obj/machinery/modular_fabricator/proc/aq_stop_all()
	queue_stopped = TRUE
	item_queue.Cut()
	playsound(src, 'sound/machines/buzz-two.ogg', 30, TRUE)
	return TRUE

/obj/machinery/rnd/production
	/// Nazwa, identyfikator projektu, liczba sztuk i czasy bieżącego wydruku (dla plotera w pulpicie)
	var/aq_print_name
	var/aq_print_id
	var/aq_print_amount = 0
	var/aq_print_start = 0
	var/aq_print_end = 0

/obj/machinery/rnd/production/user_try_print_id(id, amount)
	. = ..()
	if(!.)
		return
	var/datum/design/design = SSresearch.techweb_design_by_id(id)
	if(!design)
		return
	if(istext(amount))
		amount = text2num(amount)
	amount = clamp(amount || 1, 1, 50)
	var/timecoeff = design.lathe_time_factor / efficiency_coeff
	aq_print_name = design.name
	aq_print_id = design.id
	aq_print_amount = amount
	aq_print_start = world.time
	aq_print_end = world.time + (32 * timecoeff * amount) ** 0.8

/obj/machinery/rnd/production/ui_static_data(mob/user)
	var/list/data = ..()
	data["queued"] = FALSE
	data["canSync"] = TRUE
	return data

/obj/machinery/rnd/production/ui_data(mob/user)
	var/list/data = ..()
	data["powered"] = !(machine_stat & NOPOWER)
	data["silo"] = !!materials?.silo
	data["hacked"] = !!(obj_flags & EMAGGED)
	if(aq_print_end > world.time)
		data["printing"] = list(
			"id" = aq_print_id,
			"name" = aq_print_name,
			"amount" = aq_print_amount,
			"left" = aq_print_end - world.time,
			"total" = max(1, aq_print_end - aq_print_start),
		)
	return data

/obj/machinery/rnd/production/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(action == "classic")
		aq_open_classic_ui(usr)
		return TRUE

// Okno z core odświeża się tylko przy ui_update(), a ploter pulpitu potrzebuje postępu wydruku
/obj/machinery/rnd/production/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	var/datum/tgui/opened = SStgui.get_open_ui(user, src)
	opened?.set_autoupdate(TRUE)
