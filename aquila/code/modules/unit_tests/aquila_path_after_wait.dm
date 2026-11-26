/// AQUILA - get_path_to (code/__HELPERS/path.dm): gdy wszystkie miejsca SSpathfinder są zajęte, szukający czeka,
/// a w tym czasie może zniknąć (test botów tworzy i usuwa kilkanaście botów naraz). Po czekaniu nie liczy już A*
/// dla moba bez kafelka i nie wywala „Invalid A* start or destination”, tylko zwraca pustą ścieżkę.
/datum/unit_test/aquila_path_after_wait

/datum/unit_test/aquila_path_after_wait/Run()
	var/mob/living/carbon/human/walker = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/turf/target = get_step(run_loc_floor_bottom_left, EAST)
	var/datum/flowcache/cache = SSpathfinder.mobs
	var/list/taken = list()
	var/slot = cache.getfree(src)
	while(slot)
		taken += slot
		slot = cache.getfree(src)
	var/runtimes_before = GLOB.total_runtimes
	var/list/result = list("done" = FALSE)
	INVOKE_ASYNC(src, PROC_REF(find_path), walker, target, result)
	qdel(walker)
	for(var/taken_slot in taken)
		cache.found(taken_slot)
	for(var/i in 1 to 20)
		if(result["done"])
			break
		sleep(1)
	if(!result["done"])
		return Fail("Szukanie ścieżki nie skończyło się po zwolnieniu miejsc w SSpathfinder")
	if(GLOB.total_runtimes != runtimes_before)
		return Fail("Szukanie ścieżki dla moba usuniętego w trakcie czekania wywołało runtime")
	if(length(result["path"]))
		return Fail("Usunięty mob dostał ścieżkę ([length(result["path"])] kroków)")

/datum/unit_test/aquila_path_after_wait/proc/find_path(mob/walker, turf/target, list/result)
	result["path"] = get_path_to(walker, target)
	result["done"] = TRUE
