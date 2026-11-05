#define MAX_SPAWN_ATTEMPT 3


/datum/round_event/ghost_role
	// We expect 0 or more /clients (or things with .key) in this list
	var/list/priority_candidates = list()
	var/minimum_required = 1
	var/role_name = "debug rat with cancer" // Q U A L I T Y  M E M E S
	var/list/spawned_mobs = list()
	var/status
	fakeable = FALSE

/datum/round_event/ghost_role/start()
	try_spawning()

/datum/round_event/ghost_role/proc/try_spawning(sanity = 0, retry = 0)
	// The event does not run until the spawning has been attempted
	// to prevent us from getting gc'd halfway through
	processing = FALSE

	status = spawn_role()
	if((status == WAITING_FOR_SOMETHING))
		if(retry >= MAX_SPAWN_ATTEMPT)
			message_admins("Event [role_name] przekracza limit prób pojawienia się. Przerywam i zwracam.")
			if(control && control.occurrences > 0)	//Don't refund if it hasn't
				control.occurrences--
			return
		var/waittime = 300 * (2**retry)
		message_admins("Event nie stworzy roli [role_name], dopóki nie zostaną \
			spełnione pewne warunki. Czekam [waittime/10] s i ponawiam.")
		addtimer(CALLBACK(src, PROC_REF(try_spawning), 0, ++retry), waittime)
		return

	if(status == MAP_ERROR)
		message_admins("Nie można stworzyć roli [role_name] z powodu błędu mapy.")
	else if(status == NOT_ENOUGH_PLAYERS)
		message_admins("Nie można stworzyć roli [role_name], bo nie zgłosiło się \
			dość graczy.")
	else if(status == SUCCESSFUL_SPAWN)
		message_admins("Rola [role_name] pojawia się pomyślnie.")
		if(spawned_mobs.len)
			for (var/mob/M in spawned_mobs)
				announce_to_ghosts(M)
		else
			message_admins("Brak mobów na liście `spawned_mobs`, to jest \
				błąd.")
	else
		message_admins("Próba stworzenia roli [role_name] zwraca [status], \
			to jest błąd.")

	processing = TRUE

/datum/round_event/ghost_role/proc/spawn_role()
	// Return true if role was successfully spawned, false if insufficent
	// players could be found, and just runtime if anything else happens
	return TRUE

/datum/round_event/ghost_role/proc/get_candidates(banning_key, role_preference, poll_ignore = null)
	// Returns a list of candidates in priority order, with candidates from
	// `priority_candidates` first, and ghost roles randomly shuffled and
	// appended after
	var/list/mob/dead/observer/regular_candidates
	// don't get their hopes up
	if(priority_candidates.len < minimum_required)
		regular_candidates = pollGhostCandidates("Czy chcesz zgłosić się do specjalnej roli: '[role_name]'?", banning_key, role_preference, ignore_category = poll_ignore)
	else
		regular_candidates = list()

	shuffle_inplace(regular_candidates)

	var/list/candidates = priority_candidates + regular_candidates

	return candidates

#undef MAX_SPAWN_ATTEMPT
