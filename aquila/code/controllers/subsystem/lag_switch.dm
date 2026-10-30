/// Drastyczne środki przeciw lagom (port tgstation#59717, #62999, #95976): mniej efektów, mniejsze obciążenie serwera.
SUBSYSTEM_DEF(lag_switch)
	name = "Lag Switch"
	flags = SS_NO_FIRE

	/// Czy przełączniki włączą się same po przekroczeniu progu graczy (TRUE, jeśli jest wpis w configu)
	var/auto_switch = FALSE
	/// Liczba klientów, przy której włączają się przełączniki automatyczne
	var/trigger_pop = INFINITY - 1337
	/// Stany przełączników, indeksy z aquila/code/__DEFINES/lag_switch.dm
	var/static/list/measures[MEASURES_AMOUNT]
	/// Przełączniki włączane automatycznie
	var/list/auto_measures = list(DISABLE_GHOST_ZOOM_TRAY, DISABLE_RUNECHAT, DISABLE_USR_ICON2HTML, DISABLE_PARALLAX, DISABLE_FOOTSTEPS)
	/// Timer odliczania przed automatycznym włączeniem (admini mogą anulować)
	var/veto_timer_id
	/// Odstęp między wiadomościami przy slowmode
	var/slowmode_cooldown = 3 SECONDS

/datum/controller/subsystem/lag_switch/Initialize(start_timeofday)
	for(var/i in 1 to measures.len)
		measures[i] = FALSE
	var/auto_switch_pop = CONFIG_GET(number/auto_lag_switch_pop)
	if(auto_switch_pop)
		auto_switch = TRUE
		trigger_pop = auto_switch_pop
		RegisterSignal(SSdcs, COMSIG_GLOB_CLIENT_CONNECT, PROC_REF(client_connected))
	return ..()

/datum/controller/subsystem/lag_switch/proc/client_connected(datum/source, client/connected)
	SIGNAL_HANDLER
	if(TGS_CLIENT_COUNT < trigger_pop)
		return

	auto_switch = FALSE
	UnregisterSignal(SSdcs, COMSIG_GLOB_CLIENT_CONNECT)
	veto_timer_id = addtimer(CALLBACK(src, PROC_REF(set_all_measures), TRUE, TRUE), 20 SECONDS, TIMER_STOPPABLE)
	message_admins("Lag Switch: osiągnięto próg graczy. Automatyczne środki przeciw lagom włączą się za 20 sekund. (<a href='?_src_=holder;[HrefToken()];change_lag_switch_option=CANCEL'>ANULUJ</a>)")
	log_admin("Lag Switch population threshold reached. Automatic activation of lag mitigation measures occuring in 20 seconds.")

/// Włącza albo wyłącza automatyczne przełączanie po liczbie klientów
/datum/controller/subsystem/lag_switch/proc/toggle_auto_enable()
	auto_switch = !auto_switch
	if(auto_switch)
		RegisterSignal(SSdcs, COMSIG_GLOB_CLIENT_CONNECT, PROC_REF(client_connected))
	else
		UnregisterSignal(SSdcs, COMSIG_GLOB_CLIENT_CONNECT)

/// Wołane z linku w czacie adminów
/datum/controller/subsystem/lag_switch/proc/cancel_auto_enable_in_progress()
	if(!veto_timer_id)
		return FALSE

	deltimer(veto_timer_id)
	veto_timer_id = null
	return TRUE

/// Zmienia odstęp slowmode, a przy skróceniu zeruje trwające odliczania
/datum/controller/subsystem/lag_switch/proc/change_slowmode_cooldown(length)
	if(!length)
		return FALSE

	var/length_secs = length SECONDS
	if(length_secs <= 0)
		length_secs = 1 // jeden tick, cooldowny nie lubią zera

	if(length_secs < slowmode_cooldown)
		for(var/client/C as anything in GLOB.clients)
			COOLDOWN_RESET(C, say_slowmode)

	slowmode_cooldown = length_secs
	if(measures[SLOWMODE_SAY])
		to_chat(world, span_boldannounce("Administracja zmieniła odstęp między wiadomościami na [length] s."))
	return TRUE

/// Zmienia stan jednego przełącznika
/datum/controller/subsystem/lag_switch/proc/set_measure(measure_key, state)
	if(isnull(measure_key) || isnull(state))
		stack_trace("SSlag_switch.set_measure() was called with a null arg")
		return FALSE
	if(isnull(LAZYACCESS(measures, measure_key)))
		stack_trace("SSlag_switch.set_measure() was called with a measure_key not in the list of measures")
		return FALSE
	if(measures[measure_key] == state)
		return TRUE

	measures[measure_key] = state

	switch(measure_key)
		if(DISABLE_DEAD_KEYLOOP)
			if(state)
				deadchat_broadcast(span_big("Dla wydajności swobodne latanie duchów jest wyłączone. Do oglądania używaj Orbit, Teleport i Jump."))
			else
				deadchat_broadcast("Swobodne latanie duchów znowu działa.")
		if(DISABLE_GHOST_ZOOM_TRAY)
			if(state) // przy włączaniu zwykły widok dla obecnych duchów
				for(var/mob/dead/observer/ghost in GLOB.dead_mob_list)
					if(!ghost.client)
						continue
					if(!ghost.client.holder && ghost.client.view_size.getView() != ghost.client.view_size.default)
						ghost.client.view_size.resetToDefault()
		if(SLOWMODE_SAY)
			if(state)
				to_chat(world, span_boldannounce("Włączono slowmode czatu IC i martwych: jedna wiadomość co [slowmode_cooldown / 10] s."))
			else
				for(var/client/C as anything in GLOB.clients)
					COOLDOWN_RESET(C, say_slowmode)
				to_chat(world, span_boldannounce("Administracja wyłączyła slowmode czatu IC i martwych."))
		if(DISABLE_PARALLAX)
			if(state)
				to_chat(world, span_boldannounce("Dla wydajności wyłączono parallax."))
			else
				to_chat(world, span_boldannounce("Parallax znowu działa."))
			for(var/mob/mob as anything in GLOB.player_list)
				mob.hud_used?.update_parallax_pref(mob)
		if(DISABLE_FOOTSTEPS)
			if(state)
				to_chat(world, span_boldannounce("Dla wydajności wyłączono dźwięki kroków."))
			else
				to_chat(world, span_boldannounce("Dźwięki kroków znowu działają."))

	return TRUE

/// Zmienia wszystkie przełączniki naraz (automat tylko te z auto_measures)
/datum/controller/subsystem/lag_switch/proc/set_all_measures(state, automatic = FALSE)
	if(isnull(state))
		stack_trace("SSlag_switch.set_all_measures() was called with a null state arg")
		return FALSE

	if(automatic)
		message_admins("Lag Switch: włączam automatyczne środki przeciw lagom.")
		log_admin("Lag Switch enabling automatic measures now.")
		veto_timer_id = null
		for(var/measure in auto_measures)
			set_measure(measure, state)
		return TRUE

	for(var/i in 1 to measures.len)
		set_measure(i, state)
	return TRUE
