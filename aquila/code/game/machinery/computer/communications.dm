/obj/machinery/computer/communications
	/// Cooldown before you can call in an ERT
	COOLDOWN_DECLARE(static/reinforcement_action_cooldown)
	/// Cooldown before you can wake up another wave of assistants from cryostasis
	COOLDOWN_DECLARE(static/crew_wake_cooldown)
	/// Przełącznik oświetlenia nocnego: ogłoszenie i wiadomość dla adminów najwyżej raz na minutę
	COOLDOWN_DECLARE(static/nightshift_toggle_cooldown)
	/// Ckey of the admin ghost who logged in with every access. Their window closing (also after moving to another mob
	/// or disconnecting) logs the console out again; another admin closing their own window does not
	var/admin_ghost_ckey

/obj/machinery/computer/communications/ui_close(mob/user)
	. = ..()
	if(admin_ghost_ckey && user?.ckey == admin_ghost_ckey && authorize_name == "Centrala")
		admin_ghost_ckey = null
		authenticated = FALSE
		authorize_access = null
		authorize_name = null

/obj/machinery/computer/communications/proc/authenticated_as_cap_sec_or_silicon(mob/user)
	if (issilicon(user))
		return TRUE
	return (ACCESS_CAPTAIN in authorize_access) || (ACCESS_HOS in authorize_access)

/obj/machinery/computer/communications/ui_act(action, list/params)
	. = ..()
	if (.)
		return

	switch(action)
		if("requestERT")
			if (!authenticated_as_cap_sec_or_silicon(usr))
				return
			if (!COOLDOWN_FINISHED(src, reinforcement_action_cooldown))
				return
			var/reason = trim(html_encode(params["reason"]), MAX_MESSAGE_LEN)
			ert_request(reason, usr)
			to_chat(usr, "<span class='notice'>Wysłano prośbę.</span>")
			usr.log_message("has requested an emergency response team from Centcom with reason \"[reason]\"", LOG_SAY)
			priority_announce("[usr] prosi o oddział szybkiego reagowania. Zgoda lub odmowa zostanie wkrótce przesłana.", "Prośba o oddział szybkiego reagowania", SSstation.announcer.get_rand_report_sound())
			playsound(src, 'sound/machines/terminal_prompt.ogg', 50, FALSE)
			COOLDOWN_START(src, reinforcement_action_cooldown, 15 MINUTES)
			. = TRUE
		if("requestCrewWake")
			if (!authenticated_as_cap_sec_or_silicon(usr))
				return
			if (!COOLDOWN_FINISHED(src, crew_wake_cooldown))
				return
			var/reason = trim(html_encode(params["reason"]), MAX_MESSAGE_LEN)
			crew_wake_request(reason, usr)
			to_chat(usr, "<span class='notice'>Prośba wysłana.</span>")
			usr.log_message("has requested a crew wake from cryostasis with reason \"[reason]\"", LOG_SAY)
			priority_announce("Wysłano prośbę o wybudzenie dodatkowej załogi z kriostazy (zlecenie: [usr]). Potwierdzenie lub odmowa zostanie wkrótce przesłana.", "Prośba o wybudzenie załogi", SSstation.announcer.get_rand_report_sound())
			playsound(src, 'sound/machines/terminal_prompt.ogg', 50, FALSE)
			COOLDOWN_START(src, crew_wake_cooldown, 15 MINUTES)
			. = TRUE
		// AQUILA: kapitan wyłącza oświetlenie nocne na całym statku
		if("toggleNightShift")
			if (!authenticated_as_non_silicon_captain(usr) || !CONFIG_GET(flag/enable_night_shifts))
				return
			if (!COOLDOWN_FINISHED(src, nightshift_toggle_cooldown))
				to_chat(usr, "<span class='warning'>Oświetlenie można przełączyć ponownie za [DisplayTimeText(COOLDOWN_TIMELEFT(src, nightshift_toggle_cooldown))].</span>")
				return
			COOLDOWN_START(src, nightshift_toggle_cooldown, 1 MINUTES)
			SSnightshift.toggle_captain_disabled(usr)
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
			. = TRUE

/obj/machinery/computer/communications/ui_data(mob/user)
	. = ..()
	if ((authenticated || issilicon(user)) && authenticated_as_non_silicon_captain(user) && CONFIG_GET(flag/enable_night_shifts))
		.["canToggleNightShift"] = TRUE
		.["nightShiftDisabled"] = SSnightshift.captain_disabled

// Łączność mają też konsole na statkach załogi poza poziomem ze znacznikiem stacji: górniczy statek i główny statek
// załadowany jako instancja (ZTRAITS_MINING_SHIP i ZTRAITS_BOARDABLE_SHIP nie mają ZTRAIT_STATION). Bez tego okno
// pokazywało tylko „Nie można nawiązać połączenia ze statkiem.”, a każda akcja była odrzucana.
/obj/machinery/computer/communications/has_communication()
	. = ..()
	if(.)
		return
	var/obj/structure/overmap/ship = get_overmap()
	return ship && (ship.role == MAIN_OVERMAP || ship.role == MAIN_MINING_SHIP)
