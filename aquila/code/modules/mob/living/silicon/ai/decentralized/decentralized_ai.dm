// AI w data core'ach (port Monkestation/Monkestation2.0#11862, oryginał z Yogstation)

/mob/living/silicon/ai
	///If this is set, this is the last data core this AI was in before deploying into something.
	var/obj/machinery/ai/data_core/last_used_data_core
	///Boolean on whether the AI is in a magically powered area AKA. places with power but no APC (shuttles).
	var/technically_unpowered = FALSE
	var/datum/ai_dashboard/dashboard
	///Override for the console download, checked first
	var/can_download = TRUE
	///Can we (shift-click) examine humans?
	var/canExamineHumans = FALSE
	///Can we scan atmos and power by clicking turfs?
	var/canEngineeringScan = FALSE
	///Did we get the death prompt?
	var/is_dying = FALSE
	///RGB party mode for data cores
	var/party_time = FALSE
	///Mobs tracked by the advanced tracking project, shown in the status panel
	var/list/target_list
	///Extra view range from the expanded camera network project
	var/view_range_boost = 0

/mob/living/silicon/ai/Initialize(mapload, datum/ai_laws/L, mob/target_ai)
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return
	dashboard = new(src)
	// AI na kafelku (start rundy, nowy rdzeń z konsoli) przenosi się do data core'a, jeśli na tym poziomie jakiś jest.
	// Bez data core'ów zostaje na kafelku jak dawniej (mapy bez serwerowni AI).
	if(isturf(loc))
		relocate(TRUE, FALSE)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_AI_CREATED, src)

/mob/living/silicon/ai/Destroy()
	var/datum/ai_os/our_os = get_ai_os()
	our_os?.remove_ai(src)
	QDEL_NULL(dashboard)
	last_used_data_core = null
	target_list = null
	return ..()

/mob/living/silicon/ai/Life()
	. = ..()
	if(stat == DEAD)
		return
	// Rdzeń za długo niesprawny (przegrzany, bez prądu): SI szuka innego
	if(isaicore(loc))
		var/obj/machinery/ai/data_core/core = loc
		if(!core.valid_data_core(src))
			relocate()
			return
	dashboard?.tick(SSmobs.wait / (1 SECONDS))
	if(party_time && isaicore(loc))
		var/obj/machinery/ai/data_core/core = loc
		core.set_light(7, 3, "#[random_color()]")
	if(!isaicore(loc))
		return
	var/area/home = get_area(src)
	if(home && !home.requires_power && !home.get_apc())
		if(!technically_unpowered)
			ai_deactivate_power()
	else if(technically_unpowered)
		ai_reactivate_power()

///Returns the resource system for the z-level we live on (or the one of the core we left for a mech/shell)
/mob/living/silicon/ai/proc/get_ai_os()
	var/turf/our_turf
	if(controlled_mech && last_used_data_core)
		our_turf = get_turf(last_used_data_core)
	else
		our_turf = get_turf(src)
	if(!our_turf)
		return null
	return GLOB.ai_os["[our_turf.z]"]

///Returns TRUE if there is any data core in the system this AI lives in
/mob/living/silicon/ai/proc/available_ai_cores()
	var/turf/our_turf = get_turf(src)
	return our_turf && LAZYLEN(GLOB.data_cores["[our_turf.z]"])

///Returns a single AI core that is habitable to src
/mob/living/silicon/ai/proc/find_valid_ai_core()
	RETURN_TYPE(/obj/machinery/ai/data_core)
	var/turf/ai_turf = get_turf(src)
	if(isnull(ai_turf))
		return null
	var/obj/machinery/ai/data_core/primary/data_core = locate() in GLOB.data_cores["[ai_turf.z]"]
	//in the case the primary core is deleted, this is ran before Destroy process is done (for AI relocation), so check QDELETED.
	if(data_core && !QDELETED(data_core) && data_core.can_transfer_ai(src))
		return data_core

	for(var/obj/machinery/ai/data_core/other_data_cores as anything in GLOB.data_cores["[ai_turf.z]"])
		if(!QDELETED(other_data_cores) && other_data_cores.can_transfer_ai(src))
			return other_data_cores

	return null

/**
 * Przenosi AI do działającego data core'a.
 * kill_otherwise: gdy żadnego nie ma, AI umiera (zostaje intellicard z jego zapisem).
 * AI na mapie bez żadnego data core'a nigdy nie umiera przez ten proc.
 */
/mob/living/silicon/ai/proc/relocate(silent = FALSE, kill_otherwise = TRUE, ignore_z_levels = FALSE)
	if(is_dying)
		return FALSE
	var/had_core = isaicore(loc)
	if(!silent && had_core)
		to_chat(src, span_userdanger("Utracono połączenie z rdzeniem danych. Próba ponownego połączenia..."))

	if(last_used_data_core && !QDELETED(last_used_data_core) && last_used_data_core != loc)
		if(last_used_data_core.can_transfer_ai(src, ignore_z_levels))
			last_used_data_core.transfer_AI(src)
			return TRUE
	//it's gone pal
	if(QDELETED(last_used_data_core))
		last_used_data_core = null

	var/obj/machinery/ai/data_core/new_data_core = find_valid_ai_core()
	if(!new_data_core)
		if(kill_otherwise && (had_core || available_ai_cores()))
			is_dying = TRUE
			INVOKE_ASYNC(src, PROC_REF(death_prompt), get_turf(src))
		return FALSE

	if(!silent)
		to_chat(src, span_danger("Wykryto zapasowy rdzeń danych. Przekierowywanie połączenia..."))
	new_data_core.transfer_AI(src)
	return TRUE

/mob/living/silicon/ai/proc/death_prompt(turf/death_turf)
	to_chat(src, span_userdanger("Nie można przywrócić połączenia z rdzeniem danych. Wyłączanie systemu..."))
	sleep(2 SECONDS)
	to_chat(src, span_warning("Próba ponownego uruchomienia... BŁĄD"))
	sleep(2 SECONDS)
	to_chat(src, span_warning("OOM EXCEPTION - Zakończono proces potomny PID[rand(100,2000)]"))
	sleep(2 SECONDS)
	to_chat(src, span_notice("Próba połączenia z hostami rdzeni danych..."))
	sleep(2 SECONDS)
	if(QDELETED(src))
		return
	if(find_valid_ai_core())
		to_chat(src, span_notice("Połączenie udane. Rozpoczynanie wgrywania plików."))
		is_dying = FALSE
		relocate(TRUE)
		return
	to_chat(src, span_warning("Połączenie nieudane. Brak aktywnych hostów."))
	sleep(0.5 SECONDS)
	to_chat(src, span_userdanger("BŁĄD KRYTYCZNY: wyczerpano zasoby systemu. Tworzenie kopii odzyskiwania."))
	sleep(1.5 SECONDS)
	if(QDELETED(src))
		return

	is_dying = FALSE // you arent dying if you are dead!
	if(!death_turf)
		death_turf = get_turf(src)
	var/obj/item/aicard/salvage = new(death_turf)
	disconnect_shell()
	death()
	forceMove(salvage)
	salvage.AI = src
	control_disabled = TRUE
	radio_enabled = FALSE
	salvage.update_icon()
	salvage.visible_message(span_notice("[salvage] wypada ze szczątków!"), blind_message = span_hear("Słyszysz, jak coś małego upada na podłogę."))

///Called when an AI is moved into an area that has power but no APC (shuttles, mostly)
/mob/living/silicon/ai/proc/ai_deactivate_power()
	disconnect_shell()
	view_core()
	technically_unpowered = TRUE
	to_chat(src, span_alert("Utracono dostęp do APC!"))

///Called when an AI is unpowered but has been moved into an area with power
/mob/living/silicon/ai/proc/ai_reactivate_power()
	technically_unpowered = FALSE

/mob/living/silicon/ai/ai_lose_power()
	if(isaicore(loc) && relocate(silent = FALSE, kill_otherwise = FALSE)) //see about moving to one with power.
		return
	return ..()

/mob/living/silicon/ai/get_stat_tab_status()
	var/list/tab_data = ..()
	if(stat)
		return tab_data
	var/obj/machinery/ai/data_core/ai_location = loc
	if(istype(ai_location))
		tab_data["Rdzeń danych"] = GENERATE_STAT_TEXT("[get_area_name(ai_location, TRUE)]")
		if(ai_location.integrated_battery)
			tab_data["Bateria rdzenia"] = GENERATE_STAT_TEXT("[round(ai_location.integrated_battery.percent())]%")
	var/datum/ai_os/our_os = get_ai_os()
	if(our_os)
		tab_data["Przydział CPU"] = GENERATE_STAT_TEXT("[our_os.cpu_assigned[src] || 0] / [our_os.total_cpu] THz")
		tab_data["Przydział RAM"] = GENERATE_STAT_TEXT("[(our_os.ram_assigned[src] || 0) + (dashboard?.free_ram || 0)] / [our_os.total_ram] TB")
	for(var/mob/tracked_mob as anything in target_list)
		if(QDELETED(tracked_mob))
			continue
		var/turf/tracked_turf = get_turf(tracked_mob)
		tab_data["Śledzony: [tracked_mob.name]"] = GENERATE_STAT_TEXT("[get_area_name(tracked_mob, TRUE)] ([tracked_turf?.x], [tracked_turf?.y], [tracked_turf?.z])")
	return tab_data

/mob/living/silicon/ai/Topic(href, href_list)
	. = ..()
	if(usr != src)
		return
	if(href_list["instant_download"])
		var/obj/machinery/computer/ai_control_console/C = locate(href_list["console"]) in GLOB.machines
		if(C?.downloading == src)
			C.finish_download()
	if(href_list["go_to_machine"])
		var/atom/target = locate(href_list["go_to_machine"])
		if(!target || !eyeobj)
			return
		if(can_see(target))
			eyeobj.setLoc(get_turf(target))
		else
			to_chat(src, span_warning("[target] nie jest w zasięgu żadnej aktywnej kamery."))

/mob/living/silicon/ai/set_core_display_icon(input, client/C)
	. = ..()
	SEND_SIGNAL(src, COMSIG_AI_ICON_CHANGE, icon_state)

/mob/living/silicon/ai/proc/partytime()
	party_time = TRUE
	var/obj/machinery/ai/data_core/core = loc
	if(istype(core))
		core.set_light(7, 3, "#[random_color()]")

/mob/living/silicon/ai/proc/stoptheparty()
	party_time = FALSE
	var/obj/machinery/ai/data_core/core = loc
	if(istype(core))
		core.set_light(0)

/mob/living/silicon/ai/reset_perspective(atom/A)
	// Patrzenie „na rdzeń” z wnętrza data core'a ma pokazywać oko kamery, nie wnętrze maszyny
	if(isaicore(A) && A == loc)
		A = null
	return ..(A)

///Mech wraca AI do data core'a zamiast do pustego rdzenia. Zwraca TRUE, jeśli zajął się wyjściem.
/obj/mecha/proc/ai_return_to_data_core(mob/living/silicon/ai/AI)
	var/turf/core_turf = get_turf(AI.last_used_data_core || src)
	if(!core_turf || !LAZYLEN(GLOB.data_cores["[core_turf.z]"]))
		return FALSE
	to_chat(AI, span_notice("Próba powrotu do rdzenia danych..."))
	if(!AI.find_valid_ai_core())
		to_chat(AI, span_userdanger("Brak działających rdzeni danych. Nie można wrócić."))
		return TRUE
	AI.controlled_mech = null
	AI.remote_control = null
	RemoveActions(AI, 1)
	occupant = null
	silicon_pilot = FALSE
	AI.relocate(TRUE, FALSE)
	SStgui.close_user_uis(AI, src)
	icon_state = initial(icon_state) + "-open"
	setDir(dir_in)
	if(AI.client)
		AI.update_mouse_pointer()
		AI.client.view_size.resetToDefault()
	zoom_mode = 0
	return TRUE
