/proc/gq_announce(message, sound='nsv13/sound/effects/ship/action_stations.ogg', color_override = "red") // AQ EDIT - kolor ramki
	if(!message)
		return

	// AQ EDIT - ramka ogłoszenia jak minor_announce (układ tg)
	var/complete_msg = CHAT_ALERT_SPAN(color_override, ANNOUNCEMENT_HEADER(MINOR_ANNOUNCEMENT_TITLE(html_encode("Uwaga:"))) + MINOR_ANNOUNCEMENT_TEXT(html_encode(message)))
	for(var/mob/M in GLOB.player_list)
		if(!isnewplayer(M) && M.can_hear())
			to_chat(M, complete_msg)
			if(M.client.prefs.toggles & PREFTOGGLE_SOUND_ANNOUNCEMENTS)
				SEND_SOUND(M, sound(sound))

/area
	var/redalert = FALSE //General quarters active?

/proc/toggle_gq_lights(state)
	for(var/X in GLOB.teleportlocs) //Update the lights
		var/area/AR = GLOB.teleportlocs[X]
		if(AR.redalert == state)
			continue
		AR.redalert = state
		for(var/obj/machinery/light/L in AR)
			L.update()

/proc/mini_announce(message, from, html_encode = TRUE) //Even less obtrusive than minor_announce!
	if(!message)
		return
	if (html_encode)
		from = html_encode(from)
		message = html_encode(message)
	for(var/mob/M in GLOB.player_list)
		if(!isnewplayer(M) && M.can_hear())
			var/complete_msg = "<meta charset='UTF-8'><h3>[from]</h3><span class='danger'>[message]</span><BR>"
			to_chat(M, complete_msg)
