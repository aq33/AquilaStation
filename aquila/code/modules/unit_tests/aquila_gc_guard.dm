/**
 * AQUILA - raport wycieków na końcu każdej części testów (aquila_unit_test_every_shard()).
 *
 * Obiekt usunięty przez test, który po chwili nadal istnieje, coś trzyma: to wyciek. SSgarbage zauważa go dopiero
 * po GC_CHECK_QUEUE (5 minut), więc w krótkiej części przechodził niezauważony. Tutaj lista wycieków trafia do logu
 * świata (linie "## AQUILA GC LEAK"), bez oblewania testu: zestaw wycieków zależy od czasu i kolejności testów, więc
 * oblewanie dawałoby niestabilne CI. Co trzyma dany obiekt, sprawdzisz lokalnie przez find_references().
 *
 * Znane, nienaprawione (stan 17.11.2026): okręty AI overmapy, mimiki (copy), posąg petrified, gas_mixture — bez
 * referencji widocznej dla wyszukiwarki, najpewniej trzymane przez uśpione procki (pętle AI ze sleep/spawn).
 */
/datum/unit_test/aquila_gc_guard

/datum/unit_test/aquila_gc_guard/Run()
	var/started = world.time
	// SSgarbage co swoje wait sprawdza kolejkę filtra: zwolnione obiekty znikają, reszta przechodzi do kolejki sprawdzenia
	sleep(GC_FILTER_QUEUE + 2 * SSgarbage.wait)

	var/list/leaked = list()
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

	// Wycieki, które SSgarbage już wyłapał (część dłuższa niż GC_CHECK_QUEUE)
	for(var/path in SSgarbage.items)
		var/datum/qdel_item/item = SSgarbage.items[path]
		if(item.failures)
			leaked[path] += item.failures

	for(var/path in leaked)
		log_world("## AQUILA GC LEAK: [path] did not get collected after qdel [leaked[path]] time(s)")
