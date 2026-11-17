/**
 * AQUILA - strażnik wycieków na końcu każdej części testów (aquila_unit_test_every_shard()).
 *
 * Obiekt usunięty przez test, który po chwili nadal istnieje, coś trzyma: to wyciek. SSgarbage zauważa go dopiero
 * po GC_CHECK_QUEUE (5 minut), więc w krótkiej części przechodził niezauważony, a w dłuższej kosztował ~3 minuty
 * szukania referencji z zamrożonym światem (FIND_REF_NO_CHECK_TICK). Tutaj wyciek od razu oblewa test z nazwą typu.
 * Dla pierwszego wycieku strażnik sam szuka referencji, żeby w logu było widać, co go trzyma.
 */
/datum/unit_test/aquila_gc_guard

/datum/unit_test/aquila_gc_guard/Run()
	var/started = world.time
	// SSgarbage co swoje wait sprawdza kolejkę filtra: zwolnione obiekty znikają, reszta przechodzi do kolejki sprawdzenia
	sleep(GC_FILTER_QUEUE + 2 * SSgarbage.wait)

	var/list/leaked = list()
	var/datum/first_leak
	var/list/one_of_type = list()
	for(var/level in GC_QUEUE_FILTER to GC_QUEUE_CHECK)
		for(var/list/entry as anything in SSgarbage.queues[level])
			if(length(entry) < 2)
				continue
			var/qdeleted_at = entry[1]
			if(qdeleted_at >= started) // usunięte już w trakcie czekania: jeszcze nie miały szansy się zwolnić
				continue
			var/datum/thing = locate(entry[2])
			if(!thing || thing.gc_destroyed != qdeleted_at) // zwolnione albo to już inny obiekt pod tym samym ref
				continue
			leaked[thing.type] += 1
			first_leak ||= thing
			if(!one_of_type[thing.type])
				one_of_type[thing.type] = thing

	// Wycieki, które SSgarbage już wyłapał (część dłuższa niż GC_CHECK_QUEUE)
	for(var/path in SSgarbage.items)
		var/datum/qdel_item/item = SSgarbage.items[path]
		if(item.failures)
			leaked[path] += item.failures

	if(!length(leaked))
		return
	for(var/path in leaked)
		Fail("[path] did not get collected after qdel [leaked[path]] time(s): something still holds a reference to it")
#ifdef REFERENCE_TRACKING
	// SZKIC (zbieranie danych do planu): jedno szukanie na typ. Globale i datumy trwają kilka sekund,
	// atomy (~2 min) tylko wtedy, gdy w datumach nic nie było (jak REFERENCE_TRACKING_FAST).
	var/index = 0
	for(var/path in one_of_type)
		var/datum/thing = one_of_type[path]
		index++
		thing.aquila_gc_guard_search(world.time + index / 1000)
#endif

#ifdef REFERENCE_TRACKING
/datum/proc/aquila_gc_guard_search(search_time)
	SSgarbage.can_fire = FALSE
	log_reftracker("AQGUARD Beginning search for references to a [type] \ref[src].")
	var/found = DoSearchVar(GLOB, "GLOB", search_time = search_time)
	var/global_vars = list()
	for(var/key in global.vars)
		global_vars[key] = global.vars[key]
	found = DoSearchVar(global_vars, "Native Global", search_time = search_time) || found
	for(var/datum/container)
		found = DoSearchVar(container, "Datums -> [container.type]", search_time = search_time) || found
	if(!found)
		for(var/datum/container in world)
			if(DoSearchVar(container, "World -> [container.type]", search_time = search_time))
				found = TRUE
				break
	log_reftracker("AQGUARD Completed search for [type] \ref[src]. [found ? "Found" : "No"] reference(s).")
	SSgarbage.can_fire = TRUE
	SSgarbage.next_fire = world.time + world.tick_lag
#endif
