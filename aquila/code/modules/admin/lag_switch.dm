// Lag switches (port tgstation#59717, #62999, #95976): panel admina i przełączniki podpięte nadpisaniami.
// Hooki w core (AQ EDIT): pętla SSinput, runechat i dymki mowy, icon2html, sygnał połączenia klienta.

/// Liczba klientów, od której przełączniki włączają się same (brak wpisu = nigdy)
/datum/config_entry/number/auto_lag_switch_pop
	config_entry_value = null
	min_val = 0

/client
	COOLDOWN_DECLARE(say_slowmode)

/world/AVerbsAdmin()
	. = ..()
	. += /datum/admins/proc/show_lag_switch_panel

/datum/admins/proc/show_lag_switch_panel()
	set category = "Admin.Game"
	set name = "Show Lag Switches"
	set desc = "Panel drastycznych środków przeciw lagom."

	if(!SSlag_switch.initialized)
		to_chat(usr, span_notice("Subsystem Lag Switch jeszcze się nie zainicjalizował."))
		return
	if(!check_rights(R_ADMIN))
		return

	var/list/dat = list("<html><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><title>Lag Switches</title></head><body><h2><B>Środki przeciw lagom</B></h2>")
	dat += "Automatyczne włączanie: <a href='?_src_=holder;[HrefToken()];change_lag_switch_option=TOGGLE_AUTO'><b>[SSlag_switch.auto_switch ? "Wł." : "Wył."]</b></a><br/>"
	dat += "Próg graczy: <a href='?_src_=holder;[HrefToken()];change_lag_switch_option=NUM'><b>[SSlag_switch.trigger_pop]</b></a><br/>"
	dat += "Odstęp slowmode (włączanie niżej): <a href='?_src_=holder;[HrefToken()];change_lag_switch_option=SLOWCOOL'><b>[SSlag_switch.slowmode_cooldown / 10] s</b></a><br/>"
	dat += "<br/><b>WSZYSTKIE: <a href='?_src_=holder;[HrefToken()];change_lag_switch=ALL_ON'>WŁ.</a> | <a href='?_src_=holder;[HrefToken()];change_lag_switch=ALL_OFF'>WYŁ.</a></b><br/>"
	dat += "<br/>Bez zoomu i t-raya duchów (poza adminami): [lag_switch_link(DISABLE_GHOST_ZOOM_TRAY)]<br/>"
	dat += "<br/>============! STREFA WŚCIEKŁYCH DUCHÓW !============<br/>"
	dat += "Bez swobodnego latania duchów (poza adminami, ogłasza w dchacie): [lag_switch_link(DISABLE_DEAD_KEYLOOP)]<br/>"
	dat += "====================================================<br/>"
	dat += "<br/><b>Poniższe omija <abbr title='TRAIT_BYPASS_MEASURES'><u>specjalna cecha</u></abbr></b><br/>"
	dat += "Slowmode mowy (ogłasza wszystkim): [lag_switch_link(SLOWMODE_SAY)]<br/>"
	dat += "Bez runechatu: [lag_switch_link(DISABLE_RUNECHAT)]<br/>"
	dat += "Bez ikon w examine: [lag_switch_link(DISABLE_USR_ICON2HTML)]<br/>"
	dat += "Bez parallaxu: [lag_switch_link(DISABLE_PARALLAX)]<br/>"
	dat += "Bez dźwięku kroków: [lag_switch_link(DISABLE_FOOTSTEPS)]<br/>"
	dat += "<br/>Blokada dołączania do gry: przycisk Toggle Entering w Game Panelu.<br/>"
	dat += "</body></html>"
	usr << browse(dat.Join(), "window=lag_switch_panel;size=460x480")

/// Link przełączający jeden środek w panelu
/datum/admins/proc/lag_switch_link(measure)
	return "<a href='?_src_=holder;[HrefToken()];change_lag_switch=[measure]'><b>[SSlag_switch.measures[measure] ? "Wł." : "Wył."]</b></a>"

/datum/admins/Topic(href, href_list)
	if(!href_list["change_lag_switch"] && !href_list["change_lag_switch_option"])
		return ..()
	// te same zabezpieczenia co w core, zanim cokolwiek przełączymy
	if(usr.client != owner || !check_rights(0) || !CheckAdminHref(href, href_list))
		return

	if(href_list["change_lag_switch"])
		if(!check_rights(R_ADMIN))
			return

		switch(href_list["change_lag_switch"])
			if("ALL_ON")
				SSlag_switch.set_all_measures(TRUE)
				log_admin("[key_name(usr)] turned all Lag Switch measures ON.")
				message_admins("[key_name_admin(usr)] włączył wszystkie środki przeciw lagom.")
			if("ALL_OFF")
				SSlag_switch.set_all_measures(FALSE)
				log_admin("[key_name(usr)] turned all Lag Switch measures OFF.")
				message_admins("[key_name_admin(usr)] wyłączył wszystkie środki przeciw lagom.")
			else
				var/switch_index = text2num(href_list["change_lag_switch"])
				if(!SSlag_switch.set_measure(switch_index, !LAZYACCESS(SSlag_switch.measures, switch_index)))
					to_chat(usr, span_danger("Nie udało się przełączyć środka przeciw lagom. Szczegóły w runtime'ach."), confidential = TRUE)
				else
					log_admin("[key_name(usr)] turned a Lag Switch measure at index ([switch_index]) [LAZYACCESS(SSlag_switch.measures, switch_index) ? "ON" : "OFF"]")
					message_admins("[key_name_admin(usr)] [LAZYACCESS(SSlag_switch.measures, switch_index) ? "włączył" : "wyłączył"] środek przeciw lagom nr [switch_index].")

		show_lag_switch_panel()
		return

	if(href_list["change_lag_switch_option"])
		if(!check_rights(R_ADMIN))
			return

		switch(href_list["change_lag_switch_option"])
			if("CANCEL")
				if(SSlag_switch.cancel_auto_enable_in_progress())
					log_admin("[key_name(usr)] canceled the automatic Lag Switch activation in progress.")
					message_admins("[key_name_admin(usr)] anulował automatyczne włączenie środków przeciw lagom.")
				return // bez otwierania panelu
			if("TOGGLE_AUTO")
				SSlag_switch.toggle_auto_enable()
				log_admin("[key_name(usr)] toggled automatic Lag Switch activation [SSlag_switch.auto_switch ? "ON" : "OFF"].")
				message_admins("[key_name_admin(usr)] [SSlag_switch.auto_switch ? "włączył" : "wyłączył"] automatyczne środki przeciw lagom.")
			if("NUM")
				var/new_num = input(usr, "Nowy próg graczy:", "Lag Switch") as null|num
				if(!isnull(new_num))
					SSlag_switch.trigger_pop = new_num
					log_admin("[key_name(usr)] set the Lag Switch automatic trigger pop to [new_num].")
					message_admins("[key_name_admin(usr)] ustawił próg automatycznych środków przeciw lagom na [new_num].")
			if("SLOWCOOL")
				var/new_num = input(usr, "Nowy odstęp w sekundach:", "Lag Switch") as null|num
				if(!isnull(new_num))
					SSlag_switch.change_slowmode_cooldown(new_num)
					log_admin("[key_name(usr)] set the Lag Switch slowmode cooldown to [new_num] seconds.")
					message_admins("[key_name_admin(usr)] ustawił odstęp slowmode na [new_num] s.")

		show_lag_switch_panel()

// ---------------------------------------------------------------- duchy

/mob/dead/observer/change_view_range()
	if(SSlag_switch.measures[DISABLE_GHOST_ZOOM_TRAY] && !client?.holder)
		to_chat(usr, span_notice("Ten verb jest teraz wyłączony dla wszystkich."))
		return
	return ..()

/mob/dead/observer/add_view_range(input as num)
	if(SSlag_switch.measures[DISABLE_GHOST_ZOOM_TRAY] && !client?.holder)
		to_chat(usr, span_notice("Ten verb jest teraz wyłączony dla wszystkich."))
		return
	return ..()

/mob/dead/observer/tray_view()
	if(SSlag_switch.measures[DISABLE_GHOST_ZOOM_TRAY] && !client?.holder)
		to_chat(usr, span_notice("Ten verb jest teraz wyłączony dla wszystkich."))
		return
	return ..()

/mob/dead/observer/reenter_corpse()
	. = ..()
	if(. && SSlag_switch.measures[DISABLE_DEAD_KEYLOOP] && !mind?.current?.client?.holder)
		to_chat(mind.current, span_warning("Żeby znowu opuścić ciało, użyj verba Ghost."))

/mob/living/death(gibbed)
	var/was_dead = stat == DEAD
	. = ..()
	if(was_dead || stat != DEAD || !SSlag_switch.measures[DISABLE_DEAD_KEYLOOP])
		return
	if(!client || client.holder || !mind?.active)
		return
	to_chat(src, span_deadsay(span_big("Swobodne latanie duchów jest wyłączone.\nDo oglądania używaj Orbit, Teleport i Jump.")))
	ghostize(TRUE)

// ---------------------------------------------------------------- slowmode

/// TRUE, jeśli slowmode blokuje tę wiadomość (i wtedy informuje mówiącego)
/mob/proc/lag_switch_slowmode_blocks(message)
	if(!client || !SSlag_switch.measures[SLOWMODE_SAY] || HAS_TRAIT(src, TRAIT_BYPASS_MEASURES) || src != usr)
		return FALSE
	if(!COOLDOWN_FINISHED(client, say_slowmode))
		to_chat(src, span_warning("Wiadomość niewysłana przez slowmode. Odczekaj [SSlag_switch.slowmode_cooldown / 10] s między wiadomościami.\n\"[message]\""))
		return TRUE
	COOLDOWN_START(client, say_slowmode, SSlag_switch.slowmode_cooldown)
	return FALSE

/mob/living/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language, ignore_spam = FALSE, forced)
	if(!forced && message && lag_switch_slowmode_blocks(message))
		return
	return ..()

/mob/say_dead(message)
	if(message && lag_switch_slowmode_blocks(message))
		return
	return ..()

// ---------------------------------------------------------------- parallax i kroki

/datum/hud/apply_parallax_pref(mob/viewmob)
	var/mob/screenmob = viewmob || mymob
	if(SSlag_switch.measures[DISABLE_PARALLAX] && !HAS_TRAIT(screenmob, TRAIT_BYPASS_MEASURES))
		return FALSE
	return ..()

/datum/component/footstep/play_footstep()
	SIGNAL_HANDLER
	if(SSlag_switch.measures[DISABLE_FOOTSTEPS] && !HAS_TRAIT(parent, TRAIT_BYPASS_MEASURES))
		return
	return ..()
