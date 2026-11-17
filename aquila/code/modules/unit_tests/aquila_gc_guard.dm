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
	if(first_leak)
		log_world("## aquila_gc_guard: searching references to the first leaked [first_leak.type]")
		first_leak.find_references(skip_alert = TRUE)
#endif
