// Zapętlone alarmy z relay() (przegrzanie reaktora, alarm kadłuba, napęd FTL...) dostaje załoga obecna na statku w chwili startu,
// a stop_relay() wycisza je tylko tym, którzy są na statku w chwili końca. Kto w międzyczasie zginął i został duchem, odleciał
// myśliwcem albo zmienił ciało, słyszał pętlę do końca rundy (zapętlone „rdzeń się przegrzewa” po ochłodzeniu stormdrive'a).
// Jak przy skrzypieniu kadłuba (ship_sounds.dm) zapamiętujemy klientów, którym pętla poszła, i jej koniec wysyłamy też im.

/obj/structure/overmap
	/// Kanał -> klienci, którym relay() puścił zapętlony dźwięk na tym kanale
	var/list/aq_relay_loop_listeners

/// Klienci, którzy dostają dźwięk z relay(): załoga okrętu i jednostek w nim (myśliwce w hangarze), tak samo jak w relay()
/obj/structure/overmap/proc/aq_relay_hearers(list/hearers = list())
	for(var/mob/M as anything in mobs_in_ship)
		if(M.client && M.can_hear())
			hearers |= M.client
	for(var/obj/structure/overmap/O as anything in overmaps_in_ship)
		O.aq_relay_hearers(hearers)
	return hearers

/// Ucina dźwięk na kanale jednemu słuchaczowi (osobna procka dla testu)
/obj/structure/overmap/proc/aq_relay_stop_loop(listener, channel)
	SEND_SOUND(listener, sound(null, repeat = 0, wait = 0, channel = channel))

/obj/structure/overmap/relay(S, message = null, loop = FALSE, channel = null)
	. = ..()
	if(!S || !loop || !channel)
		return
	LAZYINITLIST(aq_relay_loop_listeners)
	var/key = "[channel]"
	var/list/listeners = aq_relay_loop_listeners[key] || list()
	aq_relay_loop_listeners[key] = aq_relay_hearers(listeners)

/obj/structure/overmap/stop_relay(channel)
	..()
	var/key = "[channel]"
	var/list/listeners = LAZYACCESS(aq_relay_loop_listeners, key)
	if(!listeners)
		return
	LAZYREMOVE(aq_relay_loop_listeners, key)
	for(var/listener in listeners)
		if(listener)
			aq_relay_stop_loop(listener, channel)
