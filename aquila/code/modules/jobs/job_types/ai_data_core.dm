// Zdecentralizowane AI: spawn SI do rdzenia danych (port Monkestation/Monkestation2.0#11862)

/datum/job/ai/after_spawn(mob/H, mob/M, latejoin)
	. = ..()
	var/mob/living/silicon/ai/AI = H
	if(!istype(AI))
		return
	// Latejoin przenosi SI na miejsce pustego rdzenia, więc wracamy do rdzenia danych
	if(!isaicore(AI.loc))
		AI.relocate(TRUE, FALSE)
	var/datum/ai_os/our_os = AI.get_ai_os()
	if(!our_os || !isaicore(AI.loc))
		return
	// Pierwsza SI w sieci dostaje wszystkie wolne zasoby, kolejne dzieli konsola dystrybucji
	our_os.set_cpu(AI, our_os.total_cpu - our_os.total_cpu_assigned() + (our_os.cpu_assigned[AI] || 0))
	our_os.set_ram(AI, our_os.total_ram - our_os.total_ram_assigned() + (our_os.ram_assigned[AI] || 0))

/datum/job/ai/special_check_latejoin(client/C)
	. = ..()
	if(. || !do_special_check)
		return
	if(length(GLOB.ai_list) >= total_positions)
		return FALSE
	for(var/z in GLOB.data_cores)
		for(var/obj/machinery/ai/data_core/core as anything in GLOB.data_cores[z])
			if(is_station_level(core.z) && core.valid_ticks > 0 && core.valid_holder())
				return TRUE
	return FALSE

/obj/effect/landmark/start/ai/after_round_start()
	. = ..()
	// Na mapach z rdzeniami danych nie stawiamy pustego rdzenia SI na miejscu startu
	var/turf/our_turf = get_turf(src)
	if(!our_turf || !LAZYLEN(GLOB.data_cores["[our_turf.z]"]))
		return
	for(var/obj/structure/AIcore/latejoin_inactive/inactive_core in our_turf)
		GLOB.latejoin_ai_cores -= inactive_core
		qdel(inactive_core)
