// Event „Złomiarze”: statek złomiarzy pojawia się w pustej przestrzeni, duchy zajmują sleepery.
// Działa też jako antagonista midround o średniej wadze w trybie weighted (medium_events()).

/datum/round_event_control/salvagers
	name = "Salvagers"
	typepath = /datum/round_event/salvagers
	weight = 8
	max_occurrences = 1
	min_players = 12
	dynamic_should_hijack = TRUE
	gamemode_blacklist = list("nuclear")
	cannot_spawn_after_shuttlecall = TRUE

// Złomiarze to rola dla duchów, ale event nie dziedziczy po /datum/round_event/ghost_role, więc flagę sprawdzamy sami
/datum/round_event_control/salvagers/canSpawnEvent(players_amt, gamemode)
	if(!(GLOB.ghost_role_flags & GHOSTROLE_MIDROUND_EVENT))
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
	var/list/candidates = pollGhostCandidates("Czy chcesz dołączyć do załogi złomiarzy?", ROLE_SPACE_PIRATE, /datum/role_preference/midround_ghost/space_pirate, 15 SECONDS)
	shuffle_inplace(candidates)
	var/datum/map_template/shuttle/pirate/salvager/ship = new
	var/x = rand(TRANSITIONEDGE, world.maxx - TRANSITIONEDGE - ship.width)
	var/y = rand(TRANSITIONEDGE, world.maxy - TRANSITIONEDGE - ship.height)
	var/turf/T = locate(x, y, SSmapping.empty_space.z_value)
	if(!T)
		CRASH("Salvager event found no turf to load in")
	if(!ship.load(T))
		CRASH("Loading the salvager ship failed!")
	for(var/turf/A in ship.get_affected_turfs(T))
		for(var/obj/effect/mob_spawn/human/pirate/salvager/spawner in A)
			if(length(candidates))
				var/mob/M = candidates[1]
				spawner.create(M.ckey)
				candidates -= M
				notify_ghosts("Statek złomiarzy ma ciekawy obiekt: [M]!", source = M, action = NOTIFY_ORBIT, header = "Coś ciekawego!")
			else
				notify_ghosts("Statek złomiarzy ma ciekawy obiekt: [spawner]!", source = spawner, action = NOTIFY_ORBIT, header = "Coś ciekawego!")
	priority_announce("Skanery wykryły statek złomiarzy, który trzyma się naszego kursu. Złomiarze rozbierają wszystko, co nie jest przykręcone, a często także to, co jest. Pilnujcie maszyn.", "Statek złomiarzy", SSstation.announcer.get_rand_alert_sound())
