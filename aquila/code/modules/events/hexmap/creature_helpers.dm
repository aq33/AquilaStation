// AQUILA - wspólne procedury eventów ze stworami z mapy hex (etap E4): bezpieczne pola w tunelach technicznych,
// wolne pola obok siebie, wentylacje statku, obszary, w których nic się nie pojawia, i wybór ducha z ankiety

/**
 * Typecache obszarów, w których eventy ze stworami niczego nie stawiają: niebezpieczne i zamknięte pomieszczenia.
 * Lista z unsafe_area_types w find_event_area() zabłąkanej kapsuły (aquila/code/modules/events/stray_cargo.dm), do tego
 * zbrojownia, mostek, skarbiec, pokój FTL i podstacje. Pokój socjalny maszynowni zostaje dozwolony.
 */
/proc/aquila_hex_unsafe_area_typecache()
	var/static/list/unsafe_areas
	if(!unsafe_areas)
		unsafe_areas = typecacheof(list(
			/area/ai_monitored/turret_protected,
			/area/ai_monitored/security/armory,
			/area/ai_monitored/nuke_storage,
			/area/security/nuke_storage,
			/area/bridge,
			/area/engine,
			/area/nsv/engine,
			/area/nsv/magazine,
			/area/nsv/weapons,
			/area/nsv/hanger,
			/area/nsv/shuttle,
			/area/nsv/boarding_pod,
			/area/shuttle,
			/area/maintenance/nsv/ftlroom,
			/area/maintenance/nsv/central_substation,
			/area/maintenance/nsv/port_substation,
			/area/maintenance/nsv/starboard_substation,
		))
		unsafe_areas -= typesof(/area/engine/break_room)
	return unsafe_areas

/// Czy w obszarze tego typu event ze stworami nie może niczego postawić
/proc/aquila_hex_unsafe_area_type(area_type)
	return !area_type || aquila_hex_unsafe_area_typecache()[area_type]

/**
 * Typecache obszarów, do których eventy nie wrzucają rzeczy ani ludzi (kapsuły, goście, prezenty, teleport):
 * niebezpieczne obszary z aquila_hex_unsafe_area_typecache() i zamknięte pomieszczenia: bryg i cele, gabinety
 * dowództwa, magazyn EVA, bezpieczny magazyn techniczny, teleporter, ksenobiologia, wirusologia i komora spalania toksyn.
 */
/proc/aquila_hex_closed_area_typecache()
	var/static/list/closed_areas
	if(!closed_areas)
		var/list/unsafe_areas = aquila_hex_unsafe_area_typecache()
		closed_areas = unsafe_areas.Copy()
		var/list/extra = typecacheof(list(
			/area/security/brig,
			/area/security/prison,
			/area/security/warden,
			/area/security/execution,
			/area/crew_quarters/heads,
			/area/nsv/crew_quarters/heads,
			/area/ai_monitored/storage/eva,
			/area/storage/eva,
			/area/storage/tech,
			/area/teleporter,
			/area/gateway,
			/area/science/xenobiology,
			/area/medical/virology,
			/area/science/mixing/chamber,
		))
		for(var/area_type in extra)
			closed_areas[area_type] = TRUE
	return closed_areas

/// Czy do obszaru tego typu event nie może niczego wrzucić (niebezpieczny albo zamknięty)
/proc/aquila_hex_closed_area_type(area_type)
	return !area_type || aquila_hex_closed_area_typecache()[area_type]

/// Obszar tuneli technicznych statku, w którym może się coś pojawić (bez paneli słonecznych, utylizacji, zagród szlamów, pokoju FTL i podstacji)
/proc/aquila_hex_maint_area_ok(area/A)
	var/static/list/excluded_areas = typecacheof(list(
		/area/maintenance/solars,
		/area/maintenance/disposal,
		/area/maintenance/department/science/xenobiology,
	))
	return istype(A, /area/maintenance) && (A.type in GLOB.the_station_areas) && !is_type_in_typecache(A, excluded_areas) && !aquila_hex_unsafe_area_type(A.type)

/// Wolne pole podłogi z powietrzem do oddychania poza niebezpiecznymi obszarami: bez gęstych obiektów, mobów i drzwi
/proc/aquila_hex_free_safe_turf(turf/T)
	if(!isturf(T) || isgroundlessturf(T) || !is_turf_safe(T))
		return FALSE
	var/area/turf_area = get_area(T)
	if(aquila_hex_unsafe_area_type(turf_area?.type))
		return FALSE
	if(locate(/mob/living) in T)
		return FALSE
	if(locate(/obj/machinery/door) in T)
		return FALSE
	return !is_blocked_turf(T)

/// Czy między start a finish (bez nich samych) nie ma ściany ani gęstego obiektu (okna, kraty, zamkniętych drzwi); max_dist ogranicza długość linii
/proc/aquila_hex_clear_line(turf/start, turf/finish, max_dist = 7)
	if(!isturf(start) || !isturf(finish) || start.z != finish.z || get_dist(start, finish) > max_dist)
		return FALSE
	var/turf/current = start
	while(current != finish)
		current = get_step_towards(current, finish)
		if(!current)
			return FALSE
		if(current != finish && (current.density || is_blocked_turf(current, TRUE)))
			return FALSE
	return TRUE

/**
 * Stwory eventu (weakrefy z creature_refs, żywe i martwe) znikają w obłoku dymu, gdy event się kończy; lista zostaje
 * wyczyszczona. Mob, którym steruje gracz, zostaje. Zwraca, ile stworów zniknęło.
 */
/proc/aquila_hex_vanish_creatures(list/datum/weakref/creature_refs)
	. = 0
	for(var/datum/weakref/creature_ref as anything in creature_refs)
		var/mob/living/creature = creature_ref?.resolve()
		if(QDELETED(creature) || creature.key)
			continue
		var/turf/creature_turf = get_turf(creature)
		if(creature_turf)
			new /obj/effect/temp_visual/small_smoke/halfsecond(creature_turf)
			creature.visible_message("<span class='warning'>[capitalize(creature.name)] rozpływa się w powietrzu.</span>")
		qdel(creature)
		.++
	creature_refs?.Cut()

/// Klucz pierwszego kandydata z listy (zdejmuje ich po kolei), który nadal ma klucz; null, gdy nikt nie został
/proc/aquila_hex_take_candidate_key(list/candidates)
	while(length(candidates))
		var/candidate = popleft(candidates)
		var/candidate_key
		if(istype(candidate, /client))
			var/client/candidate_client = candidate
			candidate_key = candidate_client.key
		else if(ismob(candidate))
			var/mob/candidate_mob = candidate
			if(!QDELETED(candidate_mob))
				candidate_key = candidate_mob.key
		if(candidate_key)
			return candidate_key

/**
 * Losowe wolne i bezpieczne pole w tunelach technicznych statku (jeden losowy obszar po drugim).
 * Gdy statek nie ma takich tuneli, losowe wolne pole statku; null, gdy nie ma żadnego.
 */
/proc/aquila_hex_maint_turf()
	var/list/areas = list()
	for(var/area/A as anything in GLOB.sortedAreas)
		if(aquila_hex_maint_area_ok(A))
			areas += A
	while(length(areas))
		var/area/A = pick_n_take(areas)
		var/list/turfs = list()
		for(var/turf/T in A)
			if(is_station_level(T.z) && aquila_hex_free_safe_turf(T))
				turfs += T
		if(length(turfs))
			return pick(turfs)
	for(var/attempt in 1 to 10)
		var/turf/T = aquila_hex_random_ship_turf(aquila_hex_unsafe_area_typecache())
		if(aquila_hex_free_safe_turf(T))
			return T

/// Do amount wolnych pól wokół center (najbliższe pierwsze, center też się liczy), do których z center nic nie zasłania (także okno)
/proc/aquila_hex_free_turfs_near(turf/center, amount, range = 3)
	. = list()
	if(!isturf(center))
		return
	for(var/dist in 0 to range)
		for(var/turf/T as anything in (dist ? (RANGE_TURFS(dist, center) - RANGE_TURFS(dist - 1, center)) : list(center)))
			if(length(.) >= amount)
				return
			if(!isopenturf(T) || isgroundlessturf(T) || T.density || is_blocked_turf(T, TRUE))
				continue
			if(dist && !aquila_hex_clear_line(center, T, range))
				continue
			. += T

/// Pola pod wentylacjami statku, które nie są zaspawane: najpierw te w tunelach technicznych
/proc/aquila_hex_vent_turfs(maint_first = TRUE)
	var/list/maint_turfs = list()
	var/list/other_turfs = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/vent in GLOB.machines)
		if(QDELETED(vent) || vent.welded)
			continue
		var/turf/vent_turf = get_turf(vent)
		if(!vent_turf || !is_station_level(vent_turf.z) || isspaceturf(vent_turf))
			continue
		var/area/vent_area = get_area(vent_turf)
		if(aquila_hex_unsafe_area_type(vent_area?.type))
			continue
		if(maint_first && aquila_hex_maint_area_ok(vent_area))
			maint_turfs += vent_turf
		else
			other_turfs += vent_turf
	return length(maint_turfs) ? maint_turfs : other_turfs

/**
 * Kandydaci do roli ducha z eventu: jak get_candidates() roli ducha (najpierw priority_candidates, potem przetasowane
 * duchy z ankiety), ale ankieta pokazuje nazwę roli z eventu zamiast nazwy preferencji (smar ma preferencję bingla)
 * i ma własną kategorię „nie pokazuj więcej” dla tego eventu. req_hours: godziny gry żywą postacią (gdy config włącza limity).
 */
/proc/aquila_hex_poll_ghost_role(datum/round_event/ghost_role/event, banning_key, role_preference, req_hours = 0)
	var/list/candidates = event.priority_candidates.Copy()
	if(length(candidates) >= event.minimum_required || !(GLOB.ghost_role_flags & GHOSTROLE_STATION_SENTIENCE))
		return candidates
	var/list/ghosts = list()
	for(var/mob/dead/observer/ghost in GLOB.player_list)
		ghosts += ghost
	if(!length(ghosts))
		return candidates
	var/role_name = event.role_name
	var/datum/poll_config/config = new(
		question = "Czy chcesz zgłosić się do specjalnej roli: '[role_name]'?", // ten sam tekst co w get_candidates()
		role = role_preference,
		check_jobban = banning_key,
		req_hours = req_hours,
		poll_time = 30 SECONDS,
		ignore_category = "[event.type]",
		role_name_text = role_name,
		auto_add_type = POLL_AUTO_ADD_GHOSTS,
	)
	var/list/signed_up = SSpolling.poll_candidates(config, ghosts)
	if(islist(signed_up))
		candidates += shuffle(signed_up)
	return candidates

/// Czy na wolnym polu można postawić coś gęstego (automat, postać) bez zatarasowania przejścia: obok nie ma drzwi, a z czterech sąsiednich pól co najmniej trzy są wolne
/proc/aquila_hex_dense_spot_ok(turf/T)
	if(!aquila_hex_free_safe_turf(T))
		return FALSE
	for(var/turf/near in orange(1, T))
		if(locate(/obj/machinery/door) in near)
			return FALSE
	var/open_sides = 0
	for(var/side in GLOB.cardinals)
		var/turf/neighbour = get_step(T, side)
		if(isopenturf(neighbour) && !neighbour.density && !is_blocked_turf(neighbour, TRUE))
			open_sides++
	return open_sides >= 3

/**
 * Do amount wolnych i bezpiecznych pól w jednym losowym pomieszczeniu statku (bez tuneli technicznych i obszarów
 * z aquila_hex_closed_area_typecache()), na które może spaść kapsuła albo pojawić się gość. Zwraca listę pól
 * z jednego pomieszczenia, które ma ich co najmniej amount; pustą listę, gdy takiego nie ma.
 * dense - pola dla czegoś gęstego (aquila_hex_dense_spot_ok()); area_choices - typy obszarów do wyboru (domyślnie obszary
 * statku, wtedy tylko pola na poziomach statku; podane wprost biorą pola z każdego poziomu).
 */
/proc/aquila_hex_room_turfs(amount = 1, dense = FALSE, list/area_choices)
	. = list()
	var/list/choices = area_choices || GLOB.the_station_areas
	var/list/area_types = choices.Copy()
	while(length(area_types))
		var/area_type = pick_n_take(area_types)
		if(aquila_hex_closed_area_type(area_type) || ispath(area_type, /area/maintenance) || ispath(area_type, /area/space))
			continue
		var/list/turfs = list()
		for(var/turf/T as anything in get_area_turfs(area_type))
			if((!area_choices && !is_station_level(T.z)) || isspaceturf(T))
				continue
			if(dense ? aquila_hex_dense_spot_ok(T) : aquila_hex_free_safe_turf(T))
				turfs += T
		if(length(turfs) >= amount)
			for(var/i in 1 to amount)
				. += pick_n_take(turfs)
			return

/// Losowe wolne i bezpieczne pole statku (nie kosmos, nie niebezpieczny ani zamknięty obszar) do teleportu; null, gdy nie znalazł
/proc/aquila_hex_safe_teleport_turf()
	var/list/turfs = aquila_hex_safe_teleport_turfs(1)
	return length(turfs) ? turfs[1] : null

/**
 * Do amount wolnych i bezpiecznych pól statku do teleportu, każde z innego losowego obszaru (bez kosmosu i obszarów
 * z aquila_hex_closed_area_typecache()). Sprawdza najwyżej 15 obszarów, w każdym pola w losowej kolejności do pierwszego dobrego.
 */
/proc/aquila_hex_safe_teleport_turfs(amount = 1)
	. = list()
	var/list/area_types = GLOB.the_station_areas.Copy()
	var/areas_checked = 0
	while(length(area_types) && length(.) < amount && areas_checked < 15)
		var/area_type = pick_n_take(area_types)
		if(aquila_hex_closed_area_type(area_type) || ispath(area_type, /area/space))
			continue
		areas_checked++
		for(var/turf/open/T as anything in shuffle(get_area_turfs(area_type)))
			if(istype(T) && !isspaceturf(T) && is_station_level(T.z) && aquila_hex_free_safe_turf(T))
				. += T
				break

/// Pole kosmosu kilka pól od burty statku (od min_dist do max_dist), na którym można coś postawić; null, gdy żadna burta nie ma wolnego kosmosu
/proc/aquila_hex_space_spot_near_hull(min_dist = 2, max_dist = 4, list/side_order)
	for(var/side in (side_order || shuffle(GLOB.cardinals.Copy())))
		var/turf/hull = aquila_hex_ship_hull_turf(side)
		if(!isspaceturf(hull))
			continue
		var/turf/center = aquila_hex_inside_map(get_ranged_target_turf(hull, side, rand(min_dist, max_dist)))
		var/list/spots = aquila_hex_free_space_near(center, 1, 1)
		if(length(spots))
			return spots[1]

/// Nazwa pomieszczenia statku najbliższego polu w kosmosie (do range pól); null, gdy w pobliżu nie ma statku
/proc/aquila_hex_nearest_ship_area_name(turf/spot, range = 12)
	if(!isturf(spot))
		return null
	for(var/dist in 1 to range)
		for(var/turf/T as anything in (RANGE_TURFS(dist, spot) - RANGE_TURFS(dist - 1, spot)))
			if(isspaceturf(T))
				continue
			var/area/A = get_area(T)
			if(A && (A.type in GLOB.the_station_areas))
				return A.name
