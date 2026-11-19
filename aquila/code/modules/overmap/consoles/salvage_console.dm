// AQUILA - konsola odzysku (zakłócacz EWAR, nsv13/code/game/machinery/computer/salvage.dm) i konsola magnesu
// (aquila/code/modules/mining/mineral_magnet_ui.dm) mają jedno okno „Odzysk i abordaż” (SalvageConsole.tsx)
// z zakładkami „Cele abordażu” i „Magnes”. Każda konsola bierze dane drugiej zakładki od konsoli drugiego typu
// na tym samym okręcie i przekazuje jej akcje. Zakładka wymaga dostępu konsoli, która ją obsługuje; bez niego
// okno pokazuje ją tylko do podglądu.

/obj/machinery/computer/ship/salvage
	/// Konsola magnesu tego okrętu (zakładka „Magnes”)
	var/datum/weakref/magnet_ref
	/// Kiedy wolno znowu szukać konsoli magnesu, gdy okręt jej nie ma
	var/next_magnet_search = 0
	/// TRUE na czas boarding_tab_data(): ui_data() zwraca wtedy same dane zakładki „Cele abordażu”
	var/tmp/boarding_data_only = FALSE

/obj/machinery/computer/ship/mineral_magnet
	/// Zakłócacz EWAR tego okrętu (zakładka „Cele abordażu”)
	var/datum/weakref/salvage_ref
	/// Kiedy wolno znowu szukać zakłócacza, gdy okręt go nie ma
	var/next_salvage_search = 0

/// Dane całego okna odzysku; default_tab to zakładka otwierana na tej konsoli ("boarding" albo "magnet")
/obj/machinery/computer/ship/proc/salvage_console_data(mob/user, list/boarding, obj/machinery/computer/ship/salvage/salvage, obj/machinery/computer/ship/mineral_magnet/magnet, default_tab)
	var/list/data = list()
	data["default_tab"] = default_tab
	data["boarding_present"] = !!salvage
	data["boarding_access"] = salvage ? salvage.allowed(user) : FALSE
	data["boarding"] = boarding
	data["magnet_present"] = !!magnet
	data["magnet_access"] = magnet ? magnet.allowed(user) : FALSE
	data["magnet"] = magnet?.magnet_tab_data(user)
	return data

/// Odmowa akcji zakładki bez dostępu: dźwięk błędu i komunikat
/obj/machinery/computer/ship/proc/salvage_console_denied(mob/user)
	var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
	playsound(src, sound, 100, 1)
	to_chat(user, "<span class='warning'>Odmowa dostępu</span>")

/// Konsola magnesu na tym samym okręcie. Najpierw ta z klatką na asteroidy; brak szuka się ponownie najwyżej co 10 sekund.
/obj/machinery/computer/ship/salvage/proc/get_magnet_console()
	if(!linked && !has_overmap())
		return null
	var/obj/machinery/computer/ship/mineral_magnet/magnet = magnet_ref?.resolve()
	if(!QDELETED(magnet) && magnet.linked == linked)
		return magnet
	magnet_ref = null
	if(world.time < next_magnet_search)
		return null
	next_magnet_search = world.time + 10 SECONDS
	magnet = null
	var/obj/machinery/computer/ship/mineral_magnet/fallback
	for(var/obj/machinery/computer/ship/mineral_magnet/candidate in GLOB.machines)
		if(QDELETED(candidate) || (candidate.linked || candidate.has_overmap()) != linked)
			continue
		if(candidate.target_location)
			magnet = candidate
			break
		if(!fallback)
			fallback = candidate
	if(!magnet)
		magnet = fallback
	if(magnet)
		magnet_ref = WEAKREF(magnet)
	return magnet

/// Zakłócacz EWAR na tym samym okręcie; brak szuka się ponownie najwyżej co 10 sekund
/obj/machinery/computer/ship/mineral_magnet/proc/get_salvage_console()
	if(!linked && !has_overmap())
		return null
	var/obj/machinery/computer/ship/salvage/salvage = salvage_ref?.resolve()
	if(!QDELETED(salvage) && salvage.linked == linked)
		return salvage
	salvage_ref = null
	if(world.time < next_salvage_search)
		return null
	next_salvage_search = world.time + 10 SECONDS
	for(var/obj/machinery/computer/ship/salvage/candidate in GLOB.machines)
		if(QDELETED(candidate) || (candidate.linked || candidate.has_overmap()) != linked)
			continue
		salvage_ref = WEAKREF(candidate)
		return candidate
	return null

/// Same dane zakładki „Cele abordażu” (te, które rdzeń daje w ui_data()); null bez okrętu
/obj/machinery/computer/ship/salvage/proc/boarding_tab_data(mob/user)
	if(!linked && !has_overmap())
		return null
	boarding_data_only = TRUE
	return ui_data(user)

/obj/machinery/computer/ship/salvage/ui_data(mob/user)
	// Flaga gaśnie przed wywołaniem rdzenia, więc błąd w nim nie zostawi okna w trybie „same cele”
	var/only_boarding = boarding_data_only
	boarding_data_only = FALSE
	// Rdzeń bez okrętu sięga do linked.active_boarding_target i się wywraca
	var/list/boarding = (linked || has_overmap()) ? ..() : null
	if(only_boarding)
		return boarding
	return salvage_console_data(user, boarding, src, get_magnet_console(), "boarding")

/obj/machinery/computer/ship/salvage/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	switch(action)
		if("salvage", "stop_salvage")
			if(!allowed(usr))
				salvage_console_denied(usr)
				return FALSE
		if("pull", "pull_wreck", "push")
			..() // odcisk palca i dźwięk kliknięcia; rdzeń tych akcji nie zna i nie mówi, czy okno pozwala działać
			if(!ui || ui.status != UI_INTERACTIVE)
				return FALSE
			var/obj/machinery/computer/ship/mineral_magnet/magnet = get_magnet_console()
			if(!magnet)
				return FALSE
			if(!magnet.allowed(usr))
				salvage_console_denied(usr)
				return FALSE
			return magnet.magnet_act(action, params, usr)
	return ..()
