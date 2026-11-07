// AQUILA - Su-437 Sabre jako shuttle (jak promy na Aurorze). W hangarze stoi jego wnętrze (szablon shuttle'a
// na porcie /obj/docking_port/stationary/sabre), a jednostka overmapy czeka niewidoczna przy włazie. Start ze steru
// przenosi wnętrze na prywatny port w rezerwacji i wypuszcza jednostkę na overmapę obok gospodarza; dokowanie
// (komputer dokowania w trybie dokowania) sadza wnętrze na wolnym porcie Sabre celu albo na wolnym miejscu przy
// jego kadłubie, tak żeby właz wychodził na pokład. Właz w lewej gondoli: pusta ręka = wejście, przedmioty i wąż
// paliwowy = obsługa jednostki (tankowanie, części, naprawa, karta), przeciągnięcie skrzyni = ładownia.
// Wnętrza: aquila/_maps/shuttles/sabre/ (kadłub i wyposażenie ze starego wnętrza w rezerwacji).

/// Maksymalna odległość (w polach) szukania miejsca do lądowania od środka wnętrza celu
#define SABRE_LANDING_SEARCH_RANGE 60

/area/shuttle/sabre
	name = "Su-437 Sabre"
	icon_state = "shuttle"
	lighting_colour_tube = "#e6af68"
	lighting_colour_bulb = "#e6af68"
	teleport_restriction = TELEPORT_ALLOW_NONE
	/// Sabre, do którego należy to wnętrze
	var/obj/structure/overmap/small_craft/transport/sabre/shuttle/sabre

/// W locie wnętrze ma własny wirtualny Z jak wnętrza promów desantowych, w doku należy do poziomu gospodarza
/area/shuttle/sabre/get_virtual_z(turf/T)
	if(sabre && !sabre.sabre_docked_at && sabre.linked_virtual_z)
		return sabre.linked_virtual_z
	return ..()

/area/shuttle/sabre/Destroy()
	sabre = null
	return ..()

/datum/map_template/shuttle/sabre
	name = "Su-437 Sabre"
	description = "Jednostka pomocnicza Su-437 Sabre, w hangarze stoi jako wnętrze."
	prefix = "aquila/_maps/shuttles/"
	port_id = "sabre"
	suffix = "nanotrasen"
	can_be_bought = FALSE
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)

/datum/map_template/shuttle/sabre/mining
	name = "Su-437 Sabre (górniczy)"
	suffix = "mining"

/obj/docking_port/mobile/sabre
	name = "Su-437 Sabre"
	id = "sabre"
	dynamic_id = TRUE
	area_type = /area/shuttle/sabre
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
	/// Jaką jednostkę overmapy tworzy to wnętrze
	var/craft_type = /obj/structure/overmap/small_craft/transport/sabre/shuttle
	var/obj/structure/overmap/small_craft/transport/sabre/shuttle/craft

/obj/docking_port/mobile/sabre/mining
	craft_type = /obj/structure/overmap/small_craft/transport/sabre/shuttle/mining

/obj/docking_port/mobile/sabre/register()
	. = ..()
	if(!craft && docked)
		var/obj/structure/overmap/small_craft/transport/sabre/shuttle/new_craft = new craft_type(get_turf(src))
		new_craft.link_shuttle(src)

/obj/docking_port/mobile/sabre/Destroy(force)
	if(force && craft)
		craft.shuttle_port = null
		craft = null
	return ..()

/// Port w hangarze: na starcie rundy stawia na sobie wnętrze Sabre
/obj/docking_port/stationary/sabre
	name = "dok Sabre"
	dir = NORTH
	width = 9
	height = 9
	dwidth = 0
	dheight = 0
	roundstart_template = /datum/map_template/shuttle/sabre

/obj/docking_port/stationary/sabre/mining
	name = "dok Sabre (górniczy)"
	roundstart_template = /datum/map_template/shuttle/sabre/mining

/// Miejsce wybrane przez komputer dokowania przy kadłubie celu albo parking w rezerwacji; bez szablonu na starcie
/obj/docking_port/stationary/sabre/temporary
	name = "miejsce lądowania Sabre"
	roundstart_template = null

/obj/structure/overmap/small_craft/transport/sabre/shuttle
	interior_mode = NO_INTERIOR
	possible_interior_maps = list()
	/// Wnętrze (mobilny port shuttle'a)
	var/obj/docking_port/mobile/sabre/shuttle_port
	/// Port, na którym stoi wnętrze; null w locie
	var/obj/docking_port/stationary/sabre_docked_at
	/// Port w hangarze, na którym Sabre zaczął rundę (wraca tam, jeśli jest wolny)
	var/obj/docking_port/stationary/sabre_home_port
	/// Prywatny port w rezerwacji, na którym czeka wnętrze w locie
	var/obj/docking_port/stationary/sabre/temporary/sabre_parking
	var/datum/turf_reservation/sabre_parking_reservation
	/// Przesunięcia pól kadłuba względem mobilnego portu (do szukania miejsca do lądowania)
	var/list/hull_offsets
	/// Przesunięcia pól przed włazem (tam wysiada się z Sabre) względem mobilnego portu
	var/list/exit_offsets

/obj/structure/overmap/small_craft/transport/sabre/shuttle/mining
	icon = 'nsv13/icons/overmap/nanotrasen/carrier_mining.dmi'
	req_one_access = list(ACCESS_CARGO, ACCESS_MINING, ACCESS_TRANSPORT_PILOT)

/obj/structure/overmap/small_craft/transport/sabre/shuttle/Destroy()
	for(var/area/shuttle/sabre/A in linked_areas)
		if(A.sabre == src)
			A.sabre = null
	if(shuttle_port?.craft == src)
		shuttle_port.craft = null
	shuttle_port = null
	sabre_docked_at = null
	sabre_home_port = null
	if(sabre_parking && !sabre_parking.docked)
		qdel(sabre_parking, TRUE)
	sabre_parking = null
	QDEL_NULL(sabre_parking_reservation)
	return ..()

/// Łączy jednostkę z wnętrzem, które właśnie stanęło na porcie w hangarze
/obj/structure/overmap/small_craft/transport/sabre/shuttle/proc/link_shuttle(obj/docking_port/mobile/sabre/port)
	shuttle_port = port
	port.craft = src
	sabre_home_port = port.docked
	linked_areas = list()
	for(var/area/shuttle/sabre/A in port.shuttle_areas)
		A.sabre = src
		A.name = name
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
	sabre_dock_hide(port.docked)

/// Pole przed włazem: pierwsze pole poza wnętrzem w linii prostej od włazu
/obj/structure/overmap/small_craft/transport/sabre/shuttle/proc/sabre_hatch_outside(turf/hatch)
	for(var/dir in GLOB.cardinals)
		var/turf/T = get_step(hatch, dir)
		if(T && !istype(T.loc, /area/shuttle/sabre))
			return T

/// Pola przed włazem w obecnym położeniu wnętrza (port w hangarze może być obrócony)
/obj/structure/overmap/small_craft/transport/sabre/shuttle/proc/sabre_exit_turfs()
	. = list()
	if(!shuttle_port)
		return
	for(var/turf/closed/indestructible/dropship/sabre_hatch/H in shuttle_port.return_turfs())
		var/turf/outside = sabre_hatch_outside(H)
		if(outside)
			. += outside

/// Kształt kadłuba i pola przed włazem względem mobilnego portu, liczone na parkingu (zawsze bez obrotu,
/// tak jak tymczasowe miejsca lądowania)
/obj/structure/overmap/small_craft/transport/sabre/shuttle/proc/sabre_cache_offsets()
	hull_offsets = list()
	exit_offsets = list()
	for(var/turf/T as anything in shuttle_port.return_turfs())
		if(!shuttle_port.shuttle_areas[T.loc])
			continue
		hull_offsets += list(list(T.x - shuttle_port.x, T.y - shuttle_port.y))
	for(var/turf/outside as anything in sabre_exit_turfs())
		exit_offsets += list(list(outside.x - shuttle_port.x, outside.y - shuttle_port.y))

/// Pierwsze pole włazu: tam stoi ukryta jednostka, żeby wąż paliwowy i naprawa sięgały jej z hangaru
/obj/structure/overmap/small_craft/transport/sabre/shuttle/proc/sabre_hatch_turf()
	if(!shuttle_port)
		return
	for(var/turf/closed/indestructible/dropship/sabre_hatch/H in shuttle_port.return_turfs())
		return H

/// Chowa jednostkę przy włazie wnętrza stojącego na porcie
/obj/structure/overmap/small_craft/transport/sabre/shuttle/proc/sabre_dock_hide(obj/docking_port/stationary/port)
	sabre_docked_at = port
	velocity._set(0, 0)
	angular_velocity = 0
	user_thrust_dir = 0
	brakes = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_ABSTRACT
	resistance_flags |= INDESTRUCTIBLE
	var/turf/T = sabre_hatch_turf()
	if(T)
		forceMove(T)

/obj/structure/overmap/small_craft/transport/sabre/shuttle/proc/sabre_unhide()
	sabre_docked_at = null
	density = initial(density)
	mouse_opacity = initial(mouse_opacity)
	invisibility = initial(invisibility)
	resistance_flags = initial(resistance_flags)

/obj/structure/overmap/small_craft/transport/sabre/shuttle/can_move()
	if(sabre_docked_at)
		return FALSE
	return ..()

/// Ludzie we wnętrzu zmieniają okręt, w którym są (dźwięki, paralaksa, wirtualny Z)
/obj/structure/overmap/small_craft/transport/sabre/shuttle/proc/sabre_refresh_occupants()
	for(var/area/shuttle/sabre/A in linked_areas)
		for(var/mob/M in A)
			M.update_overmap()

/// Prywatny port w rezerwacji, na którym wnętrze czeka w locie
/obj/structure/overmap/small_craft/transport/sabre/shuttle/proc/sabre_make_parking()
	if(sabre_parking)
		return sabre_parking
	sabre_parking_reservation = SSmapping.RequestBlockReservation(shuttle_port.width + 2, shuttle_port.height + 2)
	if(!sabre_parking_reservation)
		return
	sabre_parking_reservation.overmap_fallback = src
	var/turf/T = locate(sabre_parking_reservation.bottom_left_coords[1] + 1 + shuttle_port.dwidth, sabre_parking_reservation.bottom_left_coords[2] + 1 + shuttle_port.dheight, sabre_parking_reservation.bottom_left_coords[3])
	sabre_parking = new(T)
	sabre_parking.name = "parking [name]"
	return sabre_parking

/// Start: wnętrze na parking, jednostka na overmapę obok gospodarza
/obj/structure/overmap/small_craft/transport/sabre/shuttle/proc/sabre_launch(mob/user)
	if(!sabre_docked_at || !shuttle_port)
		return FALSE
	var/obj/structure/overmap/host = get_overmap()
	if(!host?.current_system)
		to_chat(user, span_warning("Nie można wystartować: [host ? host : "port"] nie jest teraz w żadnym układzie."))
		return FALSE
	if(get_fuel() <= 0)
		to_chat(user, span_warning("Zbiornik paliwa [src] jest pusty."))
		return FALSE
	var/obj/docking_port/stationary/parking = sabre_make_parking()
	if(!parking)
		to_chat(user, span_warning("Błąd systemu startowego [src]."))
		message_admins("[src] nie zdołał zarezerwować miejsca na wnętrze w locie.")
		return FALSE
	var/obj/docking_port/stationary/old_port = sabre_docked_at
	var/result = shuttle_port.initiate_docking(parking)
	if(result != DOCKING_SUCCESS)
		to_chat(user, span_warning("Zaczepy dokowania [src] się nie zwolniły."))
		message_admins("[src] nie wystartował z [old_port] (błąd [result]).")
		return FALSE
	if(!length(hull_offsets))
		sabre_cache_offsets()
	sabre_unhide()
	last_overmap = host
	check_overmap_elegibility(ignore_position = TRUE, ignore_cooldown = TRUE)
	sabre_refresh_occupants()
	relay('nsv13/sound/effects/ship/boarding_pod.ogg', "<span class='notice'>Zaczepy dokowania zwalniają się i [src] odrywa się od [host].</span>")
	if(istype(old_port, /obj/docking_port/stationary/sabre/temporary))
		qdel(old_port, TRUE)
	log_game("[key_name(user)] launched [src] from [old_port] ([host])")
	return TRUE

/obj/structure/overmap/small_craft/transport/sabre/shuttle/docking_act(obj/structure/overmap/OM)
	if(sabre_docked_at || !shuttle_port || OM == src)
		return FALSE
	if(is_docking_on_cooldown())
		return FALSE
	var/obj/item/fighter_component/docking_computer/DC = loadout.get_slot(HARDPOINT_SLOT_DOCKING)
	if(!DC || !DC.docking_mode)
		return FALSE
	if(istype(OM, /obj/structure/overmap/asteroid) && OM.interior_status != INTERIOR_READY)
		var/obj/structure/overmap/asteroid/AS = OM
		AS.interior_mode = INTERIOR_DYNAMIC
		DC.docking_cooldown = TRUE
		RegisterSignal(AS, COMSIG_INTERIOR_DONE_LOADING, PROC_REF(sabre_asteroid_loaded))
		SSstar_system.queue_for_interior_load(AS)
		return TRUE
	DC.docking_cooldown = TRUE
	INVOKE_ASYNC(src, PROC_REF(sabre_try_land), OM)
	return TRUE

/obj/structure/overmap/small_craft/transport/sabre/shuttle/proc/sabre_asteroid_loaded(obj/structure/overmap/asteroid/AS)
	SIGNAL_HANDLER
	UnregisterSignal(AS, COMSIG_INTERIOR_DONE_LOADING)
	INVOKE_ASYNC(src, PROC_REF(sabre_try_land), AS)

/// Szuka miejsca (to może potrwać kilka ticków) i ląduje; bez miejsca komputer dokowania odpoczywa 10 sekund
/obj/structure/overmap/small_craft/transport/sabre/shuttle/proc/sabre_try_land(obj/structure/overmap/OM)
	var/obj/item/fighter_component/docking_computer/DC = loadout.get_slot(HARDPOINT_SLOT_DOCKING)
	if(pilot)
		to_chat(pilot, span_notice("Komputer dokowania szuka miejsca do lądowania przy [OM]..."))
	var/obj/docking_port/stationary/port = sabre_find_landing(OM)
	if(QDELETED(src) || QDELETED(OM) || sabre_docked_at)
		if(istype(port, /obj/docking_port/stationary/sabre/temporary))
			qdel(port, TRUE)
		return
	if(!port || !sabre_land(OM, port))
		if(pilot && !port)
			to_chat(pilot, span_warning("Komputer dokowania nie znajduje miejsca do lądowania przy [OM]."))
		if(DC)
			addtimer(VARSET_CALLBACK(DC, docking_cooldown, FALSE), 10 SECONDS)

/// Wolny port Sabre celu, a bez niego miejsce przy kadłubie, z którego właz wychodzi na pokład
/obj/structure/overmap/small_craft/transport/sabre/shuttle/proc/sabre_find_landing(obj/structure/overmap/OM)
	if(sabre_home_port && !sabre_home_port.docked && sabre_home_port.get_overmap() == OM)
		return sabre_home_port
	for(var/obj/docking_port/stationary/sabre/port in SSshuttle.stationary)
		if(istype(port, /obj/docking_port/stationary/sabre/temporary) || port.docked)
			continue
		if(port.get_overmap() == OM && shuttle_port.canDock(port) == SHUTTLE_CAN_DOCK)
			return port
	var/turf/center = sabre_landing_center(OM)
	if(!center)
		return
	var/turf/bottom_left = sabre_find_spot(OM, center)
	if(!bottom_left)
		return
	var/obj/docking_port/stationary/sabre/temporary/spot = new(bottom_left)
	spot.name = "miejsce lądowania przy [OM]"
	return spot

/// Gdzie szukać miejsca do lądowania: środek wnętrza celu albo jego punkt dokowania
/obj/structure/overmap/small_craft/transport/sabre/shuttle/proc/sabre_landing_center(obj/structure/overmap/OM)
	if(length(OM.occupying_levels))
		var/datum/space_level/level = OM.occupying_levels[1]
		return locate(round(world.maxx / 2), round(world.maxy / 2), level.z_value)
	if(OM.roomReservation)
		var/list/bl = OM.roomReservation.bottom_left_coords
		var/list/tr = OM.roomReservation.top_right_coords
		return locate(round((bl[1] + tr[1]) / 2), round((bl[2] + tr[2]) / 2), bl[3])
	if(length(OM.docking_points))
		return get_turf(OM.docking_points[1])

/// Czy wnętrze zmieści się z mobilnym portem na polu (x, y, z)
/obj/structure/overmap/small_craft/transport/sabre/shuttle/proc/sabre_spot_free(obj/structure/overmap/OM, x, y, z)
	for(var/list/offset as anything in hull_offsets)
		var/tx = x + offset[1]
		var/ty = y + offset[2]
		if(tx <= TRANSITIONEDGE || ty <= TRANSITIONEDGE || tx > world.maxx - TRANSITIONEDGE || ty > world.maxy - TRANSITIONEDGE)
			return FALSE
		var/turf/T = locate(tx, ty, z)
		if(!isspaceturf(T) || istype(T, /turf/open/space/transit) || istype(T.loc, /area/shuttle))
			return FALSE
		if(OM.roomReservation && SSmapping.used_turfs[T] != OM.roomReservation)
			return FALSE
		if(OM.boarding_interior && OM.interior_mode == INTERIOR_EXCLUSIVE && tx <= OM.boarding_interior.width && ty <= OM.boarding_interior.height)
			return FALSE // To wnętrze zniknie razem z poziomem abordażu
		for(var/atom/movable/AM as anything in T)
			if(AM.density)
				return FALSE
	return TRUE

/// Najpierw miejsca, z których właz wychodzi prosto na podłogę celu, potem wolny kosmos najbliżej środka
/obj/structure/overmap/small_craft/transport/sabre/shuttle/proc/sabre_find_spot(obj/structure/overmap/OM, turf/center)
	var/z = center.z
	var/best_distance = INFINITY
	var/turf/best
	for(var/turf/open/floor in RANGE_TURFS(SABRE_LANDING_SEARCH_RANGE, center))
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
			if(sabre_spot_free(OM, x, y, z))
				best = locate(x, y, z)
				best_distance = distance
				break
		CHECK_TICK
	if(best)
		return best
	for(var/radius in 0 to SABRE_LANDING_SEARCH_RANGE step 2)
		for(var/turf/T as anything in RANGE_TURFS(radius, center) - RANGE_TURFS(max(radius - 2, -1), center))
			if(sabre_spot_free(OM, T.x, T.y, z))
				return T
		CHECK_TICK

/// Lądowanie: wnętrze na port, jednostka chowa się przy włazie (jak transfer_from_overmap myśliwców)
/obj/structure/overmap/small_craft/transport/sabre/shuttle/proc/sabre_land(obj/structure/overmap/OM, obj/docking_port/stationary/port)
	if(sabre_docked_at || !shuttle_port)
		return FALSE
	var/result = shuttle_port.initiate_docking(port)
	if(result != DOCKING_SUCCESS)
		if(istype(port, /obj/docking_port/stationary/sabre/temporary) && !port.docked)
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
	resize = 0
	pixel_w = initial(pixel_w)
	pixel_z = initial(pixel_z)
	bound_width = initial(bound_width)
	bound_height = initial(bound_height)
	var/turf/T = sabre_hatch_turf()
	if(current_system)
		current_system.remove_ship(src, T, is_ftl_jump = FALSE)
	OM.overmaps_in_ship += src
	weapon_safety = TRUE
	sabre_dock_hide(port)
	SEND_SIGNAL(src, COMSIG_FTL_STATE_CHANGE)
	if(reserved_z)
		free_treadmills += reserved_z
		reserved_z = null
	relay('nsv13/sound/effects/ship/boarding_pod.ogg', "<span class='notice'>[src] dokuje przy [OM]. Zaczepy zablokowane, właz odblokowany.</span>")
	for(var/mob/living/M in operators)
		stop_piloting(M)
	sabre_refresh_occupants()
	return TRUE

/// Wejście przez właz: tak jak wejście do promu desantowego, tylko z hangaru
/obj/structure/overmap/small_craft/transport/sabre/shuttle/proc/sabre_board(mob/living/user)
	if(!sabre_docked_at)
		return FALSE
	if(!allowed(user))
		to_chat(user, span_warning("Odmowa dostępu."))
		return FALSE
	to_chat(user, span_notice("Otwierasz właz [src] i wchodzisz do środka..."))
	if(!do_after(user, 2 SECONDS, target = user))
		return FALSE
	enter(user)
	return TRUE

/// Wyjście przez wrota w burcie kokpitu na pole przed włazem
/obj/structure/overmap/small_craft/transport/sabre/shuttle/proc/sabre_leave(atom/movable/AM)
	var/list/exits = sabre_exit_turfs()
	if(!length(exits))
		return FALSE
	var/turf/T = exits[1]
	for(var/turf/candidate as anything in exits)
		if(!candidate.density)
			T = candidate
			break
	var/mob/user = ismob(AM) ? AM : null
	var/atom/movable/pulled = user?.pulling
	playsound(src, 'nsv13/sound/effects/footstep/ladder2.ogg', 50)
	if(pulled)
		pulled.forceMove(T)
	AM.forceMove(T)
	if(pulled)
		user.start_pulling(pulled)
	mobs_in_ship -= AM
	return TRUE

/obj/structure/overmap/small_craft/transport/sabre/shuttle/exit(mob/user)
	if(sabre_docked_at)
		return sabre_leave(user)
	return ..()

/obj/structure/overmap/small_craft/transport/sabre/shuttle/examine(mob/user)
	. = ..()
	. += span_notice("Paliwo: [round(get_fuel())]/[round(get_max_fuel())]. Stan kadłuba: [round(obj_integrity / max_integrity * 100)]%.")

// Wrota w burcie kokpitu: wyjście na zewnątrz w doku, zablokowane w locie

/turf/closed/indestructible/dropship/entry/sabre
	desc = "Masywne wrota. W doku wychodzi się nimi na zewnątrz, w locie są zablokowane."

/turf/closed/indestructible/dropship/entry/sabre/Bumped(atom/movable/AM)
	var/area/shuttle/sabre/A = loc
	if(!istype(A) || !A.sabre || !ismob(AM))
		return
	if(A.sabre.sabre_docked_at)
		A.sabre.sabre_leave(AM)
	else if(ismob(AM))
		to_chat(AM, span_warning("Wrota są zablokowane w trakcie lotu."))

// Właz w lewej gondoli: wejście i obsługa jednostki od strony hangaru

/turf/closed/indestructible/dropship/sabre_hatch
	name = "właz Sabre"
	desc = "Właz w gondoli Sabre. Pustą ręką się wchodzi, a tu też tankuje się jednostkę, montuje części i naprawia kadłub."

/turf/closed/indestructible/dropship/sabre_hatch/proc/get_sabre()
	var/area/shuttle/sabre/A = loc
	return istype(A) ? A.sabre : null

/turf/closed/indestructible/dropship/sabre_hatch/examine(mob/user)
	. = ..()
	var/obj/structure/overmap/small_craft/transport/sabre/shuttle/S = get_sabre()
	if(S)
		. += S.examine(user)

/turf/closed/indestructible/dropship/sabre_hatch/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	var/obj/structure/overmap/small_craft/transport/sabre/shuttle/S = get_sabre()
	if(S && isliving(user))
		return S.sabre_board(user)

/turf/closed/indestructible/dropship/sabre_hatch/attack_robot(mob/user)
	if(user.Adjacent(src))
		return attack_hand(user)

/turf/closed/indestructible/dropship/sabre_hatch/attackby(obj/item/W, mob/user, params)
	var/obj/structure/overmap/small_craft/transport/sabre/shuttle/S = get_sabre()
	if(S?.sabre_docked_at)
		return S.attackby(W, user, params)
	return ..()

/turf/closed/indestructible/dropship/sabre_hatch/MouseDrop_T(atom/movable/target, mob/user)
	var/obj/structure/overmap/small_craft/transport/sabre/shuttle/S = get_sabre()
	if(!S?.sabre_docked_at || !isliving(user) || !user.Adjacent(src))
		return ..()
	if(isliving(target))
		if(target == user)
			return S.sabre_board(user)
		return ..()
	return S.MouseDrop_T(target, user)

// Wąż paliwowy na włazie tankuje Sabre, który czeka przy nim ukryty
/obj/item/cryofuel_nozzle/afterattack(atom/target, mob/user, proximity)
	if(istype(target, /turf/closed/indestructible/dropship/sabre_hatch))
		var/turf/closed/indestructible/dropship/sabre_hatch/hatch = target
		var/obj/structure/overmap/small_craft/transport/sabre/shuttle/S = hatch.get_sabre()
		if(S?.sabre_docked_at)
			return ..(S, user, proximity)
	return ..()

// Ster: w doku pyta o start, potem steruje jak ster promu desantowego

/obj/machinery/computer/ship/helm/console/dropship/sabre
	name = "stanowisko pilota Sabre"

/// Ster zawsze steruje swoim Sabre, także w doku, gdzie pola wnętrza należą do okrętu gospodarza
/obj/machinery/computer/ship/helm/console/dropship/sabre/get_overmap(failsafe = FALSE)
	var/area/shuttle/sabre/A = get_area(src)
	return istype(A) ? A.sabre : null

/obj/machinery/computer/ship/helm/console/dropship/sabre/attack_hand(mob/living/user)
	var/obj/structure/overmap/small_craft/transport/sabre/shuttle/S = has_overmap()
	if(S?.sabre_docked_at && isliving(user))
		if(tgui_alert(user, "[S] stoi w doku. Startujemy?", name, list("Start", "Anuluj")) != "Start")
			return TRUE
		if(QDELETED(S) || !S.sabre_docked_at || !user.Adjacent(src) || !S.sabre_launch(user))
			return TRUE
	return ..()

#undef SABRE_LANDING_SEARCH_RANGE
