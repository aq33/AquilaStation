// AQUILA - prom, którego wnętrze jest shuttle'em (Su-437 Sabre, prom zbudowany Wyznacznikiem Stref Promu).
// W doku wnętrze stoi na porcie, a jednostka overmapy czeka przy nim niewidoczna (shuttle_anchor_turf). Start przenosi
// wnętrze na prywatny parking w rezerwacji i wypuszcza jednostkę na overmapę obok gospodarza. Dokowanie (komputer
// dokowania w trybie dokowania) sadza wnętrze na porcie celu albo na wolnym miejscu przy jego kadłubie, tak żeby
// wyjście z promu wychodziło na pokład. Wszystko działa tylko przy ustawionym shuttle_port; zwykłe promy desantowe
// z wnętrzem w rezerwacji zachowują się po staremu.

/// Maksymalna odległość (w polach) szukania miejsca do lądowania od środka wnętrza celu
#define SHUTTLE_CRAFT_SEARCH_RANGE 60
/// Jak długo komputer dokowania czeka na wczytanie wnętrza asteroidy
#define SHUTTLE_CRAFT_ASTEROID_WAIT (30 SECONDS)
/// Jak długo po starcie prom nie dokuje z powrotem do gospodarza, na którego jeszcze nachodzi
#define SHUTTLE_CRAFT_LAUNCH_GRACE (15 SECONDS)

/// Miejsce lądowania wybrane przez komputer dokowania albo parking w rezerwacji; wymiary i kierunek jak u promu
/obj/docking_port/stationary/shuttle_craft_spot
	name = "miejsce lądowania"

/obj/structure/overmap/small_craft/transport
	/// Wnętrze (mobilny port shuttle'a); null dla promów z wnętrzem w rezerwacji
	var/obj/docking_port/mobile/shuttle_port
	/// Port, na którym stoi wnętrze; null w locie
	var/obj/docking_port/stationary/shuttle_docked_at
	/// Port, na którym prom zaczął (wraca tam, jeśli jest wolny)
	var/obj/docking_port/stationary/shuttle_home_port
	/// Prywatny port w rezerwacji, na którym czeka wnętrze w locie
	var/obj/docking_port/stationary/shuttle_craft_spot/shuttle_parking
	var/datum/turf_reservation/shuttle_parking_reservation
	/// Przesunięcia pól wnętrza względem mobilnego portu (do szukania miejsca do lądowania)
	var/list/hull_offsets
	/// Przesunięcia pól przed wyjściem z promu względem mobilnego portu
	var/list/exit_offsets
	/// Okręt, z którego prom ostatnio wystartował, i kiedy (żeby od razu do niego nie wrócić)
	var/obj/structure/overmap/shuttle_launch_host
	var/shuttle_launched_at = 0
	/// Podpowiedź dla pilota, czemu prom nie dokuje, najwyżej co 5 sekund
	COOLDOWN_DECLARE(shuttle_dock_hint_cooldown)

/obj/structure/overmap/small_craft/transport/Destroy()
	if(!shuttle_port)
		return ..()
	var/obj/docking_port/mobile/interior = shuttle_port
	var/obj/docking_port/stationary/parking = shuttle_parking
	var/datum/turf_reservation/parking_reservation = shuttle_parking_reservation
	if(shuttle_landing_eye)
		shuttle_manual_landing_end(shuttle_landing_eye)
	shuttle_launch_host = null
	// Najpierw small_craft/Destroy ewakuuje załogę; rezerwacja z wnętrzem w locie znika dopiero potem
	. = ..()
	// Wnętrze w locie stoi na parkingu: bez jednostki nie ma dokąd wrócić, więc znika razem z nią
	if(parking && interior && !QDELETED(interior) && interior.docked == parking)
		interior.jumpToNullSpace()
	shuttle_port = null
	shuttle_docked_at = null
	shuttle_home_port = null
	shuttle_parking = null
	shuttle_parking_reservation = null
	if(parking && !QDELETED(parking) && !parking.docked)
		qdel(parking, TRUE)
	qdel(parking_reservation)

/// Łączy jednostkę z wnętrzem stojącym na porcie
/obj/structure/overmap/small_craft/transport/proc/shuttle_link(obj/docking_port/mobile/port)
	shuttle_port = port
	shuttle_home_port = port.docked
	linked_areas = list()
	for(var/area/A as anything in port.shuttle_areas)
		linked_areas += A
	interior_entry_points = list()
	for(var/turf/T as anything in port.return_turfs())
		if(!port.shuttle_areas[T.loc])
			continue
		var/obj/effect/landmark/dropship_entry/entry = locate() in T
		if(entry)
			interior_entry_points += entry
			entry.linked = src
		var/obj/machinery/computer/ship/navigation/nav = locate() in T
		if(nav && !starmap)
			starmap = nav
	linked_virtual_z = get_new_virtual_z()
	interior_status = INTERIOR_READY
	shuttle_dock_hide(port.docked)
	// Napęd FTL wiąże się z okrętem w LateInitialize tylko przy wczytaniu mapy: prom tworzony przez port robi to tutaj
	set_ftl_tether(ftl_home_overmap())

/// Pole, przy którym czeka ukryta jednostka, kiedy wnętrze stoi w doku
/obj/structure/overmap/small_craft/transport/proc/shuttle_anchor_turf()
	return get_turf(shuttle_port)

/// Pola, na które wychodzi się z promu: przed śluzami na zewnętrznej ścianie wnętrza
/obj/structure/overmap/small_craft/transport/proc/shuttle_exit_turfs()
	. = list()
	if(!shuttle_port)
		return
	for(var/turf/T as anything in shuttle_port.return_turfs())
		if(!shuttle_port.shuttle_areas[T.loc] || !(locate(/obj/machinery/door/airlock) in T))
			continue
		for(var/dir in GLOB.cardinals)
			var/turf/outside = get_step(T, dir)
			if(outside && !shuttle_port.shuttle_areas[outside.loc])
				. |= outside

/// Kształt wnętrza i pola przed wyjściem względem mobilnego portu (liczone przed każdym lądowaniem)
/obj/structure/overmap/small_craft/transport/proc/shuttle_cache_offsets()
	hull_offsets = list()
	exit_offsets = list()
	for(var/turf/T as anything in shuttle_port.return_turfs())
		if(!shuttle_port.shuttle_areas[T.loc])
			continue
		hull_offsets += list(list(T.x - shuttle_port.x, T.y - shuttle_port.y))
	for(var/turf/outside as anything in shuttle_exit_turfs())
		exit_offsets += list(list(outside.x - shuttle_port.x, outside.y - shuttle_port.y))

/// Chowa jednostkę przy wnętrzu stojącym na porcie
/obj/structure/overmap/small_craft/transport/proc/shuttle_dock_hide(obj/docking_port/stationary/port)
	shuttle_docked_at = port
	velocity._set(0, 0)
	angular_velocity = 0
	user_thrust_dir = 0
	brakes = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_ABSTRACT
	resistance_flags |= INDESTRUCTIBLE
	var/turf/T = shuttle_anchor_turf()
	if(T)
		forceMove(T)

/obj/structure/overmap/small_craft/transport/proc/shuttle_unhide()
	shuttle_docked_at = null
	density = initial(density)
	mouse_opacity = initial(mouse_opacity)
	invisibility = initial(invisibility)
	resistance_flags = initial(resistance_flags)

/obj/structure/overmap/small_craft/transport/can_move()
	if(shuttle_docked_at)
		return FALSE
	return ..()

/// Ludzie we wnętrzu zmieniają okręt, w którym są (dźwięki, paralaksa, wirtualny Z)
/obj/structure/overmap/small_craft/transport/proc/shuttle_refresh_occupants()
	for(var/area/A as anything in shuttle_port?.shuttle_areas)
		for(var/mob/M in A)
			M.update_overmap()

/// Nowy port dla tego wnętrza: te same wymiary i kierunek (chyba że pilot obrócił miejsce lądowania kamerą)
/obj/structure/overmap/small_craft/transport/proc/shuttle_new_spot(turf/T, spot_name, spot_dir)
	var/obj/docking_port/stationary/shuttle_craft_spot/spot = new(T)
	spot.dir = spot_dir || shuttle_port.dir
	spot.width = shuttle_port.width
	spot.height = shuttle_port.height
	spot.dwidth = shuttle_port.dwidth
	spot.dheight = shuttle_port.dheight
	spot.name = spot_name
	return spot

/// Prywatny port w rezerwacji, na którym wnętrze czeka w locie
/obj/structure/overmap/small_craft/transport/proc/shuttle_make_parking()
	if(shuttle_parking)
		return shuttle_parking
	var/list/box = shuttle_port.return_coords(0, 0, shuttle_port.dir)
	var/min_x = min(box[1], box[3])
	var/min_y = min(box[2], box[4])
	shuttle_parking_reservation = SSmapping.RequestBlockReservation(abs(box[3] - box[1]) + 3, abs(box[4] - box[2]) + 3)
	if(!shuttle_parking_reservation)
		return
	shuttle_parking_reservation.overmap_fallback = src
	var/list/bl = shuttle_parking_reservation.bottom_left_coords
	shuttle_parking = shuttle_new_spot(locate(bl[1] + 1 - min_x, bl[2] + 1 - min_y, bl[3]), "parking [name]")
	return shuttle_parking

/// Czy można teraz wystartować (paliwo, silniki); komunikat dla gracza przy odmowie
/obj/structure/overmap/small_craft/transport/proc/shuttle_can_launch(mob/user)
	if(get_fuel() <= 0)
		to_chat(user, span_warning("Zbiornik paliwa [src] jest pusty."))
		return FALSE
	return TRUE

/// Start: wnętrze na parking, jednostka na overmapę obok gospodarza
/obj/structure/overmap/small_craft/transport/proc/shuttle_launch(mob/user)
	if(!shuttle_docked_at || !shuttle_port)
		return FALSE
	var/obj/structure/overmap/host = get_overmap()
	if(!host?.current_system)
		to_chat(user, span_warning("Nie można wystartować: [host ? host : "port"] nie jest teraz w żadnym układzie."))
		return FALSE
	if(!shuttle_can_launch(user))
		return FALSE
	var/obj/docking_port/stationary/parking = shuttle_make_parking()
	if(!parking)
		to_chat(user, span_warning("Błąd systemu startowego [src]."))
		message_admins("[src] nie zdołał zarezerwować miejsca na wnętrze w locie.")
		return FALSE
	var/obj/docking_port/stationary/old_port = shuttle_docked_at
	var/result = shuttle_port.initiate_docking(parking)
	if(result != DOCKING_SUCCESS)
		to_chat(user, span_warning("Zaczepy dokowania [src] się nie zwolniły."))
		message_admins("[src] nie wystartował z [old_port] (błąd [result]).")
		return FALSE
	shuttle_cache_offsets()
	shuttle_unhide()
	last_overmap = host
	if(old_port == shuttle_home_port)
		set_ftl_tether(host)
	else if(!get_ftl_tether())
		set_ftl_tether(ftl_home_overmap())
	check_overmap_elegibility(ignore_position = TRUE, ignore_cooldown = TRUE)
	shuttle_launch_host = host
	shuttle_launched_at = world.time
	// Pilot siada za sterem dopiero po starcie, więc podpowiedź o trybie dokowania z check_overmap_elegibility do nikogo
	// nie dociera: prom z wnętrzem od razu jest gotowy do dokowania
	var/obj/item/fighter_component/docking_computer/DC = loadout.get_slot(HARDPOINT_SLOT_DOCKING)
	if(DC)
		DC.docking_mode = TRUE
	shuttle_refresh_occupants()
	relay('nsv13/sound/effects/ship/boarding_pod.ogg', "<span class='notice'>Zaczepy dokowania zwalniają się i [src] odrywa się od [host].</span>")
	if(DC)
		relay(null, "<span class='notice'>Tryb dokowania włączony: wleć w sojuszniczy okręt albo asteroidę, żeby zadokować.</span>")
	if(istype(old_port, /obj/docking_port/stationary/shuttle_craft_spot))
		qdel(old_port, TRUE)
	log_game("[key_name(user)] launched [src] from [old_port] ([host])")
	return TRUE

/obj/structure/overmap/small_craft/transport/docking_act(obj/structure/overmap/OM)
	if(!shuttle_port)
		return ..()
	if(shuttle_docked_at || OM == src || shuttle_landing_eye)
		return FALSE
	// Tuż po starcie prom wciąż nachodzi na gospodarza: bez tego od razu by do niego wrócił
	if(OM == shuttle_launch_host && world.time < shuttle_launched_at + SHUTTLE_CRAFT_LAUNCH_GRACE)
		return FALSE
	if(istype(OM, /obj/structure/overmap/asteroid/shipbreak_wreck))
		return FALSE // Wnętrze wraku istnieje tylko w klatce magnesu (jak w small_craft/docking_act)
	var/obj/item/fighter_component/docking_computer/DC = loadout.get_slot(HARDPOINT_SLOT_DOCKING)
	if(!DC)
		shuttle_dock_hint(OM, "[src] nie ma komputera dokowania, więc nie zadokuje przy [OM]. Zamontuj go, kiedy prom stoi w doku.")
		return FALSE
	if(DC.docking_cooldown)
		if(!isasteroid(OM) || OM.interior_status == INTERIOR_READY) // Przy wczytywanej asteroidzie czeka się na skan
			shuttle_dock_hint(OM, "Komputer dokowania [src] jeszcze się przygotowuje. Spróbuj ponownie za kilka sekund.")
		return FALSE
	if(!DC.docking_mode)
		shuttle_dock_hint(OM, "Tryb dokowania jest wyłączony. Włącz go przyciskiem „Tryb dokowania” w panelu jednostki i wleć w [OM].")
		return FALSE
	if(istype(OM, /obj/structure/overmap/asteroid) && OM.interior_status != INTERIOR_READY)
		var/obj/structure/overmap/asteroid/AS = OM
		AS.interior_mode = INTERIOR_DYNAMIC
		DC.docking_cooldown = TRUE
		RegisterSignal(AS, COMSIG_INTERIOR_DONE_LOADING, PROC_REF(shuttle_asteroid_loaded))
		SSstar_system.queue_for_interior_load(AS)
		addtimer(CALLBACK(src, PROC_REF(shuttle_asteroid_timeout), AS), SHUTTLE_CRAFT_ASTEROID_WAIT)
		if(pilot)
			to_chat(pilot, span_notice("Komputer dokowania skanuje [AS]. To potrwa chwilę, zostań w pobliżu."))
		return TRUE
	DC.docking_cooldown = TRUE
	INVOKE_ASYNC(src, PROC_REF(shuttle_begin_landing), OM)
	return TRUE

/// Pilot wleciał w sojuszniczy okręt albo asteroidę, a prom nie może zadokować: mówi mu, co zrobić
/obj/structure/overmap/small_craft/transport/proc/shuttle_dock_hint(obj/structure/overmap/OM, message)
	if(!pilot || !COOLDOWN_FINISHED(src, shuttle_dock_hint_cooldown))
		return
	if(!isasteroid(OM) && OM.faction != faction)
		return
	COOLDOWN_START(src, shuttle_dock_hint_cooldown, 5 SECONDS)
	to_chat(pilot, span_warning(message))

/obj/structure/overmap/small_craft/transport/proc/shuttle_asteroid_loaded(obj/structure/overmap/asteroid/AS)
	SIGNAL_HANDLER
	UnregisterSignal(AS, COMSIG_INTERIOR_DONE_LOADING)
	INVOKE_ASYNC(src, PROC_REF(shuttle_begin_landing), AS)

/// Asteroida zniknęła albo jej wnętrze się nie wczytało: komputer dokowania nie może czekać w nieskończoność
/obj/structure/overmap/small_craft/transport/proc/shuttle_asteroid_timeout(obj/structure/overmap/asteroid/AS)
	if(QDELETED(src) || shuttle_docked_at || shuttle_landing_eye)
		return
	if(!QDELETED(AS))
		UnregisterSignal(AS, COMSIG_INTERIOR_DONE_LOADING)
	var/obj/item/fighter_component/docking_computer/DC = loadout.get_slot(HARDPOINT_SLOT_DOCKING)
	if(DC)
		DC.docking_cooldown = FALSE

/// Szuka miejsca (to może potrwać kilka ticków) i ląduje; bez miejsca komputer dokowania odpoczywa 10 sekund
/obj/structure/overmap/small_craft/transport/proc/shuttle_try_land(obj/structure/overmap/OM)
	var/obj/item/fighter_component/docking_computer/DC = loadout.get_slot(HARDPOINT_SLOT_DOCKING)
	if(pilot)
		to_chat(pilot, span_notice("Komputer dokowania szuka miejsca do lądowania przy [OM]..."))
	var/obj/docking_port/stationary/port = shuttle_find_landing(OM)
	if(QDELETED(src) || QDELETED(OM) || shuttle_docked_at)
		if(istype(port, /obj/docking_port/stationary/shuttle_craft_spot))
			qdel(port, TRUE)
		if(!QDELETED(src) && !shuttle_docked_at && DC)
			DC.docking_cooldown = FALSE // Cel zniknął w trakcie szukania: komputer dokowania nie może zostać zablokowany
		return
	if(!port || !shuttle_land(OM, port))
		if(pilot && !port)
			to_chat(pilot, span_warning("Komputer dokowania nie znajduje miejsca do lądowania przy [OM]."))
		if(DC)
			addtimer(VARSET_CALLBACK(DC, docking_cooldown, FALSE), 10 SECONDS)

/// Wolne porty celu, na których ten prom może stanąć (oprócz portu domowego)
/obj/structure/overmap/small_craft/transport/proc/shuttle_preferred_ports(obj/structure/overmap/OM)
	return list()

/// Port domowy, wolny port celu, a bez nich miejsce przy kadłubie, z którego wyjście prowadzi na pokład
/obj/structure/overmap/small_craft/transport/proc/shuttle_find_landing(obj/structure/overmap/OM)
	if(shuttle_home_port && !shuttle_home_port.docked && shuttle_home_port.get_overmap() == OM)
		return shuttle_home_port
	for(var/obj/docking_port/stationary/port as anything in shuttle_preferred_ports(OM))
		if(!port.docked && port.get_overmap() == OM && shuttle_port.canDock(port) == SHUTTLE_CAN_DOCK)
			return port
	var/turf/center = shuttle_landing_center(OM)
	if(!center)
		return
	if(!length(hull_offsets))
		shuttle_cache_offsets()
	var/turf/spot_turf = shuttle_find_spot(OM, center)
	if(!spot_turf)
		return
	return shuttle_new_spot(spot_turf, "miejsce lądowania przy [OM]")

/// Gdzie szukać miejsca do lądowania: środek wnętrza celu albo jego punkt dokowania
/obj/structure/overmap/small_craft/transport/proc/shuttle_landing_center(obj/structure/overmap/OM)
	if(length(OM.occupying_levels))
		var/datum/space_level/level = OM.occupying_levels[1]
		return locate(round(world.maxx / 2), round(world.maxy / 2), level.z_value)
	if(OM.roomReservation)
		var/list/bl = OM.roomReservation.bottom_left_coords
		var/list/tr = OM.roomReservation.top_right_coords
		return locate(round((bl[1] + tr[1]) / 2), round((bl[2] + tr[2]) / 2), bl[3])
	if(length(OM.docking_points))
		return get_turf(OM.docking_points[1])

/// Czy wnętrze zmieści się z mobilnym portem na polu (x, y, z); offsets to kształt kadłuba (domyślnie bez obrotu)
/obj/structure/overmap/small_craft/transport/proc/shuttle_spot_free(obj/structure/overmap/OM, x, y, z, list/offsets)
	for(var/list/offset as anything in (offsets || hull_offsets))
		if(!shuttle_landing_turf_free(OM, locate(x + offset[1], y + offset[2], z)))
			return FALSE
	return TRUE

/// Czy na tym polu może stanąć kawałek kadłuba: wolny kosmos w obrębie wnętrza celu
/obj/structure/overmap/small_craft/transport/proc/shuttle_landing_turf_free(obj/structure/overmap/OM, turf/T)
	if(!T || T.x <= TRANSITIONEDGE || T.y <= TRANSITIONEDGE || T.x > world.maxx - TRANSITIONEDGE || T.y > world.maxy - TRANSITIONEDGE)
		return FALSE
	if(!isspaceturf(T) || istype(T, /turf/open/space/transit) || istype(T.loc, /area/shuttle))
		return FALSE
	if(OM.roomReservation && SSmapping.used_turfs[T] != OM.roomReservation)
		return FALSE
	if(OM.boarding_interior && OM.interior_mode == INTERIOR_EXCLUSIVE && T.x <= OM.boarding_interior.width && T.y <= OM.boarding_interior.height)
		return FALSE // To wnętrze zniknie razem z poziomem abordażu
	for(var/atom/movable/AM as anything in T)
		if(AM.density)
			return FALSE
	return TRUE

/// Najpierw miejsca, z których wyjście prowadzi prosto na podłogę celu, potem takie, z których wychodzi się na kosmos
/// tuż przy skale (górnik od razu kopie), a na końcu wolny kosmos najbliżej środka
/obj/structure/overmap/small_craft/transport/proc/shuttle_find_spot(obj/structure/overmap/OM, turf/center)
	var/z = center.z
	var/best_distance = INFINITY
	var/turf/best
	for(var/turf/open/floor in RANGE_TURFS(SHUTTLE_CRAFT_SEARCH_RANGE, center))
		if(isspaceturf(floor) || floor.density || istype(floor.loc, /area/shuttle))
			continue
		var/next_to_space = FALSE
		for(var/dir in GLOB.cardinals)
			if(isspaceturf(get_step(floor, dir)))
				next_to_space = TRUE
				break
		if(!next_to_space)
			continue
		var/distance = get_dist(floor, center)
		if(distance >= best_distance)
			continue
		for(var/list/offset as anything in exit_offsets)
			var/x = floor.x - offset[1]
			var/y = floor.y - offset[2]
			if(shuttle_spot_free(OM, x, y, z))
				best = locate(x, y, z)
				best_distance = distance
				break
		CHECK_TICK
	if(best)
		return best
	for(var/turf/closed/mineral/rock in RANGE_TURFS(SHUTTLE_CRAFT_SEARCH_RANGE, center))
		var/distance = get_dist(rock, center)
		if(distance >= best_distance)
			continue
		for(var/dir in GLOB.cardinals)
			var/turf/outside = get_step(rock, dir)
			if(!isspaceturf(outside) || istype(outside, /turf/open/space/transit))
				continue
			for(var/list/offset as anything in exit_offsets)
				var/x = outside.x - offset[1]
				var/y = outside.y - offset[2]
				if(shuttle_spot_free(OM, x, y, z))
					best = locate(x, y, z)
					best_distance = distance
					break
			if(best_distance == distance)
				break
		CHECK_TICK
	if(best)
		return best
	// Pierścienie szerokości 2 od środka (sam środek przy promieniu 0), bez odejmowania list
	for(var/radius in 0 to SHUTTLE_CRAFT_SEARCH_RANGE step 2)
		for(var/turf/T as anything in RANGE_TURFS(radius, center))
			if(radius && max(abs(T.x - center.x), abs(T.y - center.y)) <= radius - 2)
				continue
			if(shuttle_spot_free(OM, T.x, T.y, z))
				return T
			CHECK_TICK

/// Lądowanie: wnętrze na port, jednostka chowa się przy nim (jak transfer_from_overmap myśliwców)
/obj/structure/overmap/small_craft/transport/proc/shuttle_land(obj/structure/overmap/OM, obj/docking_port/stationary/port)
	if(shuttle_docked_at || !shuttle_port)
		return FALSE
	var/result = shuttle_port.initiate_docking(port)
	if(result != DOCKING_SUCCESS)
		if(istype(port, /obj/docking_port/stationary/shuttle_craft_spot) && !port.docked)
			qdel(port, TRUE)
		if(pilot)
			to_chat(pilot, span_warning("Dokowanie do [OM] nie powiodło się."))
		message_admins("[src] nie zadokował w [port] przy [OM] (błąd [result]).")
		return FALSE
	enemies = list() //Reset RWR warning.
	last_overmap = OM
	var/obj/item/fighter_component/docking_computer/DC = loadout.get_slot(HARDPOINT_SLOT_DOCKING)
	if(DC)
		DC.docking_cooldown = TRUE
		addtimer(VARSET_CALLBACK(DC, docking_cooldown, FALSE), 20 SECONDS)
		DC.docking_mode = FALSE
	if(port == shuttle_home_port)
		set_ftl_tether(OM)
	resize = 0
	pixel_w = initial(pixel_w)
	pixel_z = initial(pixel_z)
	bound_width = initial(bound_width)
	bound_height = initial(bound_height)
	var/turf/T = shuttle_anchor_turf()
	if(current_system)
		current_system.remove_ship(src, T, is_ftl_jump = FALSE)
	OM.overmaps_in_ship += src
	weapon_safety = TRUE
	shuttle_dock_hide(port)
	SEND_SIGNAL(src, COMSIG_FTL_STATE_CHANGE)
	if(reserved_z)
		free_treadmills += reserved_z
		reserved_z = null
	relay('nsv13/sound/effects/ship/boarding_pod.ogg', "<span class='notice'>[src] dokuje przy [OM]. Zaczepy zablokowane.</span>")
	for(var/mob/living/M in operators)
		stop_piloting(M)
	// Po lądowaniu ludzie należą do gospodarza: nikt już nie wyłączy im pętli alarmu promu ani dźwięku skoku
	set_master_caution(FALSE)
	stop_relay(CHANNEL_SHIP_ALERT)
	shuttle_refresh_occupants()
	return TRUE

/// Wyjście z promu na pole przed wyjściem (wolne, najlepiej na podłodze)
/obj/structure/overmap/small_craft/transport/proc/shuttle_leave(atom/movable/AM)
	var/turf/T
	var/obj/machinery/door/airlock/exit_door
	for(var/turf/candidate as anything in shuttle_exit_turfs())
		var/obj/machinery/door/airlock/door
		if(is_blocked_turf(candidate, TRUE))
			door = shuttle_exit_door(candidate, AM)
			if(!door)
				continue
		if(!T || (shuttle_exit_unsafe(T) && !shuttle_exit_unsafe(candidate)))
			T = candidate
			exit_door = door
	if(!T)
		return FALSE
	if(exit_door)
		INVOKE_ASYNC(exit_door, TYPE_PROC_REF(/obj/machinery/door, open))
	var/mob/user = ismob(AM) ? AM : null
	var/atom/movable/pulled = user?.pulling
	playsound(src, 'nsv13/sound/effects/footstep/ladder2.ogg', 50)
	if(pulled)
		pulled.forceMove(T)
	AM.forceMove(T)
	if(pulled)
		user.start_pulling(pulled)
	mobs_in_ship -= AM
	if(user)
		user.stop_sound_channel(CHANNEL_HEARTBEAT)
		user.stop_sound_channel(CHANNEL_SHIP_ALERT)
	return TRUE

/// Wyjście zastawione tylko zamkniętą, zasilaną i nieryglowaną śluzą (właz przy drzwiach śluzy statku), do której
/// wysiadający ma dostęp: ta śluza, inaczej null
/obj/structure/overmap/small_craft/transport/proc/shuttle_exit_door(turf/T, atom/movable/AM)
	if(T.density || !ismob(AM))
		return
	var/obj/machinery/door/airlock/door = locate() in T
	if(!door || !door.density || door.locked || !door.hasPower() || !door.allowed(AM))
		return
	for(var/atom/movable/blocker as anything in T)
		if(blocker != door && blocker.density && !ismob(blocker))
			return
	return door

/// Kosmos albo otwarta przestrzeń pod nogami: wyjście tam tylko, gdy innego nie ma
/obj/structure/overmap/small_craft/transport/proc/shuttle_exit_unsafe(turf/T)
	return isspaceturf(T) || istype(T, /turf/open/openspace)

/obj/structure/overmap/small_craft/transport/exit(mob/user)
	if(shuttle_port && shuttle_docked_at)
		return shuttle_leave(user)
	return ..()

#undef SHUTTLE_CRAFT_SEARCH_RANGE
#undef SHUTTLE_CRAFT_ASTEROID_WAIT
#undef SHUTTLE_CRAFT_LAUNCH_GRACE
