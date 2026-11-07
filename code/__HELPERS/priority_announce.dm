#define DEFAULT_ALERT "alert_sound"

/proc/priority_announce(text, title = "", sound = DEFAULT_ALERT, type, sender_override, has_important_message, auth_id, color_override) // AQ EDIT - color_override jak w tg
	if(!text)
		return

	var/announcement = "" // AQ EDIT - bez <meta> w środku ramki
	if(sound == DEFAULT_ALERT)
		sound = SSstation.announcer.get_rand_alert_sound()

	if(sound && SSstation.announcer.event_sounds[sound])
		sound = SSstation.announcer.event_sounds[sound]

	// AQ EDIT START - ogłoszenia w układzie tg: nagłówek, podtytuł i tekst w pasiastej ramce (style chat_alert_* w tgchat)
	var/header
	if(type == "Priority")
		header = MAJOR_ANNOUNCEMENT_TITLE("Ogłoszenie Priorytetowe")
		if (title && length(title) > 0)
			header += SUBHEADER_ANNOUNCEMENT_TITLE(html_encode(title))
	else if(type == JOB_NAME_CAPTAIN)
		header = MAJOR_ANNOUNCEMENT_TITLE("Ogłoszenie Kapitana")
		GLOB.news_network.submit_article(html_encode(text), "Ogłoszenie kapitana", "Ogłoszenia stacji", null)

	else
		if(!sender_override)
			header = MAJOR_ANNOUNCEMENT_TITLE("Komunikat: [command_name()]")
		else
			header = MAJOR_ANNOUNCEMENT_TITLE(sender_override)
		if (title && length(title) > 0)
			header += SUBHEADER_ANNOUNCEMENT_TITLE(html_encode(title))

		if(!sender_override)
			if(title == "")
				GLOB.news_network.submit_article(text, "Komunikat Centrali", "Ogłoszenia stacji", null)
			else
				GLOB.news_network.submit_article(title + "<br><br>" + text, "Centrala", "Ogłoszenia stacji", null)
	announcement += ANNOUNCEMENT_HEADER(header)

	///If the announcer overrides alert messages, use that message.
	if(SSstation.announcer.custom_alert_message && !has_important_message)
		announcement += MAJOR_ANNOUNCEMENT_TEXT(SSstation.announcer.custom_alert_message)
	else
		announcement += MAJOR_ANNOUNCEMENT_TEXT(html_encode(text))
	if(auth_id)
		announcement += MAJOR_ANNOUNCEMENT_TEXT("-[auth_id]")
	announcement = CHAT_ALERT_SPAN(color_override, announcement)
	// AQ EDIT END

	var/s = sound(sound)
	for(var/mob/M in GLOB.player_list)
		if(!isnewplayer(M) && M.can_hear())
			to_chat(M, announcement)
			if(M.client.prefs.toggles & PREFTOGGLE_SOUND_ANNOUNCEMENTS)
				SEND_SOUND(M, s)

/proc/exploration_announce(text, z_value)
	var/announcement = CHAT_ALERT_SPAN(null, ANNOUNCEMENT_HEADER(MAJOR_ANNOUNCEMENT_TITLE("Komunikat: [command_name()]")) + MAJOR_ANNOUNCEMENT_TEXT(html_encode(text))) // AQ EDIT - układ tg

	for(var/mob/M in GLOB.player_list)
		if(isliving(M))
			var/turf/T = get_turf(M)
			if(istype(get_area(M), /area/shuttle/exploration) || T.z == z_value)
				to_chat(M, announcement)
		if(isobserver(M))
			to_chat(M, announcement)

/proc/print_command_report(text = "", title = null, announce=TRUE)
	if(!title)
		title = "Tajny komunikat: [command_name()]"

	if(announce)
		priority_announce("Raport został pobrany i wydrukowany na wszystkich konsolach komunikacyjnych.", "Nadchodzi tajna wiadomość", SSstation.announcer.get_rand_report_sound(), has_important_message = TRUE)
	var/datum/comm_message/M  = new
	M.title = title
	M.content =  text

	SScommunications.send_message(M)

/proc/minor_announce(message, title = "Uwaga:", alert, from, html_encode = TRUE, silent = FALSE, color_override) //nsv13 - silent arg // AQ EDIT - color_override jak w tg
	if(!message)
		return

	if (html_encode)
		title = html_encode(title)
		message = html_encode(message)

	// AQ EDIT START - układ tg: tytuł i tekst w ramce, kolor ramki z color_override
	var/complete_msg = ""
	if(title)
		complete_msg += ANNOUNCEMENT_HEADER(MINOR_ANNOUNCEMENT_TITLE(title))
	complete_msg += MINOR_ANNOUNCEMENT_TEXT(message)
	if(from)
		complete_msg += MINOR_ANNOUNCEMENT_TEXT("-[from]")
	complete_msg = CHAT_ALERT_SPAN(color_override, complete_msg)
	// AQ EDIT END
	for(var/mob/M in GLOB.player_list)
		if(!isnewplayer(M) && M.can_hear())
			to_chat(M, complete_msg)
			if(!silent && (M.client.prefs.toggles & PREFTOGGLE_SOUND_ANNOUNCEMENTS)) //nsv13 - silent arg integration
				if(alert)
					SEND_SOUND(M, sound('sound/misc/notice1.ogg'))
				else
					SEND_SOUND(M, sound('sound/misc/notice2.ogg'))

#undef DEFAULT_ALERT
