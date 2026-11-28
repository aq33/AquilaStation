// AQUILA - skorupa rojowca bez bramy. Event z Bee stawiał skorupę tylko przy GLOB.the_gateway, a żaden nasz okręt
// nie ma bramy, więc event (także z puli złomowiska na mapie FTL i z weighted midround) kończył się bez efektu.
// Skorupa ląduje teraz w tunelach serwisowych albo w ładowni, jak coś przywiezione z wraku.

/// Nikt nie wejdzie w skorupę, gdy admini wyłączyli spawnery duchów
/datum/round_event_control/spawn_swarmer/canSpawnEvent(players_amt, gamemode)
	if(!(GLOB.ghost_role_flags & GHOSTROLE_SPAWNER))
		return FALSE
	return ..()

/// Stawia skorupę na losowym bezpiecznym polu, zwraca ją albo null, gdy nie ma żadnego pola
/datum/round_event/spawn_swarmer/proc/spawn_shell()
	var/list/turfs = candidate_turfs()
	if(!length(turfs))
		message_admins("Event rojowca nie znalazł bezpiecznego pola w tunelach serwisowych ani w ładowni, nic się nie pojawiło.")
		log_game("Swarmer event found no safe maintenance or cargo turf, nothing was spawned.")
		return
	var/turf/spot = pick(turfs)
	var/obj/effect/mob_spawn/swarmer/shell = new(spot)
	message_admins("Event rojowca stawia skorupę w [ADMIN_VERBOSEJMP(spot)].")
	log_game("Swarmer event spawned a swarmer shell at [AREACOORD(spot)].")
	return shell

/// Pola w tunelach serwisowych i ładowni okrętu
/datum/round_event/spawn_swarmer/proc/candidate_turfs()
	. = list()
	for(var/area/A as anything in GLOB.sortedAreas)
		if(!valid_area(A))
			continue
		for(var/turf/T in A)
			if(valid_turf(T))
				. += T
		CHECK_TICK

/datum/round_event/spawn_swarmer/proc/valid_area(area/A)
	var/static/list/allowed_areas = typecacheof(list(
		/area/maintenance,
		/area/quartermaster/storage,
		/area/quartermaster/warehouse,
		/area/cargo,
	))
	var/static/list/excluded_areas = typecacheof(list(
		/area/maintenance/solars, // pół w kosmosie
		/area/maintenance/disposal, // taśmociągi, zgniatarka i spalarnia
		/area/maintenance/department/science/xenobiology, // zagrody szlamów na niektórych mapach
	))
	return is_type_in_typecache(A, allowed_areas) && !is_type_in_typecache(A, excluded_areas)

/datum/round_event/spawn_swarmer/proc/valid_turf(turf/T)
	if(!T || !is_station_level(T.z) || !valid_area(get_area(T)))
		return FALSE
	if(isgroundlessturf(T) || !is_turf_safe(T))
		return FALSE
	if(is_blocked_turf(T))
		return FALSE
	if(locate(/obj/effect/mob_spawn) in T)
		return FALSE
	return TRUE

/datum/round_event/spawn_swarmer/proc/announce_shell(obj/effect/mob_spawn/swarmer/shell)
	var/area/A = get_area(shell)
	var/swarmer_report = "<span class='big bold'>Komunikat wysokiego priorytetu: [command_name()]</span>"
	swarmer_report += "<br><br>Nasze czujniki dalekiego zasięgu wykryły na pokładzie waszego okrętu dziwny sygnał. Jego źródło jest w okolicy: [A?.name]. Zalecamy natychmiastowe sprawdzenie ładunku i tuneli serwisowych, bo mogło się z nimi coś przedostać."
	print_command_report(swarmer_report, announce = TRUE)
