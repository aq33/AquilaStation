// Event „Złomiarze” jak w Goonie: od 15. do 70. minuty rundy, duchy zgłaszają się, gra wybiera od 1 do 5 złomiarzy.
// Statek złomiarzy pojawia się w pustej przestrzeni, złomiarze budzą się w kriosleeperach.
// Działa też jako antagonista midround o średniej wadze w trybie weighted (medium_events()).

/datum/round_event_control/salvagers
	name = "Salvagers"
	typepath = /datum/round_event/salvagers
	weight = 8
	max_occurrences = 1
	min_players = 12
	earliest_start = 15 MINUTES
	dynamic_should_hijack = TRUE
	gamemode_blacklist = list("nuclear")
	cannot_spawn_after_shuttlecall = TRUE
	/// Po tylu minutach rundy złomiarze już nie przylatują
	var/latest_start = 70 MINUTES

// Złomiarze to rola dla duchów, ale event nie dziedziczy po /datum/round_event/ghost_role, więc flagę sprawdzamy sami
/datum/round_event_control/salvagers/canSpawnEvent(players_amt, gamemode)
	if(!(GLOB.ghost_role_flags & GHOSTROLE_MIDROUND_EVENT))
		return FALSE
	if(world.time - SSticker.round_start_time > latest_start)
		return FALSE
	return ..()

// Nasze mapy nie mają pustej warstwy; tworzymy ją tak jak dla piratów (aquila/code/modules/weighted/spawn_fallbacks.dm)
/datum/round_event_control/salvagers/preRunEvent()
	if(!SSmapping.empty_space)
		SSmapping.space_levels_so_far++
		SSmapping.empty_space = SSmapping.add_new_zlevel("Empty Area [SSmapping.space_levels_so_far]", list(ZTRAIT_LINKAGE = SELFLOOPING), orbital_body_type = /datum/orbital_object/z_linked/beacon/weak)
	return ..()

/datum/round_event/salvagers/start()
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(spawn_salvagers))

/proc/spawn_salvagers()
	var/list/candidates = pollGhostCandidates("Czy chcesz dołączyć do załogi złomiarzy?", ROLE_SPACE_PIRATE, /datum/role_preference/midround_ghost/salvager, 15 SECONDS)
	if(!length(candidates))
		message_admins("Złomiarze: nikt się nie zgłosił. Ankieta trafia tylko do duchów z włączoną preferencją roli „Złomiarz”.")
		return
	shuffle_inplace(candidates)
	var/count = rand(1, min(length(candidates), 5))
	var/datum/map_template/shuttle/pirate/salvager/ship = new
	var/x = rand(TRANSITIONEDGE, world.maxx - TRANSITIONEDGE - ship.width)
	var/y = rand(TRANSITIONEDGE, world.maxy - TRANSITIONEDGE - ship.height)
	var/turf/T = locate(x, y, SSmapping.empty_space.z_value)
	if(!T)
		CRASH("Salvager event found no turf to load in")
	if(!ship.load(T))
		CRASH("Loading the salvager ship failed!")
	var/list/sleepers = list()
	for(var/turf/A in ship.get_affected_turfs(T))
		for(var/obj/effect/mob_spawn/human/pirate/salvager/spawner in A)
			sleepers += spawner
	if(!length(sleepers))
		CRASH("The salvager ship has no sleepers")
	var/list/sleeper_turfs = list()
	for(var/obj/effect/mob_spawn/spawner as anything in sleepers)
		sleeper_turfs += get_turf(spawner)
	// Pierwszy sleeper to brygadzista, kolejni złomiarze dostają nowe sleepery obok istniejących
	for(var/i in 1 to count)
		var/mob/dead/observer/ghost = candidates[i]
		var/obj/effect/mob_spawn/human/pirate/salvager/spawner
		if(i <= length(sleepers))
			spawner = sleepers[i]
		else
			spawner = new /obj/effect/mob_spawn/human/pirate/salvager(pick(sleeper_turfs))
		spawner.create(ghost.ckey)
		notify_ghosts("Statek złomiarzy ma ciekawy obiekt: [ghost]!", source = ghost, action = NOTIFY_ORBIT, header = "Coś ciekawego!")
	// Złomiarze budzą się tylko na starcie, jak w Goonie: wolne sleepery znikają
	for(var/i in (count + 1) to length(sleepers))
		qdel(sleepers[i])
	message_admins("Złomiarze: na statku budzi się [count] złomiarzy.")
	priority_announce("Skanery wykryły statek złomiarzy, który trzyma się naszego kursu. Złomiarze rozbierają wszystko, co nie jest przykręcone, a często także to, co jest. Pilnujcie maszyn.", "Statek złomiarzy", SSstation.announcer.get_rand_alert_sound())
