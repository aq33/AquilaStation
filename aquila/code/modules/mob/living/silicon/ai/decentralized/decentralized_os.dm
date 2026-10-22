///Assoc list of ["z_level"] = ai_os
GLOBAL_LIST_EMPTY(ai_os)
///All server cabinets in the world
GLOBAL_LIST_EMPTY(ai_server_cabinets)

/datum/ai_os
	var/name = "Zdecentralizowany System Zarządzania Zasobami (DRMS)"

	var/total_cpu = 0
	var/total_ram = 0

	var/previous_ram = 0

	var/list/cpu_assigned = list()
	var/list/ram_assigned = list()

	var/temp_limit = AI_TEMP_LIMIT

	var/list/mob/living/silicon/ai/ai_list = list()

/datum/ai_os/New(obj/machinery/ai/creator)
	update_list(creator)

//Taken from gravity generator
/datum/ai_os/proc/update_list(obj/machinery/ai/creator)
	var/turf/creator_turf = get_turf(creator)
	if(!creator_turf)
		return
	var/list/z_list = list()
	// take multi-z into account.
	if(is_station_level(creator_turf.z))
		for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
			z_list += z
	else
		z_list += creator_turf.z

	for(var/z in z_list)
		GLOB.ai_os["[z]"] = src

/datum/ai_os/proc/add_ai(mob/living/silicon/ai/AI)
	if(AI in ai_list)
		return
	ai_list |= AI
	RegisterSignal(AI, COMSIG_PARENT_QDELETING, PROC_REF(on_ai_deleted))

/datum/ai_os/proc/remove_ai(mob/living/silicon/ai/AI)
	ai_list -= AI
	cpu_assigned -= AI
	ram_assigned -= AI
	UnregisterSignal(AI, COMSIG_PARENT_QDELETING)
	update_allocations()

/datum/ai_os/proc/on_ai_deleted(datum/source)
	SIGNAL_HANDLER
	remove_ai(source)

/datum/ai_os/proc/total_cpu_assigned()
	var/total = 0
	for(var/N in cpu_assigned)
		total += cpu_assigned[N]
	return total

/datum/ai_os/proc/total_ram_assigned()
	var/total = 0
	for(var/mob/living/silicon/ai/AI as anything in ram_assigned)
		total += (ram_assigned[AI] - AI.dashboard?.free_ram)
	return total

/datum/ai_os/proc/update_hardware()
	previous_ram = total_ram
	total_ram = 0
	total_cpu = 0
	for(var/obj/machinery/ai/server_cabinet/C as anything in GLOB.ai_server_cabinets)
		if(C.linked_os != src)
			continue
		// Szafa w okresie karencji (was_valid_holder, valid_ticks > 0) nadal się liczy
		if(!C.roundstart && !C.valid_holder() && !(C.was_valid_holder && C.valid_ticks > 0))
			continue
		total_ram += C.total_ram
		total_cpu += C.total_cpu

	update_allocations()

/datum/ai_os/proc/update_allocations()
	var/cpu_overflow = total_cpu_assigned() - total_cpu
	if(cpu_overflow > 0)
		for(var/mob/living/silicon/ai/AI as anything in cpu_assigned.Copy())
			var/taken = min(cpu_assigned[AI], cpu_overflow)
			if(!taken)
				continue
			cpu_assigned[AI] -= taken
			cpu_overflow -= taken
			to_chat(AI, span_warning("Odebrano ci część zasobów obliczeniowych. Jeśli to pomyłka, skontaktuj się z inżynierią."))
			if(cpu_overflow <= 0)
				break

	//Do we have the same amount or more RAM than before? Do nothing
	if(total_ram >= previous_ram)
		return

	//Find out how much is actually assigned. We can have more total_cpu than the sum of cpu_assigned. Same with RAM
	var/total_assigned_ram = total_ram_assigned()
	//If we have less assigned ram than we have cpu and ram, just return, everything is fine.
	if(total_assigned_ram < total_ram)
		return

	//Copy the lists of assigned resources so we don't manipulate the list prematurely.
	var/list/ram_assigned_copy = ram_assigned.Copy()

	//List of touched AIs so we can notify them at the end.
	var/list/affected_AIs = list()

	if(total_assigned_ram > total_ram)
		var/needed_amount = total_assigned_ram - total_ram
		for(var/mob/living/silicon/ai/AI as anything in ram_assigned_copy)
			var/free_ram = AI.dashboard?.free_ram
			if((ram_assigned_copy[AI] - free_ram) >= needed_amount)
				ram_assigned_copy[AI] -= needed_amount
				total_assigned_ram -= needed_amount
				affected_AIs |= AI
				break
			else if(ram_assigned_copy[AI])
				var/amount = ram_assigned_copy[AI] - free_ram
				ram_assigned_copy[AI] -= amount
				affected_AIs |= AI
				needed_amount -= amount
				total_assigned_ram -= amount
				if(total_ram >= total_assigned_ram)
					break
	//Set the actual values of the assigned to our manipulated copies. Bypass helper procs as we assume we're correct.
	ram_assigned = ram_assigned_copy

	for(var/mob/living/silicon/ai/AI as anything in affected_AIs)
		to_chat(AI, span_warning("Odebrano ci część zasobów obliczeniowych. Jeśli to pomyłka, skontaktuj się z inżynierią."))

/datum/ai_os/proc/set_cpu(mob/living/silicon/ai/AI, amount, adjust_overflow = FALSE, update = TRUE)
	if(!istype(AI) || amount < 0)
		return
	//total cpu - current AIs CPU + new CPU we're giving > total_cpu
	if(total_cpu_assigned() - cpu_assigned[AI] + amount > total_cpu)
		if(!adjust_overflow)
			return
		amount = max(0, total_cpu - total_cpu_assigned() + cpu_assigned[AI])
	cpu_assigned[AI] = amount
	if(update)
		update_allocations()

/datum/ai_os/proc/set_ram(mob/living/silicon/ai/AI, amount, adjust_overflow = FALSE, update = TRUE)
	if(!istype(AI) || amount < 0)
		return
	//total ram - current AIs ram + new ram we're giving > total_ram
	if(total_ram_assigned() - ram_assigned[AI] + amount > total_ram)
		if(!adjust_overflow)
			return
		amount = max(0, total_ram - total_ram_assigned() + ram_assigned[AI])
	ram_assigned[AI] = amount
	if(update)
		update_allocations()

/datum/ai_os/proc/clear_ai_resources(mob/living/silicon/ai/AI)
	if(!istype(AI))
		return
	set_ram(AI, amount = 0, update = FALSE)
	set_cpu(AI, amount = 0, update = TRUE)

/datum/ai_os/proc/get_temp_limit()
	return temp_limit
