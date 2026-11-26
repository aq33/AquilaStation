// Okno magnesu na asteroidy w TGUI (zamiast HTML i input() z nsv13/code/modules/mining/asteroid.dm).
// Asteroidy w zasięgu są w oknie razem ze składem rdzenia, wypchnięcie potwierdza się w oknie.
// Okno jest wspólne z zakłócaczem EWAR (SalvageConsole.tsx, zakładka „Magnes”).

// Konsole przy klatce (Atlas, Snake) stoją na pomoście w kosmosie, gdzie nie ma prądu.
// Maszyna bez prądu daje w TGUI tylko podgląd, więc magnes ma własne zasilanie.
/obj/machinery/computer/ship/mineral_magnet
	use_power = NO_POWER_USE

// Bez dostępu górnika okno otwiera się do podglądu (zakładki odzysku: aquila/code/modules/overmap/consoles/salvage_console.dm)
/obj/machinery/computer/ship/mineral_magnet/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/computer/ship/mineral_magnet/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		return
	if(!..())
		return
	ui = new(user, src, "SalvageConsole", name)
	ui.set_autoupdate(TRUE)
	ui.open()

/obj/machinery/computer/ship/mineral_magnet/ui_data(mob/user)
	var/obj/machinery/computer/ship/salvage/salvage = get_salvage_console()
	return salvage_console_data(user, salvage?.boarding_tab_data(user), salvage, src, "magnet")

/// Dane zakładki „Magnes” okna odzysku
/obj/machinery/computer/ship/mineral_magnet/proc/magnet_tab_data(mob/user)
	var/list/data = list()
	data["has_cage"] = !!target_location
	data["cooldown"] = cooldown
	data["has_asteroid"] = !!current_asteroid
	data["has_wreck"] = !!current_wreck
	data["wreck_name"] = current_wreck?.name
	data["wreck_health"] = get_wreck_health()
	var/list/asteroids = list()
	var/list/wrecks = list()
	if(linked && target_location && !current_asteroid && !current_wreck)
		for(var/obj/structure/overmap/asteroid/shipbreak_wreck/wreck in orange(5, linked))
			if(wreck.salvage_left > 0)
				wrecks += list(list("name" = "[wreck.name] (promy do wyciągnięcia: [wreck.salvage_left])", "ref" = REF(wreck)))
		for(var/obj/structure/overmap/asteroid/asteroid in orange(5, linked))
			if(istype(asteroid, /obj/structure/overmap/asteroid/shipbreak_wreck))
				continue
			var/list/ores = list()
			for(var/turf/closed/mineral/mineral_type as anything in asteroid.core_composition)
				var/obj/item/stack/ore/ore_type = initial(mineral_type.mineralType)
				ores += ore_type ? initial(ore_type.name) : initial(mineral_type.name)
			asteroids += list(list("name" = asteroid.name, "ref" = REF(asteroid), "ores" = ores))
	data["asteroids"] = asteroids
	data["wrecks"] = wrecks
	return data

/obj/machinery/computer/ship/mineral_magnet/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("pull", "pull_wreck", "push")
			if(!allowed(usr))
				salvage_console_denied(usr)
				return FALSE
			return magnet_act(action, params, usr)
		if("salvage", "stop_salvage")
			// Zakłócacz sam sprawdza swój dostęp i nadaje komunikaty swoim radiem
			var/obj/machinery/computer/ship/salvage/salvage = get_salvage_console()
			if(!salvage)
				return FALSE
			return salvage.ui_act(action, params, ui, state)

/// Akcja zakładki „Magnes” (dostęp sprawdza wywołujący); TRUE, gdy okno trzeba odświeżyć
/obj/machinery/computer/ship/mineral_magnet/proc/magnet_act(action, list/params, mob/user)
	if(!target_location)
		return FALSE
	switch(action)
		if("pull")
			if(current_asteroid || current_wreck)
				return FALSE
			var/obj/structure/overmap/asteroid/target = locate(params["ref"]) in orange(5, linked)
			if(target && !istype(target, /obj/structure/overmap/asteroid/shipbreak_wreck))
				pull_in_asteroid(user, target)
			return TRUE
		if("pull_wreck")
			if(current_asteroid || current_wreck)
				return FALSE
			var/obj/structure/overmap/asteroid/shipbreak_wreck/wreck = locate(params["ref"]) in orange(5, linked)
			if(wreck)
				pull_in_wreck(user, wreck)
			return TRUE
		if("push")
			if(current_asteroid || current_wreck)
				start_push()
			return TRUE
	return FALSE

/// Z celem wybranym w oknie: przyciąga od razu ten, bez listy input(); bez celu działa jak dawniej
/obj/machinery/computer/ship/mineral_magnet/pull_in_asteroid(mob/user, obj/structure/overmap/asteroid/target)
	if(!target)
		return ..()
	if(cooldown)
		say("BŁĄD: obwody magnetyzujące się ładują...")
		return FALSE
	if(!has_overmap() || !length(target.core_composition))
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		return FALSE
	linked.relay('nsv13/sound/effects/ship/tractor.ogg', "<span class='warning'>NIEBEZPIECZEŃSTWO: magnes namierzył asteroidę. Natychmiast opuść klatkę na asteroidy.</span>")
	cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 1 MINUTES)
	if(prob(20))
		var/list/potential_ruins = flist("_maps/map_files/Mining/nsv13/ruins/")
		current_asteroid = new /datum/map_template/asteroid("_maps/map_files/Mining/nsv13/ruins/[pick(potential_ruins)]", null, FALSE, target.core_composition)
	else
		var/list/potential_asteroids = flist("_maps/map_files/Mining/nsv13/asteroids/")
		current_asteroid = new /datum/map_template/asteroid("_maps/map_files/Mining/nsv13/asteroids/[pick(potential_asteroids)]", null, FALSE, target.core_composition)
	addtimer(CALLBACK(src, PROC_REF(load_asteroid)), 10 SECONDS)
	qdel(target)
	return TRUE
