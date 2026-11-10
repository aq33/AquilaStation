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
		// AQUILA: kapitan puszcza jukebox przez głośniki nagłośnienia na korytarzach
		if("togglePA")
			if (!authenticated_as_non_silicon_captain(usr))
				return
			var/obj/machinery/jukebox/jukebox = locate(params["ref"]) in pa_jukeboxes()
			if (!jukebox)
				return
			SSjukeboxes.set_shipwide(jukebox, !jukebox.shipwide)
			log_game("[key_name(usr)] [jukebox.shipwide ? "enabled" : "disabled"] shipwide broadcast of [jukebox] at [AREACOORD(jukebox)]")
			message_admins("[ADMIN_LOOKUPFLW(usr)] [jukebox.shipwide ? "włączył(a)" : "wyłączył(a)"] nadawanie [jukebox] na cały statek [ADMIN_JMP(jukebox)]")
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, FALSE)
			. = TRUE

/obj/machinery/computer/communications/ui_data(mob/user)
	. = ..()
	if (authenticated_as_non_silicon_captain(user) && CONFIG_GET(flag/enable_night_shifts))
		.["canToggleNightShift"] = TRUE
		.["nightShiftDisabled"] = SSnightshift.captain_disabled
	if (authenticated_as_non_silicon_captain(user))
		.["canControlPA"] = TRUE
		.["paOnShip"] = !!get_overmap()
		var/list/jukeboxes = list()
		for(var/obj/machinery/jukebox/jukebox as anything in pa_jukeboxes())
			jukeboxes += list(list(
				"ref" = REF(jukebox),
				"name" = "[jukebox]",
				"area" = get_area_name(jukebox, TRUE),
				"playing" = jukebox.yt_active,
				"title" = (jukebox.yt_active && jukebox.yt_index) ? jukebox.yt_tracks[jukebox.yt_index]["title"] : null,
				"shipwide" = jukebox.shipwide,
			))
		.["paJukeboxes"] = jukeboxes

/// Jukeboxy, które mogą nadawać przez nagłośnienie statku tej konsoli (bez radia i głośnika Syndykatu)
/obj/machinery/computer/communications/proc/pa_jukeboxes()
	. = list()
	var/obj/structure/overmap/ship = get_overmap()
	if(!ship)
		return
	for(var/obj/machinery/jukebox/jukebox in GLOB.machines)
		if(jukebox.can_broadcast && jukebox.get_overmap() == ship)
			. += jukebox

// Łączność mają też konsole na statkach załogi poza poziomem ze znacznikiem stacji: górniczy statek i główny statek
// załadowany jako instancja (ZTRAITS_MINING_SHIP i ZTRAITS_BOARDABLE_SHIP nie mają ZTRAIT_STATION). Bez tego okno
// pokazywało tylko „Nie można nawiązać połączenia ze statkiem.”, a każda akcja była odrzucana.
/obj/machinery/computer/communications/has_communication()
	. = ..()
	if(.)
		return
	var/obj/structure/overmap/ship = get_overmap()
	return ship && (ship.role == MAIN_OVERMAP || ship.role == MAIN_MINING_SHIP)
