// AQUILA: telewizor rozrywkowy jako odbiornik sieci transmisji (port Monkestation/tg telescreen.dm).
// Stała sieć Thunderdome zostaje; inne sieci przychodzą z COMSIG_GLOB_NETWORK_BROADCAST_UPDATED.

/obj/machinery/computer/security/telescreen/entertainment
	/// Głośniki z radiem rozrywkowym
	var/obj/item/radio/entertainment/speakers/speakers
	/// Sieci, które są zawsze w telewizorze (Thunderdome z mapy)
	var/list/default_networks
	/// Sieci nadające teraz na żywo
	var/list/live_networks = list()
	/// Czujniki ruchu Thunderdome wykryły walkę
	var/thunderdome_live = FALSE

/obj/machinery/computer/security/telescreen/entertainment/Initialize(mapload)
	. = ..()
	default_networks = network.Copy()
	RegisterSignal(SSdcs, COMSIG_GLOB_NETWORK_BROADCAST_UPDATED, PROC_REF(on_network_broadcast_updated))
	speakers = new(src)

/obj/machinery/computer/security/telescreen/entertainment/Destroy()
	UnregisterSignal(SSdcs, COMSIG_GLOB_NETWORK_BROADCAST_UPDATED)
	LAZYREMOVE(GLOB.spesstv_viewers, REF(src))
	QDEL_NULL(speakers)
	return ..()

/obj/machinery/computer/security/telescreen/entertainment/examine(mob/user)
	. = ..()
	. += length(live_networks) ? "<span class='notice'>Coś leci na żywo!</span>" : "<span class='notice'><i>Nic ciekawego nie leci.</i></span>"
	if(speakers)
		. += "<span class='notice'>Głośniki są [speakers.listening ? "włączone" : "wyciszone"]. <b>Ctrl+klik</b> je przełącza.</span>"

/obj/machinery/computer/security/telescreen/entertainment/CtrlClick(mob/user)
	if(!speakers || !user.canUseTopic(src, !issilicon(user)))
		return ..()
	var/now_listening = speakers.toggle_mute()
	balloon_alert(user, now_listening ? "dźwięk włączony" : "wyciszono")

/obj/machinery/computer/security/telescreen/entertainment/obj_break(damage_flag)
	. = ..()
	LAZYREMOVE(GLOB.spesstv_viewers, REF(src))

/obj/machinery/computer/security/telescreen/entertainment/power_change()
	. = ..()
	if(!powered())
		LAZYREMOVE(GLOB.spesstv_viewers, REF(src))

/obj/machinery/computer/security/telescreen/entertainment/update_active_camera_screen()
	. = ..()
	update_spesstv_watcher_list(REF(src), active_camera)

/obj/machinery/computer/security/telescreen/entertainment/ui_act(action, params)
	. = ..()
	update_spesstv_watcher_list(REF(src), active_camera)

/obj/machinery/computer/security/telescreen/entertainment/ui_close(mob/user, datum/tgui/tgui)
	. = ..()
	if(!active_camera)
		LAZYREMOVE(GLOB.spesstv_viewers, REF(src))

/// Kamery reporterów i awatarów się ruszają, więc obraz odświeżamy co tick, gdy coś jest oglądane
/obj/machinery/computer/security/telescreen/entertainment/ui_requires_update(mob/user, datum/tgui/ui)
	. = ..()
	if(active_camera)
		return TRUE

/// Czujniki Thunderdome (motion.dm) włączają i wyłączają ekran; nie gasimy go, gdy leci inna transmisja
/obj/machinery/computer/security/telescreen/entertainment/notify(on)
	thunderdome_live = on
	if(on && icon_state != icon_state_off)
		return
	if(!on && length(live_networks))
		return
	return ..()

/// Dopisuje albo zdejmuje sieć z telewizora, zapala ekran i mówi komunikat
/obj/machinery/computer/security/telescreen/entertainment/proc/on_network_broadcast_updated(datum/source, tv_show_id, is_show_active, announcement)
	SIGNAL_HANDLER
	if(!network)
		return
	if(is_show_active)
		network |= tv_show_id
		live_networks |= tv_show_id
	else
		network -= tv_show_id
		live_networks -= tv_show_id
		network |= default_networks
	update_live_screen(announcement)
	INVOKE_ASYNC(src, PROC_REF(refresh_viewers))

/// Telescreen/update_icon() wraca do pustego ekranu; przy transmisji zostaje zapalony
/obj/machinery/computer/security/telescreen/entertainment/update_icon()
	. = ..()
	if(machine_stat & (BROKEN|NOPOWER))
		return
	icon_state = (length(live_networks) || thunderdome_live) ? icon_state_on : icon_state_off

/// Ustawia ekran na „na żywo” albo pusty
/obj/machinery/computer/security/telescreen/entertainment/proc/update_live_screen(announcement)
	update_icon()
	if(announcement && is_operational)
		INVOKE_ASYNC(src, TYPE_PROC_REF(/atom/movable, say), announcement)

/// Wysyła nową listę kamer wszystkim, którzy mają otwarte okno
/obj/machinery/computer/security/telescreen/entertainment/proc/refresh_viewers()
	for(var/datum/tgui/ui as anything in SStgui.get_all_open_uis(src))
		ui.send_full_update()
