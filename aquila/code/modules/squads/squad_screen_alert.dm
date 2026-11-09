// Komunikaty drużyny na ekranie: tytuł w kolorze drużyny, tekst wypisywany literami, portret nadawcy.
// Mechanika z TGMC (tgstation/TerraGov-Marine-Corps, code/modules/screen_alert/), przepisana pod nasz HUD:
// jeden komunikat naraz na klienta, reszta czeka w kolejce.

/datum/aq_squad_alert
	var/title
	var/message
	var/title_color = "#ffffff"
	/// Wygląd nadawcy w chwili wysłania; null = komunikat automatyczny
	var/mutable_appearance/portrait
	/// Ile tekst wisi po wypisaniu
	var/hold_time = 8 SECONDS

/datum/aq_squad_alert/New(title, message, title_color, mob/living/sender, hold_time)
	src.title = title
	src.message = message
	if(title_color)
		src.title_color = title_color
	if(hold_time)
		src.hold_time = hold_time
	if(sender)
		portrait = new /mutable_appearance(sender.appearance)

/client
	/// Komunikaty drużyny czekające na wyświetlenie (pierwszy jest na ekranie)
	var/list/aq_squad_alerts

/atom/movable/screen/aq_squad_alert_text
	icon = null
	maptext_width = 420
	maptext_height = 80
	maptext_x = 72
	maptext_y = 0
	screen_loc = "LEFT:8,TOP-2:-8"
	plane = ABOVE_HUD_PLANE
	layer = ABOVE_HUD_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/aq_squad_alert_portrait
	icon = 'aquila/icons/squads/screen_alert.dmi'
	icon_state = "frame_back"
	screen_loc = "LEFT:8,TOP-2:-8"
	plane = ABOVE_HUD_PLANE
	layer = ABOVE_HUD_LAYER
	appearance_flags = APPEARANCE_UI | KEEP_TOGETHER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/aq_squad_alert_portrait/proc/set_portrait(mutable_appearance/sender_look)
	cut_overlays()
	if(sender_look)
		var/mutable_appearance/face = new /mutable_appearance(sender_look)
		face.dir = SOUTH
		face.transform = matrix().Scale(1.5)
		face.pixel_x = 16
		face.pixel_y = 10
		face.layer = layer + 0.1
		face.plane = FLOAT_PLANE
		face.appearance_flags = RESET_COLOR | RESET_TRANSFORM | RESET_ALPHA | KEEP_TOGETHER
		add_overlay(face)
	else
		add_overlay(mutable_appearance(icon, "cic", layer + 0.1, FLOAT_PLANE))
	add_overlay(mutable_appearance(icon, "frame", layer + 0.2, FLOAT_PLANE))
	filters = filter(type = "alpha", icon = icon(icon, "mask"))

/// Dodaje komunikat do kolejki klienta
/client/proc/aq_queue_squad_alert(datum/aq_squad_alert/alert)
	LAZYADD(aq_squad_alerts, alert)
	if(length(aq_squad_alerts) == 1)
		INVOKE_ASYNC(src, PROC_REF(aq_play_squad_alerts))

/client/proc/aq_play_squad_alerts()
	while(src && length(aq_squad_alerts))
		var/datum/aq_squad_alert/alert = aq_squad_alerts[1]
		var/atom/movable/screen/aq_squad_alert_portrait/portrait_box = new
		portrait_box.set_portrait(alert.portrait)
		var/atom/movable/screen/aq_squad_alert_text/text_box = new
		screen += portrait_box
		screen += text_box
		var/header = "<span style='font-size:9px;color:[alert.title_color];text-decoration:underline'>[html_encode(alert.title)]</span><br>"
		var/body = alert.message
		var/body_length = length_char(body)
		for(var/shown = 2 to body_length + 2 step 2)
			if(!src)
				return
			text_box.maptext = MAPTEXT("[header]<span style='font-size:8px;-dm-text-outline:1px black'>[html_encode(copytext_char(body, 1, shown))]</span>")
			sleep(0.5)
		if(!src)
			return
		sleep(alert.hold_time)
		if(!src)
			return
		animate(text_box, alpha = 0, time = 5)
		animate(portrait_box, alpha = 0, time = 5)
		sleep(5)
		if(!src)
			return
		screen -= portrait_box
		screen -= text_box
		qdel(portrait_box)
		qdel(text_box)
		LAZYREMOVE(aq_squad_alerts, alert)

/mob/proc/aq_has_squad_pager()
	return length(GetAllContents(/obj/item/squad_pager)) > 0

/// Kto dostaje komunikaty drużyny na ekran: członkowie z pagerem przy sobie
/datum/squad/proc/aq_alert_recipients()
	. = list()
	for(var/mob/living/carbon/human/member as anything in members)
		if(member.client && member.stat != DEAD && member.aq_has_squad_pager())
			. += member

/// Komunikat na ekranie dla całej drużyny; sender = null to komunikat automatyczny
/datum/squad/proc/aq_squad_screen_alert(message, title, mob/living/sender, hold_time, play_tts = FALSE)
	var/list/recipients = aq_alert_recipients()
	for(var/mob/living/carbon/human/member as anything in recipients)
		member.playsound_local(get_turf(member), sender ? 'nsv13/sound/effects/notice2.ogg' : 'sound/machines/twobeep.ogg', 40, FALSE)
		member.client.aq_queue_squad_alert(new /datum/aq_squad_alert(title, message, colour, sender, hold_time || (sender ? 8 SECONDS : 4 SECONDS)))
	if(play_tts && sender && length(recipients))
		aq_squad_tts_speak(sender, message, recipients)
	return recipients
