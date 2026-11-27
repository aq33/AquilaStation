// AQUILA - zegar celi wpięty w kartotekę (Tau Ceti brigdoors.dm, pauza i ułaskawienie jak w CM-SS13 brig_system.dm).
// Start z więźniem ustawia „w areszcie”, koniec „po odbyciu kary”, ręczne zatrzymanie „na zwolnieniu warunkowym”.
// 30 s przed końcem ostrzega HUD-y ochrony. Pauza zachowuje pozostały czas, ułaskawienie daje Kapitan albo Komendant.

/// Ile przed końcem wyroku ostrzec HUD-y ochrony
#define BRIG_TIMER_WARNING (30 SECONDS)

/obj/machinery/door_timer
	/// Osadzony (imię z kartoteki albo wpisane ręcznie)
	var/prisoner_name
	/// Zarzuty (artykuły kodeksu, tekst)
	var/prisoner_crimes
	/// Pozostały czas zapauzowanego wyroku (decysekundy) albo null
	var/paused_left
	/// Ostrzeżenie przed końcem już poszło
	var/end_warned = FALSE
	/// Kto i za co ułaskawił (zwolnienie wymuszone przez ułaskawienie, nie przez „zatrzymaj”)
	var/pardon_text

/obj/machinery/door_timer/proc/cell_label()
	return id ? "cela [id]" : "cela"

/obj/machinery/door_timer/proc/prisoner_record()
	if(!prisoner_name || !GLOB.data_core)
		return null
	return find_record("name", prisoner_name, GLOB.data_core.security)

/obj/machinery/door_timer/process()
	. = ..()
	if(!timing || end_warned || !prisoner_name || (machine_stat & (NOPOWER|BROKEN)))
		return
	if(time_left() <= BRIG_TIMER_WARNING)
		end_warned = TRUE
		aq_security_hud_message("[capitalize(cell_label())]: [prisoner_name] wychodzi za [DisplayTimeText(time_left(), 1)].")

/obj/machinery/door_timer/timer_start()
	. = ..()
	if(!. || !prisoner_name)
		return
	end_warned = FALSE
	var/datum/data/record/record = prisoner_record()
	if(record)
		GLOB.data_core.set_criminal_status(record, "Incarcerated", "Zegar celi ([cell_label()])", prisoner_crimes ? "[prisoner_crimes], [DisplayTimeText(timer_duration, 1)]" : DisplayTimeText(timer_duration, 1))
	else
		aq_security_announce("[capitalize(cell_label())]: osadzono [prisoner_name] na [DisplayTimeText(timer_duration, 1)][prisoner_crimes ? " za: [prisoner_crimes]" : ""].")

/obj/machinery/door_timer/timer_end(forced = FALSE)
	var/name = prisoner_name
	. = ..()
	if(!.)
		return
	paused_left = null
	end_warned = FALSE
	if(!name)
		return
	var/new_status = forced && !pardon_text ? "Paroled" : "Discharged"
	var/reason = pardon_text || (forced ? "zwolnienie przed końcem wyroku" : "koniec wyroku")
	var/datum/data/record/record = prisoner_record()
	if(record)
		GLOB.data_core.set_criminal_status(record, new_status, "Zegar celi ([cell_label()])", reason)
	prisoner_name = null
	prisoner_crimes = null
	pardon_text = null

/// Wstrzymuje odliczanie, drzwi zostają zamknięte (więzień w ambulatorium, przesłuchanie)
/obj/machinery/door_timer/proc/pause_timer()
	if(!timing)
		return FALSE
	paused_left = time_left()
	timing = FALSE
	activation_time = null
	set_timer(paused_left) // „Uruchom” po pauzie liczy od pozostałego czasu, nie od pełnego wyroku
	update_icon()
	return TRUE

/obj/machinery/door_timer/proc/resume_timer()
	if(timing || isnull(paused_left))
		return FALSE
	set_timer(paused_left)
	paused_left = null
	activation_time = REALTIMEOFDAY
	timing = TRUE
	update_icon()
	return TRUE

/// Ułaskawienie: Kapitan albo Komendant (karta w ręce albo dostęp)
/obj/machinery/door_timer/proc/can_pardon(mob/user)
	var/obj/item/card/id/id = user?.get_idcard(TRUE)
	var/list/access = id ? id.GetAccess() : list()
	return (ACCESS_CAPTAIN in access) || (ACCESS_HOS in access)

/obj/machinery/door_timer/proc/pardon(mob/user)
	if(!prisoner_name || !(timing || !isnull(paused_left)))
		return FALSE
	pardon_text = "ułaskawienie: [aq_record_author(user)]"
	if(!timing) // zapauzowany: timer_end i tak otworzy drzwi
		timing = TRUE
	return timer_end(forced = TRUE)

/// Imię z rekordu ochrony osoby w zasięgu wzroku albo wpisane ręcznie
/obj/machinery/door_timer/proc/choose_prisoner(mob/user)
	var/list/choices = list()
	for(var/mob/living/carbon/human/H in view(7, src))
		var/visible = H.get_face_name(H.get_id_name(""))
		if(visible && visible != "Unknown")
			choices[visible] = visible
	choices["Wpisz ręcznie…"] = "manual"
	var/picked = tgui_input_list(user, "Kogo osadzasz?", "Zegar celi", choices)
	if(!picked || !can_interact(user))
		return FALSE
	var/name = choices[picked] == "manual" ? trim(tgui_input_text(user, "Imię i nazwisko osadzonego", "Zegar celi", max_length = MAX_NAME_LEN)) : picked
	if(!name || !can_interact(user))
		return FALSE
	prisoner_name = name
	return TRUE

/// Zarzuty z kodeksu (config/space_law.json); podpowiada wyrok zgodny z GenPopem
/obj/machinery/door_timer/proc/choose_crimes(mob/user)
	var/list/names = list()
	for(var/list/category as anything in get_space_law_catalog())
		for(var/list/crime as anything in category["crimes"])
			names += crime["name"]
	var/list/picked = tgui_input_checkboxes(user, "Zarzuty", "Zegar celi", names, 0)
	if(!length(picked) || !can_interact(user))
		return FALSE
	prisoner_crimes = jointext(picked, ", ")
	var/sentence = aq_sentence_for_crimes(picked)
	if(sentence && !timing)
		set_timer(sentence)
	return TRUE

/// Alarm bojowy (czerwony i wyżej): zegar wolno uruchomić bez imienia, żeby nie blokować walki
/obj/machinery/door_timer/proc/combat_alert()
	return GLOB.security_level >= SEC_LEVEL_RED

/obj/machinery/door_timer/ui_data()
	var/list/data = ..()
	data["prisoner"] = prisoner_name
	data["crimes"] = prisoner_crimes
	data["paused"] = !isnull(paused_left)
	data["can_pardon"] = !!prisoner_name && (timing || !isnull(paused_left))
	data["needs_prisoner"] = !combat_alert()
	return data

/obj/machinery/door_timer/ui_act(action, params)
	switch(action)
		if("start")
			if(!prisoner_name && !combat_alert())
				to_chat(usr, "<span class='warning'>Najpierw wpisz osadzonego.</span>")
				return FALSE
		if("set_prisoner", "set_crimes", "pause", "resume", "pardon")
			if(machine_stat & (NOPOWER|BROKEN))
				return FALSE
			if(!allowed(usr))
				to_chat(usr, "<span class='warning'>Odmowa dostępu.</span>")
				return FALSE
			switch(action)
				if("set_prisoner")
					if(timing || !isnull(paused_left))
						return FALSE
					. = choose_prisoner(usr)
				if("set_crimes")
					. = choose_crimes(usr)
				if("pause")
					. = pause_timer()
					if(.)
						investigate_log("[key_name(usr)] paused [id]'s timer with [time_left(seconds = TRUE)] seconds left", INVESTIGATE_RECORDS)
				if("resume")
					. = resume_timer()
				if("pardon")
					if(!can_pardon(usr))
						to_chat(usr, "<span class='warning'>Ułaskawić może tylko Kapitan albo Komendant.</span>")
						return FALSE
					investigate_log("[key_name(usr)] pardoned [prisoner_name] in cell [id]", INVESTIGATE_RECORDS)
					. = pardon(usr)
			ui_update()
			return
	return ..()

// GenPop: to samo ostrzeżenie przed końcem wyroku na karcie więźnia
/obj/item/card/id/prisoner
	var/end_warned = FALSE

/obj/item/card/id/prisoner/process(delta_time)
	. = ..()
	if(end_warned || served_time >= sentence || (sentence - served_time) * 10 > BRIG_TIMER_WARNING)
		return
	end_warned = TRUE
	aq_security_hud_message("GenPop: [registered_name] kończy wyrok za [DisplayTimeText((sentence - served_time) * 10, 1)].")

#undef BRIG_TIMER_WARNING
