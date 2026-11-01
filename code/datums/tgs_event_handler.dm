/datum/tgs_event_handler/impl
	var/datum/timedevent/reattach_timer

/datum/tgs_event_handler/impl/HandleEvent(event_code, ...)
	switch(event_code)
		if(TGS_EVENT_REBOOT_MODE_CHANGE)
			var/list/reboot_mode_lookup = list ("[TGS_REBOOT_MODE_NORMAL]" = "działać normalnie", "[TGS_REBOOT_MODE_SHUTDOWN]" = "wyłączać serwera", "[TGS_REBOOT_MODE_RESTART]" = "twardo restartować serwera")
			var/old_reboot_mode = args[2]
			var/new_reboot_mode = args[3]
			message_admins("TGS: Restart nie będzie już [reboot_mode_lookup["[old_reboot_mode]"]], zamiast tego będzie [reboot_mode_lookup["[new_reboot_mode]"]]")
		if(TGS_EVENT_PORT_SWAP)
			message_admins("TGS: Zmiana portu z [world.port] na [args[2]]")
		if(TGS_EVENT_INSTANCE_RENAMED)
			message_admins("TGS: Zmiana nazwy instancji z [world.TgsInstanceName()] na [args[2]]")
		if(TGS_EVENT_COMPILE_START)
			message_admins("TGS: Rozpoczęto wdrożenie, nadchodzi nowa wersja gry...")
		if(TGS_EVENT_COMPILE_CANCELLED)
			message_admins("TGS: Wdrożenie anulowane!")
		if(TGS_EVENT_COMPILE_FAILURE)
			message_admins("TGS: Wdrożenie nieudane!")
		if(TGS_EVENT_DEPLOYMENT_COMPLETE)
			message_admins("TGS: Wdrożenie zakończone!")
			to_chat(world, "<span class='boldannounce'>Serwer zaktualizowany, zmiany zostaną wprowadzone w następnej rundzie...</span>")
		if(TGS_EVENT_WATCHDOG_DETACH)
			message_admins("TGS się restartuje...")
			reattach_timer = addtimer(CALLBACK(src, PROC_REF(LateOnReattach)), 1 MINUTES, TIMER_STOPPABLE)
		if(TGS_EVENT_WATCHDOG_REATTACH)
			var/datum/tgs_version/old_version = world.TgsVersion()
			var/datum/tgs_version/new_version = args[2]
			if(!old_version.Equals(new_version))
				to_chat(world, "<span class='boldannounce'>TGS zaktualizowany do v[new_version.deprefixed_parameter]</span>")
			else
				message_admins("TGS: Znów online")
			if(reattach_timer)
				deltimer(reattach_timer)
				reattach_timer = null
		if(TGS_EVENT_WATCHDOG_SHUTDOWN)
			to_chat_immediate(world, "<span class='boldannounce'>Serwer się wyłącza!</span>")

/datum/tgs_event_handler/impl/proc/LateOnReattach()
	message_admins("Uwaga: TGS od pełnej minuty nie zgłosił, że wrócił! Czy jest jakiś problem?")
